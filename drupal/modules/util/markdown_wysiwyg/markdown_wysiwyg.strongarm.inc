<?php

/**
 * Implementation of hook_strongarm().
 *
 * Manually install format.
 */
function markdown_wysiwyg_strongarm() {
  $export = array();

  // Ensure the formats have been installed.
  if (!$formats = _markdown_wysiwyg_formats()) {
    return $export;
  }

  _markdown_wysiwyg_install_manual($formats);

  return $export;
}

/**
 * "Manually" install WYSIWYG and Better Formats settings.
 */
function _markdown_wysiwyg_install_manual($formats) {
  if (!variable_get('markdown_wysiwyg_installed', FALSE)) {

    // Install WYSIWYG.
    $wysiwyg = array();
    $wysiwyg[] = array(
      'format' => $formats['Markdown WYSIWYG'],
      'editor' => 'tinymce',
      'settings' => 'a:20:{s:7:"default";i:1;s:11:"user_choose";i:1;s:11:"show_toggle";i:1;s:5:"theme";s:8:"advanced";s:8:"language";s:2:"en";s:7:"buttons";a:3:{s:7:"default";a:7:{s:4:"bold";i:1;s:6:"italic";i:1;s:7:"bullist";i:1;s:7:"numlist";i:1;s:4:"link";s:6:"unlink";i:1;s:7:"cleanup";i:1;s:10:"blockquote";i:1;}s:4:"font";a:1:{s:12:"formatselect";i:1;}s:8:"markdown";a:1:{s:8:"markdown";i:1;}}s:11:"toolbar_loc";s:3:"top";s:13:"toolbar_align";s:4:"left";s:8:"path_loc";s:6:"bottom";s:8:"resizing";i:1;s:11:"verify_html";i:1;s:12:"preformatted";i:0;s:22:"convert_fonts_to_spans";i:1;s:17:"remove_linebreaks";i:0;s:23:"apply_source_formatting";i:0;s:27:"paste_auto_cleanup_on_paste";i:1;s:13:"block_formats";s:9:"h2,h3,h4,";s:11:"css_setting";s:4:"none";s:8:"css_path";s:0:"";s:11:"css_classes";s:0:"";}'
    );

    foreach ($wysiwyg as $editor) {
      db_query("INSERT INTO {wysiwyg} (format, editor, settings) VALUES (%d, '%s', '%s')", $editor['format'], $editor['editor'], $editor['settings']);
    }

    // Install Better Formats.
    $types = array('node', 'comment', 'block');
    $roles = user_roles();
    $names = array(
      $roles[DRUPAL_AUTHENTICATED_RID] => array(
        'format' => $formats['Markdown WYSIWYG'],
        'weight' => -2,
      ),
    );
    foreach ($types as $type) {
      foreach ($roles as $rid => $name) {
        if (in_array($name, array_keys($names))) {
          db_query("UPDATE {better_formats_defaults} SET format = %d , weight = %d WHERE rid = %d AND type = '%s'", $names[$name]['format'], $names[$name]['weight'], $rid, $type);
          if (!db_affected_rows()) {
            db_query("INSERT INTO {better_formats_defaults} (rid, type, format, type_weight, weight) VALUES (%d, '%s', %d, 1, %d)", $rid, $type, $names[$name]['format'], $names[$name]['weight']);
          }
        }
      }
    }
    drupal_set_message(t('WYSIWYG and Better Formats settings saved. Note that these settings are not managed by Features, meaning that no updates will be received.'));
    variable_set('markdown_wysiwyg_installed', TRUE);
  }
}
