<?php 
Layout::extend('layouts/eventtype');
$title = 'Index';
?>

<h3><?php echo Html::anchor(Url::action('eventtypeController::newForm'), 'Create New eventtype') ?></h3>

<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>

<?php foreach($eventtypeSet as $eventtype): ?>
	<?php Part::draw('eventtype/details', $eventtype) ?>
	<hr />
<?php endforeach; ?>