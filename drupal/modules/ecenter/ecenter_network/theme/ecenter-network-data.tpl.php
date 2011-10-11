<div id="results">
  <div id="hop-wrapper" class="clearfix">
    <div id="result-links-wrapper" class="clearfix">
      <h2><?php print $title; ?></h2>

      <?php if ($issuelink): ?>
      <div class="issuelink">
        <?php print $issuelink; ?>
      </div>
      <?php endif; ?>
      <?php if ($issues): ?>
      <div class="issues">
        <?php print $issues; ?>
      </div>
      <?php endif; ?>
      <?php if ($permalink): ?>
      <div class="permalink">
        <?php print $permalink; ?>
        <?php print $permalink_field; ?>
      </div>
      <?php endif; ?>
    </div>

    <?php print $hops; ?>
  </div>

  <div id="end-to-end-wrapper" class="clearfix">
    <?php print $end_to_end; ?>
  </div>
</div>
