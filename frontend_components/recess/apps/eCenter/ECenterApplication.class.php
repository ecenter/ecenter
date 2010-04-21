<?php
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
?>