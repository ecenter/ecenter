<?php
// $Id$

/**
 * @file
 * E-Center Network theming.
 */

/**
 * Theme main data display
 */
function template_preprocess_ecenter_network_data(&$vars) {
  global $user;
  $data = $vars['data'];

  // All parameters
  $params = $data['parameters'];
  
  drupal_add_js(array('ecenterNetwork' => array('tracerouteData' => 
    $data['drs']['traceroute']['diff'])), 'setting');
  drupal_add_js(array('ecenterNetwork' => array('tracerouteMaxLength' => 
    $data['drs']['traceroute']['traceroute_max'])), 'setting');

  // End to end measurements
  if (!empty($data['drs']['end_to_end'])) {
    $vars['end_to_end'] = theme('ecenter_network_end_to_end',
      $data['drs']['end_to_end'], $params['timezone'], $data['ads'], 
      $data['fds'], !$vars['standalone']);
  }

  // Per-hop measurements
  $vars['traceroute'] = theme('ecenter_network_traceroute', 
    $data['drs']['traceroute']['diff'], $params['timezone'], $data['fds']);

  // Generate permalink
  $vars['permalink'] = l(t('Link'), 'network', array(
    'query' => $params,
    'absolute' => TRUE,
    'attributes' => array('title' => $vars['title']),
  ));
 
  // @TODO This works! Should we include it?
  $url = url('network', array('query' => $params, 'absolute' => TRUE,));
  $short_url = shorturl_shorten($url, TRUE);

  $permalink_field['permalink'] = array(
    '#id' => 'ecenter-permalink',
    '#type' => 'textfield',
    '#size' => 115,
    '#attributes' => array('readonly' => 'readonly'),
    '#value' => $short_url, 
  );
  $vars['permalink_field'] = drupal_render($permalink_field);
}

/**
 * Theme end to end data table
 */
function template_preprocess_ecenter_network_end_to_end(&$vars) {
  $data = $vars['data'];

  $statistics_table = array();
  $data_tables = array();

  if (!$data) {
    return;
  }

  foreach ($data as $test => $directions) {
    $start = 0;
    $end = 0;

    foreach ($directions as $direction => $measurements) {
      foreach ($measurements as $measurement => $values) {
        // Suggestion array to format values
        $value_suggestions = array(
          'ecenter_network_format_'. $test .'_'. $measurement,
          'ecenter_network_format_'. $test,
          'ecenter_network_format_default',
        );

        // Process stats table
        if (($statistics = $values['statistics']) && is_array($statistics)) {
          // Suggestion array to format value labels
          $label_suggestions = array(
            'ecenter_network_format_'. $test .'_'. $measurement .'_label',
            'ecenter_network_format_'. $test .'_label',
            'ecenter_network_format_default_label',
          );

          $row = array();
          foreach ($statistics as $key => $value) {
            $row[$key] = array('data' => theme($value_suggestions, $value,
              $test, $measurement), 'class' => $key);
          }
          $header = array(
            'header' => TRUE,
            'data' => theme($label_suggestions, $measurement, $test,
              $direction, TRUE),
          );
          // Create table row for theming
          $table[$test .'_'. $measurement .'_'. $direction] = array(
            'data' => array($header) + $row,
            'class' => $test .'-'. $measurement .' '. $test .'-'. $measurement
              .'-'. $direction,
            'id' => $test .'-'. $measurement .'-'. $direction,
          );
        }

        // Process timeseries into tables
        if (($timeseries = $values['timeseries']) && is_array($timeseries)
          && $values['statistics']['max'] > 0) {
          $data_table = array();
          $i = 1;
          ksort($timeseries);

          $time_range = array_keys($timeseries);
          $max = max($time_range);
          $min = min($time_range);
          $end = ($max > $end) ? $max : $end;
          $start = ($start == 0 || $min < $start) ? $min : $start;

          foreach ($timeseries as $timestamp => $value) {
            $time = _ecenter_network_timestamp_to_local($timestamp, 'Y-m-d H:i:s', $vars['timezone']);
            $data_table[] = array(
              array('data' => $time, 'header' => TRUE),
              theme($value_suggestions, $value, $test, $measurement, FALSE)
            );
          }
          $data_tables[$test][$measurement][$direction] = $data_table;
          $data_tables[$test][$measurement]['start'] = $start;
          $data_tables[$test][$measurement]['end'] = $end;

          // Add forecasts
          if (!empty($vars['fds_data'][$test][$measurement][$direction])) {
            $forecast_table = array();
            $forecast_data = $vars['fds_data'][$test][$measurement][$direction];
            foreach ($forecast_data as $timestamp => $values) {
              $time = _ecenter_network_timestamp_to_local($timestamp);
              $err = $values['stderr'] / 2;

              $forecast_table[] = array(
                'class' => 'forecast',
                'data' => array(
                  array('data' => $time, 'header' => TRUE),
                  theme($value_suggestions, $values['value'], $test, $measurement, FALSE),
                  theme($value_suggestions, $values['value'] - $err, $test, $measurement, FALSE),
                  theme($value_suggestions, $values['value'] + $err, $test, $measurement, FALSE),
                ),
              );

            }
            
            $data_tables[$test][$measurement][$direction .'_forecast'] = $forecast_table;
          }
         
          // Add anomaly tables
          if ((($test == 'owamp' && $measurement == 'max_delay') || $test == 'bwctl') 
            && !empty($vars['ads_data'][$test][$direction])) {
            $data_table = array();
            foreach ($vars['ads_data'][$test][$direction] as $warning_type => $timeseries) {
              foreach ($timeseries as $timestamp => $value) {
                $time = _ecenter_network_timestamp_to_local($timestamp);
                $data_table[] = array(
                  array('data' => $time, 'header' => TRUE),
                  $value['value'] * 1000,
                );
              }
            }
            $data_tables[$test][$measurement][$direction .'_'. $warning_type] = $data_table;
          }

          // Reverse table order
          krsort($data_tables[$test][$measurement][$direction]);
        }
      }
    }
  }

  if (!empty($table)) {
    // Sort table
    ksort($table);

    $headers = array(
      array('data' => 'Measurement', 'class' => 'result-header',),
      t('Average'), t('Max'), t('Min'),
    );
    $vars['table'] = theme('jqplot_table', $headers, $table,
      array('class' => 'data-table end-to-end-table'));
    $vars['data_tables'] = theme('ecenter_network_end_to_end_tables',
      $data_tables, $vars['timezone']);
  }
  else {
    $vars['table'] = '<p>'. t('No end-to-end results available.') .'</p>';
  }
}

