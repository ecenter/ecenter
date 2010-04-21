<?php
Part::input($metadata, 'metadata');
?>
	<fieldset>
	<h3><?php echo Html::anchor(Url::action('metadataController::details', $metadata->metadata), 'metadata #' . $metadata->metadata) ?></h3>
	<p>
		<strong>Metaid</strong>: <?php echo $metadata->metaid; ?><br />
		<strong>Service</strong>: <?php echo Html::anchor(Url::action('serviceController::details',  $metadata->service),   $metadata->service) ?> <br />
		<strong>Subject</strong>: <?php echo htmlentities($metadata->subject); ?><br />
		<strong>Parameters</strong>: <?php echo htmlentities($metadata->parameters); ?><br />

	</p>

	</fieldset>
