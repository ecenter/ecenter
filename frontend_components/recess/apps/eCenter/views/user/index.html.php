<?php 
Layout::extend('layouts/user');
$title = 'Index';
?>

<h3><?php echo Html::anchor(Url::action('userController::newForm'), 'Create New user') ?></h3>

<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>

<?php foreach($userSet as $user): ?>
	<?php Part::draw('user/details', $user) ?>
	<hr />
<?php endforeach; ?>