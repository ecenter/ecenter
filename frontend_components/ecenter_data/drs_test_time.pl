#!/usr/local/bin/perl
use strict;
use warnings;  

use lib qw(lib);

use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;

use DRS::DataClient;
use Data::Dumper;
use DBI;
use POSIX qw(strftime);
use Ecenter::Utils;
use DateTime::Format::MySQL;

local $SIG{CHLD} = 'IGNORE';

local $| = 1;

my %OPTIONS;

my @string_option_keys = qw/password user db start seconds url stress max/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
	   qw/debug help v/
) or pod2usage(1);
my $output_level =  $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

$OPTIONS{url} ||= 'http://localhost:8055';
$OPTIONS{stress} ||= 30;
$OPTIONS{max} ||= 5;
$OPTIONS{period} ||= 2; # hours to send request for
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';
$OPTIONS{seconds} ||= 3600;
eval {
    $OPTIONS{start}  =  $OPTIONS{start}?
        DateTime::Format::MySQL->parse_datetime( $OPTIONS{start} ):
	    DateTime::Format::MySQL->parse_datetime( '2011-04-01 01:01:01' );
};
if($@) {
    $logger->logdie($@);
}

unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{password};
}

my $dbh =  DBI->connect('DBI:mysql:' . $OPTIONS{db},  $OPTIONS{user}, $OPTIONS{password},
                                    {RaiseError => 1, PrintError => 1});

 
print '"Days", "Attempt0", "Attempt1", "Attempt2", "Time0", "Time1", "Time2"' . "\n";
for(my $stress = 1; $stress <= $OPTIONS{stress}; $stress++ ) {
    my @good =();
    my @times =();
    for(my $try = 0;$try<$OPTIONS{max};$try++) {
        my $data;
	my $t1 = time();
	eval {
            $data= Ecenter::DataClient->new( {  url =>  $OPTIONS{url}  } );
            ## send request for all data between two hubs 
            my $end =  DateTime->from_epoch( epoch =>  ($OPTIONS{start}->epoch + $stress*$OPTIONS{seconds}));
	    my $data_hr  = $data->get_data({src_hub => 'ANL', dst_hub => 'LBL', 
                                        start =>    DateTime::Format::MySQL->format_datetime($OPTIONS{start}),
					end =>  DateTime::Format::MySQL->format_datetime($end),
				        resolution => 50, timeout => 1000 } );
        };
	if($@ || !($data->snmp && ref $data->snmp eq ref {})) {
	    $logger->error("Failed $@", sub{Dumper($data->snmp)});
	    push @good, 0;
	} else {
	    push @good, 1;
	 }  
	 push @times, (time()-$t1);
    }
    print "$stress, ". join(', ', @good) . ',' . join(', ', @times) . "\n";
}

exit 0;
