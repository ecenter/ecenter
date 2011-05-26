<p>
<?php print t('Time period: From @start to @end', 
  array('@start' => $start, '@end' => $end)); ?>
</p>

<p><?php print t('All times expressed in your local timezone.'); ?></p>

<h2><?php print t('Hub status'); ?></h2>
<?php print $health_table; ?>
