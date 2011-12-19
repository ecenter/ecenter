<?php
// Load helpers
require_once('data_retrieval_service.inc');
require_once('data_retrieval_service_sitecentric.inc');
require_once('data_retrieval_service_circuit.inc');
require_once('anomaly_detection_service.inc');
require_once('forecasting_data_service.inc');

/**
 * Get an E-Center Data Retrieval Service client
 *
 * Factory-style helper function. All parameters optional
 *
 * @param $status_check
 *   If '503', return HTTP 503 page or redirect. If 'message', set message and
 *   continue. If FALSE, just return the client (default).
 * @param $type
 *   'drs' for Data Retrieval Service (default), 'ads' for Anomaly Detection
 *   Service
 * @param $name
 *   A unique name for this client (optional)
 */
function ecenter_network_get_client($status_check = FALSE, $type = 'drs', $name = NULL) {
  static $clients = array();

  require_once('ecenter_service.class.inc');
  switch ($type) {
    case 'drs':
      require_once('data_retrieval_service.class.inc');
      $klass = 'DataRetrievalService';
      $name = ($name) ? $name : 'drs_default';
      break;
    case 'drs_circuit':
      require_once('data_retrieval_service.class.inc');
      $klass = 'DataRetrievalService';
      $name = ($name) ? $name : 'drs_circuit';
      break;
    case 'drs_sitecentric':
      require_once('data_retrieval_service.class.inc');
      $klass = 'DataRetrievalService';
      $name = ($name) ? $name : 'drs_sitecentric';
      break;
    case 'ads':
      require_once('anomaly_detection_service.class.inc');
      $klass = 'AnomalyDetectionService';
      $name = ($name) ? $name : 'ads_default';
      break;
    case 'fds':
      require_once('forecasting_data_service.class.inc');
      $klass = 'ForecastingDataService';
      $name = ($name) ? $name : 'fds_default';
      break;
    default:
      drupal_set_message(t('Incorrect $type passed to client constructor'), 
        'error');
  }

  if (empty($clients[$name])) {
    $host = variable_get('ecenter_network_'. $type .'_host', 'localhost');
    $port = variable_get('ecenter_network_'. $type .'_port', 8000);
    $dir = variable_get('ecenter_network_'. $type .'_basedir', '');
    $timeout = variable_get('ecenter_network_'. $type .'_timeout', 30);
    $status_timeout = variable_get('ecenter_network_'. $type .'_status_timeout', 2);
    $clients[$name] = new $klass($host, $port, $dir, $timeout, 
      $status_timeout);
  }

  // Check client availability
  if ($status_check && !$clients[$name]->checkStatus()) {
    $message = t('!class client is not available.', array('!class' => $klass));
    watchdog('ecenter', $message, array(), WATCHDOG_ERROR);

    switch ($status_check) {
      case '503':
        drupal_set_header('HTTP/1.1 503 Service unavailable');
        // Keep old path for reference, and to allow forms to redirect to it.
        if (!isset($_REQUEST['destination'])) {
          $_REQUEST['destination'] = $_GET['q'];
        }
        print theme('page', '<div class="ecenter-fatal">'. $message .'</div>');
        exit();
      default:
        drupal_set_message($message, 'error');
    }
  }
  return $clients[$name];
}
