<?php

/**
 * Get/cache forecasting data
 */
function ecenter_network_get_fds_data($src, $dst, $start, $end, $fds_type) {
  $params = get_defined_vars();
  static $results = array();

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
    '#attributes' => array('class' => 'analysis-submit fds-submit'),
    '#weight' => 0,
  );
  $form['fds_wrapper']['fds_type'] = array(
    '#id' => 'fds-type',
    '#name' => 'fds_type',
    '#type' => 'select',
    '#title' => t('Type'),
    '#value' => (!empty($fds) && !empty($fds_type)) ? $fds_type : 'snmp',
    '#options' => array(
      'snmp' => t('SNMP utilization'),
      'bwctl' => t('bwctl (bandwidth control)'),
      'owamp' => t('owamp (one-way ping)'),
    ),
    '#weight' => 10,
  );
  $form['fds_wrapper']['fds'] = array(
    '#id' => 'fds-enable',
    '#name' => 'fds',
    '#type' => 'checkbox',
    '#title' => 'Use forecasting',
    '#value' => $value,
    '#attributes' => array('class' => 'analysis-enable fds-enable'),
    '#weight' => 10,
  );

  return $form;
}
