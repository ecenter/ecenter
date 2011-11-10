<?php

/**
 * Get/cache forecasting data
 *
 * @param $src
 *   Source IP address
 * @param $dst
 *   Destination IP address
 * @param $start
 *   Start time, expressed in UTC, formatted as Y-m-d H:i:s
 * @param $end
 *   End time, expressed in UTC, formatted as Y-m-d H:i:s
 * @param fds_type
 *   One of 'snmp', 'bwctl', or 'owamp'
 * @return
 *   An array of parsed data
 */
function ecenter_network_get_fds_data($src, $dst, $start, $end, $fds_type) {
  $params = get_defined_vars();
  static $results = array();

  $start_date = date_create($start, timezone_open('UTC'));
  $end_date = date_create($start, timezone_open('UTC'));
  $diff = date_diff($end_date, $start_date);
  if ($diff->days < 60) {
    date_modify($end_date, '-2 months');
    $start = date_format($end_date, 'Y-m-d H:i:s');
    $params['start'] = $start;
  }

  $params['fds'] = TRUE;
  $query = http_build_query($params);

  if (!array_key_exists($query, $results)) {
    $caching = variable_get('ecenter_network_fds_cache_enabled', 0);
    if ($caching && $result = cache_get($query, 'cache_ecenter_data')) {
      $results[$query] = $result->data;
    }
    else {
      $resolution = variable_get('ecenter_network_fds_resolution', 1000);
      $client = ecenter_network_get_client(FALSE, 'fds');
      $result = $client->getData($src, $dst, $start, $end, $fds_type);
      if ($result['code'] == 200) {
        $data = ecenter_network_parse_fds_response($result);
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

/**
 * Parse Forecasting Data Service data
 * 
 * @param $response
 *   A response object from the ADS
 * @return
 *   An array of parsed data
 */
function ecenter_network_parse_fds_response($response) {
  $parsed_data = array();
  $data = $response['response'];
  $params = $response['parameters'];
  $type = $response['parameters']['data_type'];

  switch ($type) {
    case 'snmp':
      foreach ($data as $node_ip => $forecast) {
        $i = 0;
        $length = count($forecast['utilization']['forecast']);
        while ($i < $length) {
          $value = $forecast['utilization']['forecast'][$i];
          $err = $forecast['utilization']['sderr'][$i];
          $timestamp = $forecast['utilization']['times'][$i];
          $parsed_data[$type]['utilization'][$node_ip][$timestamp] = array(
            'value' => $value,
            'stderr' => $err,
            'errpct' => $err / $value,
          );
          $i++;
        }
      }
      break;

    case 'bwctl':
      foreach ($data as $src_ip => $destinations) {
        $i = 0;
        $src_node = ecenter_network_get_node($src_ip);

        if ($src_node['hub_name'] == $params['src']['value']) {
          $direction = 'forward';
        }
        else if ($src_node['hub_name'] == $params['dst']['value']) {
          $direction = 'reverse';
        }
        else {
          continue; // This shouldn't ever happen in the data. But knowing the data...
        }

        foreach ($destinations as $dst_ip => $destination_forecast) {
          $dst_node = ecenter_network_get_node($dst_ip);

          if ( $destination_forecast['status'] == 'ok' && 
            ($direction == 'forward' && $dst_node['hub_name'] == $params['dst']['value']) ||
            ($direction == 'reverse' && $dst_node['hub_name'] == $params['src']['value']) ) {

            $i = 0;
            $length = count($destination_forecast['throughput']['forecast']);

            while ($i < $length) {
              $value = $destination_forecast['throughput']['forecast'][$i];
              $err = $destination_forecast['throughput']['sderr'][$i];
              $timestamp = $destination_forecast['throughput']['times'][$i];
              $parsed_data[$type]['throughput'][$direction][$timestamp] = array(
                'value' => $value,
                'stderr' => $err,
                'errpct' => $err / $value,
              );
              $i++;
            }

          }
        }
      }
      break;
  }

  return $parsed_data;
}

/**
 * Form snippet for FDS
 */
function ecenter_network_fds_form($value = FALSE) {
  extract(_ecenter_network_extract_query());

  $form['fds_wrapper'] = array(
    '#prefix' => '<div id="fds-settings-wrapper" class="analysis-wrapper">',
    '#suffix' => '</div>',
  );
  $form['fds_wrapper']['fds_submit'] = array(
    '#type' => 'submit',
    '#id' => 'fds-submit',
    '#name' => 'fds-submit',
    '#value' => t('Get forecast'),
    '#attributes' => array(
      'class' => 'analysis-submit fds-submit disabled',
      'disabled' => TRUE,
    ),
    '#weight' => 0,
  );

  $form['fds_wrapper']['fds_type'] = array(
    '#id' => 'fds-type',
    '#name' => 'fds_type',
    '#type' => 'select',
    '#title' => t('Type'),
    '#value' => (!empty($fds) && !empty($fds_type)) ? $fds_type : 'snmp',
    '#options' => array(
      'snmp' => t('SNMP'),
      'bwctl' => t('bwctl'),
      //'owamp' => t('owamp (one-way ping)'),
    ),
    '#attributes' => array(
      'disabled' => TRUE,
    ),
    '#weight' => 5,
  );


  if (user_access('access ecenter forecasting data')) {
    $form['fds_wrapper']['fds'] = array(
      '#id' => 'fds-enable',
      '#name' => 'fds',
      '#type' => 'checkbox',
      '#title' => 'Use forecasting',
      '#value' => $value,
      '#attributes' => array('class' => 'analysis-enable fds-enable'),
      '#weight' => 10,
    );

    /*$form['fds_wrapper']['fds_settings'] = array(
      '#id' => 'fds-settings-fieldset',
      '#prefix' => '<div id="fds-settings">',
      '#suffix' => '</div>',
      '#type' => 'fieldset',
      '#title' => t('Forecast settings'),
      '#collapsible' => TRUE,
      '#collapsed' => TRUE,
      '#weight' => 10,
    );

    $form['fds_wrapper']['fds_settings']['start'] = array(
      '#id' => 'fds_start',
      '#name' => 'fds_start',
      '#title' => t('Start'),
      '#type' => 'textfield',
      '#weight' => 1,
      '#size' => 12,
    );

    $form['fds_wrapper']['fds_settings']['end'] = array(
      '#id' => 'fds_end',
      '#name' => 'fds_end',
      '#title' => t('End'),
      '#type' => 'textfield',
      '#size' => 12,
      '#weight' => 2,
    );*/

    $form['fds_wrapper']['fds_submit']['#attributes']['class'] = 'analysis-submit fds-submit';
    unset($form['fds_wrapper']['fds_submit']['#attributes']['disabled']);
    unset($form['fds_wrapper']['fds_type']['#attributes']['disabled']);
  }

  return $form;
}