/**
 * Theme recent user queries
 */
function theme_ecenter_network_recent_queries($collapse = FALSE) {
  global $user;
  if ($user->uid > 0) {
    $queries = $user->ecenter_network_queries;
  }
  else if (isset($_COOKIE[session_name()])) {
    $queries = unserialize(sess_read('ecenter_network_queries'));
  }

  $element['queries'] = array(
    '#type' => 'fieldset',
    '#title' => t('Your recent E-Center Network queries'),
    '#prefix' => '<div id="recent-queries">',
    '#suffix' => '</div>',
  );

  if (!empty($queries)) {
    $links = array();
    foreach ($queries as $query) {
      $links[] = theme('ecenter_network_recent_query', $query['query'], $query['time']);
    }
    $element['queries'] += array(
      '#collapsible' => $collapse,
      '#collapsed' => $collapse,
      'links' => array(
        '#value' => theme('item_list', array_reverse($links)),
      ),
    );
  }
  else {
    $element['queries'] = array(
      'no_queries' => array(
        '#value' => t('No recent queries available.'),
      ),
    );
  }
  return drupal_render($element);
}

/**
 * Theme a single query link
 */
function theme_ecenter_network_recent_query($query, $time) {
  $time = _ecenter_network_timestamp_to_local($time, 'M d, Y - H:i');

  $query_parts = explode('&amp;', urldecode($query));
  foreach ($query_parts as $part) {
    list($key, $value) = explode('=', $part);

    if ($key == 'start' || $key == 'end') {
      $value = _ecenter_network_utc_to_local($value, 'M d, Y - H:i');
    }

    if ($key == 'src' || $key == 'dst') {
      list($temp, $value) = explode(':', $value, 2);
    }

    $values[$key] = $value;
  }

  $query_text = t('<span class="path">@src to @dst</span> from
    <span class="date-range">@start to @end</span>',
    array(
      '@src' => $values['src'], '@dst' => $values['dst'],
      '@start' => $values['start'], '@end' => $values['end']
    )
  );

  $query_time = t('Last queried: @time', array('@time' => $time));

  $output = '<div class="link"><a href="'. urldecode(url('network') .'?'. $query) .'">'.
    $query_text .'</a></div>';
  $output .= '<div class="query-date">'. $query_time .'</div>';
  return $output;
}

