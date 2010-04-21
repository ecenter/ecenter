<?php 
Layout::extend('layouts/keyword');
$title = 'Details of keyword #' . $keyword->keyword ;
?>

<?php Part::draw('keyword/details', $keyword) ?>

<?php echo Html::anchor(Url::action('keywordController::index'), 'Back to list of keywords') ?>
<hr />
