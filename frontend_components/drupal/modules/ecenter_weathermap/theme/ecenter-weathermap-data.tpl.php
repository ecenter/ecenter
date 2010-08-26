<p><?php print $permalink; ?></p>

<div id="traceroute">
</div>

<?php /*
<div class="traceroute-wrapper">
  <?php foreach (array('forward' => $data['forward'], 'reverse' => $data['reverse']) as $direction => $traceroutes): ?>
    <?php foreach ($traceroutes as $trace_id => $traceroute): ?>
    <div class="traceroute">
      <h2><?php print t('Trace: @id (@direction)', array('@id' => $trace_id, '@direction' => $direction)); ?></h2>
      <?php foreach ($traceroute as $hop): ?>
      <div class="hop-wrapper">
        <h3>
          <?php print t('Hop #@id (@ip)', array('@id' => $hop['hop']['hop_id'], '@ip' => $hop['hop']['hop_ip'])); ?>
        </h3>
        <div class="hop_data">
          <?php foreach ($hop['data'] as $type => $hop_data): ?>
          <?php if (!empty($hop_data)): ?>
          <div class="clearfix data-wrapper <?php print $type; ?>-data-wrapper">
            <?php print theme('ecenter_weathermap_render_data_'. $type, $hop_data); ?>
          </div>
          <?php endif; ?>
          <?php endforeach; ?>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endforeach; ?>
  <?php endforeach; ?>
</div>
*/
?>
