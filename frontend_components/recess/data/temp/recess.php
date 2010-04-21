<?php
Library::import('recess.framework.controllers.Controller');
Library::import('recess.database.orm.Model');
Library::import('recess.lang.PathFinder');

abstract class Application {
	
	public $name = 'Unnamed Application';
	
	/**
	 * OVERRIDE THIS with appname.controllers.
	 *
	 * @var string
	 */
	public $controllersPrefix = '';
	
	/**
	 * OVERRIDE THIS with appname.models.
	 *
	 * @var string
	 */
	public $modelsPrefix = '';
	
	/**
	 * OVERRIDE THIS with appname/views/
	 *
	 * @var PathFinder
	 */
	public $viewsDir = null;
	
	/**
	 * OVERRIDE THIS with the path to your app's public files relative to url.base, apps/appname/public/ by default
	 *
	 * @var string
	 */
	public $assetUrl = '';
	
	/**
	 * OVERRIDE THIS with the routing prefix to your application
	 *
	 * @var string
	 */
	public $routingPrefix = '/';
	
	public $plugins = array();
	
	protected $viewPathFinder = null;
	
	public function addViewPath($path) {
		if($this->viewPathFinder == null) {
			$this->viewPathFinder = new PathFinder();
		}
		$this->viewPathFinder->addPath($path);
	}
	
	public function viewPathFinder() {
		return $this->viewPathFinder;
	}
	
	public function findView($view) {
		return $this->viewPathFinder->find($view);
	}
	
	static protected $runningApplication = null;
	
	static function active() {
		return self::$runningApplication;
	}
	
	static function activate(Application $application) {
		$application->init();
		self::$runningApplication = $application;	
	}
	
	function init() {
		$this->addViewPath($_ENV['dir.recess'] . 'recess/framework/ui/parts/');
		foreach($this->plugins as $plugin) {
			$plugin->init($this);
		}
		$this->addViewPath($this->viewsDir);
	}
	
	function addRoutesToRouter(RtNode $router) {
		$classes = $this->listControllers();
		foreach($classes as $class) {
			if(Library::classExists($this->controllersPrefix . $class)) {
				$instance = new $class($this);
			} else {
				continue;
			}
			
			if($instance instanceof Controller) {
				$routes = Controller::getRoutes($instance);
				if(!is_array($routes)) continue;
				foreach($routes as $route) {
					$router->addRoute($this, $route, $this->routingPrefix);
				}
			}
		}		
		return $router;
	}
	
	const CONTROLLERS_CACHE_KEY = 'Recess::Framework::App::LstCntrlrs::';
	
	function listControllers() {
		$controllers = Cache::get(self::CONTROLLERS_CACHE_KEY . get_class($this));
		if($controllers === false) {
			$controllers = Library::findClassesIn($this->controllersPrefix);
		}
		return $controllers;
	}

	/** 
	 * Deprecated. Use findView instead.
	 * @return unknown_type
	 */
	function getViewsDir() {
		return $this->viewsDir;
	}
	
	function getAssetUrl() {
		return $this->assetUrl;
	}
	
	function urlTo($methodName) {
		$args = func_get_args();
		list($controllerName, $methodName) = explode('::', $methodName, 2);
		$args[0] = $methodName;
		Library::import($this->controllersPrefix . $controllerName);
		$controller = new $controllerName($this);
		return call_user_func_array(array($controller,'urlTo'),$args);
	}	
}
?><?php
Library::import('recess.framework.Application');
Library::import('recess.framework.helpers.AssertiveTemplate');

class RecessToolsApplication extends Application {
	
	public $codeTemplatesDir;
	
	public function __construct() {
		
		$this->name = 'Recess Tools';
		
		$this->viewsDir = $_ENV['dir.recess'] . 'recess/apps/tools/views/';	
		
		$this->assetUrl = $_ENV['url.assetbase'] . 'recess/recess/apps/tools/public/';
		
		$this->codeTemplatesDir = $_ENV['dir.recess'] . 'recess/apps/tools/templates/';
		
		$this->controllersPrefix = 'recess.apps.tools.controllers.';

		$this->modelsPrefix = 'recess.apps.tools.models.';
		
		$this->routingPrefix = 'recess/';
		
	}
}

?><?php
Library::import('recess.framework.Application');

class WelcomeApplication extends Application {
	public function __construct() {
		
		$this->name = 'Welcome to Recess';
		
		$this->viewsDir = $_ENV['dir.apps'] . 'welcome/views/';	
		
		$this->modelsPrefix = 'welcome.models.';
		
		$this->controllersPrefix = 'welcome.controllers.';
		
		$this->routingPrefix = '/';
		
		$this->assetUrl = 'recess/recess/apps/tools/public/';
		
	}
}
?><?php
Library::import('recess.framework.Application');

class ECenterApplication extends Application {
	public function __construct() {
		
		$this->name = 'ECenter Caching';
		
		$this->viewsDir = $_ENV['dir.apps'] . 'eCenter/views/';
		
		$this->assetUrl = $_ENV['url.assetbase'] . 'apps/eCenter/public/';
		
		$this->modelsPrefix = 'eCenter.models.';
		
		$this->controllersPrefix = 'eCenter.controllers.';
		
		$this->routingPrefix = 'ecenter/';
		
	}
}
?><?php
/**
 * Registry of Database Sources
 *
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Databases {
	
	const DEFAULT_SOURCE = 'Default';
	
	static $sources = array();
	static $default = null;
	
	/**
	 * Retrieve a named data source.
	 *
	 * @param string $name
	 * @return PdoDataSource
	 */
	static function getSource($name) {
		if(isset(self::$sources[$name]))
			return self::$sources[$name];
		else
			return null;
	}
	
	/**
	 * Add a named datasource.
	 *
	 * @param string $name
	 * @param PdoDataSource $source
	 */
	static function addSource($name, PdoDataSource $source) {
		self::$sources[$name] = $source;
	}
	
	/**
	 * Get all named data sources.
	 *
	 * @return array of PdoDataSource
	 */
	static function getSources() {
		return self::$sources;
	}
	
	/**
	 * Set the default data source
	 *
	 * @param PdoDataSource $source
	 */
	static function setDefaultSource(PdoDataSource $source) {
		self::$sources[self::DEFAULT_SOURCE] = $source;
	}
	
	/**
	 * Retrieve the default data source
	 *
	 * @return PdoDataSource
	 */
	static function getDefaultSource() {
		return self::$sources[self::DEFAULT_SOURCE];
	}
	
}

?><?php
Library::import('recess.database.pdo.exceptions.DataSourceCouldNotConnectException');
Library::import('recess.database.pdo.exceptions.ProviderDoesNotExistException');
Library::import('recess.database.pdo.PdoDataSet');

Library::import('recess.database.pdo.RecessTableDescriptor');
Library::import('recess.database.pdo.RecessColumnDescriptor');

/**
 * A PDO wrapper in the Recess PHP Framework that provides a single interface for commonly 
 * needed operations (i.e.: list tables, list columns in a table, etc).
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class PdoDataSource extends PDO {
	const PROVIDER_CLASS_LOCATION = 'recess.database.pdo.';
	const PROVIDER_CLASS_SUFFIX = 'DataSourceProvider';
	const CACHE_PREFIX = 'Recess::PdoDS::';
	
	protected $provider = null;
	
	protected $cachePrefix;
	
	/**
	 * Creates a data source instance to represent a connection to the database.
	 * The first argument can either be a string DSN or an array which contains
	 * the construction arguments.
	 *
	 * @param mixed $dsn String DSN or array of arguments (dsn, username, password)
	 * @param string $username
	 * @param string $password
	 * @param array $driver_options
	 */
	function __construct($dsn, $username = '', $password = '', $driver_options = array()) {
		if(is_array($dsn)) {
			$args = $dsn;
			if(isset($args[0])) { $dsn = $args[0]; }
			if(isset($args[1])) { $username = $args[1];	}
			if(isset($args[2])) { $password = $args[2];	}
			if(isset($args[3])) { $driver_options = $args[3]; }
		}
		
		try {
			parent::__construct($dsn, $username, $password, $driver_options);
			parent::setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		} catch (PDOException $exception) {
			throw new DataSourceCouldNotConnectException($exception->getMessage(), get_defined_vars());
		}
		
		$this->cachePrefix = self::CACHE_PREFIX . $dsn . '::*::';
		
		$this->provider = $this->instantiateProvider();
	}
	
	/**
	 * Locate the pdo driver specific data source provider, instantiate, and return.
	 * Throws ProviderDoesNotExistException for a pdo driver without a Recess provider.
	 *
	 * @return IPdoDataSourceProvider
	 */
	protected function instantiateProvider() {
		$driver = ucfirst(parent::getAttribute(PDO::ATTR_DRIVER_NAME));
		$providerClass = $driver . self::PROVIDER_CLASS_SUFFIX;
		$providerFullyQualified = self::PROVIDER_CLASS_LOCATION . $providerClass;
		// Library::import($providerFullyQualified);
		if(Library::classExists($providerFullyQualified)) {
			$provider = new $providerClass;
			$provider->init($this);
			return $provider;
		} else {
			throw new ProviderDoesNotExistException($providerClass, get_defined_vars());	
		}
	}
	
	/**
	 * Begin a select operation by returning a new, unrealized PdoDataSet
	 *
	 * @param string $table Optional parameter that sets the from clause of the select to a table.
	 * @return PdoDataSet
	 */
	function select($table = '') {
		if($table != '') {
			$PdoDataSet = new PdoDataSet($this);
			return $PdoDataSet->from($table);
		} else {
			return new PdoDataSet($this);
		}
	}
	
	/**
	 * Takes the SQL and arguments (array of Criterion) and returns an array
	 * of objects of type $className.
	 * 
	 * @todo Determine edge conditions and throws.
	 * @param string $query
	 * @param array(Criterion) $arguments 
	 * @param string $className the type to fill from query results.
	 * @return array($className)
	 */
	function queryForClass(SqlBuilder $builder, $className) {
		$statement = $this->provider->getStatementForBuilder($builder,'select',$this);
		$statement->setFetchMode(PDO::FETCH_CLASS, $className, array());
		$statement->execute();
		return $this->provider->fetchAll($statement);
	}
	
	/**
	 * Execute the query from a SqlBuilder instance.
	 *
	 * @param SqlBuilder $builder
	 * @param string $action
	 * @return boolean
	 */
	function executeSqlBuilder(SqlBuilder $builder, $action) {
		return $this->provider->executeSqlBuilder($builder, $action, $this);
	}
	
	function executeStatement($statement, $arguments) {
		$statement = $this->prepareStatement($statement, $arguments);
		return $statement->execute();
	}
	
	function explainStatement($statement, $arguments) {
		$statement = $this->prepareStatement('EXPLAIN QUERY PLAN ' . $statement, $arguments);
		$statement->execute();
		return $statement->fetchAll();
	}
	
	function prepareStatement($statement, $arguments) {
		try {
			$statement = $this->prepare($statement);
		} catch(PDOException $e) {
			throw new RecessException($e->getMessage() . ' SQL: ' . $statement,get_defined_vars());
		}
		foreach($arguments as &$argument) {
			// Begin workaround for PDO's poor numeric binding
			$queryParameter = $argument->getQueryParameter();
			if(is_numeric($queryParameter)) { continue; } 
			// End Workaround
			$statement->bindValue($argument->getQueryParameter(), $argument->value);
		}
		return $statement;
	}
	
	/**
	 * List the tables in a data source alphabetically.
	 * @return array(string) The tables in the data source
	 */
	function getTables() {
		$cacheKey = $this->cachePrefix . 'Tables';
		$tables = Cache::get($cacheKey);
		if(!$tables) {
			$tables = $this->provider->getTables();
			Cache::set($this->cachePrefix . 'Tables', $tables);
		}
		return $tables;
	}
	
	/**
	 * List the column names of a table alphabetically.
	 * @param string $table Table whose columns to list.
	 * @return array(string) Column names sorted alphabetically.
	 */
	function getColumns($table) {
		$cacheKey = $this->cachePrefix . $table . '::Columns';
		$columns = Cache::get($cacheKey);
		if(!$columns) {
			$columns = $this->provider->getColumns($table);
			Cache::set($cacheKey, $columns);
		}
		return $columns;
	}
	
	/**
	 * Retrieve the a table's RecessTableDescriptor.
	 *
	 * @param string $table
	 * @return RecessTableDescriptor
	 */
	function getTableDescriptor($table) {
		$cacheKey = $this->cachePrefix . $table . '::Descriptor';
		$descriptor = Cache::get($cacheKey);
		if(!$descriptor) {
			$descriptor = $this->provider->getTableDescriptor($table);
			Cache::set($cacheKey, $descriptor);
		}
		return $descriptor;
	}
	
	/**
	 * Take a table descriptor and apply it / verify it on top of the
	 * table descriptor returned from a database. This is used to ensure
	 * a model's marked up fields are in congruence with the table. Also
	 * checks to ensure the number of columns in the cascaded descriptor
	 * do not outnumber the actual number of columns. Finally with a database
	 * like sqlite which largely ignores column typing it enables the model
	 * to inform the actual Recess type of the column.
	 *
	 * @param string $table
	 * @param RecessTableDescriptor $descriptor
	 */
	function cascadeTableDescriptor($table, $descriptor) { 
		$cacheKey = $this->cachePrefix . $table . '::Descriptor';
		Cache::set($cacheKey, $this->provider->cascadeTableDescriptor($table, $descriptor));
	}
	
	/**
	 * Drop a table from the database.
	 *
	 * @param string $table
	 */
	function dropTable($table) {
		return $this->provider->dropTable($table);
	}
	
	/**
	 * Empty a table in the database.
	 *
	 * @param string $table
	 */
	function emptyTable($table) {
		return $this->provider->emptyTable($table);
	}
	
	function createTableSql($tableDescriptor) {
		return $this->provider->createTableSql($tableDescriptor);
	}
}

?><?php
Library::import('recess.database.pdo.PdoDataSource');
Library::import('recess.database.orm.ModelSet');

class ModelDataSource extends PdoDataSource {

	function selectModelSet($table = '') {
		if($table != '') {
			$ModelSet = new ModelSet($this);
			return $ModelSet->from($table);
		} else {
			return new ModelSet($this);
		}
	}
	
	
	/**
	 * Transform a model descriptor to a table descriptor.
	 *
	 * @param ModelDescriptor $descriptor
	 * @return RecessTableDescriptor
	 */
	function modelToTableDescriptor(ModelDescriptor $descriptor) {
		Library::import('recess.database.pdo.RecessTableDescriptor');
		Library::import('recess.database.pdo.RecessColumnDescriptor');
		$tableDescriptor = new RecessTableDescriptor();
		$tableDescriptor->name = $descriptor->getTable();
		foreach($descriptor->properties as $property) {
			$tableDescriptor->addColumn(
								$property->name,
								$property->type,
								true,
								$property->isPrimaryKey,
								array(),
								($property->isAutoIncrement ? array('autoincrement' => true) : array())
							);
		}
		return $tableDescriptor;
	}
	
	function createTableSql($descriptor) {
		return parent::createTableSql($this->modelToTableDescriptor($descriptor));
	}
	
}
?><?php
Library::import('recess.database.pdo.RecessTableDescriptor');
Library::import('recess.database.pdo.RecessColumnDescriptor');
Library::import('recess.database.pdo.RecessType');

/**
 * Interface for vendor specific operations needed by PdoDataSource.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
interface IPdoDataSourceProvider {
	
	/**
	 * Initialize with a reference back to the PDO object.
	 *
	 * @param PDO $pdo
	 */
	function init(PDO $pdo);
	
	/**
	 * List the tables in a data source alphabetically.
	 * @return array(string) The tables in the data source
	 */
	function getTables();
	
	/**
	 * List the column names of a table alphabetically.
	 * @param string $table Table whose columns to list.
	 * @return array(string) Column names sorted alphabetically.
	 */
	function getColumns($table);

	/**
	 * Retrieve the a table's RecessTableDescriptor.
	 *
	 * @param string $table Name of table.
	 * @return RecessTableDescriptor
	 */
	function getTableDescriptor($table);
	
	/**
	 * Sanity check and semantic sugar from higher level
	 * representation of table pushed down to the RDBMS
	 * representation of the table.
	 *
	 * @param string $table
	 * @param RecessTableDescriptor $descriptor
	 */
	function cascadeTableDescriptor($table, RecessTableDescriptor $descriptor);
	
	/**
	 * Drop a table from the data source.
	 *
	 * @param string $table Table to drop.
	 */
	function dropTable($table);
	
	/**
	 * Empty a table in the data source.
	 *
	 * @param string $table Table to drop.
	 */
	function emptyTable($table);
	
	/**
	 * Given a Table Definition, return the CREATE TABLE SQL statement
	 * in the provider's desired syntax.
	 *
	 * @param RecessTableDescriptor $tableDescriptor
	 */
	function createTableSql(RecessTableDescriptor $tableDescriptor);
}

?><?php
Library::import('recess.database.pdo.IPdoDataSourceProvider');
Library::import('recess.database.pdo.RecessType');

/**
 * MySql Data Source Provider
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class MysqlDataSourceProvider implements IPdoDataSourceProvider {
	protected static $mysqlToRecessMappings;
	protected static $recessToMysqlMappings;
	protected $pdo = null;
	
	/**
	 * Initialize with a reference back to the PDO object.
	 *
	 * @param PDO $pdo
	 */
	function init(PDO $pdo) {
		$this->pdo = $pdo;
	}
	
	/**
	 * List the tables in a data source.
	 * @return array(string) The tables in the data source ordered alphabetically.
	 */
	function getTables() {
		$results = $this->pdo->query('SHOW TABLES');
		
		$tables = array();
		
		foreach($results as $result) {
			$tables[] = $result[0];
		}
		
		sort($tables);
		
		return $tables;
	}
	
	/**
	 * List the column names of a table alphabetically.
	 * @param string $table Table whose columns to list.
	 * @return array(string) Column names sorted alphabetically.
	 */
	function getColumns($table) {
		try {
			$results = $this->pdo->query('SHOW COLUMNS FROM ' . $table . ';');
		} catch(Exception $e) {
			return array();
		}
		
		$columns = array();
		
		foreach($results as $result) {
			$columns[] = $result['Field'];
		}
		
		sort($columns);
		
		return $columns;
	}
	
	/**
	 * Retrieve the a table's RecessTableDescriptor.
	 *
	 * @param string $table Name of table.
	 * @return RecessTableDescriptor
	 */
	function getTableDescriptor($table) {
		Library::import('recess.database.pdo.RecessTableDescriptor');
		$tableDescriptor = new RecessTableDescriptor();
		$tableDescriptor->name = $table;
		
		try {
			$results = $this->pdo->query('SHOW COLUMNS FROM ' . $table . ';');
			$tableDescriptor->tableExists = true;
		} catch (PDOException $e) {
			$tableDescriptor->tableExists = false;
			return $tableDescriptor;
		}
		
		foreach($results as $result) {
			$tableDescriptor->addColumn(
				$result['Field'],
				$this->getRecessType($result['Type']),
				$result['Null'] == 'NO' ? false : true,
				$result['Key'] == 'PRI' ? true : false,
				$result['Default'] == null ? '' : $result['Default'],
				$result['Extra'] == 'auto_increment' ? array('autoincrement' => true) : array());
		}
		
		return $tableDescriptor;
	}
	
	function getRecessType($mysqlType) {
		if(strtolower($mysqlType) == 'tinyint(1)')
			return RecessType::BOOLEAN;
		
		if( ($parenPos = strpos($mysqlType,'(')) !== false ) {
			$mysqlType = substr($mysqlType,0,$parenPos);
		}
		if( ($spacePos = strpos($mysqlType,' '))) {
			$mysqlType = substr($mysqlType(0,$spacePos));
		}
		$mysqlType = strtolower(rtrim($mysqlType));
		
		$mysqlToRecessMappings = MysqlDataSourceProvider::getMysqlToRecessMappings();
		if(isset($mysqlToRecessMappings[$mysqlType])) {
			return $mysqlToRecessMappings[$mysqlType];
		} else {
			return RecessType::STRING;
		}
	}
	
	static function getMysqlToRecessMappings() {
		if(!isset(self::$mysqlToRecessMappings)) {
			self::$mysqlToRecessMappings = array(
				'enum' => RecessType::STRING,
				'binary' => RecessType::STRING,
				'varbinary' => RecessType::STRING,
				'varchar' => RecessType::STRING,
				'char' => RecessType::STRING,
				'national' => RecessType::STRING,
			
				'text' => RecessType::TEXT,
				'tinytext' => RecessType::TEXT,
				'mediumtext' => RecessType::TEXT,
				'longtext' => RecessType::TEXT,
				'set' => RecessType::TEXT,
			
				'blob' => RecessType::BLOB,
				'tinyblob' => RecessType::BLOB,
				'mediumblob' => RecessType::BLOB,
				'longblob' => RecessType::BLOB,
			
				'int' => RecessType::INTEGER,
				'integer' => RecessType::INTEGER,
				'tinyint' => RecessType::INTEGER,
				'smallint' => RecessType::INTEGER,
				'mediumint' => RecessType::INTEGER,
				'bigint' => RecessType::INTEGER,
				'bit' => RecessType::INTEGER,
			
				'bool' => RecessType::BOOLEAN,
				'boolean' => RecessType::BOOLEAN,
			
				'float' => RecessType::FLOAT,
				'double' => RecessType::FLOAT,
				'decimal' => RecessType::STRING,
				'dec' => RecessType::STRING,
			
				'year' => RecessType::INTEGER,
				'date' => RecessType::DATE,
				'datetime' => RecessType::DATETIME,
				'timestamp' => RecessType::TIMESTAMP,
				'time' => RecessType::TIME,
			); 
		}
		return self::$mysqlToRecessMappings;
	}
	
	static function getRecessToMysqlMappings() {
		if(!isset(self::$recessToMysqlMappings)) {
			self::$recessToMysqlMappings = array(
				RecessType::BLOB => 'BLOB',
				RecessType::BOOLEAN => 'TINYINT(1)',
				RecessType::DATE => 'DATE',
				RecessType::DATETIME => 'DATETIME',
				RecessType::FLOAT => 'FLOAT',
				RecessType::INTEGER => 'INTEGER',
				RecessType::STRING => 'VARCHAR(255)',
				RecessType::TEXT => 'TEXT',
				RecessType::TIME => 'TIME',
				RecessType::TIMESTAMP => 'TIMESTAMP',
			);
		}
		return self::$recessToMysqlMappings;
	}
	
	/**
	 * Drop a table from MySql database.
	 *
	 * @param string $table Name of table.
	 */
	function dropTable($table) {
		return $this->pdo->exec('DROP TABLE ' . $table);
	}
	
	/**
	 * Empty a table from MySql database.
	 *
	 * @param string $table Name of table.
	 */
	function emptyTable($table) {
		return $this->pdo->exec('DELETE FROM ' . $table);
	}
	
	/**
	 * Given a Table Definition, return the CREATE TABLE SQL statement
	 * in the MySQL's syntax.
	 *
	 * @param RecessTableDescriptor $tableDescriptor
	 */
	function createTableSql(RecessTableDescriptor $definition) {
		$sql = 'CREATE TABLE ' . $definition->name;
		
		$mappings = MysqlDataSourceProvider::getRecessToMysqlMappings();
		
		$columnSql = null;
		foreach($definition->getColumns() as $column) {
			if(isset($columnSql)) { $columnSql .= ', '; }
			$columnSql .= "\n\t" . $column->name . ' ' . $mappings[$column->type];
			if($column->isPrimaryKey) {
				$columnSql .= ' NOT NULL';
			
				if(isset($column->options['autoincrement'])) {
					$columnSql .= ' AUTO_INCREMENT';
				}
				
				$columnSql .= ' PRIMARY KEY';
			}
		}
		$columnSql .= "\n";
		
		return $sql . ' (' . $columnSql . ')';
	}
	
	/**
	 * Sanity check and semantic sugar from higher level
	 * representation of table pushed down to the RDBMS
	 * representation of the table.
	 *
	 * @param string $table
	 * @param RecessTableDescriptor $descriptor
	 */
	function cascadeTableDescriptor($table, RecessTableDescriptor $descriptor) {
		$sourceDescriptor = $this->getTableDescriptor($table);
		
		if(!$sourceDescriptor->tableExists) {
			$descriptor->tableExists = false;
			return $descriptor;
		}
		
		$sourceColumns = $sourceDescriptor->getColumns();
		
		$errors = array();
		
		foreach($descriptor->getColumns() as $column) {
			if(isset($sourceColumns[$column->name])) {
				if($column->isPrimaryKey && !$sourceColumns[$column->name]->isPrimaryKey) {
					$errors[] = 'Column "' . $column->name . '" is not the primary key in table ' . $table . '.';
				}
				if($sourceColumns[$column->name]->type != $column->type) {
					$errors[] = 'Column "' . $column->name . '" type "' . $column->type . '" does not match database column type "' . $sourceColumns[$column->name]->type . '".';
				}
			} else {
				$errors[] = 'Column "' . $column->name . '" does not exist in table ' . $table . '.';
			}
		}
		
		if(!empty($errors)) {
			throw new RecessException(implode(' ', $errors), get_defined_vars());
		} else {
			return $sourceDescriptor;
		}
	}
	
	/**
	 * Fetch all returns columns typed as Recess expects:
	 *  i.e. Dates become Unix Time Based and TinyInts are converted to Boolean
	 *
	 * TODO: Refactor this into the query code so that MySql does the type conversion
	 * instead of doing it slow and manually in PHP.
	 * 
	 * @param PDOStatement $statement
	 * @return array fetchAll() of statement
	 */
	function fetchAll(PDOStatement $statement) {
		try {
			$columnCount = $statement->columnCount();
			$manualFetch = false;
			$booleanColumns = array();
			$dateColumns = array();
			$timeColumns = array();
			for($i = 0 ; $i < $columnCount; $i++) {
				$meta = $statement->getColumnMeta($i);
				if(isset($meta['native_type'])) {
					switch($meta['native_type']) {
						case 'TIMESTAMP': case 'DATETIME': case 'DATE':
							$dateColumns[] = $meta['name'];
							break;
						case 'TIME':
							$timeColumns[] = $meta['name'];
							break;
					}
				} else {
					if($meta['len'] == 1) {
						$booleanColumns[] = $meta['name'];
					}
				}
			}
			
			if(	!empty($booleanColumns) || 
				!empty($datetimeColumns) || 
				!empty($dateColumns) || 
				!empty($timeColumns)) {
				$manualFetch = true;
			}
		} catch(PDOException $e) {
			return $statement->fetchAll();
		}
		
		if(!$manualFetch) {
			return $statement->fetchAll();
		} else {
			$results = array();
			while($result = $statement->fetch()) {
				foreach($booleanColumns as $column) {
					$result->$column = $result->$column == 1;
				}
				foreach($dateColumns as $column) {
					$result->$column = strtotime($result->$column);
				}
				foreach($timeColumns as $column) {
					$result->$column = strtotime('1970-01-01 ' . $result->$column);
				}
				$results[] = $result;
			}
			return $results;
		}
	}
	
	function getStatementForBuilder(SqlBuilder $builder, $action, PdoDataSource $source) {
		$criteria = $builder->getCriteria();
		$builderTable = $builder->getTable();
		$tableDescriptors = array();
		
		foreach($criteria as $criterion) {
			$table = $builderTable;
			$column = $criterion->column;
			if(strpos($column,'.') !== false) {
				$parts = explode('.', $column);
				$table = $parts[0];
				$column = $parts[1];
			}
			
			if(!isset($tableDescriptors[$table])) {
				$tableDescriptors[$table] = $source->getTableDescriptor($table)->getColumns();
			}
			
			if(isset($tableDescriptors[$table][$column])) {
				switch($tableDescriptors[$table][$column]->type) {
					case RecessType::DATETIME: case RecessType::TIMESTAMP:
						if(is_int($criterion->value)) {
							$criterion->value = date('Y-m-d H:i:s', $criterion->value);
						} else {
							$criterion->value = null;
						}
						break;
					case RecessType::DATE:
						$criterion->value = date('Y-m-d', $criterion->value);
						break;
					case RecessType::TIME:
						$criterion->value = date('H:i:s', $criterion->value);
						break;
					case RecessType::BOOLEAN:
						$criterion->value = $criterion->value == true ? 1 : 0;
						break;
					case RecessType::INTEGER:
						if(is_array($criterion->value)) {
							break;
						} else if (is_numeric($criterion->value)) {
							$criterion->value = (int)$criterion->value;
						} else {
							$criterion->value = null;
						}
						break;
					case RecessType::FLOAT:
						if(!is_numeric($criterion->value)) {
							$criterion->value = null;
						}
						break;
				}
			}
		}
		
		$sql = $builder->$action();
		$statement = $source->prepare($sql);
		$arguments = $builder->getPdoArguments();
		foreach($arguments as &$argument) {
			// Begin workaround for PDO's poor numeric binding
			$param = $argument->getQueryParameter();
			if(is_numeric($param)) { continue; }
			if(is_string($param) && strlen($param) > 0 && substr($param,0,1) !== ':') { continue; }
			// End Workaround
			
			// Ignore parameters that aren't used in this $action (i.e. assignments in select)
			if(''===$param || strpos($sql, $param) === false) { continue; } 
			$statement->bindValue($param, $argument->value);
		}
		return $statement;
	}
	
	/**
	 * @param SqlBuilder $builder
	 * @param string $action
	 * @param PdoDataSource $source
	 * @return boolean
	 */
	function executeSqlBuilder(SqlBuilder $builder, $action, PdoDataSource $source) {		
		return $this->getStatementForBuilder($builder, $action, $source)->execute();
	}
}
?><?php

interface IPolicy {
	public function preprocess(Request $request);
	
	public function getControllerFor(Request $request, RtNode $routes);
	
	public function getViewFor(Response $response);
}

?><?php
Library::import('recess.framework.controllers.Controller');
Library::import('recess.framework.views.LayoutsView');
Library::import('recess.framework.views.NativeView');
Library::import('recess.framework.views.JsonView');
Library::import('recess.framework.interfaces.IPolicy');
Library::import('recess.framework.http.MimeTypes');

// TODO: Remove this import in 0.3
Library::import('recess.framework.views.RecessView');

class DefaultPolicy implements IPolicy {
	protected $controller;
		
	/**
	 * Used to pre-process a request.
	 * This may involve extracting information and transforming values. 
	 * For example, Transforming the HTTP method from POST to PUT based on a POSTed field.
	 * 
	 * @param	Request The Request to refine.
	 * @return	Request The refined Request.
	 */
	public function preprocess(Request $request) {
		$this->getHttpMethodFromPost($request);

		$this->forceFormatFromResourceString($request);
			
		return $request;
	}
	
	public function getControllerFor(Request $request, RtNode $routes) {
		$routeResult = $routes->findRouteFor($request);
		
		if($routeResult->routeExists) {
			if($routeResult->methodIsSupported) {
				$controller = $this->getControllerFromRouteResult($request, $routeResult);
			} else {
				throw new RecessResponseException('METHOD not supported, supported METHODs are: ' . implode(',', $routeResult->acceptableMethods), ResponseCodes::HTTP_METHOD_NOT_ALLOWED, get_defined_vars());
			}
		} else {
			throw new RecessResponseException('Resource does not exist.', ResponseCodes::HTTP_NOT_FOUND, get_defined_vars());
		}
		
		Application::activate($request->meta->app);
		$this->controller = $controller;
		
		return $controller;
	}
	
	public function getViewFor(Response $response) {
		// TODO: When version 0.3 is released, remove this conditional
		// 		 and break backwards compatibility with versions <= 0.12
		if(!isset($response->meta->respondWith) || empty($response->meta->respondWith)) {
			$view = new $response->meta->viewClass;
			$response->meta->respondWith = array($view);
			if($view != 'LayoutsView') {
				$response->meta->respondWith[] = $view;
			}
			$response->meta->respondWith[] = 'JsonView';
		}
		
		if($response instanceof ForwardingResponse) {
			return new NativeView();
		}
		
		// Here we select a view that can respond in the desired format
		$viewClasses = $response->meta->respondWith;
		$views = array();
		foreach($viewClasses as $viewClass) {
			$views[] = new $viewClass();
		}
		
		$accepts = $response->request->accepts;
		$accepts->resetFormats();
		do {
			$format = $accepts->nextFormat();
			foreach($views as $view) {
				if($view->canRespondWith($response)) {
					return $view;
				}
			}
		} while ($format !== false);
		
		if(isset($response->meta->viewName)) {
			if(isset($response->meta->viewsPrefix)) {
				$view = $response->meta->viewsPrefix . $response->meta->viewName;
			} else {
				$view = $response->meta->viewName;
			}
			throw new RecessResponseException('Unable to provide desired content-type. Does the view "' . $view . '" exist?', ResponseCodes::HTTP_NOT_ACCEPTABLE, get_defined_vars());
		} else {
			throw new RecessResponseException('Unable to provide desired content-type. Does your view exist?', ResponseCodes::HTTP_NOT_ACCEPTABLE, get_defined_vars());
		}
		
	}
	
	/////////////////////////////////////////////////////////////////////////
	// Helper Methods

	const HTTP_METHOD_FIELD = '_METHOD';

	protected function getHttpMethodFromPost(Request $request) {
		if(array_key_exists(self::HTTP_METHOD_FIELD, $request->post)) {
			$request->method = $request->post[self::HTTP_METHOD_FIELD];
			unset($request->post[self::HTTP_METHOD_FIELD]);
			if($request->method == Methods::PUT) {
				$request->put = $request->post;
			}
		}
		return $request;
	}

