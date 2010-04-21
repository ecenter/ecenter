<?php 
Layout::extend('layouts/eventtype');
if(isset($eventtype->ref_id)) {
	$title = 'Edit eventtype #' . $eventtype->ref_id;
} else {
	$title = 'Create New eventtype';
}
$title = $title;
?>

<?php Part::draw('eventtype/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('eventtypeController::index'), 'eventtype List') ?>