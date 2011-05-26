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
  $context->tag = 'ecenter';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'wiki' => 'wiki',
      ),
      'options' => array(
        'node_form' => '1',
      ),
    ),
  );
  $context->reactions = array(
    'breadcrumb' => 'wiki',
    'menu' => 'wiki',
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('ecenter');

  $export['ecenter_wiki'] = $context;
  return $export;
}
