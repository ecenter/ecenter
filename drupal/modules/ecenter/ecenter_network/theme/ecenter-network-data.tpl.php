<div id="results">
  <?php /* <div id="results-title" class="clearfix">
    <h2><?php print $title; ?></h2>
    </div> */ ?>
  <div id="hop-wrapper" class="clearfix">
    <?php print $hops; ?>
  </div>
  <div id="end-to-end-wrapper" class="clearfix">
    <?php print $end_to_end; ?>
  </div>

  <?php if ($permalink): ?>
  <div class="permalink">
    <?php print $permalink_field; ?>
    <?php print $permalink; ?>
  </div>
  <?php endif; ?>

</div>
