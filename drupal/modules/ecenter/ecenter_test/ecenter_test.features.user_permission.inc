<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function ecenter_test_foo_user_default_permissions() {
  $permissions = array();

  // Exported permission: access devel information
  $permissions['access devel information'] = array(
    'name' => 'access devel information',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  return $permissions;
}
