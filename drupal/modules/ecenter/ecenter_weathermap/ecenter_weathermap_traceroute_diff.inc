<?php
// $Id$

/**
 * @file
 * Diff an E-center traceroute
 *
 * Adapted for E-center from http://paulbutler.org/archives/a-simple-diff-algorithm-in-php/
 *
 * Available on Github at:
 * http://github.com/paulgb/simplediff/blob/5bfe1d2a8f967c7901ace50f04ac2d9308ed3169/simplediff.php
 *
 * The original code is released under the zlib/libpng license
 * (http://www.opensource.org/licenses/zlib-license.php).
 */

function ecenter_weathermap_traceroute_diff($forward, $reverse) {
  foreach ($forward as $findex => $ovalue) {
    // Find matching sequences
    $rkeys = ecenter_weathermap_traceroute_array_keys($reverse, $ovalue);

    foreach ($rkeys as $rindex) {
      $matrix[$findex][$rindex] = isset($matrix[$findex - 1][$rindex - 1]) ? $matrix[$findex - 1][$rindex - 1] + 1 : 1;
      if ($matrix[$findex][$rindex] > $maxlen) {
        $maxlen = $matrix[$findex][$rindex];
        $fmax = $findex + 1 - $maxlen;
        $rmax = $rindex + 1 - $maxlen;
      }
    }
  }

  // Ignore extraneous empty diffs
  if (empty($forward) && empty($reverse)) {
    return array();
  }

  if ($maxlen == 0) {
    return array(array(
      'diff' => array(
        'forward' => $forward,
        'reverse' => $reverse,
      )
    ));
  }

  // Take matches and turn them into a set of associated pairs
  $fwd_slices = array_slice($forward, $fmax, $maxlen);
  $rev_slices = array_slice($reverse, $rmax, $maxlen);
  $slices = array();
  while (!empty($fwd_slices) && !empty($rev_slices)) {
    $slices[] = array(
      'match' => array(
        'forward' => array(array_pop($fwd_slices)),
        'reverse' => array(array_pop($rev_slices)),
      ),
    );
  }

  // Recurse into non-matching sequences while mashing together with matching
  // sequences
  return array_merge(
    ecenter_weathermap_traceroute_diff(array_slice($forward, 0, $fmax), array_slice($reverse, 0, $rmax)),
    $slices,
    ecenter_weathermap_traceroute_diff(array_slice($forward, $fmax + $maxlen), array_slice($reverse, $rmax + $maxlen))
  );
}

function ecenter_weathermap_traceroute_array_keys($hops, $match) {
  $return = array();
  foreach ($hops as $k => $hop) {
    if ($hop['hop']['hop_ip'] == $match['hop']['hop_ip']) {
      $return[] = $k;
      break; 
    }
    elseif ($hop['hop']['netblock'] == $match['hop']['netblock']) {
      $return[] = $k;
      break;
    }
  }
  return $return;
}
