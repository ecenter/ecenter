<?php
// $Id$

/**
 * Theme main data display
 */
function template_preprocess_ecenter_weathermap_data(&$vars) {
  $vars['permalink'] = l('Permalink', 'weathermap', array('query' => http_build_query($vars['params'])));
  $vars['snmp'] = theme('ecenter_weathermap_render_data_snmp', $vars['data']['diff']);
  dpm($vars['data']);
}

/**
 * Theme SNMP data
 */
function theme_ecenter_weathermap_render_data_snmp($data) {
  
  $plot_options = array(
    'width' => 650,
    'height' => 250,
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
          'pad' => 0,
          'renderer' => '$.jqplot.DateAxisRenderer',
          'tickOptions' => array(
            'formatString' => "%H:%M",
          ),
          //'label' => t('Time (@date)', array('@date' => $date_label)),
          'labelRenderer' => '$.jqplot.CanvasAxisLabelRenderer',
        ),
        'yaxis' => array(
          'min' => 0,
          'max' => 100,
          'pad' => 0,
          'numberTicks' => 5,
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

  foreach ($data as $row) {
    // For matches, create "couplets" of tables to be plotted on the same chart
    if (!empty($row['match'])) {
      foreach (array('forward', 'reverse') as $direction) {
        foreach ($row['match'][$direction] as $hop) {
          if (!empty($hop['data']['snmp']) && is_array($hop['data']['snmp'])) {
            $table = array();
            dpm($hop['data']['snmp']);
            foreach ($hop['data']['snmp'] as $item) {
              $table[] = array(
                'label' => array(
                  //'data' => format_date($item['timestamp'], 'custom', 'Y-m-d H:i:s'),
                  'data' => $item['timestamp'],
                  'header' => TRUE,
                ),
                'utilization' => array(
                  'data' => sprintf('%01.2f', $utilization),
                  'class' => $class,
                ),
              );
            }

          }
        }
      }
    }
  }
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
