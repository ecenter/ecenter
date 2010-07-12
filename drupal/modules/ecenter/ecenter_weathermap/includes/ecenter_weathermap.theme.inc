<?php
// $Id$

function template_preprocess_ecenter_weathermap(&$vars) {
  dpm($vars);
}

function theme_ecenter_weathermap_traceroute($hops) {
  $output = '';
  foreach ($hops as $hop) {
    $output .= ' '. $hop->hop_ip;
  }
  return $output;
}
// function template_preprocess_ecenter_weathermap_traceroute(&$vars) {}

/**
 * Theme services for use in options list.  Should always return plaintext!
 */
function theme_ecenter_weathermap_hop_option($hop) {
  return $hop->nodename .' ('. $hop->ip_noted .')';
}
