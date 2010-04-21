<?php
/**
 * !Database ecenter
 * !Table keywords_service
 * !BelongsTo services
 * !BelongsTo keywords
 */
class keywords_service extends Model {
	/** !Column PrimaryKey, Integer, AutoIncrement */
	public $ref_id;

	/** !Column String */
	public $keyword;

	/** !Column Integer */
	public $service;

}
?>
