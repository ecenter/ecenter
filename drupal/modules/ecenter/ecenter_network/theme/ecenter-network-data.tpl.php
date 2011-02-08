<div id="results-toolbar" class="clear-block">
  <h2><?php print $title; ?></h2>
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
  <div id="end-to-end-wrapper" class="clear-block">
    <h3><?php print t('End to end results'); ?></h3>
    <?php print $end_to_end; ?>
  </div>

  <div id="hop-wrapper" class="clear-block">
    <div id="snmp-results">
      <?php print $hops; ?>
    </div>
  </div>
<div>
