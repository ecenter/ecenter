#!/usr/local/bin/perl 
use strict;
use warnings;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use Ecenter::Data::Snmp;
use Ecenter::Data::Requester;
#use perfSONAR_PS::Client::Snmp;
use DateTime;

Log::Log4perl->easy_init($INFO); 

my $url = 'http://ps6.es.net:8080/perfSONAR_PS/services/snmpMA';
my $ifaddress = '134.55.220.37';
my %params = (type =>  'snmp', 
  	      url =>  $url,
     	      ifAddress =>  $ifaddress
             );
my $obj1 =  Ecenter::Data::Snmp->new(\%params);
 
$obj1->get_data({ start=> DateTime->from_epoch(epoch => 1301119100),
                  end =>  DateTime->from_epoch(epoch => 1301119500),
                                               direction => 'out' });
my $dd = $obj1->data;
print  Dumper( $obj1->data);

#11


