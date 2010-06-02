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
  // Hello, world.
  if (drupal_is_front_page()) {
    unset($vars['breadcrumb']);
  }
  dsm('testing...');
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
