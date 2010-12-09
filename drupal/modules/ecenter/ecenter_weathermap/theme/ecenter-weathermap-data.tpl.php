<div class="results-header">
  <h2>
    <span class="src-dst"><?php print $src_dst; ?></span>, 
    <span class="date-range"><?php print $date_range; ?></span>
  </h2>

  <?php if ($issuelink || $permalink): ?>
  <div class="links">
    <?php if ($issuelink): ?>
    <span class="issue-link"><?php print $issuelink; ?></span>
    <?php endif; ?>

    <?php if ($permalink): ?>
    <span class="permalink"><?php print $permalink; ?></span>
    <?php endif; ?>
  </div>
  <?php endif; ?>

</div>

<div class="end-to-end-results">
  <?php print $end_to_end_table; ?>
</div>

<div class="hop-results clearfix">
  <div id="traceroute"></div>
  <div id="results">
    <?php print $snmp; ?>
  </div>
</div>
