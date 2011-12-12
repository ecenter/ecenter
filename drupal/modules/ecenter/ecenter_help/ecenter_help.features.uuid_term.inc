<?php

/**
 * Implementation of hook_uuid_features_default_terms().
 */
function ecenter_help_uuid_features_default_terms() {
  $terms = array();

  $terms[] = array(
    'uuid' => 'b0acb2e6-24e8-11e1-b676-0026b9b97a6a',
    'name' => 'E-Center Documentation',
    'description' => '',
    'weight' => '0',
    'uuid_vocabulary' => 'b0ac92f2-24e8-11e1-b676-0026b9b97a6a',
  );
  return $terms;
}
