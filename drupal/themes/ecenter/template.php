<?php
// $Id$

/**
 * @file
 * The E-center theme.
 */
function ecenter_theme() {
  $path = drupal_get_path('theme', 'ecenter') .'/tpl';
  return array(
    'wiki_node_form' => array('arguments' => array('form' => NULL), 'template' => 'wiki-node-form', 'path' => $path),
    'insert_multiple_values' => array('arguments' => array('element' => NULL)),
  );
}

/**
 * Preprocess page
 */
function ecenter_preprocess_page(&$vars) {
  if (drupal_is_front_page()) {
    unset($vars['breadcrumb']);
  }
}

function ecenter_preprocess_wiki_node_form(&$vars) {
  $form = $vars['form'];

  //dpm($form);

  // Render some elements individually
  $vars['title'] = drupal_render($form['title']);
  $vars['buttons'] = drupal_render($form['buttons']);
  $vars['image_attachments'] = drupal_render($form['field_image']);
  $vars['body'] = drupal_render($form['body_field']);

  // Catch all
  $vars['form'] = drupal_render($form);
}

function ecenter_insert_multiple_values($element) {
  return drupal_render($element);
}

/**
 * Implementation of wikitools create -- but why did they use a theme fn for
 * this?
 */
function ecenter_wikitools_create($page_name) {
  $node_types = wikitools_node_types();
  $form = array();
  $output = '';
  if (wikitools_node_creation() && count($node_types)) {
    $output .= '<p>'. t('You can create the page as:') .'</p>';
    // Collapse the forms initially if there are more than one.
    $collapsed = count($node_types) > 1 ? ' collapsed' : '';

    // Use path to generate title and set path
    $page_name_split = explode('/', $page_name);

    // If link looks like a link, fill in path and disable pathauto; otherwise
    // revert to default behavior
    $count = 0;
    if (($count = count($page_name_split)) && $count > 1) {
      $name = $page_name_split[$count - 1];
      $name = ucfirst(str_replace(array('-', '_'), ' ', $name));
      $_GET['edit']['title'] = $name;
      $_GET['edit']['path']['path'] = variable_get('wikitools_path', 'wiki') .'/'. $page_name;
      $_GET['edit']['path']['pathauto_perform_alias'] = 0;
    }
    else {
      $_GET['edit']['title'] = ucfirst($page_name);
    }

    if (module_exists('nodehierarchy') && $count > 1) {
      array_unshift($page_name_split, variable_get('wikitools_path', 'wiki'));
      array_pop($page_name_split);
      $path = implode('/', $page_name_split);
      $path = drupal_lookup_path('source', $path);
      if ($path) {
        $nid = array_pop(explode('/', $path));
        $_GET['edit']['parent'] = $nid;
      }
    }

    foreach ($node_types as $type) {
      drupal_add_js('misc/collapse.js');
      $type = node_get_types('type', $type);
      if (node_access('create', $type->type)) {
        if ($router_item = menu_get_item('node/add/'. str_replace('_', '-', $type->type))) {
          if ($router_item['file']) {
            require_once($router_item['file']);
          }
          $output .= call_user_func_array($router_item['page_callback'], $router_item['page_arguments']);
        }
      }
    }
    // Some of the callbacks could have set the page title, so we reset it.
    drupal_set_title(t('Page does not exist: %page', array('%page' => $page_name)));
  }
  return $output;
}
