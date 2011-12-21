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
    $caching = FALSE;
    if ($caching && $result = cache_get($query, 'cache_ecenter_data')) {
      $results[$query] = $result->data;
    }
    else {
      $resolution = variable_get('ecenter_network_drs_circuit_resolution', 50);
      $client = ecenter_network_get_client('message', 'drs_circuit');
      $result = $client->getCircuitData($src, $dst, $start, $end, $no_snmp, $resolution);
      if ($result['code'] == 200) {
        $data = ecenter_network_parse_circuit_response($result);
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
  }
  return $results[$query];
}

function ecenter_network_parse_circuit_response($response) {
  $parsed_data = array(
    'parameters' => $response['parameters'],
  );

  $data = $response['response'];

  if (!empty($data)) {
    //$diff = array();
    $parsed_data['circuits'] = array();
    foreach ($data['circuits'] as $source => $destinations) {
      foreach ($destinations as $destination => $circuits) {
        foreach ($circuits as $circuit_name => $circuit) {
          $fwd_traceroute = array();
          $rev_traceroute = array();
          $diff = array();
          foreach ($circuit['hops'] as $urn => $hop) {
            $hop['urn'] = $urn;
            $hop['hub'] = $hop['hub_name'];

            list($fwd_hop, $rev_hop) = array($hop, $hop);

            $fwd_hop['data']['snmp'] = $data['snmp']['out'][$urn];
            $rev_hop['data']['snmp'] = $data['snmp']['in'][$urn];
            
            $fwd_traceroute[$hop['hop_num']] = $fwd_hop;
            $rev_traceroute[$hop['hop_num']] = $rev_hop;
            
            $diff[$hop['hop_num']] = array(
              'match' => array(
                'forward' => array($fwd_hop),
                'reverse' => array($rev_hop)
              )
            );
          }

          ksort($fwd_traceroute);
          ksort($rev_traceroute);
          $parsed_data['circuits'][$circuit_name]['traceroute']['forward'] = $fwd_traceroute;
          $parsed_data['circuits'][$circuit_name]['traceroute']['reverse'] = array_reverse($rev_traceroute);

          ksort($diff);
          $parsed_data['circuits'][$circuit_name]['traceroute']['diff'] = $diff;
          $parsed_data['circuits'][$circuit_name]['traceroute']['traceroute_max'] = count($diff);
        }
      }
    }
  }
  return $parsed_data;
}
