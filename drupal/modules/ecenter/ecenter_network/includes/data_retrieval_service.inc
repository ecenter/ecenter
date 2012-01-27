<?php

/**
 * E-center network health
 */
function ecenter_network_health() {
  $client = ecenter_network_get_client('503');

  extract(_ecenter_network_extract_query());

  if (!$start || !$end) {
    $inc = 30;
    module_load_include('inc', 'date_api', 'date_api_elements');
    $now = time();
    $start = date_make_date($now);
    $end = date_make_date($now);
    date_modify($start, '-24 hours');

    $utc = timezone_open('UTC');
    date_timezone_set($start, $utc);
    date_timezone_set($end, $utc);

    date_increment_round($start, $inc);
    date_increment_round($end, $inc);

    $start = date_format($start, 'Y-m-d H:i:s');
    $end = date_format($end, 'Y-m-d H:i:s');
  }

  $response = $client->getHealth($start, $end);
  if ($response['code'] == 200) {
    return theme('ecenter_network_health', $response['response'], $start, $end);
  }
  return 'this should be an error message';
}

/**
 * Get/cache data
 *
 * @param $src
 *   Source IP address
 * @param $dst
 *   Destination IP address
 * @param $start
 *   Start time, expressed in UTC, formatted as Y-m-d H:i:s
 * @param $end
 *   End time, expressed in UTC, formatted as Y-m-d H:i:s
 * @return
 *   An array of parsed data
 */
function ecenter_network_get_data($src, $dst, $start, $end) {
  $params = get_defined_vars();
  global $user;
  static $results = array();

  $query = http_build_query($params);

  if (!array_key_exists($query, $results)) {
    $caching = variable_get('ecenter_network_data_cache_enabled', 0);
    if ($caching && $result = cache_get($query, 'cache_ecenter_data')) {
      $results[$query] = $result->data;
    }
    else {
      $resolution = variable_get('ecenter_network_drs_resolution', 50);
      $client = ecenter_network_get_client();
      $result = $client->getData($src, $dst, $start, $end, $resolution);
      if ($result['code'] == 200) {
        $data = ecenter_network_parse_response($result);
        if ($caching) {
          $expires = time() + variable_get('ecenter_network_data_cache_ttl', 3600);
          cache_set($query, $data, 'cache_ecenter_data', $expires);
        }
        $results[$query] = $data;
      }
      else { // Note that the static variable is NOT set in this case
        watchdog('ecenter_network',
          'Request (@url) failed with code @code (@response).',
          array('@url' => $result['url'], '@code' => $result['code'],
          '@response' => $result['response']), WATCHDOG_WARNING);
        return NULL;
      }
    }

    // Remember user's last queries: Anonymous users queries are stored in
    // their session; authenticated users queries are stored along with their
    // user object. Only capture successful queries.
    if (!empty($results[$query]) && $user->uid > 0) {
      $queries = $user->ecenter_network_queries;
      if (count($queries) >
        (variable_get('ecenter_network_recent_query_limit', 5))) {
        array_shift($queries);
      }
      $queries[$query] = array('time' => time(), 'query' => $query);
      user_save($user, array('ecenter_network_queries' => $queries));
    }
    else if (!empty($results[$query]) && isset($_COOKIE[session_name()])) {
      $queries = unserialize(sess_read('ecenter_network_queries'));
      if (count($queries) >
        (variable_get('ecenter_network_recent_query_limit', 5) - 1)) {
        array_shift($queries);
      }
      $queries[$query] = array('time' => time(), 'query' => $query);
      sess_write('ecenter_network_queries', serialize($queries));
    }

  }
  return $results[$query];
}

/**
 * Get/cache traceroute data
 *
 * @param $traceroute
 *   Pasted traceroute
 * @param $start
 *   Start time, expressed in UTC, formatted as Y-m-d H:i:s
 * @param $end
 *   End time, expressed in UTC, formatted as Y-m-d H:i:s
 * @return
 *   An array of parsed data
 */
function ecenter_network_get_traceroute_data($traceroute, $start, $end) {
  global $user;
  $resolution = variable_get('ecenter_network_drs_resolution', 50);
  $client = ecenter_network_get_client();
  $result = $client->getTraceroute($traceroute, $start, $end, $resolution);

  switch ($result['code']) {
    case 200:
      return ecenter_network_parse_response($result);
    case 501:
      drupal_set_message(t('There was an error in your pasted traceroute. Please try again.'));
      return FALSE;
    default:
      drupal_set_message(t('The data retrieval service experienced an error.'));
      if (!empty($result['parameters'])) {
        drupal_set_message(t('Include this URL when reporting this error: <a href="@href">@href</a>', array('@href' => url('network', array('query' => $result['parameters'], 'absolute' => TRUE))))); 
      }
      watchdog('ecenter_network',
        'Request (@url) failed with code @code (@response).',
        array('@url' => $result['url'], '@code' => $result['code'],
        '@response' => $result['response']), WATCHDOG_WARNING);
      return FALSE;
  }
}

