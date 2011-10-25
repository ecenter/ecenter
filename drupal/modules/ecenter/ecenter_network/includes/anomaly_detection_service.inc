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
function ecenter_network_get_ads_data($src, $dst, $start, $end, $algorithm = 'spd',
  $detector_type = NULL, $sensitivity = NULL, $elevation1 = NULL, 
  $elevation2 = NULL, $swc = NULL) {
  
  $params = get_defined_vars();
  static $results = array();

  $params['ads'] = TRUE;
  $query = http_build_query($params);

  if (!array_key_exists($query, $results)) {
    $caching = variable_get('ecenter_network_ads_cache_enabled', 0);
    if ($caching && $result = cache_get($query, 'cache_ecenter_data')) {
      $results[$query] = $result->data;
    }
    else {
      $resolution = variable_get('ecenter_network_ads_resolution', 1000);
      $client = ecenter_network_get_client('message', 'ads');
      foreach (array('owamp', 'bwctl') as $data_type) {
        $result = $client->getData($src, $dst, $start, $end, $data_type, $resolution, $algorithm, $detector_type, $sensitivity, $elevation1, $elevation2, $swc);
        if ($result['code'] == 200) {
          $data = ecenter_network_parse_ads_response($result);
          if ($caching) {
            $expires = time() + variable_get('ecenter_network_data_cache_ttl', 3600);
            cache_set($query, $data, 'cache_ecenter_data', $expires);
          }
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

/**
 * Form snippet for ADS
 */
function ecenter_network_ads_form($value = FALSE) {
  extract(_ecenter_network_extract_query());

  $form['ads_wrapper'] = array(
    '#prefix' => '<div id="ads-settings-wrapper" class="analysis-wrapper">',
    '#suffix' => '</div>',
  );
  
  $form['ads_wrapper']['ads_submit'] = array(
    '#type' => 'submit',
    '#id' => 'ads-submit',
    '#name' => 'ads-submit',
    '#value' => t('Detect anomalies'),
    '#attributes' => array('class' => 'analysis-submit ads-submit'),
    '#weight' => 0,
  );

  $form['ads_wrapper']['ads'] = array(
    '#id' => 'ads-enable',
    '#name' => 'ads',
    '#type' => 'checkbox',
    '#title' => 'Use anomaly detection (experimental)',
    '#value' => $value,
    '#attributes' => array('class' => 'analysis-enable ads-enable'),
    '#weight' => 10,
  );

  $form['ads_wrapper']['ads_settings'] = array(
    '#id' => 'ads-settings-fieldset',
    '#prefix' => '<div id="ads-settings">',
    '#suffix' => '</div>',
    '#type' => 'fieldset',
    '#title' => t('Anomaly settings'),
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
    '#weight' => 5,
  );

  $form['ads_wrapper']['ads_settings']['algorithm'] = array(
    '#id' => 'algorithm',
    '#name' => 'algorithm',
    '#title' => theme('advanced_help_topic', 'ecenter_network', 'ads_algorithm') . t('Algorithm'),
    '#type' => 'select',
    '#options' => array(
      'spd' => t('spd'),
      'apd' => t('apd'),
    ),
    '#attributes' => array('class' => 'ads-algorithm'),
    '#value' => (!empty($algorithm)) ? $algorithm : 'spd',
    '#weight' => 1,
  );

  $form['ads_wrapper']['ads_settings']['sensitivity'] = array(
    '#id' => 'sensitivity',
    '#name' => 'sensitivity',
    '#title' => theme('advanced_help_topic', 'ecenter_network', 'ads_sensitivity') . t('Sensitivity'),
    '#type' => 'textfield',
    '#size' => 5,
    '#id' => 'sensitivity',
    '#name' => 'sensitivity',
    '#value' => (!empty($sensitivity)) ? $sensitivity : 2,
    '#weight' => 2,
  );

  $form['ads_wrapper']['ads_settings']['elevation1'] = array(
    '#id' => 'elevation1',
    '#name' => 'elevation1',
    '#title' => theme('advanced_help_topic', 'ecenter_network', 'ads_elevation1') . t('Elevation 1'),
    '#type' => 'textfield',
    '#size' => 5,
    '#value' => (!empty($elevation1)) ? $elevation1 : 0.2,
    '#weight' => 3,
  );

  $form['ads_wrapper']['ads_settings']['elevation2'] = array(
    '#id' => 'elevation2',
    '#name' => 'elevation2',
    '#title' => theme('advanced_help_topic', 'ecenter_network', 'ads_elevation2') . t('Elevation 2'),
    '#type' => 'textfield',
    '#size' => 5,
    '#value' => (!empty($elevation2)) ? $elevation2 : 0.4,
    '#weight' => 4,
  );

  $form['ads_wrapper']['ads_settings']['swc'] = array(
    '#id' => 'swc',
    '#name' => 'swc',
    '#title' => theme('advanced_help_topic', 'ecenter_network', 'ads_swc') . t('Window count'),
    '#type' => 'textfield',
    '#size' => 5,
    '#value' => (!empty($swc)) ? $swc : 15,
    '#weight' => 5,
  );

  return $form;
}

