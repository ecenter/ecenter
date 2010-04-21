<?php 
Layout::extend('layouts/keywordsService');
$title = 'Details of keywords_service #' . $keywordsService->ref_id ;
?>

<?php Part::draw('keywordsService/details', $keywordsService) ?>

<?php echo Html::anchor(Url::action('keywords_serviceController::index'), 'Back to list of keywordsServices') ?>
<hr />
