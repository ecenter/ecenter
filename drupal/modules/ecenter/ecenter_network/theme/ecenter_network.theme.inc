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
  // Generate permalink
  $permalink['permalink'] = array(
    '#type' => 'textfield',
    '#size' => 45,
    '#title' => l(t('Permalink'), 'network',
      array('query' => $vars['params'], 'absolute' => TRUE,)
    ),
    '#value' => url('network', 
      array('query' => $vars['params'], 'absolute' => TRUE,)
    ),
  );
  $vars['permalink'] = drupal_render($permalink);
  
  // Generate issue link -- encode params for use with custom ecenter_issues
  // module
  // @TODO Move into menu for features export?
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

  // End to end statistics
  if (!empty($vars['data']['end_to_end'])) {
    $vars['end_to_end'] = theme('ecenter_network_end_to_end', $vars['data']['end_to_end']);
  }
  else {
    $vars['end_to_end'] = '<p class="missing">'. t('No end to end data available') .'</p>';
  }

  // Generate SNMP charts
  if (!empty($vars['data']['diff'])) {
    $vars['hops'] = theme('ecenter_network_hops', $vars['data']['diff']);
  }
  else {
    $vars['hops'] = '<p class="missing">'. t('No path or utilization data available.') .'</p>';
  }

}

/**
 * Theme SNMP data
 */
function theme_ecenter_network_hops($data) {

  // @TODO Determine how to set colors...  MESSY!
  $critical = variable_get('ecenter_network_threshold_critical_snmp_utilization', 60);
  $marginal = variable_get('ecenter_network_threshold_marginal_snmp_utilization', 40);

  //$tables = array('forward', 'reverse');
  $tables = array();

  // Create tables for scrapin'
  foreach ($data as $row) {
    $match = (!empty($row['match'])) ? TRUE : FALSE;
    $all_hops = array_shift(array_values($row));

    foreach (array('forward', 'reverse') as $direction) {

      $hops = $all_hops[$direction];

      if (!empty($hops) && is_array($hops)) {
        foreach ($hops as $hop) {
          if (!empty($hop['data']['snmp']) && is_array($hop['data']['snmp'])) {
            $table = array();
            foreach ($hop['data']['snmp'] as $item) {
              $table[] = array(
                'label' => array(
                  'data' => $item[0] * 1000,
                  'header' => TRUE,
                ),
                'utilization' => array(
                  'data' => sprintf('%01.4f', 100 * ($item[1]['utilization'] / $item[1]['capacity'])),
                  'class' => $class,
                ),
              );
            }
            $tables[] = theme('ecenter_network_utilization_table', $hop['hop'], $direction, $table);
          }
        }
      }
    }
  }
  //jqplot_register_tablechart('#utilization-tables', $plot_options);

  return '<div id="utilization-tables">'. implode("\n", $tables) .'</div>';
}

/**
 * Theme end to end data table
 */
function template_preprocess_ecenter_network_end_to_end(&$vars) {
  $raw_data = $vars['data'];
  $statistics_table = array();
  $data_tables = array();

  foreach ($raw_data as $type => $measurements) {
    foreach ($measurements as $direction=>$data) {
      if (($statistics = $data['statistics']) && is_array($statistics)) {
        foreach ($statistics as $measurement => $row) {
          // Suggestion array to format values
          $suggestions = array(
            'ecenter_network_format_'. $type .'_'. $measurement,
            'ecenter_network_format_'. $type,
            'ecenter_network_format_default',
          );
          // Theme each statistic
          foreach ($row as $key => $value) {
            $row[$key] = array('data' => theme($suggestions, $value, $type, $measurement), 'class' => $key);
          }

          // Suggestion array to format label
          $suggestions = array(
            'ecenter_network_format_'. $type .'_'. $measurement .'_label',
            'ecenter_network_format_'. $type .'_label',
            'ecenter_network_format_default_label',
          );

          // Create table row for theming
          $header = array(
            'header' => TRUE,
            'data' => theme($suggestions, $measurement, $type, $direction, TRUE),
          );
          $table[$type .'_'. $measurement .'_'. $direction] = array(
            'data' => array($header) + $row,
            'class' => $type .'_'. $measurement .' '. $type .'_'. $measurement .'_'. $direction,
          ); 
        }
      }

      if (($timeseries = $data['timeseries']) && is_array($timeseries)) {
        foreach ($timeseries as $measurement => $series) {

          if (!in_array($measurement, array('throughput', 'max_delay', 'loss'))) {
            continue;
          }

          // Suggestion array to format values
          $suggestions = array(
            'ecenter_network_format_'. $type .'_'. $measurement,
            'ecenter_network_format_'. $type,
            'ecenter_network_format_default',
          );

          $data_table = array();
          foreach ($series as $timestamp => $value) {
            // Note we multiple x 1000 because Javascript uses microseconds!
            $data_table[] = array(array('data' => $timestamp * 1000, 'header' => TRUE), theme($suggestions, $value, $type, $measurement, FALSE));
          }

          $data_tables[$type][$measurement][$direction] = $data_table;
        }
      }  
    }
  }

  // Sort table
  ksort($table);

  $headers = array(
    array('data' => t('End-to-end results'), 'class' => 'result-header',),
    t('Average'), t('Max'), t('Min'),
  );

  if (!empty($table)) {
    $vars['table'] = theme('jqplot_table', $headers, $table, array('class' => 'end-to-end-table'));
    $vars['data_tables'] = theme('ecenter_network_end_to_end_tables', $data_tables);
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
      $output .= '<div class="wrapper" id="'. $type .'-'. $measurement .'-data-tables">';
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
      drupal_alter('ecenter_network_plot_options', $plot_options, $measurement, $type);  
      $options = array(
        'height' => 150,
        'width' => 400,
        'hideTables' => FALSE,
        'plotOptions' => $plot_options,
      );
      jqplot_register_tablechart('#'. $type .'-'. $measurement .'-data-tables', $options);
    }
  }
  return $output;
}

