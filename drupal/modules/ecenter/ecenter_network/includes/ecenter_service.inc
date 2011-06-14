<?php

/**
 * @file
 * Provides an abstract class for interacting with E-Center's data retrieval, 
 * anomaly detection, and other services to developed.
 */

abstract class EcenterService {

  /**
   * Connection options
   */
  protected $_host, $_port, $_path, $_timeout, $_url, $_status_timeout;

  /**
   * Allow return value to be set on object
   */
  public $data_type = 'json';

  /**
   * Client constructor
   *
   * @param $host
   *   The hostname of the network data web service.
   * @param $port
   *   The port used by the network data web service.
   * @param $path
   *   The base path of the query service.
   * @param $timeout
   *   Request timeout.
   * @param $status_timeout
   *   Timeout for a status request. This can/should be much shorter than the
   *   regular data timeout.
   */
  public function __construct($host = 'localhost', $port = 8099, $path = '', $timeout = 30, $status_timeout = 2) {
    $this->_host = $host;
    $this->_port = $port;
    $this->_path = $path;
    $this->_url = 'http://'. $host .':'. $port;
    $this->_url .= ($path) ? '/'. $path : '';
    $this->_timeout = $timeout;
    $this->_status_timeout = $status_timeout;
  }

  /**
   * Query a data service
   *
   * @param $path
   *   The path to the web service resource.
   * @param $parameters
   *   An array of search/filter parameters, if required. May contain key/value
   *   to pass in the query string, or an array with an array of key/value pairs
   *   belonging to an element named 'query'. The array invocation allows 
   *   additional metadata to be maintained with the query parameters.
   * @param $timeout
   *   (optional) Request timeout to use (overrides timeout set in constructor).
   * @return
   *   An associative array consisting of querystring, query parameters as an
   *   associative array, response
   */
  protected function query($path, $parameters = NULL, $timeout = NULL) {

    $timeout = ($timeout) ? $timeout : $this->_timeout;
    $url = $this->_url .'/'. $path .'.'. $this->data_type;

    if (!empty($parameters)) {
      $query = array();
      foreach ($parameters as $key => $value) {
        if (is_array($value)) {
          foreach ($value['query'] as $query_key => $query_value) {
            $query[$query_key] = $query_value;
          }
        }
        else {
          $query[$key] = $value;
        }
      }
      $querystring = http_build_query($query);

      if (!empty($querystring)) {
        $url .= '?'. $querystring;
      }
      // @TODO Fix... somewhere: Dancer does not support encoded ampersands in the querystring
      $url = str_replace('&amp;', '&', $url);
    }


    $handle = curl_init();

    $options = array(
      CURLOPT_URL => $url,
      CURLOPT_TIMEOUT => $timeout,
      CURLOPT_RETURNTRANSFER => 1,
      CURLOPT_FRESH_CONNECT => 1,
      CURLOPT_FORBID_REUSE => 1,
      CURLOPT_VERBOSE => 1,
    );

    curl_setopt_array($handle, $options);

    $response = curl_exec($handle);
    $error = curl_error($handle);
    $code = curl_getinfo($handle, CURLINFO_HTTP_CODE);

    if (!$error) {
      $response = json_decode($response, $assoc);
    }
    else {
      $response = $error;
    }

    curl_close($handle);

    $result = array(
      'parameters' => $parameters,
      'query' => $querystring,
      'url' => $url,
      'code' => $code,
      'response' => $response,
    );

    return $result;
  }

  /**
   * Check server status
   *
   * @return
   *   True if server is operational.
   */
  public function checkStatus() {
    $q = 'status';
    $status = $this->query($q, NULL, $this->_status_timeout);
    if ($status['response']['status']) {
      return TRUE;
    }
    return FALSE;
  }
}
