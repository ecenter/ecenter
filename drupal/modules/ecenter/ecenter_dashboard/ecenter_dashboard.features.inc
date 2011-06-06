<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_dashboard_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
}

/**
 * Implementation of hook_heartbeat_message_info().
 */
function ecenter_dashboard_heartbeat_message_info() {
  $messages = array();

  // Exported heartbeat message: ecenter_add_wiki
  $messages['ecenter_add_wiki'] = array (
    'message' => '!username has added wiki page !node_title',
    'message_concat' => '',
    'message_id' => 'ecenter_add_wiki',
    'concat_args' => 
    array (
      'type' => 'single',
      'group_by' => 'none',
      'group_target' => '',
      'group_by_target' => '',
      'group_num_max' => '',
      'merge_separator' => '',
      'merge_end_separator' => '',
      'roles' => 
      array (
        0 => '0',
        1 => '0',
        2 => '0',
        3 => '0',
        4 => '0',
      ),
      'merge_separator_t' => '0',
      'merge_end_separator_t' => '0',
    ),
    'description' => 'User created a wiki page.',
    'perms' => '1',
    'custom' => 1,
    'variables' => 
    array (
    ),
  );

  // Exported heartbeat message: ecenter_update_wiki
  $messages['ecenter_update_wiki'] = array (
    'message' => '<div class="picture-wrapper">!picture</div>
  <div class="message">
    <div class="meta"><span class="username">!username</span> updated wiki page <span class="title">!node_title</span></div>
    <div class="log-message"><span class="message-label">Message:</span> !log_message</div>
  </div>',
    'message_concat' => '',
    'message_id' => 'ecenter_update_wiki',
    'concat_args' => 
    array (
      'type' => 'single',
      'group_by' => 'none',
      'group_target' => '',
      'group_by_target' => '',
      'group_num_max' => '',
      'merge_separator' => '',
      'merge_end_separator' => '',
      'roles' => 
      array (
        0 => '0',
        1 => '0',
        2 => '0',
        3 => '0',
        4 => '0',
      ),
      'merge_separator_t' => '0',
      'merge_end_separator_t' => '0',
    ),
    'description' => 'User updated wiki page.',
    'perms' => '10',
    'custom' => 1,
    'variables' => 
    array (
    ),
  );


  return $messages;
}

/**
 * Implementation of hook_rules_defaults().
 */
