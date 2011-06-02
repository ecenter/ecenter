<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function ecenter_wiki_context_default_contexts() {
  $export = array();
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'ecenter_wiki';
  $context->description = '';
  $context->tag = 'e-center';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'wiki' => 'wiki',
      ),
      'options' => array(
        'node_form' => '0',
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'views-ecenter_wiki_revisions-block' => array(
          'module' => 'views',
          'delta' => 'ecenter_wiki_revisions-block',
          'region' => 'right',
          'weight' => 0,
        ),
      ),
    ),
    'breadcrumb' => 'wiki',
    'menu' => 'wiki',
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('e-center');

  $export['ecenter_wiki'] = $context;
  return $export;
}
