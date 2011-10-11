#!/bin/env perl 

use FindBin qw($RealBin);
use lib  "$RealBin";
use Data::Dumper qw(Dumper);

use Log::Log4perl qw(:easy);
use JSON::XS qw(decode_json encode_json);
use English qw( -no_match_vars );

use Ecenter::ADS::Detector::FFF;

Log::Log4perl->easy_init($DEBUG); 
 
 
my $data = `cat $RealBin/t/data/bwctl2.json`;
$data = decode_json $data;
my %params = (
                  data      => $data,
		  data_type => 'bwctl',
		  future_points => 15, 
	     );
#2
 
my $obj1 =  Ecenter::ADS::Detector::FFF->new(\%params);
$obj1->process_data;
print "Results:" . Dumper($obj1->results);
#11


