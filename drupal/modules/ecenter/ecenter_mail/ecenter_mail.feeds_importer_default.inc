<?php

/**
 * Implementation of hook_feeds_importer_default().
 */
function ecenter_mail_feeds_importer_default() {
  $export = array();

  $feeds_importer = new stdClass;
  $feeds_importer->disabled = FALSE; /* Edit this to true to make a default feeds_importer disabled initially */
  $feeds_importer->api_version = 1;
  $feeds_importer->id = 'mailhandler_comments';
  $feeds_importer->config = array(
    'name' => 'Mailhandler comments',
    'description' => 'Imports comments from a Mailhandler mailbox',
    'fetcher' => array(
      'plugin_key' => 'MailhandlerFetcher',
      'config' => array(
        'filter' => 'MailhandlerFiltersComments',
      ),
    ),
    'parser' => array(
      'plugin_key' => 'MailhandlerParser',
      'config' => array(
        'default_commands' => 'status: 1',
        'command_plugin' => array(
          'MailhandlerCommandsHeaders' => 'MailhandlerCommandsHeaders',
          'MailhandlerCommandsDefault' => 'MailhandlerCommandsDefault',
          'MailhandlerCommandsFiles' => 'MailhandlerCommandsFiles',
        ),
        'authenticate_plugin' => 'MailhandlerAuthenticateDefault',
        'available_commands' => 'status',
        'commands_failed_auth' => 'status: 0',
      ),
    ),
    'processor' => array(
      'plugin_key' => 'FeedsCommentProcessor',
      'config' => array(
        'input_format' => '0',
        'update_existing' => '1',
        'expire' => '-1',
        'mappings' => array(
          0 => array(
            'source' => 'parent_nid',
            'target' => 'nid',
            'unique' => FALSE,
          ),
          1 => array(
            'source' => 'parent_cid',
            'target' => 'pid',
            'unique' => FALSE,
          ),
          2 => array(
            'source' => 'subject',
            'target' => 'subject',
            'unique' => FALSE,
          ),
          3 => array(
            'source' => 'body_html',
            'target' => 'comment',
            'unique' => FALSE,
          ),
          4 => array(
            'source' => 'authenticated_uid',
            'target' => 'uid',
            'unique' => FALSE,
          ),
        ),
        'author' => 0,
      ),
    ),
    'content_type' => '',
    'update' => 0,
    'import_period' => '0',
    'expire_period' => 3600,
    'import_on_create' => 1,
  );
  $export['mailhandler_comments'] = $feeds_importer;

  return $export;
}
