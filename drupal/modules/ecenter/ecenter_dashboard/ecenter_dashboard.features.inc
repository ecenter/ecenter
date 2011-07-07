<?php

/**
 * Implementation of hook_flag_default_flags().
 */
function ecenter_dashboard_flag_default_flags() {
  $flags = array();
  // Exported flag: "Promote to E-Center dashboard carousel".
  $flags['ecenter_dashboard_carousel'] = array(
    'content_type' => 'node',
    'title' => 'Promote to E-Center dashboard carousel',
    'global' => '1',
    'types' => array(
      '0' => 'snippet',
    ),
    'flag_short' => 'Promote to E-Center dashboard carousel',
    'flag_long' => '',
    'flag_message' => 'Promote to E-Center dashboard carousel',
    'unflag_short' => 'Remove from E-Center dashboard carousel',
    'unflag_long' => '',
    'unflag_message' => '',
    'unflag_denied_text' => '',
    'link_type' => 'toggle',
    'roles' => array(
      'flag' => array(
        '0' => '3',
      ),
      'unflag' => array(
        '0' => '3',
      ),
    ),
    'show_on_page' => 1,
    'show_on_teaser' => 0,
    'show_on_form' => 0,
    'access_author' => '',
    'i18n' => 0,
    'flag_confirmation' => '',
    'unflag_confirmation' => '',
    'api_version' => 2,
    'module' => 'ecenter_dashboard',
    'locked' => array(
      '0' => 'name',
    ),
  );
  return $flags;
}

/**
 * Implementation of hook_views_api().
 */
function ecenter_dashboard_views_api() {
  return array(
    'api' => '3.0-alpha1',
  );
}
