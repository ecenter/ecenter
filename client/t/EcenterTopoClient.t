use warnings;
use strict;    
use Test::More tests => 8;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use_ok('Ecenter::TopoClient');
use Ecenter::TopoClient;
Log::Log4perl->easy_init($INFO); 
 
my $obj1 = undef;
my %params = ( url =>  'url_value_id',
	       src_ip => '134.225.111.89'
	     );
#2
eval {
$obj1 =  Ecenter::TopoClient->new(\%params);
};
#$obj1->url('url_value_id');
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::TopoClient ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->find_attribute_by_name($_)->get_value($obj1), " Check $_") or diag("$@ failed $_") }
    keys %params;
ok($obj1->url  eq 'url_value_id', " URL check ...  ");
ok($obj1->can('get_hubs'), " Check get_hubs ");
ok($obj1->can('get_nodes'), " Check get_nodes ");
ok($obj1->can('get_destination_hubs'), " Check get_destination_hubs ");
#11