/**
 * Theme per-hop data
 *
 * @TODO We might want to make this more flexible. However, this data isn't
 * likely to change soon.
 */
function theme_ecenter_network_traceroute($traceroute = array(), $timezone = FALSE, $fds_data = array()) {
  $tables = array();

  if (empty($traceroute)) {
    return t('No traceroute available.');
  }

  $settings = array();
  $directions = array();
  $sidx = 0;

  foreach ($traceroute as $ttl => $diff_data) {
    $match = (!empty($diff_data['match'])) ? TRUE : FALSE;
    $data = array_pop($diff_data);

    foreach (array('forward', 'reverse') as $direction) {
      if (empty($data[$direction])) {
        continue;
      }
      $directions[$direction] = 1;
      foreach ($data[$direction] as $hop_index => $hop) {
        $table = array();
        $capacity = 0;

        if (!empty($hop['data']['snmp'])) {
          $hub_id = $ttl .'_'. $hop['hub_name']; 
          $settings['ecenterNetwork']['seriesLookupByIndex'][] = array(
            'id' => $hop['id'], 
            'hubID' => $hub_id,
          );
          $settings['ecenterNetwork']['seriesLookupByID'][$hop['id']] = array(
            'sidx' => $sidx,
            'hubID' => $hub_id,
          );
          $settings['ecenterNetwork']['seriesLookupByHub'][$hub_id]['id'][] = $hop['id'];
          $settings['ecenterNetwork']['seriesLookupByHub'][$hub_id]['sidx'][] = $sidx;
          $sidx++;

          foreach ($hop['data']['snmp'] as $timeseries) {
            $time = _ecenter_network_timestamp_to_local($timeseries[0], 'Y-m-d H:i:s', $timezone);
            $table[] = array(
              'label' => array(
                'data' => $time,
                'header' => TRUE,
              ),
              'utilization' => array(
                'data' => sprintf('%01.4f',
                  100 * ($timeseries[1]['utilization'] / $timeseries[1]['capacity'])),
                'class' => $class,
              ),
            );
          }
        }

        $attributes = array(
          'class' => 'data-table '. $direction .' '. strtolower($hub_id) .'-data-table',
          'data-jqplotSeriesOptions' => '{"label":"'. ucfirst($direction) .' utilization' .'"}',
        );

        $capacity = $hop['data']['snmp'][0][1]['capacity'];
        $tables[] = theme('ecenter_network_utilization_table', $table, $hop, $direction, $attributes, $capacity);

        if (!empty($fds_data['snmp']['utilization'][$hop['hop_ip']]) && !empty($hop['data']['snmp'])) {
          $forecast_table = array();
          $forecast_data = $fds_data['snmp']['utilization'][$hop['hop_ip']];

          $last_value = array_pop($hop['data']['snmp']);

          $forecast_data[$last_value[0]] = array(
            'value' => $last_value[1]['utilization'], 
            'stderr' => 0, 
            'errpct' => 0,
          );
          ksort($forecast_data);

          foreach ($forecast_data as $timestamp => $forecast) {
            $time = _ecenter_network_timestamp_to_local($timestamp, 'Y-m-d H:i:s', $timezone);
            $value = 100 * ($forecast['value'] / $last_value[1]['capacity']);
            $err = $forecast['stderr'] / 2;
            $min_err = 100 * (($forecast['value'] - $err) / $last_value[1]['capacity']);
            $max_err = 100 * (($forecast['value'] + $err) / $last_value[1]['capacity']);

            $forecast_table[] = array(
              'class' => 'forecast',
              'data' => array(
                'label' => array(
                  'data' => $time,
                  'header' => TRUE,
                ),
                'utilization' => array(
                  'data' => sprintf('%01.4f', $value),
                ),
                'min_err' => array(
                  'data' => sprintf('%01.4f', $min_err),
                ),
                'max_err' => array(
                  'data' => sprintf('%01.4f', $max_err),
                ),
              ),
            );
          }
          $hub_id = $ttl .'_'. $hop['hub_name'];
          $settings['ecenterNetwork']['seriesLookupByIndex'][] = array(
            'id' => $hop['id'],
            'hubID' => $hub_id,
          );
          $settings['ecenterNetwork']['seriesLookupByID'][$hop['id']] = array(
            'sidx' => $sidx,
            'hubID' => $hub_id,
          );
          $settings['ecenterNetwork']['seriesLookupByHub'][$hub_id]['id'][] = $hop['id'];
          $settings['ecenterNetwork']['seriesLookupByHub'][$hub_id]['sidx'][] = $sidx;
          $sidx++;

          $attributes = array(
            'class' => 'forecast '. $direction .' '. strtolower($hub_id) .'-data-table',
            'data-jqplotSeriesOptions' => '{"label":"'. ucfirst($direction) .' forecast' .'","linePattern":"dashed"}'
          );

          $tables[] = theme('ecenter_network_utilization_table', $forecast_table,
            $hop, $direction, $attributes);
        }
      }
    }
  }

  drupal_add_js($settings, 'setting');

  if (!empty($tables)) {
    $plot_options = _ecenter_network_plot_options_template();
    $plot_options['seriesDefaults']['markerOptions']['show'] = FALSE;
    $plot_options['seriesDefaults']['lineWidth'] = 0.5;
    $plot_options['seriesDefaults']['color'] = '#111111';
    $plot_options['axes']['xaxis']['pad'] = 0;
    $plot_options['axes']['xaxis']['numberTicks'] = 20;
    $plot_options['axes']['yaxis']['min'] = 0;
    $plot_options['axes']['yaxis']['max'] = 100;
    $plot_options['axes']['yaxis']['numberTicks'] = 5;
    $plot_options['linehighlighter'] = array(
      'show' => TRUE,
      'sizeAdjust' => 2.5,
      'threshold' => 4,
    );

    if (count($directions) == 1 && !empty($directions['forward'])) {
      $plot_options['seriesColors'] = array($plot_options['seriesColors'][0]); 
    }
    else if (count($directions) == 1 && !empty($directions['reverse'])) {
      $plot_options['seriesColors'] = array($plot_options['seriesColors'][1]); 
    }

    if (count($directions) > 1 && !empty($fds_data)) {
      $in_color = $plot_options['seriesColors'][0];
      $out_color = $plot_options['seriesColors'][1];
      $plot_options['linehighlighter']['colors'] = array($in_color, $in_color, $out_color, $out_color);
    }

    drupal_alter('ecenter_network_plot_options', $plot_options, 'utilization', 'snmp');
    $options = array(
      'height' => 155,
      'width' => 900,
      'hideTables' => FALSE,
      'parseX' => '$.tablechart.parseText',
      'dependencies' => array('canvasTextRenderer'),
      'plotOptions' => $plot_options,
    );
    jqplot_register_tablechart('#utilization-tables', $options);
    return '<div id="utilization-tables" class="data-wrapper"><div class="chart-title"><h3>'. 
      t('Per hop utilization').'</h3></div><div class="data-tables">'. implode("\n", $tables) .
      '</div></div>';
  }
  else {
    return t('No per-hop data available.');
  }

}