	protected function forceFormatFromResourceString(Request $request) {
		$lastPartIndex = count($request->resourceParts) - 1;
		if($lastPartIndex < 0) return $request;
		
		$lastPart = $request->resourceParts[$lastPartIndex];
		
		$lastDotPosition = strrpos($lastPart, Library::dotSeparator);
		if($lastDotPosition !== false) {
			$format = substr($lastPart, $lastDotPosition + 1);
			if($format !== '') {
				$mime = MimeTypes::preferredMimeTypeFor($format);
				if($mime !== false) {
					$request->accepts->forceFormat($format);
					$request->format = $format;
					$request->setResource(substr($request->resource, 0, strrpos($request->resource, Library::dotSeparator)));
				}
			}
		}
		
		return $request;
	}

	// @Todo: Worry about the "input" problem. This isn't based on the format
	//			but rather it is based on the content-type of the entity.
	protected function reparameterizeForFormat(Request $request) {
		if($request->format == Formats::JSON) {
			$method = strtolower($request->method);
			$request->$method = json_decode($request->input, true);
		} else if ($request->format == Formats::XML) {
			// TODO: XML reparameterization in request transformer
		}
		return $request;
	}
	
	protected function getControllerFromRouteResult(Request $request, RoutingResult $routeResult) {
		$request->meta->app = $routeResult->route->app;
		$request->meta->controllerMethod = $routeResult->route->function;
		$request->meta->controllerMethodArguments = $routeResult->arguments;
		$request->meta->useAssociativeArguments = true;
		$controllerClass = $routeResult->route->class;
		Library::import($controllerClass);
		$controllerClass = Library::getClassName($controllerClass);
		$controller = new $controllerClass($routeResult->route->app);
		$request->meta->controller = $controller;
		return $controller;
	}

}

?><?php
Library::import('recess.http.ForwardingResponse');
/**
 * Entry into Recess PHP Framework occurs in the coordinator. It is responsible
 * for the flow of control from preprocessing of request data, the serving of a request
 * in a controller, and rendering a response to the request through a view.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @final 
 */
final class Recess {
	/**
	 * Recess PHP Framework Entry Point
	 * @param Request $request The raw Request.
	 * @package recess
	 * @static 
	 */
	public static function main(Request $request, IPolicy $policy, RtNode $routes, array $plugins = array()) {
		static $callDepth = 0;
		static $calls = array();
		$callDepth++;
		$calls[] = $request;
		if($callDepth > 3) { 
			print_r($calls);
			die('Forwarding loop in main?');
		}

		$request = $policy->preprocess($request);
		
		$controller = $policy->getControllerFor($request, $routes);
		
		$response = $controller->serve($request);
		
		$view = $policy->getViewFor($response);

		ob_start();

		$view->respondWith($response);
		
		if($response instanceof ForwardingResponse) {
			$forwardRequest = new Request();
			$forwardRequest->setResource($response->forwardUri);
			$forwardRequest->method = Methods::GET;
			if(isset($response->context)) {
				$forwardRequest->get = $response->context;
			}
			$forwardRequest->accepts = $response->request->accepts;
			$forwardRequest->cookies = $response->request->cookies;
			$forwardRequest->username = $response->request->username;
			$forwardRequest->password = $response->request->password;
			
			$cookies = $response->getCookies();
			if(is_array($cookies)) {
				foreach($response->getCookies() as $cookie) {	
					$forwardRequest->cookies[$cookie->name] = $cookie->value;
				}
			}
			Recess::main($forwardRequest, $policy, $routes, $plugins);
		}

		ob_end_flush();

	}
}
?><?php
Library::import('recess.http.Request');
Library::import('recess.http.Methods');
Library::import('recess.http.Accepts');

/**
 * @author Kris Jordan <krisjordan@gmail.com>
 * @contributor Luiz Alberto Zaiats
 * 
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Environment {

	public static function getRawRequest() {
		$request = new Request();
		
		$request->method = $_SERVER['REQUEST_METHOD'];
		
		$request->format = 'html';
				
		$request->setResource(self::stripQueryString($_SERVER['REQUEST_URI']));
		
		$request->get = $_GET;
		
		$request->post = $_POST;
		
		if(	$request->method == Methods::POST ||
			$request->method == Methods::PUT )
		{
			$request->input = file_get_contents('php://input');

			if($request->method == Methods::POST) {
				$request->post = $_POST;
			} else {
				$request->put = self::getPutParameters($request->input);
			}
		}
		
		$request->headers = self::getHttpRequestHeaders();
		
		$request->accepts = new Accepts($request->headers);
		
		$request->username = @$_SERVER['PHP_AUTH_USER'];
		
		$request->password = @$_SERVER['PHP_AUTH_PW'];
		
		$request->cookies = $_COOKIE;
		
		$request->isAjax =  isset($request->headers['X_REQUESTED_WITH']) 
							&& $request->headers['X_REQUESTED_WITH'] == 'XMLHttpRequest';

		return $request;
	}
	
	private static function	stripQueryString($uri) {
		$questionMarkPosition = strpos($uri, '?');
		if($questionMarkPosition !== false) {
			return substr($uri,0,$questionMarkPosition);
		}
		return $uri;
	}
	
	private static function getHttpRequestHeaders() {
		$lengthOfHTTP_ = 5;
		$httpHeaders = array();
		
		foreach(array_keys($_SERVER) as $key) {
			if(substr($key,0,$lengthOfHTTP_) == 'HTTP_') {
				$httpHeaders[substr($key, $lengthOfHTTP_)] = $_SERVER[$key];
			}
		}
		return $httpHeaders;
	}
	
	private static function getPutParameters($input) {
		$putdata = $input;
		if(function_exists('mb_parse_str')) {
	    	mb_parse_str($putdata, $outputdata);
		} else {
			parse_str($putdata, $outputdata);
		}
    	return $outputdata;
	}
}

?><?php
Library::import('recess.lang.ClassDescriptor');
Library::import('recess.lang.AttachedMethod');
Library::import('recess.lang.WrappableAnnotation');
Library::import('recess.lang.BeforeAnnotation');
Library::import('recess.lang.AfterAnnotation');

/**
 * Object is the base class for extensible classes in the Recess.
 * Object introduces a standard mechanism for building a class
 * descriptor through reflection and the realization of Annotations.
 * Object also introduces the ability to attach methods to a class
 * at run-time.
 * 
 * Sub-classes of Object can introduce extensibility points 
 * with 'wrappable' methods. A wrappable method can be dynamically 'wrapped' 
 * by other methods which are called prior to or after the wrapped method.
 * 
 * Wrappable methods can be declared using a Wrappable annotation on the 
 * method being wrapped. The annotation takes a single parameter, which is
 * the desired name of the wrapped method. By convention the native PHP method
 * being wrapped is prefixed with 'wrapped', i.e.:
 *  class Foobar {
 *    /** !Wrappable foo * /
 *    function wrappedFoo() { ... }
 *  }
 *  $obj->foo();
 * 
 * Example usage of wrappable methods and a hypothetical "EchoWrapper" which
 * wraps a method by echo'ing strings before and after. 
 * 
 *   class Model extends Object {
 *     /** !Wrappable insert * /
 *     function wrappedInsert() { echo "Wrapped (insert)"; }
 *   }
 * 
 *   /** !EchoWrapper insert, Before: "Hello", After: "World" * /
 *   class Person extends Model {}
 * 
 *   $person = new Person();
 *   $person->insert();
 *   
 *   // Output:
 *   Hello
 *   Wrapped (insert)
 *   World
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class Object {
	
	protected static $descriptors = array();
	
	/**
	 * Attach a method to a class. The result of this static method is the ability to
	 * call, on any instance of $attachOnClassName, a method named $attachedMethodAlias
	 * which delegates that method call to $providerInstance's $providerMethodName.
	 *
	 * @param string $attachOnClassName
	 * @param string $attachedMethodAlias
	 * @param object $providerInstance
	 * @param string $providerMethodName
	 */
	static function attachMethod($attachOnClassName, $attachedMethodAlias, $providerInstance, $providerMethodName) {
		self::getClassDescriptor($attachOnClassName)->attachMethod($attachOnClassName, $attachedMethodAlias, $providerInstance, $providerMethodName);
	}
	
	/**
	 * Wrap a method on a class. The result of this static method is the provided IWrapper
	 * implementation will be called before and after the wrapped method.
	 * 
	 * @param string $wrapOnClassName
	 * @param string $wrappableMethodName
	 * @param IWrapper $wrapper
	 */
	static function wrapMethod($wrapOnClassName, $wrappableMethodName, IWrapper $wrapper) {
		self::getClassDescriptor($wrapOnClassName)->addWrapper($wrappableMethodName, $wrapper);
	}
	
	/**
	 * Dynamic dispatch of function calls to attached methods.
	 *
	 * @param string $name
	 * @param array $arguments
	 * @return variant
	 */
	final function __call($name, $arguments) {
		$classDescriptor = self::getClassDescriptor($this);
		
		$attachedMethod = $classDescriptor->getAttachedMethod($name);
		if($attachedMethod !== false) {
			$object = $attachedMethod->object;
			$method = $attachedMethod->method;
			array_unshift($arguments, $this);
			$reflectedMethod = new ReflectionMethod($object, $method);
			return $reflectedMethod->invokeArgs($object, $arguments);
		} else {
			throw new RecessException('"' . get_class($this) . '" class does not contain a method or an attached method named "' . $name . '".', get_defined_vars());
		}
	}
	
	const RECESS_CLASS_KEY_PREFIX = 'Object::desc::';

	/**
	 * Return the ObjectInfo for provided Object instance.
	 *
	 * @param variant $classNameOrInstance - String Class Name or Instance of Recess Class
	 * @return ClassDescriptor
	 */
	final static protected function getClassDescriptor($classNameOrInstance) {
		if($classNameOrInstance instanceof Object) {
			$class = get_class($classNameOrInstance);
			$instance = $classNameOrInstance;
		} else {
			$class = $classNameOrInstance;
			if(class_exists($class, true)) {
				$reflectionClass = new ReflectionClass($class);
				if(!$reflectionClass->isAbstract()) {	
					$instance = new $class;
				} else {
					return new ClassDescriptor();
				}
			}
		}
		
		if(!isset(self::$descriptors[$class])) {		
			$cache_key = self::RECESS_CLASS_KEY_PREFIX . $class;
			$descriptor = Cache::get($cache_key);
			
			if($descriptor === false) {				
				if($instance instanceof Object) {
					$descriptor = call_user_func(array($class, 'buildClassDescriptor'), $class);
					
					Cache::set($cache_key, $descriptor);
					self::$descriptors[$class] = $descriptor;
				} else {
					throw new RecessException('ObjectRegistry only retains information on classes derived from Object. Class of type "' . $class . '" given.', get_defined_vars());
				}
			} else {
				self::$descriptors[$class] = $descriptor;
			}
		}
		
		return self::$descriptors[$class];
	}
	
	/**
	 * Retrieve an array of the attached methods for a particular class.
	 *
	 * @param variant $classNameOrInstance - String class name or instance of a Recess Class
	 * @return array
	 */
	final static function getAttachedMethods($classNameOrInstance) {
		$descriptor = self::getClassDescriptor($classNameOrInstance);
		return $descriptor->getAttachedMethods();
	}	
	
	/**
	 * Clear the descriptors cache.
	 */
	final static function clearDescriptors() {
		self::$descriptors = array();
	}
	
	/**
	 * Initialize a class' descriptor. Override to return a subclass specific descriptor.
	 * A subclass's descriptor may need to initialize certain properties. For example
	 * Model's descriptor has properties initialized for table, primary key, etc. The controller
	 * descriptor has a routes array initialized as empty.
	 * 
	 * @param $class string Name of class whose descriptor is being initialized.
	 * @return ClassDescriptor
	 */
	protected static function initClassDescriptor($class) {	return new ClassDescriptor(); }
		
	/**
	 * Prior to expanding the annotations for a class method this hook is called to give
	 * a subclass an opportunity to manipulate its descriptor. For example Controller
	 * uses this in able to create default routes for methods which do not have explicit
	 * Route annotations.
	 * 
	 * @param $class string Name of class whose descriptor is being initialized.
	 * @param $method ReflectionMethod
	 * @param $descriptor ClassDescriptor
	 * @param $annotations Array of annotations found on method.
	 * @return ClassDescriptor
	 */
	protected static function shapeDescriptorWithMethod($class, $method, $descriptor, $annotations) { return $descriptor; }
	
	/**
	 * Prior to expanding the annotations for a class property this hook is called to give
	 * a subclass an opportunity to manipulate its class descriptor. For example Model
	 * uses this to initialize the datastructure for a Property before a Column annotation
	 * applies metadata. 
	 * 
	 * @param $class string Name of class whose descriptor is being initialized.
	 * @param $property ReflectionProperty
	 * @param $descriptor ClassDescriptor
	 * @param $annotations Array of annotations found on method.
	 * @return ClassDescriptor
	 */
	protected static function shapeDescriptorWithProperty($class, $property, $descriptor, $annotations) { return $descriptor; }

	/**
	 * After all methods and properties of a class have been visited and annotations expanded
	 * this hook provides a sub-class a final opportunity to do post-processing and sanitization.
	 * For example, Model uses this hook to ensure consistency between model's descriptor
	 * and the actual database's columns.
	 * 
	 * @param $class
	 * @param $descriptor
	 * @return ClassDescriptor
	 */
	protected static function finalClassDescriptor($class, $descriptor) { return $descriptor; }
	
	/**
	 * Builds a class' metadata structure (Class Descriptor through reflection 
	 * and expansion of annotations. Hooks are provided in a Strategy Pattern-like 
	 * fashion to allow subclasses to influence various points in the pipeline of 
	 * building a class descriptor (initialization, discovery of method, discovery of
	 * property, finalization). 
	 * 
	 * @param $class Name of class whose descriptor is being built.
	 * @return ClassDescriptor
	 */
	protected static function buildClassDescriptor($class) {
		$descriptor = call_user_func(array($class, 'initClassDescriptor'), $class);

		try {
			$reflection = new RecessReflectionClass($class);
		} catch(ReflectionException $e) {
			throw new RecessException('Class "' . $class . '" has not been declared.', get_defined_vars());
		}
		
		foreach ($reflection->getAnnotations() as $annotation) {
			$annotation->expandAnnotation($class, $reflection, $descriptor);
		}
		
		foreach($reflection->getMethods(false) as $method) {
			$annotations = $method->getAnnotations();
			$descriptor = call_user_func(array($class, 'shapeDescriptorWithMethod'), $class, $method, $descriptor, $annotations);
			foreach($annotations as $annotation) {
				$annotation->expandAnnotation($class, $method, $descriptor);
			}
		}
		
		foreach($reflection->getProperties(false) as $property) {
			$annotations = $property->getAnnotations();
			$descriptor = call_user_func(array($class, 'shapeDescriptorWithProperty'), $class, $property, $descriptor, $annotations);
			foreach($annotations as $annotation) {
				$annotation->expandAnnotation($class, $property, $descriptor);
			}
		}
		
		$descriptor = call_user_func(array($class, 'finalClassDescriptor'), $class, $descriptor);
		
		return $descriptor;
	}	
	
}

?><?php
Library::import('recess.lang.Object');
Library::import('recess.http.Accepts');

/**
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Request {	
	
	public $accepts;
	
	public $format;
	public $headers;
	public $resource;
	public $resourceParts = array();
	public $method;
	public $input;
	public $isAjax = false;

	public $get = array();
	public $post = array();
	public $put = array();

	public $cookies;
	
	public $meta; // Key/value store used by Policy to mark-up request
	
	public $username = '';
	public $password = '';
	
	public function __construct() {
		$this->meta = new Meta;
		$this->accepts = new Accepts(array());
	}
	
	public function setResource($resource) {
		if(isset($_ENV['url.base'])) {
			$resource = str_replace($_ENV['url.base'], '/', $resource);
		}
		$this->resource = $resource;
		$this->resourceParts = self::splitResourceString($resource);
	}
	
	public static function splitResourceString($resourceString) {
		$parts = array_filter(explode(Library::pathSeparator, $resourceString), array('Request','resourceFilter'));
		if(!empty($parts)) {
			return array_combine(range(0, count($parts)-1), $parts);
		} else {
			return $parts;	
		}
	}
	
	public static function resourceFilter($input) {
		return trim($input) != '';
	}
	
	public function data($name) {
		if(isset($this->post[$name])) {
			return $this->post[$name];
		} else if (isset($this->put[$name])) {
			return $this->put[$name];
		} else if (isset($this->get[$name])) {
			return $this->get[$name];
		} else {
			return '';
		}
	}
}

class Meta extends Object {}

?><?php
Library::import('recess.http.AcceptsList');
Library::import('recess.http.MimeTypes');

class Accepts {
	
	protected $headers;
	
	protected $format = '';
	protected $formats = false;
	protected $formatsTried = array();
	protected $formatsCurrent = array();
	
	protected $languages = false;
	protected $encodings = false;
	protected $charsets = false;
	
	const FORMATS = 'ACCEPT';
	const LANGUAGES = 'ACCEPT_LANGUAGE';
	const ENCODINGS = 'ACCEPT_ENCODING';
	const CHARSETS = 'ACCEPT_CHARSETS';
	
	public function __construct($headers) {
		$this->headers = $headers;
	}
	
	public function format() {
		return $this->format;
	}
	
	protected function initFormats() {
		if(isset($this->headers[self::FORMATS])) {
			$this->formats = new AcceptsList($this->headers[self::FORMATS]);
		} else {
			$this->formats = new AcceptsList('');
		}
	}
	
	public function forceFormat($format) {
		$mimeType = MimeTypes::preferredMimeTypeFor($format);
		if($mimeType != false) {
			$this->headers[self::FORMATS] = $mimeType;
		} else {
			$this->headers[self::FORMATS] = '';
		}
	}
	
	public function nextFormat() {
		if($this->formats === false) {
			$this->initFormats();
		}
		
		while(current($this->formatsCurrent) === false) {
			$key = key($this->formatsCurrent);
			
			$nextTypes = $this->formats->next();
			
			if($nextTypes === false) { return false; } // Base case, ran out of types in ACCEPT string
			$this->formatsTried = array_merge($this->formatsTried, $this->formatsCurrent);
			
			$nextTypes = MimeTypes::formatsFor($nextTypes);
			$this->formatsCurrent = array();
			foreach($nextTypes as $type) {
				if(!in_array($type, $this->formatsTried)) {
					$this->formatsCurrent[] = $type;
				}
			}
		}
		
		$result = each($this->formatsCurrent);
		$this->format = $result[1];
		return $result[1]; // Each returns an array of (key, value)
	}
	
	public function resetFormats() {
		$this->format = '';
		
		if($this->formats !== false) 
			$this->formats->reset();
			
		$this->formatsTried = array();
		$this->formatsCurrent = array();
	}
	
	public function nextLanguage() {
		return 'en';
	}

	public function resetLanguages() {
		
	}
		
	public function nextEncoding() {
		return 'gzip';
	}
	
	public function resetEncodings() {
		
	}	
	
	public function nextCharset() {
		return 'utf-8';
	}
	
	public function resetCharset() {
		
	}
	
}
?><?php
/**
 * Http Methods as Const Strings
 *
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Methods {
	const OPTIONS = 'OPTIONS';
	const GET = 'GET';
	const HEAD = 'HEAD';
	const POST = 'POST';
	const PUT = 'PUT';
	const DELETE = 'DELETE';
	const TRACE = 'TRACE';
	const CONNECT = 'CONNECT';
}
?><?php
Library::import('recess.framework.routing.RoutingResult');
Library::import('recess.framework.routing.Rt');

/**
 * Routing nodes are used to build a routing tree which maps a requested
 * URI string and HTTP Method to a Route. Example Route paths:
 * 
 * /pages/				-> matches /pages/
 * /pages/$id			-> matches /pages/1 ... (id => 1)
 * /pages/slug/$slug	-> matches /pages/slug/some-slug-here (slug => some-slug-here)
 * 
 * For the purposes of this class a URI path is broken into parts delimited
 * with a '/'. There are two kinds of path parts: static and parametric. Static matches
 * have precedence over parametric matches. For example, if you have the following routes:
 * 
 * (1) /pages/$page_title/
 * (2) /pages/a-page/
 * (3) /pages/$page_title/$id
 * 
 * A request of "/pages/a-page/" will match (2) and the result will not contain an argument.
 * A request of "/pages/b-page/" will match (1) and the result will contain argument ("page_title" => "b_page")
 * A request of "/pages/a-page/1" will match (3) with result arguments ("page_title" => "a_page", "id" => "1")
 * 
 * Note: Because routing trees are serialized and unserialized frequently I am breaking the naming
 * conventions and using short, one-letter member names.
 * 
 * @todo Add regular expression support to the parametric parts (/pages/:id(regexp-goes-here?)/)
 * 
 * @author Kris Jordan <krisjordan@gmail.com> <kris@krisjordan.com>
 * @copyright Copyright (c) 2008, Kris Jordan 
 * @package recess.routing
 */
class RtNode {
	
	protected $c = ''; // (c)ondition
	protected $m; // (m)ethods
	protected $s; // (s)tatic children
	protected $p; // (d)ynamic children
	
	/**
	 * Used to add a route to the routing tree.
	 * 
	 * @param Route The route to add to this routing tree.
	 */
	public function addRoute($app, Route $route, $prefix) {
		if($route->path == '') return;
		
		$route = clone $route;
		
		$route->app = $app;
		
		if($route->path[0] != '/') {
			if(substr($route->path,-1) != '/') {
				$route->path = $prefix . '/' . trim($route->path);
			}else{
				$route->path = $prefix . trim($route->path);
			}
		}
		
		$pathParts = $this->getRevesedPathParts($route->path);
		$this->addRouteRecursively($pathParts, count($pathParts) - 1, $route);
	}
	
	/**
	 * The recursive method powering addRouteFor(Request).
	 * 
	 * @param array Part of a path in reverse order.
	 * @param int Current index of path part array - decrements with each step.
	 * @param Route The route being added
	 * 
	 * @return FindRouteResult
	 */
	private function addRouteRecursively(&$pathParts, $index, $route) {
		// Base Case
		if($index < 0) {
			foreach($route->methods as $method) {
				if(isset($this->m[$method])) {
					Library::import('recess.framework.routing.DuplicateRouteException');
					throw new DuplicateRouteException($method . ' ' . str_replace('//','/',$route->path), $route->fileDefined, $route->lineDefined);
				}
				$this->m[$method] = new Rt($route);
			}
			return;
		}

		$nextPart = $pathParts[$index];
		
		if($nextPart[0] != '$') {
			$childrenArray = &$this->s;
			$nextKey = $nextPart;
			$isParam = false;
		} else {
			$childrenArray = &$this->p;
			$nextKey = substr($nextPart, 1);
			$isParam = true;
		}
		
		if(!isset($childrenArray[$nextKey])) {
			$child = new RtNode();
			if($isParam) {
				$child->c = $nextKey;
			}
			$childrenArray[$nextKey] = $child;
		} else {
			$child = $childrenArray[$nextKey];
		}
		
		$child->addRouteRecursively($pathParts, $index - 1, $route);
	}
	
	/**
	 * Traverses children recursively to find a matching route. First looks
	 * to see if a static (non-parametric, i.e. /this_is_static/ vs. /$this_is_dynamic/)
	 * match exists. If not, we match against dynamic children. We reverse and step backwards
	 * through the array because $index > 0 is less costly than $index < count($parts)
	 * in PHP.
	 * 
	 * @param Request The recess.http.Request object to find a matching route for.
	 * 
	 * @return RoutingResult
	 */
	public function findRouteFor(Request $request) {
		$pathParts = array_reverse($request->resourceParts);
		return $this->findRouteRecursively($pathParts, count($pathParts) - 1, $request->method);
	}
	
	/**
	 * The recursive method powering findRouteFor(Request).
	 * 
	 * @param array Part of a path in reverse order.
	 * @param int Current index of path part array - decrements with each step.
	 * @param string The HTTP METHOD desired for this route.
	 * 
	 * @return RoutingResult
	 */
	private function findRouteRecursively(&$pathParts, $index, &$method) {
		// Base Case - We've gone to the end of the path.
		if($index < 0) {
			$result = new RoutingResult();
			if(!empty($this->m)) { // Leaf, now check HTTP Method Match
				if(isset($this->m[$method])) {
					$result->routeExists = true;
					$result->methodIsSupported = true;
					$result->route = $this->m[$method]->toRoute();
				} else {
					$result->routeExists = true;
					$routes = array_values($this->m);
					$result->route = $routes[0]->toRoute();
					$result->route->methods = array_values($this->m);
					$result->methodIsSupported = false;
					$result->acceptableMethods = array_keys($this->m);
				}
			} else { // Non-leaf, no match
				$result->routeExists = false;
			}
			return $result;
		}
		
		// Find a child for the next part of the path.
		$nextPart = &$pathParts[$index];
		
		$result = new RoutingResult();
		
		// Check for a static match
		if(isset($this->s[$nextPart])) {
			$child = $this->s[$nextPart];
			$result = $child->findRouteRecursively($pathParts, $index - 1, $method);
		}
		
		if(!$result->routeExists && !empty($this->p)) {
			foreach($this->p as $child) {
				if($child->matches($nextPart)) {
					$result = $child->findRouteRecursively($pathParts, $index - 1, $method);
					if($result->routeExists) {
						if($child->c != '') {
							$result->arguments[$child->c] = urldecode($nextPart);
						}
						return $result;
					}
				}
			}
		}
		
		return $result;
	}
	
	public function getStaticPaths() {
		if(is_array($this->s)) return $this->s;
		else return array();
	}
	
	public function getParametricPaths() {
		if(is_array($this->p)) return $this->p;
		else return array();
	}
	
	public function getMethods() {
		if(is_array($this->m)) return $this->m;
		else return array();
	}
	
	public function matches($path) {
		return $path != '';
	}
	
	public static function __set_state($array) {
		$node = new RtNode();
		$node->c = $array['c'];
		$node->m = $array['m'];
		$node->s = $array['s'];
		$node->p = $array['p'];
		return $node;
	}
	
	// Helper Methods
	
	/**
	 * Explodes a string by forward slashes, removes empty first/last node
	 * and finally reverses the array.
	 * @param string Path to be split and reversed.
	 */
	private function getRevesedPathParts($path) {
		$parts = explode('/',$path);
		$count = count($parts);
		$return = array();
		for($i = $count - 1; $i >= 0; $i--) {
			if($parts[$i] !== '') {
				$return[] = $parts[$i];
			}
		}
		return $return;
	}
}
?><?php
Library::import('recess.http.Request');

interface IController {
	// function wrappedServe(Request $request);
	static function getRoutes($class);
}

?><?php
Library::import('recess.lang.Object');
Library::import('recess.lang.reflection.RecessReflectionClass');
Library::import('recess.lang.Annotation');
Library::import('recess.framework.interfaces.IController');
Library::import('recess.framework.controllers.annotations.ViewAnnotation');
Library::import('recess.framework.controllers.annotations.RouteAnnotation');
Library::import('recess.framework.controllers.annotations.RoutesPrefixAnnotation');
Library::import('recess.framework.controllers.annotations.PrefixAnnotation');
Library::import('recess.framework.controllers.annotations.RespondsWithAnnotation');
/**
 * The controller is responsible for interpretting a preprocessed Request,
 * performing some action in response to the Request (usually CRUDS), and
 * returning a Response which contains relevant state for a view to render
 * the Response.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 */
abstract class AbstractController extends Object implements IController {
	
	public abstract function init();
	
	public static function getViewClass($class) {
		return self::getClassDescriptor($class)->viewClass;
	}
	
	public static function getviewsPrefix($class) {
		return self::getClassDescriptor($class)->viewsPrefix;
	}
	
	public static function getRoutes($class) {
		return self::getClassDescriptor($class)->routes;
	}

	protected function ok($viewName = null) {
		Library::import('recess.http.responses.OkResponse');
		$response = new OkResponse($this->request);
		if(isset($viewName)) $response->meta->viewName = $viewName;
		return $response;
	}
	
	protected function conflict($viewName) {
		Library::import('recess.http.responses.ConflictResponse');
		$response = new ConflictResponse($this->request);
		$response->meta->viewName = $viewName;
		return $response;
	}
	
	protected function redirect($redirectUri,$scheme=null) {
		Library::import('recess.http.responses.TemporaryRedirectResponse');
		$response = new TemporaryRedirectResponse($this->request, $this->buildUrl($redirectUri,$scheme));
		return $response;
	}
	
	protected function found($redirectUri,$scheme=null) {
		Library::import('recess.http.responses.FoundResponse');
		$response = new FoundResponse($this->request, $this->buildUrl($redirectUri,$scheme));
		return $response;
	}
	
	protected function moved($redirectUri,$scheme=null) {
		Library::import('recess.http.responses.MovedPermanentlyResponse');
		$response = new MovedPermanentlyResponse($this->request, $this->buildUrl($redirectUri,$scheme));
		return $response;
	}

	protected function buildUrl($uri, $scheme=null) {
		$parts = parse_url($uri);
		if(!is_null($scheme)) {
			$parts['scheme'] = $scheme;
			if(!empty($parts['host'])) $parts['host'] = $_SERVER['SERVER_NAME'];
		}
		$url = '';
		if(!empty($parts['scheme'])) {
			$url .= $parts['scheme'].'://';
			if(!empty($parts['user'])) $url .= $parts['user'] . (empty($parts['pass']) ? '' : $parts['pass']) .'@';
			$url .= $parts['host'];
			if(!empty($parts['port'])) $url .= ':'.$parts['port'];
		}
		$url .= empty($parts['path']) ? '/' : $parts['path'];
		if(!empty($parts['query'])) $url .= '?'.$parts['query'];
		if(!empty($parts['fragment'])) $url .= '#'.$parts['fragment'];
		return $url;
	}
	
	protected function forwardOk($forwardedUri) {
		Library::import('recess.http.responses.ForwardingOkResponse');
		return new ForwardingOkResponse($this->request, $forwardedUri);
	}
	
	protected function forwardNotFound($forwardUri, $flash = '') {
		Library::import('recess.http.responses.ForwardingNotFoundResponse');
		return new ForwardingNotFoundResponse($this->request, $forwardUri, array('flash' => $flash));
	}
	
	protected function created($resourceUri, $contentUri = '') {
		Library::import('recess.http.responses.CreatedResponse');
		if($contentUri == '') $contentUri = $resourceUri;
		return new CreatedResponse($this->request, $resourceUri, $contentUri);
	}
	
	protected function unauthorized($forwardUri, $realm = '') { 
		Library::import('recess.http.responses.ForwardingUnauthorizedResponse');
		return new ForwardingUnauthorizedResponse($this->request, $forwardUri, $realm);
	}
}

?><?php
Library::import('recess.framework.AbstractController');

Library::import('recess.lang.Annotation');
Library::import('recess.framework.controllers.annotations.ViewAnnotation');
Library::import('recess.framework.controllers.annotations.RouteAnnotation');
Library::import('recess.framework.controllers.annotations.RoutesPrefixAnnotation');
Library::import('recess.framework.controllers.annotations.PrefixAnnotation');
Library::import('recess.framework.controllers.annotations.RespondsWithAnnotation');

/**
 * The controller is responsible for interpretting a preprocessed Request,
 * performing some action in response to the Request (usually CRUDS), and
 * returning a Response which contains relevant state for a view to render
 * the Response.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @author Joshua Paine
 */
abstract class Controller extends AbstractController {
	
	const CLASSNAME = 'Controller';
	
	/** @var Request */
	protected $request;
	
	protected $headers;
	
	/** @var Application */
	protected $application;
		
	public function __construct($application = null) {
		$this->application = $application;
	}
	
	public function init() { }

	protected static function initClassDescriptor($class) {
		$descriptor = new ClassDescriptor();
		$descriptor->routes = array();
		$descriptor->methodUrls = array();
		$descriptor->routesPrefix = '';
		$descriptor->viewClass = 'LayoutsView';
		$descriptor->viewsPrefix = '';
		$descriptor->respondWith = array();
		return $descriptor;
	}

	protected static function shapeDescriptorWithMethod($class, $method, $descriptor, $annotations) {
		$unreachableMethods = array('serve','urlTo','__call','__construct','init','application');

		if(in_array($method->getName(), $unreachableMethods)) return $descriptor;
		
		if(	empty($annotations) && 
				$method->isPublic() && 
				!$method->isStatic()
			   ) {
			   	$parameters = $method->getParameters();
			   	$parameterNames = array();
			   	foreach($parameters as $parameter) {
			   		$parameterNames[] = '$' . $parameter->getName();
			   	}
			   	if(!empty($parameterNames)) {
			   		$parameterPath = '/' . implode('/',$parameterNames);
			   	} else {
			   		$parameterPath = '';
			   	}
				// Default Routing for Public Methods Without Annotations
				$descriptor->routes[] = 
					new Route(	$class, 
								$method->getName(), 
								Methods::GET, 
								$descriptor->routesPrefix . $method->getName() . $parameterPath);
		}
		return $descriptor;
	}

