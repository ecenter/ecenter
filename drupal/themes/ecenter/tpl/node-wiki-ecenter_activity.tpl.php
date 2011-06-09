<div class="node">
  <div class="picture"><?php print $picture; ?></div>
  <div class="meta">
    <span class="date"><?php print $date; ?></span>
    <span class="type"><?php print $node_type; ?></span>
    <span class="title">
      <a href="<?php print $node_url ?>" title="<?php print $title ?>">
        <?php print $title ?>
      </a>
    </span>
    <span class="action"><?php print $action; ?></span>
    <span class="name"><?php print $name; ?></span>
    <span class="picture"><?php // print $picture; ?></span>
  </div>
  <div class="details">
    <span class="message">
      <label><?php print t('Log message:'); ?></label>
      <span class="text"><?php print $message; ?></span>
    </span>
  </div>

  <div class="test">
    <?php print $test; ?>
  </div>
</div>
