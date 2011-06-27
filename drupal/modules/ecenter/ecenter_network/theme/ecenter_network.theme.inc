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
 
  // Source / dst table
  $hops = ecenter_network_get_hops();

  $src_hop = $hops['combined'][$vars['params']['src']];
  $dst_hop = $hops['combined'][$vars['params']['dst']];

  //dpm($vars);

  // Generate date range -- internal date is stored as UTC
  $dates = array();
  foreach (array('start', 'end') as $val) {
    $dates[$val] = _ecenter_network_utc_to_local($vars['params'][$val], 
      'M j, Y H:i', $vars['params']['timezone']);
  }

  $vars['title'] = t('<span class="src-dst">@src_hub_name (@src_hub) to
@dst_hub_name (@dst_hub)</span><span class="separator">, </span>
<span class="date-range">@start - @end</span>',
    array(
      '@src_hub_name' => $src_hop['hub_name'],
      '@src_hub' => $src_hop['hub'],
      '@dst_hub_name' => $dst_hop['hub_name'],
      '@dst_hub' => $dst_hop['hub'],
      '@start' => $dates['start'],
      '@end' => $dates['end'],
    )
  );

  // Set title
  drupal_set_title(t('E-Center Network Query | ') . $vars['title']);

  // Links and issue queries shouldn't take timezone argument 
  unset($vars['params']['timezone']);

  // Generate permalink
  $vars['permalink'] = l(t('Permanent link (bookmark and share results)'), 'network', array(
    'query' => $vars['params'],
    'absolute' => TRUE,
    'attributes' => array('title' => $vars['title']),
  ));
  $permalink_field['permalink'] = array(
    '#id' => 'ecenter-permalink',
    '#type' => 'textfield',
    '#size' => 115,
    '#attributes' => array('readonly' => 'readonly'),
    '#value' => url('network', 
      array('query' => $vars['params'], 'absolute' => TRUE,)
    ),
  );
  $vars['permalink_field'] = drupal_render($permalink_field);

  // Generate issue link -- encode params for use with custom ecenter_issues
  // module
  if (module_exists('ecenter_issues') && user_access('create issue content')) {
    $issue_params = array();
    foreach ($vars['params'] as $key=>$param) {
      $issue_params[] = "$key=$param";
    }
    $issue_query = urlencode(implode('&', $issue_params));

    $vars['issuelink'] = l('Create issue from these results', 'node/add/issue',
      array(
        'query' => array('query' => $issue_query),
      )
    );

    $query = ecenter_issues_get_query_node($vars['params']);
    if ($query->nid) {
      $issue_links = array();
      $issues = ecenter_issues_get_query_issues($query);
      foreach ($issues as $issue) {
        $issue_links[] = l($issue->title, 'node/'. $issue->nid) . t(' by ') . $issue->name;
      }
      $vars['issues'] = '<label>'. t('Issues from this query: ') .'</label>'. implode(', ', $issue_links);
    }
  }

  // End to end measurements
  $vars['end_to_end'] = theme('ecenter_network_end_to_end',
    $vars['data']['drs']['end_to_end'], $vars['data']['ads']);

  // Per-hop measurements
  $vars['hops'] = theme('ecenter_network_hops', $vars['data']['drs']['hops']);
}

/**
 * Theme end to end data table
 */
