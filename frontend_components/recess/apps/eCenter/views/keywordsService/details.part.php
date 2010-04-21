<?php
Part::input($keywordsService, 'keywords_service');
?>
 	<fieldset>
	<h3><?php echo Html::anchor(Url::action('keywords_serviceController::details', $keywordsService->ref_id), 'keywords_service #' . $keywordsService->ref_id) ?></h3>
	<p>
		<strong>Keyword</strong>: <?php echo Html::anchor(Url::action('keywordController::details',   $keywordsService->keyword), 'keyword #' .  $keywordsService->keyword) ?><br />
		<strong>Service</strong>: <?php echo Html::anchor(Url::action('serviceController::details',  $keywordsService->service), 'service #' . $keywordsService->service ) ?><br />

	</p>
 
	</fieldset>
 
