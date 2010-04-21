<?php
/**
 * !Database ecenter
 * !Table keyword
 * !HasMany keywords_services
 */
class keyword extends Model {
	/** !Column PrimaryKey, String */
	public $keyword;
	/** !Column  String */
	public $pattern;
	/** !Column DateTime */
	public $created;

}
?>