function template_preprocess_ecenter_network_end_to_end(&$vars) {
  $data = $vars['data'];

  $statistics_table = array();
  $data_tables = array();

  $ads = ecenter_network_ads_form();
  $vars['ads'] = drupal_render($ads);

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
          );
        }

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
            $time = _ecenter_network_timestamp_to_local($timestamp);
            $data_table[] = array(
              array('data' => $time, 'header' => TRUE),
              theme($value_suggestions, $value, $test, $measurement, FALSE)
            );
          }
          $data_tables[$test][$measurement][$direction] = $data_table;
          $data_tables[$test][$measurement]['start'] = $start;
          $data_tables[$test][$measurement]['end'] = $end;

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
      $data_tables);
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
function theme_ecenter_network_hops($hops = array()) {
  $tables = array();

  if (empty($hops)) {
    return t('No traceroute available.');
  }

  $settings = array();

  $sidx = 0;

  // Create tables for scraping
  foreach ($hops as $hop) {
    // @TODO Iterate over all types, use measurement / type callbacks
    $table = array();

    $settings['ecenterNetwork']['seriesLookupByIndex'][] = array(
      'id' => $hop['id'], 
      'hub' => $hop['hub']
    );
    $settings['ecenterNetwork']['seriesLookupByID'][$hop['id']] = array(
      'sidx' => $sidx,
      'hub' => $hop['hub'],
    );
    $settings['ecenterNetwork']['seriesLookupByHub'][$hop['hub']]['id'][] = $hop['id'];
    $settings['ecenterNetwork']['seriesLookupByHub'][$hop['hub']]['sidx'][] = $sidx;
    $sidx++;


    foreach ($hop['data']['snmp'] as $timeseries) {

      if (!empty($timeseries)) {
        $time = _ecenter_network_timestamp_to_local($timeseries[0]);
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
    if (!empty($table)) {
      $tables[] = theme('ecenter_network_utilization_table', $table, $hop);
    }
  }
  
  drupal_add_js($settings, 'setting');

  if (!empty($tables)) {

    $plot_options = _ecenter_network_plot_options_template();
    $plot_options['seriesDefaults']['markerOptions']['show'] = FALSE;
    $plot_options['seriesDefaults']['lineWidth'] = 0.85;
    $plot_options['seriesDefaults']['color'] = '#777777';
    $plot_options['axes']['xaxis']['pad'] = 0;
    $plot_options['axes']['xaxis']['numberTicks'] = 10;
    $plot_options['axes']['yaxis']['min'] = 0;
    $plot_options['axes']['yaxis']['max'] = 100;
    $plot_options['axes']['yaxis']['numberTicks'] = 5;
    $plot_options['linehighlighter'] = array(
      'show' => TRUE,
      'sizeAdjust' => 2.5,
      'threshold' => 4,
    );
    drupal_alter('ecenter_network_plot_options', $plot_options, 'utilization', 'snmp');
    $options = array(
      'height' => 175,
      'width' => 550,
      'hideTables' => FALSE,
      'parseX' => '$.tablechart.parseText',
      'dependencies' => array('canvasTextRenderer'),
      'plotOptions' => $plot_options,
    );
    jqplot_register_tablechart('#utilization-tables', $options);
    return '<div id="utilization-tables" class="wrapper"><div class="chart-title"><h3>'. 
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
function theme_ecenter_network_end_to_end_tables($tables) {
  $output = '';
  foreach ($tables as $type => $measurements) {
    foreach ($measurements as $measurement => $measurement_data) {
      $start = _ecenter_network_timestamp_to_local($measurement_data['start'], 'M j, Y H:i');
      $end = _ecenter_network_timestamp_to_local($measurement_data['end'], 'M j, Y H:i');

      unset($measurement_data['start'], $measurement_data['end']);

      $suggestions = array(
        'ecenter_network_format_'. $type .'_'. $measurement .'_label',
        'ecenter_network_format_'. $type .'_label',
        'ecenter_network_format_default_label',
      );
      $output .= '<div class="wrapper" id="'. $type .'-'. $measurement
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
      $plot_options['legend']['show'] = TRUE;

      drupal_alter('ecenter_network_plot_options', $plot_options, $measurement,
        $type, $measurement_data);
      $options = array(
        'height' => 125,
        'width' => 400,
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
function theme_ecenter_network_utilization_table($table, $hop) {
  $attributes = array();
  $attributes['class'] = $direction;

  $headers = array(t('Time'), t('Percent utilization'));
  $output = '<div class="data-table">';
  $output .= '<h3>'. $hop['nodename'] .' ('. $hop['ip_noted'] .')</h3>';
  $output .= theme('jqplot_table', $headers, $table, $attributes);
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
      'location' => 'se',
      'xoffset' => 1,
      'yoffset' => 1,
    ),
    'seriesColors' => array('#035dc5', '#a71932', '#133f52', '#e34605', '#672b18', '#049e33',  '#650fc2',),
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
      'background' => '#ffffff',
      'gridLineColor' => '#cccccc',
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

