The E-Center frontend is packaged as a Drupal 6 distribution.

The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes the read has a basic understanding of Drupal installation.

The core E-Center network analysis functionality requires a running version of the Data Retrieval Service. See the [DRS deployment guide][2] or [contact the Fermilab E-Center team][3] for access to the FNAL Data Retrieval Service.

## Getting E-Center

### From code repository

You must have [Drush][4] and [Drush make][5] installed to build E-Center from scratch. Clone from Git repository:

<pre>
git clone https://github.com/ecenter/ecenter.git
</pre>

Run the build script:

<pre>cd ecenter/drupal
./build.sh /var/www/ecenter
</pre>

this command will create an E-Center instance in the `/var/www/ecenter` directory. You may pass the `--tar` flag to create a gzipped tarball of the built distribution or the `--working-copy` flag to build E-Center for local development.

### From zipped file

Download the appropriate (usually the most recent) release from [the downloads page][6] and extract in your webroot.

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

 [1]: http://drupal.org/documentation/install
 [2]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/DEPLOYMENT.markdown
 [3]: https://ecenter.fnal.gov/contact
 [4]: http://drupal.org/project/drush
 [5]: http://drupal.org/project/drush_make
 [6]: https://github.com/ecenter/ecenter/downloads
 [7]: http://drupal.org/documentation/install/create-database
 [8]: http://drupal.org/documentation/install/settings-file
 [9]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/select-profile-annotated.png
 [10]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-01.png
 [11]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-02-drs.png
 [12]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-03-drs-perf.png
