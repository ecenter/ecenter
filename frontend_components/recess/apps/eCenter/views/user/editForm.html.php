<?php 
Layout::extend('layouts/user');
if(isset($user->user)) {
	$title = 'Edit user #' . $user->user;
} else {
	$title = 'Create New user';
}
$title = $title;
?>

<?php Part::draw('user/form', $_form, $title) ?>

<?php echo Html::anchor(Url::action('userController::index'), 'user List') ?>