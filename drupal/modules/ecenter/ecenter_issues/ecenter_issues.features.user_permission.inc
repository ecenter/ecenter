<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function ecenter_issues_user_default_permissions() {
  $permissions = array();

  // Exported permission: create issue content
  $permissions['create issue content'] = array(
    'name' => 'create issue content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'authenticated user',
      '2' => 'trusted user',
    ),
  );

  // Exported permission: create network_query content
  $permissions['create network_query content'] = array(
    'name' => 'create network_query content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'trusted user',
    ),
  );

  // Exported permission: delete any issue content
  $permissions['delete any issue content'] = array(
    'name' => 'delete any issue content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: delete any network_query content
  $permissions['delete any network_query content'] = array(
    'name' => 'delete any network_query content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: delete own issue content
  $permissions['delete own issue content'] = array(
    'name' => 'delete own issue content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'trusted user',
    ),
  );

  // Exported permission: delete own network_query content
  $permissions['delete own network_query content'] = array(
    'name' => 'delete own network_query content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: edit any network_query content
  $permissions['edit any network_query content'] = array(
    'name' => 'edit any network_query content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: edit own issue content
  $permissions['edit own issue content'] = array(
    'name' => 'edit own issue content',
    'roles' => array(
      '0' => 'administrator',
      '1' => 'authenticated user',
      '2' => 'trusted user',
    ),
  );

  // Exported permission: edit own network_query content
  $permissions['edit own network_query content'] = array(
    'name' => 'edit own network_query content',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  return $permissions;
}
