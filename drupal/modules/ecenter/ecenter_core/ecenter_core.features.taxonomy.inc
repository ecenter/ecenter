<?php

/**
 * Implementation of hook_taxonomy_default_vocabularies().
 */
function ecenter_core_taxonomy_default_vocabularies() {
  return array(
    'tags' => array(
      'name' => 'Tags',
      'description' => 'Sitewide tags',
      'help' => '',
      'relations' => '1',
      'hierarchy' => '0',
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
    ),
  );
}