	/**
	 * urlTo is a helper method that returns the url to a controller method.
	 * Examples:
	 * 	$controller->urlTo('someMethod'); => /route/to/someMethod/
	 *  $controller->urlTo('someMethodOneParameter', 'param1');  =>  /route/to/someMethodOneParam/param1
	 *  $controller->urlTo('OtherController::otherMethod'); => Returns the route to another controller's method
	 *  
	 * Thanks to Joshua Paine for improving the API of urlTo!
	 * 
	 * @param $methodName
	 * @return string The url linking to controller method.
	 */
	public function urlTo($methodName) {
		$args = func_get_args();
		
		// First check to see if this is a urlTo on another Controller Class
		if(strpos($methodName,'::') !== false) {
		    return call_user_func_array(array($this->application,'urlTo'),$args);
		}		
    
    // Check to see if this urlTo contains args in the methodName
		// Ignores keys, assuming params are in the proper order.
		// Ex. $controller->urlTo("details?id=43")
		if(strpos($methodName,'?') !== false) {
		    list($methodName, $params) = explode('?', $methodName, 2);
			$args = empty($args)? explode('&',$params) : $args;
			foreach($args as $i => $arg) {
				$val = strpos($arg, '=') !== false ? substr($arg,strrpos($arg, '=')+1) : $arg;
				$args[$i] = $val;
			}
		}
		
		array_shift($args);
		$descriptor = Controller::getClassDescriptor($this);
		if(isset($descriptor->methodUrls[$methodName])) {
			$url = $descriptor->methodUrls[$methodName];
			if($url[0] != '/') {
				$url = $this->application->routingPrefix . $url;
			} else {
				$url = substr($url, 1);
			}
			
			if(!empty($args)) {
				$reflectedMethod = new ReflectionMethod($this, $methodName);
				$parameters = $reflectedMethod->getParameters();
				
				if(count($parameters) < count($args)) {
					throw new RecessException('urlTo(\'' . $methodName . '\') called with ' . count($args) . ' arguments, method "' . $methodName . '" takes ' . count($parameters) . '.', get_defined_vars());
				}
				
				$i = 0;
				$params = array();
				foreach($parameters as $parameter) {
					if(isset($args[$i])) $params[] = '$' . $parameter->getName();
					$i++;
				}
				$url = str_replace($params, $args, $url);
			}
			
			if(strpos($url, '$') !== false) { 
				throw new RecessException('Missing arguments in urlTo(' . $methodName . '). Provide values for missing arguments: ' . $url, get_defined_vars());
			}
			return trim($_ENV['url.base'] . $url);
		} else {
			throw new RecessException('No url for method ' . $methodName . ' exists.', get_defined_vars());
		}
	}
	
	/**
	 * The serve method is where inversion of control occurs which delegates
	 * control to another method in the controller.
	 * 
	 * The method name and arguments should have been extracted in the 
	 * preprocessing step. Here we ensure that the method exists and that all 
	 * required parameters are provided as arguments from the request string.
	 * 
	 * Call the method and return its response.
	 *
	 * @param DefaultRequest $request The HTTP request being served.
	 * 
	 * !Wrappable serve
	 */
	function wrappedServe(Request $request) {		
		$this->request = $request;
		
		$shortWiredResponse = $this->init();
		if($shortWiredResponse instanceof Response) {
				$shortWiredResponse->meta->viewClass = 'LayoutsView';
				$shortWiredResponse->meta->viewsPrefix = '';
				return $shortWiredResponse;
		}
		
		$methodName = $request->meta->controllerMethod;
		$methodArguments = $request->meta->controllerMethodArguments;
		$useAssociativeArguments = $request->meta->useAssociativeArguments;
		
		// Does method exist? Do arguments match?
		if (method_exists($this, $methodName)) {
			$method = new ReflectionMethod($this, $methodName);
			$parameters = $method->getParameters();
			
			$callArguments = array();
			try {
				if($useAssociativeArguments) {
					$callArguments = $this->getCallArgumentsAssociative($parameters, $methodArguments);
				} else {
					$callArguments = $this->getCallArgumentsSequential($parameters, $methodArguments);
				}
			} catch(RecessException $e) {
				throw new RecessException('Error calling method "' . $methodName . '" in "' . get_class($this) . '". ' . $e->getMessage(), array());
			}
			
			$response = $method->invokeArgs($this, $callArguments);
		} else {
			throw new RecessException('Error calling method "' . $methodName . '" in "' . get_class($this) . '". Method does not exist.', array());
		}

		if(!$response instanceof Response) {
			Library::import('recess.http.responses.OkResponse');
			$response = new OkResponse($this->request);
		}
		
		$descriptor = self::getClassDescriptor($this);
		if(!$response instanceof ForwardingResponse && 
		   !isset($response->meta->viewName)) $response->meta->viewName = $methodName;
		// TODO: Remove this deprecated viewClass at 0.3
		$response->meta->viewClass = $descriptor->viewClass;
		$response->meta->viewsPrefix = $descriptor->viewsPrefix;
		
		$response->meta->respondWith = $descriptor->respondWith;
		if(empty($response->data)) $response->data = get_object_vars($this);

		if(is_array($this->headers)) { foreach($this->headers as $header) $response->addHeader($header); }
		
		if(is_array($response->data)) {
			$response->data['controller'] = $this;
			unset($response->data['request']);
			unset($response->data['headers']);
		}
		return $response;
	}

	private function getCallArgumentsAssociative($parameters, $arguments) {
		$callArgs = array();
		foreach($parameters as $parameter) {
			if(!isset($arguments[$parameter->getName()])) {
				if(!$parameter->isOptional()) {
					throw new RecessException('Expects ' . count($parameters) . ' arguments, given ' . count($arguments) . ' and missing required parameter: "' . $parameter->name . '"', array());
				}
			} else {
				$callArgs[] = $arguments[$parameter->getName()];
			}
		}
		return $callArgs;
	}

	private function getCallArgumentsSequential($parameters, $arguments) {
		$callArgs = array();
		$parameterCount = count($parameters);
		for($i = 0; $i < $parameterCount; $i++) {
			if(!isset($arguments[$i])) {
				if(!$parameters[$i]->isOptional()) {
					throw new RecessException('Expects ' . count($parameters) . ' arguments, given ' . count($arguments) . ' and missing required parameter # ' . ($i + 1) . ' named: "' . $parameters[$i]->name . '"', array());
				}
			} else {
				$callArgs[] = $arguments[$i];
			}
		}
		return $callArgs;
	}

	public function application() {
		return $this->application;
	}
}

?><?php
Library::import('recess.framework.controllers.Controller');

/**
 * !RespondsWith Layouts, Json
 * !Prefix routes/
 */
class RecessToolsRoutesController extends Controller {
	
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Tools are available only during development.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	/** !Route GET */
	public function home() {
		
	}
	
}

?><?php
Library::import('recess.lang.AttachedMethod');
Library::import('recess.lang.WrappedMethod');

/**
 * Recess PHP Framework class info object that stores additional
 * state about a Object. This additional state includes
 * attached methods or named public properties.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 */
class ClassDescriptor {
	
	protected $attachedMethods = array();
	protected $wrappedMethods = array();
	
	/**
	 * Return a RecessAttachedMethod for given name, or return false.
	 *
	 * @param string $methodName Method name.
	 * @return RecessAttachedMethod on success, false on failure.
	 */
	function getAttachedMethod($methodName) {
		if(isset($this->attachedMethods[$methodName]))
			return $this->attachedMethods[$methodName];
		else
			return false;
	}
	
	/**
	 * Return all attached methods.
	 *
	 * @return array(AttachedMethod)
	 */
	function getAttachedMethods() {
		return $this->attachedMethods;
	}
	
	/**
	 * Add an attached method with given methodName alias.
	 *
	 * @param string $methodName
	 * @param AttachedMethod $attachedMethod
	 */
	function addAttachedMethod($methodName, AttachedMethod $attachedMethod) {
		$this->attachedMethods[$methodName] = $attachedMethod;
	}
	
	/**
	 * Attach a method to a class. The result of this static method is the ability to
	 * call, on any instance of $attachOnClassName, a method named $attachedMethodAlias
	 * which delegates that method call to $providerInstance's $providerMethodName.
	 *
	 * @param string $attachOnClassName
	 * @param string $attachedMethodAlias
	 * @param object $providerInstance
	 * @param string $providerMethodName
	 */
	function attachMethod($attachOnClassName, $attachedMethodAlias, $providerInstance, $providerMethodName) {
		$attachedMethod = new AttachedMethod($providerInstance, $providerMethodName, $attachedMethodAlias);
		$this->addAttachedMethod($attachedMethodAlias, $attachedMethod);
	}
	
	/**
	 * Add a Wrapper to a WrappedMethod on this class descriptor.
	 * 
	 * @param string $methodName
	 * @param IWrapper $wrapper
	 */
	function addWrapper($methodName, IWrapper $wrapper) {
		if(!isset($this->wrappedMethods[$methodName])) {
			$this->wrappedMethods[$methodName] = new WrappedMethod();			
		}
		$this->wrappedMethods[$methodName]->addWrapper($wrapper);
	}
	
	/**
	 * Register a WrappedMethod on this class descriptor.
	 * 
	 * @param string $methodName
	 * @param WrappedMethod $wrappedMethod
	 */
	function addWrappedMethod($methodName, WrappedMethod $wrappedMethod) {
		if(isset($this->wrappedMethods[$methodName])) {
			$this->wrappedMethods[$methodName] = $wrappedMethod->assume($this->wrappedMethods[$methodName]);
		} else {
			$this->wrappedMethods[$methodName] = $wrappedMethod;
		}
	}
}
?><?php
Library::import('recess.lang.Object');

/**
 * Recess PHP Framework reflection for class which introduces annotations.
 * Annotations follow the following syntax:
 * 
 * !AnnotationName value, key: value, value, (sub array value, key: value, (sub sub array value))
 * 
 * When parsed, AnnotationName is concatenated with 'Annotation' to derive a classname,
 * ex: !HasMany => HasManyAnnotation
 * 
 * This class is instantiated if it exists (else throws UnknownAnnotationException) and its init 
 * method is passed the value array following the annotation's name.
 * 
 * @todo Harden the regular expressions.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class RecessReflectionClass extends ReflectionClass {
	function getProperties($filter = null) {
		Library::import('recess.lang.reflection.RecessReflectionProperty');
		$rawProperties = parent::getProperties();
		$properties = array();
		foreach($rawProperties as $rawProperty) {
			$properties[] = new RecessReflectionProperty($this->name, $rawProperty->name);
		}
		return $properties;
	}
	function getMethods($getAttachedMethods = true){
		Library::import('recess.lang.reflection.RecessReflectionMethod');
		$rawMethods = parent::getMethods();
		$methods = array();
		foreach($rawMethods as $rawMethod) {
			$method = new RecessReflectionMethod($this->name, $rawMethod->name);
			$methods[] = $method;
		}
		
		if($getAttachedMethods && is_subclass_of($this->name, 'Object')) {
			$methods = array_merge($methods, Object::getAttachedMethods($this->name));
		}
		
		return $methods;
	}
	function getAnnotations() {
		Library::import('recess.lang.Annotation');
		$docstring = $this->getDocComment();
		if($docstring == '') return array();
		else {
			$returns = array();
			try {
				$returns = Annotation::parse($docstring);
			} catch(InvalidAnnotationValueException $e) {			
				throw new InvalidAnnotationValueException('In class "' . $this->name . '".' . $e->getMessage(),0,0,$this->getFileName(),$this->getStartLine(),array());
			} catch(UnknownAnnotationException $e) {
				throw new UnknownAnnotationException('In class "' . $this->name . '".' . $e->getMessage(),0,0,$this->getFileName(),$this->getStartLine(),array());
			}
		}
		return $returns;
	}	
}

?><?php
Library::import('recess.lang.exceptions.InvalidAnnotationValueException');
Library::import('recess.lang.exceptions.UnknownAnnotationException');

/**
 * Base class for class, method, and property annotations.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class Annotation {
	
	protected $errors = array();
	protected $values = array();
	
	const FOR_CLASS = 1;
	const FOR_METHOD = 2;
	const FOR_PROPERTY = 4;
	
	/* Begin abstract methods */
	
	/**
	 * Returns a string representation of the intended usage of an annotation.
	 * 
	 * @return string
	 */
	abstract public function usage();
	
	/**
	 * Returns an integer representation of the type(s) of PHP language constructs
	 * the annotation is applicable to. Use the Annotation::FOR_* consts to return
	 * the desired result.
	 * 
	 * Examples:
	 *  // Only valid on classes
	 *  function isFor() { return Annotation::FOR_CLASS; }
	 *  
	 *  // Valid on methods or properties
	 *  function isFor() { return Annotation::FOR_METHOD | Annotation::FOR_PROPERTY; }
	 * 
	 * @return integer
	 */
	abstract public function isFor();
	
	/**
	 * Validate is called just before expansion. Because there may be multiple 
	 * constraints of an annotation the implementation of validate should append
	 * any error messages to the protected $errors property. Commonly used validations
	 * helper methods are provided as protected methods on the Annotation class.
	 * 
	 * @param $class The classname the annotation is on.
	 */
	abstract protected function validate($class);
	
	/**
	 * The expansion step of an annotation gives it an opportunity to manipulate
	 * a class' descriptor by introducing additional metadata, attach methods, and
	 * wrap methods.
	 * 
	 * @param string $class Classname the annotation is applied to.
	 * @param mixed $reflection The Reflection(Class|Method|Property) object the annotation is applied to.
	 * @param ClassDescriptor $descriptor The ClassDescriptor being manipulated.
	 */
	abstract protected function expand($class, $reflection, $descriptor);
	
	/* End abstract methods */
	
	/* Begin validation helper methods */
	
	protected function acceptedKeys($keys) {
		foreach($this->parameters as $key => $value) {
			if (is_string($key) && !in_array($key, $keys)) {
				$this->errors[] = "Invalid parameter: \"$key\".";
			}
		}
	}
	
	protected function requiredKeys($keys) {
		foreach($keys as $key) {
			if(!array_key_exists($key, $this->parameters)) {
				$this->errors[] = get_class($this) . " requires a '$key' parameter.";
			}
		}
	}
	
	protected function acceptedKeylessValues($values) {
		foreach($this->parameters as $key => $value) {
			if(!is_string($key) && !in_array($value, $values)) {
				$this->errors[] = "Unknown parameter: \"$value\".";
			}
		}
	}
	
	protected function acceptedIndexedValues($index, $values) {
		if(!in_array($this->parameters[$index],$values)) {
			$this->errors[] = "Parameter $index is set to \"" . $this->parameters[$key] . "\". Valid values: " . implode(', ', $values) . '.';
		}
	}
	
	protected function acceptedValuesForKey($key, $values, $case = null) {
		if(!isset($this->parameters[$key])) { return; }
		
		if($case === null) {
			$value = $this->parameters[$key];
		} else if($case === CASE_LOWER) {
			$value = strtolower($this->parameters[$key]);
		} else if($case === CASE_UPPER) {
			$value = strtoupper($this->parameters[$key]);
		}
		if(!in_array($value, $values)) {
			$this->errors[] = 'The "' . $key . '" parameter is set to "' . $this->parameters[$key] . '". Valid values: ' . implode(', ', $values) . '.';
		}
	}
	
	protected function acceptsNoKeylessValues() {
		$this->acceptedKeylessValues(array());
	}
	
	protected function acceptsNoKeyedValues() {
		$this->acceptedKeys(array());
	}
	
	protected function validOnSubclassesOf($annotatedClass, $baseClass) {
		if( !is_subclass_of($annotatedClass, $baseClass) ) {
			$this->errors[] = get_class($this) . " is only valid on objects of type $baseClass.";
		}
	}
	
	protected function minimumParameterCount($count) {
		if( ! (count($this->parameters) >= $count) ) {
			$this->errors[] = get_class($this) . " takes at least $count parameters.";
		}
	}
	
	protected function maximumParameterCount($count) {
		if( ! (count($this->parameters) <= $count) ) {
			$this->errors[] = get_class($this) . " takes at most $count parameters.";
		}
	}
	
	protected function exactParameterCount($count) {
		if ( count($this->parameters) != $count ) {
			$this->errors[] = get_class($this) . " requires exactly $count parameters.";
		}
	}
	
	/* End validation helper methods */
	
	
	function init($parameters) {
		$this->parameters = array_change_key_case($parameters, CASE_LOWER);
	}
	
	function isAValue($value) {
		return in_array($value, $this->values);
	}
	
	/**
	 * Mask other values to return the first not contained in the array.
	 * 
	 * @param $values
	 * @return value not in the array of other values
	 */
	function valueNotIn($values) {
		foreach($this->values as $value) {
			if(!in_array($value, $values)) {
				return $value;
			}
		}
		return null;
	}
	
	
	function expandAnnotation($class, $reflection, $descriptor) {		
		// First check to ensure this annotation is allowed
		// to apply to this type of PHP construct (class, method, property)
		// using a simple bitwise mask.
		if($reflection instanceof ReflectionClass) {
			$annotationIsOn = self::FOR_CLASS;
			$annotationIsOnType = 'class';
		} else if ($reflection instanceof ReflectionMethod) {
			$annotationIsOn = self::FOR_METHOD;
			$annotationIsOnType = 'method';
		} else if ($reflection instanceof ReflectionProperty) {
			$annotationIsOn = self::FOR_PROPERTY;
			$annotationIsOnType = 'property';
		}
		if(!($annotationIsOn & $this->isFor())) {
			$isFor = array();
			foreach(array('Classes' => self::FOR_CLASS, 'Methods' => self::FOR_METHOD, 'Properties' => self::FOR_PROPERTY) as $key => $mask) {
				if($mask & $this->isFor()) {
					$isFor[] = $key; 
				}
			}
			$this->errors[] = get_class($this) . ' is only valid on ' . implode(', ', $isFor) . '.';
			$typeError = true;
		} else {
			$typeError = false;
		}
		
		// Run annotation specified validations
		$this->validate($class);
		
		// Throw Exception if Annotation Errors Exist
		if(!empty($this->errors)) {
			if($reflection instanceof ReflectionProperty) {
				$message = 'Invalid ' . get_class($this) . ' on property "' . $reflection->getName() . '". ';
				$reflection = new ReflectionClass($class);
			} else {
				$message = 'Invalid ' . get_class($this) . ' on ' . $annotationIsOnType . ' "' . $reflection->getName() . '". ';
			}
			if(!$typeError) {
				$message .= "Expected usage: \n" . $this->usage();
			}
			$message .= "\n == Errors == \n * ";
			$message .= implode("\n * ", $this->errors);
			throw new RecessErrorException($message,0,0,$reflection->getFileName(),$reflection->getStartLine(),array());
		}
		
		// Map keyed parameters to properties on this annotation
		// Place unkeyed parameters on the $this->values array
		foreach($this->parameters as $key => $value) {
			if(is_string($key)) {
				$this->{$key} = $value;
			} else {
				$this->values[] = $value;
			}
		}
		
		// At this point we've processed the parameters, clearing memory
		unset($this->parameters);
		
		// Finally dispatch to abstract method expand() so that
		// Annotation developers can implement glorious new
		// functionalities.
		$this->expand($class, $reflection, $descriptor);
	}
	
	
	/**
	 * Given a docstring, returns an array of Recess Annotations.
	 * @param $docstring
	 * @return unknown_type
	 */
	static function parse($docstring) {
		preg_match_all('%(?:\s|\*)*!(\S+)[^\n\r\S]*(?:(.*?)(?:\*/)|(.*))%', $docstring, $result, PREG_PATTERN_ORDER);
		
		$annotations = $result[1];
		if(isset($result[2][0]) && $result[2][0] != '') {
			$values = $result[2];
		} else { 
			$values = $result[3];
		}
		$returns = array();
		if(empty($result[1])) return array();
		foreach($annotations as $key => $annotation) {
			// Strip Whitespace
			$value = preg_replace('/\s*(\(|:|,|\))[^\n\r\S]*/', '${1}', '(' . $values[$key] . ')');
			// Extract Strings
			preg_match_all('/\'(.*?)(?<!\\\\)\'|"(.*?)(?<!\\\\)"/', $value, $result, PREG_PATTERN_ORDER);
			$quoted_strings = $result[2];
			$value = preg_replace('/\'.*?(?<!\\\\)\'|".*?(?<!\\\\)"/', '%s', $value);
			// Insert Single Quotes
			$value = preg_replace('/((?!\(|,|:))(?!\))(.*?)((?=\)|,|:))/', '${1}\'${2}\'${3}', $value);
			// Array Keyword
			$value = str_replace('(','array(',$value);
			// Arrows
			$value = str_replace(':', '=>', $value);
			
			$value = vsprintf($value . ';', $quoted_strings);
			
			@eval('$array = ' . $value);
			if(!isset($array)) { 
				throw new InvalidAnnotationValueException('There is an unparseable annotation value: "!' . $annotation . ': ' . $values[$key] . '"',0,0,'',0,array());
			}
			
			$annotationClass = $annotation . 'Annotation';
			$fullyQualified = Library::getFullyQualifiedClassName($annotationClass);
			
			if($annotationClass != $fullyQualified || class_exists($annotationClass,false)) {
				$annotation = new $annotationClass;
				$annotation->init($array);
			} else {
				throw new UnknownAnnotationException('Unknown annotation: "' . $annotation . '"',0,0,'',0,get_defined_vars());
			}
			
			$returns[] = $annotation;
		}
		unset($annotations,$values,$result);
		return $returns;
	}
}
?><?php
Library::import('recess.lang.Annotation');

class RespondsWithAnnotation extends Annotation {
	
	public function usage() {
		return	"!RespondsWith View[, View, ...]\n";
	}

	public function isFor() {
		return Annotation::FOR_CLASS;
	}

	protected function validate($class) {
		$this->minimumParameterCount(1);
		$this->validOnSubclassesOf($class, Controller::CLASSNAME);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		if(!isset($descriptor->respondWith) || !is_array($descriptor->respondWith)) {
			$descriptor->respondWith = array();
		}
		
		foreach($this->values as $value) {
			$viewClass = $value . 'View';
			if(!in_array($viewClass, $descriptor->respondWith)) {
				$descriptor->respondWith[] = $viewClass;
			}
		}
		
//		if($reflection instanceof ReflectionClass) {
//			$this->expandClass($class, $reflection, $descriptor);
//		} else if ($reflection instanceof ReflectionMethod) { 
//			$this->expandMethod($class, $reflection, $descriptor);
//		}
	}
	
//	protected function expandClass($class, $reflectionClass, $descriptor) {
//		$descriptor->respondWith = $this->values;
//	}
//	
//	protected function expandMethod($class, $reflectionMethod, $descriptor) {
//		
//	}
}
?><?php
Library::import('recess.lang.Annotation');

class PrefixAnnotation extends Annotation {
	
	public function usage() {
		return '!Prefix prefix/of/route/ [, Views: prefix/, Routes: prefix/]';
	}

	public function isFor() {
		return Annotation::FOR_CLASS;
	}

	protected function validate($class) {
		$this->acceptedKeys(array('views', 'routes'));
		$this->minimumParameterCount(1);
		$this->maximumParameterCount(3);
		$this->validOnSubclassesOf($class, Controller::CLASSNAME);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		if(isset($this->values[0])) {
			$viewsPrefix = $routesPrefix = $this->values[0];
		} else {
			$viewsPrefix = $routesPrefix = '';
		}

		if(isset($this->views)) { $viewsPrefix = $this->views; }
		if($viewsPrefix == '/') { $viewsPrefix = ''; }
		$descriptor->viewsPrefix = $viewsPrefix;
		
		if(isset($this->routes)) { $routesPrefix = $this->routes; }
		if($routesPrefix == '/') { $routesPrefix = ''; }
		$descriptor->routesPrefix = $routesPrefix;
	}
}
?><?php
Library::import('recess.lang.Annotation');

/**
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class RecessReflectionMethod extends ReflectionMethod {
	function getAnnotations() {
		$docstring = $this->getDocComment();
		if($docstring == '') return array();
		else {
			$returns = array();
			try {
				$returns = Annotation::parse($docstring);
			} catch(InvalidAnnotationValueException $e) {			
				throw new InvalidAnnotationValueException('In class "' . $this->getDeclaringClass()->name . '" on method "'. $this->name .'".' . $e->getMessage(),0,0,$this->getFileName(),$this->getStartLine(),array());
			} catch(UnknownAnnotationException $e) {
				throw new UnknownAnnotationException('In class "' . $this->getDeclaringClass()->name . '" on method "'. $this->name .'".' . $e->getMessage(),0,0,$this->getFileName(),$this->getStartLine(),array());
			}
		}
		return $returns;
	}
	
	function isAttached() {
		return false;
	}
}
?><?php
Library::import('recess.lang.Annotation');
Library::import('recess.framework.routing.Route');

class RouteAnnotation extends Annotation {
	
	const EMPTY_PATH = ' ';
	
	protected $httpMethods = array();
	protected $path = self::EMPTY_PATH;
	
	public function usage() {
		return '!Route ( GET | POST | PUT | DELETE)[, route/path/here]';
	}

	public function isFor() {
		return Annotation::FOR_METHOD;
	}

	protected function validate($class) {
		$this->minimumParameterCount(1);
		$this->maximumParameterCount(2);
		$this->validOnSubclassesOf($class, Controller::CLASSNAME);
		$this->acceptedIndexedValues(0, array(Methods::GET, Methods::POST, Methods::PUT, Methods::DELETE));
	}
	
	protected function expand($class, $reflection, $descriptor) {
		if(is_array($this->values[0])) {
			$this->httpMethods = $this->values[0];
		} else {
			$this->httpMethods = array($this->values[0]);
		}
		
		if(isset($this->values[1])) {
			$this->path = $this->values[1];
		}
		
		$controller = Library::getFullyQualifiedClassName($class);
		$controllerMethod	= $reflection->getName();
		
		if(strpos($this->path, Library::pathSeparator)===0) {
			// Absolute Route
			$route = new Route($controller, $controllerMethod, $this->httpMethods, $this->path);
			$descriptor->methodUrls[$controllerMethod] = $this->path;
		} else {
			// Relative Route
			$route = new Route($controller, $controllerMethod, $this->httpMethods, $descriptor->routesPrefix . $this->path);
			$descriptor->methodUrls[$controllerMethod] = $descriptor->routesPrefix . $this->path;
		}
		
		$route->fileDefined = $reflection->getFileName();
		$route->lineDefined = $reflection->getStartLine();
		
		$descriptor->routes[] = $route;
	}
}
?><?php
/**
 * Routes map a routing path to a application, class, and method.
 * 
 * @author Kris Jordan <krisjordan@gmail.com> <kris@krisjordan.com>
 * @copyright Copyright (c) 2008, Kris Jordan 
 * @package recess.routing
 */
class Route {
	public $class;
	public $function;
	
	public $app;
	public $methods = array();
	public $path;
	
	public $fileDefined = '';
	public $lineDefined = 0;
	
	public function __construct($class, $function, $methods, $path) {
		$this->class = $class;
		$this->function = $function;
				
		if(is_array($methods)) { $this->methods = $methods; }
		else { $this->methods[] = $methods; }
		$this->path = $path;
	}
	
	public static function __set_state($array) {
		$route = new Route($array['class'], $array['function'], $array['methods'], $array['path']);
		$route->app = $array['app'];
		return $route;
	}
}
?><?php
Library::import('recess.lang.Annotation');
Library::import('recess.lang.WrappedMethod');

/**
 * The WrappableAnnotation can be applied to methods in classes deriving
 * from Object. The wrappable annotation expands to create a WrappedMethod
 * called by the first (and only) parameter passed to the Wrappable annotation.
 * 
 * class Foo extends Object {
 * 	/** !Wrappable test * /
 * 	function wrappedTest($arg) { echo $arg; return 'fooz'; }
 * 
 *  /** !Before test * /
 *  function echoArgs(&$args) { echo 'Before test("' . $args[0] . '")'; }
 *  
 *  /** !After test * /
 *  function echoArgs($retVal) { echo 'After test() returns: ' . $retVal; return 'baz'; }
 * }
 * $foo = new Foo();
 * $result = $foo->test('bar');
 * // > Before test("bar")
 * // > bar
 * // > After test() returns: fooz
 * echo $result
 * // > baz
 * 
 * Key methods in the framework are made Wrappable so that functionality can
 * easily be plugged into Recess.
 * 
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class WrappableAnnotation extends Annotation {
	
	public function usage() {
		return '!Wrappable wrappedMethodName';
	}
	
	protected function validate($class) {
		$this->exactParameterCount(1);
	}
	
	public function isFor() {
		return Annotation::FOR_METHOD;
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$methodName = $this->values[0];
		
		$wrappedMethod = new WrappedMethod($reflection->name);
		
		$descriptor->attachMethod($class, $methodName, $wrappedMethod, WrappedMethod::CALL);
				
		$descriptor->addWrappedMethod($methodName, $wrappedMethod);
	}
	
}
?><?php
Library::import('recess.lang.IWrapper');
Library::import('recess.lang.reflection.ReflectionMethod');

/**
 * WrappedMethod is used as an attached method provider on a Recess Object.
 * WrappedMethod provides an additional level of indirection prior to
 * invoking a method on an Object that allows classes implementing
 * IWrapper to register callbacks before() and after(). before() callbacks
 * are able to modify the arguments being passed to a method, and
 * can short-circuit a return value. after() callbacks can modify the
 * return value. Shares similarities to the aspect oriented notion of join
 * points.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class WrappedMethod {
	
	const CALL = 'call';
	
	/**
	 * Registered wrappers whose callbacks are invoked during call()
	 * @var array(IWrapper)
	 */
	protected $wrappers = array();
	
	/**
	 * Name of the method to invoke on the object passed to call()
	 * @var string
	 */
	public $method;
	
	/**
	 * The constructor takes an optional method name.
	 * 
	 * @param String $method name of the method to invoke
	 */
	function __construct($method = '') {
		$this->method = $method;
	}
	
	/**
	 * Wrap the method with another IWrapper
	 * 
	 * @param IWrapper $wrapper
	 */
	function addWrapper(IWrapper $wrapper) {
		foreach($this->wrappers as $existingWrapper) {
			if($existingWrapper->combine($wrapper)) {
				return;
			}
		}
		$this->wrappers[] = $wrapper;
	}
	
	/**
	 * Assume takes the wrappers from another WrappedMethod
	 * and makes them their own. Assume is necessary because
	 * the actual WrappedMethod in a ClassDescriptor may not exist
	 * prior to it needing to be wrapped (by a Class-level annotation)
	 * so we create a place-holder WrappedMethod until the actual
	 * wrapped method Assumes its rightful place.
	 * 
	 * @param WrappedMethod $wrappedMethod the place-holder WrappedMethod.
	 * @return WrappedMethod
	 */
	function assume(WrappedMethod $wrappedMethod) {
		$this->wrappers = $wrappedMethod->wrappers;
		return $this;
	}
	
	/**
	 * The wrappers and wrapped method are invoked in call().
	 * First the before() methods of wrappers are invoked in the order
	 * in which the Wrappers were applied. The before methods are passed
	 * the arguments which will eventually be passed to the actual wrapped
	 * method by reference for possible manipulation. If a before method
	 * returns a value this value is short-circuits the calling process
	 * and returns that value immediately. Next the wrapped method is
	 * invoked. The result is then passed to the after() methods of wrappers
	 * in the reverse order in which they were applied. The after methods
	 * can manipulate the returned value.
	 * 
	 * @return mixed
	 */
	function call() {
		$args = func_get_args();
		
		$object = array_shift($args);
		
		foreach($this->wrappers as $wrapper) {
			$returns = $wrapper->before($object, $args);
			if($returns !== null) { 
				// Short-circuit return
				return $returns;
			}
		}
		
		if(!isset($this->reflectedMethod)) {
			$this->reflectedMethod = new ReflectionMethod($object, $this->method);
		}
		
		$returns = $this->reflectedMethod->invokeArgs($object, $args);
		
		foreach(array_reverse($this->wrappers) as $wrapper) {
			$wrapperReturn = $wrapper->after($object, $returns);
			if($wrapperReturn !== null) {
				$returns = $wrapperReturn;
			}
		}
		
		return $returns;
	}
}
?><?php

/**
 * Data structure for an attached method. Holds a reference
 * to an instance of an object and the mapped function on
 * the object.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 */
class AttachedMethod {
	public $object;
	public $method;
	public $name;
	
	function __construct($object, $method, $name) { 
		$this->object = $object;
		$this->method = $method;
		$this->name = $name;
	}
	
	function isFinal() { return true; }
    function isAbstract() { return false; }
    function isPublic() { return true; }
    function isPrivate() { return false; }
    function isProtected() { return false; }
    function isStatic() { return false; }
    function isConstructor() { return false; }
    function isDestructor() { return false; }
    function isAttached() { return true; }

    function getName() { return $this->alias; }
    function isInternal() { return false; }
    function isUserDefined() { return true; }
    
    function getFileName() { $reflection = new ReflectionClass($this->object); return $reflection->getMethod($this->method)->getFileName(); }
    function getStartLine() { $reflection = new ReflectionClass($this->object); return $reflection->getMethod($this->method)->getStartLine(); }
    function getEndLine() { $reflection = new ReflectionClass($this->object); return $reflection->getMethod($this->method)->getEndLine(); }
    function getParameters() { 
    	$reflection = new ReflectionClass($this->object); 
    	$params = $reflection->getMethod($this->method)->getParameters(); 
    	array_shift($params); 
    	return $params;
    }
    function getNumberOfParameters() { $reflection = new ReflectionClass($this->object); return $reflection->getMethod($this->method)->getNumberOfParameters() - 1; }
    function getNumberOfRequiredParameters() { $reflection = new ReflectionClass($this->object); return $reflection->getMethod($this->method)->getNumberOfRequiredParameters() - 1; }
}

?><?php
Library::import('recess.lang.Annotation');

/**
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 * @todo Add custom getFileName() and getStartLine() methods
 */
class RecessReflectionProperty extends ReflectionProperty {
	function getAnnotations() {
		$docstring = $this->getDocComment();
		if($docstring == '') return array();
		else {
			$returns = array();
			try {
				$returns = Annotation::parse($docstring);
			} catch(InvalidAnnotationValueException $e) {			
				throw new InvalidAnnotationValueException('In class "' . $this->getDeclaringClass()->name . '" on property "'. $this->name .'".' . $e->getMessage(),0,0,$this->getDeclaringClass()->getFileName(),$this->getDeclaringClass()->getStartLine(),array());
			} catch(UnknownAnnotationException $e) {
				throw new UnknownAnnotationException('In class "' . $this->getDeclaringClass()->name . '" on property "'. $this->name .'".' . $e->getMessage(),0,0,$this->getDeclaringClass()->getFileName(),$this->getDeclaringClass()->getStartLine(),array());
			}
		}
		return $returns;
	}
}

?><?php
class Rt {
	public $c; // Class
	public $f; // Function
	public $a; // App
	
	function __construct(Route $route) {
		$this->c = Library::getClassName($route->class);
		$this->f = $route->function;
		$this->a = $route->app;
	}
	
