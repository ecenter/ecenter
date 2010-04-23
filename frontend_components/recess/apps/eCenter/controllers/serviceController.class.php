<?php
Library::import('eCenter.models.service');
Library::import('eCenter.models.keywords_service');
Library::import('eCenter.models.eventtype');
Library::import('eCenter.models.metadata');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts, Json
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
		$kws =   $keywords_svc->equal('service', $service);
		$evnts = $eventtype->equal('service', $service);
		$mds =   $md->equal('service', $service);
		
		$this->service->metadatas = array();
		$this->service->keywords_services  = array();
		$this->service->eventtypes = array();
		foreach ($mds as $md) {
		  $this->service->metadatas [] = $md;
		}
		foreach ($kws as $kw) {
		  $this->service->keywords_services [] = $kw;
		}
		foreach ($evnts as $ev) {
		  $this->service->eventtypes [] = $ev;
		}
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
?>