function ecenter_network_ecenter_network_plot_options_alter(&$options, $measurement, $type) {
  $options['series'] = array(
    array('label' => t('Forward'),),
    array('label' => t('Reverse'),),
  );
  switch ($measurement) {
    case 'throughput':
      $options['axes']['yaxis']['label'] = t('mbps');
      return;
    case 'max_delay':
      $options['axes']['yaxis']['label'] = t('milliseconds');
      return;
    case 'loss':
      $options['axes']['yaxis']['label'] = t('%');
      return;

  }
}

function _ecenter_network_plot_options_template() {
  return array( 
    'seriesDefaults' => array(
      'lineWidth' => 1.5,
      'shadow' => FALSE,
      'fill' => FALSE,
      'markerOptions' => array(
        'size' => 4,
        'shadow' => FALSE,
      ),
    ),
    'legend' => array(
      'location' => 'se',
      'xoffset' => 1,
      'yoffset' => 1,
    ),
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
        'min' => 0,
        'numberTicks' => 4,
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
    'highlighter' => array(
      'show' => TRUE,
      'sizeAdjust' => 2,
      'lineWidthAdjust' => 3,
      'tooltipLocation' => 'n',
      'tooltipOffset' => 20,
      'tooltipSeparator' => ': ',
    ),
    'cursor' => array(
      'show' => TRUE,
      'showTooltip' => FALSE,
      'zoom' => TRUE,
      'clickReset' => TRUE,
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
    case 'minRtt':
    case 'maxRtt':
    case 'medianRtt':
    case 'meanRtt':
    case 'iqrIpd':
      $format = ($format) ? $format : '%1.0f';
      $measurement_units = ($units) ? t('ms') : NULL;
      return theme('ecenter_network_format_value', sprintf($format, $value), $mesurement_units);
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
function theme_ecenter_network_format_default_label($measurement, $type = NULL, $direction = NULL, $help = NULL) {
  if ($help) {
    switch ($measurement) {
      case 'maxRTT':
      case 'max_delay':
        $help = theme('advanced_help_topic', 'ecenter_network', 'rtt');
      default:
        $help = NULL;
    }
  }
  
  $type = ($type) ? t('(@type)', array('@type' => $type)) : '';
  return $help . t(ucfirst($direction)) .' '. t(ucfirst(str_replace('_', ' ', $measurement))) .' '. $type; 
}


/**
 * Format a value
 */
function theme_ecenter_network_format_value($value, $units = NULL) {
  $output = '<span class="value">'. $value .'</span>';
  $output .= ($units) ? '<span class="unit">'. $units .'</span>' : '';
  return $output;
}

/**
 * Theme utilization table
 */
function theme_ecenter_network_utilization_table($hop, $direction, $table) {
  $attributes = array();
  $attributes['class'] = $direction;
  $attributes['class'] .= ($direction == 'forward') ? "{lineWidth : 1}" : "{lineWidth : 0, sizeAdjust: 0}";

  $headers = array(t('Time'), t('Percent utilization'));
  $output = '<div class="data-table">';
  $output .= '<h3>'. $hop['nodename'] .' ('. t(ucfirst($direction)) .')</h3>';
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
