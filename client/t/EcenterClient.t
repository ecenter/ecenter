use warnings;
use strict;    
use Test::More tests => 6;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use_ok('Ecenter::DRS::Client');
use Ecenter::DRS::Client;
Log::Log4perl->easy_init($INFO); 
 
my $obj1 = undef;
my %params = ( url =>  'url_value_id',
	       logger=> get_logger()
	     );
#2
eval {
$obj1 =  Ecenter::DRS::Client->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::DRS::Client ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->get_attribute($_)->get_value($obj1), " Check $_") } keys %params;
ok($obj1->url  eq 'url_value_id', " URL check ...  ");
ok($obj1->can('send_request'), " Check send_request");

#11


