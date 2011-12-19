<?php

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
function ecenter_network_get_circuit_data($src, $dst, $start, $end, $no_snmp = FALSE) {
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
      $resolution = variable_get('ecenter_network_drs_circuit_resolution', 50);
      $client = ecenter_network_get_client('message', 'drs_circuit');
      $result = $client->getCircuitData($src, $dst, $start, $end, $no_snmp, $resolution);
      if ($result['code'] == 200) {
        //$data = ecenter_network_parse_response($result);
        $data = $result['response'];
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


