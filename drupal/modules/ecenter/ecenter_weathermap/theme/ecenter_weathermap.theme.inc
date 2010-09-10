<?php
// $Id$

/**
 * @file
 * E-Center Weathermap theming.
 */

/**
 * Theme main data display
 */
function template_preprocess_ecenter_weathermap_data(&$vars) {
  //dpm($vars['data']);

  // Generate permalink
  $vars['permalink'] = l('Permalink', 'weathermap', array('query' => $vars['params']));

  // Generate issue link -- encode params for use with prepopulate module
  $issue_params = array();
  foreach ($vars['params'] as $key=>$param) {
    $issue_params[] = "$key=$param";
  }
  $issue_query = urlencode(implode('&', $issue_params));

  $vars['issuelink'] = l('Create issue from this query', 'node/add/issue',
    array(
      'query' => array(
        'edit[field_issue_query][0][value]' => $issue_query,
      ),
      'attributes' => array(
        'class' => 'button',
      ),
    )
  );

  // Source / dst table
  $src_hops = ecenter_weathermap_get_hops();
  $dst_hops = ecenter_weathermap_get_hops($vars['params']['src_ip']);
  $query_table = array(
    array(
      array(
        'data' => t('Source'),
        'header' => TRUE,
      ),
      array(
        'data' => $src_hops[$vars['params']['src_ip']]->nodename
      ),
    ),
    array(
      array(
        'data' => t('Destination'),
        'header' => TRUE,
      ),
      array(
        'data' => $dst_hops[$vars['params']['dst_ip']]->nodename
      ),
    ),
  );
  $vars['query_table'] = theme('ecenter_weathermap_table', array(), $query_table, array('class' => 'path-table'));

  // Generate date range -- internal date is stored as UTC
  $utc = timezone_open('UTC');
  $tz = timezone_open(date_default_timezone_name(TRUE));
  $dates = array();
  foreach (array('start', 'end') as $val) {
    $date = date_create($vars['params'][$val], $utc);
    date_timezone_set($date, $tz);
    $dates[$val] = date_format($date, 'M j, Y H:i');
  }
  $vars['date_range'] = t('@start - @end', array('@start' => $dates['start'], '@end' => $dates['end']));

  // Generate SNMP charts
  if (!empty($vars['data']['diff'])) {
    $vars['snmp'] = theme('ecenter_weathermap_render_data_snmp', $vars['data']['diff']);
  }

  // Generate end to end statistics
  if (!empty($vars['data']['end_to_end'])) {
    $vars['end_to_end_table'] = theme('ecenter_weathermap_render_data_end_to_end_table', $vars['data']['end_to_end']);
  }
  else {
    $vars['end_to_end_table'] = t('No end to end data available');
  }
}

/**
 * Theme SNMP data
 */
