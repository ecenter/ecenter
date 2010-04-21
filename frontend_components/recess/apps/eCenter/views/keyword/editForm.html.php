<?php 
Layout::extend('layouts/keyword');
if(isset($keyword->ref_id)) {
	$title = 'Edit keyword #' . $keyword->ref_id;
} else {
	$title = 'Create New keyword';
}
$title = $title;
?>

<?php Part::draw('keyword/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('keywordController::index'), 'keyword List') ?>