/**
 * Theme end to end data tables for plotting
 */
function theme_ecenter_network_end_to_end_tables($tables, $timezone = NULL) {
  $output = '';
  
  foreach ($tables as $type => $measurements) {
    foreach ($measurements as $measurement => $measurement_data) {
      $start = _ecenter_network_timestamp_to_local($measurement_data['start'], 'M j, Y H:i', $timezone);
      $end = _ecenter_network_timestamp_to_local($measurement_data['end'], 'M j, Y H:i', $timezone);

      unset($measurement_data['start'], $measurement_data['end']);

      $suggestions = array(
        'ecenter_network_format_'. $type .'_'. $measurement .'_label',
        'ecenter_network_format_'. $type .'_label',
        'ecenter_network_format_default_label',
      );
      $output .= '<div class="data-wrapper" id="'. $type .'-'. $measurement
        .'-data-tables">';
      $output .= '<div class="chart-title clearfix"><h3>'.
        theme($suggestions, $measurement, $type) .'</h3>';

      $output .= '<div class="chart-label">'. 
        t('@start - @end', array('@start' => $start, '@end' => $end)) 
        .'</div>';
      $output .= '</div>';

      $output .= '<div class="data-tables">';
      foreach ($measurement_data as $direction => $table) {

        ksort($table);

        $attributes = array(
          'class' => $direction, 
          'data-jqplotSeriesOptions' => '{"label":"'. ucfirst($direction) .' utilization' .'"}',
        );

        $output .= '<div class="data-table">';
        $output .= '<h3>'. t(ucfirst(str_replace('_', ' ', $direction))) .'</h3>';
        $output .= theme('jqplot_table', array(), $table, $attributes);
        $output .= '</div>';
      }
      $output .= '</div>';

      $output .= '</div>';

      $plot_options = _ecenter_network_plot_options_template();
      
      $forecast_colors = array('#48b4db', '#be4c2e');
      if (empty($measurement_data['reverse'])) {
        $plot_options['seriesColors'] = array($plot_options['seriesColors'][0], $forecast_colors[0]);  
      }
      else if (empty($measurement_data['forward'])) {
        $plot_options['seriesColors'] = array($plot_options['seriesColors'][1], $forecast_colors[1]);  
      }
      else if (!empty($measurement_data['forward_forecast'])) {
        $plot_options['seriesColors'] = array($plot_options['seriesColors'][0], $forecast_colors[0], $plot_options['seriesColors'][1], $forecast_colors[1]);  
      }
      else if (!empty($measurement_data['reverse_forecast'])) {
        $plot_options['seriesColors'] = array_merge($plot_options['seriesColors'], $plot_options['seriesColors'][1], $forecast_colors[1]);
      }
      else {
        $plot_options['seriesColors'] = array_merge($plot_options['seriesColors'], $forecast_colors);
      }

      drupal_alter('ecenter_network_plot_options', $plot_options, $measurement,
        $type, $measurement_data);
      $options = array(
        'height' => 175,
        'width' => 490,
        'hideTables' => FALSE,
        'parseX' => '$.tablechart.parseText',
        'dependencies' => array('canvasTextRenderer'),
        'plotOptions' => $plot_options,
      );
      jqplot_register_tablechart('#'. $type .'-'. $measurement .'-data-tables',
        $options);

    }
  }
  return $output;
}

