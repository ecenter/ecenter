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
  $vars['permalink'] = l('Permalink', 'weathermap', array('query' => http_build_query($vars['params'])));
  $vars['snmp'] = theme('ecenter_weathermap_render_data_snmp', $vars['data']['diff']);
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
          //'renderer' => '$.jqplot.DateAxisRenderer',
          //'tickOptions' => array(
          //  'formatString' => "%H:%M",
          //),
          //'label' => t('Time (@date)', array('@date' => $date_label)),
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

    // For matches, create "couplets" of tables to be plotted on the same chart
    if (!empty($row['match'])) {
      $table = array();

      $id = $row['match']['forward']['hop']['hop_id'];

      foreach (array('forward', 'reverse') as $direction) {
        if (empty($row['match'][$direction]['data']['snmp'])) {
          continue;
        }

        $hop = $row['match'][$direction];
        if (!empty($hop['data']['snmp']) && is_array($hop['data']['snmp'])) {
          foreach ($hop['data']['snmp'] as $item) {
            $table[$direction][] = array(
              'label' => array(
                'data' => $item[0],
                'header' => TRUE,
              ),
              'utilization' => array(
                'data' => sprintf('%01.2f', 100 * ($item[1]['utilization'] / $item[1]['capacity'])),
                'class' => $class,
              ),
            );
          }

        }
      }

      $output = '<div class="snmp-chart-wrapper" id="hop-'. $id .'">';
      $output .= (!empty($table['forward'])) ? theme('ecenter_weathermap_table', $headers, $table['forward']) : '';
      $output .= (!empty($table['reverse'])) ? theme('ecenter_weathermap_table', $headers, $table['reverse']) : '';
      $output .= '</div>';
      $out[] = $output;
    }
  }
  jqplot_register_tablechart('.snmp-chart-wrapper', $plot_options);

  return implode("\n", $out);
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
