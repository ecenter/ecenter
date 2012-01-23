<?php

/**
 * Get/cache site centric data
 *
 * @TODO Integrate parsing before cache is set
 *
 * @param $site
 *   Source IP address
 * @param $start
 *   Start time, expressed in UTC, formatted as Y-m-d H:i:s
 * @param $end
 *   End time, expressed in UTC, formatted as Y-m-d H:i:s
 * @return
 *   An array of parsed data
 */
function ecenter_network_get_site_centric_data($site, $start, $end) {
  global $user;
  static $results = array();

  $query = http_build_query(array(
    'src_hub' => $site,
    'start' => $start,
    'end' => $end,
  ));

  if (!array_key_exists($query, $results)) {
    $caching = variable_get('ecenter_network_site_data_cache_enabled', 0);
    if ($caching && $result = cache_get($query, 'cache_ecenter_site_data')) {
      $results[$query] = ecenter_network_parse_site_data($result->data, $site);
    }
    else {
      $resolution = variable_get('ecenter_network_site_data_resolution', 50);
      $client = ecenter_network_get_client(FALSE, 'drs_sitecentric');
      $result = $client->getSiteCentricData($site, $start, $end);
      if ($result['code'] == 200) {
        $data = $result['response'];
        if ($caching) {
          $expires = time() + variable_get('ecenter_network_site_data_cache_ttl', 7200);
          cache_set($query, $data, 'cache_ecenter_site_data', $expires);
        }
        $results[$query] = ecenter_network_parse_site_data($data, $site);
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

/**
 * Parse 'site centric view' data
 *
 * Compatible with 3.4.x version of DRS. 
 *
 * @param $response
 *   A response object from the DRS
 * @return
 *   An array of parsed data
 */
function ecenter_network_parse_site_data($data, $site) {
  $parsed_data = array(
    'source' => $site,
  );
  foreach (array('direct_traceroute' => 'forward', 'reverse_traceroute' => 'reverse') as $key => $direction) {
    if (!empty($data[$key])) {
      foreach ($data[$key] as $hub => $results) {
        if (!empty($hub) && $hub != $site) {
          $parsed_data['destinations'][$hub]['traceroute'][$direction]['snmp'] = $results['snmp'];
        }
      }
    }
  }
  foreach (array('bwctl', 'owamp', 'pinger') as $key) {
    foreach ($data[$key] as $hub => $measurements) {
      if ($hub != $site) {
        $parsed_data['destinations'][$hub]['e2e'][$key] = $measurements;
      }
    }
  }
  return $parsed_data;
}
