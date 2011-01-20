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
   * Provide a "backdoor" technique for returning other data types than json
   */
  public $data_type = 'json';

  /**
   * Provide a "backdoor" technique for extending available datatypes
   */
  public $query_types = array('hub', 'ip');

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
   * @param $assoc
   *   (optional) If true (default), return associative array, otherwise return
   *   an anonymous PHP object.
   * @return
   *   An associative array consisting of querystring, query parameters as an
   *   associative array, response
   */
  protected function query($path, $parameters = NULL, $timeout = NULL, $assoc = TRUE) {
    $timeout = ($timeout) ? $timeout : $this->_timeout;

    $url = $this->_url .'/'. $path .'.'. $this->data_type;
    $querystring = ($parameters) ? http_build_query($parameters) : FALSE;

    if (!empty($querystring)) {
      $url .= '?'. $querystring;
    }

    // @TODO Fix... somewhere: Dancer does not support encoded ampersands in the querystring
    $url = str_replace('&amp;', '&', $url);

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
      'code' => $code,
      'response' => $response,
    );

    //if ($path == 'data') {
      //dpm(urldecode($url));
      //dpm(debug_backtrace());
    //}

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
    $status = $this->query($q, NULL, $this->_status_timeout, FALSE);
    if ($status['response']->status) {
      return TRUE;
    }
    return FALSE;
  }

  /**
   * Get hubs
   *
   * @return
   *   An array of hubs.
   */
  public function getHubs() {
    return $this->query('hub');
  }

  /**
   * Get hops
   *
   * @param $src_ip
   *   (optional) Source IP.  If provided, will return all destinations for this
   *   source.
   * @return
   *   An array of hubs.
   */
  public function getHops($src_ip='') {
    $q = (!empty($src_ip)) ? 'destination/' . $src_ip : 'source';
    return $this->query($q);
  }


  /**
   * Get data from service
   *
   * @param $src
   *   Source, of the form <query_type>:<source identifier>.
   * @param $dst
   *   Destination, of the form <query_type>:<destination identifier>.
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @param $resolution
   *   (optional) Maximum number of data points to return for any measurement.
   * @return
   *   Result for this query.
   */
  public function getData($src, $dst, $start, $end, $resolution = 50) {

    // Parse out query type
    list($src_type, $src) = explode(':', $src, 2);
    list($dst_type, $dst) = explode(':', $dst, 2);

    if (array_search($src_type, $this->query_types) === FALSE && array_search($dst_type, $this->query_types) !== FALSE) {
      throw new Exception('Invalid source query type.');
    }
    else if (array_search($src_type, $this->query_types) !== FALSE && array_search($dst_type, $this->query_types) === FALSE) {
      throw new Exception('Invalid destination query type.');
    }
    else if (array_search($src_type, $this->query_types) === FALSE && array_search($dst_type, $this->query_types) === FALSE) {
      throw new Exception('Invalid source and destination query types.');
    }

    $params = array(
      'src_'. $src_type => $src,
      'dst_'. $dst_type => $dst,
      'start' => $start,
      'end' => $end,
      'resolution' => $resolution,
    );

    return $this->query('data', $params);
  }

  /**
   * Get node
   * 
   * @param $ip
   *   IP address to query for
   * @return 
   *   Result for this query
   */
  public function getNode($ip) {
    return $this->query('node/'. $ip);
  }

}
