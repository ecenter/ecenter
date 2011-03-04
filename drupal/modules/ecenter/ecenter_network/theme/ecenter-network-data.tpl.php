<div id="results-title" class="clearfix">
  <h2><?php print $title; ?></h2>
  <?php if ($permalink): ?>
  <?php print $permalink; ?>
  <?php endif; ?>
</div>

<div id="results">
  <div id="hop-wrapper" class="clear-block">
    <?php print $hops; ?>
  </div>
  <div id="end-to-end-wrapper" class="clear-block">
    <?php print $end_to_end; ?>
  </div>
</div>
