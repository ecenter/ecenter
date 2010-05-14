use warnings;
use strict;    
use Test::More tests => 11;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::Data::PingER');
use Ecenter::Data::Requester;
use perfSONAR_PS::Client::PingER;
use DateTime;


Log::Log4perl->easy_init($INFO); 

my $obj1 = undef;
my $url ='http://xenmon.fnal.gov:8075/perfSONAR_PS/services/pinger/ma';
my %params = (type =>  'pinger', 
              url =>  $url,
              ma   =>  perfSONAR_PS::Client::PingER->new( { instance =>  $url}),
	      src_regexp => 'fnal',
	      dst_regexp => 'slac'
	     );
#2
eval {
$obj1 =  Ecenter::Data::PingER->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::PingER...  $EVAL_ERROR") ;
$EVAL_ERROR = undef; 
#3-10
ok($obj1->logger , " Logger check ...  ") or diag("  $ERRNO " . Dumper($obj1));
ok($obj1->ma, " MA check ...  ") or diag("  $ERRNO ". Dumper($obj1));
foreach (qw/type url src_regexp dst_regexp/) {
  ok($obj1->$_ eq $params{$_} , " $_ check ...  ") or diag("  $ERRNO". Dumper($obj1));
} 
my $self = $obj1->get_metadata;
my $mds = $obj1->metadata;
ok($mds  &&  $mds ->{'xenmon.fnal.gov:pinger.slac.stanford.edu:1000'}, " get_metdata check ...  ") or diag("  $ERRNO". Dumper($obj1->metadata));
ok( $obj1->meta_keys->[0], " meta_keys check ...  ") or diag("  $ERRNO". Dumper($obj1->meta_keys));
$obj1->get_data({meta_keys => $mds ->{'xenmon.fnal.gov:pinger.slac.stanford.edu:1000'}{keys}, start=> DateTime->from_epoch( epoch => (time() - 80000)), end => DateTime->now(), });
my $dd = $obj1->data;
ok( $dd &&  $dd->[0], " data check ...  ") or diag("  $ERRNO". Dumper($dd));

#11


