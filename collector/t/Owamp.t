use warnings;
use strict;    
use Test::More tests => 9;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::Data::Owamp');
use Ecenter::Data::Requester;
use perfSONAR_PS::Client::MA;
use DateTime;


Log::Log4perl->easy_init($INFO); 

my $obj1 = undef;
my $url ='http://netmon1.atlas-swt2.org:8085/perfSONAR_PS/services/pSB';
my %params = (
              url =>  $url,
              ma   =>  perfSONAR_PS::Client::MA->new( { instance =>  $url}),
	      subject =>  '<owamp:subject xmlns:owamp="http://ggf.org/ns/nmwg/tools/owamp/2.0"  id="s-in-iowamp-1"><nmwgt:endPointPair xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">
       <nmwgt:src value="129.107.255.26" type="ipv4"/>
        <nmwgt:dst value="192.41.236.31" type="ipv4"/>
      </nmwgt:endPointPair> </owamp:subject> '
 
	     );
#2
eval {
$obj1 =  Ecenter::Data::Owamp->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::Owamp...  $EVAL_ERROR") ;
$EVAL_ERROR = undef; 
#3-10
ok($obj1->logger , " Logger check ...  ") or diag("  $ERRNO " . Dumper($obj1));
ok($obj1->ma, " MA check ...  ") or diag("  $ERRNO ". Dumper($obj1));
foreach (qw/url subject/) {
  ok($obj1->$_ eq $params{$_} , " $_ check ...  ") or diag("  $ERRNO". Dumper($obj1));
}

my $self = $obj1->get_metadata;
my $mds = $obj1->metadata;
my ($key ,$md_key) = each  %{$mds};
ok($mds  &&  $key eq 'f2efddac16bec50012b208bd836ba486', " get_metadata check ...  ") or diag("  $ERRNO". Dumper($obj1->metadata));
ok( $obj1->meta_keys->[0], " meta_keys check ...  ") or diag("  $ERRNO". Dumper($obj1->meta_keys));
$obj1->get_data({meta_keys =>  $obj1->meta_keys, start=> DateTime->from_epoch( epoch => (time() - 80000)), end => DateTime->now(), });
my $dd = $obj1->data;
ok( $dd &&  $dd->[0], " data check ...  ") or diag("  Data $ERRNO". Dumper($dd));

#11


