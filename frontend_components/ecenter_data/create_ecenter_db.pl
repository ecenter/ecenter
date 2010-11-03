#!/bin/env perl 
use strict;
use warnings;
=head1 NAME 

create_ecenter_db.pl - create current db structure with timestamped data dirs

=head1 DESCRIPTION

create current db structure with timestamped data dir, preserve existing database tables.
Must be <root> to run.

=head1 OPTIONS

=head2 user

  username to connect to the ecenter data db 
  Default: ecenter

=head2 root_pass

 root password to connect to the ecenter data db
 Default:read from /root/ecenter/etc/my_db 

=head2 trunk

 absolute path to the trunk dir ( root for the ecenter data API)
 Default: /home/netadmin/ecenter/trunk
 
=head2 db

database name of the ecenter data db
Default: ecenter_data

=head2 pass

  password to connect to the ecenter data db  as ecenter user
  Default: read from /etc/my_ecenter

=cut

use POSIX qw(strftime);
use Template;
use Carp;
use English qw( -no_match_vars );
use Getopt::Long;
use Pod::Usage;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my %OPTIONS; 
my @string_option_keys = qw/user root_pass db trunk pass/;

GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help/,
) or pod2usage(1);
 
unless($OPTIONS{pass}) {
    $OPTIONS{pass} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{pass};
}
unless($OPTIONS{root_pass}) {
    $OPTIONS{root_pass} = `cat /root/ecenter/etc/my_db`;
    chomp $OPTIONS{root_pass};
}
croak(" no root password provided !!!" ) unless $OPTIONS{root_pass};
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';

my $today = strftime("%Y%m", localtime());
$OPTIONS{trunk} ||= '/home/netadmin/ecenter/trunk';
my $templfile = "$OPTIONS{trunk}/collector/ecenter_db_sql.tmpl";
my $template = Template->new({ABSOLUTE => 1});
croak(" Template $template is missing !!!" ) unless -e  $templfile;
`mv $OPTIONS{trunk}/collector/sql/ecenter_db.sql  $OPTIONS{trunk}/collector/sql/ecenter_db.$today` if -e "$OPTIONS{trunk}/collector/sql/ecenter_db.sql";
$template->process(  $templfile, 
                    { datestamp => $today, dbname => $OPTIONS{db}, 
		      user => $OPTIONS{user}, pass =>  $OPTIONS{pass} }, 
		    "$OPTIONS{trunk}/collector/sql/ecenter_db.sql") or croak("processing failed: " . $template->error);

####my $dbh = DBI->connect("dbi:mysql:database=$OPTIONS{db}", 'root', $OPTIONS{root_pass}) or croak(" Couldnt connect to db $DBI::errstr");
if(system("/usr/local/mysql/bin/mysql -u root -p'$OPTIONS{root_pass}' < $OPTIONS{trunk}/collector/sql/ecenter_db.sql")) {
   croak("Failed to create in the db: $OS_ERROR $ERRNO");
}
make_schema_at(
      'Ecenter::DB',
      {  dump_directory => "$OPTIONS{trunk}/frontend_components/ecenter_data/lib" },
       [ "dbi:mysql:database=$OPTIONS{db}", $OPTIONS{user} ,  $OPTIONS{pass} ],
);
 
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov 

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010, Fermitools

All rights reserved.

=cut
