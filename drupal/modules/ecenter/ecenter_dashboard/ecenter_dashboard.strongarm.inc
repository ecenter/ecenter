<?php

/**
 * Implementation of hook_strongarm().
 */
function ecenter_dashboard_strongarm() {
  $export = array();
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_access_types';
  $strongarm->value = array(
    'privateheartbeat' => array(
      'name' => 'Personal Heartbeat',
      'class' => 'PrivateHeartbeat',
      'path' => 'includes/privateheartbeat.inc',
      'module' => 'heartbeat',
      'access' => array(
        0 => 'view personal heartbeat activity',
      ),
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'publicheartbeat' => array(
      'name' => 'Public Heartbeat',
      'class' => 'PublicHeartbeat',
      'path' => 'includes/publicheartbeat.inc',
      'module' => 'heartbeat',
      'access' => TRUE,
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'singleheartbeat' => array(
      'name' => 'Single activity',
      'class' => 'SingleHeartbeat',
      'path' => 'includes/singleheartbeat.inc',
      'module' => 'heartbeat',
      'access' => TRUE,
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'ogheartbeat' => array(
      'name' => 'Organic group activity',
      'class' => 'OgHeartbeat',
      'path' => 'ogheartbeat.inc',
      'module' => 'og_activity',
      'access' => 1,
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'groupsactivity' => array(
      'name' => 'Organic groups activity',
      'class' => 'GroupsActivity',
      'path' => 'groupsactivity.inc',
      'module' => 'og_activity',
      'access' => 1,
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'membersactivity' => array(
      'name' => 'Organic group member activity',
      'class' => 'MembersActivity',
      'path' => 'membersactivity.inc',
      'module' => 'og_activity',
      'access' => 1,
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
      ),
      'poll_messages' => 0,
    ),
    'connectedheartbeat' => array(
      'name' => 'Heartbeat relational activity',
      'class' => 'ConnectedHeartbeat',
      'path' => 'connectedheartbeat.inc',
      'module' => 'friendlist_activity',
      'access' => 'user_is_logged_in',
      'status' => 'default',
      'messages_denied' => array(),
      'display_filters' => 0,
      'display_block_filters' => 0,
      'filters' => array(),
      'filters_cumul' => 0,
      'settings' => array(
        'block_items_max' => 10,
        'block_show_pager' => 2,
        'page_items_max' => 15,
        'page_show_pager' => 1,
        'page_pager_ajax' => 1,
        'num_load_max' => 30,
        'page_disabled' => 0,
        'skip_active_user' => 0,
      ),
      'poll_messages' => 0,
    ),
  );

  $export['heartbeat_access_types'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_display_tags';
  $strongarm->value = 0;

  $export['heartbeat_activity_display_tags'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_grouping_how_many';
  $strongarm->value = '5';

  $export['heartbeat_activity_grouping_how_many'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_grouping_seconds';
  $strongarm->value = '7200';

  $export['heartbeat_activity_grouping_seconds'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_log_cron_delete';
  $strongarm->value = '7948800';

  $export['heartbeat_activity_log_cron_delete'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_stream_actor_delete';
  $strongarm->value = 1;

  $export['heartbeat_activity_stream_actor_delete'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_activity_stream_delete';
  $strongarm->value = 1;

  $export['heartbeat_activity_stream_delete'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_add_og_admins_to_personal';
  $strongarm->value = TRUE;

  $export['heartbeat_add_og_admins_to_personal'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_add_og_members_to_personal';
  $strongarm->value = TRUE;

  $export['heartbeat_add_og_members_to_personal'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_add_og_related_to_personal';
  $strongarm->value = TRUE;

  $export['heartbeat_add_og_related_to_personal'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_allowed_tags';
  $strongarm->value = 'h1,h2,h3,h4,h5,h6,a,span,em,strong,ul,li,p,div,img,blockquote';

  $export['heartbeat_allowed_tags'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_context_perm';
  $strongarm->value = 0;

  $export['heartbeat_context_perm'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_enabled';
  $strongarm->value = 1;

  $export['heartbeat_enabled'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_filters';
  $strongarm->value = array(
    'all' => array(
      'name' => 'All',
    ),
  );

  $export['heartbeat_filters'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_profile_message_templates';
  $strongarm->value = array();

  $export['heartbeat_profile_message_templates'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_show_message_times';
  $strongarm->value = 1;

  $export['heartbeat_show_message_times'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'heartbeat_show_time_grouped_items';
  $strongarm->value = 1;

  $export['heartbeat_show_time_grouped_items'] = $strongarm;
  return $export;
}
