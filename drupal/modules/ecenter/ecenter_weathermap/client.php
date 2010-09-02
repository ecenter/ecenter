<?php
// $Id$

/**
 * @file
 * Provides a thin integration layer with the E-Center Network data query
 * service.
 */

class Ecenter_Data_Service_Client {

  /**
   * Stream contexts for GET and POST
   */
  protected $_getContext, $_postContext;

  /**
   * Connection options
   */
  protected $_host, $_port, $_path, $_timeout, $_url, $_status_timeout;

  /**
   * Provide a backdoor method for returning other data types than json
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
   * Query the data service
   *
   * @param $path
   *   The path to the web service resource.
   * @param $parameters
   *   An array of search/filter parameters, if required.
   * @param $timeout
   *   (optional) Request timeout to use (overrides timeout set in constructor).
   */
  protected function query($path, $parameters = NULL, $timeout = NULL) {
    static $results = array();

    $timeout = ($timeout) ? $timeout : $this->_timeout;

    $url = $this->_url .'/'. $path .'.'. $this->data_type;
    $querystring = ($parameters) ? http_build_query($parameters) : FALSE;

    if (!empty($querystring)) {
      $url .= '?'. $querystring;
    }

    // @TODO Dancer does not support encoded ampersands in the querystring
    $url = str_replace('&amp;', '&', $url);

    if (empty($results[$url])) {
      //dpm('Query URL: '. $url);

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

      if (!empty($response)) {
        $code = curl_getinfo($handle, CURLINFO_HTTP_CODE);
        $response = json_decode($response);
      }
      else {
        $code = 0;
        $response = 'Timed out after '. $timeout .' seconds.';
      }

      curl_close($handle);

      $results[$url] = array(
        'parameters' => $parameters,
        'query' => $querystring,
        'code' => $code,
        'response' => $response,
      );

    }
    return $results[$url];
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
    if ($status['response']->status) {
      return TRUE;
    }
    return FALSE;
  }

  /**
   * Get hubs
   *
   * @param $src_ip
   *   (optional) Source IP.  If provided, will return all destinations for this
   *   source.
   * @return 
   *   An array of hubs.
   */
  public function getHubs($src_ip='') {
    $q = 'hub';
    if (!empty($src_ip)) {
      $q .= '/src_ip/'. $src_ip;
    }
    return $this->query($q);
  }

  /**
   * Get data from service
   *
   * @param $src_ip
   *   Source IP address.
   * @param $dst_ip
   *   Destination IP address.
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @param $resolution
   *   (optional) Maximum number of data points to return for any measurement.
   * @return
   *   Result for this query.
   */
  public function getData($src_ip, $dst_ip, $start, $end, $resolution = 50) {
    $parameters = array(
      'src_ip' => $src_ip,
      'dst_ip' => $dst_ip,
      'start' => $start,
      'end' => $end,
      'resolution' => $resolution,
    );
    return $this->query('data', $parameters);
  }

}
