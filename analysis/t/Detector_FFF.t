use warnings;
use strict;

use FindBin qw($RealBin);
use lib  "$RealBin";


use Test::More tests => 8;
use Log::Log4perl qw(:easy);
use JSON::XS qw(decode_json encode_json);
use English qw( -no_match_vars );
use_ok('Ecenter::ADS::Detector::FFF');
use Ecenter::ADS::Detector::FFF;
Log::Log4perl->easy_init($DEBUG); 
 
my $obj1 = undef;
 
my $data = `cat $RealBin/data/bwctl.json`;
$data = decode_json $data;
my %params = (
                  data      => $data,
		  data_type => 'bwctl',
		  future_points => '5',
	     );
#2
eval {
$obj1 =  Ecenter::ADS::Detector::FFF->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::ADS::Detector::FFF ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->find_attribute_by_name($_)->get_value($obj1), " Check $_") or diag("$@ failed $_") }
    keys %params;

ok($obj1->can('process_data'), " Check process_data ");
ok($obj1->process_data, " Process_data ");
ok($obj1->results && ref $obj1->results eq ref {}, " Process_data is done");

#11


