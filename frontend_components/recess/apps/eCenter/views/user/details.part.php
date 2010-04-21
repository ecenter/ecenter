<?php
Part::input($user, 'user');
?>
<form method="POST" action="<?php echo Url::action('userController::delete', $user->user) ?>">
	<fieldset>
	<h3><?php echo Html::anchor(Url::action('userController::details', $user->user), 'user #' . $user->user) ?></h3>
	<p>
		<strong>Name</strong>: <?php echo $user->name; ?><br />
		<strong>Email</strong>: <?php echo $user->email; ?><br />
		<strong>Created</strong>: <?php echo date(DATE_ISO8601,$user->created); ?><br />
		<strong>Username</strong>: <?php echo $user->username; ?><br />
		<strong>Keycode</strong>: <?php echo $user->keycode; ?><br />

	</p>
	<?php echo Html::anchor(Url::action('userController::editForm', $user->user), 'Edit') ?> - 
	<input type="hidden" name="_METHOD" value="DELETE" />
	<input type="submit" name="delete" value="Delete" />
	</fieldset>
</form>