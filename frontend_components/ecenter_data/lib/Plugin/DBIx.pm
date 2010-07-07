package  Plugin::DBIx;

use strict;
use Dancer::Plugin;
use Ecenter::Schema;

=head1 NAME

  Plugin::DBIx -   database connections for Ecenter schema based on DBIx::Class

=cut

our $VERSION = '0.06';

my $dbh;
my $last_connection_check;
my $settings = plugin_setting;
$settings->{connection_check_threshold} ||= 30;

register dbix => sub {
    if ($dbh) {
        if (time - $last_connection_check
            < $settings->{connection_check_threshold}) {
            return $dbh;
        } else {
            if (_check_connection($dbh)) {
                $last_connection_check = time;
                return $dbh;
            } else {
                Dancer::Logger->debug(
                    "Database connection went away, reconnecting"
                );
                if ($dbh) { $dbh->storage->disconnect; }
                return $dbh = _get_connection();
            }
        }
    } else {
        return $dbh = _get_connection();
    }
};

register_plugin;

sub _get_connection {

    # Assemble the DSN:
    my $dsn;
    if ($settings->{dsn}) {
        $dsn = $settings->{dsn};
    } else {
        $dsn = "dbi:" . $settings->{driver};
        for (qw(database host port)) {
            if (exists $settings->{$_}) {
                $dsn .= ":$_=". $settings->{$_};
            }
        }
    }
    
    unless($settings->{password}) {
        $settings->{password} = `cat $settings->{pass_file}`;
        chomp $settings->{password};
    }
    my $dbh =   Ecenter::Schema->connect($dsn, 
        $settings->{username}, $settings->{password}, $settings->{dbi_params}
    );

    if (!$dbh) {
        Dancer::Logger->error( "Database connection failed ");
    }  
    $dbh->storage->debug(1)  if  $settings->{debug};  

    $last_connection_check = time;
    return $dbh;
}



# Check the connection is alive
sub _check_connection {
    my $dbh = shift;
    return unless $dbh;
    return $dbh->storage->connected;
}


=head1 SYNOPSIS

    use Dancer;
    use Plugin::DBIx;

    # Calling the database keyword will get you a connected Ecenter::Schema handle:
    get '/service/:id' => sub {
        my $service = database->resultset('Service')->search({ id => params->{id} }); 
        return $service->next;
    };

    dance;

Database connection details are read from your Dancer application config - see
below.


=head1 DESCRIPTION

Provides an easy way to obtain a connected Ecenter::Schema handle by simply calling
the database keyword within your L<Dancer> application.

 
=head1 CONFIGURATION

Connection details will be taken from your Dancer application config file, and
should be specified as, for example: 

    plugins:
        Database:
            driver: 'mysql'
            database: 'test'
            host: 'localhost'
            username: 'myusername'
            password: 'mypassword'
	    pass_file: '/etc/my_ecenter'
            connectivity-check-threshold: 10
            dbi_params:
                RaiseError: 1
                AutoCommit: 1

The C<connectivity-check-threshold> setting is optional, if not provided, it
will default to 30 seconds.  If the database keyword was last called more than
this number of seconds ago, a quick check will be performed to ensure that we
still have a connection to the database, and will reconnect if not.  This
handles cases where the database handle hasn't been used for a while and the
underlying connection has gone away.

The C<dbi_params> setting is also optional, and if specified, should be settings
which can be passed to C<< DBI->connect >> as its third argument; see the L<DBI>
documentation for these.

The optional C<pass_file> setting is a filename where to get password for the db, used
if password is not set.

If you prefer, you can also supply a pre-crafted DSN using the C<dsn> setting;
in that case, it will be used as-is, and the driver/database/host settings will 
be ignored.  This may be useful if you're using some DBI driver which requires 
a peculiar DSN.

 
=head1 AUTHOR

David Precious, C<< <davidp@preshweb.co.uk> >>
modified for the DBIx::Class support by Maxim Grigoriev, 2010

=head1 CONTRIBUTING

This module is developed on Github at:

L<http://github.com/bigpresh/Dancer-Plugin-Database>

Feel free to fork the repo and submit pull requests!


=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-database at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-Database>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

 
 
You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-Database>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-Database>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-Database>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-Database/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2010 David Precious.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=head1 SEE ALSO

L<Dancer>

L<DBI>



=cut

1;
