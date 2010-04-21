<?php 
Layout::extend('layouts/metadata');
$title = 'Details of metadata #' . $metadata->metadata ;
?>

<?php Part::draw('metadata/details', $metadata) ?>

<?php echo Html::anchor(Url::action('metadataController::index'), 'Back to list of metadatas') ?>
<hr />