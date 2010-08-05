use warnings;
use strict;    
use Test::More tests => 10;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::Data::Bwctl');
use Ecenter::Data::Requester;
use perfSONAR_PS::Client::MA;
use DateTime;


Log::Log4perl->easy_init($INFO); 

my $obj1 = undef;
my $url ='http://lhc-dmz-bw.deemz.net:8085/perfSONAR_PS/services/pSB';
my %params = (
              url =>  $url,
              ma   =>  perfSONAR_PS::Client::MA->new( { instance =>  $url}),
	      dst => 'lhc-dmz-bw.deemz.net',
	      src => 'anlborder-ps.it.anl.gov'
	     );
#2
eval {
$obj1 =  Ecenter::Data::Bwctl->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::Bwctl...  $EVAL_ERROR") ;
$EVAL_ERROR = undef; 
#3-10
ok($obj1->logger , " Logger check ...  ") or diag("  $ERRNO " . Dumper($obj1));
ok($obj1->ma, " MA check ...  ") or diag("  $ERRNO ". Dumper($obj1));
foreach (qw/url/) {
  ok($obj1->$_ eq $params{$_} , " $_ check ...  ") or diag("  $ERRNO". Dumper($obj1));
}

my $self = $obj1->get_metadata;
my $mds = $obj1->metadata;
ok($mds  &&  $mds ->{'xenmon.fnal.gov:pinger.slac.stanford.edu:1000'}, " get_metadata check ...  ") or diag("  $ERRNO". Dumper($obj1->metadata));
ok( $obj1->meta_keys->[0], " meta_keys check ...  ") or diag("  $ERRNO". Dumper($obj1->meta_keys));
$obj1->get_data({meta_keys => $mds ->{'xenmon.fnal.gov:pinger.slac.stanford.edu:1000'}{keys}, start=> DateTime->from_epoch( epoch => (time() - 80000)), end => DateTime->now(), });
my $dd = $obj1->data;
ok( $dd &&  $dd->[0], " data check ...  ") or diag("  $ERRNO". Dumper($dd));

#11


