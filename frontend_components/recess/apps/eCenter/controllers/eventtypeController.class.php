<?php
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
?>