/**
 * Consolidated value formatter
 */
function theme_ecenter_network_format_default($value, $type = NULL, $measurement = NULL, $units = TRUE, $format = NULL) {
  switch ($measurement) {
    case 'throughput':
      $measurement_units = ($units) ? t('mbps') : NULL;
      $format = ($format) ? $format : '%1.0f';
      return theme('ecenter_network_format_value', sprintf($format, $value / (1000 * 1000)), $measurement_units);
    case 'max_delay':
    case 'min_delay':
      $measurement_units = ($units) ? t('ms') : NULL;
      $format = ($format) ? $format : '%1.0f';
      return theme('ecenter_network_format_value', sprintf($format, $value * 1000), $measurement_units);
    case 'maxRtt':
    case 'minRtt':
    case 'medianRtt':
    case 'meanRtt':
    case 'maxIpd':
    case 'meanIpd':
    case 'minIpd':
    case 'iqrIpd':
      $format = ($format) ? $format : '%1.0f';
      $measurement_units = ($units) ? t('ms') : NULL;
      return theme('ecenter_network_format_value', sprintf($format, $value), $measurement_units);
    case 'loss':
      $format = ($format) ? $format : '%1.1f';
      return theme('ecenter_network_format_value', sprintf($format, $value));
    case 'lossPercent':
      $format = ($format) ? $format : '%1.1f';
      $measurement_units = ($units) ? t('%') : NULL;
      return theme('ecenter_network_format_value', sprintf($format, $value), $measurement_units);
    default:
      $format = ($format) ? $format : '%1.0f';
      return theme('ecenter_network_format_value', sprintf($format, $value));
  }
}

/**
 * Theme label
 */
