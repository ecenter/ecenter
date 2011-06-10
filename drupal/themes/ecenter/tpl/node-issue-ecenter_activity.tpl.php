<div class="node <?php print $classes; ?>">
  <div class="picture-wrapper"><?php print $picture; ?></div>
  <?php if ($comment_mode): ?>
    <div class="meta">
      <span class="date"><?php print $date; ?></span>
      <span class="name"><?php print $name; ?></span>
      <span class="action"><?php print $action; ?></span>
      <span class="title">
        <a href="<?php print $node_url ?>" title="<?php print $title ?>">
          <?php print $title ?>
        </a>
      </span>
    </div>
    <div class="details">
      <span class="message">
        <label><?php print t('@user wrote:', array('@user' => $name_plain)); ?></label>
        <span class="text"><?php print $message; ?></span>
      </span>
    </div>

    <?php if ($groups): ?>
    <div class="groups">
      <label><?php print format_plural(count($node->og_groups), 'Group:', ' Groups:'); ?></label>
      <?php print $groups; ?>
    </div>
    <?php endif; ?>

  <?php else: ?>
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
        <label><?php print t('@user wrote:', array('@user' => $name_plain)); ?></label>
        <span class="text"><?php print $message; ?></span>
      </span>
    </div>

    <?php if ($groups): ?>
    <div class="groups">
      <label><?php print format_plural(count($node->og_groups), 'Group:', ' Groups:'); ?></label>
      <?php print $groups; ?>
    </div>
    <?php endif; ?>

  <?php endif; ?>
</div>
