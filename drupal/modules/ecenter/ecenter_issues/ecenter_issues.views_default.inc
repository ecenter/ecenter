<?php

/**
 * Implementation of hook_views_default_views().
 */
function ecenter_issues_views_default_views() {
  $views = array();

  // Exported view: ecenter_issues
  $view = new view;
  $view->name = 'ecenter_issues';
  $view->description = 'E-Center issues';
  $view->tag = 'ecenter';
  $view->base_table = 'node';
  $view->human_name = '';
  $view->core = 0;
  $view->api_version = '3.0-alpha1';
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */

  /* Display: Defaults */
  $handler = $view->new_display('default', 'Defaults', 'default');
  $handler->display->display_options['title'] = 'Network issues';
  $handler->display->display_options['access']['type'] = 'none';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['query']['type'] = 'views_query';
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['exposed_form']['options']['reset_button'] = TRUE;
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['pager']['options']['items_per_page'] = '20';
  $handler->display->display_options['pager']['options']['offset'] = '0';
  $handler->display->display_options['pager']['options']['id'] = '0';
  $handler->display->display_options['style_plugin'] = 'semanticviews_default';
  $handler->display->display_options['style_options']['row']['class'] = 'row clearfix';
  $handler->display->display_options['row_plugin'] = 'semanticviews_fields';
  $handler->display->display_options['row_options']['skip_blank'] = 1;
  $handler->display->display_options['row_options']['semantic_html'] = array(
    'title' => array(
      'element_type' => 'h3',
      'class' => 'title',
    ),
    'field_issue_query_nid' => array(
      'element_type' => 'div',
      'class' => 'query',
    ),
    'body' => array(
      'element_type' => 'div',
      'class' => 'body',
    ),
    'picture' => array(
      'element_type' => 'span',
      'class' => 'user-picture',
    ),
    'name' => array(
      'element_type' => 'span',
      'class' => 'post-author',
      'label_element_type' => 'label',
      'label_class' => '',
    ),
    'created' => array(
      'element_type' => 'span',
      'class' => 'posted',
    ),
    'changed' => array(
      'element_type' => 'span',
      'class' => 'updated clear-right',
      'label_element_type' => 'label',
      'label_class' => '',
    ),
    'comment_count' => array(
      'element_type' => 'span',
      'class' => 'comment-count',
    ),
    'last_comment_name' => array(
      'element_type' => 'span',
      'class' => 'last-comment',
      'label_element_type' => 'label',
      'label_class' => '',
    ),
    'last_comment_timestamp' => array(
      'element_type' => 'span',
      'class' => 'last-comment-time',
    ),
    'new_comments' => array(
      'element_type' => 'span',
      'class' => 'new-comments',
    ),
  );
  $handler->display->display_options['exposed_block'] = TRUE;
  /* Relationship: Content: Query (field_issue_query) */
  $handler->display->display_options['relationships']['field_issue_query_nid']['id'] = 'field_issue_query_nid';
  $handler->display->display_options['relationships']['field_issue_query_nid']['table'] = 'node_data_field_issue_query';
  $handler->display->display_options['relationships']['field_issue_query_nid']['field'] = 'field_issue_query_nid';
  $handler->display->display_options['relationships']['field_issue_query_nid']['required'] = 0;
  $handler->display->display_options['relationships']['field_issue_query_nid']['delta'] = '-1';
  /* Field: Node: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['title']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['title']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['title']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['title']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['title']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['title']['alter']['html'] = 0;
  $handler->display->display_options['fields']['title']['hide_empty'] = 0;
  $handler->display->display_options['fields']['title']['empty_zero'] = 0;
  $handler->display->display_options['fields']['title']['link_to_node'] = 1;
  /* Field: Content: Query (field_issue_query) */
  $handler->display->display_options['fields']['field_issue_query_nid']['id'] = 'field_issue_query_nid';
  $handler->display->display_options['fields']['field_issue_query_nid']['table'] = 'node_data_field_issue_query';
  $handler->display->display_options['fields']['field_issue_query_nid']['field'] = 'field_issue_query_nid';
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['alter']['html'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['hide_empty'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['empty_zero'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['link_to_node'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['label_type'] = 'none';
  $handler->display->display_options['fields']['field_issue_query_nid']['format'] = 'query_link';
  $handler->display->display_options['fields']['field_issue_query_nid']['multiple']['group'] = 0;
  $handler->display->display_options['fields']['field_issue_query_nid']['multiple']['multiple_reversed'] = 0;
  /* Field: Node: Body */
  $handler->display->display_options['fields']['body']['id'] = 'body';
  $handler->display->display_options['fields']['body']['table'] = 'node_revisions';
  $handler->display->display_options['fields']['body']['field'] = 'body';
  $handler->display->display_options['fields']['body']['label'] = '';
  $handler->display->display_options['fields']['body']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['body']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['body']['alter']['trim'] = 1;
  $handler->display->display_options['fields']['body']['alter']['max_length'] = '200';
  $handler->display->display_options['fields']['body']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['body']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['body']['alter']['strip_tags'] = 1;
  $handler->display->display_options['fields']['body']['alter']['html'] = 1;
  $handler->display->display_options['fields']['body']['hide_empty'] = 0;
  $handler->display->display_options['fields']['body']['empty_zero'] = 0;
  /* Field: User: Picture */
  $handler->display->display_options['fields']['picture']['id'] = 'picture';
  $handler->display->display_options['fields']['picture']['table'] = 'users';
  $handler->display->display_options['fields']['picture']['field'] = 'picture';
  $handler->display->display_options['fields']['picture']['label'] = '';
  $handler->display->display_options['fields']['picture']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['word_boundary'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['ellipsis'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['html'] = 0;
  $handler->display->display_options['fields']['picture']['hide_empty'] = 0;
  $handler->display->display_options['fields']['picture']['empty_zero'] = 0;
  /* Field: User: Name */
  $handler->display->display_options['fields']['name']['id'] = 'name';
  $handler->display->display_options['fields']['name']['table'] = 'users';
  $handler->display->display_options['fields']['name']['field'] = 'name';
  $handler->display->display_options['fields']['name']['label'] = 'By';
  $handler->display->display_options['fields']['name']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['name']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['name']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['name']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['name']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['name']['alter']['html'] = 0;
  $handler->display->display_options['fields']['name']['hide_empty'] = 0;
  $handler->display->display_options['fields']['name']['empty_zero'] = 0;
  $handler->display->display_options['fields']['name']['link_to_user'] = 1;
  $handler->display->display_options['fields']['name']['overwrite_anonymous'] = 0;
  /* Field: Node: Post date */
  $handler->display->display_options['fields']['created']['id'] = 'created';
  $handler->display->display_options['fields']['created']['table'] = 'node';
  $handler->display->display_options['fields']['created']['field'] = 'created';
  $handler->display->display_options['fields']['created']['label'] = '';
  $handler->display->display_options['fields']['created']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['created']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['created']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['created']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['created']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['created']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['created']['alter']['html'] = 0;
  $handler->display->display_options['fields']['created']['hide_empty'] = 0;
  $handler->display->display_options['fields']['created']['empty_zero'] = 0;
  /* Field: Node: Updated date */
  $handler->display->display_options['fields']['changed']['id'] = 'changed';
  $handler->display->display_options['fields']['changed']['table'] = 'node';
  $handler->display->display_options['fields']['changed']['field'] = 'changed';
  $handler->display->display_options['fields']['changed']['label'] = 'Last updated';
  $handler->display->display_options['fields']['changed']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['changed']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['changed']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['changed']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['changed']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['changed']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['changed']['alter']['html'] = 0;
  $handler->display->display_options['fields']['changed']['hide_empty'] = 1;
  $handler->display->display_options['fields']['changed']['empty_zero'] = 0;
  /* Field: Node: Comment count */
  $handler->display->display_options['fields']['comment_count']['id'] = 'comment_count';
  $handler->display->display_options['fields']['comment_count']['table'] = 'node_comment_statistics';
  $handler->display->display_options['fields']['comment_count']['field'] = 'comment_count';
  $handler->display->display_options['fields']['comment_count']['label'] = '';
  $handler->display->display_options['fields']['comment_count']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['comment_count']['alter']['text'] = '[comment_count] comments';
  $handler->display->display_options['fields']['comment_count']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['comment_count']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['comment_count']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['comment_count']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['comment_count']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['comment_count']['alter']['html'] = 0;
  $handler->display->display_options['fields']['comment_count']['hide_empty'] = 0;
  $handler->display->display_options['fields']['comment_count']['empty_zero'] = 0;
  /* Field: Node: Last comment author */
  $handler->display->display_options['fields']['last_comment_name']['id'] = 'last_comment_name';
  $handler->display->display_options['fields']['last_comment_name']['table'] = 'node_comment_statistics';
  $handler->display->display_options['fields']['last_comment_name']['field'] = 'last_comment_name';
  $handler->display->display_options['fields']['last_comment_name']['label'] = 'Last comment';
  $handler->display->display_options['fields']['last_comment_name']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['last_comment_name']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['last_comment_name']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['alter']['html'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['hide_empty'] = 0;
  $handler->display->display_options['fields']['last_comment_name']['empty_zero'] = 0;
  /* Field: Node: Last comment time */
  $handler->display->display_options['fields']['last_comment_timestamp']['id'] = 'last_comment_timestamp';
  $handler->display->display_options['fields']['last_comment_timestamp']['table'] = 'node_comment_statistics';
  $handler->display->display_options['fields']['last_comment_timestamp']['field'] = 'last_comment_timestamp';
  $handler->display->display_options['fields']['last_comment_timestamp']['label'] = '';
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['alter']['html'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['hide_empty'] = 0;
  $handler->display->display_options['fields']['last_comment_timestamp']['empty_zero'] = 0;
  /* Field: Node: New comments */
  $handler->display->display_options['fields']['new_comments']['id'] = 'new_comments';
  $handler->display->display_options['fields']['new_comments']['table'] = 'node';
  $handler->display->display_options['fields']['new_comments']['field'] = 'new_comments';
  $handler->display->display_options['fields']['new_comments']['label'] = '';
  $handler->display->display_options['fields']['new_comments']['alter']['alter_text'] = 1;
  $handler->display->display_options['fields']['new_comments']['alter']['text'] = 'new comments';
  $handler->display->display_options['fields']['new_comments']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['new_comments']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['new_comments']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['new_comments']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['new_comments']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['new_comments']['alter']['html'] = 0;
  $handler->display->display_options['fields']['new_comments']['hide_empty'] = 1;
  $handler->display->display_options['fields']['new_comments']['empty_zero'] = 0;
  $handler->display->display_options['fields']['new_comments']['link_to_comment'] = 1;
  /* Sort criterion: Node: Last comment time */
  $handler->display->display_options['sorts']['last_comment_timestamp']['id'] = 'last_comment_timestamp';
  $handler->display->display_options['sorts']['last_comment_timestamp']['table'] = 'node_comment_statistics';
  $handler->display->display_options['sorts']['last_comment_timestamp']['field'] = 'last_comment_timestamp';
  $handler->display->display_options['sorts']['last_comment_timestamp']['order'] = 'DESC';
  $handler->display->display_options['sorts']['last_comment_timestamp']['exposed'] = TRUE;
  $handler->display->display_options['sorts']['last_comment_timestamp']['expose']['label'] = 'Node: Last comment time';
  $handler->display->display_options['sorts']['last_comment_timestamp']['granularity'] = 'minute';
  /* Sort criterion: Node: Post date */
  $handler->display->display_options['sorts']['created']['id'] = 'created';
  $handler->display->display_options['sorts']['created']['table'] = 'node';
  $handler->display->display_options['sorts']['created']['field'] = 'created';
  $handler->display->display_options['sorts']['created']['order'] = 'DESC';
  $handler->display->display_options['sorts']['created']['exposed'] = TRUE;
  $handler->display->display_options['sorts']['created']['expose']['label'] = 'Node: Post date';
  /* Sort criterion: Node: Updated date */
  $handler->display->display_options['sorts']['changed']['id'] = 'changed';
  $handler->display->display_options['sorts']['changed']['table'] = 'node';
  $handler->display->display_options['sorts']['changed']['field'] = 'changed';
  $handler->display->display_options['sorts']['changed']['order'] = 'DESC';
  $handler->display->display_options['sorts']['changed']['exposed'] = TRUE;
  $handler->display->display_options['sorts']['changed']['expose']['label'] = 'Node: Updated date';
  /* Filter: Node: Published */
  $handler->display->display_options['filters']['status']['id'] = 'status';
  $handler->display->display_options['filters']['status']['table'] = 'node';
  $handler->display->display_options['filters']['status']['field'] = 'status';
  $handler->display->display_options['filters']['status']['value'] = '1';
  /* Filter: Node: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'issue' => 'issue',
  );
  /* Filter: User: Name */
  $handler->display->display_options['filters']['uid']['id'] = 'uid';
  $handler->display->display_options['filters']['uid']['table'] = 'users';
  $handler->display->display_options['filters']['uid']['field'] = 'uid';
  $handler->display->display_options['filters']['uid']['value'] = '';
  $handler->display->display_options['filters']['uid']['exposed'] = TRUE;
  $handler->display->display_options['filters']['uid']['expose']['operator'] = 'uid_op';
  $handler->display->display_options['filters']['uid']['expose']['limit_operators'] = array();
  $handler->display->display_options['filters']['uid']['expose']['label'] = 'Poster';
  $handler->display->display_options['filters']['uid']['expose']['identifier'] = 'uid';
  $handler->display->display_options['filters']['uid']['expose']['reduce'] = 0;
  /* Filter: Content: Source Hub (field_query_src_hub) */
  $handler->display->display_options['filters']['field_query_src_hub_value']['id'] = 'field_query_src_hub_value';
  $handler->display->display_options['filters']['field_query_src_hub_value']['table'] = 'node_data_field_query_src_hub';
  $handler->display->display_options['filters']['field_query_src_hub_value']['field'] = 'field_query_src_hub_value';
  $handler->display->display_options['filters']['field_query_src_hub_value']['relationship'] = 'field_issue_query_nid';
  $handler->display->display_options['filters']['field_query_src_hub_value']['exposed'] = TRUE;
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['operator'] = 'field_query_src_hub_value_op';
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['limit_operators'] = array();
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['label'] = 'Source';
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['identifier'] = 'src_hub';
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['optional'] = TRUE;
  $handler->display->display_options['filters']['field_query_src_hub_value']['expose']['single'] = TRUE;
  $handler->display->display_options['filters']['field_query_src_hub_value']['case'] = 0;
  /* Filter: Content: Destination Hub (field_query_dst_hub) */
  $handler->display->display_options['filters']['field_query_dst_hub_value']['id'] = 'field_query_dst_hub_value';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['table'] = 'node_data_field_query_dst_hub';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['field'] = 'field_query_dst_hub_value';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['relationship'] = 'field_issue_query_nid';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['exposed'] = TRUE;
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['operator'] = 'field_query_dst_hub_value_op';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['limit_operators'] = array();
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['label'] = 'Destination';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['identifier'] = 'dst_hub';
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['optional'] = TRUE;
  $handler->display->display_options['filters']['field_query_dst_hub_value']['expose']['single'] = TRUE;
  $handler->display->display_options['filters']['field_query_dst_hub_value']['case'] = 0;

  /* Display: Page */
  $handler = $view->new_display('page', 'Page', 'page_1');
  $handler->display->display_options['path'] = 'issues';
  $handler->display->display_options['menu']['type'] = 'normal';
  $handler->display->display_options['menu']['title'] = 'View issues';
  $handler->display->display_options['menu']['weight'] = '15';
  $handler->display->display_options['menu']['name'] = 'primary-links';
  $translatables['ecenter_issues'] = array(
    t('Defaults'),
    t('Network issues'),
    t('more'),
    t('Apply'),
    t('Reset'),
    t('Sort By'),
    t('Asc'),
    t('Desc'),
    t('Items per page'),
    t('- All -'),
    t('Offset'),
    t('Query'),
    t('By'),
    t('Last updated'),
    t('[comment_count] comments'),
    t('.'),
    t(','),
    t('Last comment'),
    t('new comments'),
    t('Node: Last comment time'),
    t('Node: Post date'),
    t('Node: Updated date'),
    t('Poster'),
    t('Source'),
    t('Destination'),
    t('Page'),
  );

  $views[$view->name] = $view;

  return $views;
}
