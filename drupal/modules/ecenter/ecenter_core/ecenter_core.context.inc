<?php

/**
 * Implementation of hook_context_default_contexts().
 */
function ecenter_core_context_default_contexts() {
  $export = array();
  $context = new stdClass;
  $context->disabled = FALSE; /* Edit this to true to make a default context disabled initially */
  $context->api_version = 3;
  $context->name = 'ecenter_site';
  $context->description = 'E-Center sitewide context';
  $context->tag = 'e-center';
  $context->conditions = array(
    'sitewide' => array(
      'values' => array(
        1 => 1,
      ),
    ),
  );
  $context->reactions = array(
    'block' => array(
      'blocks' => array(
        'ecenter_core-login' => array(
          'module' => 'ecenter_core',
          'delta' => 'login',
          'region' => 'header',
          'weight' => 0,
        ),
        'menu-primary-links' => array(
          'module' => 'menu',
          'delta' => 'primary-links',
          'region' => 'navigation',
          'weight' => 0,
        ),
      ),
    ),
  );
  $context->condition_mode = 1;

  // Translatables
  // Included for use with string extractors like potx.
  t('E-Center sitewide context');
  t('e-center');

  $export['ecenter_site'] = $context;
  return $export;
}
