<?php
// $Id$

/**
 * @file
 * E-Center Weathermap theming.
 */

/**
 * Theme main data display
 */
function template_preprocess_ecenter_network_data(&$vars) {
  // Generate permalink
  $permalink['permalink'] = array(
    '#type' => 'textfield',
    '#title' => t('Permalink'),
    '#value' => url('network', 
      array('query' => $vars['params'], 'absolute' => TRUE,)
    ),
  );
  $vars['permalink'] = drupal_render($permalink);
  // Generate issue link -- encode params for use with custom ecenter_issues
  // module
  if (user_access('create issue content')) {
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

  $query_table = array(
    array(
      array(
        'data' => t('Source'),
        'header' => TRUE,
      ),
      array(
        'data' => $src_hop['hub_name'] .' ('. $src_hop['hub'] .')',
      ),
    ),
    array(
      array(
        'data' => t('Destination'),
        'header' => TRUE,
      ),
      array(
        'data' => $dst_hop['hub_name'] .' ('. $dst_hop['hub'] .')',
      ),
    ),
  );

  $vars['src_dst'] = t('From @src_hub_name (@src_hub) to @dst_hub_name (@dst_hub)', 
    array(
      '@src_hub_name' => $src_hop['hub_name'],
      '@src_hub' => $src_hop['hub'],
      '@dst_hub_name' => $dst_hop['hub_name'],
      '@dst_hub' => $dst_hop['hub'],
    )
  );

  // Generate date range -- internal date is stored as UTC
  //$utc = timezone_open('UTC');
  //$tz = timezone_open(date_default_timezone_name(TRUE));
  $dates = array();
  foreach (array('start', 'end') as $val) {
    $date = date_create($vars['params'][$val]);
    $dates[$val] = date_format($date, 'M j, Y H:i');
  }
  $vars['date_range'] = t('@start - @end', array('@start' => $dates['start'], '@end' => $dates['end']));

  // Generate SNMP charts
  if (!empty($vars['data']['diff'])) {
    $vars['snmp'] = theme('ecenter_network_render_data_snmp', $vars['data']['diff']);
  }
  else {
    $vars['snmp'] = '<p class="missing">'. t('No path or utilization data available.') .'</p>';
  }

  // Generate end to end statistics
  if (!empty($vars['data']['end_to_end'])) {
    $vars['end_to_end_table'] = theme('ecenter_network_render_data_end_to_end_table', $vars['data']['end_to_end']);
  }
  else {
    $vars['end_to_end_table'] = '<p class="missing">'. t('No end to end data available') .'</p>';
  }
}

/**
 * Theme SNMP data
 */
function theme_ecenter_network_render_data_snmp($data) {
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
            //$tables[$direction][] = theme('ecenter_network_utilization_table', $hop['hop'], $direction, $table);
          }
        }
      }
    }
  }
  jqplot_register_tablechart('#utilization-tables', $plot_options);

  /*$forward = '<h3>'. t('Forward') .'</h3>'
    .'<div id="forward-tables" class="utilization-table">'
    . implode("\n", $tables['forward']) .'</div>';
  $reverse = '<h3>'. t('Reverse') .'</h3>'
    .'<div id="reverse-tables" class="utilization-table">'
    . implode("\n", $tables['reverse']) .'</div>';

  jqplot_register_tablechart('#forward-tables', $plot_options);
  jqplot_register_tablechart('#reverse-tables', $plot_options);*/

  return '<div id="utilization-tables">'. implode("\n", $tables) .'</div>';
  //return $forward . $reverse;
}

/**
 * Theme end to end data table
 */