	function toRoute() {
		$route = new Route(Library::getFullyQualifiedClassName($this->c),$this->f,array(),'');
		$route->app = $this->a;
		return $route;
	}
}
?><?php
Library::import('recess.framework.controllers.Controller');
Library::import('recess.database.Databases');
Library::import('recess.database.pdo.PdoDataSource');

/**
 * !RespondsWith Layouts, Json
 * !Prefix database/
 */
class RecessToolsDatabaseController extends Controller {
	
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Tools are available only during development.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	/** !Route GET */
	public function home() {
		$this->default = Databases::getDefaultSource();
		$this->sources = Databases::getSources();
		
		$this->sourceInfo = array();
		foreach($this->sources as $name => $source) {
			if($name != 'Default') {
				$this->sourceInfo[$name]['dsn'] = RecessConf::$namedDatabases[$name];
			} else {
				$this->sourceInfo[$name]['dsn'] = RecessConf::$defaultDatabase[0];
			}
			$this->sourceInfo[$name]['tables'] = $source->getTables();
			$this->sourceInfo[$name]['driver'] = $source->getAttribute(PDO::ATTR_DRIVER_NAME);
		}
	}
	
	/** !Route GET, source/$sourceName/table/$tableName */
	public function showTable($sourceName, $tableName) {
		$source = Databases::getSource($sourceName);
		if($source == null) {
			return $this->redirect($this->urlTo('home'));
		} else {
			$this->source = $source;
		}
		
		$this->sourceName = $sourceName;
		$this->table = $tableName;
		$this->columns = $this->source->getTableDescriptor($tableName)->getColumns();
	}
	
	/** !Route GET, source/$sourceName/table/$tableName/drop */
	public function dropTable($sourceName, $tableName) {
		$this->sourceName = $sourceName;
		$this->tableName = $tableName;
	}
	
	/** !Route POST, source/$sourceName/table/$tableName/drop */
	public function dropTablePost($sourceName, $tableName) {
		$source = Databases::getSource($sourceName);
		$source->dropTable($tableName);
		return $this->forwardOk($this->urlTo('home'));
	}
	
	/** !Route GET, source/$sourceName/table/$tableName/empty */
	public function emptyTable($sourceName, $tableName) {
		$this->sourceName = $sourceName;
		$this->tableName = $tableName;
	}
	
	/** !Route POST, source/$sourceName/table/$tableName/empty */
	public function emptyTablePost($sourceName, $tableName) {
		$source = Databases::getSource($sourceName);
		$source->emptyTable($tableName);
		return $this->forwardOk($this->urlTo('showTable', $sourceName, $tableName));
	}
	
	private function getDsn($sourceName) {
		if($sourceName != 'Default') {
			$this->dsn = RecessConf::$defaultDatabase[0];
		} else {
			$this->dsn = RecessConf::$namedDatabases[$sourceName];
		}
	}
	
	/** !Route GET, new-source */
	public function newSource() {
		
	}
	
}

?><?php
Library::import('recess.framework.controllers.Controller');
Library::import('recess.http.responses.ErrorResponse');
Library::import('recess.http.responses.NotFoundResponse');
Library::import('recess.http.responses.OkResponse');

Library::import('recess.apps.tools.models.RecessReflectorClass');
Library::import('recess.apps.tools.models.RecessReflectorPackage');
Library::import('recess.apps.tools.models.RecessReflectorProperty');
Library::import('recess.apps.tools.models.RecessReflectorMethod');

/**
 * !RespondsWith Layouts
 * !Prefix code/
 */
class RecessToolsCodeController extends Controller {
	
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Tools are available only during development.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	protected function checkTables() {
		try{ // This is so hacked it's embarrasing. Sorry folks.
			Model::createTableFor('RecessReflectorClass');
		} catch(Exception $e) {}
		try{
			Model::createTableFor('RecessReflectorPackage');
		} catch(Exception $e) {}
		
	}
	
	protected function checkIndex() {
		$this->recursiveIndex($_ENV['dir.apps']);
		$this->recursiveIndex($_ENV['dir.recess']);
	}
	
	/** !Route GET */
	public function home() {
		$this->checkTables();
		$this->classes = Make::a('RecessReflectorClass')->all()->orderBy('name');
		$this->packages = Make::a('RecessReflectorPackage')->all()->orderBy('name');		
	}
	
	/** !Route GET, index */
	public function index() {
		$this->checkTables();
		$this->checkIndex();
		return $this->forwardOk($this->urlTo('home'));
	}
	
	private function recursiveIndex($base, $dir = '') {
		$dirInfo = scandir($base . $dir);
		foreach($dirInfo as $item) {
			$location = $base . $dir . '/' . $item;
			if(is_dir($location) && $item[0] != '.') {
				$this->recursiveIndex($base, $dir . '/' . $item);
			} else {
				if($item[0] == '.' || strrpos($item, '.class.php') === false) { continue; }
				$fullyQualified = str_replace('/', '.', $dir . '/' . $item);
				if($fullyQualified[0] == '.') {
					$fullyQualified = substr($fullyQualified, 1);
				}
				$fullyQualified = str_replace('..', '.', $fullyQualified);
				$fullyQualified = str_replace('.class.php','',$fullyQualified);
				
				$this->indexClass($fullyQualified, $dir . '/' . $item);
			}
		}
	}
	
	private function indexClass($fullyQualifiedClassName, $dir) {
		if(!Library::classExists($fullyQualifiedClassName)) {
			return false;
		}

		$model = Library::getClassName($fullyQualifiedClassName);
		$reflectorClass = new RecessReflectorClass();
		$reflectorClass->name = $model;
		if(!$reflectorClass->exists()) {
			$reflectorClass->fromClass($model, $dir);
		}
		
		return $reflectorClass;
	}
	
	/** !Route GET, class/$class */
	public function classInfo($class) {
		$this->checkTables();
		$result = $this->indexClass($class, '');
		
		if($result === false) {
			return new NotFoundResponse($this->request);
		}
		
		$this->reflector = $result;
		
		$className = Library::getClassName($class);
		$reflection = new RecessReflectionClass($className);
		
		$this->reflection = $reflection;
		$this->className = $className;
		
		if($reflection->isSubclassOf('Model')) {
			$this->relationships = Model::getRelationships($className);
			$this->columns = Model::getColumns($className);
			$this->table = Model::tableFor($className);
			$this->source = Model::sourceNameFor($className);
		}
	}
	 
	/** !Route GET, package/$packageName */
	function packageInfo ($packageName) {
		Library::import('recess.apps.tools.models.RecessReflectorPackage');
		$package = new RecessReflectorPackage();
		$package->name = $packageName;
		$this->package = $package->find()->first();
		
	}
	
	
	/** !Route GET, class/$fullyQualifiedModel/create */
	function createTable ($fullyQualifiedModel) {
		if(!Library::classExists($fullyQualifiedModel)) {
			return new NotFoundResponse($this->request);
		}

		$class = Library::getClassName($fullyQualifiedModel);
		
		Model::createTableFor($class);
	}
	
}

?><?php
Library::import('recess.framework.controllers.Controller');

/**
 * !RespondsWith Layouts, Json
 * !Prefix tests/
 */
class RecessToolsTestsController extends Controller {
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Tools are available only during development.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	/** !Route GET */
	public function home() {
		
	}
}
?><?php
Library::import('recess.framework.controllers.Controller');

/**
 * !RespondsWith Layouts, Json
 * !Prefix Views: home/, Routes: /
 */
class RecessToolsHomeController extends Controller {
	
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Tools are available only during development.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	/** !Route GET */
	public function home() {
	}
	
}

?><?php
Library::import('recess.framework.controllers.Controller');
Library::import('recess.database.pdo.RecessType');

/**
 * !RespondsWith Layouts, Json
 * !Prefix apps/
 */
class RecessToolsAppsController extends Controller {
	
	public function init() {
		if(RecessConf::$mode == RecessConf::PRODUCTION) {
			throw new RecessResponseException('Recess Tools are available only during development. Please disable the application in a production environment.', ResponseCodes::HTTP_NOT_FOUND, array());
		}
	}
	
	/** !Route GET */
	public function home() {
		$this->apps = RecessConf::$applications;
		if(isset($this->request->get->flash)) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, uninstall/$appClass */
	public function uninstall($appClass) {
		//Library::getFullyQualifiedClassName($appClass);
		$this->app = new $appClass;
	}
	
	/** !Route GET, new */
	public function newApp() {
		$writeable = is_writable($_ENV['dir.apps']);
		
		$this->appsDirWriteable = $writeable;
		if($this->appsDirWriteable) {
			$this->form = $this->getNewAppForm();
			return $this->ok('newAppWizard');
		} else {
			return $this->ok('newAppInstructions');
		}
	}
	
	/** !Route POST, new */
	public function newAppPost() {
		$form = $this->getNewAppForm($this->request->post);
		$form->assertNotEmpty('appName');
		$form->assertNotEmpty('programmaticName');
		if($form->hasErrors()) {
			$this->form = $form;
			return $this->conflict('newAppWizard');
		} else {
			Library::import('recess.lang.Inflector');
			$this->form = $this->getNewAppStep2Form($this->request->post);
			$this->form->routingPrefix->setValue(Inflector::toCamelCaps($this->form->programmaticName->getValue()) . '/');
			return $this->ok('newAppWizardStep2');
		}
	}
	
	/** !Route POST, new/step2 */
	function newAppStep2 () {
		$form = $this->getNewAppStep2Form($this->request->post);
		$this->generateApp();
		return $this->ok('newAppWizardComplete');
	}
	
	private function generateApp() {
		Library::import('recess.lang.Inflector');
		
		$appName = $this->request->post['appName'];
		$programmaticName = Inflector::toProperCaps($this->request->post['programmaticName']);
		$camelProgrammaticName = Inflector::toCamelCaps($programmaticName);
		
		$this->applicationClass = $programmaticName . 'Application';
		$this->applicationFullClass = $camelProgrammaticName . '.' . $this->applicationClass;
		$this->appName = $appName;
		
		$routesPrefix = $this->request->post['routingPrefix'];
		if(substr($routesPrefix,-1) != '/') { $routesPrefix .= '/'; }
		if($routesPrefix{0} === '/') { $routesPrefix = substr($routesPrefix,1); }
		$appDir = $_ENV['dir.apps'] . $camelProgrammaticName;
		
		$this->messages = array();
		$this->messages[] = $this->tryCreatingDirectory($appDir, 'application');
		
		$appReplacements = array('appName' => $appName, 'programmaticName' => $programmaticName, 'camelProgrammaticName' => $camelProgrammaticName, 'routesPrefix' => $routesPrefix);
		$this->messages[] = $this->tryGeneratingFile('Application Class', $this->application->codeTemplatesDir . 'Application.template.php', $appDir . '/' . $programmaticName . 'Application.class.php', $appReplacements);
		
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/models', 'models');
		
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/controllers', 'controllers');
		$this->messages[] = $this->tryGeneratingFile('Home Controller', $this->application->codeTemplatesDir . 'scaffolding/controllers/HomeController.template.php', $appDir . '/controllers/' . $programmaticName . 'HomeController.class.php', $appReplacements);
		
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/views', 'views');
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/views/parts', 'common parts');
		$this->messages[] = $this->tryGeneratingFile('Navigation Part', $this->application->codeTemplatesDir . 'scaffolding/views/parts/navigation.part.template.php', $appDir . '/views/parts/navigation.part.php', $appReplacements);
		$this->messages[] = $this->tryGeneratingFile('Style Part', $this->application->codeTemplatesDir . 'scaffolding/views/parts/style.part.template.php', $appDir . '/views/parts/style.part.php', $appReplacements);
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/views/home', 'home views');
		$this->messages[] = $this->tryCreatingDirectory($appDir . '/views/layouts', 'layouts');
		$this->messages[] = $this->tryGeneratingFile('Home Template', $this->application->codeTemplatesDir . 'scaffolding/views/home/index.template.php', $appDir . '/views/home/index.html.php', $appReplacements);
		$this->messages[] = $this->tryGeneratingFile('Master Layout', $this->application->codeTemplatesDir . 'scaffolding/views/master.layout.template.php', $appDir . '/views/layouts/master.layout.php', $appReplacements);
		
		$scaffolding_dir = $this->application->codeTemplatesDir . 'scaffolding';
		$this->messages[] = $this->tryCopyDirectory($scaffolding_dir . '/public', $appDir . '/public');
	}
	
	private function tryCreatingDirectory($path, $name) {
		$message = '';
		try { 
			$message = 'Creating ' . $name . ' dir "' . $path . '" ... ';
			mkdir($path);
			$message .= 'ok.';
		} catch (Exception $e) {
			if(file_exists($path)) $message .= ' already exists.';
			else $message .= 'failed.';
		}
		return $message;
	}
	
	/**
	 * Copy all files and directories (recursive) to another directory
	 */
	private function tryCopyDirectory($src, $dst) {
		$message = '';
		try { 
			$message = 'Copying ' . $src . ' dir to ' . $dst . ' ... ';
			$dir = opendir($src); 
			mkdir($dst); 
			while(false !== ( $file = readdir($dir))) {
				if (( $file != '.' ) && ( $file != '..' )) {
					if ( is_dir($src . '/' . $file) ) {
						self::tryCopyDirectory($src . '/' . $file,$dst . '/' . $file);
					} else {
						copy($src . '/' . $file,$dst . '/' . $file);
					}
				}
			}
			closedir($dir);
		} catch (Exception $e) {
			if(file_exists($dst)) $message .= ' already exists.';
			else if(!is_dir($src)) $message .= ', source directory does not exist.';
			else $message .= 'failed.';
		}
		return $message;
	}
	
	private function tryGeneratingFile($name, $template, $outputFile, $values, $allowSlashes = false) {
		$templateContents = file_get_contents($template);
		$search = array_keys($values);
		foreach($search as $key => $value) {
			$search[$key] = '/\{\{' . $value . '\}\}/';
		}
		$replace = array_values($values);
		foreach($replace as $key => $value) {
			if(!$allowSlashes) { 
				$value = addSlashes($value);
			}
			$replace[$key] = $value;
		}
		$output = preg_replace($search,$replace,$templateContents);
		
		$message = '';
		try {
			$message = 'Generating ' . $name . ' at "' . $outputFile . '" ... ';
			if(file_exists($outputFile)) {
				throw new Exception('file exists');
			}
			file_put_contents($outputFile, $output);
			$message .= 'ok.';
		} catch(Exception $e) {
			if(file_exists($outputFile)) $message .= ' already exists. Not overwriting.';
			else $message .= 'failed.';
		}
		return $message;
	}
	
	private function getNewAppForm($fillValues = array()) {
		Library::import('recess.framework.forms.Form');
		$form = new Form('');
		$form->method = "POST";
		$form->flash = "";
		$form->action = $this->urlTo('newApp');
		$form->inputs['appName'] = new TextInput('appName', '', '','');
		$form->inputs['programmaticName'] = new TextInput('programmaticName', '', '','');
		$form->fill($fillValues);
		return $form;
	}
	
	private function getNewAppStep2Form($fillValues = array()) {
		Library::import('recess.framework.forms.Form');
		$form = new Form('');
		$form->method = "POST";
		$form->flash = "";
		$form->action = $this->urlTo('newAppStep2');
		$form->inputs['appName'] = new HiddenInput('appName', '');
		$form->inputs['programmaticName'] = new HiddenInput('programmaticName', '');
		$form->inputs['routingPrefix'] = new TextInput('routingPrefix', '','','');
		$form->fill($fillValues);
		return $form;
	}

	/** !Route GET, $appClass */
	public function app($appClass) {
		$application = $this->getApplication($appClass);
		if(!$application instanceof Application) {
			return $application; // App not found
		}
		
		$this->app = $application;
	}
	
	/** !Route GET, app/$app/model/gen */
	public function createModel($app) {
		$this->sources = Databases::getSources();
		$this->tables = Databases::getDefaultSource()->getTables();
		$this->app = $app;
	}
	
	/** !Route POST, app/$app/model/gen */
	public function generateModel($app) {
		$values = $this->request->post;
		
		$modelName = $values['modelName'];
		$tableExists = $values['tableExists'] == 'yes' ? true : false;
		if($tableExists) {
			$dataSource = $values['existingDataSource'];
			$createTable = false;
			$tableName = $values['existingTableName'];
		} else {
			$dataSource = $values['dataSource'];
			$createTable = $values['createTable'] == 'Yes' ? true : false;
			$tableName = $values['tableName'];
		}
		$propertyNames = $values['fields'];
		$primaryKey = $values['primaryKey'];
		$types = $values['types'];
		
		Library::import('recess.database.orm.Model', true); 
		// Forcing b/c ModelDescriptor is in Model
			
		$modelDescriptor = new ModelDescriptor($modelName, false);
		$modelDescriptor->setSource($dataSource);
		$modelDescriptor->setTable($tableName, false);
		
		$pkFound = false;
		foreach($propertyNames as $i => $name) {
			if($name == "") continue;
			$property = new ModelProperty();
			$property->name = trim($name);
			if($name == $primaryKey) {
				$property->isPrimaryKey = true;
			}
			if($types[$i] == 'Integer Autoincrement') {
				if($property->isPrimaryKey) {
					$property->type = RecessType::INTEGER;
					$property->isAutoIncrement = true;
				} else {
					$property->type = RecessType::INTEGER;
				}
			} else {
				$property->type = $types[$i];
			}
			$modelDescriptor->properties[] = $property;
		}
		
		Library::import('recess.database.orm.ModelGen');
		$this->modelCode = ModelGen::toCode($modelDescriptor, $_ENV['dir.temp'] . 'Model.class.php');
		
		$app = new $app;
		if(strpos($app->modelsPrefix,'recess.apps.') !== false) {
			$base = $_ENV['dir.recess'];
		} else {
			$base = $_ENV['dir.apps'];
		}
		$path = $base . str_replace(Library::dotSeparator,Library::pathSeparator,$app->modelsPrefix);
		$path .= $modelName . '.class.php';
		$this->path = $path;
		
		$this->modelWasSaved = false;
		$this->codeGenMessage = '';
		try {
			if(file_exists($this->path)) {
				if(file_get_contents($this->path) == $this->modelCode) {
					$this->modelWasSaved = true;
				} else {
					$this->codeGenMessage = 'File already exists!';
				}
			} else {
				file_put_contents($this->path, $this->modelCode);			
				$this->modelWasSaved = true;
			}
		} catch(Exception $e) {	
			$this->codeGenMessage = 'File could not be saved. Is models directory writeable?';
			$this->modelWasSaved = false;
		}
		
		$this->modelName = $modelName;
		$this->appName = get_class($app);
		$this->tableGenAttempted = $createTable;
		$this->tableWasCreated = false;
		$this->tableSql = '';
		if($createTable) {
			$modelSource = Databases::getSource($dataSource);
			$this->tableSql = $modelSource->createTableSql($modelDescriptor);
			try {
				$modelSource->exec($this->tableSql);
				$this->tableWasCreated = true;
			} catch(Exception $e) {
				$this->tableWasCreated = false;
			}
		}
		
		return $this->ok('createModelComplete');
	}
	
	/** !Route GET, $app/model/$model/scaffolding */
	public function generateScaffolding($app, $model) {
		$app = new $app;
		if(strpos($app->controllersPrefix,'recess.apps.') !== false) {
			$base = $_ENV['dir.recess'];
		} else {
			$base = $_ENV['dir.apps'];
		}
		Library::import('recess.lang.Inflector');
		$controllersDir = $base . str_replace(Library::dotSeparator,Library::pathSeparator,$app->controllersPrefix);
		$viewsDir = $app->viewsDir;
		
		Library::import($app->modelsPrefix . $model);
		$replacements = 
			array(	'modelName' => $model, 
					'modelNameLower' => Inflector::toCamelCaps($model),
					'fullyQualifiedModel' => $app->modelsPrefix . $model, 
					'primaryKey' => Model::primaryKeyName($model),
					'viewsPrefix' => Inflector::toCamelCaps($model),
					'routesPrefix' => Inflector::toCamelCaps($model),);
		
		$this->messages[] = $this->tryGeneratingFile('RESTful ' . $model . ' Controller', $this->application->codeTemplatesDir . 'scaffolding/controllers/ResourceController.template.php', $controllersDir . $model . 'Controller.class.php', $replacements);
		
		$indexFieldTemplate = $this->getTemplate($this->application->codeTemplatesDir . 'scaffolding/views/resource/indexField.template.php');
		$indexDateFieldTemplate = $this->getTemplate($this->application->codeTemplatesDir . 'scaffolding/views/resource/indexDateField.template.php');
		$editFormInputTemplate = $this->getTemplate($this->application->codeTemplatesDir . 'scaffolding/views/resource/editFormInput.template.php');
		
		$indexFields = '';
		$formFields = '';
		foreach(Model::getProperties($model) as $property) {
			if($property->isPrimaryKey) continue;
			$values = array(
							'fieldName' => $property->name,
							'primaryKey' => Model::primaryKeyName($model),
							'modelName' => $model,
							'modelNameLower' => Inflector::toCamelCaps($model),
							'fieldNameEnglish' => Inflector::toEnglish($property->name) );
			switch($property->type) {
				case RecessType::DATE:
				case RecessType::DATETIME:
				case RecessType::TIME:
				case RecessType::TIMESTAMP:
					$template = $indexDateFieldTemplate;
					break;
				default:
					$template = $indexFieldTemplate;
					break;
			}
			$formFields .= $this->fillTemplate($editFormInputTemplate, $values);
			$indexFields .= $this->fillTemplate($template, $values);
		}
		
		$replacements['fields'] = $indexFields;
		$replacements['editFields'] = $formFields;
		
		$viewsDir = $app->viewsDir . $replacements['viewsPrefix'] . '/';
		$this->messages[] = $this->tryCreatingDirectory($viewsDir, $model . ' views dir');
		$this->messages[] = $this->tryGeneratingFile('resource layout', $this->application->codeTemplatesDir . 'scaffolding/views/resource/resource.layout.template.php', $viewsDir . '../layouts/' . $replacements['viewsPrefix'] . '.layout.php', $replacements);
		$this->messages[] = $this->tryGeneratingFile('index view', $this->application->codeTemplatesDir . 'scaffolding/views/resource/index.template.php', $viewsDir . 'index.html.php', $replacements);
		$this->messages[] = $this->tryGeneratingFile('editForm view', $this->application->codeTemplatesDir . 'scaffolding/views/resource/editForm.template.php', $viewsDir . 'editForm.html.php', $replacements, true);
		$this->messages[] = $this->tryGeneratingFile('form part', $this->application->codeTemplatesDir . 'scaffolding/views/resource/form.part.template.php', $viewsDir . 'form.part.php', $replacements, true);
		$this->messages[] = $this->tryGeneratingFile('static details', $this->application->codeTemplatesDir . 'scaffolding/views/resource/details.template.php', $viewsDir . 'details.html.php', $replacements);
		$this->messages[] = $this->tryGeneratingFile('details part', $this->application->codeTemplatesDir . 'scaffolding/views/resource/details.part.template.php', $viewsDir . 'details.part.php', $replacements);
		$this->appName = get_class($app);
		$this->modelName = $model;
	}
	
	protected function getTemplate($templateFile) {
		try {
			return file_get_contents($templateFile);
		} catch (Exception $e) {
			return '';
		}
	}
	
	protected function fillTemplate($template, $values) {
		$search = array_keys($values);
		foreach($search as $key => $value) {
			$search[$key] = '/\{\{' . $value . '\}\}/';
		}
		$replace = array_values($values);
		foreach($replace as $key => $value) {
			$replace[$key] = addslashes($value);
		}
		return preg_replace($search,$replace,$template);
	}
	
	/** !Route GET, model/gen/analyzeModelName/$modelName */
	public function analyzeModelName($modelName) {
		Library::import('recess.lang.Inflector');
		$this->tableName = Inflector::toPlural(Inflector::toUnderscores($modelName));
		$this->isValid = preg_match('/^[a-zA-Z][_a-zA-z0-9]*$/', $modelName) == 1;
	}
	
	/** !Route GET, model/gen/getTables/$sourceName */
	public function getTables($sourceName) {
		$this->tables = Databases::getSource($sourceName)->getTables();
	}
	
	/** !Route GET, model/gen/getTableProps/$sourceName/$tableName */
	public function getTableProps($sourceName, $tableName) {
		$source = Databases::getSource($sourceName);
		if($source == null) {
			return $this->redirect($this->urlTo('home'));
		} else {
			$this->source = $source;
		}
		$this->sourceName = $sourceName;
		$this->table = $tableName;
		$this->columns = $this->source->getTableDescriptor($tableName)->getColumns();
	}
	
	/** !Route GET, $app/controller/gen */
	public function createController($app) {
		
		$application = $this->getApplication($app);
		if(!$application instanceof Application) {
			return $application; // App not found
		}
		
		$this->app = $application;
		
		return $this->ok('genController');
	}
	
	private function getApplication($appClass) {
		foreach(RecessConf::$applications as $app) {
			if(get_class($app) == $appClass) {
				return $app;
			}
		}
		return $this->forwardNotFound($this->urlTo('home'), 'Application ' . $appClass . ' does not exist or is not enabled.');
	}
	
}

?><?php
Library::import('recess.framework.controllers.Controller');

/**
 * !RespondsWith Layouts, Json
 * !Prefix Routes: /, Views: home/
 */
class WelcomeHomeController extends Controller {
	/**
	 * !Route GET, /
	 */
	function index() {
		$this->flash = 'Welcome to your new Recess app!';
	}
}
?><?php
Library::import('eCenter.models.keyword');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix keyword/
 */
class keywordController extends Controller {
	
	/** @var keyword */
	protected $keyword;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->keyword = new keyword();
		$this->_form = new ModelForm('keyword', $this->request->data('keyword'), $this->keyword);
	}
	
	/** !Route GET */
	function index() {
		$this->keywordSet = $this->keyword->all();
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $keyword */
	function details($keyword) {
		$this->keyword->keyword = $keyword;
		if($this->keyword->exists()) {
			return $this->ok('details');
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->keyword->insert();
			return $this->created($this->urlTo('details', $this->keyword->keyword));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $keyword/edit 
	function editForm($keyword) {
		$this->keyword->keyword = $keyword;
		if($this->keyword->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $keyword));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keyword does not exist.');
		}
	}
	
	 !Route PUT, $keyword  
	function update($keyword) {
		$oldkeyword = new keyword($keyword);
		if($oldkeyword->exists()) {
			$oldkeyword->copy($this->keyword)->save();
			return $this->forwardOk($this->urlTo('details', $keyword));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keyword does not exist.');
		}
	}
	
	 !Route DELETE, $keyword  
	function delete($keyword) {
		$this->keyword->keyword = $keyword;
		if($this->keyword->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keyword does not exist.');
		}
	} */
}
?><?php
Library::import('eCenter.models.keywords_service');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix keywordsService/
 */
class keywords_serviceController extends Controller {
	
	/** @var keywords_service */
	protected $keywordsService;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->keywordsService = new keywords_service();
		$this->_form = new ModelForm('keywordsService', $this->request->data('keywordsService'), $this->keywordsService);
	}
	
	/** !Route GET */
	function index() {
		$this->keywordsServiceSet = $this->keywordsService->all();
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $ref_id */
	function details($ref_id) {
		$this->keywordsService->ref_id = $ref_id;
		if($this->keywordsService->exists()) {
			return $this->ok('details');
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->keywordsService->insert();
			return $this->created($this->urlTo('details', $this->keywordsService->ref_id));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $ref_id/edit  
	function editForm($ref_id) {
		$this->keywordsService->ref_id = $ref_id;
		if($this->keywordsService->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $ref_id));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keywords_service does not exist.');
		}
	}
	
	  !Route PUT, $ref_id 
	function update($ref_id) {
		$oldkeywords_service = new keywords_service($ref_id);
		if($oldkeywords_service->exists()) {
			$oldkeywords_service->copy($this->keywordsService)->save();
			return $this->forwardOk($this->urlTo('details', $ref_id));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keywords_service does not exist.');
		}
	}
	
	  !Route DELETE, $ref_id
	function delete($ref_id) {
		$this->keywordsService->ref_id = $ref_id;
		if($this->keywordsService->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'keywords_service does not exist.');
		}
	} */
}
?><?php
Library::import('eCenter.models.metadata');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix metadata/
 */
class metadataController extends Controller {
	
	/** @var metadata */
	protected $metadata;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->metadata = new metadata();
		$this->_form = new ModelForm('metadata', $this->request->data('metadata'), $this->metadata);
	}
	
	/** !Route GET */
	function index() {
		$this->metadataSet = $this->metadata->all();
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $metadata */
	function details($metadata) {
		$this->metadata->metadata = $metadata;
		if($this->metadata->exists()) {
			return $this->ok('details');
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->metadata->insert();
			return $this->created($this->urlTo('details', $this->metadata->metadata));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $metadata/edit  
	function editForm($metadata) {
		$this->metadata->metadata = $metadata;
		if($this->metadata->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $metadata));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'metadata does not exist.');
		}
	}
	
	  !Route PUT, $metadata  
	function update($metadata) {
		$oldmetadata = new metadata($metadata);
		if($oldmetadata->exists()) {
			$oldmetadata->copy($this->metadata)->save();
			return $this->forwardOk($this->urlTo('details', $metadata));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'metadata does not exist.');
		}
	}
	
	  !Route DELETE, $metadata  
	function delete($metadata) {
		$this->metadata->metadata = $metadata;
		if($this->metadata->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'metadata does not exist.');
		}
	}*/
}
?><?php
Library::import('eCenter.models.service');
Library::import('eCenter.models.keywords_service');
Library::import('eCenter.models.eventtype');
Library::import('eCenter.models.metadata');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix service/
 */
class serviceController extends Controller {
	
	/** @var service */
	protected $service;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->service = new service(); 
		$this->_form = new ModelForm('service', $this->request->data('service'), $this->service);
	}
	
	/** !Route GET */
	function index() {
		$this->serviceSet = $this->service->all()->orderBy('type,name');
		
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $service */
	function details($service) {
		$this->service->service = $service;
		$keywords_svc = new keywords_service();
		$eventtype= new eventtype();
		$md = new metadata();
		$this->service->keywords_services = $keywords_svc->equal('service', $service);
		$this->service->eventtypes =  $eventtype->equal('service', $service);
		$this->service->metadatas =  $md->equal('service', $service);
		if($this->service->exists()) {
			return $this->ok('details');
			
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->service->insert();
			return $this->created($this->urlTo('details', $this->service->service));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $service/edit  
	function editForm($service) {
		$this->service->service = $service;
		if($this->service->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $service));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'service does not exist.');
		}
	} */
	
	/** !Route PUT, $service  
	function update($service) {
		$oldservice = new service($service);
		if($oldservice->exists()) {
			$oldservice->copy($this->service)->save();
			return $this->forwardOk($this->urlTo('details', $service));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'service does not exist.');
		}
	} */
	
	/** !Route DELETE, $service  
	function delete($service) {
		$this->service->service = $service;
		if($this->service->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'service does not exist.');
		}
	} */
}
?><?php
Library::import('recess.framework.controllers.Controller');

/**
 * !RespondsWith Layouts
 * !Prefix Views: home/, Routes: /
 */
class ECenterHomeController extends Controller {
	
	/** !Route GET */
	function index() {
		
		$this->flash = '';
		
	}
	
}
?><?php
Library::import('eCenter.models.eventtype');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix eventtype/
 */
class eventtypeController extends Controller {
	
	/** @var eventtype */
	protected $eventtype;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->eventtype = new eventtype();
		$this->_form = new ModelForm('eventtype', $this->request->data('eventtype'), $this->eventtype);
	}
	
	/** !Route GET */
	function index() {
		$this->eventtypeSet = $this->eventtype->all();
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $ref_id */
	function details($ref_id) {
		$this->eventtype->ref_id = $ref_id;
		if($this->eventtype->exists()) {
			return $this->ok('details');
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->eventtype->insert();
			return $this->created($this->urlTo('details', $this->eventtype->ref_id));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $ref_id/edit 
	function editForm($ref_id) {
		$this->eventtype->ref_id = $ref_id;
		if($this->eventtype->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $ref_id));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'eventtype does not exist.');
		}
	}
	
	 !Route PUT, $ref_id  
	function update($ref_id) {
		$oldeventtype = new eventtype($ref_id);
		if($oldeventtype->exists()) {
			$oldeventtype->copy($this->eventtype)->save();
			return $this->forwardOk($this->urlTo('details', $ref_id));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'eventtype does not exist.');
		}
	}
	
	 !Route DELETE, $ref_id  
	function delete($ref_id) {
		$this->eventtype->ref_id = $ref_id;
		if($this->eventtype->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'eventtype does not exist.');
		}
	} */
}
?><?php
Library::import('eCenter.models.user');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts
 * !Prefix user/
 */
class userController extends Controller {
	
	/** @var user */
	protected $user;
	
	/** @var Form */
	protected $_form;
	
	function init() {
		$this->user = new user();
		$this->_form = new ModelForm('user', $this->request->data('user'), $this->user);
	}
	
	/** !Route GET */
	function index() {
		$this->userSet = $this->user->all();
		if(isset($this->request->get['flash'])) {
			$this->flash = $this->request->get['flash'];
		}
	}
	
	/** !Route GET, $user */
	function details($user) {
		$this->user->user = $user;
		if($this->user->exists()) {
			return $this->ok('details');
		} else {
			return $this->forwardNotFound($this->urlTo('index'));
		}
	}
	
	/** !Route GET, new */
	function newForm() {
		$this->_form->to(Methods::POST, $this->urlTo('insert'));
		return $this->ok('editForm');
	}
	
	/** !Route POST */
	function insert() {
		try {
			$this->user->insert();
			return $this->created($this->urlTo('details', $this->user->user));		
		} catch(Exception $exception) {
			return $this->conflict('editForm');
		}
	}
	
