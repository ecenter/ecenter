<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_mail_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "feeds" && $api == "feeds_importer_default") {
    return array("version" => 1);
  }
  elseif ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
  elseif ($module == "ultimate_cron" && $api == "default_ultimate_cron_functions") {
    return array("version" => 1);
  }
}
