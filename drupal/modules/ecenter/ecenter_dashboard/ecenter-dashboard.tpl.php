<div class="main-content">
  <?php foreach ($main_content as $name => $block): ?>
  <div id="dashboard-<?php print $name; ?>" class="row clearfix">
    <h2><?php print $block['subject']; ?></h2>
    <div class="description"><?php print $block['description']; ?></div>
    <div class="content"><?php print $block['content']; ?></div>
  </div>
  <?php endforeach; ?>
</div>

<div class="secondary-content">
  <?php foreach ($secondary_content as $name => $block): ?>
  <div id="dashboard-<?php print $name; ?>" class="row clearfix">
    <h2><?php print $block['subject']; ?></h2>
    <div class="description"><?php print $block['description']; ?></div>
    <div class="content"><?php print $block['content']; ?></div>
  </div>
  <?php endforeach; ?>
</div>
