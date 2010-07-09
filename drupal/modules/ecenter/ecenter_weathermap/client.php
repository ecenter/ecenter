<?php
// $Id$

/**
 * @file
 * Provides a thin integration layer with the E-Center Network data query
 * service.
 */


class Ecenter_Data_Service_Client {

  /**
   * Default timeout for requests
   */
  protected $_defaultTimeout;

  /**
   * Stream contexts for GET and POST
   */
  protected $_getContext, $_postContext;

  /**
   * Connection options
   */
  protected $_host, $_port, $_path;
  protected $_url;

  /**
   * Provide a backdoor method for returning other data types than json
   */
  public $data_type = 'json';

  /**
   * @param $host
   *   The hostname of the network data web service.
   *
   * @param $port
   *   The port used by the network data web service.
   *
   * @param $path
   *   The base path of the query service.
   */
  public function __construct($host = 'localhost', $port = 8099, $path = '') {
    $this->_host = $host;
    $this->_port = $port;
    $this->_path = $path;
    $this->_url = 'http://'. $host .':'. $port;
    $this->_url .= ($path) ? '/'. $path : '';

    // create our shared get and post stream contexts
    //$this->_getContext = stream_context_create();
    //$this->_postContext = stream_context_create();

    // determine our default http timeout from ini settings
    $this->_defaultTimeout = (int) ini_get('default_socket_timeout');

    // double check we didn't get 0 for a timeout
    if ($this->_defaultTimeout <= 0)
    {
      $this->_defaultTimeout = 60;
    }
  }

  /**
   * @param $path
   *   The path to the web service resource.
   *
   * @param $parameters
   *   An array of search/filter parameters, if required.
   */
  protected function query($path, $parameters = FALSE) {
    $url = $this->_url .'/'. $path .'.'. $this->data_type;
    $querystring = ($parameters) ? http_build_query($parameters) : FALSE;
    if (!empty($querystring)) {
      $url .= '?'. $querystring;
    }
    $handle = curl_init();

    curl_setopt($handle, CURLOPT_URL, $url);
    curl_setopt($handle, CURLOPT_RETURNTRANSFER, TRUE);

    $response = curl_exec($handle);
    $code = curl_getinfo($handle, CURLINFO_HTTP_CODE);

    curl_close($handle);

    return array(
      'code' => $code,
      'response' => json_decode($response),
    );
  }

  public function getHubs($src_ip='') {
    $q = 'hub';
    if (!empty($src_ip)) {
      $q .= '/src_ip/'. $src_ip;
    }
    return $this->query($q);
  }

  /**
   * @param $src_ip
   *   The source IPv4 or IPv6 address.
   *
   * @param $dst_ip
   *   The destination IPv4 or IPv6 address.
   *
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getMetadata($src_ip, $dst_ip, $debug=FALSE) {
    $parameters = array(
      'src_ip' => $src_ip,
      'dst_ip' => $dst_ip,
    );
    if ($debug) {
      $parameters += array('debug' => TRUE);
    }
    return $this->query('metadata', $parameters);
  }

  /**
   * @param $meta_id
   *   The metadata id that describes the test the returned
   *   data comes from.
   *
   * @param $type
   *   The type of data requested.
   *
   * @param $start_date
   *   The start date for data, formatted as YYYY-MM-DD HH:mm:ss
   *
   * @param $end_date
   *   The end date for data, formatted as YYYY-MM-DD HH:mm:ss
   *
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getData($meta_id, $type, $start_date, $end_date, $debug=FALSE) {
    $parameters = array(
      'start' => $start_date,
      'end' => $end_date,
    );
    if ($debug) {
      $parameters += array('debug' => TRUE);
    }
    return $this->query($type .'_data/'. $meta_id, $parameters);
  }


  /**
   * @param $src_ip
   *   The source IPv4 or IPv6 address.
   *
   * @param $dst_ip
   *   The destination IPv4 or IPv6 address.
   *
   * @param $start_date
   *   The start date for data, formatted as YYYY-MM-DD HH:mm:ss
   *
   * @param $end_date
   *   The end date for data, formatted as YYYY-MM-DD HH:mm:ss
   *
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getPathData($src_ip, $dst_ip, $start_date, $end_date, $debug=FALSE) {
    $parameters = array(
      'src_ip' => $src_ip,
      'dst_ip' => $dst_ip,
      'start' => $start_date,
      'end' => $end_date,
    );
    if ($debug) {
      $parameters += array('debug' => TRUE);
    }
    return $this->query('data', $parameters);
  }

  /**
   * @param $service_id
   *   The id of the service we'd like information about.
   *
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getService($service_id, $debug=FALSE) {
    $parameters = array();
    if ($debug) {
      $parameters = array('debug' => TRUE);
    }
    return $this->query('service/'. $service_id, $parameters);
  }

  /**
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getServices($debug=FALSE) {
    $parameters = array();
    if ($debug) {
      $parameters['debug'] = TRUE;
    }
    return $this->query('services', $parameters);
  }

  /**
   * @param $src_ip
   *   Source IP
   *
   * @param $debug
   *   Include query debugging information in the response.
   */
  public function getDestinationServices($src_ip, $debug=FALSE) {
    if ($debug) {
      $parameters['debug'] = TRUE;
    }
    return $this->query('destination-services/'. $src_ip, $parameters);
  }
}
