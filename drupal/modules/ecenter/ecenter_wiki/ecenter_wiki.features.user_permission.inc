<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function ecenter_wiki_user_default_permissions() {
  $permissions = array();

  // Exported permission: create wiki content
  $permissions['create wiki content'] = array(
    'name' => 'create wiki content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'trusted user',
    ),
  );

  // Exported permission: delete any wiki content
  $permissions['delete any wiki content'] = array(
    'name' => 'delete any wiki content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: delete own wiki content
  $permissions['delete own wiki content'] = array(
    'name' => 'delete own wiki content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: edit any wiki content
  $permissions['edit any wiki content'] = array(
    'name' => 'edit any wiki content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'trusted user',
    ),
  );

  // Exported permission: edit own wiki content
  $permissions['edit own wiki content'] = array(
    'name' => 'edit own wiki content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'trusted user',
    ),
  );

  return $permissions;
}
