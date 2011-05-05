#!/usr/local/bin/perl
use strict;
use warnings;  

use forks;
use forks::shared;


use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;

use Ecenter::Data::Snmp;
use Data::Dumper;
use DBI;
use Ecenter::Utils;
local $SIG{CHLD} = 'IGNORE';

my %OPTIONS;

my @string_option_keys = qw/password user db   stress max/;
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

my $url = 'http://ps6.es.net:8080/perfSONAR_PS/services/snmpMA';
 
$OPTIONS{stress} ||= 240;
$OPTIONS{max} ||= 10;
$OPTIONS{period} ||= 2; # hours to send request for
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';
unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{password};
}

my $dbh =  DBI->connect('DBI:mysql:' . $OPTIONS{db},  $OPTIONS{user}, $OPTIONS{password},
                                    {RaiseError => 1, PrintError => 1});

my %data = %{$dbh->selectall_hashref( qq|select distinct n.ip_noted  from node n join metadata m on(n.ip_addr=m.src_ip)
                                       join snmp_data_201104 s on(s.metaid=m.metaid)|, 'ip_noted')};

 print '"Days", "Passed", "Attempted, Time"' . "\n";
for(my $stress = 1; $stress <= $OPTIONS{stress}; $stress++ ) {
    my $IPs : shared = 0;
    my $GOOD  : shared = 0;
    my $TTIME : shared = 0;
    foreach my $addr (keys %data) {
        last if $IPs > $OPTIONS{max};
        pool_control(1, 0);
        threads->new({'context' => 'scalar'},
            sub {  
        	my %params = ( type =>  'snmp',
         		       url =>  $url,
         		       ifAddress => $addr
		);
		my $t1 = time();
	        my $obj1 =  Ecenter::Data::Snmp->new(\%params);
	        eval {
		    $logger->info("-- Tried:$IPs Passed:$GOOD") unless ($IPs++) % 10;
		    $obj1->get_data({ start     => DateTime->from_epoch( epoch => (time() - ($stress*24*3600))),
                                      end       => DateTime->from_epoch( epoch => (time() - (24*3600))),
                                      direction => 'out' });
	        };
	        my $dd = $obj1->data;
	        if($@ || !($dd &&  $dd->[0] &&  $dd->[0][0] > 0)) {
        	    $logger->error(" $addr failed $@", sub{Dumper($dd)});
		    return;
	        }
		my $t2 = time() - $t1;
		$TTIME+=$t2;
	        $GOOD++; 
	   }
	);
	
    }
    pool_control(1, 1);
    print "$stress, $GOOD, $IPs, $TTIME\n";
}

exit 0;
