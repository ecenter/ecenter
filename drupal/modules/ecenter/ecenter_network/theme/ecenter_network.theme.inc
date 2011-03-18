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

  // Generate issue link -- encode params for use with custom ecenter_issues
  // module
  if (module_exists('ecenter_issues') && user_access('create ecenter issue content')) {
    $issue_params = array();
    foreach ($vars['params'] as $key=>$param) {
      $issue_params[] = "$key=$param";
    }
    $issue_query = urlencode(implode('&', $issue_params));

    $vars['issuelink'] = l('Create issue from this query', 'node/add/issue',
      array(
        'query' => array('query' => $issue_query),
      )
    );
  }

  // Source / dst table
  $hops = ecenter_network_get_hops();

  $src_hop = $hops['combined'][$vars['params']['src']];
  $dst_hop = $hops['combined'][$vars['params']['dst']];

  // Generate date range -- internal date is stored as UTC
  $dates = array();
  foreach (array('start', 'end') as $val) {
    $date = date_create($vars['params'][$val]);
    $dates[$val] = date_format($date, 'M j, Y H:i');
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
      '@end' => $dates['end']
    )
  );

  // Set title
  drupal_set_title(t('E-Center Network Query | ') . $vars['title']);

  // Generate permalink
  $vars['permalink'] = l(t('Permalink'), 'network', array(
    'query' => $vars['params'],
    'absolute' => TRUE,
    'attributes' => array('title' => $vars['title']),
  ));
  // Generate permalink
  $permalink_field['permalink'] = array(
    '#id' => 'ecenter-permalink',
    '#type' => 'textfield',
    '#size' => 115,
    '#disabled' => TRUE,
    '#value' => urldecode(url('network',
      array('query' => $vars['params'], 'absolute' => TRUE,)
    )),
  );
  $vars['permalink_field'] = drupal_render($permalink_field);

  // End to end measurements
  $vars['end_to_end'] = theme('ecenter_network_end_to_end',
    $vars['data']['end_to_end']);

  // Per-hop measurements
  $vars['hops'] = theme('ecenter_network_hops', $vars['data']['hops']);

}

/**
 * Theme recent user queries
 */
function template_preprocess_ecenter_network_recent_queries(&$vars) {
  global $user;
  if ($user->uid > 0) {
    $queries = $user->ecenter_network_queries;
  }
  else if (isset($_COOKIE[session_name()])) {
    $queries = unserialize(sess_read('ecenter_network_queries'));
  }

  if (!empty($queries)) {
    $links = array();
    foreach ($queries as $query) {
      $tz = date_default_timezone_name(TRUE);
      $time = date_make_date($query['time'], timezone_open('UTC'), DATE_UNIX);
      date_timezone_set($time, timezone_open($tz));
      $links[] = theme('ecenter_network_recent_query', $query['query'], $time);
    }
    $vars['queries'] = array_reverse($links);
  }
  else {
    $vars['queries'] = array(t('No recent queries available.'));
  }
}

/**
 * Theme a single query link
 */
