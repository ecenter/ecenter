<p>
<?php print t('Time period: From @start to @end', 
  array('@start' => $start, '@end' => $end)); ?>
</p>

<p><?php print t('All times expressed in your local timezone.'); ?></p>

<h2><?php print t('Metadata count'); ?></h2>
<?php print $health_table; ?>

<h2><?php print t('Measurement period'); ?></h2>
<?php print $period_table; ?>
