<?php

/**
 * Implementation of hook_user_default_permissions().
 */
function ecenter_user_user_default_permissions() {
  $permissions = array();

  // Exported permission: add twitter accounts
  $permissions['add twitter accounts'] = array(
    'name' => 'add twitter accounts',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: administer consumers
  $permissions['administer consumers'] = array(
    'name' => 'administer consumers',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: administer oauth
  $permissions['administer oauth'] = array(
    'name' => 'administer oauth',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: make twitter accounts global
  $permissions['make twitter accounts global'] = array(
    'name' => 'make twitter accounts global',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: oauth authorize any consumers
  $permissions['oauth authorize any consumers'] = array(
    'name' => 'oauth authorize any consumers',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: oauth register any consumers
  $permissions['oauth register any consumers'] = array(
    'name' => 'oauth register any consumers',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  // Exported permission: use global twitter account
  $permissions['use global twitter account'] = array(
    'name' => 'use global twitter account',
    'roles' => array(
      '0' => 'administrator',
    ),
  );

  return $permissions;
}
