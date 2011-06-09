use warnings;
use strict;

use FindBin qw($RealBin);
use lib  "$RealBin";


use Test::More tests => 7;
use Log::Log4perl qw(:easy);
use JSON::XS qw(decode_json encode_json);
use English qw( -no_match_vars );
use_ok('Ecenter::ADS::Detector::APD');
use Ecenter::ADS::Detector::APD;
Log::Log4perl->easy_init($INFO); 
 
my $obj1 = undef;
 
my $data = `cat $RealBin/data/bwctl.json`;
$data = decode_json $data;
my %params = (
                  data      => $data,
		  data_type => 'bwctl',
		  algo      => 'apd',
	     );
#2
eval {
$obj1 =  Ecenter::ADS::Detector::APD->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::ADS::Detector::APD ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->find_attribute_by_name($_)->get_value($obj1), " Check $_") or diag("$@ failed $_") }
    keys %params;

ok($obj1->can('process_data'), " Check process_data ");
ok($obj1->process_data, " Process_data ");
ok($obj1->results && ref $obj1->results eq ref {}, " Process_data is done");

#11


