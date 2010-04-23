<?php
Library::import('eCenter.models.keyword');
Library::import('recess.framework.forms.ModelForm');

/**
 * !RespondsWith Layouts, Json
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
?>
