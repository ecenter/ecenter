<div id="results">
  <div id="results-title" class="clearfix">
    <?php if ($issuelink): ?>
    <div class="issuelink">
      <?php print $issuelink; ?>
    </div>
    <?php endif; ?>
    <h2><?php print $title; ?></h2>
    <?php if ($permalink): ?>
    <div class="permalink">
      <?php print $permalink_field; ?>
      <?php print $permalink; ?>
    </div>
    <?php endif; ?>
  </div>
  <div id="hop-wrapper" class="clearfix">
    <?php print $hops; ?>
  </div>
  <div id="end-to-end-wrapper" class="clearfix">
    <?php print $end_to_end; ?>
  </div>
</div>