function theme_ecenter_network_format_default_label($measurement, $test, $direction = NULL, $help = NULL) {
  if ($help) {
    switch ($measurement) {
      case 'throughput':
        $help = theme('advanced_help_topic', 'ecenter_network', 'throughput');
        break;
      case 'max_delay':
      case 'min_delay':
        $help = theme('advanced_help_topic', 'ecenter_network', 'delay');
        break;
      case 'maxRtt':
      case 'minRtt':
      case 'medianRtt':
      case 'meanRtt':
        $help = theme('advanced_help_topic', 'ecenter_network', 'rtt');
        break;
      case 'maxIpd':
      case 'minIpd':
      case 'meanIpd':
        $help = theme('advanced_help_topic', 'ecenter_network', 'iqripd');
        break;
      default:
        $help = theme('advanced_help_topic', 'ecenter_network', strtolower($measurement));
    }
  }

  switch ($measurement) {
    case 'iqrIpd':
      $measurement = 'inter-packet delay';
      break;
    case 'sent':
      $measurement = 'packets per test';
  }

  $direction = ($test != 'pinger') ? t(ucfirst($direction)) .' ' : NULL;

  return $help . $direction . t(str_replace('_', ' ', ucfirst($measurement))); 
}

/**
 * Format a numeric value for display in the E-center diagnostic tool
 */
function theme_ecenter_network_format_value($value, $units = NULL) {
  $output = '<span class="value">'. $value .'</span>';
  $output .= ($units) ? '<span class="unit">'. $units .'</span>' : '';
  return $output;
}

/**
 * Theme utilization table
 */
function theme_ecenter_network_utilization_table($table, $hop, $direction, $attributes = array(), $capacity = 0) {
  $capacity_string = ($capacity) ? t(' - @capacity gbps', array('@capacity' => $capacity / pow(10, 9))) : '';
 
  $class = 'data-table-wrapper';
  $class .= (empty($table)) ? ' no-data' : '';

  $output = "<div class=\"{$class}\">";
  $output .= '<h3>'. ucfirst($direction) .': '. $hop['nodename'] .' ('. $hop['hub'] . $capacity_string .')</h3>';

  if (!empty($table)) {
    $headers = array(t('Time'), t('% utilization'));
    $output .= theme('jqplot_table', $headers, $table, $attributes);
  } 
  else {
    $output .= '<p>'. t('No SNMP utilization data available.') .'</p>';
  }

  $output .= '</div>';
  return $output;
}

/**
 * Theme services for use in options list.  Should always return plaintext!
 */
function theme_ecenter_network_hop_option($hop) {
  return check_plain($hop['hub_name']);
}

/**
 * Theme health display
 */
function template_preprocess_ecenter_network_health(&$vars) {
  drupal_add_js(libraries_get_path('qtip') .'/jquery.qtip.js');
  drupal_add_js(drupal_get_path('module', 'ecenter_network') .
    '/js/behaviors-health.js');

  $data = $vars['data'];

  $sources = ecenter_network_get_hops();
  $metadata = array_intersect_key($data['metadata'], $sources['hubs']);

  // Convert times
  $vars['start'] = _ecenter_network_utc_to_local($vars['start'], 'Y-m-d H:i');
  $vars['end'] = _ecenter_network_utc_to_local($vars['end'], 'Y-m-d H:i');

  // Metadata count
  $header = array(t('Hub'));
  $header_created = FALSE;
  $rows = array();

  foreach ($metadata as $hub => $measurements) {
    $row = array(
      array(
        'data' => $hub,
        'header' => TRUE,
      ),
    );
    foreach ($measurements as $key => $values) {
      if (!$header_created) {
        $header[] = t($key);
      }

      $metadata_count = $values['metadata_count'];
      unset($values['metadata_count']);

      $cached_data_count = 0;
      foreach ($values as $month => $month_data) {
        $cached_data_count += $month_data['cached_data_count'];
      }

      $row[] = theme('ecenter_network_health_row', $metadata_count, $cached_data_count);
    }
    $rows[] = $row;
    $header_created = TRUE;
  }
  $vars['health_table'] = theme('table', $header, $rows, array('class' => 'network-health'));
}

/**
 * Theme a row of the health display
 */
function theme_ecenter_network_health_row($metadata_count = 0, $cached_data_count = 0) {
  $rows = array(
    'metadata_count' => array(
      array('data' => t('Metadata'), 'header' => TRUE),
      $metadata_count,
    ),
    'cached_data_count' => array(
      array('data' => t('Cached data'), 'header' => TRUE),
      $cached_data_count,
    ),
  );

  if ($metadata_count == 0) {
    $class = 'critical';
  }
  else if ($cached_data_count == 0) {
    $class = 'marginal';
  }
  else {
    $class = 'normal';
  }

  return theme('table', array(), $rows, array('class' => $class));
}

