<?php
Part::input($form, 'ModelForm');
Part::input($title, 'string');
?>
<?php $form->begin(); ?>
	<fieldset>
		<legend><?php echo $title ?></legend>
		<?php $form->input('user'); ?>		
				<p>
			<label for="<?php echo $form->name->getName(); ?>">Name</label><br />
			<?php $form->input('name'); ?>
		</p>
		<p>
			<label for="<?php echo $form->email->getName(); ?>">Email</label><br />
			<?php $form->input('email'); ?>
		</p>
		<p>
			<label for="<?php echo $form->created->getName(); ?>">Created</label><br />
			<?php $form->input('created'); ?>
		</p>
		<p>
			<label for="<?php echo $form->username->getName(); ?>">Username</label><br />
			<?php $form->input('username'); ?>
		</p>
		<p>
			<label for="<?php echo $form->keycode->getName(); ?>">Keycode</label><br />
			<?php $form->input('keycode'); ?>
		</p>

		<input type="submit" value="Save" />
	</fieldset>
<?php $form->end(); ?>