<?php
  $headers = array('Hop IP', 'Hop ID', 'Hop name', 'hub');
  $base_traceroute = theme('table', $headers, $traceroutes['base']);
  $settings = array();
?>

<p>We start with base reference traceroute, and will draw traceroute subway maps based on permutations of the base traceroute diffed with it.</p>

<?php /*
<h2>Reference traceroute</h2>
<div class="clearfix traceroute-test-wrapper">
  <div class="traceroute-test-col">
    <?php print $base_traceroute; ?>
  </div>
</div>
 */ ?>

<?php // @TODO loop? ?>

<h2>Reference - reference</h2>
<div id="base" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['base']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'base',
      'diff' => $diff,
    );
  ?>
</div>

<?php
  drupal_add_js(array('ecenter_test_traceroute' => $settings), 'setting');
?>

<h2>Missing single hops</h2>
<div id="missing-hop" class="clearfix traceroute-test-wrapper">
  <div class="clearfix">
  <div class="visual-traceroute-wrapper"></div>
    <div class="traceroute-test-col">
      <h3>Missing single hop</h3>
      <?php print theme('table', $headers, $traceroutes['missing_one']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['missing_one']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'missing-hop',
      'diff' => $diff,
    );
  ?>
</div>

<h2>Missing multiple hops</h2>
<div id="missing-multiple" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Missing multiple hops</h3>
      <?php print theme('table', $headers, $traceroutes['missing_multiple']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['missing_multiple']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'missing-multiple',
      'diff' => $diff,
    );
  ?>
</div>

<h2>Additional single hop</h2>
<div id="add-hop" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Additional single hop</h3>
      <?php print theme('table', $headers, $traceroutes['add_one']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['add_one']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'add-hop',
      'diff' => $diff,
    );
  ?>
</div>

<h2>Additional multiple hops</h2>
<div id="add-multiple" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Additional multiple hops</h3>
      <?php print theme('table', $headers, $traceroutes['add_multiple']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['add_multiple']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'add-multiple',
      'diff' => $diff,
    );
  ?>
</div>

<h2>Additional multiple hops - Missing single hop</h2>
<div id="add-multiple" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Additional multiple hops</h3>
      <?php print theme('table', $headers, $traceroutes['add_multiple']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Missing one hop</h3>
      <?php print theme('table', $headers, $traceroutes['combined']); ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['missing_multiple'], 
      $traceroutes['add_multiple']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'add-multiple',
      'diff' => $diff,
    );
  ?>
</div>



<h2>Combined</h2>
<div id="combined" class="clearfix traceroute-test-wrapper">
  <div class="visual-traceroute-wrapper"></div>
  <div class="clearfix">
    <div class="traceroute-test-col">
      <h3>Combined (skips + hops)</h3>
      <?php print theme('table', $headers, $traceroutes['combined']); ?>
    </div>
    <div class="traceroute-test-col">
      <h3>Reference traceroute</h3>
      <?php print $base_traceroute; ?>
    </div>
  </div>
  <?php
    $diff = ecenter_network_traceroute_diff($traceroutes['base'], 
      $traceroutes['combined']);
    //kpr($diff);
    $settings[] = array(
      'id' => 'combined',
      'diff' => $diff,
    );
  ?>
</div>

<?php
  drupal_add_js(array('ecenter_test_traceroute' => $settings), 'setting');
?>



