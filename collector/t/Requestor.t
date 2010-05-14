use warnings;
use strict;    
use Test::More tests => 10;
use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );
use_ok('Ecenter::Data::Requester');
use Ecenter::Data::Requester;
use  perfSONAR_PS::Client::PingER;

Log::Log4perl->init("logger.conf"); 

my $obj1 = undef;
my %params = (type =>  'type1', url =>  'url_value_id',
              ma   =>  perfSONAR_PS::Client::PingER->new( { instance => 'http://localhost:8075'}),
	      src_regexp => '131',
	      dst_regexp => '34',
	      logger=> get_logger()
	     );
#2
eval {
$obj1 =  Ecenter::Data::Requester->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::Requester ...  $EVAL_ERROR");
$EVAL_ERROR = undef; 
#3-10
map {  ok($obj1->meta->get_attribute($_)->get_value($obj1), " Check $_") } keys %params;
ok($obj1->url  eq 'url_value_id', " URL check ...  ");
ok($obj1->type eq 'type1', " Type check ...  ");

#11


