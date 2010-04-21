<?php 
Layout::extend('layouts/metadata');
if(isset($metadata->metadata)) {
	$title = 'Edit metadata #' . $metadata->metadata;
} else {
	$title = 'Create New metadata';
}
$title = $title;
?>

<?php Part::draw('metadata/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('metadataController::index'), 'metadata List') ?>