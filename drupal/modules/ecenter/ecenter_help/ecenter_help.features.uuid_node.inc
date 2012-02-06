<?php

/**
 * Implementation of hook_uuid_features_default_content().
 */
function ecenter_help_uuid_features_default_content() {
  $nodes = array();

  $nodes[] = array(
  'type' => 'wiki',
  'language' => '',
  'uid' => '1',
  'status' => '1',
  'created' => '1328201556',
  'changed' => '1328544116',
  'comment' => '0',
  'promote' => '0',
  'moderate' => '0',
  'sticky' => '0',
  'tnid' => '0',
  'translate' => '0',
  'revision_uid' => '1',
  'title' => 'Configuration notes',
  'body' => '## Server configuration

The running Drupal instance lives in `~/public_html/drupal`

The custom codebase for Drupal is cloned at `~/workspace/eads/ecenter`

The running Drupal instance symlinks to the custom module directories (`ecenter` and `util` under `profiles/ecenter/modules`) and theme (`ecenter` under`profiles/ecenter/themes`) in the cloned repository.

The Apache configuration for E-Center frontend instances lives at `/etc/httpd/conf.d/ssl.conf`

## Drupal architecture

The frontend architecture depends heavily on Features module for exporting configuration.

## Module overview

E-Center\'s main functional areas are handled by clusters of modules:

*   Network data visualization: Custom modules, primarily `ecenter_network`. The `ecenter_network` module relies heavily on custom classes for querying the Data Retrieval Service, OpenLayers for mapping, jQuery UI for interactive widgets and modal popups, and the jqPlot library (provided with a simple integration module) for charting.
*   Group functionality: Organic Groups module.
*   Email integration: Notifications 4.x, Messaging 4.x, Mailhandler, Mailcomment
*   Cron: Ultimate Cron (and dependencies background_process and progress) are required for data caching and email integration.
*   Theme: The theme uses the LESS CSS preprocessor, provided by the Drupal LESS module.
*   Content editing: Markdown source (in restricted and advanced flavors) is the only input style provided by E-Center. The `ecenter_editor` module uses the Markdownify library to allow TinyMCE to act as a WYSIWYG editor for Markdown source.

In terms of stability, the least stable and messiest component of the custom modules is the code to handle the site-centric view. The primary "weathermap" user interface is far more complex, but nonetheless more coherent.

## Content types

E-Center defines a handful of content types:

*   Wiki page: A collaboratively edited wiki page.
*   Group: Group content type
*   Issue: Issue/conversation for users.
*   Snippet: Snippet of HTML for inclusion somewhere on the site, such as the front page carousel.
*   Network query: Internal representation of a network query.
*   Page: Static page such as an about page.

## Gotchas

### Drush make on xenmon

Because the server does not have common certificates installed, `drush make` fails when trying to download from secure hosts such as github. E-Center must be built elsewhere until this problem is resolved.

### Disappearing theme

Due to long-standing bugs in the Drupal 6 bootstrap process, the E-Center theme may have to be re-enabled after running updates.

### Patches

These components must be re-patched (or patches re-rolled) if they are updated:

*   Drupal core
*   ahah_helper
*   context
*   jquery_ui
*   jquery_update
*   background_process

None of these modules are updated frequently, and unlikely to require re-rolled patches. See the E-Center makefile for patch details.',
  'teaser' => '## Server configuration

The running Drupal instance lives in `~/public_html/drupal`

The custom codebase for Drupal is cloned at `~/workspace/eads/ecenter`

The running Drupal instance symlinks to the custom module directories (`ecenter` and `util` under `profiles/ecenter/modules`) and theme (`ecenter` under`profiles/ecenter/themes`) in the cloned repository.

The Apache configuration for E-Center frontend instances lives at `/etc/httpd/conf.d/ssl.conf`

## Drupal architecture

The frontend architecture depends heavily on Features module for exporting configuration.

## Module o',
  'log' => '',
  'revision_timestamp' => '1328544116',
  'format' => '3',
  'name' => 'admin',
  'picture' => '',
  'data' => 'a:0:{}',
  'path' => 'wiki/ecenter/configuration',
  'og_groups_both' => array(),
  'og_groups' => array(),
  'tableofcontents_toc_automatic' => '0',
  'og_public' => TRUE,
  'last_comment_timestamp' => '1328201556',
  'last_comment_name' => NULL,
  'comment_count' => '0',
  'taxonomy' => array(
    '1' => array(
      'tid' => '1',
      'vid' => '1',
      'name' => 'Documentation',
      'description' => '',
      'weight' => '0',
      'v_weight_unused' => '0',
    ),
  ),
  'uuid' => '91e3953c-4dbf-11e1-ba2b-0026b9b97a6a',
  'pathauto_perform_alias' => FALSE,
  'revision_uuid' => 'e4915520-50db-11e1-ba2b-0026b9b97a6a',
  'date' => '2012-02-02 10:52:36 -0600',
  'uuid_term' => array(
    '0' => 'ee90cb44-4930-11e1-ba2b-0026b9b97a6a',
  ),
);
  $nodes[] = array(
  'type' => 'wiki',
  'language' => '',
  'uid' => '1',
  'status' => '1',
  'created' => '1323710681',
  'changed' => '1328544136',
  'comment' => '0',
  'promote' => '0',
  'moderate' => '0',
  'sticky' => '0',
  'tnid' => '0',
  'translate' => '0',
  'revision_uid' => '1',
  'title' => 'Frontend installation guide',
  'body' => 'The E-Center frontend is packaged as a Drupal 6 distribution. The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes you have a basic understanding of the Drupal installation procedure and PHP web application administration.

The core E-Center network analysis functionality requires a running version of the Data Retrieval Service. See the [DRS deployment guide][2] or [contact the Fermilab E-Center team][3] for access to the FNAL Data Retrieval Service.

## Download E-Center

### From zipped file

Download the appropriate (usually the most recent) release from [the downloads page][4] and extract in your webroot.

### From code repository

You must have [Drush][5] and [Drush make][6] installed to build E-Center from scratch. Clone from Git repository:

<pre>git clone https://github.com/ecenter/ecenter.git</pre>

Run the build script:

<pre>cd ecenter/drupal
./build.sh /var/www/ecenter</pre>

this command will create an E-Center instance in the `/var/www/ecenter` directory. You may pass the `--tar` flag to create a gzipped tarball of the built distribution or the `--working-copy` flag to build E-Center for local development.

## Install E-Center

Extract or copy the E-Center codebase to your webroot. Follow the Drupal guide to [create a database][7] and [edit the settings.php file][8] (the distribution comes with a pre-generated settings.php file).

Now, head to the default Drupal install URL `http://ecenter.myhost.tld/install.php`.

### Select E-Center profile

If your configuration is correct, you will see a profile selection screen. Select the "E-Center" profile.

![Select E-Center profile option][9]

### Configure Drupal and E-Center

At this point, Drupal is installed. Fill in the standard Drupal configuration details. As shown below, you may need to edit file permissions on the settings file that comes with the E-Center distribution.

![Configure Drupal][10]

This is where we depart from the standard Drupal installation. Enter configuration details for each Data Retrieval Service instance. You may always add or change this information later.

![Configure Data Retrieval Service][11]

Configure DRS caching. The defaults, which aggressively cache DRS results, should be appropriate for most E-Center deployments, and should only be disabled in development and for debugging:

![Configure DRS caching][12]

## Configure E-Center

### Cron configuration (recommended)

Drupal requires a periodic maintenance command to be run called *cron*. See the [Drupal cron documentation][13] for in-depth information on configuring cron.

E-Center uses a replacement for the standard Drupal cron system called [Ultimate Cron][14] which allows cron processes to run at different frequencies. This allows E-Center to check for new email replies every minute, send email notifications every five minutes, and cache Data Retrieval Service results once an hour.

By default, E-Center comes with the Ultimate Cron\'s *poormanscron* setting enabled, which replicates the functionality of another popular Drupal module. No additional work is required to configure cron when this setting is enabled.

However, for performance and simplicity, you should configure your crontab and disable Ultimate Cron\'s poormanscron setting if at all possible. On many Linux and Unix systems, you can add a line to your `/etc/crontab` file or in a task-specific crontab such as `/etc/cron.d/ecenter.cron`:

<pre>* * * * *  root wget -O - -q -t 1 http://myhost.tld/cron.php
</pre>

If using the crontab, you **must** configure cron to run once a minute (`* * * * *`), as per Ultimate Cron\'s installation instructions. If you

To disable the *poormanscron* setting, visit [`admin/settings/cron/settings`][15].

### Performance and caching configuration (recommended)

You may want to enable some performance settings for production sites at [`admin/settings/performance`][16]. E-Center is incompatible with aggressive mode caching and block caching. E-Center has been tested to work with normal mode caching, CSS optimization, and Javascript optimization.

### Configure email integration (optional)

E-Center\'s email integration allows users to receive email updates on comment threads and to post responses by replying to the original email message.

#### Create a mailbox

Before enabling the E-Center mail module, you must set up a special email address/mailbox to receive these messages and know the IMAP or POP configuration of the mailbox.

#### Configure E-Center to use your mailbox

*   Enable the `ecenter_mail` module from the modules page or with Drush.
*   Create a new *mailhandler* mailbox definition at [`/admin/build/mailhandler/add`][17] and provide your mailbox server configuration.
*   Configure comment integration by visiting [`admin/messaging/mailcomment`][18]. At the least, you must ensure the reply-to address matches your mailbox address.

#### Tips and tricks

*   **Always use a dedicated email address for email integration**.
    *   The mailbox used for email integration should be considered insecure: Anyone with administrative access to E-Center or to E-Center\'s database can see the mailbox password.
    *   Using the mailbox for any other purpose could cause strange bugs and prevent integration from working properly.
*   When configuring the mailbox definition for encrypted IMAP access (as used by Gmail and many other email providers), add `/ssl` to the *Extra commands* option.

### Configure Shibboleth integration (optional)

*Coming soon.*

### Configure ApacheSolr search (optional)

*Coming soon.*

## Site administration

You may always change the E-Center data service configuration by visiting [`admin/settings/ecenter`][19].

You may wish to change the default security and permissions settings: See the Drupal documentation on [roles][20] and [permissions][21].

## E-Center for developers

Developers who wish to hack E-Center should:

*   **Build for E-Center for development**: Build the distribution from a Git clone of the codebase. Use the `--working-copy` flag when building the Drupal distribution.
*   **Enable devel:** The Drupal `devel` module is included in the E-Center distribution. Enable `devel` and `simplemenu_devel` from the modules page or using `drush`.
*   **Enable LESS CSS developer mode:** To debug and develop CSS, enable LESS development mode at [`admin/settings/less`][22] to rebuild CSS files on every request.

Remember to disable these settings in production, as they can have a serious performance impact. Leaving `devel` module enabled could also pose security risks if debugging messages are leaked to unauthorized users.

See the [E-Center Configuration Notes][23] for an in-depth description of the E-Center architecture.

 [1]: http://drupal.org/documentation/install
 [2]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/DEPLOYMENT.markdown
 [3]: contact
 [4]: https://github.com/ecenter/ecenter/downloads
 [5]: http://drupal.org/project/drush
 [6]: http://drupal.org/project/drush_make
 [7]: http://drupal.org/documentation/install/create-database
 [8]: http://drupal.org/documentation/install/settings-file
 [9]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/select-profile-annotated.png
 [10]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-01.png
 [11]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-02-drs.png
 [12]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-03-drs-perf.png
 [13]: http://drupal.org/cron
 [14]: http://drupal.org/project/ultimate_cron
 [15]: admin/settings/cron/settings
 [16]: admin/settings/performance
 [17]: admin/build/mailhandler/add
 [18]: admin/messaging/mailcomment/add
 [19]: admin/settings/ecenter
 [20]: http://drupal.org/getting-started/6/admin/user/roles
 [21]: http://drupal.org/getting-started/6/admin/user/permissions
 [22]: admin/settings/less
 [23]: wiki/ecenter/configuration',
  'teaser' => 'The E-Center frontend is packaged as a Drupal 6 distribution. The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes you have a basic understanding of the Drupal installation procedure and PHP web application administration.

The core E-Center network analysis functionality requires a running version of the Data Retrieval Service.',
  'log' => '',
  'revision_timestamp' => '1328544136',
  'format' => '3',
  'name' => 'admin',
  'picture' => '',
  'path' => 'wiki/ecenter/install',
  'data' => 'a:0:{}',
  'og_groups_both' => array(),
  'og_groups' => array(),
  'tableofcontents_toc_automatic' => '0',
  'og_public' => TRUE,
  'last_comment_timestamp' => '1323808503',
  'last_comment_name' => NULL,
  'comment_count' => '0',
  'taxonomy' => array(
    '1' => array(
      'tid' => '1',
      'vid' => '1',
      'name' => 'Documentation',
      'description' => '',
      'weight' => '0',
      'v_weight_unused' => '0',
    ),
  ),
  'uuid' => 'b0a988e6-24e8-11e1-b676-0026b9b97a6a',
  'pathauto_perform_alias' => FALSE,
  'revision_uuid' => 'f0888a4c-50db-11e1-ba2b-0026b9b97a6a',
  'date' => '2011-12-12 11:24:41 -0600',
  'uuid_term' => array(
    '0' => 'ee90cb44-4930-11e1-ba2b-0026b9b97a6a',
  ),
);
  return $nodes;
}
