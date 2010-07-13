<?php
// $Id$

/**
 * Central AJAX dispatch function for driving RESTful web service.
 *
 * POST to this...
 */
function ecenter_weathermap_ajax() {
  /*if (empty($dispatch) || ($js != 'js' && $js != 'nojs')) {
    drupal_not_found();
  }*/
  // Simple slugify of dispatch
  //$dispatch = str_replace('-', '_', $dispatch);

  /*$args = func_get_args();
  unset($args[0], $args[1]); // Unset first two args
  array_unshift($args, ecenter_weathermap_sanitize_get()); // Add _GET as first argument
  array_unshift($args, ecenter_weathermap_get_client());

  $output = call_user_func_array("ecenter_weathermap_ajax_$dispatch", $args);*/

  // We're starting in step #3, preparing for #4.
  $form_state = array('storage' => NULL, 'submitted' => FALSE);
  $form_build_id = $_POST['form_build_id'];
  // Step #4.
  $form = form_get_cache($form_build_id, $form_state);

  // Preparing for #5.
  $args = $form['#parameters'];
  $form_id = array_shift($args);
  $form_state['post'] = $form['#post'] = $_POST;
  $form['#programmed'] = $form['#redirect'] = FALSE;

  // Step #5.
  drupal_process_form($form_id, $form, $form_state);
  // Step #6 and #7 and #8.
  $form = drupal_rebuild_form($form_id, $form_state, $args, $form_build_id);

  // Step #9.
  //$choice_form = $form['choice_wrapper']['choice'];
  //unset($choice_form['#prefix'], $choice_form['#suffix']);
  //$output = theme('status_messages') . drupal_render($choice_form);

  // Final rendering callback.
  //drupal_json(array('status' => TRUE, 'data' => $output));

  $ouput = $form['src_ip'];
  $output .= '<pre>'. print_r($form, true) .'</pre>';
  /*$output .= '<pre>---</pre>';
  $output .= '<pre>'. print_r(array_keys($form), true) .'</pre>';*/
  echo $output;
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
