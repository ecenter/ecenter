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
    '#title' => t('Permalink'),
    '#size' => 45,
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
    $vars['end_to_end_table'] = '<p class="missing">'. t('No end to end data available') .'</p>';
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
  $plot_options = array(
    'width' => 570,
    'height' => 250,
    //'hideTables' => TRUE,
    'plotOptions' => array(
      'seriesDefaults' => array(
        'lineWidth' => 1.5,
        'shadow' => FALSE,
        'fill' => FALSE,
        'color' => '#aaaaaa',
        'markerOptions' => array(
          'show' => FALSE,
          'size' => 3,
        ),
      ),
      'axesDefaults' => array(
        'showTickMarks' => FALSE,
      ),
      'axes' => array(
        'xaxis' => array(
          'pad' => 0,
          'autoscale' => TRUE,
          'numberTicks' => 10,
          'renderer' => '$.jqplot.DateAxisRenderer',
          'tickOptions' => array(
            'formatString' => "%H:%M",
          ),
          'label' => t('Time'),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        ),
        'yaxis' => array(
          'min' => 0,
          'max' => 100,
          'numberTicks' => 6,
          'label' => t('Percent utilization'),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
          'tickOptions' => array(
            'formatString' => '%01.0f%',
            'color' => '#cccccc',
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
      'linehighlighter' => array(
        'threshold' => 4,
        'sizeAdjust' => 2,
      ),
      'cursor' => array(
        'show' => TRUE,
        'showTooltip' => FALSE,
        'zoom' => TRUE,
        'clickReset' => TRUE,
      ),
    ),
  );


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
  jqplot_register_tablechart('#utilization-tables', $plot_options);

  return '<div id="utilization-tables">'. implode("\n", $tables) .'</div>';
}

/**
 * Theme end to end data table
 */
function theme_ecenter_network_end_to_end($data) {
  $table = array();
  $data_tables = array();

  foreach ($data as $type => $measurements) {

    foreach (array('forward', 'reverse') as $direction) {
      if (!empty($measurements[$direction]['statistics'])) {
        foreach ($measurements[$direction]['statistics'] as $measurement => $statistics) {
          // Create suggestion array
          $suggestions = array(
            'ecenter_network_format_'. $type .'_'. $measurement,
            'ecenter_network_format_'. $type,
            'ecenter_network_format_default',
          );
          foreach ($statistics as $key => $value) {
            $statistics[$key] = array('data' => theme($suggestions, $value, $type, $measurement), 'class' => $key);
          }
          $table[$type .'_'. $measurement .'_'. $direction] = array(array('data' => ucfirst($direction) .' '. $measurement .' ('. $type .')', 'header' => TRUE)) + $statistics;
        }
        foreach ($measurements[$direction]['timeseries'] as $measurement => $timeseries) {
          $data_table = array();
          
          // Create suggestion array
          $suggestions = array(
            'ecenter_network_format_'. $type .'_'. $measurement,
            'ecenter_network_format_'. $type,
            'ecenter_network_format_default',
          );
          foreach ($timeseries as $timestamp => $value) {
            $data_table[] = array($timestamp, theme($suggestions, $value, $type, $measurement, FALSE));
          }
          $data_tables[] = '<div class="hide data-table '. $measurement .'"><h2>'. ucfirst($direction) .' '. $measurement .'</h2>'. theme('jqplot_table', array(t('Time'), t('Value')), $data_table) .'</div>';
        }
      }
    }
  }

  ksort($table);

  $headers = array(
    array('data' => '', 'class' => 'empty',),
    t('Average'), t('Max'), t('Min'),
  );

  if (!empty($table)) {
    return theme('jqplot_table', $headers, $table, array('class' => 'end-to-end-table')) . implode($data_tables, '');
  }
}

/**
 * Consolidated value formatter
 */
function theme_ecenter_network_format_default($value, $type = NULL, $measurement = NULL, $units = TRUE, $format = NULL) {
  if (!$units) {
    if ($format) {
      return sprintf($format, $value);
    }
    else {
      return $value;
    }
  }
  switch ($measurement) {
    case 'throughput':
      return theme('ecenter_network_format_value', number_format($value / (1000 * 1000), 0, '', ','), t('mbps'));
    case 'max_delay':
    case 'min_delay':
      return theme('ecenter_network_format_value', sprintf('%1.0f', $value * 1000), t('ms'));
    case 'minRtt':
    case 'maxRtt':
    case 'medianRtt':
    case 'meanRtt':
    case 'iqrIpd':
      return theme('ecenter_network_format_value', sprintf('%1.0f', $value), t('ms'));
    case 'loss': 
    case 'lossPercent': 
      return theme('ecenter_network_format_value', sprintf('%1.1f', $value), t('%'));
    default:
      return '<span class="value">'. sprintf('%1.0f', $value) .'</span>';
  }
}

/** 
 * Format a value
 */
function theme_ecenter_network_format_value($value, $units) {
  return '<span class="value">'. $value .'</span><span class="unit">'. $units .'</span>';
}

/**
 * Theme utilization table
 */
function theme_ecenter_network_utilization_table($hop, $direction, $table) {
  $attributes = array();
  $attributes['class'] = $direction;
  $attributes['class'] .= ($direction == 'forward') ? "{lineWidth : 1}" : "{lineWidth : 0, sizeAdjust: 0}";

  $headers = array(t('Time'), t('Percent utilization'));
  $output = '<div class="snmp-data-table">';
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
