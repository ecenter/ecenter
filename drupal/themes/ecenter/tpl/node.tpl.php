<?php
// $Id$
?>
<div id="node-<?php print $node->nid; ?>" class="node<?php if ($sticky) { print ' sticky'; } ?><?php if (!$status) { print ' node-unpublished'; } ?> clearfix">

<?php if (!$page): ?>
  <h2><a href="<?php print $node_url ?>" title="<?php print $title ?>"><?php print $title ?></a></h2>
<?php endif; ?>

  <div class="content">
    <?php print $content ?>
  </div>

  <?php if ($terms): ?>
    <div class="terms terms-inline"><?php print t('Tags:'); ?><?php print $terms ?></div>
  <?php endif;?>

  <?php print $links; ?>
</div>
