<div class="node">
  <div class="picture"><?php print $picture; ?></div>
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
      <?php if ($groups): ?>
      <span class="groups">
        <?php print format_plural(count($node->og_groups), 'in group', 'in groups'); ?>
        <?php print $groups; ?>
      </span>
      <?php endif; ?>
    </div>
    <div class="details">
      <span class="message">
        <label><?php print t('@user wrote:', array('@user' => $name_plain)); ?></label>
        <span class="text"><?php print $message; ?></span>
      </span>
    </div>
  <?php endif; ?>
</div>
