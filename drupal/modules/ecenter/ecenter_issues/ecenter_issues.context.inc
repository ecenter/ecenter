<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function ecenter_issues_context_default_contexts() {
  $export = array();

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'ecenter_issues';
  $context->description = '';
  $context->tag = 'e-center';
  $context->conditions = array(
    'node' => array(
      'values' => array(
        'issue' => 'issue',
      ),
      'options' => array(
        'node_form' => '0',
      ),
    ),
  );
  $context->reactions = array(
    'breadcrumb' => 'issues',
    'menu' => 'issues',
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('e-center');
  $export['ecenter_issues'] = $context;

  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'ecenter_issues_view';
  $context->description = '';
  $context->tag = 'e-center';
  $context->conditions = array(
    'views' => array(
      'values' => array(
        'ecenter_issues:page_1' => 'ecenter_issues:page_1',
      ),
    ),
  );
  $context->reactions = array(
    'breadcrumb' => 'issues',
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('e-center');
  $export['ecenter_issues_view'] = $context;

  return $export;
}
