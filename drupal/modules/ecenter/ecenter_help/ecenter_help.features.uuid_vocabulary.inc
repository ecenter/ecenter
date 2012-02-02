<?php

/**
 * Implementation of hook_uuid_features_default_vocabularies().
 */
function ecenter_help_uuid_features_default_vocabularies() {
  $vocabularies = array();

  $vocabularies[] = array(
    'uuid' => 'ee8dbee0-4930-11e1-ba2b-0026b9b97a6a',
    'name' => 'Tags',
    'description' => '',
    'help' => '',
    'relations' => '1',
    'multiple' => '0',
    'required' => '0',
    'tags' => '1',
    'module' => 'features_tags',
    'weight' => '0',
    'nodes' => array(
      'wiki' => 'wiki',
      'page' => 'page',
      'issue' => 'issue',
    ),
  );
  return $vocabularies;
}
