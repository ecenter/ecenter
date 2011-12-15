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
  'created' => '1323710681',
  'changed' => '1323810982',
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

## Installing E-Center

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

## Post-installation

### Cron configuration (Required)

Drupal requires a periodic maintenance command to be run called \'cron\'. See the [Drupal cron documentation][13] for in-depth information on configuring cron.

E-Center uses an enhanced cron system called [Elysia Cron][14] which allows individual tasks to run at different intervals. This allows cron tasks that should run frequently (such as email integration, which should poll an external mailbox every 1-5 minutes) and that should run rarely (like DRS site-centric data caching, which can take up to 15 minutes to run) to coexist.

You\'ll need to configure your operating system\'s cron system to call Elysia Cron\'s script, not Drupal\'s. Elysia Cron should be called roughly once a minute. On many Linux and Unix systems, you can add a line to your `/etc/crontab` file or in a task-specific file such as `/etc/cron.d/ecenter.cron`:

<pre>* * * * *  root wget -O - -q -t 1 http://host.tld/profiles/ecenter/modules/contrib/elysia_cron/cron.php</pre>

### Site administration

*   You may always change the E-Center data service configuration by visiting `admin/settings/ecenter`(relative to your webroot).
*   You will likely want to enable some performance settings for production sites at `admin/settings/performance`. E-Center is incompatible with aggressive mode caching and block caching. E-Center has been tested to work with normal mode caching, CSS optimization, and Javascript optimization.
*   You may wish to change the default security and permissions settings: See the Drupal documentation on [roles][15] and [permissions][16].

### Configure as development environment

*   **Enable devel:** The Drupal `devel` module is included in the E-Center distribution. Enable `devel` and `simplemenu_devel` from the modules page or using `drush`.

*   **Enable LESS CSS developer mode:** To debug and develop CSS, enable LESS development mode at `admin/settings/less` to rebuild CSS files on every request.

Remember to disable these settings in production, as they can have a serious performance impact. Leaving devel module enabled could also pose security risks if debugging messages are leaked to unauthorized users.

 [1]: http://drupal.org/documentation/install
 [2]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/DEPLOYMENT.markdown
 [3]: /contact
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
 [14]: http://drupal.org/project/elysia_cron
 [15]: http://drupal.org/getting-started/6/admin/user/roles
 [16]: http://drupal.org/getting-started/6/admin/user/permissions',
  'teaser' => 'The E-Center frontend is packaged as a Drupal 6 distribution. The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes you have a basic understanding of the Drupal installation procedure and PHP web application administration.

The core E-Center network analysis functionality requires a running version of the Data Retrieval Service.',
  'log' => 'Created installation guide.',
  'revision_timestamp' => '1323810982',
  'format' => '3',
  'name' => 'admin',
  'picture' => '',
  'data' => 'a:0:{}',
  'path' => 'wiki/ecenter/install',
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
      'name' => 'E-Center Documentation',
      'description' => '',
      'weight' => '0',
    ),
  ),
  'uuid' => 'b0a988e6-24e8-11e1-b676-0026b9b97a6a',
  'revision_uuid' => 'b563924a-25cf-11e1-b676-0026b9b97a6a',
  'pathauto_perform_alias' => FALSE,
  'date' => '2011-12-12 11:24:41 -0600',
  'uuid_term' => array(
    '0' => 'b0acb2e6-24e8-11e1-b676-0026b9b97a6a',
  ),
);
  return $nodes;
}
