<div id="results-toolbar" class="clear-block">
  <?php if ($issuelink || $permalink): ?>
  <div class="links">
    <?php if ($issuelink): ?>
    <?php print $issuelink; ?>
    <?php endif; ?>

    <?php if ($permalink): ?>
    <?php print $permalink; ?>
    <?php endif; ?>
  </div>
  <?php endif; ?>
</div>

<div id="results">
  <h2>
    <span class="src-dst"><?php print $src_dst; ?></span>, 
    <span class="date-range"><?php print $date_range; ?></span>
  </h2>
  
  <div id="end-to-end-wrapper" class="clear-block">
    <div id="end-to-end-results">
      <?php print $end_to_end; ?>
    </div>
    <div id="end-to-end-charts">
      Chart container!
    </div>
  </div>

  <div id="hop-wrapper" class="clear-block">
    <div id="traceroute"></div>
    <div id="snmp-results">
      <?php print $hops; ?>
    </div>
  </div>
<div>
