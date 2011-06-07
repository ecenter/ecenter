#!/bin/env perl 

use FindBin qw($RealBin);
use lib  "$RealBin";
use Data::Dumper qw(Dumper);

use Log::Log4perl qw(:easy);
use JSON::XS qw(decode_json encode_json);
use English qw( -no_match_vars );

use Ecenter::ADS::Detector::APD;

Log::Log4perl->easy_init($DEBUG); 
 
 
my $data = `cat $RealBin/t/data/owamp.json`;
$data = decode_json $data;
my %params = (
                  data      => $data,
		  data_type => 'owamp',
		  algo      => 'spd',
		  swc => 20
	     );
#2
 
my $obj1 =  Ecenter::ADS::Detector::APD->new(\%params);
$obj1->process_data;
print Dumper $obj1->results;
#11


