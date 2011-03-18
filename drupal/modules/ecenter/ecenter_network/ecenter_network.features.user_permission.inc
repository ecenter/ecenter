<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function ecenter_network_user_default_permissions() {
  $permissions = array();

  // Exported permission: access ecenter network
  $permissions['access ecenter network'] = array(
    'name' => 'access ecenter network',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'anonymous user',
      '2' => 'authenticated user',
    ),
  );

  // Exported permission: administer ecenter network
  $permissions['administer ecenter network'] = array(
    'name' => 'administer ecenter network',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: debug ecenter network
  $permissions['debug ecenter network'] = array(
    'name' => 'debug ecenter network',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  return $permissions;
}