function theme_ecenter_network_render_data_end_to_end_table($data) {
  // BWCTL
  /*if (!empty($data['bwctl']['forward'])) {
    foreach ($data['bwctl']['forward'] as $item) {
      list($timestamp, $values) = $item;
      $tz = date_default_timezone_name(TRUE);
      $date = date_make_date($timestamp, $tz, DATE_UNIX);
    }
  }*/

  $table = array();
  $headers = array(
    array(
      'data' => '',
      'class' => 'empty',
    ),
    t('Average'),
    t('Max'),
    t('Min')
  );


  foreach (array('forward', 'reverse') as $direction) {
    $dir_label = ($direction == 'forward') ? t('Forward') : t('Reverse');

    if (!empty($data['bwctl'][$direction])) {

      $mean_throughput = array();
      $max_throughput = NULL;
      $min_throughput = NULL;

      foreach ($data['bwctl'][$direction] as $item) {
        list($timestamp, $values) = $item;

        $mean_throughput[] = $values['throughput'];
        $max_throughput = ($values['throughput'] > $max_throughput) 
          ? $values['throughput'] : $max_throughput;
        $min_throughput = (!$min_throughput || ($values['throughput'] < $min_throughput)) 
          ? $values['throughput'] : $min_throughput;
      }

      $mean_throughput = array_sum($mean_throughput) / count($mean_throughput);

      $table['0_' . $direction] = array(
        array(
          'data' => t('@direction Throughput', 
            array('@direction' => ucfirst($dir_label))),
          'header' => TRUE,
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $mean_throughput / 1e+6) 
            .'</span><span class="unit">'. t('mbps') .'</span>',
          'class' => 'avg',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $max_throughput / 1e+6) 
            .'</span><span class="unit">'. t('mbps') .'</span>',
          'class' => 'max',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $min_throughput / 1e+6) 
            .'</span><span class="unit">'. t('mbps') .'</span>',
          'class' => 'min',
        ),
      );

    }

    if (!empty($data['pinger'][$direction])) {

      $mean_rtt = array();
      $mean_iqripd = array();
      $mean_loss = array();

      $max_rtt = NULL;
      $min_rtt = NULL;
      $max_iqripd = NULL;
      $min_iqripd = NULL;
      $max_loss = NULL;
      $min_loss = NULL;

      foreach ($data['pinger'][$direction] as $item) {
        list($timestamp, $values) = $item;

        $mean_rtt[] = $values['meanRtt'];
        $max_rtt = ($values['maxRtt'] > $max_rtt) 
          ? $values['maxRtt'] : $max_rtt;
        $min_rtt = (!$min_rtt || ($values['minRtt'] < $min_rtt)) 
          ? $values['minRtt'] : $min_rtt;

        $mean_iqripd[] = $values['iqrIpd'];

        $mean_loss[] = $values['lossPercent'];
        $max_loss = ($values['lossPercent'] > $max_loss) 
          ? $values['lossPercent'] : $max_loss;
        $min_loss = (!$min_loss || ($values['lossPercent'] < $min_loss)) 
          ? $values['lossPercent'] : $min_loss;
      }

      $mean_rtt = array_sum($mean_rtt) / count($mean_rtt);
      $mean_iqripd = array_sum($mean_iqripd) / count($mean_iqripd);
      $mean_loss = array_sum($mean_loss) / count($mean_loss);

      $table['1_' . $direction] = array(
        array(
          'data' => t('@direction RTT', array('@direction' => ucfirst($dir_label))),
          'header' => TRUE,
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $mean_rtt) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'avg',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $max_rtt) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'max',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $min_rtt) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'min',
        ),
      );

      $table['3_' . $direction] = array(
        array(
          'data' => t('@direction Packet Loss', array('@direction' => ucfirst($dir_label))),
          'header' => TRUE,
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $mean_loss) 
            .'</span><span class="unit">'. t('%') .'</span>',
          'class' => 'avg',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $max_loss) 
            .'</span><span class="unit">'. t('%') .'</span>',
          'class' => 'max',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $min_loss) 
            .'</span><span class="unit">'. t('%') .'</span>',
          'class' => 'min',
        ),
      );

      $table['4_' . $direction] = array(
        array(
          'data' => t('@direction Jitter', 
            array('@direction' => ucfirst($dir_label))),
          'header' => TRUE,
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.2f', $mean_iqripd) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'avg',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.2f', $max_iqripd) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'max',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.2f', $min_iqripd) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'min',
        ),
      );

    }


    if (!empty($data['owamp'][$direction])) {
      $mean_delay = array();
      $max_delay = NULL;
      $min_delay = NULL;

      foreach ($data['owamp'][$direction] as $item) {
        list($timestamp, $values) = $item;
        $mean_delay[] = ($values['max_delay'] + $values['min_delay']) / 2;
        $max_delay = ($values['max_delay'] > $max_delay) 
          ? $values['max_delay'] : $max_delay;
        $min_delay = (!$min_delay || ($values['min_delay'] < $min_delay)) 
          ? $values['min_delay'] : $min_delay;
      }

      $mean_delay = array_sum($mean_delay) / count($mean_delay);

      $table['2_' . $direction] = array(
        array(
          'data' => t('@direction Delay', array('@direction' => ucfirst($dir_label))),
          'header' => TRUE,
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $mean_delay * 1000) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'avg',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $max_delay * 1000) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'max',
        ),
        array(
          'data' => '<span class="value">'. sprintf('%01.1f', $min_delay * 1000) 
            .'</span><span class="unit">'. t('ms') .'</span>',
          'class' => 'min',
        ),
      );
    }
  }

  ksort($table);
  if (!empty($table)) {
    return theme('jqplot_table', $headers, $table, array('class' => 'end-to-end-table'));
  }
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