/*
function ecenter_dashboard_rules_defaults() {
  return array(
    'rules' => array(
      'hrule_add_page' => array(
        '#type' => 'rule',
        '#set' => 'event_node_insert',
        '#label' => 'Heartbeat: when user adds a page, log user activity',
        '#active' => 0,
        '#weight' => '0',
        '#categories' => array(
          '0' => 'heartbeat',
          'ecenter_dashboard' => 'ecenter_dashboard',
        ),
        '#status' => 'default',
        '#conditions' => array(
          '0' => array(
            '#weight' => 0,
            '#info' => array(
              'label' => 'page is published',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
            '#name' => 'rules_condition_content_is_published',
            '#settings' => array(
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#type' => 'condition',
          ),
          '1' => array(
            '#type' => 'condition',
            '#settings' => array(
              'type' => array(
                'page' => 'page',
              ),
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#name' => 'rules_condition_content_is_type',
            '#info' => array(
              'label' => 'Content has type page',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
            '#weight' => 0,
          ),
        ),
        '#actions' => array(
          '0' => array(
            '#info' => array(
              'label' => 'Logs activity for single users adding a page',
              'label callback' => FALSE,
              'eval input' => array(
                '0' => 'uid_param',
                '1' => 'uid_target_param',
                '2' => 'nid_param',
                '3' => 'nid_target_param',
                '4' => 'message_id_param',
                '5' => 'variables_param',
              ),
              'module' => 'heartbeat',
            ),
            '#name' => 'heartbeat_rules_default_action',
            '#settings' => array(
              'uid_param' => '[author:uid]',
              'uid_target_param' => '0',
              'nid_param' => '[node:nid]',
              'nid_target_param' => '',
              'message_id_param' => 'heartbeat_add_node',
              'variables_param' => '@username=|=[author:user-name-url]-|-@node_type=|=[node:type]-|-@node_title=|=[node:title-link]-|-@types=|=pages-|-',
              '#eval input' => array(
                'token_rules_input_evaluator' => array(
                  'uid_param' => array(
                    '0' => 'author',
                  ),
                  'nid_param' => array(
                    '0' => 'node',
                  ),
                  'variables_param' => array(
                    '0' => 'node',
                    '1' => 'author',
                  ),
                ),
              ),
            ),
            '#type' => 'action',
            '#weight' => 0,
          ),
        ),
        '#version' => 6003,
      ),
      'rules_ecenter_add_wiki' => array(
        '#type' => 'rule',
        '#set' => 'event_node_insert',
        '#label' => 'E-Center Heartbeat: when user adds a wiki, log user activity',
        '#active' => 1,
        '#weight' => '0',
        '#categories' => array(
          '0' => 'heartbeat',
          'ecenter_dashboard' => 'ecenter_dashboard',
        ),
        '#status' => 'default',
        '#conditions' => array(
          '0' => array(
            '#weight' => 0,
            '#info' => array(
              'label' => 'page is published',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
            '#name' => 'rules_condition_content_is_published',
            '#settings' => array(
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#type' => 'condition',
          ),
          '1' => array(
            '#type' => 'condition',
            '#settings' => array(
              'type' => array(
                'wiki' => 'wiki',
              ),
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#name' => 'rules_condition_content_is_type',
            '#info' => array(
              'label' => 'Content has type page',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
            '#weight' => 0,
          ),
        ),
        '#actions' => array(
          '0' => array(
            '#weight' => 0,
            '#info' => array(
              'label' => 'Logs activity for single users adding a wiki page',
              'label callback' => FALSE,
              'eval input' => array(
                '0' => 'uid_param',
                '1' => 'uid_target_param',
                '2' => 'nid_param',
                '3' => 'nid_target_param',
                '4' => 'message_id_param',
                '5' => 'variables_param',
              ),
              'module' => 'heartbeat',
            ),
            '#name' => 'heartbeat_rules_default_action',
            '#settings' => array(
              'uid_param' => '[author:uid]',
              'uid_target_param' => '0',
              'nid_param' => '[node:nid]',
              'nid_target_param' => '',
              'message_id_param' => 'ecenter_add_wiki',
              'variables_param' => '@picture=|=[user:heartbeat-user-picture]-|-@username=|=[author:user-name-url]-|-@node_title=|=[node:title-link]-|-@revision_log=|=[node:log]',
              '#eval input' => array(
                'token_rules_input_evaluator' => array(
                  'uid_param' => array(
                    '0' => 'author',
                    '1' => ':global',
                  ),
                  'nid_param' => array(
                    '0' => 'node',
                    '1' => ':global',
                  ),
                  'variables_param' => array(
                    '0' => 'node',
                    '1' => 'author',
                    '2' => 'user',
                    '3' => ':global',
                  ),
                  'uid_target_param' => array(
                    '0' => ':global',
                  ),
                  'nid_target_param' => array(
                    '0' => ':global',
                  ),
                  'message_id_param' => array(
                    '0' => ':global',
                  ),
                ),
              ),
            ),
            '#type' => 'action',
          ),
        ),
        '#version' => 6003,
      ),
      'rules_ecenter_update_wiki' => array(
        '#type' => 'rule',
        '#set' => 'event_node_update',
        '#label' => 'E-center Heartbeat: when user updates a wiki page, log user activity',
        '#active' => 1,
        '#weight' => '0',
        '#categories' => array(
          '0' => 'heartbeat',
          'ecenter_dashboard' => 'ecenter_dashboard',
        ),
        '#status' => 'default',
        '#conditions' => array(
          '0' => array(
            '#weight' => 0,
            '#info' => array(
              'label' => 'page is published',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
            '#name' => 'rules_condition_content_is_published',
            '#settings' => array(
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#type' => 'condition',
          ),
          '1' => array(
            '#weight' => 0,
            '#type' => 'condition',
            '#settings' => array(
              'type' => array(
                'wiki' => 'wiki',
              ),
              '#argument map' => array(
                'node' => 'node',
              ),
            ),
            '#name' => 'rules_condition_content_is_type',
            '#info' => array(
              'label' => 'Content has type wiki',
              'label callback' => FALSE,
              'arguments' => array(
                'node' => array(
                  'type' => 'node',
                  'label' => 'Content',
                ),
              ),
              'module' => 'Node',
            ),
          ),
        ),
        '#actions' => array(
          '0' => array(
            '#weight' => 5,
            '#info' => array(
              'label' => 'Logs activity for single users adding a page',
              'label callback' => FALSE,
              'eval input' => array(
                '0' => 'uid_param',
                '1' => 'uid_target_param',
                '2' => 'nid_param',
                '3' => 'nid_target_param',
                '4' => 'message_id_param',
                '5' => 'variables_param',
              ),
              'module' => 'heartbeat',
            ),
            '#name' => 'heartbeat_rules_default_action',
            '#settings' => array(
              'uid_param' => '[user:uid]',
              'uid_target_param' => '0',
              'nid_param' => '[node:nid]',
              'nid_target_param' => '',
              'message_id_param' => 'ecenter_update_wiki',
              'variables_param' => '@picture=|=[user:heartbeat-user-picture]-|-@username=|=[user:user-name-url]-|-@node_title=|=[node:title-link]-|-@log_message=|=[node:log]-|-',
              '#eval input' => array(
                'token_rules_input_evaluator' => array(
                  'uid_param' => array(
                    '0' => 'user',
                    '1' => ':global',
                  ),
                  'nid_param' => array(
                    '0' => 'node',
                    '1' => ':global',
                  ),
                  'variables_param' => array(
                    '0' => 'node',
                    '1' => 'user',
                    '2' => ':global',
                  ),
                  'uid_target_param' => array(
                    '0' => ':global',
                  ),
                  'nid_target_param' => array(
                    '0' => ':global',
                  ),
                  'message_id_param' => array(
                    '0' => ':global',
                  ),
                ),
              ),
            ),
            '#type' => 'action',
          ),
        ),
        '#version' => 6003,
      ),
      'hrules_add_comment' => array(
        '#type' => 'rule',
        '#set' => 'event_comment_publish',
        '#label' => 'Heartbeat: When a user adds a comment',
        '#active' => 0,
        '#weight' => '0',
        '#categories' => array(
          '0' => 'heartbeat',
          'ecenter_dashboard' => 'ecenter_dashboard',
        ),
        '#status' => 'default',
        '#conditions' => array(),
        '#actions' => array(
          '0' => array(
            '#weight' => 0,
            '#info' => array(
              'label' => 'Logs user activity for single users',
              'eval input' => array(
                '0' => 'uid_param',
                '1' => 'uid_target_param',
                '2' => 'nid_param',
                '3' => 'nid_target_param',
                '4' => 'message_id_param',
                '5' => 'variables_param',
              ),
              'module' => 'heartbeat',
            ),
            '#name' => 'heartbeat_rules_default_action',
            '#settings' => array(
              'uid_param' => '[comment_author:uid]',
              'uid_target_param' => '[node_author:uid]',
              'nid_param' => '[node:nid]',
              'nid_target_param' => '0',
              'message_id_param' => 'heartbeat_add_comment',
              'variables_param' => '@username=|=[comment_author:user-name-url]-|-@title=|=[node:title-link]-|-@comment=|=[comment:comment-body-raw]-|-',
              '#eval input' => array(
                'token_rules_input_evaluator' => array(
                  'uid_param' => array(
                    '0' => 'comment_author',
                  ),
                  'uid_target_param' => array(
                    '0' => 'node_author',
                  ),
                  'nid_param' => array(
                    '0' => 'node',
                  ),
                  'variables_param' => array(
                    '0' => 'comment',
                    '1' => 'comment_author',
                    '2' => 'node',
                  ),
                ),
              ),
            ),
            '#type' => 'action',
          ),
        ),
        '#version' => 6003,
      ),
      'og_activity_rules_1' => array(
        '#type' => 'rule',
        '#set' => 'event_og_become_co_admin',
        '#categories' => array(
          '0' => 'og_activity',
          '1' => 'heartbeat',
          'ecenter_dashboard' => 'ecenter_dashboard',
        ),
        '#label' => 'User becomes co-admin of a group',
        '#active' => 0,
        '#weight' => '0',
        '#status' => 'default',
        '#conditions' => array(),
        '#actions' => array(
          '0' => array(
            '#weight' => 1,
            '#info' => array(
              'label' => 'Logs user activity for single users',
              'eval input' => array(
                '0' => 'uid_param',
                '1' => 'uid_target_param',
                '2' => 'nid_param',
                '3' => 'nid_target_param',
                '4' => 'message_id_param',
                '5' => 'variables_param',
              ),
              'module' => 'heartbeat',
            ),
            '#name' => 'heartbeat_rules_default_action',
            '#settings' => array(
              'uid_param' => '[user:uid]',
              'uid_target_param' => '0',
              'nid_param' => '[node:nid]',
              'nid_target_param' => '[node:og-id]',
              'message_id_param' => 'og_become_co_admin',
              'variables_param' => '@username=|=[user:user-name-url]-|-@group=|=[node:title-link]-|-',
              '#eval input' => array(
                'token_rules_input_evaluator' => array(
                  'uid_param' => array(
                    '0' => 'user',
                  ),
                  'nid_param' => array(
                    '0' => 'node',
                  ),
                  'nid_target_param' => array(
                    '0' => 'node',
                  ),
                  'variables_param' => array(
                    '0' => 'node',
                    '1' => 'user',
                  ),
                ),
              ),
            ),
            '#type' => 'action',
          ),
        ),
        '#version' => 6003,
      ),
    ),
  );
}
*/
