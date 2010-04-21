<?php
/**
 * !Database ecenter
 * !Table eventtype
 * !BelongsTo Service
 */
class eventtype extends Model {
	/** !Column PrimaryKey, Integer, AutoIncrement */
	public $ref_id;
	/** !Column  String */
        public $eventtype;
	/** !Column  Integer */
        public $service;
}
?>