	/** !Route GET, $user/edit */
	function editForm($user) {
		$this->user->user = $user;
		if($this->user->exists()) {
			$this->_form->to(Methods::PUT, $this->urlTo('update', $user));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'user does not exist.');
		}
	}
	
	/** !Route PUT, $user */
	function update($user) {
		$olduser = new user($user);
		if($olduser->exists()) {
			$olduser->copy($this->user)->save();
			return $this->forwardOk($this->urlTo('details', $user));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'user does not exist.');
		}
	}
	
	/** !Route DELETE, $user */
	function delete($user) {
		$this->user->user = $user;
		if($this->user->delete()) {
			return $this->forwardOk($this->urlTo('index'));
		} else {
			return $this->forwardNotFound($this->urlTo('index'), 'user does not exist.');
		}
	}
}
?><?php

class RoutingResult {
	public $route = null;
	public $arguments = array();
	public $routeExists = false;
	public $methodIsSupported = false;
	public $acceptableMethods = array();
}

?><?php
/**
 * PathFinder is a utility class that stores a stack of paths and finds the location
 * of a file relative to each of the paths in the reverse order they were added. So, the 
 * most recently added path has the highest precedence.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 */
class PathFinder {
	
	protected $paths = array();
	
	/**
	 * Add a path to the stack that takes higher look-up precedence than previously added paths.
	 * 
	 * @param string $path
	 * @return PathFinder
	 */
	function addPath($path) {
		array_push($this->paths, $path);
		return $this;
	}
	
	/**
	 * Find the path to a file by searching down the stack.
	 * 
	 * @param string $file Relative file name.
	 * @return string or bool The location of the file or false if it cannot be found.
	 */
	function find($file) {
		for($i = count($this->paths) - 1; $i >= 0;  $i--) {
			$filePath = $this->paths[$i] . $file;
			if(file_exists($filePath)) {
				return $filePath;
			}
		}
		return false;
	}
	
	/**
	 * Get the most preferred path as a string.
	 * 
	 * @return string
	 */
	function __toString() {
		if(!empty($this->paths)) {
			return end($this->paths);
		} else {
			return '';
		}
	}
}
?><?php
Library::import('recess.http.Request');
Library::import('recess.http.Cookie');

/**
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Response {
	public $code;
	public $data;
	public $request;
	public $headers = array();
	public $meta = array();
	
	protected $cookies = array();
	
	public function __construct(Request $request, $code, $data = array()) {
		$this->request = $request;
		$this->code = $code;
		$this->data = $data;
		$this->meta = $request->meta;
	}
	
	public function addCookie(Cookie $cookie) {
		$this->cookies[] = $cookie;
	}
	
	public function addCookies($cookies) {
		$this->cookies = array_merge($this->cookies, $cookies);
	}
	
	public function getCookies() {
		return $this->cookies;
	}
	
	public function addHeader($header) {
		$this->headers[] = $header;
	}
	
	public function clearCookies() {
		if(is_array($this->request->cookies))
		foreach(array_keys($this->request->cookies) as $cookieKey) {
			$this->addCookie(new Cookie($cookieKey,''));
		}
	}
}
?><?php

Library::import('recess.http.Response');
Library::import('recess.http.ResponseCodes');

class OkResponse extends Response {
	public function __construct(Request $request, $data = array()) {
		parent::__construct($request, ResponseCodes::HTTP_OK, $data);
	}
}

?><?php
/**
 * ResponseCodes provides named constants for
 * HTTP protocol status codes. Written for the
 * Recess PHP Framework (http://www.recessframework.org/)
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class ResponseCodes {
	// [Informational 1xx]
	const HTTP_CONTINUE = 100;
	const HTTP_SWITCHING_PROTOCOLS = 101;
	// [Successful 2xx]
	const HTTP_OK = 200;
	const HTTP_CREATED = 201;
	const HTTP_ACCEPTED = 202;
	const HTTP_NONAUTHORITATIVE_INFORMATION = 203;
	const HTTP_NO_CONTENT = 204;
	const HTTP_RESET_CONTENT = 205;
	const HTTP_PARTIAL_CONTENT = 206;
	// [Redirection 3xx]
	const HTTP_MULTIPLE_CHOICES = 300;
	const HTTP_MOVED_PERMANENTLY = 301;
	const HTTP_FOUND = 302;
	const HTTP_SEE_OTHER = 303;
	const HTTP_NOT_MODIFIED = 304;
	const HTTP_USE_PROXY = 305;
	const HTTP_UNUSED= 306;
	const HTTP_TEMPORARY_REDIRECT = 307;
	// [Client Error 4xx]
	const errorCodesBeginAt = 400;
	const HTTP_BAD_REQUEST = 400;
	const HTTP_UNAUTHORIZED  = 401;
	const HTTP_PAYMENT_REQUIRED = 402;
	const HTTP_FORBIDDEN = 403;
	const HTTP_NOT_FOUND = 404;
	const HTTP_METHOD_NOT_ALLOWED = 405;
	const HTTP_NOT_ACCEPTABLE = 406;
	const HTTP_PROXY_AUTHENTICATION_REQUIRED = 407;
	const HTTP_REQUEST_TIMEOUT = 408;
	const HTTP_CONFLICT = 409;
	const HTTP_GONE = 410;
	const HTTP_LENGTH_REQUIRED = 411;
	const HTTP_PRECONDITION_FAILED = 412;
	const HTTP_REQUEST_ENTITY_TOO_LARGE = 413;
	const HTTP_REQUEST_URI_TOO_LONG = 414;
	const HTTP_UNSUPPORTED_MEDIA_TYPE = 415;
	const HTTP_REQUESTED_RANGE_NOT_SATISFIABLE = 416;
	const HTTP_EXPECTATION_FAILED = 417;
	// [Server Error 5xx]
	const HTTP_INTERNAL_SERVER_ERROR = 500;
	const HTTP_NOT_IMPLEMENTED = 501;
	const HTTP_BAD_GATEWAY = 502;
	const HTTP_SERVICE_UNAVAILABLE = 503;
	const HTTP_GATEWAY_TIMEOUT = 504;
	const HTTP_VERSION_NOT_SUPPORTED = 505;
		
	private static $messages = array(
		// [Informational 1xx]
		100=>'100 Continue',
		101=>'101 Switching Protocols',
		// [Successful 2xx]
		200=>'200 OK',
		201=>'201 Created',
		202=>'202 Accepted',
		203=>'203 Non-Authoritative Information',
		204=>'204 No Content',
		205=>'205 Reset Content',
		206=>'206 Partial Content',
		// [Redirection 3xx]
		300=>'300 Multiple Choices',
		301=>'301 Moved Permanently',
		302=>'302 Found',
		303=>'303 See Other',
		304=>'304 Not Modified',
		305=>'305 Use Proxy',
		306=>'306 (Unused)',
		307=>'307 Temporary Redirect',
		// [Client Error 4xx]
		400=>'400 Bad Request',
		401=>'401 Unauthorized',
		402=>'402 Payment Required',
		403=>'403 Forbidden',
		404=>'404 Not Found',
		405=>'405 Method Not Allowed',
		406=>'406 Not Acceptable',
		407=>'407 Proxy Authentication Required',
		408=>'408 Request Timeout',
		409=>'409 Conflict',
		410=>'410 Gone',
		411=>'411 Length Required',
		412=>'412 Precondition Failed',
		413=>'413 Request Entity Too Large',
		414=>'414 Request-URI Too Long',
		415=>'415 Unsupported Media Type',
		416=>'416 Requested Range Not Satisfiable',
		417=>'417 Expectation Failed',
		// [Server Error 5xx]
		500=>'500 Internal Server Error',
		501=>'501 Not Implemented',
		502=>'502 Bad Gateway',
		503=>'503 Service Unavailable',
		504=>'504 Gateway Timeout',
		505=>'505 HTTP Version Not Supported'
	);
	
	public static function getMessageForCode($code) {
		return self::$messages[$code];
	}
	
	public static function isError($code) {
		return is_numeric($code) && $code >= self::HTTP_BAD_REQUEST;
	}
	
	public static function canHaveBody($code) {
		return
			// True if not in 100s
			($code < self::HTTP_CONTINUE || $code >= self::HTTP_OK)
			&& // and not 204 NO CONTENT
			$code != self::HTTP_NO_CONTENT
			&& // and not 304 NOT MODIFIED
			$code != self::HTTP_NOT_MODIFIED;
	}
}
?><?php
Library::import('recess.http.Response');
Library::import('recess.lang.Object');

/**
 * Renders a Response in a desired format by sending relevant
 * HTTP headers usually followed by a rendered body.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @author Joshua Paine
 * 
 * @abstract 
 */
abstract class AbstractView extends Object {
	protected $response;
	
	public abstract function canRespondWith(Response $response);
	
	/**
	 * The entry point from the Recess with a Response to be rendered.
	 * Delegates the two steps in rendering a view: 1) Send Headers, 2) Render Body
	 *
	 * @param Response $response
	 */
	public final function respondWith(Response $response) {
		if(!headers_sent())
			$this->sendHeadersFor($response);
		
		if(ResponseCodes::canHaveBody($response->code) && !$response instanceof ForwardingResponse) {
			$this->response = $response;
			$this->render($response);
		}
	}
	
	/**
	 * Get the Request this view is being used in response to
	 * 
	 * @return Request 
	 */
	public function getRequest() {
		return $this->response->request;
	}
	
	/**
	 * Get the response
	 * @return Response
	 */
	public function getResponse() {
		return $this->response;
	}
	
	/**
	 * Import and (as required) initialize helpers for use in the view.
	 * Helper is the path and name of a class as used by Library::import().
	 * For multiple helpers, pass a single array of helpers or use multiple arguments.
	 * 
	 * @param $helper
	 */
	public function loadHelper($helper) {
		$helpers = is_array($helper) ? $helper : func_get_args();
		foreach($helpers as $helper) {
			Library::import($helper);
			$init = array(Library::getClassName($helper),'init');
			if(is_callable($init)) call_user_func($init, $this); 
		}
	}
		
	/**
	 * Responsible for sending all headers in a Response. Marked final because
	 * all headers should be bundled in Response object.
	 *
	 * @param Response $response
	 * @final
	 */
	protected function sendHeadersFor(Response $response) {
		
		header('HTTP/1.1 ' . ResponseCodes::getMessageForCode($response->code));
		
		$format = $response->request->accepts->format();
		header('Content-Type: ' . MimeTypes::preferredMimeTypeFor($format));
		
		foreach($response->headers as $header) {
			header($header);
		}
		
		foreach($response->getCookies() as $cookie) {
			if($cookie->value == '') {
				setcookie($cookie->name, '', time() - 10000, $cookie->path, $cookie->domain, $cookie->secure, $cookie->httponly);
			} else {
				setcookie($cookie->name, $cookie->value, $cookie->expire, $cookie->path, $cookie->domain, $cookie->secure, $cookie->httponly);
			}
		}
		
		flush();
		
		// TODO: Determine other headers to send here. Content-Type, Caching, Etags, ...
	}

	/**
	 * Realizes HTTP's body content based on the Response parameter. Responsible
	 * for returning content in the format desired. The render method likely uses
	 * inversion of control which delegates to another method within the view to 
	 * realize the Response.
	 *
	 * @param Response $response
	 * @abstract 
	 */
	protected abstract function render(Response $response);

}
?><?php
Library::import('recess.framework.AbstractView');

class NativeView extends AbstractView {
	 function getTemplateFor($response) {
		// TODO: Cache in production mode
		$format = $response->request->accepts->format();

		if(is_string($format)) {
			$extension = ".$format.php";
		} else  {
			$extension = '.php';
		}

		$template = $response->meta->viewsPrefix . 
					$response->meta->viewName . 
					$extension;
				
		return $template;
	}

	function canRespondWith(Response $response) {
		// TODO: Cache in production mode
		return Application::active()->findView($this->getTemplateFor($response));
	}

	protected function render(Response $response) {
		$context = $response->data;
		$context['viewsDir'] = $response->meta->app->getViewsDir();
		extract($context);
		include $this->getTemplateFor($response);
	}
}
?><?php
Library::import('recess.framework.views.NativeView');
Library::import('recess.framework.helpers.Layout');
Library::import('recess.framework.helpers.Url');
Library::import('recess.framework.helpers.Html');
Library::import('recess.framework.util.AssertedParams');

class LayoutsView extends NativeView { 	
	/**
	 * Realizes HTTP's body content based on the Response parameter. Responsible
	 * for returning content in the format desired. The render method likely uses
	 * inversion of control which delegates to another method within the view to 
	 * realize the Response.
	 *
	 * @param Response $response
	 * @abstract 
	 */
	protected function render(Response $response) {
		$this->loadHelper(	'recess.framework.helpers.Layout',
							'recess.framework.helpers.Part',
							'recess.framework.helpers.Buffer',
							'recess.framework.helpers.Url',
							'recess.framework.helpers.Html' );
		$template = $this->getTemplateFor($response);
		$template = str_replace($response->meta->app->getViewsDir(), '', $template);
		Layout::draw($template, $response->data);
	}
}
?><?php

class AcceptsList {
	
	protected $range;
	
	protected $types;
	
	protected $qs = false;	
	
	protected $key = 0;
	
	public function __construct($range) {
		$this->range = $range;
	}
	
	public function next() {
		if($this->qs === false) $this->init();
		
		if(isset($this->qs[$this->key])) {
			return $this->qs[$this->key++];
		} else {
			return false;
		}
	}
	
	public function reset() {
		$this->key = 0;
	}
	
	protected function init() {
		// Break apart each type
		$this->types = explode(',', $this->range);
		
		$qs = array();
		
		$count = count($this->types);
		
		// Iterate through each to clean-up and extract precedence
		for($t = 0; $t < $count; $t++) {
			$this->types[$t] = trim($this->types[$t]);
			
			$q = 1.0;
			
			// Break apart type parameters
			$params = explode(';', $this->types[$t]);
			
			$paramsCount = count($params);
			if(count($paramsCount > 1)) {
				for($p = 1; $p < $paramsCount; $p++) {
					$qPos = strpos($params[$p], 'q=');
					if($qPos !== false) {
						$qValue = trim(substr($params[$p], $qPos + 2));
						if(is_numeric($qValue)) {
							$q = $qValue;
						}
					}
				}
			}
			
			$lenParams0 = strlen($params[0]);
			if($lenParams0 > 0 && $params[0][$lenParams0-1] === '*') {
				$q -= 0.01;
				
				if($params[0][0] === '*') {
					$q -= 0.01;
				}
			}
			
			if(!isset($qs[$q])) {
				$qs[(string)$q] = array();
			}
			
			$qs[(string)$q][] = $params[0];
		}
		
		// Sort keys of q-value in descending order
		krsort($qs);
		
		// Re-key qs 0,1,..N for simple iteration
		$this->qs = array_combine(range(0,count($qs)-1), $qs);
	}
	
}

?><?php
abstract class MimeTypes {
	
	protected static $byFormat = array();
	protected static $byMime = array();
	
	static function init() {
		// TODO: Cache the MIME Type Data Structure
		MimeTypes::registerMany(
			array(
				array('html', 'text/html'),
				array('xhtml', 'application/xhtml+xml'),
				array('xml', array('application/xml', 'text/xml', 'application/x-xml')),
				array('json', array('application/json', 'text/x-json','application/jsonrequest')),
				array('js', array('text/javascript', 'application/javascript', 'application/x-javascript')),
				array('css', 'text/css'),
				array('rss', 'application/rss+xml'),
				array('yaml', array('application/x-yaml', 'text/yaml')),
				array('atom', 'application/atom+xml'),
				array('text', 'text/plain'),
				array('png', 'image/png'),
				array('jpg', 'image/jpeg', 'image/pjpeg'),
				array('gif', 'image/gif'),
				array('form', 'multipart/form-data'),
				array('url-form', 'application/x-www-form-urlencoded'),
				array('csv', 'text/csv'),
			)
		);
	}
	
	static function preferredMimeTypeFor($format) {
		if(isset(self::$byFormat[$format])) {
			return self::$byFormat[$format][0];
		} else {
			return false;
		}
	}
	
	static function formatsFor($types) {
		$types = is_array($types) ? $types : array($types);
		
		$linearizedFormats = array();
		
		foreach($types as $type) {
			$parts = explode('/', $type);
			if(count($parts) >= 1) {
				if($parts[0] == '*') {
					// Wildcard -- add all formats and return
					return self::addUnique($linearizedFormats, array_keys(self::$byFormat));
				} else {
					if(isset(self::$byMime[$parts[0]])) {
						if($parts[1] == '*') {
							foreach(self::$byMime[$parts[0]] as $formats) {
								$linearizedFormats = self::addUnique($linearizedFormats, $formats);
							}
						} else {
							if(isset(self::$byMime[$parts[0]][$parts[1]])) {
								$linearizedFormats = self::addUnique($linearizedFormats, self::$byMime[$parts[0]][$parts[1]]);
							}
						}
					}
				}
			}
		}
		
		if( ($key = array_search('html', $linearizedFormats)) !== false) {
			if($key != 0) {
				array_splice($linearizedFormats, $key, 1);
				array_unshift($linearizedFormats, 'html');
			}
		}
		
		return $linearizedFormats;
	}
	
	static private function addUnique($formats, $additionalFormats) {
		foreach($additionalFormats as $format) {
			if(!in_array($format, $formats)) $formats[] = $format;
		}
		return $formats;
	}
	
	
	static function register($type, $extension, $synonyms = array()) {
		self::registerMany(array(array($type,$extension,$synonyms)));
	}
	
	static function registerMany($types) {
		foreach($types as $type) {
			$formats = is_array($type[0]) ? $type[0] : array($type[0]);
			$mimes = is_array($type[1]) ? $type[1] : array($type[1]);
			
			foreach($mimes as $mime) { 
				$parts = explode('/', $mime);
				if(count($parts) == 2) {
					if(!isset(self::$byMime[$parts[0]])) {
						self::$byMime[$parts[0]] = array();
					}
					self::$byMime[$parts[0]][$parts[1]] = $formats;
				}
			}
			
			foreach($formats as $format) {
				if(!isset(self::$byFormat[$format])) {
					self::$byFormat[$format] = array();
				}
				self::$byFormat[$format] = array_unique(array_merge(self::$byFormat[$format], $mimes));
			}
		}
	}
}

MimeTypes::init();
?><?php
Library::import('recess.cache.Cache');
Library::import('recess.lang.PathFinder');
Library::import('recess.framework.helpers.exceptions.MissingRequiredInputException');
Library::import('recess.framework.helpers.exceptions.InputTypeCheckException');

/**
 * AssertiveTemplate is a helper class that provides support for
 * 'Assertive Templates' or templates that assert their inputs. Typically
 * you will use a subclass of AssertiveTemplate, rather than the base
 * class itself.
 * 
 * @author Kris Jordan
 */
abstract class AssertiveTemplate {
	
	/**
	 * Used to locate AssertiveTemplates 
	 * @var Paths
	 */
	private static $paths = false;
	
	/**
	 * Initialize the AssertiveTemplate helper class by registering
	 * the application's views directory as a path.
	 * 
	 * @param AbstractView
	 */
	public static function init(AbstractView $view = null) {
		self::setPathFinder(Application::active()->viewPathFinder());
	}
	
	/**
	 * Add a directory to be checked for the existance of AssertiveTemplates.
	 * Paths are checked in the reverse order of their being added so
	 * that the most specific paths are checked first.
	 * @param string $path
	 */
	public static function addPath($path) {
		if(!self::$paths instanceof PathFinder) {
			// To-do: Cache Paths
			self::$paths = new PathFinder();
		}
		self::$paths->addPath($path);
	}
	
	/**
	 * Set the PathFinder to use when looking for Assertive Templates
	 * @param PathFinder $pathFinder
	 */
	public static function setPathFinder(PathFinder $pathFinder) {
		self::$paths = $pathFinder;
	}
	
	protected static $loaded = array();
	
	/**
	 * Include a PHP file with a context and return the context that results
	 * after the template has been executed.
	 * 
	 * @param string The PHP file to include relative to registered paths.
	 * @param array An associative array whose keys will become variables in the template.
	 * @return array The context after execution of the template as a key/value array.
	 */
	public static function includeTemplate($__assertive_template__, $context) {
		$__assertive_template__ = self::$paths->find($__assertive_template__);
		if($__assertive_template__ === false) {
			throw new Exception('Could not locate AssertiveTemplate: ' . $__assertive_template__);
		}
		// Unset 'context' if it isn't a key in $context
		if(isset($context['context'])) {
			extract($context);
		} else {
			extract($context);
			unset($context);
		}
		include $__assertive_template__;
		return get_defined_vars();
	}
	
	static $types = array('string','int','bool','float','array');
	
	/**
	 * input is used by the assertive templates themselves to assert the
	 * variable name and type of an expected input, as well as a default
	 * value for optional inputs. If the input is required and is missing
	 * this will throw a MissingRequiredInputException. If the input type
	 * does not match the expected type this will throw an 
	 * InputTypeCheckException.
	 * 
	 * @param varies based on the type string passed at argument 2.
	 * @param string The type $input is expected to be.
	 * @param varies Default value for optional arguments.
	 * 
	 * @return Returns the $input, if $input was null and optional returns $default.
	 */
	public static function input(&$input, $type, $default = null) {
		if($input === NULL && $default !== null) {
			$input = $default;
		} else {
			if($input === null) {
				/** Hacky for better debuging experience. Analyze stack to find name of required input missing. */
				$stack = debug_backtrace();
				if(isset($stack[0])) {
					$script = explode("\n", file_get_contents($stack[0]['file']));
					$lineNumber = $stack[0]['line'] - 1;
					$line = $script[$lineNumber];
					preg_match('/\s*(\S*?)::input\(/', $line, $matches);
					if(isset($matches[1])) {
						preg_match(self::getInputRegex($matches[1]), $line, $inputMatches);
						if(isset($inputMatches[1])) {
							throw new MissingRequiredInputException('Missing input "'.$inputMatches[1].'" of type "'.$type.'" in: '.$stack[0]['file'], 1);
						}
					}
				}
				throw new MissingRequiredInputException('Missing required ' . $type . ' input in :' , 1);
			}
		}
		
		if(!self::typeCheck($input, $type)) {
			$passed = gettype($input);
			if($passed === 'object') {
				$passed = get_class($input);
			}
			throw new InputTypeCheckException("Input type mismatch, expected: '$type', actual:'$passed'.", 1);			
		}
		
		return $input;
	}
	
	/**
	 * Determines whether a provided value is of the requested type. Not
	 * quite the same as PHP's internal type checking to allow for type
	 * 'array' to be satisfied by implementations of ArrayAccess. The type
	 * argument is a string that can be either a PHP type like 'string',
	 * 'int', 'float', or a class name.
	 * 
	 * @param variable The value whose type is being checked.
	 * @param string The expected type.
	 * @return boolean True if $value is a $type. False if not.
	 */
	public static function typeCheck($value, $type) {
		if(in_array($type, self::$types)) {
			if($type === 'array') {
				if(!(is_array($value) || $value instanceof ArrayAccess)) {
					return false;
				} else {
					return true;
				}
			} else {
				$fn = 'is_' . $type;
				if(!$fn($value)) {
					return false;
				} else {
					return true;
				}
			}
		} else {
			if(!$value instanceof $type) {
				return false;
			} else {
				return true;
			}
		}
	}
	
	/**
	 * Returns a multi-dimensional array that describes the inputs
	 * of an assertive template. Data available: 
	 *   array[$inputName]['required'] = boolean
	 *   array[$inputName]['type'] = string type representation
	 *   array[$inputName]['default'] = string default value
	 *   
	 * @param string Part name relative to AssertiveTemplate's paths.
	 * @param string The class name to look for, i.e. for Part::input 'Part', Layout::input 'Layout'
	 * @returns array Representation of required inputs.
	 */
	public static function getInputs($template, $class = 'AssertiveTemplate') {
		if(!isset(self::$loaded[$template])) {
			$cacheKey = 'AssertiveTemplate::inputs::' . $template;
			if(($inputs = Cache::get($cacheKey)) !== false) {
				self::$loaded[$template] = $inputs;
			} else {
				if(self::$paths === false) {
					self::init();
				}
				$templateFile = self::$paths->find($template);
				if($templateFile === false) {
					throw new RecessFrameworkException("The file \"$template\" does not exist.", 1);
				}
				$file = file_get_contents($templateFile);
				$pattern = self::getInputRegex($class);
				preg_match_all($pattern, $file, $matches);
		
				$inputs = array();
				foreach($matches[0] as $key => $value) {
					$input = array();
					$name = $matches[1][$key];
					$input['type'] = $matches[2][$key];
					$input['required'] = !isset($matches[3][$key]) || $matches[3][$key] === '';
					if(!$input['required']) {
						$input['default'] = $matches[3][$key];
					} else {
						$input['default'] = null;
					}
					$inputs[$name] = $input;
				}

				self::$loaded[$template] = $inputs;
				Cache::set($cacheKey, $inputs);
			}
		}
		return self::$loaded[$template];
	}
	
	/**
	 * Returns the regex to extract all inputs from a file.
	 * @param string The class name to search for.
	 * @return string The regex.
	 */
	private static function getInputRegex($class) {
		$ws = '(?:\s*)';
		$openParen = '\(';
		$closeParen = '\)';
		$identifier = '[a-zA-Z_][a-zA-Z_0-9]*';
		$quote = '["\']';
		$classInput = "$class$ws::$ws" . "input$ws";
		$dollar = '\$';
		$pattern = "/$classInput$openParen$ws$dollar($identifier)$ws,$ws$quote($identifier)$quote$ws(?:,$ws(.*)|$ws)?$closeParen$ws;/";
		return $pattern;	
	}
}
?><?php
Library::import('recess.framework.helpers.AssertiveTemplate');
Library::import('recess.framework.helpers.Buffer');

/**
 * Layout is a style of AssertiveTemplate that allows child templates
 * to 'extend' parent Layouts. Context is transferred from child to parent
 * by matching variables that exist in the child and are registered
 * as an input to the parent. Thus layouts must specify any required and
 * optional inputs they expect to be passed.
 * 
 * Parent layouts require a '.layout.php' extension.
 * 
 * @author Kris
 */
class Layout extends AssertiveTemplate {
	private static $parentStack = array();
	private static $debugTraces = array();
	
	/**
	 * Outputs a child template. Pass the template name (with extension) and
	 * an associative array context of variables to be passed to the child.
	 * 
	 * @param string The filename of the template, with extension, relative to AssertiveTemplate paths.
	 * @param array The associative array of context the child template expects.
	 * @return boolean Returns true on success.
	 */
	public static function draw($template, $context) {
		Buffer::to($body);
		$context = self::includeTemplate($template, $context);
		Buffer::end();
		
		if(empty(self::$parentStack)) {
			echo $body;
			return true;
		} else {
			if(!isset($context['body'])) {
				$context['body'] = $body;
			}
			while($parent = array_pop(self::$parentStack)) {
				try{
					$parentInputs = self::getInputs($parent, 'Layout');
				}catch(RecessFrameworkException $e) {
	//				if(RecessConf::$mode == RecessConf::DEVELOPMENT) {
						$trace = array_pop(self::$debugTraces);
						throw new RecessErrorException('Extended layout does not exist.', 0, 0, $trace[0]['file'], $trace[0]['line'], $trace[0]['args']);
	//				} else {
	//					throw $e;
	//				}
				}
				$context = array_intersect_key($context, $parentInputs);
				$context = self::includeTemplate($parent, $context);
			}
	//		if(RecessConf::$mode == RecessConf::DEVELOPMENT) {
				array_pop(self::$debugTraces);
	//		}
			return true;
		}
	}
	
	/**
	 * Used by child templates so indicate they 'extend' a parent layout which
	 * is to be included and assume all requested context from a child. Parent
	 * layouts are required to use a '.layout.php' extension.
	 * 
	 * @param string The name of the layout being extended without the '.layout.php' extension.
	 */
	public static function extend($assertiveTemplate) {
		if(strpos($assertiveTemplate,'/layout') !== strlen($assertiveTemplate) - 7) {
			array_push(self::$parentStack, $assertiveTemplate . '.layout.php');
		} else {
			array_push(self::$parentStack, $assertiveTemplate . '.php');
		}
		//if(RecessConf::$mode == RecessConf::DEVELOPMENT) {
			$trace = debug_backtrace();
			array_pop($trace);
			array_push(self::$debugTraces, $trace);
		//}
	}
}
?><?php
Library::import('recess.framework.helpers.AssertiveTemplate');
Library::import('recess.framework.helpers.blocks.PartBlock');
Library::import('recess.framework.helpers.exceptions.MissingRequiredDrawArgumentsException');

/**
 * A Part is a template that defines specific inputs and has similarities 
 * to 'partials' of other frameworks. These inputs are defined sequentially
 * so that parts can be drawn with a list of arguments just like a function
 * call. Parts have a Block counterpart: PartBlock which can be instantiated
 * using the static 'block' method.
 * 
 * Part templates require the extension: '.part.php'
 * 
 * @author Kris Jordan
 */
class Part extends AssertiveTemplate {
	protected static $app;
	
	/**
	 * Returns a multi-dimensional array that describes the inputs
	 * of a part. Data available: 
	 *   array[$inputName]['required'] = boolean
	 *   array[$inputName]['type'] = string type representation
	 *   
	 * @param string Part name relative to AssertiveTemplate's paths.
	 * @param string Always use 'Part' here.
	 * @returns array Representation of required inputs.
	 */
	public static function getInputs($part, $class = 'Part') {
		return parent::getInputs($part . '.part.php', $class);
	}
	
	/**
	 * Send a part directly to output with the provided arguments. The first
	 * argument is the filename of the part relative to paths registered with
	 * AssertiveTemplate minus the '.part.php' extension. Subsequent arguments
	 * depend on the parts themselves.
	 * 
	 * @param string The filename of part relative to AssertiveTemplate's paths minus '.part.php'
	 * @param Depends on the part's inputs.
	 * @return boolean Returns true if successful. Throws if unsuccessful.
	 */
	public static function draw() {
		$args = func_get_args();
		try {	
			if(!empty($args)) {
				$partPath = array_shift($args);
				
				$argCount = count($args);
				if($argCount > 0) {
					$inputs = self::getInputs($partPath);
					$inputKeys = array_keys($inputs);
					$inputCount = count($inputKeys);
					if($inputCount > $argCount) {
						$inputKeys = array_slice($inputKeys, 0, $argCount);
					} else {
						$args = array_slice($args, 0, $inputCount);
					}
					if(!empty($inputKeys)) {
						$args = array_combine($inputKeys, $args);
					}
				}
				
				self::drawArray($partPath, $args);
			}
		} catch(MissingRequiredInputException $e) {
			throw new MissingRequiredDrawArgumentsException($e->getMessage(), 1);
		}
		
		return true;
	}
	
	/**
	 * Factory method to produce PartListBlock, a Block equivalent to Part. PartBlock
	 * instances store the arguments they've been instantiated with so that when
	 * their draw method is called only the remaining arguments (if any) must be
	 * passed. Ex:
	 * 
	 * $block = Block::part('a-part', 'one');
	 * $block->draw();
	 * 
	 * Equivalent to:
	 * $block = Block::part('a-part');
	 * $block->draw('one')
	 * 
	 * @see BlockPart for more information on its capabilities.
	 * @param string The name of the part template.
	 * @param varies Based on part.
	 * @return PartBlock Returns a block that retains the arguments passed in.
	 */
	public static function block() {
		$args = func_get_args();
		return new PartBlock($args);
	}
	
	/**
	 * Draw a part by passing a key/value array where the keys match the
	 * part's input variable names.
	 * 
	 * @param string The name of the part template.
	 * @param array Key/values according to part's input(s).
	 * @return boolean True if successful, throws exception if unsuccessful.
	 */
	public static function drawArray($partPath = '', $args = array()) {
		if(!is_array($args)) {
			throw new RecessFrameworkException("Part::drawArray must be called with an array.", 1);
		}
		if($partPath === '') {
			throw new RecessFrameworkException("First parameter 'partPath' must not be empty.", 1);
		}
		
		try {
			$inputs = self::getInputs($partPath, 'Part');
		} catch(Exception $e) { 
			throw new RecessFrameworkException("Could not find Part: $partPath", 1);
		}
		
		$part = $partPath;
		$part .= '.part.php';
		
		// What if drawArray is always passed key=>value pairs?
		$context = array_intersect_key($args, $inputs);
		
		self::includeTemplate($part, $context);
		
		return true;
	}
}
?><?php
abstract class AbstractHelper {
	public static function init(AbstractView $view) {}
}
?><?php
Library::import('recess.framework.helpers.blocks.Block');
Library::import('recess.framework.helpers.blocks.HtmlBlock');
Library::import('recess.framework.helpers.blocks.ListBlock');
Library::import('recess.framework.AbstractHelper');

/**
 * Buffer is a helper class that acts as a factory for
 * HtmlBlocks. Buffer and blocks are often used in conjunction
 * with layouts as an easy mechanism for transferring chunks of
 * HTML from a child template to a parent Layout.
 * 
 * Buffer can be used to fill unempty HtmlBlocks,
 * overwrite HtmlBlocks, or append/prepend to them. Here are some
 * example usages:
 * 
 * Buffer::to($block);
 * echo 'hello world';
 * Buffer::end();
 * // $block is now an HtmlBlock with contents 'hello world'
 * 
 * Buffer::append($block);
 * echo '!<br />';
 * Buffer::end();
 * // $block is now an HtmlBlock with contents 'hello world!<br />'
 * 
 * Buffer::to($block);
 * print_r($block);
 * Block::end();
 * // $block is still 'hello world!<br />'
 * 
 * Buffer::to($block, Buffer::OVERWRITE);
 * echo 'overwritten';
 * Buffer::end();
 * // $block is now 'overwritten'
 * 
 * echo $block;
 * // overwritten
 * 
 * @author Kris Jordan
 */
abstract class Buffer extends AbstractHelper {
	
