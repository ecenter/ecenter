<?php 
Layout::extend('layouts/service');
$title = 'Details of service #' . $service->service ;
?>

<?php Part::draw('service/details', $service) ?>

<?php echo Html::anchor(Url::action('serviceController::index'), 'Back to list of services') ?>
<hr />