/**
 * Get hops
 *
 * @param $src
 *   (optional) Source (hub name or IP) to determine potential destinations.
 *   If not supplied, list all potential source hops.
 * @param $src_type
 *   (optional) Source type ('hub' or 'ip')
 * @return
 *   An array of hop objects.
 */
function ecenter_network_get_hops($src = NULL, $src_type = 'hub') {
  static $hops = array();
  $src_key = (!empty($src)) ? $src : 'sources';

  if (empty($hops[$src_key])) {
    $caching = variable_get('ecenter_network_hop_cache_enabled', 0);
    if ($caching && $result = cache_get($src_key, 'cache_ecenter_hops')) {
      $hops[$src_key] = $result->data;
    }
    else {
      $client = ecenter_network_get_client();
      $result = $client->getHops($src, $src_type);
      if ($result['code'] == 200) {
        $data = ecenter_network_parse_hops($result['response']);
        $hops[$src_key] = $data;
        if ($caching) {
          $expires = time() + variable_get('ecenter_network_hop_cache_ttl', 300);
          cache_set($src_key, $data, 'cache_ecenter_hops', $expires);
        }
      }
      else {
        drupal_set_message(t('Request (@url) failed with code @code (@response).', 
          array('@url' => $result['url'], '@code' => $result['code'], '@response' => $result['response'])));
      }
    }
  }
  return $hops[$src_key];
}

/**
 * Get node
 */
function ecenter_network_get_node($ip) {
  static $nodes = array();
  if (empty($nodes[$ip])) {
    $caching = variable_get('ecenter_network_node_cache_enabled', 0);
    if ($caching && $result = cache_get($ip, 'cache_ecenter_nodes')) {
      $nodes[$ip] = $result->data;
    }
    else {
      $client = ecenter_network_get_client();
      $result = $client->getNode($ip);
      if ($result['code'] == 200) {
        $data = $result['response'];
        // Calculate netblock -- @TODO may not be necessary
        $data['netblock'] = long2ip(ip2long($data['ip_noted']) & 
          ~((1 << (32 - $data['netmask'])) - 1));
        $nodes[$ip] = $data;
        if ($caching) {
          $expires = time() + variable_get('ecenter_network_node_cache_ttl', 300);
          cache_set($ip, $data, 'cache_ecenter_nodes', $expires);
        }
      }
      else {
        drupal_set_message(t('Request (@url) failed with code @code (@response).', 
          array('@url' => $result['url'], '@code' => $result['code'], 
            '@response' => $result['response'])));
        return FALSE;
      }
    }
  }
  return $nodes[$ip];
}

/**
 * Parse Data Retrieval Sevice data
 *
 * Compatible with 3.4.x version of DRS. Several portions of the parser are
 * computationally expensive (a day's worth of data takes 200-300 ms to parse).
 *
 * @param $response
 *   A response object from the E-center webservice.
 * @return
 *   An array of parsed data
 */