	const NORMAL = 0;
	const OVERWRITE = 1;
	const APPEND = 2;
	const PREPEND = 3;
	
	/** STATIC MEMBERS **/
	
	private static $bufferBlocks = array();
	private static $bufferModes = array();
	
	/**
	 * Begin output buffering to the block passed by reference. If the
	 * reference is set to Null a new HtmlBlock will be assigned to the 
	 * reference.
	 * 
	 * @param HtmlBlock or Null - The block the buffer will fill.
	 * @param int Optional - mode used to fill block.
	 */
	public static function to(&$block, $mode = self::NORMAL) {
		self::modalStart($block, $mode);
	}
	
	/**
	 * Buffer will append to the provided HtmlBlock. If null this will
	 * create a new block, not fail.
	 * 
	 * @param HtmlBlock The block to append to.
	 */
	public static function appendTo(&$block) {
		self::modalStart($block, self::APPEND);
	}
	
	/**
	 * Buffer will append to the provided HtmlBlock. If null this will
	 * create a new block, not fail.
	 * 
	 * @param HtmlBlock The block to append to.
	 */
	public static function prependTo(&$block) {
		self::modalStart($block, self::PREPEND);
	}

	/**
	 * Internal helper method for starting a new buffer.
	 * 
	 * @param HtmlBlock The block to append to.
	 */
	private static function modalStart(&$block, $mode) {
		if($block === null) {
			$block = new HtmlBlock();
		}
		array_push(self::$bufferBlocks, $block);
		array_push(self::$bufferModes, $mode);
		ob_start();
	}
	
	/**
	 * End the output buffer, clear contents, and assign contents
	 * to the block passed by reference to start the buffer. Also
	 * returns the block.
	 * 
	 * @return The final block.
	 */
	public static function end() {
		if(empty(self::$bufferBlocks)) {
			throw new RecessFrameworkException('Buffer ended without corresponding Buffer::to($block).', 2);
		}		
		$buffer = ob_get_clean();
		$mode = array_pop(self::$bufferModes);
		$block = array_pop(self::$bufferBlocks);
		switch($mode) {
			case self::NORMAL: 
				if((string)$block === '') {
					$block->set($buffer);
				}
				break;
			case self::OVERWRITE:
				$block->set($buffer);
				break;
			case self::APPEND:
				$block->append($buffer);
				break;
			case self::PREPEND:
				$block->prepend($buffer);
				break;
		}
		return $block;
	}
	
}
?><?php
Library::import('recess.framework.AbstractHelper');

/**
 * The URL helper is used in views to generate URLs to many aspects
 * of an application (controller actions, assets, etc)
 * 
 * @author Joshua Paine
 * @author Kris Jordan
 */
class Url extends AbstractHelper {

	protected static $assetUrl;
	
	protected static $app;
	
	/**
	 * Initialize the helper with state from the View
	 * @param $view
	 */
	public static function init(AbstractView $view){
		$request = $view->getRequest();
		self::setApp($request->meta->app);
	}
	
	/**
	 * Change the application this helper refers to.
	 * @param $app
	 */
	public static function setApp(Application $app) {
		self::$app = $app;
		self::$assetUrl = self::$app->getAssetUrl();
	}
	
	/**
	 * Change the assetUrl this helper uses.
	 * 
	 * @param $url
	 */
	public static function setAssetUrl($urlPrefix) {
		self::$assetUrl = $urlPrefix;
	}
	
	/**
	 * Appends suffix parameter to the base URL to generate an absolute URL.
	 * 
	 * @param $suffix
	 * @return string Absolute URL
	 */
	public static function base($suffix = ''){
		return $_ENV['url.base'] . $suffix;
	}
	
	/**
	 * Returns the URL to an asset in the assets directory.
	 * 
	 * @param $file
	 * @return string URL to an asset.
	 */
	public static function asset($file = ''){
		return self::$assetUrl . $file;
	}
	
	/**
	 * Returns the URL to an action (Controller/Method pair). Usage example:
	 * url::action('Controller::method'[, 'arg1', ...]);
	 * 
	 * @param $actionControllerMethodPair
	 * @return string URL to an application action.
	 */
	public static function action($actionControllerMethodPair) {
		try {
			$args = func_get_args();
			return call_user_func_array(array(self::$app,'urlTo'),$args);
		} catch(Exception $e) {
			throw new RecessFrameworkException("No URL for $actionControllerMethodPair exists.", 1);
		}
	}
	
}
?><?php
Library::import('recess.framework.AbstractHelper');
Library::import('recess.framework.helpers.Url');

/**
 * HTML helper class.
 * @author Joshua Paine
 * @author Kris Jordan
 * @todo Add protocol parameters back in to anchor and url::..
 * 
 * Based upon Kohana's HTML helper:
 * @author     Kohana Team
 * @copyright  (c) 2007-2009 Kohana Team
 * @license    http://kohanaphp.com/license
 */
class Html extends AbstractHelper {

	/**
	 * Convert special characters to HTML entities
	 *
	 * @param   string   string to convert
	 * @param   boolean  encode existing entities
	 * @return  string
	 */
	public static function specialchars($str, $double_encode = true) {
		// Force the string to be a string
		$str = (string) $str;

		// Do encode existing HTML entities (default)
		if ($double_encode === true) {
			$str = htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
		} else {
			// Do not encode existing HTML entities
			// From PHP 5.2.3 this functionality is built-in, otherwise use a regex
			if (version_compare(PHP_VERSION, '5.2.3', '>=')) {
				$str = htmlspecialchars($str, ENT_QUOTES, 'UTF-8', false);
			} else {
				$str = preg_replace('/&(?!(?:#\d++|[a-z]++);)/ui', '&amp;', $str);
				$str = str_replace(array('<', '>', '\'', '"'), array('&lt;', '&gt;', '&#39;', '&quot;'), $str);
			}
		}

		return $str;
	}

	/**
	 * Create HTML link anchors.
	 *
	 * @param   string  URL or URI string
	 * @param   string  link text
	 * @param   array   HTML anchor attributes
	 * @return  string
	 */
	public static function anchor($uri, $title = NULL, $attributes = NULL) {
		if ($uri === '') {
			$siteUrl = url::base();
		} else {
			$siteUrl = $uri;
		}

		return
		// Parsed URL
		'<a href="'.html::specialchars($siteUrl, false).'"'
		// Attributes empty? Use an empty string
		.(is_array($attributes) ? html::attributes($attributes) : '').'>'
		// Title empty? Use the parsed URL
		.(($title === NULL) ? $siteUrl : $title).'</a>';
	}


	/**
	 * Creates a stylesheet link.
	 *
	 * @param   string|array  filename, or array of filenames to match to array of medias
	 * @param   string|array  media type of stylesheet, or array to match filenames
	 * @return  string
	 */
	public static function css($style, $media = FALSE) {
		if(is_array($media)) {
			$media = implode(', ', $media);
		}
		return html::link($style, 'stylesheet', 'text/css', '.css', $media);
	}

	/**
	 * Creates a link tag.
	 *
	 * @param   string|array  filename
	 * @param   string|array  relationship
	 * @param   string|array  mimetype
	 * @param   string        specifies suffix of the file
	 * @param   string|array  specifies on what device the document will be displayed
	 * @return  string
	 */
	public static function link($href, $rel, $type, $suffix = FALSE, $media = FALSE) {
		$compiled = '';

		if (is_array($href)) {
			foreach ($href as $_href) {
				$_rel   = is_array($rel) ? array_shift($rel) : $rel;
				$_type  = is_array($type) ? array_shift($type) : $type;
				$_media = is_array($media) ? array_shift($media) : $media;

				$compiled .= html::link($_href, $_rel, $_type, $suffix, $_media);
			}
		} else {
			// Add the suffix only when it's not already present
			$suffix   = ( ! empty($suffix) AND strpos($href, $suffix) === FALSE) ? $suffix : '';
			$media    = empty($media) ? '' : ' media="'.$media.'"';
			$compiled = '<link rel="'.$rel.'" type="'.$type.'" href="'.url::asset(($type=="text/css" ? 'css/' : '').$href.$suffix).'"'.$media.' />';
		}

		return $compiled."\n";
	}

	/**
	 * Creates a script link.
	 *
	 * @param   string|array  filename
	 * @return  string
	 */
	public static function js($script) {
		$compiled = '';

		if (is_array($script)) {
			foreach ($script as $name) {
				$compiled .= html::js($name);
			}
		} else {
			// Do not touch full URLs
			if (strpos($script, '://') === FALSE) {
				// Add the suffix only when it's not already present
				$suffix = (substr($script, -3) !== '.js') ? '.js' : '';
				$script = url::asset('js/'.$script.$suffix);
			}
			$compiled = '<script type="text/javascript" src="'.$script.'"></script>';
		}

		return $compiled."\n";
	}

	/**
	 * Creates a image link.
	 *
	 * @param   string        image source, or an array of attributes
	 * @param   string|array  image alt attribute, or an array of attributes
	 * @return  string
	 */
	public static function img($src = NULL, $alt = NULL) {
		// Create attribute list
		$attributes = is_array($src) ? $src : array('src' => $src);

		if (is_array($alt)) {
			$attributes += $alt;
		} elseif ( ! empty($alt)) {
			// Add alt to attributes
			$attributes['alt'] = $alt;
		}
		if(!isset($attributes['alt'])) $attributes['alt'] = '';
		if (strpos($attributes['src'], '://') === FALSE) {
			// Make the src attribute into an absolute URL
			$attributes['src'] = url::asset('img/'.$attributes['src']);
		}

		return '<img'.html::attributes($attributes).'>';
	}

	/**
	 * Compiles an array of HTML attributes into an attribute string.
	 *
	 * @param   string|array  array of attributes
	 * @return  string
	 */
	public static function attributes($attrs) {
		if (empty($attrs))
			return '';

		if (is_string($attrs))
			return ' '.$attrs;

		$compiled = '';
		foreach ($attrs as $key => $val) {
			$compiled .= ' '.$key.'="'.$val.'"';
		}

		return $compiled;
	}

} // End html

function h($var,$encode_entities=true){ return html::specialchars($var,$encode_entities); }
?><?php
Library::import('recess.framework.helpers.exceptions.MissingRequiredDrawArgumentsException');
Library::import('recess.framework.helpers.exceptions.BlockToStringException');

/**
 * A Block is a fundamental unit of UI in Recess.
 * 
 * @author Kris Jordan
 * @since 0.20
 */
abstract class Block {
	
	/**
	 * Output the contents of the block. Returns true if successful or false if
	 * the block is empty. Sub-classes of block may optionally require parameters
	 * be passed to draw. If these parameters are not passed as expected the
	 * sub-class must throw an exception of type MissingRequiredDrawArgumentsException.
	 * 
	 * @return boolean
	 */
	public abstract function draw();
	
	/**
	 * Return the contents of this block as a string. If the block is not fully
	 * formed (i.e., it's draw requires an argument), then __toString will throw
	 * an exception of type BlockToStringException.
	 * 
	 * @return string
	 */
	public abstract function __toString();
	
}
?><?php
Library::import('recess.framework.helpers.blocks.Block');

/**
 * HtmlBlock is a Block that wraps around static HTML strings.
 * It is often used in conjunction with Buffer which is a helper
 * for automatically buffering output to blocks.
 *  
 * @author Kris Jordan
 */
class HtmlBlock extends Block {
	protected $contents = '';
	
	/**
	 * HtmlBlock can be constructed with an optional string that denotes
	 * its initial contents. i.e. $block = new HtmlBlock('<p>hello world</p>');
	 * @param string Contents optional.
	 */
	public function __construct($contents = '') {
		$this->contents = $contents;
	}
	
	/**
	 * If the block has contents, draw will output the contents and return true. 
	 * If not, it will return false. HtmlBlock's draw takes no arguments and 
	 * will never throw MissingArgumentsException.
	 * 
	 * @see recess/framework/helpers/blocks/Block#draw()
	 */
	public function draw() {
		if($this->contents !== '') {
			echo $this->contents;
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Return 
	 * @see recess/recess/recess/framework/helpers/blocks/Block#__toString()
	 */
	public function __toString(){
		return $this->contents;
	}
	
	public function set($contents) {
		$this->contents = $contents;
	}
	
	public function append($contents) {
		$this->contents .= $contents;
	}
	
	public function prepend($contents) {
		$this->contents = $contents . $this->contents;
	}
}
?><?php
/**
 * The inflector provides basic functionality for transforming words
 * between their singular and plural forms, as well as programmatic forms
 * (i.e. camelCapsFormat, ProperCapsFormat, under_scores_format)
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class Inflector {
	
	/**
	 * Return the plural form of an english word, in many cases.
	 * Currently this is naive and only appends an 's' to the end of a word.
	 * i.e. person => persons
	 *      thing => things
	 *      goose => gooses
	 *
	 * @param string $word
	 * @return string
	 */
	public static function toPlural($word) {
		return $word .= 's';
	}
	
	/**
	 * Return the singular form of an english word, in many cases.
	 * Currently this is naive and only removes the last character
	 * of a string.
	 * 
	 * i.e. persons => persons
	 * 		things => thing
	 * 		oxen => oxe
	 *
	 * @param string $word
	 * @return string
	 */
	public static function toSingular($word) {
		return substr($word, 0, -1);
	}
	
	/**
	 * Return whether or not an english word is plural. Currently
	 * naive and only returns whether or not the last character
	 * is an 's' or not.
	 *
	 * @param string $word
	 * @return string
	 */
	public static function isPlural($word) {
		return substr($word, -1, 1) === 's';
	}
	
	/**
	 * Go from underscores_form or camelCapsForm to ProperCapsForm.
	 * 
	 * i.e. this_is_in_underscores => ThisIsInUnderscores
	 * 		helloWorld => HelloWorld
	 * 
	 * @param string $word in camelCaps or underscores_form.
	 * @return string in ProperCapsForm
	 */
	public static function toProperCaps($word) {
		$word = explode('_', trim($word, '_'));
		$word = array_map('ucfirst', $word);
		return implode('', $word);
	}
	
	/**
	 * Go from underscores_form or ProperCapsForm to camelCapsForm
	 * 
	 * i.e. this_is_in_underscores => thisIsInUnderscores
	 * 		HelloWorld => helloWorld
	 *
	 * @param string $word in ProperCapsForm or underscores_form
	 * @return string camelCapsForm
	 */
	public static function toCamelCaps($word) {
		$word = self::toProperCaps($word);
		$word[0] = strtolower($word[0]);
		return $word;
	}
	
	/**
	 * Go from ProperCapsForm or camelCapsForm to underscores_form
	 *
	 * @param string $word in camelCapsForm or ProperCapsForm
	 * @return string underscores_form
	 */
	public static function toUnderscores($word) {
		return strtolower(
			preg_replace('/_+/', '_',
				trim(
					preg_replace(
						'/[A-Z]/',
						"_\\0",
						$word
					),
				'_')
			)
		);
	}
	
	/**
	 * Go from underscores_form or camelCapsForm or ProperCapsForm to English Form.
	 *
	 * @param string $word in underscores_form or camelCapsForm or ProperCapsForm
	 * @return string in English Form
	 */
	public static function toEnglish($word) {
		$word = Inflector::toUnderscores($word);
		$word = explode('_', $word);
		$word = array_map('ucfirst', $word);
		return implode(' ', $word);
	}
}

?><?php
Library::import('recess.lang.Annotation');

/**
 * Abstract class for relationship annotations.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class AbstractRelationshipAnnotation extends Annotation {

	static $ON_DELETE_VALUES = array(Relationship::CASCADE, Relationship::DELETE, Relationship::NULLIFY);
	
	protected $class;
	protected $key;
	protected $through;
	protected $ondelete;
	
	public function isFor() {
		return Annotation::FOR_CLASS;
	}
	
	protected function expandHelper($relationship, $descriptor) {
		$relationshipName = $this->values[0];
		
		if(isset($this->class)) {
			$relationship->foreignClass = $this->class;
		}
		
		if(isset($this->key)) {
			$relationship->foreignKey = $this->key;
		}
		
		if(isset($this->through)) {
			$relationship->through = $this->through;
		}
		
		if(isset($this->ondelete)) {
			$relationship->onDelete = strtolower($this->ondelete);
		}
		
		$descriptor->relationships[$relationshipName] = $relationship;
		
		$relationship->attachMethodsToModelDescriptor($descriptor);
	}

}
?><?php
Library::import('recess.database.orm.annotations.AbstractRelationshipAnnotation');
Library::import('recess.database.orm.relationships.HasManyRelationship');

/**
 * An annotation used on Model Classes, the HasMany annotations gives a model
 * a HasManyRelationship.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class HasManyAnnotation extends AbstractRelationshipAnnotation {
	
	static $ACCEPTED_KEYS = array(Relationship::FOREIGN_CLASS, Relationship::FOREIGN_KEY, Relationship::THROUGH, Relationship::ON_DELETE);	

	public function usage() {
		return '!HasMany relationshipName [, Class: relatedClass] [, Key: foreignKey] [, Through: throughClass ] [, OnDelete: ( Delete | Cascade | Nullify )]';
	}
	
	protected function validate($class) {
		$this->minimumParameterCount(1);
		$this->maximumParameterCount(5);
		$this->acceptedKeys(self::$ACCEPTED_KEYS);
		$this->acceptedValuesForKey(Relationship::ON_DELETE, parent::$ON_DELETE_VALUES, CASE_LOWER);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$relationshipName = $this->values[0];
		
		$relationship = new HasManyRelationship();
		$relationship->init($class, $relationshipName);
		
		$this->expandHelper($relationship, $descriptor);
	}

}
?><?php
Library::import('recess.database.orm.annotations.AbstractRelationshipAnnotation');
Library::import('recess.database.orm.relationships.BelongsToRelationship');

/**
 * An annotation used on Model Classes, the BelongsTo annotation gives a model
 * a BelongsToRelationship.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class BelongsToAnnotation extends AbstractRelationshipAnnotation {
	
	static $ACCEPTED_KEYS = array(Relationship::FOREIGN_CLASS, Relationship::FOREIGN_KEY, Relationship::ON_DELETE);
	
	public function usage() {
		return '!BelongsTo relationshipName [, Class: relatedClass] [, Key: foreignKey] [, OnDelete: ( Nullify | Cascade | Delete )]';
	}
	
	protected function validate($class) {
		$this->minimumParameterCount(1);
		$this->maximumParameterCount(4);
		$this->acceptedKeys(self::$ACCEPTED_KEYS);
		$this->acceptedValuesForKey(Relationship::ON_DELETE, parent::$ON_DELETE_VALUES, CASE_LOWER);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$relationshipName = $this->values[0];
		
		$relationship = new BelongsToRelationship();
		$relationship->init($class, $relationshipName);
		
		$this->expandHelper($relationship, $descriptor);
	}

}
?><?php
Library::import('recess.database.orm.annotations');

/**
 * An annotation used on Model Classes, the Database annotations sets the name
 * of the data source (Databases::getSource($name)) this Model should talk to.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class DatabaseAnnotation extends Annotation {
	
	public function usage() {
		return '!Database databaseName';
	}

	public function isFor() {
		return Annotation::FOR_CLASS;
	}

	protected function validate($class) {
		$this->acceptsNoKeyedValues();
		$this->exactParameterCount(1);
		$this->validOnSubclassesOf($class, Model::CLASSNAME);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$descriptor->source = $this->values[0];
	}
	
}
?><?php
Library::import('recess.database.orm.annotations');

/**
 * An annotation used on Model Classes, the Table annotations links a model
 * to a table in the RDBMS.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class TableAnnotation extends Annotation {
		
	public function usage() {
		return '!Table tableName';
	}

	public function isFor() {
		return Annotation::FOR_CLASS;
	}
	
	protected function validate($class) {
		$this->acceptsNoKeyedValues();
		$this->exactParameterCount(1);
		$this->validOnSubclassesOf($class, Model::CLASSNAME);
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$descriptor->setTable($this->values[0]);
	}
	
}
?><?php
Library::import('recess.lang.Annotation');
Library::import('recess.database.pdo.RecessType');

/**
 * An annotation used on Model properties which specifies information about the column
 * a given property maps to in the data source.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class ColumnAnnotation extends Annotation {
	const PRIMARY_KEY = 'PrimaryKey';
	const AUTO_INCREMENT = 'AutoIncrement';
	
	public function usage() {
		return '!Column type [, PrimaryKey] [, AutoIncrement]';
	}
	
	public function isFor() {
		return Annotation::FOR_PROPERTY;
	}

	protected function validate($class) {
		$this->acceptsNoKeyedValues();
		$this->minimumParameterCount(1);
		$this->maximumParameterCount(3);
		$this->acceptedKeylessValues(array_merge(RecessType::all(), array('PrimaryKey', 'AutoIncrement')));
	}
	
	protected function expand($class, $reflection, $descriptor) {
		$propertyName = $reflection->getName();
		if(isset($descriptor->properties[$propertyName])) {
			$property = &$descriptor->properties[$propertyName];
			$property->type = $this->valueNotIn(array(self::PRIMARY_KEY, self::AUTO_INCREMENT));
			$property->isPrimaryKey = $this->isAValue(self::PRIMARY_KEY);
			$property->isAutoIncrement = $this->isAValue(self::AUTO_INCREMENT);
			
			if($property->isPrimaryKey) {
				$descriptor->primaryKey = $propertyName;
			}
		}
	}
}
?><?php
/**
 * Interface used which maps to conditional SQL statements
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
interface ISqlConditions {
	
	function equal($column, $value);
	function notEqual($column, $value);
	function between ($column, $big, $small);
	function greaterThan($column, $value);
	function greaterThanOrEqualTo($column, $value);
	function lessThan($column, $value);
	function lessThanOrEqualTo($column, $value);
	function like($column, $value);
	function notLike($column, $value);
  function in($column, $value);
	
}
?><?php
Library::import('recess.lang.Inflector');
Library::import('recess.lang.Object');
Library::import('recess.lang.reflection.RecessReflectionClass');
Library::import('recess.lang.Annotation');

Library::import('recess.database.Databases');
Library::import('recess.database.sql.ISqlConditions');
Library::import('recess.database.orm.ModelClassInfo');
Library::import('recess.database.sql.SqlBuilder');

Library::import('recess.database.orm.annotations.HasManyAnnotation', true);
Library::import('recess.database.orm.annotations.BelongsToAnnotation', true);
Library::import('recess.database.orm.annotations.DatabaseAnnotation', true);
Library::import('recess.database.orm.annotations.TableAnnotation', true);
Library::import('recess.database.orm.annotations.ColumnAnnotation', true);

Library::import('recess.database.orm.relationships.Relationship');
Library::import('recess.database.orm.relationships.HasManyRelationship');
Library::import('recess.database.orm.relationships.BelongsToRelationship');

/**
 * Model is the basic unit of organization in Recess' simple ORM.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class Model extends Object implements ISqlConditions {
	
	const CLASSNAME = 'Model';
	const INSERT = 'insert';
	const UPDATE = 'update';
	const DELETE = 'delete';
	const SAVE = 'save';
	
	/**
	 * Constructor can take either a keyed array or a string/int
	 * to set the primary key with;
	 *
	 * @param mixed $data
	 */
	final public function __construct($data = null) {
		if(is_numeric($data) || is_string($data)) {
			$primaryKey = Model::primaryKeyName($this);
			$this->$primaryKey = $data;
		} else if (is_array($data)) {
			$this->copy($data, false);
		}
	}
	
	/**
	 * Get the datasource for a class.
	 *
	 * @param mixed $class
	 * @return ModelDataSource
	 */
	static function sourceFor($class) {
		return self::getClassDescriptor($class)->getSource();
	}
	
	/**
	 * Get the name of the datasource for a class
	 *
	 * @param mixed $class
	 * @return string Key name of the ModelDataSource in Databases
	 */
	static function sourceNameFor($class) {
		return self::getClassDescriptor($class)->getSourceName();
	}
	
	/**
	 * The table which $modelClass is persisted on.
	 *
	 * @param mixed $class
	 * @return string Table Name
	 */
	static function tableFor($class) {
		return self::getClassDescriptor($class)->getTable();
	}
	
	/**
	 * Return the primary key column name for a class. This is prefixed
	 * with the class' table name.
	 *
	 * @param midex $class
	 * @return string Primary Key Column Name ie "table.id"
	 */
	static function primaryKeyFor($class) {
		$descriptor = self::getClassDescriptor($class);
		return $descriptor->getTable() . '.' . $descriptor->primaryKey;
	}
	
	/**
	 * Return the property name for the primary key.
	 *
	 * @param mixed $class
	 * @return string Primary key name ie: 'id'
	 */
	static function primaryKeyName($class) {
		return self::getClassDescriptor($class)->primaryKey;
	}
	
	/**
	 * Get a relationship on a class or instance by the relationship's name.
	 *
	 * @param mixed $classOrInstance
	 * @param string $name of the relationship
	 * @return Relationship
	 */
	static function getRelationship($classOrInstance, $name) {
		if(isset(self::getClassDescriptor($classOrInstance)->relationships[$name])) {
			return self::getClassDescriptor($classOrInstance)->relationships[$name];
		} else {
			return false;
		}
	}
	
	/**
	 * Return all relationships for a class or instance
	 *
	 * @param mixed $classOrInstance
	 * @return array of Relationship
	 */
	static function getRelationships($classOrInstance) {
		return self::getClassDescriptor($classOrInstance)->relationships;
	}
	
	/**
	 * Retrieve an array of column names in the table corresponding to
	 * a model class.
	 *
	 * @param mixed $classOrInstance
	 * @return array of strings of column names
	 */
	static function getColumns($classOrInstance) {
		return self::getClassDescriptor($classOrInstance)->columns;
	}
	
	/**
	 * Retrieve an array of the properties.
	 *
	 * @param mixed $classOrInstance
	 * @return array of type ModelProperty
	 */
	static function getProperties($classOrInstance) {
		return self::getClassDescriptor($classOrInstance)->properties;
	}

	protected static function initClassDescriptor($class) {	
		return new ModelDescriptor($class, false);
	}
	
	protected static function shapeDescriptorWithProperty($class, $property, $descriptor, $annotations) {
		if(!$property->isStatic() && $property->isPublic()) {
			$modelProperty = new ModelProperty();
			$modelProperty->name = $property->name;
			$descriptor->properties[$modelProperty->name] = $modelProperty;
		}
		return $descriptor;
	}
	
	protected static function finalClassDescriptor($class, $descriptor) {
		$modelSource = Databases::getSource($descriptor->getSourceName());
		$modelSource->cascadeTableDescriptor($descriptor->getTable(), $modelSource->modelToTableDescriptor($descriptor));	
		return $descriptor;
	}
	
	/**
	 * Attempt to generate a table from this model's descriptor.
	 *
	 * @param mixed $class
	 */
	static function createTableFor($class) {
		$descriptor = self::getClassDescriptor($class);
		$modelSource = Databases::getSource($descriptor->getSourceName());
		$modelSource->exec($modelSource->createTableSql($descriptor));
	}

	/**
	 * Build a ModelSet from this instance by assigning this Model instance's
	 * properties and values.
	 *
	 * @return ModelSet
	 */
	protected function getModelSet() {
		$thisClassDescriptor = self::getClassDescriptor($this);
		$result = $thisClassDescriptor->getSource()->selectModelSet($thisClassDescriptor->getTable());
		$pkName = self::primaryKeyName($this);
		
		if(isset($this->$pkName)) {
			$result = $result->equal($pkName,$this->$pkName);
		} else {
			foreach($this as $column => $value) {
				if(isset($this->$column) && in_array($column,$thisClassDescriptor->columns)) {
					$result = $result->assign($column, $value);
				}
			}
		}
		
		$result->rowClass = get_class($this);
		return $result;
	}
	
	/**
	 * Return a results ModelSet based on the values of this instance's properties.
	 *
	 * @return ModelSet
	 */
	function select() { 
		return $this->getModelSet()->useAssignmentsAsConditions(true);
	}

	/**
	 * Alias for select.
	 *
	 * @return ModelSet
	 */
	function find() { return $this->select(); }
	
	/**
	 * Select all. This is different from find() in that find will use
	 * assigned values to the model as equality statements.
	 *
	 * @return ModelSet
	 */
	function all() { 
		return $this->getModelSet();
	}
	
	
	/**
	 * Return a SqlBuilder object which has set the table and optionally
	 * assigned values to columns based on this instances' properties. This is used in
	 * insert(), update(), and delete()
	 *
	 * @param ModelDescriptor $descriptor
	 * @param boolean $useAssignment
	 * @param boolean $excludePrimaryKey
	 * @return SqlBuilder
	 */
	protected function assignmentSqlForThisObject(ModelDescriptor $descriptor, $useAssignment = true, $excludePrimaryKey = false) {
		$sqlBuilder = new SqlBuilder();
		$sqlBuilder->from($descriptor->getTable());
		
		if(empty($descriptor->columns)) {
			throw new RecessException('The "' . $descriptor->getTable() . '" table does not appear to exist in your database.', get_defined_vars());
		}
		
		foreach($this as $column => $value) {
			if($excludePrimaryKey && $descriptor->primaryKey == $column) continue;
			if(in_array($column, $descriptor->columns) && isset($value)) {
				if($useAssignment) {
					$sqlBuilder->assign($column,$value);
				} else {
					$sqlBuilder->equal($column,$value);
				}
			}
		}
		return $sqlBuilder;
	}
	
	/**
	 * Delete row(s) from the data source which match this instance.
	 *
	 * @param boolean $cascade - Also delete models related to this model?
	 * @return boolean
	 * 
	 * !Wrappable delete
	 */
	function wrappedDelete($cascade = true) {
		$thisClassDescriptor = self::getClassDescriptor($this);
		
		if($cascade) {
			foreach($thisClassDescriptor->relationships as $relationship) {
				$relationship->delete($this);
			}
		}
			
		$sqlBuilder = $this->assignmentSqlForThisObject($thisClassDescriptor, false);
		
		return $thisClassDescriptor->getSource()->executeSqlBuilder($sqlBuilder, 'delete');	
	}

	/**
	 * Insert row into the data source based on the values of this instance.
	 * @return boolean
	 * 
	 * !Wrappable insert
	 */
	function wrappedInsert() {
		$thisClassDescriptor = self::getClassDescriptor($this);
		
		$sqlBuilder = $this->assignmentSqlForThisObject($thisClassDescriptor);
		
		$result = $thisClassDescriptor->getSource()->executeSqlBuilder($sqlBuilder, 'insert');
		
	 	$primaryKey = $thisClassDescriptor->primaryKey;
	 	
	 	$this->$primaryKey = $thisClassDescriptor->getSource()->lastInsertId();
	 	
	 	return $result;
	}

	/**
	 * Update a row in the data source based on the values of this instance.
	 * @return boolean
	 * 
	 * !Wrappable update
	 */
	function wrappedUpdate() {
		$thisClassDescriptor = self::getClassDescriptor($this);
		
		$sqlBuilder = $this->assignmentSqlForThisObject($thisClassDescriptor, true, true);
		$primaryKey = $thisClassDescriptor->primaryKey;
		$sqlBuilder->equal($thisClassDescriptor->primaryKey, $this->$primaryKey);
		
		return $thisClassDescriptor->getSource()->executeSqlBuilder($sqlBuilder, 'update');
	}
	
	/**
	 * Insert or update depending on whether or not this instance's primary key is set.
	 *
	 * @return boolean
	 * 
	 * !Wrappable save
	 */
	function wrappedSave()   {
		if($this->primaryKeyIsSet()) {
			return $this->update();
		} else {
			return $this->insert();
		}
	}
	
