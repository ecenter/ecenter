<?php 
Layout::extend('layouts/keywordsService');
if(isset($keywordsService->ref_id)) {
	$title = 'Edit keywords_service #' . $keywordsService->ref_id;
} else {
	$title = 'Create New keywords_service';
}
$title = $title;
?>

<?php Part::draw('keywordsService/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('keywords_serviceController::index'), 'keywords_service List') ?>