<?php 
Layout::extend('layouts/service');
if(isset($service->service)) {
	$title = 'Edit service #' . $service->service;
} else {
	$title = 'Create New service';
}
$title = $title;
?>

<?php Part::draw('service/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('serviceController::index'), 'service List') ?>