	/**
	 * @return boolean
	 */
	function primaryKeyIsSet() {
		$thisClassDescriptor = self::getClassDescriptor($this);
		
		$primaryKey = $thisClassDescriptor->primaryKey;
				
		if(isset($this->$primaryKey)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Shortcut method which will determine whether a row
	 * with the current instances properties exists. If so, it will
	 * preload those values (side effects).
	 * 
	 * Usage:
	 * $model->id = 1;
	 * if($model->exists()) {
	 *  die('a lonesome death');
	 * }
	 *
	 * @return boolean
	 */
	function exists() {
		$result = $this->select()->first();
		if($result !== false) {
			$this->copy($result, false);
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Copy values from a key/value array or another model/object
	 * to this instance.
	 *
	 * @param iterable $keyValuePair
	 * @return Model
	 */
	function copy($keyValuePair, $excludePrimaryKey = true) {
		if($excludePrimaryKey) {
			$pk = Model::primaryKeyName($this);
		}
		foreach($keyValuePair as $key => $value) {
			if($excludePrimaryKey && $key == $pk) {
				continue;
			}
			$this->$key = $value;
		}
		return $this;
	}
	
	/**
	 * Add equality criteria between a column and value
	 *
	 * @param string $lhs Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function equal($column, $rhs){ return $this->select()->equal($column, $rhs); }
	
	/**
	 * Add inequality criteria between a column and value
	 *
	 * @param string $lhs Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function notEqual($column, $rhs) { return $this->select()->notEqual($column,$rhs); }
	
	/**
	 * Add criteria to state a column's value falls between $small and $big
	 *
	 * @param string $column Column
	 * @param mixed $small Floor Value
	 * @param mixed $big Ceiling Value
	 * @return PdoDataSet
	 */
	function between ($column, $small, $big) { return $this->select()->between($column, $small, $big); }
	
	/**
	 * SQL criteria specifying a column's value is greater than $rhs
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function greaterThan($column, $rhs) { return $this->select()->greaterThan($column,$rhs); }
	
	/**
	 * SQL criteria specifying a column's value is no less than $rhs
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function greaterThanOrEqualTo($column, $rhs) { return $this->select()->greaterThanOrEqualTo($column,$rhs); }
	
	/**
	 * SQL criteria specifying a column's value is less than $rhs
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function lessThan($column, $rhs) { return $this->select()->lessThan($column,$rhs); }
	
	/**
	 * SQL criteria specifying a column's value is no greater than $rhs
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function lessThanOrEqualTo($column, $rhs) { return $this->select()->lessThanOrEqualTo($column,$rhs); }
	
	/**
	 * SQL LIKE criteria, note this does not automatically include wildcards
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function like($column, $rhs) { return $this->select()->like($column,$rhs); }
	
	/**
	 * SQL NOT LIKE criteria, note this does not automatically include wildcards
	 *
	 * @param string $column Column
	 * @param mixed $rhs Value
	 * @return PdoDataSet
	 */
	function notLike($column, $rhs) { return $this->select()->notLike($column,$rhs); }
	
	/**
	 * SQL IS NULL criteria
	 *
	 * @param string $column Column
	 * @return PdoDataSet
	 */
	function isNull($column) { return $this->select()->isNull($column); }
	
	/**
	 * SQL IS NOT NULL criteria
	 *
	 * @param string $column Column
	 * @return PdoDataSet
	 */
	function isNotNull($column) { return $this->select()->isNotNull($column); }
	
	/**
	 * SQL IN criteria
	 * @param string $column Column name
	 * @param array $values An array of values to test
	 * @return PdoDataSet
	 */
	function in($column, $values) { return $this->select()->in($column,$values); }
}

/**
 * Class descriptor + metadata for a model.
 */
class ModelDescriptor extends ClassDescriptor {
	
	public $primaryKey = 'id';
	private $table;
	
	public $plural;
	public $modelClass;
	public $relationships;
	
	public $columns;
	public $properties;
	
	public $source;
	
	function __construct($class, $loadColumns = true) {
		$this->table = strtolower($class);
		$this->relationships = array();
		$this->properties = array();
		$this->source = false;
		if($loadColumns) {
			$this->columns = $this->getSource()->getColumns($this->table);
		} else {
			$this->columns = array();
		}
		$this->primaryKeyColumn = 'id';
		$this->modelClass = $class;
	}
	
	function __set_state($array) {
		$descriptor = new ModelDescriptor($array['modelClass']);
		$descriptor->primaryKey = $array['primaryKey'];
		$descriptor->table = $array['table'];
		$descriptor->relationships = $array['relationships'];
		$descriptor->columns = $array['columns'];
		$descriptor->properties = $array['properties'];
		$descriptor->source = $array['source'];
		$descriptor->attachedMethods = $array['attachedMethods'];
		return $descriptor;
	}
	
	function setTable($table, $loadColumns = true) {
		$this->table = $table;
		if($loadColumns) {
			$source = $this->getSource();
			if(isset($source)) {
				$this->columns = $this->getSource()->getColumns($this->table);
			} else {
				throw new RecessException('Data Source "' . $this->getSourceName() . '" is not set.', array());
			}
		} else {
			$this->columns = array();
		}
	}
	
	function getTable() {
		return $this->table;
	}
	
	function setSource($source) {
		$this->source = $source;		
	}
	
	function getSource() {
		if(!$this->source) {
			return Databases::getDefaultSource();
		} else {
			return Databases::getSource($this->source);
		}
	}
	
	function getSourceName() {
		if(!$this->source) {
			return 'Default';
		} else {
			return $this->source;
		}
	}
}

/**
 * The data structure for a propery on a model
 */
class ModelProperty {
	public $name;
	public $type;
	public $pkCallback;
	public $isAutoIncrement = false;
	public $isPrimaryKey = false;
	public $isForeignKey = false;
	public $required = false;
	
	function __set_state($array) {
		$prop = new ModelProperty();
		$prop->name = $array['name'];
		$prop->type = $array['type'];
		$prop->pkCallback = $array['pkCallback'];
		$prop->isAutoIncrement = $array['autoincrement'];
		$prop->isPrimaryKey = $array['isPrimaryKey'];
		$prop->isForeignKey = $array['isForeignKey'];
		return $prop;
	}
}
?><?php
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
?><?php
Library::import('recess.framework.forms.FormInput');
Library::import('recess.framework.forms.TextAreaInput');
Library::import('recess.framework.forms.DateTimeInput');
Library::import('recess.framework.forms.TextInput');
Library::import('recess.framework.forms.LabelInput');
Library::import('recess.framework.forms.DateLabelInput');
Library::import('recess.framework.forms.BooleanInput');
Library::import('recess.framework.forms.HiddenInput');

class Form {
	protected $name;
	
	public $method;
	public $action;
	public $flash;
	
	function __construct($name) {
		$this->name = $name;
	}
	
	public $hasErrors = false;
	public $inputs = array();
	
	function __get($name) {
		if(isset($this->inputs[$name])) {
			return $this->inputs[$name];
		} else {
			return '';
		}
	}
	
//	function __set($name, $value) {
//		if(isset($this->inputs[$name])) {
//			$this->inputs[$name]->value = $value;
//		}
//	}
	
	function to($method, $action) {
		$this->method = $method;
		$this->action = $action;
	}
	
	function begin() {
		if($this->method == Methods::DELETE || $this->method == Methods::PUT) {
			echo '<form method="POST" action="' . $this->action . '">';
			echo '<input type="hidden" name="_METHOD" value="' . $this->method . '" />';
		} else {
			echo '<form method="' . $this->method . '" action="' . $this->action . '">';
		}
	}
	
	function input($name, $class = '') {
		if($class != '') {
			$this->inputs[$name]->class = $class;
		}
		$this->inputs[$name]->render();
	}
	
	function changeInput($name, $newInput) {
		$current = $this->inputs[$name];
		$newInput .= 'Input';
		$this->inputs[$name] = new $newInput($name);
		$this->inputs[$name]->setValue($current->getValue());
	}
	
	function fill(array $keyValues) {
		foreach($this->inputs as $key => $value) {
			if(isset($keyValues[$key])) {
				$this->inputs[$key]->setValue($keyValues[$key]);
			}
		}
	}
	
	function assertNotEmpty($inputName) {
		if(isset($this->inputs[$inputName]) && $this->inputs[$inputName]->getValue() != '') {
			return true;
		} else {
			$this->inputs[$inputName]->class = 'highlight';
			$this->inputs[$inputName]->flash = 'Required.';
			$this->hasErrors = true;
			return false;
		}
	}
	
	function hasErrors() {
		return $this->hasErrors;
	}
	
	function end() {
		echo '</form>';
	}
}
?><?php
Library::import('recess.framework.forms.Form');

class ModelForm extends Form {
	protected $model = null;
	
	function input($name, $class = '') {
		$this->inputs[$name]->setValue($this->model->$name);
		parent::input($name, $class);
	}
	
	function changeInput($name, $newInput) {
		$current = $this->inputs[$name];
		$newInput .= 'Input';
		$this->inputs[$name] = new $newInput($this->name . '[' . $name . ']');
		$this->inputs[$name]->setValue($current->getValue());
	}
	
	function __construct($name, $values, Model $model = null) {		
		$this->name = $name;
		$this->model = $model;
		
		if($model != null) {			
			$properties = Model::getProperties($model);
			$this->inputs = array();
									
			foreach($properties as $property) {
				$propertyName = $property->name;
				
				$inputName = $this->name . '[' . $propertyName . ']';
				$inputValue = isset($values[$propertyName]) ? $values[$propertyName] : '';

				switch($property->type) {
					case RecessType::STRING: 
					case RecessType::FLOAT:
					case RecessType::INTEGER:
						$this->inputs[$propertyName] = new TextInput($inputName);
						break;
					case RecessType::BOOLEAN:
						$this->inputs[$propertyName] = new BooleanInput($inputName);
						break;
					case RecessType::TEXT:
						$this->inputs[$propertyName] = new TextAreaInput($inputName);
						break;
					case RecessType::BLOB:
						$this->inputs[$propertyName] = new LabelInput($inputName);
						break;
					case RecessType::DATE:
						$this->inputs[$propertyName] = new DateTimeInput($inputName);
						$this->inputs[$propertyName]->showTime = false;
						break;
					case RecessType::DATETIME:
						$this->inputs[$propertyName] = new DateTimeInput($inputName);
						$this->inputs[$propertyName]->showTime = false;
						break;
					case RecessType::TIME:
						$this->inputs[$propertyName] = new DateTimeInput($inputName);
						$this->inputs[$propertyName]->showDate = false;
						break;
					case RecessType::TIMESTAMP:
						$this->inputs[$propertyName] = new DateLabelInput($inputName);
						break;
					default:
						echo $property->type;
				}
				
				if($property->isPrimaryKey) {
					$this->inputs[$propertyName] = new HiddenInput($propertyName);
				}
				
				if(isset($this->inputs[$propertyName]) && isset($values[$propertyName])) {
					$this->inputs[$propertyName]->setValue($values[$propertyName]);
					$model->$propertyName = $this->inputs[$propertyName]->getValue();
				}
			}
		}
	}
}

?><?php
/**
 * A Recess Relationship is an abstraction of a foreign key relationship on the RDBMS.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class Relationship {
	const FOREIGN_KEY = 'key';
	const FOREIGN_CLASS = 'class';
	const THROUGH = 'through';
	const ON_DELETE = 'ondelete';
	
	const UNSPECIFIED = 'unspecified';
	const CASCADE = 'cascade';
	const DELETE = 'delete';
	const NULLIFY = 'nullify';
	
	public $name;
	public $localClass;
	public $foreignClass;
	public $foreignKey;
	public $onDelete;
	public $through;
	
	abstract function getType();
	
	abstract function init($modelClassName, $relationshipName);
	
	function getDefaultOnDeleteMode() { return Relationship::NULLIFY; }
	
	function delete(Model $model) {
		if($this->onDelete == Relationship::UNSPECIFIED) {
			$this->onDelete = $this->getDefaultOnDeleteMode();
		}
		
		switch($this->onDelete) {
			case Relationship::CASCADE:
				$this->onDeleteCascade($model);
				break;
			case Relationship::DELETE:
				$this->onDeleteDelete($model);
				break;
			case Relationship::NULLIFY:
				$this->onDeleteNullify($model);
				break;	
		}
	}
	
	abstract function onDeleteCascade(Model $model);
	abstract function onDeleteDelete(Model $model);
	abstract function onDeleteNullify(Model $model);
}

?><?php
/**
 * A BelongsTo Recess Relationship is an abstraction of for the Many side of a 
 * foreign key relationship on the RDBMS.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class BelongsToRelationship extends Relationship {
	
	function getType() {
		return 'BelongsTo';
	}
	
	function init($modelClassName, $relationshipName) {
		$this->localClass = $modelClassName;
		$this->name = $relationshipName;
		$this->onDelete = Relationship::NULLIFY;
		$this->foreignKey = Inflector::toCamelCaps($relationshipName) . 'Id';
		$this->foreignClass = Inflector::toProperCaps($relationshipName);
	}
	
	function attachMethodsToModelDescriptor(ModelDescriptor $descriptor) {
		$alias = $this->name;
		$attachedMethod = new AttachedMethod($this, 'selectModel', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
		
		$alias = 'set' . ucfirst($this->name);
		$attachedMethod = new AttachedMethod($this,'set', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
		
		$alias = 'unset' . ucfirst($this->name);
		$attachedMethod = new AttachedMethod($this,'remove', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
	}
	
	function set(Model $model, Model $relatedModel) {
		if(!$relatedModel->primaryKeyIsSet()) {
			$relatedModel->insert();
		}
		
		$foreignKey = $this->foreignKey;
		$relatedPrimaryKey = Model::primaryKeyName($relatedModel);
		$model->$foreignKey = $relatedModel->$relatedPrimaryKey;
		$model->save();
		
		return $model;
	}
	
	function remove(Model $model) {		
		$foreignKey = $this->foreignKey;
		$model->$foreignKey = '';
		$model->save();
		
		return $model;
	}
	
	protected function augmentSelect(PdoDataSet $select) {
		$select = $select	
					->from(Model::tableFor($this->foreignClass))
					->innerJoin(Model::tableFor($this->localClass), 
								Model::primaryKeyFor($this->foreignClass), 
								Model::tableFor($this->localClass) . '.' . $this->foreignKey);
						
		$select->rowClass = $this->foreignClass;
		return $select;
	}
	
	function selectModel(Model $model) {
		$foreignKey = $this->foreignKey;
		
		if(isset($model->$foreignKey)) {
			$select = $this->augmentSelect($model->all());
			$select = $select->equal(Model::tableFor($this->localClass) . '.' . $this->foreignKey, $model->$foreignKey);
		} else {
			$select = $this->augmentSelect($model->select());
		}
		
		if(isset($select[0])) {
			return $select[0];
		} else {
			return null;
		}
	}
	
	function selectModelSet(ModelSet $modelSet) {
		return $this->augmentSelect($modelSet);
	}
	
	function onDeleteCascade(Model $model) {
		$this->selectModel($model)->delete();
	}
	
	function onDeleteDelete(Model $model) {
		$relatedModel = $this->selectModel($model);
		if($relatedModel != null) {
			$relatedModel->delete(false);		
		}
	}
	
	function onDeleteNullify(Model $model) {
		// no-op
	}
	
	function __set_state($array) {
		$relationship = new BelongsToRelationship();
		$relationship->name = $array['name'];
		$relationship->localClass = $array['localClass'];
		$relationship->foreignClass = $array['foreignClass'];
		$relationship->onDelete = $array['onDelete'];
		$relationship->through = $array['through'];
		return $relationship;
	}
}
?><?php
/**
 * Recess has a fixed set of native 'recess' types that are mapped to vendor specific
 * column types by individual DataSourceProviders.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
abstract class RecessType {
	const STRING = 'String';
	const TEXT = 'Text';
	const INTEGER = 'Integer';
	const BOOLEAN = 'Boolean';
	const FLOAT = 'Float';
	const TIME = 'Time';
	const TIMESTAMP = 'Timestamp';
	const DATE = 'Date';
	const DATETIME = 'DateTime';
	const BLOB = 'Blob';
	
	private static $all;
	
	static function all() {
		if(!isset(self::$all)) {
			self::$all = array(
							self::STRING, 
							self::TEXT, 
							self::INTEGER, 
							self::BOOLEAN, 
							self::FLOAT, 
							self::TIME, 
							self::TIMESTAMP, 
							self::DATETIME,
							self::DATE,
							self::BLOB);
		}
		return self::$all;
	}
}
?><?php
Library::import('recess.database.pdo.RecessColumnDescriptor');

/**
 * RecessTableDescriptor represents a basic abstraction of an RDBMS table.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class RecessTableDescriptor {
	
	public $name;
	
	public $tableExists = false;
	
	protected $columns = array();
	
	function addColumn($name, $type, $nullable = true, $isPrimaryKey = false, $defaultValue = '', $options = array()) {
		$this->columns[$name] = new RecessColumnDescriptor($name, $type, $nullable, $isPrimaryKey, $defaultValue, $options);
	}
	
	function getColumns() {
		return $this->columns;
	}
	
}
?><?php
/**
 * RecessTable represents a basic abstraction of an RDBMS column.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class RecessColumnDescriptor {
	
	public $name;
	
	public $type;
	
	public $isPrimaryKey = false;
	
	public $nullable = true;
	
	public $defaultValue = '';
	
	public $options = array();
	
	function __construct($name, $type, $nullable = true, $isPrimaryKey = false, $defaultValue = '', $options = array()) {
		$this->name = $name;
		$this->type = $type;
		$this->isPrimaryKey = $isPrimaryKey;
		$this->nullable = $nullable;
		$this->defaultValue = $defaultValue;
		$this->options = $options;
	}
	
}
?><?php
abstract class FormInput {
	protected $name;
	public $class;
	public $value;
	
	function __construct($name) {
		$this->name = $name;
	}
	
	function getValue() {
		return $this->value;		
	}
	
	function setValue($value) {
		$this->value = $value;
	}
	
	function getName() {
		return $this->name;
	}
	
	abstract function render();
}
?><?php
Library::import('recess.framework.forms.FormInput');
class TextInput extends FormInput {
	function render() {
		echo '<input type="text" name="', $this->name, '"', ' id="' . $this->name . '"';
		if($this->class != '') {
			echo ' class="', $this->class, '"';
		}
		
		if($this->value != '') {
			echo ' value="', $this->value, '"';
		}
		echo ' />';
	}
}
?><?php
Library::import('recess.framework.forms.FormInput');
class HiddenInput extends FormInput {	
	function render() {
		echo '<input type="hidden" name="', $this->name, '"';
		if($this->value != '') {
			echo ' value="', $this->value, '"';
		}
		echo ' />';
	}
}
?><?php
/**
 * Interface used which maps to SELECT SQL statements
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
interface ISqlSelectOptions {

	function limit($size);
	function offset($offset);
	function range($start, $finish);
	function orderBy($clause);
	function leftOuterJoin($table, $tablePrimaryKey, $fromTableForeignKey);
	function innerJoin($table, $tablePrimaryKey, $fromTableForeignKey);
	function distinct();
		
}
?><?php
Library::import('recess.database.sql.SqlBuilder');
Library::import('recess.database.sql.ISqlSelectOptions');
Library::import('recess.database.sql.ISqlConditions');

/**
 * PdoDataSet is used as a proxy to query results that is realized once the results are
 * iterated over or accessed using array notation. Queries can thus be built incrementally
 * and an SQL request will only be issued once needed.
 *  
 * Example usage:
 * 
 * $results = new PdoDataSet(Databases::getDefault());
 * $results->from('tableName')->equal('someColumn', 'Hi')->limit(10)->offset(50);
 * foreach($results as $result) { // This is when the query is run!
 * 		print_r($result);
 * }
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class PdoDataSet implements Iterator, Countable, ArrayAccess, ISqlSelectOptions, ISqlConditions {
	
	/**
	 * The SqlBuilder instance we use to build up the query string.
	 *
	 * @var SqlBuilder
	 */
	protected $sqlBuilder;
	
	/**
	 * Whether this instance has fetched results or not.
	 *
	 * @var boolean
	 */
	protected $hasResults = false;
	
	/**
	 * Array of results that is filled once a query is realized.
	 *
	 * @var array of type $this->rowClass
	 */
	protected $results = array();
	
	/**
	 * The PdoDataSource which this PdoDataSet is extracted from.
	 *
	 * @var PdoDataSource
	 */
	protected $source;
	
	/**
	 * The Class which PDO will fetch rows into.
	 *
	 * @var string Classname
	 */
	public $rowClass = 'stdClass';
	
	/**
	 * Index counter for our location in the result set.
	 *
	 * @var integer
	 */
	protected $index = 0;
	
	/**
	 * @param PdoDataSource $source
	 */
	public function __construct(PdoDataSource $source) {
		$this->sqlBuilder = new SqlBuilder();
		$this->source = $source;
	}
	
	public function __clone() {
		$this->sqlBuilder = clone $this->sqlBuilder;
		$this->hasResults = false;
		$this->results = array();
		$this->index = 0;
	}
	
	protected function reset() {
		$this->hasResults = false;
		$this->index = 0;
	}
	
	/**
	 * Once results are needed this method executes the accumulated query
	 * on the data source.
	 */
	protected function realize() {  
		if(!$this->hasResults) {
			unset($this->results);
			$this->results = $this->source->queryForClass($this->sqlBuilder, $this->rowClass);
			$this->hasResults = true;
		}
	}
	
	/**
	 * Return the SQL representation of this PdoDataSet
	 *
	 * @return string
	 */
	public function toSql() {
		return $this->sqlBuilder->select();
	}
	
	/**
	 * Return the results as an array.
	 *
	 * @return array of type $this->rowClass
	 */
	public function toArray() {
		$this->realize();
		return $this->results;
	}
	
	public function count() {
		return iterator_count($this); 
	}
	
	public function exists() {
		return (bool)iterator_count($this);
	}
	
	/*
	 * The following methods are in accordance with the Iterator interface
	 */
	public function rewind() {
		if(!$this->hasResults) {$this->realize();}
		$this->index = 0;
	}
	
	public function current() {
		if(!$this->hasResults) {$this->realize();}
		return $this->results[$this->index];
	}

	public function key() {
		if(!$this->hasResults) {$this->realize();}
		return $this->index;
	}
	
	public function next() { 
		if(!$this->hasResults) {$this->realize();}
		$this->index++;
	} 
	
	public function valid() {
		if(!$this->hasResults) {$this->realize();}
		return isset($this->results[$this->index]);
	}
	
	/*
	 * The following methods are in accordance with the ArrayAccess interface
	 */
	function offsetExists($index) {
		if(!$this->hasResults) {$this->realize();}
		return isset($this->results[$index]);
	}

	function offsetGet($index) {
		if(!$this->hasResults) {$this->realize();}
		if(isset($this->results[$index])) {
			return $this->results[$index];
		} else {
			throw new OutOfBoundsException();
		}
	}

	function offsetSet($index, $value) {
		if(!$this->hasResults) {$this->realize();}
		$this->results[$index] = $value;
	}

	function offsetUnset($index) {
		if(!$this->hasResults) {$this->realize();}
		if(isset($this->results[$index])) {
			unset($this->results[$index]);
		}
	}
	
	function isEmpty() {
		return !(isset($this[0]) && $this[0] != null);
		// return !isset($this[0]);
	}
	
	/**
	 * Return the first item in the PdoDataSet or Null if none exist
	 *
	 * @return object or false
	 */
	function first() {
		if(!$this->hasResults) {
			$results = $this->range(0,1);
			if(!$results->isEmpty()) {
				return $results[0];
			}
		} else {
			if(!$this->isEmpty()) {
				return $this[0];
			}
		}
		
		return false;
	}
	
	/**
	 * @see SqlBuilder::assign
	 * @return PdoDataSet
	 */
	function assign($column, $value) { $copy = clone $this; $copy->sqlBuilder->assign($column, $value); return $copy; }
	
	/**
	 * @see SqlBuilder::useAssignmentsAsConditions
	 * @return PdoDataSet
	 */
	function useAssignmentsAsConditions($bool) { $copy = clone $this; $copy->sqlBuilder->useAssignmentsAsConditions($bool); return $copy; }
	
	/**
	 * @see SqlBuilder::from
	 * @return PdoDataSet
	 */
	function from($table) { $copy = clone $this; $copy->sqlBuilder->from($table); return $copy; }
	
	/**
	 * @see SqlBuilder::leftOuterJoin
	 * @return PdoDataSet
	 */
	function leftOuterJoin($table, $tablePrimaryKey, $fromTableForeignKey) { $copy = clone $this; $copy->sqlBuilder->leftOuterJoin($table, $tablePrimaryKey, $fromTableForeignKey); return $copy; }
	
	/**
	 * @see SqlBuilder::innerJoin
	 * @return PdoDataSet
	 */
	function innerJoin($table, $tablePrimaryKey, $fromTableForeignKey) { $copy = clone $this; $copy->sqlBuilder->innerJoin($table, $tablePrimaryKey, $fromTableForeignKey); return $copy; }
	
	/**
	 * @see SqlBuilder::selectAs
	 * @return PdoDataSet
	 */	
	function selectAs($select, $as) { $copy = clone $this; $copy->sqlBuilder->selectAs($select, $as); return $copy; }

	/**
	 * @see SqlBuilder::distinct
	 * @return PdoDataSet
	 */	
	function distinct() { $copy = clone $this; $copy->sqlBuilder->distinct(); return $copy; }

	/**
	 * @see SqlBuilder::equal
	 * @return PdoDataSet
	 */
	function equal($lhs, $rhs){ $copy = clone $this; $copy->sqlBuilder->equal($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::notEqual
	 * @return PdoDataSet
	 */
	function notEqual($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->notEqual($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::between
	 * @return PdoDataSet
	 */	
	function between ($column, $lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->between($column, $lhs, $rhs); return $copy; }

	/**
	 * @see SqlBuilder::greaterThan
	 * @return PdoDataSet
	 */	
	function greaterThan($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->greaterThan($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::greaterThanOrEqualTo
	 * @return PdoDataSet
	 */	
	function greaterThanOrEqualTo($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->greaterThanOrEqualTo($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::lessThan
	 * @return PdoDataSet
	 */	
	function lessThan($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->lessThan($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::lessThanOrEqualTo
	 * @return PdoDataSet
	 */	
	function lessThanOrEqualTo($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->lessThanOrEqualTo($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::like
	 * @return PdoDataSet
	 */	
	function like($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->like($lhs,$rhs); return $copy; }

	/**
	 * @see SqlBuilder::like
	 * @return PdoDataSet
	 */
	function notLike($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->notLike($lhs,$rhs); return $copy; }
	
	/**
	 * @see SqlBuilder::isNull
	 * @return PdoDataSet
	 */	
	function isNull($lhs) { $copy = clone $this; $copy->sqlBuilder->isNull($lhs); return $copy; }

	/**
	 * @see SqlBuilder::like
	 * @return PdoDataSet
	 */
	function isNotNull($lhs) { $copy = clone $this; $copy->sqlBuilder->isNotNull($lhs); return $copy; }
	
	/**
	 * @see SqlBuilder::where
	 * @return PdoDataSet
	 */	
	function where($lhs, $rhs, $operator) { $copy = clone $this; $copy->sqlBuilder->where($lhs,$rhs,$operator); return $copy; }

	/**
	 * @see SqlBuilder::limit
	 * @return PdoDataSet
	 */	
	function limit($size) { $copy = clone $this; $copy->sqlBuilder->limit($size); return $copy; }

	/**
	 * @see SqlBuilder::offset
	 * @return PdoDataSet
	 */	
	function offset($offset) { $copy = clone $this; $copy->sqlBuilder->offset($offset); return $copy; }

	/**
	 * @see SqlBuilder::range
	 * @return PdoDataSet
	 */	
	function range($start, $finish) { $copy = clone $this; $copy->sqlBuilder->range($start,$finish); return $copy; }

	/**
	 * @see SqlBuilder::orderBy
	 * @return PdoDataSet
	 */	
	function orderBy($clause) { $copy = clone $this; $copy->sqlBuilder->orderBy($clause); return $copy; }

	/**
	 * @see SqlBuilder::groupBy
	 * @return PdoDataSet
	 */	
	function groupBy($clause) { $copy = clone $this; $copy->sqlBuilder->groupBy($clause); return $copy; }
	
	/**
	 * @see SqlBuilder::in
	 * @return PdoDataSet
	 */		
	function in($lhs, $rhs) { $copy = clone $this; $copy->sqlBuilder->in($lhs,$rhs); return $copy; }
}
?><?php

Library::import('recess.database.pdo.PdoDataSet');

class ModelSet extends PdoDataSet {
	
	function __call($name, $arguments) {
		$relationship = Model::getRelationship($this->rowClass, $name);
		if($relationship === false && Inflector::isPlural($name)) {
			$name = Inflector::toSingular($name);
			$relationship = Model::getRelationship($this->rowClass, $name);
			if(!$relationship instanceof BelongsToRelationship) {
				$relationship = false;
			}
		}
		
		if($relationship !== false) {
			return $relationship->selectModelSet($this);
		} else {
			throw new RecessException('Relationship "' . $name . '" does not exist.', get_defined_vars());
		}
	}
	
	function update() {
		return $this->source->executeStatement($this->sqlBuilder->useAssignmentsAsConditions(false)->update(), $this->sqlBuilder->getPdoArguments());
	}
	
	function delete($cascade = true) {
		foreach($this as $model) {
			$model->delete($cascade);
		}
	}
}

?><?php
Library::import('recess.database.sql.ISqlConditions');
Library::import('recess.database.sql.ISqlSelectOptions');

/**
 * SqlBuilder is used to incrementally compose named-parameter PDO Sql strings 
 * using a simple, chainable method call API. This is a naive wrapper that does
 * not gaurantee valid SQL output (i.e. column names using reserved SQL words).
 * 
 * 4 classes of SQL strings can be built: INSERT, UPDATE, DELETE, SELECT.
 * This class is intentionally arranged from the low complexity requirements
 * of INSERT to the more complex SELECT.
 * 
 * INSERT:        table, column/value assignments
 * UPDATE/DELETE: where conditions
 * SELECT:        order, joins, offset, limit, distinct
 * 
 * Example usage: 
 * 
 * $sqlBuilder->into('table_name')->assign('column', 'value')->insert() .. 
 * 		returns "INSERT INTO table_name (column) VALUES (:column)"
 * $sqlBuilder->getPdoArguments() returns array( ':column' => 'value' )
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @contributor Luiz Alberto Zaiats 
 * 
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class SqlBuilder implements ISqlConditions, ISqlSelectOptions {
		
	/* INSERT */
	protected $table;
	protected $assignments = array();
	
	/**
	 * Build an INSERT SQL string from SqlBuilder's state.
	 * 
	 * @return string INSERT string.
	 */
	public function insert() {
		$this->insertSanityCheck();

		$sql = 'INSERT INTO ' . self::escapeWithTicks($this->table);
		
		$columns = '';
		$values = '';
		$first = true;
		$table_prefix = $this->tableAsPrefix() . '.';
		foreach($this->assignments as $assignment) {
			if($first) { $first = false; }
			else { $columns .= ', '; $values .= ', '; }
			$columns .= self::escapeWithTicks(str_replace($table_prefix, '', $assignment->column));
			$values .= $assignment->getQueryParameter();
		}
		$columns = ' (' . $columns . ')';
		$values = '(' . $values . ')';
		
		$sql .= $columns . ' VALUES ' . $values;
		
		return $sql;
	}
	
	/**
	 * Safety check used with insert to ensure only a table and assignments were applied.
	 */
	protected function insertSanityCheck() {
		if(	!empty($this->conditions) )
			throw new RecessException('Insert does not use conditionals.', get_defined_vars());
		if(	!empty($this->joins) )
			throw new RecessException('Insert does not use joins.', get_defined_vars());
		if(	!empty($this->orderBy) ) 
			throw new RecessException('Insert does not use order by.', get_defined_vars());
		if(	!empty($this->groupBy) ) 
			throw new RecessException('Insert does not use group by.', get_defined_vars());
		if(	isset($this->limit) )
			throw new RecessException('Insert does not use limit.', get_defined_vars());
		if(	isset($this->offset) )
			throw new RecessException('Insert does not use offset.', get_defined_vars());
		if(	isset($this->distinct) )
			throw new RecessException('Insert does not use distinct.', get_defined_vars());
	}
	
	/**
	 * Set the table of focus on a sql statement.
	 *
	 * @param string $table
	 * @return SqlBuilder 
	 */
	public function table($table) { $this->table = $table; return $this; }
	
	/**
	 * Alias for table (insert into)
	 *
	 * @param string $table
	 * @return SqlBuilder
	 */
	public function into($table) { return $this->table($table); }

	/**
	 * Assign a value to a column. Used with inserts and updates.
	 *
	 * @param string $column
	 * @param mixed $value
	 * @return SqlBuilder
	 */
	public function assign($column, $value) { 
		if(strpos($column, '.') === false) {
			if(isset($this->table)) {
				$this->assignments[] = new Criterion($this->tableAsPrefix() . '.' . $column, $value, Criterion::ASSIGNMENT); 
			} else {
				throw new RecessException('Cannot assign without specifying table.', get_defined_vars());
			}
		} else {
			$this->assignments[] = new Criterion($column, $value, Criterion::ASSIGNMENT); 
		}
		return $this;
	}
	
	/* UPDATE & DELETE */
	protected $conditions = array();
	protected $conditionsUsed = array();
	protected $useAssignmentsAsConditions = false;
	
	/**
	 * Build a DELETE SQL string from SqlBuilder's state.
	 *
	 * @return string DELETE string
	 */
	public function delete() {
		$this->deleteSanityCheck();
		return 'DELETE FROM ' . self::escapeWithTicks($this->table) . $this->whereHelper();
	}
	
	/**
	 * Safety check used with delete.
	 */
	protected function deleteSanityCheck() {
		if(	!empty($this->joins) )
			throw new RecessException('Delete does not use joins.', get_defined_vars());
		if(	!empty($this->orderBy) ) 
			throw new RecessException('Delete does not use order by.', get_defined_vars());
		if(	!empty($this->groupBy) ) 
			throw new RecessException('Delete does not use group by.', get_defined_vars());
		if(	isset($this->limit) )
			throw new RecessException('Delete does not use limit.', get_defined_vars());
		if(	isset($this->offset) )
			throw new RecessException('Delete does not use offset.', get_defined_vars());
		if(	isset($this->distinct) )
			throw new RecessException('Delete does not use distinct.', get_defined_vars());
		if( !empty($this->assignments) && !$this->useAssignmentsAsConditions)
			throw new RecessException('Delete does not use assignments. To use assignments as conditions add ->useAssignmentsAsConditions() to your method call chain.', get_defined_vars());
	}
	
	/**
	 * Build an UPDATE SQL string from SqlBuilder's state.
	 *
	 * @return string
	 */
	public function update() {
		$this->updateSanityCheck();
		$sql = 'UPDATE ' . self::escapeWithTicks($this->table) . ' SET ';
		
		$first = true;
		$table_prefix = $this->tableAsPrefix() . '.';
		foreach($this->assignments as $assignment) {
			if($first) { $first = false; }
			else { $sql .= ', '; }
			$sql .= self::escapeWithTicks(str_replace($table_prefix, '', $assignment->column)) . ' = ' . $assignment->getQueryParameter();;
		}
		
		$sql .= $this->whereHelper();
		
		return $sql;
	}
	
	/**
	 * Safety check used with update.
	 */
	protected function updateSanityCheck() {
		if(	!empty($this->joins) )
			throw new RecessException('Update does not use joins.', get_defined_vars());
		if(	!empty($this->orderBy) ) 
			throw new RecessException('Update (in Recess) does not use order by.', get_defined_vars());
		if(	!empty($this->groupBy) ) 
			throw new RecessException('Update (in Recess) does not use group by.', get_defined_vars());
		if(	isset($this->limit) )
			throw new RecessException('Update (in Recess) does not use limit.', get_defined_vars());
		if(	isset($this->offset) )
			throw new RecessException('Update (in Recess) does not use offset.', get_defined_vars());
		if(	isset($this->distinct) )
			throw new RecessException('Update does not use distinct.', get_defined_vars());
	}
	
	/**
	 * Return the collection of PDO named parameters and values to be
	 * applied to a parameterized PDO statement.
	 *
	 * @return array
	 */
	public function getPdoArguments() {
		if($this->useAssignmentsAsConditions)
			return array_merge($this->conditions, $this->cleansedAssignmentsAsConditions());
		else
			return array_merge($this->conditions, $this->assignments);
	}
	
	/**
	 * Method for when using assignments as conditions. This purges
	 * assignments which have null values.
	 *  
	 * @return array
	 */
	protected function cleansedAssignmentsAsConditions() {
		$assignments = array();
		
		$count = count($this->assignments);
		for($i = 0; $i < $count; $i++) {
			if(isset($this->assignments[$i]->value))
				$assignments[] = $this->assignments[$i];
		}
		
		return $assignments;
	}
	
	/**
	 * Alias to specify which table is being used.
	 *
	 * @param string $table
	 * @return SqlBuilder
	 */
	public function from($table) { return $this->table($table); }
	
	/**
	 * Handy shortcut which allows assignments to be used as conditions
	 * in a select statement.
	 *
	 * @param boolean $bool
	 * @return SqlBuilder
	 */
	public function useAssignmentsAsConditions($bool) { $this->useAssignmentsAsConditions = $bool; return $this; }
	
	/* ISqlConditions */
	
	/**
	 * Equality expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param mixed $value
	 * @return SqlBuilder
	 */
	public function equal($column, $value)       { return $this->addCondition($column, $value, Criterion::EQUAL_TO); }
	
	/**
	 * Inequality than expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param mixed $value
	 * @return SqlBuilder
	 */
	public function notEqual($column, $value)    { return $this->addCondition($column, $value, Criterion::NOT_EQUAL_TO); }
	
	/**
	 * Shortcut alias for SqlBuilder->lessThan($column,$big)->greaterThan($column,$small) 
	 *
	 * @param string $column
	 * @param numeric $small Greater than this number. 
	 * @param numeric $big Less than this number.
	 * @return SqlBuilder
	 */
	public function between ($column, $small, $big) { $this->greaterThan($column, $small); return $this->lessThan($column, $big); }
	
	/**
	 * Greater than expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param numeric $value
	 * @return SqlBuilder
	 */
	public function greaterThan($column, $value)          { return $this->addCondition($column, $value, Criterion::GREATER_THAN); }
	
	/**
	 * Greater than or equal to expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param numeric $value
	 * @return SqlBuilder
	 */
	public function greaterThanOrEqualTo($column, $value)         { return $this->addCondition($column, $value, Criterion::GREATER_THAN_EQUAL_TO); }
	
	/**
	 * Less than expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param numeric $value
	 * @return SqlBuilder
	 */
	public function lessThan($column, $value)          { return $this->addCondition($column, $value, Criterion::LESS_THAN); }

	/**
	 * Less than or equal to expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param numeric $value
	 * @return SqlBuilder
	 */
	public function lessThanOrEqualTo($column, $value)         { return $this->addCondition($column, $value, Criterion::LESS_THAN_EQUAL_TO); }

	/**
	 * LIKE expression for WHERE clause of update, delete, or select statements, does not include wildcards.
	 *
	 * @param string $column
	 * @param string $value
	 * @return SqlBuilder
	 */
	public function like($column, $value)        { return $this->addCondition($column, $value, Criterion::LIKE); }
	
	/**
	 * NOT LIKE expression for WHERE clause of update, delete, or select statements, does not include wildcards.
	 *
	 * @param string $column
	 * @param string $value
	 * @return SqlBuilder
	 */
	public function notLike($column, $value)        { return $this->addCondition($column, $value, Criterion::NOT_LIKE); }

	/**
	 * IS NULL expression for WHERE clause of update, delete, or select statements
	 *
	 * @param string $column
	 * @param string $value
	 * @return SqlBuilder
	 */
	public function isNull($column)        { return $this->addCondition($column, null, Criterion::IS_NULL); }
	
	/**
	 * IS NOT NULL expression for WHERE clause of update, delete, or select statements
	 *
	 * @param string $column
	 * @param string $value
	 * @return SqlBuilder
	 */
	public function isNotNull($column)        { return $this->addCondition($column, null, Criterion::IS_NOT_NULL); }
	
	/**
	 * IN to expression for WHERE clause of update, delete, or select statements.
	 *
	 * @param string $column
	 * @param array $value
	 * @return SqlBuilder
	 */
	public function in($column, $value)        { return $this->addCondition($column, $value, Criterion::IN); }
	
	
	/**
	 * Add a condition to the SqlBuilder statement. Additional logic here to prepend
	 * a table name and also keep track of which columns have already been assigned conditions
	 * to ensure we do not use two identical named parameters in PDO.
	 *
	 * @param string $column
	 * @param mixed $value
	 * @param string $operator
	 * @return SqlBuilder
	 */
	protected function addCondition($column, $value, $operator) {
		if(strpos($column, '.') === false && strpos($column, '(') === false && !in_array($column, array_keys($this->selectAs))) {
			if(isset($this->table)) {
				$column = $this->tableAsPrefix() . '.' . $column;
			} else {
				throw new RecessException('Cannot use "' . $operator . '" operator without specifying table for column "' . $column . '".', get_defined_vars());
			}
		}
				
		if(isset($this->conditionsUsed[$column])) {
			$this->conditionsUsed[$column]++;
			$pdoLabel = $column . '_' . $this->conditionsUsed[$column];
		} else {
			$this->conditionsUsed[$column] = 1;
			$pdoLabel = null;
		}
		
		$this->conditions[] = new Criterion($column, $value, $operator, $pdoLabel);
		
		return $this;
	}
	
	/* SELECT */
	protected $select = '*';
	protected $selectAs = array();
	protected $joins = array();
	protected $limit;
	protected $offset;
	protected $distinct;
	protected $orderBy = array();
	protected $groupBy = array();
	protected $usingAliases = false;
	
	/**
	 * Build a SELECT SQL string from SqlBuilder's state.
	 *
	 * @return string
	 */
	public function select() {
		$this->selectSanityCheck();

		$sql = 'SELECT ' . $this->distinct . self::escapeWithTicks($this->select);

		foreach($this->selectAs as $selectAs) {
			$sql .= ', ' . $selectAs;
		}
		
		$sql .= ' FROM ' . self::escapeWithTicks($this->table);
		
		$sql .= $this->joinHelper();
		
		$sql .= $this->whereHelper();
		
		$sql .= $this->orderByHelper();
		
		$sql .= $this->groupByHelper();
		
		$sql .= $this->rangeHelper();
		
		return $sql;
	}
	
	/**
	 * Safety check used when creating a SELECT statement.
	 */
	protected function selectSanityCheck() {
		if( (!empty($this->where) || !empty($this->orderBy)) && !isset($this->table))
			throw new RecessException('Must have from if using where.', get_defined_vars());
		
		if( isset($this->offset) && !isset($this->limit))
			throw new RecessException('Must define limit if using offset.', get_defined_vars());
		
		if($this->select == '*' && !isset($this->table))
			throw new RecessException('No table has been selected.', get_defined_vars());
	}
	
	/* ISqlSelectOptions */
	
	/**
	 * LIMIT results to some number of records.
	 *
	 * @param integer $size
	 * @return SqlBuilder
	 */
	public function limit($size)           { $this->limit = $size; return $this; }
	
	/**
	 * When used in conjunction with limit($size), offset specifies which row the results will begin at.
	 *
	 * @param integer $offset
	 * @return SqlBuilder
	 */
	public function offset($offset)        { $this->offset = $offset; return $this; }
	
	/**
	 * Shortcut alias to ->limit($finish - $start)->offset($start);
	 *
	 * @param integer $start
	 * @param integer $finish
	 * @return SqlBuilder
	 */
	public function range($start, $finish) { $this->offset = $start; $this->limit = $finish - $start; return $this; }
	
	/**
	 * Add an ORDER BY expression to sql string. Example: ->orderBy('name ASC')
	 *
	 * @param string $clause
	 * @return SqlBuilder
	 */
	public function orderBy($clause) {
		if(($spacePos = strpos($clause,' ')) !== false) {
			$name = substr($clause,0,$spacePos);
		} else {
			$name = $clause;
		}
		
		if(isset($this->table) && strpos($clause,'.') === false && strpos($name,'(') === false && !array_key_exists($name, $this->selectAs)) {
			$this->orderBy[] = $this->tableAsPrefix() . '.' . $clause; 
		} else {
			$this->orderBy[] = $clause;
		}
		return $this; 
	}
	
	/**
	 * Add an GROUP BY expression to sql string. Example: ->groupBy('name')
	 *
	 * @param string $clause
	 * @return SqlBuilder
	 */
	public function groupBy($clause) {
		if(($spacePos = strpos($clause,' ')) !== false) {
			$name = substr($clause,0,$spacePos);
		} else {
			$name = $clause;
		}
		
		if(isset($this->table) && strpos($clause,'.') === false && strpos($name,'(') === false && !array_key_exists($name, $this->selectAs)) {
			$this->groupBy[] = $this->tableAsPrefix() . '.' . $clause; 
		} else {
			$this->groupBy[] = $clause;
		}
		return $this; 
	}
	
	/**
	 * Helper method which returns the current table even when it 
	 * is aliased due to joins between the same table.
	 *
	 * @return string The current table which can be used as a prefix.
	 */
	protected function tableAsPrefix() {
		if($this->usingAliases) {
			$spacePos = strrpos($this->table, ' ');
			if($spacePos !== false) {
				return substr($this->table, $spacePos + 1);
			}
		}
		return $this->table;
	}
	
	/**
	 * Left outer join expression for SELECT SQL statement.
	 *
	 * @param string $table
	 * @param string $tablePrimaryKey
	 * @param string $fromTableForeignKey
	 * @return SqlBuilder
	 */
	public function leftOuterJoin($table, $tablePrimaryKey, $fromTableForeignKey) {
		return $this->join(Join::LEFT, Join::OUTER, $table, $tablePrimaryKey, $fromTableForeignKey);
	}
	
	/**
	 * Inner join expression for SELECT SQL statement.
	 *
	 * @param string $table
	 * @param string $tablePrimaryKey
	 * @param string $fromTableForeignKey
	 * @return SqlBuilder
	 */
	public function innerJoin($table, $tablePrimaryKey, $fromTableForeignKey) {
		return $this->join('', Join::INNER, $table, $tablePrimaryKey, $fromTableForeignKey);
	}
	
	/**
	 * Generic join expression to be added to a SELECT SQL statement.
	 *
	 * @param string $leftOrRight
	 * @param string $innerOrOuter
	 * @param string $table
	 * @param string $tablePrimaryKey
	 * @param string $fromTableForeignKey
	 * @return SqlBuilder
	 */
	protected function join($leftOrRight, $innerOrOuter, $table, $tablePrimaryKey, $fromTableForeignKey) {
		if($this->table == $table) {
			$oldTable = $this->table;
			$parts = explode('__', $this->table);
			$partsCount = count($parts);
			if($partsCount > 0 && is_int($parts[$partsCount-1])) {
				$number = $parts[$partsCount - 1] + 1;
			} else {
				$number = 2;
			}
			$tableAlias = $this->table . '__' . $number;
			$this->table = self::escapeWithTicks($this->table) . ' AS ' . self::escapeWithTicks($tableAlias);
			$this->usingAliases = true;
			
			$tablePrimaryKey = str_replace($oldTable,$tableAlias,$tablePrimaryKey);			
		}
		
		$this->select = $this->tableAsPrefix() . '.*';
		$this->joins[] = new Join($leftOrRight, $innerOrOuter, $table, $tablePrimaryKey, $fromTableForeignKey);	
		return $this;
	}
	
	/**
	 * Add additional field to select statement which is aliased using the AS parameter.
	 * ->selectAs("ABS(location - 5)", 'distance') translates to => SELECT ABS(location-5) AS distance
	 *
	 * @param string $select
	 * @param string $as
	 * @return SqlBuilder
	 */
	public function selectAs($select, $as) {
		$this->selectAs[$as] = $select . ' as ' . $as;
		return $this;
	}
	
	/**
	 * Add a DISTINCT clause to SELECT SQL.
	 *
	 * @return SqlBuilder
	 */
	public function distinct() { $this->distinct = ' DISTINCT '; return $this; }

	/* HELPER METHODS */
	protected function whereHelper() {
		$sql = '';
		
		$first = true;
		if(!empty($this->conditions)) {
			foreach($this->conditions as $clause) {
				if(!$first) { $sql .= ' AND '; } else { $first = false; } // TODO: Figure out how we'll do ORing
				$sql .= self::escapeWithTicks($clause->column) . $clause->operator . $clause->getQueryParameter();
			}
		}
		
		if($this->useAssignmentsAsConditions && !empty($this->assignments)) {
			$assignments = $this->cleansedAssignmentsAsConditions();
			foreach($assignments as $clause) {
				if(!$first) { $sql .= ' AND '; } else { $first = false; } // TODO: Figure out how we'll do ORing
				$sql .= self::escapeWithTicks($clause->column) . ' = ' . $clause->getQueryParameter();
			}
		}
		
		if($sql != '') {
			$sql = ' WHERE ' . $sql;
		}
		
		return $sql;
	}
	
	protected function joinHelper() {
		$sql = '';
		if(!empty($this->joins)) {
			$joins = array_reverse($this->joins, true);
			foreach($joins as $join) {
				$joinStatement = ' ';
				
				if(isset($join->natural) && $join->natural != '') {
					$joinStatement .= $join->natural . ' ';
				}
				if(isset($join->leftRightOrFull) && $join->leftRightOrFull != '') {
					$joinStatement .= $join->leftRightOrFull . ' ';
				}
				if(isset($join->innerOuterOrCross) && $join->innerOuterOrCross != '') {
					$joinStatement .= $join->innerOuterOrCross . ' ';
				}
				
				$onStatement = ' ON ' . self::escapeWithTicks($join->tablePrimaryKey) . ' = ' . self::escapeWithTicks($join->fromTableForeignKey);
				$joinStatement .= 'JOIN ' . self::escapeWithTicks($join->table) . $onStatement;
				
				$sql .= $joinStatement;
			}
		}
		return $sql;
	}
	
	protected static function escapeWithTicks($string) {
		if($string == '*' || strpos($string, '`') !== false) {
			return $string;
		}
		if(strpos($string,Library::dotSeparator) !== false) { // Todo: Replace with Regexp
			$parts = explode(Library::dotSeparator, $string);
			if(isset($parts[1]) && $parts[1] == '*') {
				return '`' . $parts[0] . '`.*';
			} else {
				return '`' . implode('`.`', $parts) . '`';
			}
		} else {
			return '`' . $string . '`';
		}
	}
	
	protected function orderByHelper() {
		$sql = '';
		if(!empty($this->orderBy)){
			$sql = ' ORDER BY ';
			$first = true;
			foreach($this->orderBy as $order){
				if(!$first) { $sql .= ', '; } else { $first = false; }
				$sql .= $order;
			}
		}
		return $sql;
	}
	
	protected function groupByHelper() {
		$sql = '';
		if(!empty($this->groupBy)){
			$sql = ' GROUP BY ';
			$first = true;
			foreach($this->groupBy as $order){
				if(!$first) { $sql .= ', '; } else { $first = false; }
				$sql .= $order;
			}
		}
		return $sql;
	}
	
	protected function rangeHelper() {
		$sql = '';
		if(isset($this->limit)){ $sql .= ' LIMIT ' . $this->limit; }
		if(isset($this->offset)){ $sql .= ' OFFSET ' . $this->offset; }
		return $sql;
	}
	

	public function getCriteria() {
		return array_merge($this->conditions, $this->assignments);
	}
	public function getTable() {
		return $this->table;
	}
}

class Criterion {
	public $column;
	public $pdoLabel;
	public $value;
	public $operator;
	
	const GREATER_THAN = ' > ';
	const GREATER_THAN_EQUAL_TO = ' >= ';
	
	const LESS_THAN = ' < ';
	const LESS_THAN_EQUAL_TO = ' <= ';
	
	const EQUAL_TO = ' = ';
	const NOT_EQUAL_TO = ' != ';
	
	const LIKE = ' LIKE ';
	const NOT_LIKE = ' NOT LIKE ';
	
	const IS_NULL = ' IS NULL';
	const IS_NOT_NULL = ' IS NOT NULL';
	
	const COLON = ':';
	
	const ASSIGNMENT = '=';
	const ASSIGNMENT_PREFIX = 'assgn_';
	
	const UNDERSCORE = '_';
	
	const IN = ' IN ';
	
	public function __construct($column, $value, $operator, $pdoLabel = null){
		$this->column = $column;
		$this->value = $value;
		$this->operator = $operator;
		if(!isset($pdoLabel)) {
			$this->pdoLabel = preg_replace('/[ \-.,\(\)`]/', '_', $column);
		} else {
			$this->pdoLabel = preg_replace('/[ \-.,\(\)`]/', '_', $pdoLabel);
		}
	}
	
	public function getQueryParameter() {
		// Begin workaround for PDO's poor numeric binding
		if(is_array($this->value)) {
	      $value = '('.implode(',', $this->value).')';
	      return $value;
		}
		
		if(is_numeric($this->value) && !is_string($this->value)) {
			return $this->value;
		}
		// End workaround
		
		if($this->operator == self::ASSIGNMENT) { 
			return self::COLON . self::ASSIGNMENT_PREFIX . $this->pdoLabel;
		} elseif($this->operator == self::IS_NULL || $this->operator == self::IS_NOT_NULL) {
			return '';
		} else {
			return self::COLON . $this->pdoLabel;
		}
	}
}

class Join {
	const NATURAL = 'NATURAL';
	
	const LEFT = 'LEFT';
	const RIGHT = 'RIGHT';
	const FULL = 'FULL';
	
	const INNER = 'INNER';
	const OUTER = 'OUTER';
	const CROSS = 'CROSS';
	
	public $natural;
	public $leftRightOrFull;
	public $innerOuterOrCross = 'OUTER';
	
	public $table;
	public $tablePrimaryKey;
	public $fromTableForeignKey;
	
	public function __construct($leftRightOrFull, $innerOuterOrCross, $table, $tablePrimaryKey, $fromTableForeignKey, $natural = ''){
		$this->natural = $natural;
		$this->leftRightOrFull = $leftRightOrFull;
		$this->innerOuterOrCross = $innerOuterOrCross;
		$this->table = $table;
		$this->tablePrimaryKey = $tablePrimaryKey;
		$this->fromTableForeignKey = $fromTableForeignKey;
	}
}

?><?php
Library::import('recess.framework.helpers.blocks.Block');
Library::import('recess.framework.helpers.Buffer');
Library::import('recess.framework.helpers.Part');
Library::import('recess.framework.helpers.exceptions.InputDoesNotExistException');

/**
 * PartBlock is an object wrapper for Part templates. Its design is
 * inspired by curried lambdas. When a PartBlock is instantiated arguments
 * can be curried into the instance. Then, when the draw method is called
 * the remaining arguments can be passed. Ex:
 * 
 * $part = new PartBlock('mypart');
 * $part->draw('foo');
 * /// Equivalent to:
 * $part = new PartBlock('mypart', 'foo');
 * $part->draw();
 * 
 * There is also a mechanism for assigning values to inputs out-of-order 
 * with jQuery style property assignment:
 * 
 * $partBlock->inputName('value')->inputName2(10)->draw();
 * 
 * The purpose of PartBlock is to enable the state of a part to be 
 * passed around and manipulated by different entities before finally
 * being drawn.
 * 
 * @author Kris Jordan
 */
class PartBlock extends Block {
	protected $partPath = '';
	protected $args = array();
	protected $curriedArgs = 0;
	
	/**
	 * Instantiate a new PartBlock by passing the name of the Part template
	 * as the first argument followed by any other arguments to curry into
	 * the instance in the order defined by the part.
	 */
	function __construct() {
		$args = func_get_args();
		
		if(!empty($args)) {
			if(count($args) == 1) {
				if(is_array($args[0])) {
					$args = $args[0];
				} else {
					$args = array($args[0]);
				}
			}
		} else {	
			throw new RecessFrameworkException('PartListBlock are required to be constructed with the name of the part as the first argument.', 1);
		}

		$this->partPath = array_shift($args);
		$this->curry($args);
	}	
	
	/**
	 * Draw may or may not take arguments depending on the inputs of the
	 * wrapped part and the arguments that were curried in the construction
	 * of the PartBlock. The Part will throw a MissingRequiredInputException
	 * if a required input has not been satisfied.
	 * 
	 * @see recess/recess/recess/framework/helpers/blocks/Block#draw()
	 */
	public function draw() {
		$args = func_get_args();
		$clone = clone $this;
		$clone->curry($args);
		try {
			Part::drawArray($clone->partPath, $clone->args);
			return true;
		} catch(MissingRequiredInputException $e) {
			throw new MissingRequiredDrawArgumentsException($e->getMessage(), 1);
		}
	}
	
	/**
	 * Converts the PartBlock to a string based on inputs available. This will 
	 * only succeed if all required inputs have been satisfied by currying or 
	 * out-of-order assignment. If not, throws 'MissingRequiredDrawArgumentsException'.
	 * 
	 * @see recess/recess/recess/framework/helpers/blocks/Block#__toString()
	 */
	public function __toString() {
		Buffer::to($returnsBlock);
		try {
			$this->draw();
		} catch(MissingRequiredDrawArgumentsException $e) {
			die($e->getMessage());
		} catch(Exception $e) {
			die($e->getMessage());
		}
		Buffer::end();
		return (string)$returnsBlock;
	}
	
	public function get($input) {
		if(!isset($this->args[$input])) {
			$inputs = Part::getInputs($this->partPath);
			if(isset($inputs[$input])) {
				if(isset($inputs[$input]['default'])) {
					eval('$this->args[$input] = ' . $inputs[$input]['default'] . ';');
				} else {
					return null;
				}
			} else {
				throw new InputDoesNotExistException("Part '$this->partPath' does not have a '$input' input.", 1);
			}
		}
		return $this->args[$input];
	}
	
	public function set($name, $value) {
		try {
			$this->assign($name, $value);
		} catch (InputDoesNotExistException $e) {
			
		} catch (InputTypeCheckException $e) {
			throw new InputTypeCheckException($e->getMessage(), 1);	
		}
		return $this;
	}
	
	/**
	 * protected helper method for currying arguments into an instance.
	 * @param array
	 */
	protected function curry($args) {
		// pair any args with their input names
		if(is_array($args) && !empty($args)) {
			$inputs = Part::getInputs($this->partPath);
			$param = 0;
			$arg = 0;
			$argCount = count($args);
			foreach($inputs as $input => $attributes) {
				if($arg >= $argCount) {
					break;
				}
				if($param >= $this->curriedArgs) {
					try {
						$this->assign($input, $args[$arg++]);
					} catch(InputTypeCheckException $e) {
						throw new InputTypeCheckException($e->getMessage(), 2);
					}				
				}
				++$param;
			}
			$this->curriedArgs = $arg;
		}
	}
	
	/**
	 * Assign a value to a property of the PartBlock. This is an internal
	 * helper method. This method will throw an InputTypeCheckException if
	 * the assigned value does not match the expected value of a template.
	 * 
	 * @param string $property input name
	 * @param varies $value The value to be assigned.
	 */
	protected function assign($property, $value) {
		$inputs = Part::getInputs($this->partPath);
		if(isset($inputs[$property])) {
			if(Part::typeCheck($value, $inputs[$property]['type'])) {
				$this->args[$property] = $value;
			} else {
				$expected = $inputs[$property]['type'];
				$passed = gettype($value);
				if($passed === 'object') {
					$passed = get_class($value);
				}
				throw new InputTypeCheckException("Part input type mismatch '$property' expects '$expected' passed '$passed'.");
			}
		} else {
			throw new InputDoesNotExistException("Part '$this->partPath' does not have a '$property' input.", 2); 
		}
	}
}
?><?php
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
?><?php
Library::import('recess.database.orm.relationships.Relationship');

/**
 * A HasMany Recess Relationship is an abstraction of for the Many side of a 
 * foreign key relationship on the RDBMS.
 * 
 * @author Kris Jordan <krisjordan@gmail.com>
 * @copyright 2008, 2009 Kris Jordan
 * @package Recess PHP Framework
 * @license MIT
 * @link http://www.recessframework.org/
 */
class HasManyRelationship extends Relationship {
	
	function getType() {
		return 'HasMany';
	}
	
	function init($modelClassName, $relationshipName) {
		$this->localClass = $modelClassName;
		$this->name = $relationshipName;
		$this->foreignKey = Inflector::toCamelCaps($modelClassName) . 'Id';
		$this->foreignClass = Inflector::toSingular(Inflector::toProperCaps($relationshipName));
		$this->onDelete = Relationship::UNSPECIFIED;
	}
	
	function getDefaultOnDeleteMode() {
		if(!isset($this->through)) {
			return Relationship::CASCADE;
		} else {
			return Relationship::DELETE;
		}
	}
	
	function attachMethodsToModelDescriptor(ModelDescriptor $descriptor) {
		$alias = $this->name;
		$attachedMethod = new AttachedMethod($this,'selectModel', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
		
		$alias = 'addTo' . ucfirst($this->name);
		$attachedMethod = new AttachedMethod($this,'addTo', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
		
		$alias = 'removeFrom' . ucfirst($this->name);
		$attachedMethod = new AttachedMethod($this,'removeFrom', $alias);
		$descriptor->addAttachedMethod($alias, $attachedMethod);
	}
	
	function addTo(Model $model, Model $relatedModel) {
		if(!$model->primaryKeyIsSet()) {
			$model->insert();
		}
			
		if(!isset($this->through)) {
			$foreignKey = $this->foreignKey;
			$localKey = Model::primaryKeyName($model);	
			$relatedModel->$foreignKey = $model->$localKey;
			$relatedModel->save();
		} else {
			if(!$relatedModel->primaryKeyIsSet()) {
				$relatedModel->insert();
			}
			// TODO: This is a shitshow.
			$through = new $this->through;
			$localPrimaryKey = Model::primaryKeyName($model);
			$localForeignKey = $this->foreignKey;
			$through->$localForeignKey = $model->$localPrimaryKey;
			
			$relatedPrimaryKey = Model::primaryKeyName($this->through);
			$relatedForeignKey = Model::getRelationship($this->through, Inflector::toSingular($this->name))->foreignKey;
			$through->$relatedForeignKey = $relatedModel->$relatedPrimaryKey;
			
			$through->insert();
		}
		
		return $model;
	}
	
	function removeFrom(Model $model, Model $relatedModel) {
		if(!isset($this->through)) {
			$foreignKey = $this->foreignKey;
			$relatedModel->$foreignKey = '';
			$relatedModel->save();
			return $model;
		} else {
			$through = new $this->through;
			
			$localPrimaryKey = Model::primaryKeyName($model);
			$localForeignKey = $this->foreignKey;
			$through->$localForeignKey = $model->$localPrimaryKey;
			
			$relatedPrimaryKey = Model::primaryKeyName($this->through);
			$relatedForeignKey = Model::getRelationship($this->through, Inflector::toSingular($this->name))->foreignKey;
			$through->$relatedForeignKey = $relatedModel->$relatedPrimaryKey;
			
			$through->find()->delete(false);
		}
	}
	
	function selectModel(Model $model) {
		return $this->augmentSelect($model->select());
	}
	
	function selectModelSet(ModelSet $modelSet) {
		return $this->augmentSelect($modelSet);
	}
	
	protected function augmentSelect(PdoDataSet $select) {
		if(!isset($this->through)) {
			$relatedClass = $this->foreignClass;
		} else {
			$relatedClass = $this->through;
		}
		
		$relatedTable = Model::tableFor($relatedClass);
		$localTable = Model::tableFor($this->localClass);
		$foreignKey = $relatedTable . '.' . $this->foreignKey;
		$primaryKey = Model::primaryKeyFor($this->localClass);
		
		$select = $select	
					->from($relatedTable)
					->innerJoin($localTable,
								$foreignKey, 
								$primaryKey 
								);
		
		$select->rowClass = $relatedClass;
		
		if(!isset($this->through)) {
			return $select;
		} else {
			$select = $select->distinct();
			$relationship = $this->name;
			return $select->$relationship();
		}
	}
	
	function onDeleteCascade(Model $model) {
		$related = $this->selectModel($model)->delete();
		
		if(isset($this->through)) {
			$modelPk = Model::primaryKeyName($model);
			$queryBuilder = new SqlBuilder();
			$queryBuilder
				->from(Model::tableFor($this->through))
				->equal($this->foreignKey, $model->$modelPk);
			
			$source = Model::sourceFor($model);
			
			$source->executeStatement($queryBuilder->delete(), $queryBuilder->getPdoArguments());		
		}
	}
	
	function onDeleteDelete(Model $model) {
		$modelPk = Model::primaryKeyName($model);
		
		if(!isset($this->through)) {
			$relatedClass = $this->foreignClass;
		} else {
			$relatedClass = $this->through;
		}
		
		$queryBuilder = new SqlBuilder();
		$queryBuilder
			->from(Model::tableFor($relatedClass))
			->equal($this->foreignKey, $model->$modelPk);
		
		$source = Model::sourceFor($model);
		
		$source->executeStatement($queryBuilder->delete(), $queryBuilder->getPdoArguments());
	}
	
	function onDeleteNullify(Model $model) {
		if(isset($this->through)) {
			return $this->onDeleteDelete($model);
		}
		
		$modelPk = Model::primaryKeyName($model);
		
		$queryBuilder = new SqlBuilder();
		$queryBuilder
			->from(Model::tableFor($this->foreignClass))
			->assign($this->foreignKey, null)
			->equal($this->foreignKey, $model->$modelPk);
			
		$source = Model::sourceFor($model);
		
		$source->executeStatement($queryBuilder->update(), $queryBuilder->getPdoArguments());
	}
	
	function __set_state($array) {
		$relationship = new HasManyRelationship();
		$relationship->name = $array['name'];
		$relationship->localClass = $array['localClass'];
		$relationship->foreignClass = $array['foreignClass'];
		$relationship->onDelete = $array['onDelete'];
		$relationship->through = $array['through'];
		return $relationship;
	}

}

?><?php
Library::import('recess.framework.forms.FormInput');
class BooleanInput extends FormInput {
	function setValue($value) {
		if (is_numeric($value)) {
			$this->value = $value == 1;
		} else {
			$this->value = $value;
		}
	}
	
	function render() {
		echo '<input type="radio" name="', $this->name, '"', $this->value == true ? ' checked="checked" ' : '', ' value="1" />Yes</input>';
		echo '<input type="radio" name="', $this->name, '"', $this->value == true ? '' : ' checked="checked" ', ' value="0" />No</input>';
	}
}
?><?php
Library::import('recess.framework.forms.FormInput');
class DateTimeInput extends FormInput {
	
	public $showDate = true;
	public $showTime = true;
	
	protected static $months = array('Jan',
									 'Feb', 
									 'Mar',
									 'Apr',
									 'May',
									 'June',
									 'July', 
									 'Aug', 
									 'Sept', 
									 'Oct', 
									 'Nov',
									 'Dec');
									 
	protected static $meridiems = array(
									 self::AM,
									 self::PM
										);
	const MONTH = 'month';
	const DAY = 'day';
	const YEAR = 'year';
	const HOUR = 'hour';
	const MINUTE = 'minute';
	const MERIDIEM = 'meridiem';
	const AM = 'am';
	const PM = 'pm';
	const PM_HOURS = 12;
	
	function getValue() {
		return $this->value;
	}
	
	function getValueOrZero($array, $key) {
		if(isset($array[$key]) && $array[$key] != '')
			return $array[$key];
		else
			return 0;
	}
	
	function setValue($value) {
		if(is_array($value)) {
			$month = $this->getValueOrZero($value, self::MONTH);
			$day = $this->getValueOrZero($value, self::DAY);
			$year = $this->getValueOrZero($value, self::YEAR);
			$hour = $this->getValueOrZero($value, self::HOUR);
			$minute = $this->getValueOrZero($value, self::MINUTE);
			$meridiem = $this->getValueOrZero($value, self::MERIDIEM);
			
			if($meridiem == self::PM) {
				$hour += self::PM_HOURS;
			}
			
			$this->value = mktime($hour,$minute,1,$month,$day,$year);
		} else {
			$this->value = $value;
		}
	}
	
	function render() {
		
		if($this->showDate) {
			$this->printMonthInput();
			$this->printDayInput();
			$this->printYearInput();
		}
		
		if($this->showTime) {
			$this->printHourInput();
			$this->printMinuteInput();
			$this->printmeridiemInput();
		}
		
	}
	
	function printMonthInput() {
		$this->printSelect($this->name . '[' . self::MONTH . ']', self::$months, date('n', $this->value));
	}
	
	function printDayInput() {
		$this->printSelect($this->name . '[' . self::DAY . ']', range(1,31), date('j', $this->value));
	}
	
	function printYearInput() {
		$this->printText($this->name . '[' . self::YEAR . ']', date('Y', $this->value));
	}
	
	function printHourInput() {
		$this->printSelect($this->name . '[' . self::HOUR . ']', range(1,12), date('g', $this->value));
	}
	
	function printMinuteInput() {
		$this->printSelect($this->name . '[' . self::MINUTE . ']', range(0,60,15), (int)date('i', $this->value));
	}
	
	function printMeridiemInput() {
		$this->printSelect($this->name . '[' . self::MERIDIEM . ']', self::$meridiems, date('a', $this->value));
	}
	
	function printSelect($name, $values, $selected) {
		echo '<select name="', $name, '">';
		
		foreach($values as $key => $value) {
			$key++;
			echo '<option value="', $key, '"';
			if($key == $selected) {
				echo ' selected="selected"';
			}
			echo '>', $value, '</option>', "\n";
		}
		
		echo '</select>';
	}
	
	function printText($name, $value = '') {
		echo '<input class="text short" name="' . $name . '" value="' . $value . '" />';
	}
}
?><?php
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
?><?php
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