/**
 * Theme SNMP data in site-centric view
 */
function theme_ecenter_network_site_centric_data($data) {
  $tables = array();

  $headers = array();
  $row = array();
  foreach ($data['e2e'] as $type => $measurements) {
    unset($measurements['sent']);
    foreach ($measurements as $measurement => $value) {
      $headers[$measurement] = ucfirst(str_replace('_', ' ', $measurement));
      $row[] = array(
        'data' => theme('ecenter_network_format_default', $value, $type, $measurement)
      );
    }
  }
  $tables[] = '<h2>'. t('End to end') .'</h2>'. 
    theme('jqplot_table', $headers, array($row), array('class' => 'data-table'));

  $headers = array(t('Measurement'), t('Value'), t('Interface'));
  if (!empty($data['traceroute'])) {
    foreach ($data['traceroute'] as $direction => $traceroute_data) {
      $table = array();
      foreach ($traceroute_data['snmp'] as $measurement => $values) {
          $class = 'normal';

          switch ($measurement) {
            case 'utilization':
              if ($values['value'] > 95) {
                $class = 'critical';
              }
              else if ($values['value'] > 75) {
                $class = 'marginal';
              }
              break; 
            case 'errors':
            case 'drops':
              if ($values['value'] > 0) {
                $class = 'critical';
              }
              break;
          }
          $table[] = array(
            'class' => $class,
            'data' => array(
              t(ucfirst($measurement)),
              sprintf('%.2f', $values['value']),
              $values['ip'],
            ),
          );
      }
      $tables[] = '<h2>'. t(ucfirst($direction)) .'</h2>'. 
        theme('jqplot_table', $headers, $table, array('class' => 'data-table'));
    }
  }
  return implode('', $tables);
}

/**
 * Get plot options template
 */
function _ecenter_network_plot_options_template() {
  return array( 
    'seriesColors' => array('#035dc5', '#a71932',), 
    'seriesDefaults' => array(
      'lineWidth' => 1,
      'shadow' => FALSE,
      'fill' => FALSE,
      'markerOptions' => array(
        'size' => 2,
        'shadow' => FALSE,
      ),
    ),
    'legend' => array(
      'show' => TRUE,
      'renderer' => '$.jqplot.EnhancedLegendRenderer',
      'placement' => 'outsideGrid',
      'location' => 's',
      'rendererOptions' => array(
        'numberRows' => 1,
      ),
    ),
    'axes' => array(
      'xaxis' => array(
        'autoscale' => TRUE,
        'numberTicks' => 9,
        'renderer' => '$.jqplot.DateAxisRenderer',
        'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        'tickOptions' => array(
          'formatString' => "%#m/%#d <br /> %H:%M",
          'angle' => 30,
          'fontSize' => '11px',
        ),
      ),
      'yaxis' => array(
        'autoscale' => TRUE,
        'numberTicks' => 4,
        'tickOptions' => array(
          'formatString' => '%d',
          'showGridline' => TRUE,
          'showMark' => FALSE,
        ),
        'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        'labelOptions' => array(
          'fontSize' => '11px',
        ),
      ),
    ),
    'grid' => array(
      'shadow' => FALSE,
      'borderWidth' => 0,
      'background' => '#e5e5e5',
      'gridLineColor' => '#ffffff',
    ),
  );
}

/**
 * Implementation of hook_ecenter_network_plot_options_alter().
 */
