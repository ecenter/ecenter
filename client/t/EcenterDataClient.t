use warnings;
use strict;    
use Test::More tests => 14;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use_ok('Ecenter::DRS::DataClient');
use Ecenter::DRS::DataClient;
Log::Log4perl->easy_init($INFO); 
 
my $obj1 = undef;
my %params = ( url =>  'url_value_id',
	       timeout => 10,
	       resolution => 15,
	       src_ip => '134.225.111.89',
	       dst_ip => '130.247.67.89',
	       src_hub => 'fnal',
	       data_type => 'snmp',
	       dst_hub => 'lbl',
	       start => '2000-01-03 00:10:09',
	       end => '2002-01-03 00:10:09'
	     );
#2
eval {
$obj1 =  Ecenter::DRS::DataClient->new(\%params);
};
#$obj1->url('url_value_id');
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::DRS::DataClient ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->find_attribute_by_name($_)->get_value($obj1), " Check $_") or diag("$@ failed $_") }
    keys %params;
ok($obj1->url  eq 'url_value_id', " URL check ...  ");

ok($obj1->can('get_data'), " Check get_data ");

#11


