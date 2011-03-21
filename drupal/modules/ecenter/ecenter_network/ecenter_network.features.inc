<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_network_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "openlayers") {
    switch ($api) {
      case 'openlayers_layers':
      case 'openlayers_styles':
      case 'openlayers_presets':
        return array('version' => 1);
    }
  }
  if ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
}
