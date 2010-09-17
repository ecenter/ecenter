use warnings;
use strict;    
use Test::More tests => 5;
use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );
use_ok('Ecenter::Data::Requester');
use Ecenter::Data::Hub; 

Log::Log4perl->init("logger.conf"); 

my $obj1 = undef;
my %params = (  hub_name => 'FNAL'  );
#2
eval {
$obj1 =  Ecenter::Data::Hub->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::Hub ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->get_attribute($_)->get_value($obj1), " Check $_") } keys %params;
ok($obj1->get_ips, " get_ips check ...  ");
my $ips =  $obj1->get_ips;
ok($ips->{'131.225.0.0'} == 16, " Type check ...  ");

#11


