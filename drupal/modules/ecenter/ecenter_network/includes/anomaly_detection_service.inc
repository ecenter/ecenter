<?php

/**
 * Get/cache anomaly data
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
function ecenter_network_get_ads_data($src, $dst, $start, $end, $algorithm = 'spd', $detector_type = NULL, $sensitivity = NULL, $elevation1 = NULL, $elevation2 = NULL, $swc = NULL) {
  $params = get_defined_vars();
  global $user;
  static $results = array();

  $query = http_build_query($params);

  if (!array_key_exists($query, $results)) {
    $resolution = variable_get('ecenter_network_ads_resolution', 1000);
    $client = ecenter_network_get_client('message', 'ads');
    foreach (array('owamp', 'bwctl') as $data_type) {
      $result = $client->getData($src, $dst, $start, $end, $data_type, $resolution, $algorithm, $detector_type, $sensitivity, $elevation1, $elevation2, $swc);
      if ($result['code'] == 200) {
        $data = ecenter_network_parse_ads_response($result);
        $results[$query][$data_type] = $data;
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
 * Parse Anomaly Detection Service data
 *
 * Compatible with 3.4.x version of ADS.
 *
 * @param $response
 *   A response object from the ADS
 * @return
 *   An array of parsed data
 */
function ecenter_network_parse_ads_response($response) {
  $parsed_data = array();
  $data = $response['response'];
  $params = $response['parameters'];

  foreach (array('forward', 'reverse') as $direction) {
    foreach ($data as $src => $destinations) {
      foreach ($destinations as $dst => $row) {
        if (is_array($row['status']) &&
            (($direction == 'forward' 
            && $params['src']['value'] == $row['src_hub']
            && $params['dst']['value'] == $row['dst_hub']) ||
            ($direction == 'reverse' 
            && $params['dst']['value'] == $row['src_hub']
            && $params['src']['value'] == $row['dst_hub']))
          ) {
          $parsed_data[$direction] = $row['status'];
        } 
      }
    }
  }
  return $parsed_data;
}


