<?php
/**
 * !Database ecenter
 * !Table service
 * !HasMany eventtypes
 * !HasMany metadatas
 * !HasMany keywords_services
 */
class service extends Model {
	/** !Column PrimaryKey, Integer, AutoIncrement */
	public $service;
	/** !Column String */
	public $name;
	/** !Column String */
	public $url;
	/** !Column String */
	public $type;
	/** !Column String */
	public $comments;
	/** !Column  Boolean */
	public $is_alive;
	/** !Column  DateTime */
	public $updated;

}
?>
