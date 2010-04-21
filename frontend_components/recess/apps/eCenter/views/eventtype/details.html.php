<?php 
Layout::extend('layouts/eventtype');
$title = 'Details of eventtype #' . $eventtype->ref_id ;
?>

<?php Part::draw('eventtype/details', $eventtype) ?>

<?php echo Html::anchor(Url::action('eventtypeController::index'), 'Back to list of eventtypes') ?>
<hr />