<?php
/**
 * !Database ecenter
 * !Table metadata
 * !BelongsTo services
 */
class metadata extends Model {
	/** !Column PrimaryKey, Integer, AutoIncrement */
	public $metadata;

	/** !Column String */
	public $metaid;

	/** !Column Integer */
	public $service;

	/** !Column String */
	public $subject;

	/** !Column String */
	public $parameters;

}
?>
