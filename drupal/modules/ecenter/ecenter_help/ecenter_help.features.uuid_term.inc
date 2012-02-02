<?php

/**
 * Implementation of hook_uuid_features_default_terms().
 */
function ecenter_help_uuid_features_default_terms() {
  $terms = array();

  $terms[] = array(
    'uuid' => 'ee90cb44-4930-11e1-ba2b-0026b9b97a6a',
    'name' => 'Documentation',
    'description' => '',
    'weight' => '0',
    'uuid_vocabulary' => 'ee8dbee0-4930-11e1-ba2b-0026b9b97a6a',
  );
  return $terms;
}
