<?php
// $Id$
?>
<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> clearfix">

<?php if (!$page): ?>
  <h2><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print $title ?></a></h2>
<?php endif; ?>

  <?php if ($submitted): ?>
    <div class="submitted clearfix">
      <?php print $picture; ?>
      <?php print $submitted; ?>
    </div>
  <?php endif; ?>

  <?php if ($terms): ?>
    <div class="terms terms-inline">
      <span class="label"><?php print t('Tags:'); ?></span>
      <?php print $terms ?>
    </div>
  <?php endif;?>

  <div class="content">
    <?php print $content ?>
  </div>

  <?php print $links; ?>
</div>
