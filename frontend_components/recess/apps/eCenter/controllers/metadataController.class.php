<?php
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
?>
