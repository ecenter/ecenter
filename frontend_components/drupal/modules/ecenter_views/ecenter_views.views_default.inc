<?php
// $Id$

/**
 * @file
 * Views for E-Center project.
 */

/**
 * Implementation of hook_views_default_views().
 */
function ecenter_views_views_default_views() {
  /*
   * View 'ecenter_issues'
   */
  $view = new view;
  $view->name = 'ecenter_issues';
  $view->description = 'E-center: Issues';
  $view->tag = 'e-center';
  $view->view_php = '';
  $view->base_table = 'node';
  $view->is_cacheable = FALSE;
  $view->api_version = 3.0-alpha1;
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
/* Display: Defaults */
  $handler = $view->new_display('default', 'Defaults', 'default');
  $handler->display->display_options['access']['type'] = 'none';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['style_plugin'] = 'semanticviews_default';
  $handler->display->display_options['style_options']['grouping'] = 'title';
  $handler->display->display_options['style_options']['row']['class'] = 'row';
  $handler->display->display_options['row_plugin'] = 'semanticviews_fields';
  $handler->display->display_options['row_options']['skip_blank'] = 1;
  $handler->display->display_options['row_options']['semantic_html'] = array(
    'body' => array(
      'element_type' => 'div',
      'class' => 'node-body',
    ),
    'name' => array(
      'element_type' => 'div',
      'class' => 'author',
      'label_element_type' => 'label',
      'label_class' => '',
    ),
    'comment' => array(
      'element_type' => 'div',
      'class' => 'comment-body',
    ),
  );
  /* Header: Global: Text area */
  $handler->display->display_options['header']['area']['id'] = 'area';
  $handler->display->display_options['header']['area']['table'] = 'views';
  $handler->display->display_options['header']['area']['field'] = 'area';
  $handler->display->display_options['header']['area']['label'] = '';
  $handler->display->display_options['header']['area']['empty'] = TRUE;
  $handler->display->display_options['header']['area']['content'] = '<div class="messages">
<p>This is the issue tracker for E-center, and is under construction.  For the project issue tracker, visit <a href="http://code.google.com/p/ecenter/issues/">http://code.google.com/p/ecenter/issues/</a>.</p>
</div>';
  $handler->display->display_options['header']['area']['format'] = '2';
  /* Relationship: Node: Representative comment */
  $handler->display->display_options['relationships']['cid_representative']['id'] = 'cid_representative';
  $handler->display->display_options['relationships']['cid_representative']['table'] = 'node';
  $handler->display->display_options['relationships']['cid_representative']['field'] = 'cid_representative';
  $handler->display->display_options['relationships']['cid_representative']['label'] = 'Representative node';
  $handler->display->display_options['relationships']['cid_representative']['required'] = 0;
  $handler->display->display_options['relationships']['cid_representative']['subquery_sort'] = 'comments.timestamp';
  $handler->display->display_options['relationships']['cid_representative']['subquery_order'] = 'ASC';
  $handler->display->display_options['relationships']['cid_representative']['subquery_regenerate'] = 1;
  $handler->display->display_options['relationships']['cid_representative']['subquery_view'] = 'ecenter_issues_fixed_comment';
  $handler->display->display_options['relationships']['cid_representative']['subquery_namespace'] = '';
  /* Relationship: Comment: User */
  $handler->display->display_options['relationships']['uid']['id'] = 'uid';
  $handler->display->display_options['relationships']['uid']['table'] = 'comments';
  $handler->display->display_options['relationships']['uid']['field'] = 'uid';
  $handler->display->display_options['relationships']['uid']['relationship'] = 'cid_representative';
  $handler->display->display_options['relationships']['uid']['required'] = 0;
  /* Field: Node: Title */
  $handler->display->display_options['fields']['title']['id'] = 'title';
  $handler->display->display_options['fields']['title']['table'] = 'node';
  $handler->display->display_options['fields']['title']['field'] = 'title';
  $handler->display->display_options['fields']['title']['label'] = '';
  $handler->display->display_options['fields']['title']['exclude'] = TRUE;
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
  /* Field: User: Picture */
  $handler->display->display_options['fields']['picture']['id'] = 'picture';
  $handler->display->display_options['fields']['picture']['table'] = 'users';
  $handler->display->display_options['fields']['picture']['field'] = 'picture';
  $handler->display->display_options['fields']['picture']['label'] = '';
  $handler->display->display_options['fields']['picture']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['picture']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['picture']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['picture']['alter']['html'] = 0;
  $handler->display->display_options['fields']['picture']['hide_empty'] = 0;
  $handler->display->display_options['fields']['picture']['empty_zero'] = 0;
  $handler->display->display_options['fields']['picture']['imagecache_preset'] = 'user_thumb_medium';
  /* Field: Node: Body */
  $handler->display->display_options['fields']['body']['id'] = 'body';
  $handler->display->display_options['fields']['body']['table'] = 'node_revisions';
  $handler->display->display_options['fields']['body']['field'] = 'body';
  $handler->display->display_options['fields']['body']['label'] = '';
  $handler->display->display_options['fields']['body']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['body']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['body']['alter']['trim'] = 1;
  $handler->display->display_options['fields']['body']['alter']['max_length'] = '250';
  $handler->display->display_options['fields']['body']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['body']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['body']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['body']['alter']['html'] = 0;
  $handler->display->display_options['fields']['body']['hide_empty'] = 0;
  $handler->display->display_options['fields']['body']['empty_zero'] = 0;
  /* Field: Comment: Author */
  $handler->display->display_options['fields']['name']['id'] = 'name';
  $handler->display->display_options['fields']['name']['table'] = 'comments';
  $handler->display->display_options['fields']['name']['field'] = 'name';
  $handler->display->display_options['fields']['name']['relationship'] = 'cid_representative';
  $handler->display->display_options['fields']['name']['label'] = 'Fixed by';
  $handler->display->display_options['fields']['name']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['name']['alter']['text'] = 'Fixed by [name]';
  $handler->display->display_options['fields']['name']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['name']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['name']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['name']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['name']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['name']['alter']['html'] = 0;
  $handler->display->display_options['fields']['name']['hide_empty'] = 0;
  $handler->display->display_options['fields']['name']['empty_zero'] = 0;
  $handler->display->display_options['fields']['name']['link_to_user'] = 0;
  /* Field: User: Picture */
  $handler->display->display_options['fields']['picture_1']['id'] = 'picture_1';
  $handler->display->display_options['fields']['picture_1']['table'] = 'users';
  $handler->display->display_options['fields']['picture_1']['field'] = 'picture';
  $handler->display->display_options['fields']['picture_1']['relationship'] = 'uid';
  $handler->display->display_options['fields']['picture_1']['label'] = '';
  $handler->display->display_options['fields']['picture_1']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['picture_1']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['picture_1']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['picture_1']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['picture_1']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['picture_1']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['picture_1']['alter']['html'] = 0;
  $handler->display->display_options['fields']['picture_1']['hide_empty'] = 0;
  $handler->display->display_options['fields']['picture_1']['empty_zero'] = 0;
  $handler->display->display_options['fields']['picture_1']['imagecache_preset'] = 'user_thumb_medium';
  /* Field: Comment: Body */
  $handler->display->display_options['fields']['comment']['id'] = 'comment';
  $handler->display->display_options['fields']['comment']['table'] = 'comments';
  $handler->display->display_options['fields']['comment']['field'] = 'comment';
  $handler->display->display_options['fields']['comment']['relationship'] = 'cid_representative';
  $handler->display->display_options['fields']['comment']['label'] = '';
  $handler->display->display_options['fields']['comment']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['comment']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['comment']['alter']['trim'] = 1;
  $handler->display->display_options['fields']['comment']['alter']['max_length'] = '250';
  $handler->display->display_options['fields']['comment']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['comment']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['comment']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['comment']['alter']['html'] = 0;
  $handler->display->display_options['fields']['comment']['hide_empty'] = 0;
  $handler->display->display_options['fields']['comment']['empty_zero'] = 0;
  /* Sort criterion: Node: Updated date */
  $handler->display->display_options['sorts']['changed']['id'] = 'changed';
  $handler->display->display_options['sorts']['changed']['table'] = 'node';
  $handler->display->display_options['sorts']['changed']['field'] = 'changed';
  /* Filter: Node: Type */
  $handler->display->display_options['filters']['type']['id'] = 'type';
  $handler->display->display_options['filters']['type']['table'] = 'node';
  $handler->display->display_options['filters']['type']['field'] = 'type';
  $handler->display->display_options['filters']['type']['value'] = array(
    'issue' => 'issue',
  );
  
/* Display: Page */
  $handler = $view->new_display('page', 'Page', 'page_1');
  $handler->display->display_options['path'] = 'issues';
  $views[$view->name] = $view;

  /*
   * View 'ecenter_issues_fixed_comment'
   */
  $view = new view;
  $view->name = 'ecenter_issues_fixed_comment';
  $view->description = 'E-center: Issues - Fixed Comment Subquery';
  $view->tag = 'e-center';
  $view->view_php = '';
  $view->base_table = 'comments';
  $view->is_cacheable = FALSE;
  $view->api_version = 3.0-alpha1;
  $view->disabled = FALSE; /* Edit this to true to make a default view disabled initially */
  
/* Display: Defaults */
  $handler = $view->new_display('default', 'Defaults', 'default');
  $handler->display->display_options['access']['type'] = 'none';
  $handler->display->display_options['cache']['type'] = 'none';
  $handler->display->display_options['exposed_form']['type'] = 'basic';
  $handler->display->display_options['pager']['type'] = 'full';
  $handler->display->display_options['style_plugin'] = 'default';
  $handler->display->display_options['row_plugin'] = 'fields';
  /* Relationship: Flags: fixed */
  $handler->display->display_options['relationships']['flag_content_rel']['id'] = 'flag_content_rel';
  $handler->display->display_options['relationships']['flag_content_rel']['table'] = 'comments';
  $handler->display->display_options['relationships']['flag_content_rel']['field'] = 'flag_content_rel';
  /* Field: Comment: ID */
  $handler->display->display_options['fields']['cid']['id'] = 'cid';
  $handler->display->display_options['fields']['cid']['table'] = 'comments';
  $handler->display->display_options['fields']['cid']['field'] = 'cid';
  $handler->display->display_options['fields']['cid']['alter']['alter_text'] = 0;
  $handler->display->display_options['fields']['cid']['alter']['make_link'] = 0;
  $handler->display->display_options['fields']['cid']['alter']['trim'] = 0;
  $handler->display->display_options['fields']['cid']['alter']['word_boundary'] = 1;
  $handler->display->display_options['fields']['cid']['alter']['ellipsis'] = 1;
  $handler->display->display_options['fields']['cid']['alter']['strip_tags'] = 0;
  $handler->display->display_options['fields']['cid']['alter']['html'] = 0;
  $handler->display->display_options['fields']['cid']['hide_empty'] = 0;
  $handler->display->display_options['fields']['cid']['empty_zero'] = 0;
  $handler->display->display_options['fields']['cid']['link_to_comment'] = 1;
  /* Sort criterion: Comment: Post date */
  $handler->display->display_options['sorts']['timestamp']['id'] = 'timestamp';
  $handler->display->display_options['sorts']['timestamp']['table'] = 'comments';
  $handler->display->display_options['sorts']['timestamp']['field'] = 'timestamp';
  $handler->display->display_options['sorts']['timestamp']['order'] = 'DESC';
  $views[$view->name] = $view;

  return $views;
}
