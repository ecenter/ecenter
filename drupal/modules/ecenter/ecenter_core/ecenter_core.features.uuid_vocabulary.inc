<?php

/**
 * Implementation of hook_uuid_features_default_vocabularies().
 */
function ecenter_core_uuid_features_default_vocabularies() {
  $vocabularies = array();

  $vocabularies[] = array(
    'uuid' => 'b0ac92f2-24e8-11e1-b676-0026b9b97a6a',
    'name' => 'Tags',
    'description' => 'Sitewide tags',
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
      'blog_post' => 'blog_post',
    ),
  );
  return $vocabularies;
}
