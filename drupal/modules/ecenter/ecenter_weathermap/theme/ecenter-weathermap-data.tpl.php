<div class="end-to-end-results">
  <?php if ($issuelink): ?>
  <div class="issue-link">
    <?php print $issuelink; ?>
  </div>
  <?php endif; ?>

  <div class="date-range">
    <?php print $date_range; ?>
  </div>

  <?php print $query_table; ?>

  <?php print $end_to_end_table; ?>

  <div class="permalink">
    <?php print $permalink; ?>
  </div>
</div>

<div class="hop-results clearfix">

  <div id="traceroute"></div>

  <div id="results">
    <?php print $snmp; ?>
  </div>

</div>
