<div class="node <?php print $classes; ?>">
  <div class="picture-wrapper"><?php print $picture; ?></div>
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
  </div>
  <div class="details">
    <span class="message">
      <label><?php print t('Log message:'); ?></label>
      <span class="text"><?php print $message; ?></span>
    </span>
  </div>

  <?php if ($groups): ?>
  <div class="groups">
    <label><?php print format_plural(count($node->og_groups), 'Group:', ' Groups:'); ?></label>
    <?php print $groups; ?>
  </div>
  <?php endif; ?>
</div>