function theme_ecenter_weathermap_render_data_snmp($data) {

  $plot_options = array(
    'width' => 580,
    'height' => 200,
    'hideTables' => TRUE,
    'plotOptions' => array(
      'seriesDefaults' => array(
        'lineWidth' => 1.5,
        'shadow' => FALSE,
        'fillAndStroke' => TRUE,
        'markerOptions' => array(
          'show' => FALSE,
        ),
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
          'label' => t('Time (@date)', array('@date' => $date_label)),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        ),
        'yaxis' => array(
          'min' => 0,
          'max' => 100,
          'pad' => 0,
          'numberTicks' => 6,
          'label' => t('Percent utilization'),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
          'tickOptions' => array(
            'formatString' => '%01.2f%'
          ),
        ),
      ),
      'grid' => array(
        'shadow' => FALSE,
        'borderWidth' => 0,
        'background' => '#eeeeee',
        'gridLineColor' => '#ffffff',
      ),
      'highlighter' => array(
        'sizeAdjust' => 1,
        'lineWidthAdjust' => 1,
        'tooltipLocation' => 'n',
        'tooltipOffset' => 20,
        'tooltipSeparator' => ': ',
      ),
      'cursor' => array(
        'showToolTip' => FALSE,
        'zoom' => TRUE,
        'clickReset' => TRUE,
        //'constrainZoomTo' => 'x',
      ),
    ),
  );

  // @TODO Determine how to set colors...  MESSY!
  $critical = variable_get('ecenter_weathermap_threshold_critical_snmp_utilization', 60);
  $marginal = variable_get('ecenter_weathermap_threshold_marginal_snmp_utilization', 40);

  $headers = array(t('Time'), t('Percent utilization'));

  $i = 0;

  // @TODO whoa, way nested, really ugly and complicated
  foreach ($data as $row) {
    $table = array();
    $match = (!empty($row['match'])) ? TRUE : FALSE;

    $all_hops = array_shift(array_values($row));

    foreach (array('forward', 'reverse') as $direction) {\

      $hops = $all_hops[$direction];

      if (!empty($hops) && is_array($hops)) {
        foreach ($hops as $hop) {
          if (!empty($hop['data']['snmp']) && is_array($hop['data']['snmp'])) {
            foreach ($hop['data']['snmp'] as $item) {
              $table[$direction][] = array(
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
          }
        }
      }
    }

    $output = '';
    if ($match) {
      $id = $row['match']['forward'][0]['hop']['hop_id'];
      $output .= '<div class="snmp-chart-wrapper" id="hop-'. $id .'">';
      $output .= '<h1>' . $row['match']['forward'][0]['hop']['nodename'] . '</h1>';
      $output .= (!empty($table['forward'])) ? theme('ecenter_weathermap_table', $headers, $table['forward']) : '';
      $output .= (!empty($table['reverse'])) ? theme('ecenter_weathermap_table', $headers, $table['reverse']) : '';
      $output .= '</div>';
      $out[] = $output;
    }

    $output = '';
    if (!$match) {
      $id = $row['diff']['forward'][0]['hop']['hop_id'];
      $output .= '<div class="snmp-chart-wrapper" id="hop-'. $id .'">';
      $output .= '<h1>' . $row['diff']['forward'][0]['hop']['nodename'] . '</h1>';
      $output .= (!empty($table['forward'])) ? theme('ecenter_weathermap_table', $headers, $table['forward']) : '';
      $output .= '</div>';

      $id = $row['diff']['reverse'][0]['hop']['hop_id'];
      $output .= '<div class="snmp-chart-wrapper" id="hop-'. $id .'">';
      $output .= '<h1>' . $row['diff']['reverse'][0]['hop']['nodename'] . '</h1>';
      $output .= (!empty($table['reverse'])) ? theme('ecenter_weathermap_table', $headers, $table['reverse']) : '';
      $output .= '</div>';
      $out[] = $output;
    }

  }

  jqplot_register_tablechart('.snmp-chart-wrapper', $plot_options);
  return implode("\n", $out);
}

/**
 * Theme end to end data table
 */
function theme_ecenter_weathermap_render_data_end_to_end_table($data) {
  // BWCTL
  if (!empty($data['bwctl']['forward'])) {
    foreach ($data['bwctl']['forward'] as $item) {
      list($timestamp, $values) = $item;
      $tz = date_default_timezone_name(TRUE);
      $date = date_make_date($timestamp, $tz, DATE_UNIX);
      //dpm(date_format($date, 'Y-m-d H:i'));
      //dpm($values['throughput']);
      //dpm((float) $values['throughput'] / 1e+06);
    }
  }

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

  if (!empty($data['pinger']['forward'])) {
    foreach ($data['pinger']['forward'] as $item) {
      list($timestamp, $values) = $item;

      $forward_mean_rtt[] = $values['meanRtt'];
      $forward_max_rtt = ($values['maxRtt'] > $forward_max_rtt) ? $values['maxRtt'] : $forward_max_rtt;
      $forward_min_rtt = (!$forward_min_rtt || ($values['minRtt'] < $forward_min_rtt)) ? $values['minRtt'] : $forward_min_rtt;

      $forward_mean_iqripd[] = $values['iqrIpd'];
      $forward_max_iqripd = ($values['iqrIpd'] > $forward_max_iqripd) ? $values['iqrIpd'] : $forward_max_iqripd;
      $forward_min_iqripd = (!$forward_min_iqr_ipd || ($values['iqrIpd'] < $forward_min_iqripd)) ? $values['iqrIpd'] : $forward_min_iqripd;

      $forward_mean_loss[] = $values['lossPercent'];
      $forward_max_loss = ($values['lossPercent'] > $forward_max_loss) ? $values['lossPercent'] : $forward_max_loss;
      $forward_min_loss = (!$forward_min_loss || ($values['lossPercent'] < $forward_min_loss)) ? $values['lossPercent'] : $forward_min_loss;
    }

    $forward_mean_rtt = array_sum($forward_mean_rtt) / count($forward_mean_rtt);
    $forward_mean_iqripd = array_sum($forward_mean_iqripd) / count($forward_mean_iqripd);
    $forward_mean_loss = array_sum($forward_mean_loss) / count($forward_mean_loss);

    $table[] = array(
      array(
        'data' => t('Forward RTT'),
        'header' => TRUE,
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_mean_rtt) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'avg',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_max_rtt) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'max',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_min_rtt) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'min',
      ),
    );

    $table[] = array(
      array(
        'data' => t('Forward Packet Loss'),
        'header' => TRUE,
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_mean_loss) .'</span><span class="unit">'. t('%') .'</span>',
        'class' => 'avg',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_max_loss) .'</span><span class="unit">'. t('%') .'</span>',
        'class' => 'max',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.1f', $forward_min_loss) .'</span><span class="unit">'. t('%') .'</span>',
        'class' => 'min',
      ),
    );

    $table[] = array(
      array(
        'data' => t('Jitter'),
        'header' => TRUE,
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.2f', $forward_mean_iqripd) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'avg',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.2f', $forward_max_iqripd) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'max',
      ),
      array(
        'data' => '<span class="value">'. sprintf('%01.2f', $forward_min_iqripd) .'</span><span class="unit">'. t('ms') .'</span>',
        'class' => 'min',
      ),
    );
  }
  if (!empty($table)) {
    return theme('ecenter_weathermap_table', $headers, $table, array('class' => 'end-to-end-table'));
  }
}

