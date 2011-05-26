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
        'menu_block-1' => array(
          'module' => 'menu_block',
          'delta' => 1,
          'region' => 'navigation',
          'weight' => 0,
        ),
        'menu_block-2' => array(
          'module' => 'menu_block',
          'delta' => 2,
          'region' => 'navigation',
          'weight' => 1,
        ),
        'search-0' => array(
          'module' => 'search',
          'delta' => 0,
          'region' => 'navigation',
          'weight' => 2,
        ),
        'ecenter_core-sponsors' => array(
          'module' => 'ecenter_core',
          'delta' => 'sponsors',
          'region' => 'footer',
          'weight' => 0,
        ),
        'ecenter_core-site_info' => array(
          'module' => 'ecenter_core',
          'delta' => 'site_info',
          'region' => 'footer',
          'weight' => 1,
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
