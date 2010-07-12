<?php
// $Id$

/**
 * Central AJAX dispatch function for driving RESTful web service.
 *
 * Takes URIs of the form:
 * {js/nojs}/{dispatch_function}/{optional_args}
 * and returns rendered data for use in the E-Center web app.
 *
 * It is up to dispatch functions to decide what to do about missing arguments.
 *
 * The first argument pass to all dispatch functions is an instance of the 
 * webservice client.
 *
 * The second argument passed to all dispatch functions is a sanitized version 
 * of the entire $_GET array.  This is to pass along query string arguments to
 * parse, process, or simply pass on to the backend service.
 */
function ecenter_weathermap_ajax($js = 'nojs', $dispatch='') {
  if (empty($dispatch) || ($js != 'js' && $js != 'nojs')) {
    drupal_not_found();
  }

  // Simple slugify of dispatch
  $dispatch = str_replace('-', '_', $dispatch);

  $args = func_get_args();
  unset($args[0], $args[1]); // Unset first two args
  array_unshift($args, ecenter_weathermap_sanitize_get()); // Add _GET as first argument
  array_unshift($args, ecenter_weathermap_get_client());

  $output = call_user_func_array("ecenter_weathermap_ajax_$dispatch", $args);

  if ($js == 'js') {
    echo $output;
    exit();
  }
  return $output;
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

    $form = ecenter_weathermap_select_form(array(), array());
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
