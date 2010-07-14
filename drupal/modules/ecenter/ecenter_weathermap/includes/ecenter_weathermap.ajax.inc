<?php
// $Id$

/**
 * Central AJAX dispatch function for driving RESTful web service.
 *
 * POST to this...
 */
function ecenter_weathermap_ajax() {
  /*$form_state = array('storage' =>  NULL, 'rebuild' => TRUE);
  $form_build_id = $_POST['form_build_id'];
  $form = form_get_cache($form_build_id, $form_state);
  $args = $form['#parameters'];
  $form_id = $_POST['form_id'];
  $form['#post'] = $_POST;
  $form['#redirect'] = FALSE;
  $form['#programmed'] = TRUE;
  $form_state['post'] = $_POST;
  $form_state['values'] = $_POST;
  drupal_process_form($form_id, $form, $form_state);
  form_execute_handlers('submit', $form, $form_state);
  $form = drupal_rebuild_form($form_id, $form_state, $args, $form_build_id);
  print drupal_render($form['dst_ip']);
  exit();*/
  print 'foo bar';
  exit();
}

/**
 * Get hubs
 */
function ecenter_weathermap_ajax_hub_select($client, $filter, $src_ip = '') {
  $data = $client->getHubs($src_ip);
  if ($data['code'] == 200) {
    $options = array();
    foreach ($data['response'] as $hop) {
      $options[] = theme('ecenter_weathermap_hop_option', $hop);
    }

    $form_state = array();
    $form = ecenter_weathermap_select_form($form_state);
    $element = $form['dst_ip'];
    $element['#options'] = $options;
    $element['#name'] = 'dst_ip';
    $element['#id'] = 'edit-dst-ip';
    $element['#parents'] = array();
    $output = theme('quickselect', $element);
  }
  return $output;
}

/**
 * Get data
 */
function ecenter_weathermap_ajax_data($client, $filter) {
  extract($client->getData('131.243.24.11', '198.32.44.130', '2010-07-02 10:01:02', '2010-07-09 11:02:01'));
  $data = _ecenter_weathermap_object_to_array($response);

  // Traceroute should be split from everything else
  $traceroutes = $data['traceroute'];
  unset($data['traceroute']);

  foreach ($traceroutes as $tid => $traceroute) {
    // Add source / dst to traceroute
    //
  }

  // Visualize / theme FIRST traceroute
  //$traceroute = theme('ecenter_weathermap_traceroute', $response->traceroute[0]);
  return theme('ecenter_weathermap', $traceroute);
}

// Traverse an object, turning all members into arrays or preserving their
// values
function _ecenter_weathermap_object_to_array($obj) {
  if (is_object($obj)) {
    $obj = get_object_vars($obj);
  }
  foreach ($obj as $k => $v) {
    if (is_object($v) || is_array($v)) {
      $obj[$k] = _ecenter_weathermap_object_to_array($v);
    }
    else {
      $obj[$k] = $v;
    }
  }
  return $obj;
}