/**
 * Theme services for use in options list.  Should always return plaintext!
 */
function theme_ecenter_weathermap_hop_option($hop) {
  return $hop->nodename .' ('. $hop->ip_noted .')';
}

/**
 * Theme a table for Ecenter.
 *
 * Similar to regular theme_table, minus the stupid sticky headers.
 */
function theme_ecenter_weathermap_table($header, $rows, $attributes = array(), $caption = NULL) {
  $output = '<table'. drupal_attributes($attributes) .">\n";

  if (isset($caption)) {
    $output .= '<caption>'. $caption ."</caption>\n";
  }

  // Format the table header:
  if (count($header)) {
    $ts = tablesort_init($header);
    // HTML requires that the thead tag has tr tags in it followed by tbody
    // tags. Using ternary operator to check and see if we have any rows.
    $output .= (count($rows) ? ' <thead><tr>' : ' <tr>');
    foreach ($header as $cell) {
      $cell = tablesort_header($cell, $header, $ts);
      $output .= _theme_table_cell($cell, TRUE);
    }
    // Using ternary operator to close the tags based on whether or not there are rows
    $output .= (count($rows) ? " </tr></thead>\n" : "</tr>\n");
  }
  else {
    $ts = array();
  }

  // Format the table rows:
  if (count($rows)) {
    $output .= "<tbody>\n";
    $flip = array('even' => 'odd', 'odd' => 'even');
    $class = 'even';
    foreach ($rows as $number => $row) {
      $attributes = array();

      // Check if we're dealing with a simple or complex row
      if (isset($row['data'])) {
        foreach ($row as $key => $value) {
          if ($key == 'data') {
            $cells = $value;
          }
          else {
            $attributes[$key] = $value;
          }
        }
      }
      else {
        $cells = $row;
      }
      if (count($cells)) {
        // Add odd/even class
        $class = $flip[$class];
        if (isset($attributes['class'])) {
          $attributes['class'] .= ' '. $class;
        }
        else {
          $attributes['class'] = $class;
        }

        // Build row
        $output .= ' <tr'. drupal_attributes($attributes) .'>';
        $i = 0;
        foreach ($cells as $cell) {
          $cell = tablesort_cell($cell, $header, $ts, $i++);
          $output .= _theme_table_cell($cell);
        }
        $output .= " </tr>\n";
      }
    }
    $output .= "</tbody>\n";
  }

  $output .= "</table>\n";
  return $output;
}