function ecenter_network_ecenter_network_plot_options_alter(&$options, $measurement, $type, $data = array()) {
  $line_options = array(
    'highlighter' => array(
      'show' => TRUE,
      'sizeAdjust' => 0,
      'lineWidthAdjust' => 0,
      'tooltipLocation' => 'n',
      'tooltipOffset' => 10,
      'tooltipSeparator' => ': ',
      'tooltipContentEditor' => '$.jqplot.Highlighter.errorTooltip',
    ),
    'cursor' => array(
      'show' => TRUE,
      'showTooltip' => FALSE,
      'zoom' => TRUE,
      'clickReset' => TRUE,
    ),
  );

  switch ($measurement) {
    case 'throughput':
      $options += $line_options;
      $options['axes']['yaxis']['label'] = t('mbps');
      $options['axes']['yaxis']['min'] = 0;
      $options['seriesDefaults']['renderer'] = '$.jqplot.BarRenderer';
      $options['seriesDefaults']['rendererOptions'] = array(
        'barWidth' => 2,
      );
      $options['axes']['xaxis']['tickOptions']['formatString'] = "%#m/%d";
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%dmbps</span>';
      break;
    case 'max_delay':
    case 'min_delay':
    case 'maxRtt':
    case 'minRtt':
    case 'medianRtt':
    case 'meanRtt':
    case 'maxIpd':
    case 'minIpd':
    case 'medianIpd':
    case 'meanIpd':
      $options += $line_options;
      $options['axes']['yaxis']['min'] = 0;
      $options['axes']['yaxis']['label'] = t('milliseconds');
      $options['axes']['yaxis']['tickOptions']['formatString'] = '%01.1f';
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%dms</span>';
      break;
    case 'loss':
      $options += $line_options;
      $options['axes']['yaxis']['min'] = 0;
      $options['axes']['yaxis']['label'] = t('loss');
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%d</span>';
      break;
    case 'utilization':
      $options += $line_options;
      $options['legend'] = array('show' => FALSE);
      $options['axes']['yaxis']['label'] = t('% utilization');
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%d%</span>';
      break;
  }

  // Final processing
  $options['series'] = array();
  foreach (array_keys($data) as $idx => $table) {
    $options['series'][$idx] = array('label' => t(ucfirst(str_replace('_', ' ', $table))));
    switch($table) {
      case 'forward_warning':
      case 'forward_critical':
      case 'reverse_warning':
      case 'reverse_critical':
        $options['series'][$idx] += array(
          'showLine' => FALSE,
          'markerOptions' => array('style' => 'filledSquare', 'size' => 10),
        );
    }
  }
}

/**
 * Theme query title
 */
function theme_ecenter_network_query_title($params, $data = NULL) {
  list($src_type, $src_value) = explode(':', $params['src']);
  list($dst_type, $dst_value) = explode(':', $params['dst']);

  $dates = array();
  foreach (array('start', 'end') as $val) {
    $dates[$val] = _ecenter_network_utc_to_local($params[$val], 
      'M j, Y H:i', $params['timezone']);
  }

  $circuit = (!empty($params['circuit'])) ? t(' | Circuit: <span class="value">@circuit</span>', array('@circuit' => $params['circuit'])) : NULL;

  return t('<span class="src-dst"><span class="value">@src_hub</span> to
<span class="value">@dst_hub</span>!circuit
</span><span class="separator"> - </span>
<span class="date-range"><span class="start">@start to</span> 
<span class="end">@end</span></span>',
    array(
      '@src_hub' => $src_value,
      '@dst_hub' => $dst_value,
      '@start' => $dates['start'],
      '@end' => $dates['end'],
      '!circuit' => $circuit,  
    )
  );
}

/**
 * Theme ecenter messages
 * @TODO Ugly string construction
 */
function theme_ecenter_network_messages($data, $params) {
  $items = array();
  if ($params['fds']) {
    $message = '<button class="clear-fds">'. t('Clear forecast') .'</button>'. 
      t('Showing forecast for <strong>@type</strong>', array('@type' => $params['fds_type']));
    if (empty($data['fds'])) {
      $message .= ' '. t('<span class="status-alert">(No forecast data available, try again later)</span>');
    }
    $items[] = $message;
  }
  if ($params['ads']) {
    $message = '<button class="clear-ads">'. t('Clear anomalies') .'</button>'. 
      t('Showing anomalies:');

    $anomalies = array();
    foreach ($data['ads'] as $type => $values) {
      if (!empty($values)) {
        $anomalies = $type;
      }
    }
    if (empty($anomalies)) {
      $message .= ' '. t('<span class="status-ok">No anomalies detected</span>');
    }
    else {
      $message .= ' '. t('<span class="status-alert">@types anomalies detected</span>', array('@types' => implode(', ', $anomalies)));
    }

    $items[] = $message;
  }

  return theme('item_list', $items, NULL, 'ul', array('class' => 'ecenter-messages'));
}