function ecenter_network_parse_response($response) {
  $parsed_data = array(
    'parameters' => $response['parameters'],
  );
  $data = $response['response'];

  if (!empty($response['post'])) {
    $parsed_data['parameters']['start'] = $response['post']['start'];
    $parsed_data['parameters']['end'] = $response['post']['end'];
  }

  // Add hops to data structure
  foreach ($data['traceroute_nodes'] as $node_ip => $node) {
    $node = ecenter_network_get_node($node_ip);
    $node['id'] = str_replace('.', '_', $node_ip);
    $parsed_data['hops'][$node_ip] = $node + array('data' => 
      array(
        'snmp' => $data['snmp']['out'][$node_ip],
      ),
    );
  }

  // Process traceroute
  foreach (array('forward' => 'src', 'reverse' => 'dst') 
    as $direction => $end_type) {
    $traceroute = array();
    $traceroute_direction = ($direction == 'forward') ? 'direct' : 'reverse';
    if (!empty($data[$traceroute_direction .'_traceroute'])) {
      foreach ($data[$traceroute_direction .'_traceroute'] as $series) {
        // Sort series so first hop is best candidate for most likely hop
        usort($series, '_ecenter_network_sort_series');
        $hop = array_shift($series);
        if (empty($parsed_data['hops'][$hop['hop_ip']])) {
          continue;
        }
        $hop += $parsed_data['hops'][$hop['hop_ip']];

        // Geolocate IP if no geo data available
        if (!$hop['longitude'] || !$hop['latitude']) {
          $geo = geoip_city($hop['hop_ip']);
          $hop['longitude'] = $geo->longitude;
          $hop['latitude'] = $geo->latitude;
          $hop['geolocated'] = TRUE;
        }
        $traceroute[$hop['hop_num']] = $hop;
      }

      // Sort by hop number
      ksort($traceroute);

      // Strip doubled or empty hops from beginning and end of traceroute
      for ($i = 0; $i < 2; $i++) {
        $traceroute = array_reverse($traceroute);
        while (!empty($traceroute) && (empty($traceroute[0]['data']['snmp']) || $traceroute[0]['hub_name'] == $traceroute[1]['hub_name'])) {
          array_shift($traceroute);
        }
      }

      $parsed_data['traceroute'][$direction] = $traceroute;
    }
  }

  // Determine source and destination 
  if (!empty($parsed_data['traceroute']['forward']) || !empty($parsed_data['traceroute']['reverse'])) {
    if (!empty($parsed_data['traceroute']['forward'])) {
      $copy = $parsed_data['traceroute']['forward'];
      $src = array_shift($copy);
      $dst = array_pop($copy);
    }
    else {
      $copy = $parsed_data['traceroute']['reverse'];
      $dst = array_shift($copy);
      $src = array_pop($copy);
    }
    $query_src = $src['hub_name']; 
    $query_dst = $dst['hub_name'];

    $parsed_data['parameters']['src'] = 'hub:'. $src['hub_name'];
    $parsed_data['parameters']['dst'] = 'hub:'. $dst['hub_name'];
  }
  else { // Fall back to query
    $query_src = $response['parameters']['src']['value'];
    $query_dst = $response['parameters']['dst']['value'];
    $parsed_data['parameters']['src'] = $response['parameters']['src']['type'] .':'. $response['parameters']['src']['value'];
    $parsed_data['parameters']['dst'] = $response['parameters']['dst']['type'] .':'. $response['parameters']['dst']['value'];
  }

  // Parse end-to-end test data
  foreach (array('forward' => 'src', 'reverse' => 'dst') 
    as $direction => $end_type) {
    foreach (array('bwctl', 'owamp', 'pinger') as $test) {
      if (empty($data[$test])) {
        continue;
      }
      $parsed_data['end_to_end'][$test][$direction] = array();
      foreach ($data[$test] as $src => $destinations) {
        $processed_data = array();
        foreach ($destinations as $dst => $row) {
          if (empty($row)) {
            continue;
          }
          if (($direction == 'forward'
              && $query_src == $row['src_hub']
              && $query_dst == $row['dst_hub']) ||
            ($direction == 'reverse' 
              && $query_dst == $row['src_hub']
              && $query_src == $row['dst_hub'])) {
            foreach ($row['data'] as $timestamp => $measurements) {
              drupal_alter('ecenter_network_end_to_end_measurements', 
                $processed_data, $timestamp, $measurements);    
            }
            drupal_alter('ecenter_network_end_to_end_measurements_statistics',
              $processed_data); 
          }
        }
        if (!empty($processed_data)) {
          $parsed_data['end_to_end'][$test][$direction] += $processed_data;
        }
      }
    }
  }

  // Calculate diff
  if (!empty($parsed_data['traceroute']['forward']) 
    && !empty($parsed_data['traceroute']['reverse'])) {

    $forward = $parsed_data['traceroute']['forward'];
    $reverse = array_reverse($parsed_data['traceroute']['reverse']);

    $parsed_data['traceroute']['diff'] = ecenter_network_traceroute_diff($forward, $reverse);
    $parsed_data['traceroute']['traceroute_max'] = (count($forward) > count($reverse)) ? 
      count($forward) : count($reverse);
  }
  elseif (!empty($parsed_data['traceroute']['forward'])) {
    $diff = array();
    $forward = $parsed_data['traceroute']['forward'];
    foreach ($forward as $row) {
      $diff[] = array('match' => array('forward' => array($row)));
    }
    $parsed_data['traceroute']['diff'] = $diff;
    $parsed_data['traceroute']['traceroute_max'] = count($diff);
  }
  elseif (!empty($parsed_data['traceroute']['reverse'])) {
    $diff = array();
    $reverse = $parsed_data['traceroute']['reverse'];
    foreach ($reverse as $row) {
      $diff[] = array('match' => array('reverse' => array($row)));
    }
    $parsed_data['traceroute']['diff'] = $diff;
    $parsed_data['traceroute']['traceroute_max'] = count($diff);
  }
  
  return $parsed_data;
}

/**
 * Parse hops
 *
 * @param $hop_list
 *  List of hops returns from data service
 * @return
 *  Parsed array consisting of hubs, hops, and a combined list with urn-style
 *  keys (i.e. 'hub:BNL' and 'ip:127.0.0.1').
 */
function ecenter_network_parse_hops($hops) {
  $combined = array();
  $hubs = array();
  $ip_hops = array();

  usort($hops, '_ecenter_network_sort_hopname');

  foreach ($hops as $hop) {
    // First instance of hub
    if (empty($hubs[$hop['hub_name']])) {
      $hubs[$hop['hub_name']] = $hop;
      $combined['hub:'. $hop['hub_name']] = $hop + array('type' => 'hub');
    }
    $ip_hops[$hop['ip_noted']] = $hop;
    $combined['ip:'. $hop['ip_noted']] = $hop + array('type' => 'ip');
  }
  return array('combined' => $combined, 'hops' => $ip_hops, 'hubs' => $hubs);
}

/**
 * Sort traceroute
 */
function _ecenter_network_sort_series($a, $b) {
  return ((int) $a['hop_delay'] > (int) $b['hop_delay']);
}

/**
 * Callback for custom hop sort
 */
function _ecenter_network_sort_hopname($a, $b) {
  return strcmp($a['hub'], $b['hub']);
}
