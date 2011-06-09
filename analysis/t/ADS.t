use warnings;
use strict;    
use Test::More tests => 3;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use_ok('Ecenter::ADS::Detector');
use Ecenter::ADS::Detector;
Log::Log4perl->easy_init($INFO); 
 
my $obj1 = undef;
my %params = ( 
	     );
#2
eval {
$obj1 =  Ecenter::ADS::Detector->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::ADS::Detector ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->find_attribute_by_name($_)->get_value($obj1), " Check $_") or diag("$@ failed $_") }
    keys %params;

ok($obj1->can('process_data'), " Check process_data ");

#11


