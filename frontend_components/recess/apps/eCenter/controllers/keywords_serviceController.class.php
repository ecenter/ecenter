<?php
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
?>
