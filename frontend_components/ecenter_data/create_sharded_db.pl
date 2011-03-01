#!/usr/local/bin/perl

use strict;
use warnings;

=head1 NAME 

create_ecenter_db.pl - create ecenter db

=head1 DESCRIPTION

create Ecenter sharded db or update it with  new tables

=head1 OPTIONS

=head2 --user=<string>

username to connect to the ecenter data db 
Default: ecenter

=head2 --root_pass=<string>

root password to connect to the ecenter data db
Default:read from /root/ecenter/etc/my_db 

=head2 --trunk=<string>

absolute path to the trunk dir ( root for the ecenter data API)
Default: /home/netadmin/ecenter/trunk
 
=head2 --db=<string>

database name of the ecenter data db
Default: ecenter_data

=head2 --pass=<string>

password to connect to the ecenter data db  as ecenter user
Default: read from /etc/my_ecenter

=head2 --fresh

drop old db and create a new one with API - usualy done only once
Default: not set

=head2 --db_template

filename of the template file to create db - without partitions - but for the API bindings
Default: $OPTIONS{trunk}/collector/ecenter_sharded_db.tmpl

=head2 --from=2010-02-11

start from the time in the past to create API and DB tables
Deafult: current time

=head2 --to=2010-02-11

end building the APi and DB tables at the time 
Deafult: current time
 
=cut

use POSIX qw(strftime);
use Template;
use Carp;
use Date::Manip::Date;
use English qw( -no_match_vars );
use Getopt::Long;
use Pod::Usage;
use DBI;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
use DateTime;
use DateTime::Format::MySQL;

use Log::Log4perl qw(:easy);


my %OPTIONS; 
my @string_option_keys = qw/user root_pass from to db trunk pass db_template/;

GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug d help fresh/,
) or pod2usage(1);

pod2usage(1) if $OPTIONS{help};

my $output_level = $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);
 
eval {
foreach my $option (qw/from to/) {
    if($OPTIONS{$option}) {
        if($OPTIONS{$option} =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/) {
            $OPTIONS{$option} =  DateTime::Format::MySQL->parse_datetime($OPTIONS{$option} . ' 00:00:00');
        } else{
            pod2usage(2);
        }
    } else {
        $OPTIONS{$option} =   DateTime->now;
    }
}
};
if($EVAL_ERROR) {
    $logger->logdie("$EVAL_ERROR");
}
unless($OPTIONS{pass}) {
    $OPTIONS{pass} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{pass};
}
unless($OPTIONS{root_pass}) {
    $OPTIONS{root_pass} = `cat /root/ecenter/etc/my_db`;
    chomp $OPTIONS{root_pass};
}


$logger->logdie(" no root password provided !!!" ) unless $OPTIONS{root_pass};
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';


$OPTIONS{trunk} ||= '/home/netadmin/ecenter/trunk';
$OPTIONS{db_template} ||= "$OPTIONS{trunk}/collector/ecenter_sharded_db.tmpl";
  
$OPTIONS{preserve} = $OPTIONS{fresh}?'':' if not exists ';

my $template = Template->new({ABSOLUTE => 1});
$logger->logdie(" Template   $OPTIONS{db_template} is missing !!!" ) unless -e  $OPTIONS{db_template};

my $ecenter_db_sql = "$OPTIONS{trunk}/collector/sql/ecenter_sharded_db";
#
#   create SQL file for the DB
#
 
my %datestamps = (); 
$logger->debug("FROM:" . $OPTIONS{from}->epoch  . "  TO:" . $OPTIONS{to}->epoch);
for(my $time=$OPTIONS{from}->epoch;$time<=$OPTIONS{to}->epoch;$time+=3600) {
    my $datestamp = strftime( "%Y%m", localtime($time));
    $datestamps{$datestamp}++;
}
foreach my $date (keys %datestamps) {
    $logger->debug("Building... $date ");
    `mv $ecenter_db_sql.sql  $ecenter_db_sql.$date`  if -e "$ecenter_db_sql.sql";
    $template->process(  $OPTIONS{db_template}, 
                	{ dbname => $OPTIONS{db}, preserve => $OPTIONS{preserve},
			  user => $OPTIONS{user}, pass =>  $OPTIONS{pass}, datestamp => $date  }, 
			"$ecenter_db_sql.sql") 
		             or  $logger->logdie("$ecenter_db_sql.sql processing failed: " . $template->error);

    ####my $dbh = DBI->connect("dbi:mysql:database=$OPTIONS{db}", 'root', $OPTIONS{root_pass}) or croak(" Couldnt connect to db $DBI::errstr");
    #
    #    create DB
    #
    if(system("/usr/local/mysql/bin/mysql -u root -p'$OPTIONS{root_pass}' <  $ecenter_db_sql.sql")) {
	 $logger->logdie("Failed to load  $ecenter_db_sql.sql into the $OPTIONS{db} db: $OS_ERROR $ERRNO");
    }
    #    create API
    #
    make_schema_at(
	  'Ecenter::DB',
	  {  really_erase_my_files =>  ($OPTIONS{fresh}?1:0), 
             dump_directory => "$OPTIONS{trunk}/frontend_components/ecenter_data/lib" },
	   [ "dbi:mysql:database=$OPTIONS{db}", $OPTIONS{user} ,  $OPTIONS{pass} ],
    );
}
#   drop FKs and create/re-org partitions
#
exit 0;
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov 

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010-2011, Fermitools

All rights reserved.

=cut
