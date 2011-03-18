<div id="homebox-block-<?php print $block->module .'-'. $block->delta; ?>" class="<?php print $block->homebox_classes ?> clearfix block block-<?php print $block->module ?>">
  <div class="homebox-portlet-inner">
    <h2 class="portlet-header"><span class="portlet-title"><?php print $block->subject ?></span></h2>
    <div class="portlet-config">
      <?php if ($page->settings['color']): ?>
        <div class="homebox-colors">
          <span class="homebox-color-message"><?php print t('Select a color') . ':'; ?></span>
          <?php for ($i=0; $i < HOMEBOX_NUMBER_OF_COLOURS; $i++): ?>
            <span class="homebox-color-selector" style="background-color: <?php print $page->settings['colors'][$i] ?>;">&nbsp;</span>
          <?php endfor ?>
        </div>
      <?php endif; ?>
      <?php if ($block->module == 'homebox'): ?>
        <button id="delete-<?php print $block->module . '_' . $block->delta; ?>" class="homebox-delete-custom-link"><?php print t('Delete'); ?></button>
        <button id="edit-<?php print $block->module . '_' . $block->delta; ?>" class="homebox-edit-custom-link"><?php print t('Edit'); ?></button>
      <?php endif; ?>
    </div>
    <div class="portlet-content content"><?php print $block->content; ?></div>
    <?php print $block->hidden; ?>
  </div>
</div>
<div class="clear-block"> </div>
