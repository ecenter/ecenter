#!/bin/env perl 
use strict;
use warnings;
=head1 NAME 

create_ecenter_db.pl - create current db structure with timestamped data dir

=head1 DESCRIPTION

create current db structure with timestamped data dir, preserve existing database tables.

=cut

use POSIX qw(strftime);
use Template;
use Carp;
use English;
use Getopt::Long;
use Pod::Usage;
use File::Slurp qw(slurp);
use DBI;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my %OPTIONS; 
my @string_option_keys = qw/user  root_pass db trunk pass/;

GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help/,
) or pod2usage(1);
 
unless($OPTIONS{pass}) {
    $OPTIONS{pass} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{pass};
}
unless($OPTIONS{root_pass}) {
    $OPTIONS{root_pass} = `cat /etc/my_root`;
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

my $dbh = DBI->connect("dbi:mysql:database=$OPTIONS{db}", 'root', $OPTIONS{root_pass}) or croak(" Couldnt connect to db $DBI::errstr");
my $sql= slurp("$OPTIONS{trunk}/collector/sql/ecenter_db.sql");
$dbh->do($sql);
croak("Failed to create in the db: $DBI::errstr") if $DBI::err;
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
