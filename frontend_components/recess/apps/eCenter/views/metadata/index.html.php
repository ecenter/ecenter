<?php 
Layout::extend('layouts/metadata');
$title = 'Index';
?>

<h3><?php echo Html::anchor(Url::action('metadataController::newForm'), 'Create New metadata') ?></h3>

<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>

<?php foreach($metadataSet as $metadata): ?>
	<?php Part::draw('metadata/details', $metadata) ?>
	<hr />
<?php endforeach; ?>