<?php
// $Id$

/**
 * Theme main data display
 */
function template_preprocess_ecenter_weathermap_data(&$vars) {
  $data = ecenter_weathermap_parse_data($vars['data']['response']);

  $output = '<div class="traceroute-wrapper">';
  foreach ($data as $trace_id => $traceroute) {
    $output .= '<div class="traceroute">';
    $output .= '<h2>Trace: '. $trace_id .'</h2>';
    foreach ($traceroute as $hop) {
      $output .= '<div id="hop-'. $hop['hop']['hop_id'] .'-wrapper" class="hop-wrapper">';
      $output .= '<h3 class="hop-name">'. $hop['hop']['hop_id'] .' ('. $hop['hop']['hop_ip'] .')</h3>';
      $output .= '<div class="hop-data">';
      foreach ($hop['data'] as $type => $hop_data) {
        if (!empty($hop_data)) {
          $output .= "<div class='clearfix data-wrapper $type-data-wrapper'>";
          $output .= theme('ecenter_weathermap_render_data_'. $type, $hop_data); 
          $output .= "</div>";
        }
      }
      $output .= '</div>';
      $output .= '</div>';
    }
    $output .= '</div>';
  }
  $output .= '</div>';

  $vars['traceroute'] = $output;
}

/**
 * Theme SNMP data
 */
function theme_ecenter_weathermap_render_data_snmp($data) {
  jquerytools_add('tooltip');

  $headers = array(t('Time'), t('Percent utilization'));
  $table = array();
  $days = array();
  $min = 0;
  $max = 0;
  $total = 0;
  foreach ($data as $item) {
    $class = '';
    $utilization = ($item['utilization'] / $item['capacity']) * 100;
    $max = ($utilization > $max) ? $utilization : $max;
    $min = ($utilization < $min || $min == 0) ? $utilization : $min;
    $total += $utilization;

    if ($utilization > variable_get('ecenter_weathermap_threshold_critical_snmp_utilization', 40)) {
      $class = 'ecenter-critical';
    }
    if ($utilization > variable_get('ecenter_weathermap_threshold_marginal_snmp_utilization', 20)) {
      $class = 'ecenter-marginal';
    }

    global $user;
    if (variable_get('configurable_timezones', 1) && $user->uid && strlen($user->timezone)) {
      $timezone = $user->timezone;
    }
    else {
      $timezone = variable_get('date_default_timezone', 0);
    }

    $table[] = array(
      'label' => array(
        'data' => format_date($item['timestamp'], 'custom', 'Y-m-d H:i:s'),
        'header' => TRUE,
      ),
      'utilization' => array(
        'data' => sprintf('%01.2f', $utilization),
        'class' => $class,
      ),
    );

    $day = format_date($item['timestamp'], 'custom', 'Y-m-d');
    $days[$day] = $day;
  }

  // Format date
  $date_label = array_shift($days);
  $end_day = array_pop($days);
  if ($end_day) {
    $date_label .= ' - '. $end_day;
  }

  // Get average
  $avg = $total / count($data);

  $aggregate_table = array(
    'max' => array(
      'label' => array('data' => t('Maximum'), 'header' => TRUE,),
      'value' => array('data' => sprintf('%01.2f', $max)),
    ),
    'min' => array(
      'label' => array('data' => t('Minimum'), 'header' => TRUE,),
      'value' => array('data' => sprintf('%01.2f', $min),),
    ),
    'avg' => array(
      'label' => array('data' => t('Average'), 'header' => TRUE,),
      'value' => array('data' => sprintf('%01.2f', $avg),),
    ),
  );

  $plot_options = array(
    'width' => 600,
    'height' => 200,
    'hideTable' => TRUE,
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
          'renderer' => '$.jqplot.DateAxisRenderer',
          'tickOptions' => array(
            'formatString' => "%H:%M",
          ),
          'label' => t('Time (@date)', array('@date' => $date_label)),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        ),
        'yaxis' => array(
          'min' => 0,
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
        'constrainZoomTo' => 'x',
      ),
    ),
  );

  // @TODO Determine how to set colors...  MESSY!
  $critical = variable_get('ecenter_weathermap_threshold_critical_snmp_utilization', 60);
  $marginal = variable_get('ecenter_weathermap_threshold_marginal_snmp_utilization', 40);

  // Max
  if ($max > $critical) {
    $aggregate_table['max']['value']['class'] = 'ecenter-critical';
  }
  else if ($max > $marginal) {
    $aggregate_table['max']['value']['class'] = 'ecenter-marginal';
  }
  else {
    $aggregate_table['max']['value']['class'] = 'ecenter-good';
  }

  // Min
  if ($min > $critical) {
    $aggregate_table['min']['value']['class'] = 'ecenter-critical';
  }
  else if ($min > $marginal) {
    $aggregate_table['min']['value']['class'] = 'ecenter-marginal';
  }
  else {
    $aggregate_table['min']['value']['class'] = 'ecenter-good';
  }

  // Line color: @TODO -- confusingly, not working right...
  if ($max > $critical || $avg > $critical) {
    $plot_options['plotOptions']['seriesDefaults']['color'] = variable_get('ecenter_weathermap_threshold_critical_color', '#cc0000');
  }
  else if ($max > $marginal || $avg > $marginal) {
    $plot_options['plotOptions']['seriesDefaults']['color'] = variable_get('ecenter_weathermap_threshold_marginal_color', '#fe890c');
  }

  jqplot_register_tablechart('.snmp-chart', $plot_options);
  $title = '<h4>'. t('SNMP Utilization') .'</h4>';
  return $title . theme('table', $headers, $table, array('class' => 'snmp-chart')) . theme('table', NULL, $aggregate_table);
}

/**
 * Theme pingER data
 */
function theme_ecenter_weathermap_render_data_pinger($data) {
  return 'pinger data';
}

/**
 * Theme bwctl data
 */
function theme_ecenter_weathermap_render_data_bwctl($data) {
  return 'bwctl data';
}

/**
 * Theme owamp data
 */
function theme_ecenter_weathermap_render_data_owamp($data) {
  return 'owamp data';
}

/**
 * Theme traceroute
 */
function theme_ecenter_weathermap_traceroute($hops) {
  $output = '';
  foreach ($hops as $hop) {
    $output .= ' '. $hop->hop_ip;
  }
  return $output;
}

/**
 * Theme services for use in options list.  Should always return plaintext!
 */
function theme_ecenter_weathermap_hop_option($hop) {
  return $hop->nodename .' ('. $hop->ip_noted .')';
}
