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

my @string_option_keys = qw/password user db ips host  period stress max/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
	   qw/debug help forks_test bunch_test v/
) or pod2usage(1);
pod2usage(2) unless $OPTIONS{forks_test} || $OPTIONS{bunch_test};
my $output_level =  $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

my $url = 'http://ps6.es.net:8080/perfSONAR_PS/services/snmpMA';
 
$OPTIONS{stress} ||= 50; # max number of parallel streams
$OPTIONS{ips} ||= 50; # max number of IPs in the single request
$OPTIONS{max} ||= 20; #max number of interfaces - tests
$OPTIONS{period} ||= 1   ; # hours to send request for
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{host} ||= 'ecenterprod1.fnal.gov';
$OPTIONS{user} ||= 'ecenter';
unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter_ecenterprod1.fnal.gov`;
    chomp $OPTIONS{password};
}

my $dbh =  DBI->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};", $OPTIONS{user}, $OPTIONS{password},
                                    {RaiseError => 1, PrintError => 1});

my %data = %{$dbh->selectall_hashref( qq|select distinct n.ip_noted  from node n join metadata m on(n.ip_addr=m.src_ip)
                                       join snmp_data_201112 s on(s.metaid=m.metaid)|, 'ip_noted')};

if($OPTIONS{forks_test}) {
  print '"Forks", "Passed", "Attempted"' . "\n";
  for(my $stress = 1; $stress <= $OPTIONS{stress}; $stress +=5 ) {
    my $IPs : shared = 0;
    my $GOOD  : shared = 0;
    foreach my $addr (keys %data) {
        last if $IPs > $OPTIONS{max};
        pool_control($stress, 0);
        threads->new({'context' => 'scalar'},
            sub {  
        	my %params = ( type =>  'snmp',
         		       url =>  $url,
         		       ifAddress => [$addr]
		);
	        my $obj1 =  Ecenter::Data::Snmp->new(\%params);
	        eval {
		    $logger->debug("-- Tried:$IPs Passed:$GOOD") unless ($IPs++) % 5;
		    $obj1->get_data({ start     => DateTime->from_epoch( epoch => (time() - (24+$OPTIONS{period})*3600)),
                                      end       => DateTime->from_epoch( epoch => (time() - 24*3600)),
                                      direction => 'out' });
	        };
	        my $dd = $obj1->data;
	        if($@ || !($dd &&   ($dd->[1] &&  $dd->[1][0]  )   )) {
        	    $logger->error(" $addr failed $@", sub{Dumper($dd)});
		    return;
	        }
	        $GOOD++; 
	   }
	);
    }
    pool_control($stress , 1);
    print "$stress, $GOOD, $IPs\n";
  }
}
if($OPTIONS{bunch_test}) {
  print '"Aggregated", "Forks", "Passed", "Attempted"' . "\n";
  for(my $ips = 1; $ips <= $OPTIONS{ips}; $ips +=5 ) {
    my $requested_addr = [];
    my $IPs  = 0;
    foreach my $addr (keys %data) { 
       push @{$requested_addr}, $addr;
       last if $IPs++ > $ips;
    }
    for(my $stress = 1; $stress <= $OPTIONS{stress}; $stress +=5 ) {
       my $TRIED : shared = 0;
       my $GOOD  : shared = 0;
       foreach my $repetition (1..$OPTIONS{max}) {
          pool_control($stress, 0);
          threads->new({'context' => 'scalar'},
             sub {  
        	my %params = ( type =>  'snmp',
         		       url =>  $url,
         		       ifAddress => $requested_addr
		);
	        my $obj1 =  Ecenter::Data::Snmp->new(\%params);
	        eval {
		    $logger->debug("-- Tried:$TRIED Passed:$GOOD") unless ($TRIED++) % 5;
		    $obj1->get_data({ start     => DateTime->from_epoch( epoch => (time() - (24+$OPTIONS{period})*3600)),
                                      end       => DateTime->from_epoch( epoch => (time() - 24*3600)),
                                      direction => 'out' });
	        };
	        my $dd = $obj1->data;
	        if($@ || !($dd &&   ($dd->[1] &&  $dd->[1][0]  )   )) {
        	    $logger->error(" failed $@", sub{Dumper($dd)});
		    return;
	        }
	        $GOOD++; 
	     }
	  );
       }
       pool_control($stress , 1);
       print "$ips, $stress, $GOOD, $TRIED\n";
    }
  }
}
exit 0;