function theme_ecenter_network_recent_query($query, $time) {
  $query_text = array();
  $query_parts = explode('&amp;', urldecode($query));
  foreach ($query_parts as $part) {
    list($key, $value) = explode('=', $part);
    $query_text[] = '<span class="key '. $key .'">'. strtoupper($key) .':</span> '.
      '<span class="value">'. $value .'</span>';
  }

  $date = '<span class="date"><a href="'. urldecode(url('network') .'?'. $query) .'">'.
    date_format($time, 'n-j-Y g:ia') .'</a></span>';
  $query = '<span class="query">'. implode(' | ', $query_text) .'</span>';

  return $date .' '. $query;
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

  // Create tables for scraping
  foreach ($hops as $hop) {
    // @TODO Iterate over all types, use measurement / type callbacks
    $table = array();

    $settings['ecenterNetwork']['seriesLookupByIndex'][] = array('id' => $hop['id'], 'hub' => $hop['hub']);

    foreach ($hop['data']['snmp'] as $timeseries) {
      if (!empty($timeseries)) {
        $table[] = array(
          'label' => array(
            'data' => $timeseries[0] * 1000,
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

  foreach ($settings['ecenterNetwork']['seriesLookupByIndex'] as $sidx => $hop) {
    $settings['ecenterNetwork']['seriesLookupByID'][$hop['id']] = array(
      'sidx' => $sidx,
      'hub' => $hop['hub'],
    );
    if (!is_array($settings['ecenterNetwork']['seriesLookupByHub'][$hop['hub']])) {
      $settings['ecenterNetwork']['seriesLookupByHub'][$hop['hub']] = array();
    }
    $settings['ecenterNetwork']['seriesLookupByHub'][$hop['hub']] += array(
      'sidx' => array($sidx),
      'id' => array($hop['id']),
    );
  }

  if (!empty($tables)) {
    drupal_add_js($settings, 'setting');

    $plot_options = _ecenter_network_plot_options_template();
    $plot_options['seriesDefaults']['markerOptions']['show'] = FALSE;
    $plot_options['seriesDefaults']['lineWidth'] = 1;
    $plot_options['seriesDefaults']['color'] = '#999999';
    $plot_options['axes']['xaxis']['pad'] = 0;
    $plot_options['axes']['xaxis']['numberTicks'] = 10;
    $plot_options['axes']['yaxis']['min'] = 0;
    $plot_options['axes']['yaxis']['max'] = 100;
    $plot_options['axes']['yaxis']['numberTicks'] = 5;
    $plot_options['linehighlighter'] = array(
      'show' => TRUE,
      'sizeAdjust' => 2.5,
      'threshold' => 2,
    );
    drupal_alter('ecenter_network_plot_options', $plot_options, 'utilization', 'snmp');
    $options = array(
      'height' => 175,
      'width' => 600,
      'hideTables' => FALSE,
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
 * Theme end to end data table
 */
function template_preprocess_ecenter_network_end_to_end(&$vars) {
  $data = $vars['data'];
  $statistics_table = array();
  $data_tables = array();

  foreach ($data as $test => $directions) {
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
            'class' => $test .'_'. $measurement .' '. $test .'_'. $measurement
              .'_'. $direction,
          );

        }

        if (($timeseries = $values['timeseries']) && is_array($timeseries)
          && $values['statistics']['max'] > 0) {
          $data_table = array();
          foreach ($timeseries as $timestamp => $value) {
            // Note we multiple x 1000 because Javascript uses microseconds!
            $data_table[] = array(array('data' => $timestamp * 1000, 'header' => TRUE), theme($value_suggestions, $value, $test, $measurement, FALSE));
          }
          $data_tables[$test][$measurement][$direction] = $data_table;
        }
      }
    }
  }

  if (!empty($table)) {
    // Sort table
    ksort($table);

    $headers = array(
      array('data' => 'Measurement', 'class' => 'result-header',),
      t('Average'), t('Median'), t('Max'), t('Min'),
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
 * Theme end to end data tables for plotting
 */
function theme_ecenter_network_end_to_end_tables($tables) {
  $output = '';
  foreach ($tables as $type => $measurements) {
    foreach ($measurements as $measurement => $directions) {
      $suggestions = array(
        'ecenter_network_format_'. $type .'_'. $measurement .'_label',
        'ecenter_network_format_'. $type .'_label',
        'ecenter_network_format_default_label',
      );
      $output .= '<div class="wrapper" id="'. $type .'-'. $measurement
        .'-data-tables">';
      $output .= '<div class="chart-title"><h3>'.
        theme($suggestions, $measurement, $type) .'</h3></div>';

      $output .= '<div class="data-tables">';
      foreach ($directions as $direction => $data) {
        $output .= '<div class="data-table">';
        $output .= '<h4>'. t(ucfirst($direction)) .'</h4>';
        $output .= theme('jqplot_table', array(), $data);
        $output .= '</div>';
      }
      $output .= '</div>';
      $output .= '</div>';

      $plot_options = _ecenter_network_plot_options_template();
      $plot_options['legend']['show'] = TRUE;
      drupal_alter('ecenter_network_plot_options', $plot_options, $measurement,
        $type);
      $options = array(
        'height' => 150,
        'width' => 400,
        'hideTables' => FALSE,
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
 * Implementation of hook_ecenter_network_plot_options_alter().
 */
function ecenter_network_ecenter_network_plot_options_alter(&$options, $measurement, $type) {
  $options['series'] = array(
    array('label' => t('Forward'),),
    array('label' => t('Reverse'),),
  );
  $line_options = array(
    'highlighter' => array(
      'show' => TRUE,
      'sizeAdjust' => 1,
      'lineWidthAdjust' => 2,
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
      $options['seriesDefaults']['renderer'] = '$.jqplot.BarRenderer';
      $options['seriesDefaults']['rendererOptions'] = array(
        'barWidth' => 7,
      );
      return;
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
      $options['axes']['yaxis']['label'] = t('milliseconds');
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%dms</span>';
      return;
    case 'loss':
      $options += $line_options;
      $options['axes']['yaxis']['min'] = 0;
      $options['axes']['yaxis']['label'] = t('% loss');
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%d%</span>';
      return;
    case 'utilization':
      $options += $line_options;
      $options['axes']['yaxis']['label'] = t('% utilization');
      $options['highlighter']['formatString'] = '<span class="date">%s:</span> <span class="value">%d%</span>';
      return;
  }
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
        'size' => 5,
        'shadow' => FALSE,
      ),
    ),
    'legend' => array(
      'location' => 'ne',
      'xoffset' => 1,
      'yoffset' => 1,
    ),
    'seriesColors' => array('#035dc5', '#e34605', '#a71932', '#133f52', '#672b18', '#049e33',  '#650fc2',),
    'axes' => array(
      'xaxis' => array(
        'autoscale' => TRUE,
        'numberTicks' => 8,
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
  switch ($hop['type']) {
    case 'hub':
      return check_plain($hop['hub_name']);
    case 'ip':
      return check_plain($hop['hub_name']) .' ('. check_plain($hop['hub']) .' - '. check_plain($hop['ip_noted']) .')';
  }
}
