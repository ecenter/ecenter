<?php
/**
 * !Database ecenter
 * !Table user
 */
class user extends Model {
	/** !Column PrimaryKey, Integer, AutoIncrement */
	public $user;

	/** !Column String */
	public $name;

	/** !Column String */
	public $email;

	/** !Column DateTime */
	public $created;

	/** !Column String */
	public $username;

	/** !Column String */
	public $keycode;

}
?>