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

  // DRS parameters
  $params = $data['drs']['parameters'];

  // All parameters
  $query_params = $data['parameters'];

  drupal_add_js(array('ecenterNetwork' => array('tracerouteData' => 
    $data['drs']['traceroute']['diff'])), 'setting');
  drupal_add_js(array('ecenterNetwork' => array('tracerouteMaxLength' => 
    $data['drs']['traceroute']['traceroute_max'])), 'setting');

  // Generate date range -- internal date is stored as UTC
  $dates = array();
  foreach (array('start', 'end') as $val) {
    $dates[$val] = _ecenter_network_utc_to_local($params[$val], 
      'M j, Y H:i', $query_params['timezone']);
  }

  if (empty($query_params['src'])) {
    list($src_type, $src_value) = explode(':', $params['src']);
  }
  else {
    list($src_type, $src_value) = explode(':', $query_params['src']);
  }
  if (empty($query_params['dst'])) {
    list($dst_type, $dst_value) = explode(':', $params['dst']);
  }
  else {
    list($dst_type, $dst_value) = explode(':', $query_params['dst']);
  }

  $vars['title'] = t('<span class="src-dst">@src_hub to
@dst_hub</span><span class="separator">, </span>
<span class="date-range">@start - @end</span>',
    array(
      '@src_hub' => $src_value,
      '@dst_hub' => $dst_value,
      '@start' => $dates['start'],
      '@end' => $dates['end'],
    )
  );

  if (!$vars['standalone']) {
    // Set title
    drupal_set_title(t('E-Center Network Query | ') . $vars['title']);

    // Generate issue link -- encode params for use with custom ecenter_issues
    // module
    if (module_exists('ecenter_issues') && user_access('create issue content')) {
      $issue_params = array();
      foreach ($params as $key => $param) {
        $issue_params[] = "$key=$param";
      }
      $issue_query = urlencode(implode('&', $issue_params));

      $vars['issuelink'] = l('Create issue from results', 'node/add/issue',
        array(
          'query' => array('query' => $issue_query),
        )
      );
    }

    $query = ecenter_issues_get_query_node($params);
    if ($query->nid) {
      $issue_links = array();
      $issues = ecenter_issues_get_query_issues($query);
      foreach ($issues as $issue) {
        $issue_links[] = l($issue->title, 'node/'. $issue->nid) . t(' by ') . $issue->name;
      }
      $vars['issues'] = '<label>'. t('Issues from this query: ') .'</label>'. implode(', ', $issue_links);
    }

    $ads = ecenter_network_ads_form($query_params['ads']);
    $vars['ads'] = drupal_render($ads);

    $fds = ecenter_network_fds_form($query_params['fds']);
    $vars['fds'] = drupal_render($fds);

    $timezones = array_map('_ecenter_network_process_tz_name', date_timezone_names());
    $timezone_select = array(
      '#type' => 'combobox',
      '#title' => t('Timezone'),
      '#value' => $query_params['timezone'],
      '#options' => $timezones,
      '#id' => 'timezone-select',
      '#name' => 'timezone',
    );
    if ($user->uid) {
      $timezone_select['#description'] = t('Timezone for results. <a href="@url">Set default timezone</a>.', array('@url' => url('user')));
    }
    else {
      $timezone_select['#description'] = t('Timezone for results. <a href="@login_url">Login</a> or <a href="@register_url">register</a> to set default.', array('@login_url' => url('user'), '@register_url' => url('user/register')));
    }
    $vars['timezone_select'] = drupal_render($timezone_select);
 
  }

  // End to end measurements
  $vars['end_to_end'] = theme('ecenter_network_end_to_end',
    $data['drs']['end_to_end'], $query_params['timezone'], $data['ads'], 
    $data['fds'], !$vars['standalone']);

  // Per-hop measurements
  $vars['hops'] = theme('ecenter_network_traceroute', 
    $data['drs']['traceroute']['diff'], $query_params['timezone'], $data['fds']);

  // Generate permalink
  $vars['permalink'] = l(t('Link'), 'network', array(
    'query' => $params,
    'absolute' => TRUE,
    'attributes' => array('title' => $vars['title']),
  ));
  $permalink_field['permalink'] = array(
    '#id' => 'ecenter-permalink',
    '#type' => 'textfield',
    '#size' => 115,
    '#attributes' => array('readonly' => 'readonly'),
    '#value' => url('network',
      array('query' => $params, 'absolute' => TRUE,)
    ),
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
              $forecast_table[] = array(
                'class' => 'forecast',
                'data' => array(
                  array('data' => $time, 'header' => TRUE),
                  theme($value_suggestions, $values['value'], $test, $measurement, FALSE),
                ),
              );

            }
            
            $data_tables[$test][$measurement][$direction .'_forecast'] = $forecast_table;
            //  array_merge($data_tables[$test][$measurement][$direction], $forecast_table);

            //$data_tables[$test][$measurement][$direction] = 
            //  array_merge($data_tables[$test][$measurement][$direction], $forecast_table);
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
      array('class' => 'end-to-end-table'));
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
          'class' => $direction,
          'data-jqplotHighlightColor' => '#ff0000',
        );


        $capacity = $hop['data']['snmp'][0][1]['capacity'];
        $tables[] = theme('ecenter_network_utilization_table', $table, $hop, $direction, $attributes, $capacity);

        if (!empty($fds_data['snmp']['utilization'][$hop['hop_ip']])) {
          $forecast_table = array();
          $forecast_data = $fds_data['snmp']['utilization'][$hop['hop_ip']];

          $last_value = array_pop($hop['data']['snmp']);
          $forecast_data[$last_value[0]] = array('value' => $last_value[1]['utilization']);

          foreach ($forecast_data as $timestamp => $forecast) {
            $time = _ecenter_network_timestamp_to_local($timestamp, 'Y-m-d H:i:s', $timezone);
            $forecast_table[] = array(
              'class' => 'forecast',
              'data' => array(
                'label' => array(
                  'data' => $time,
                  'header' => TRUE,
                ),
                'utilization' => array(
                  'data' => sprintf('%01.4f',
                    100 * ($forecast['value'] / $last_value[1]['capacity'])),
                  'class' => $class,
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

          $tables[] = theme('ecenter_network_utilization_table', $forecast_table,
            $hop, $direction, array('data-jqplotSeriesOptions' => '{"linePattern":"dashed"}'));
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
      foreach ($measurement_data as $key => $table) {
        $output .= '<div class="data-table">';
        $output .= '<h4>'. t(ucfirst($key)) .'</h4>';
        $output .= theme('jqplot_table', array(), $table);
        $output .= '</div>';
      }
      $output .= '</div>';

      $output .= '</div>';

      $plot_options = _ecenter_network_plot_options_template();
      $plot_options['legend'] = array(
        'show' => TRUE,
        'renderer' => '$.jqplot.EnhancedLegendRenderer',
        'placement' => 'outsideGrid',
        'location' => 's',
        'rendererOptions' => array(
          'numberRows' => 1,
        ),
      );

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
  
  $output = '<div class="data-table">';
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
    theme('jqplot_table', $headers, array($row));

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
        theme('jqplot_table', $headers, $table);
    }
  }
  return implode('', $tables);
}

/**
 * Get plot options template
 */
function _ecenter_network_plot_options_template() {
  return array( 
    'seriesDefaults' => array(
      'lineWidth' => 1.5,
      'shadow' => FALSE,
      'fill' => FALSE,
      'markerOptions' => array(
        'size' => 2,
        'shadow' => FALSE,
      ),
    ),
    'legend' => array(
      'show' => FALSE,
    ),
    'seriesColors' => array('#035dc5', '#a71932',), // '#133f52', '#e34605', '#672b18', '#049e33',  '#650fc2',),
    'axes' => array(
      'xaxis' => array(
        'autoscale' => TRUE,
        'numberTicks' => 9,
        'renderer' => '$.jqplot.DateAxisRenderer',
        'tickOptions' => array(
          'formatString' => "%H:%M",
        ),
        'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
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
      $options['axes']['yaxis']['label'] = t('mbps');
      $options['axes']['yaxis']['min'] = 0;
      $options['seriesDefaults']['renderer'] = '$.jqplot.BarRenderer';
      $options['seriesDefaults']['rendererOptions'] = array(
        'barWidth' => 2,
      );
      $options['axes']['xaxis']['tickOptions']['formatString'] = "%#m/%d";
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

