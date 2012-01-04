<div id="results">
  <div id="hop-wrapper" class="clearfix">
    <?php /* <div id="result-links-wrapper" class="clearfix">
      <div class="title-col">
        <h2><?php print $title; ?></h2>
      </div>

      <div class="meta-col">

        <div class="links-wrapper">
          <?php if ($permalink): ?>
          <div class="permalink">
            <?php print $permalink_field; ?>
            <?php print $permalink; ?>
          </div>
          <?php endif; ?>
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
        </div>

        <?php if ($fds && $ads): ?>
        <div id="analysis-wrapper" class="clearfix">
          <?php if ($fds): ?>
          <?php print $fds; ?>
          <?php endif; ?>

          <?php if ($ads): ?>
          <?php print $ads; ?>
          <?php endif; ?>
        </div>
        <?php endif; ?>

        <div id="timezone-wrapper">
          <?php print $timezone_select; ?>
        </div>

      </div>
    </div> */ ?>

    <?php print $ecenter_messages; ?>

    <?php print $hops; ?>
  </div>

  <div id="end-to-end-wrapper" class="clearfix">
    <?php print $end_to_end; ?>
  </div>
</div>
