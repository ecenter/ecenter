use warnings;
use strict;    
use Test::More tests => 9;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::Data::Traceroute');
use DateTime;


Log::Log4perl->easy_init($DEBUG); 

my $obj1 = undef;
my $url ='http://anl-pt1.es.net:8085/perfSONAR_PS/services/tracerouteMA';
my %params = (
              url =>  $url, 
	      subject =>   '<traceroute:subject xmlns:traceroute="http://ggf.org/ns/nmwg/tools/traceroute/2.0" id="s-in-traceroute-1"><nmwgt:endPointPair xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">
        <nmwgt:src value="198.124.252.117" type="ipv4"/>
        <nmwgt:dst value="198.129.254.50" type="ipv4"/>
      </nmwgt:endPointPair> </traceroute:subject> '
 
	     );
#2
eval {
$obj1 =  Ecenter::Data::Traceroute->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object  ..  $EVAL_ERROR") ;
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
ok($mds  &&  $key eq '635a20e5e831317cd2392f3d2de1a008', " get_metadata check ...  ") or diag("  $ERRNO". Dumper($obj1->metadata));
ok( $obj1->meta_keys->[0], " meta_keys check ...  ") or diag("  $ERRNO". Dumper($obj1->meta_keys));
$obj1->get_data({ src_ip => "198.124.252.117", dst_ip =>"198.129.254.50" ,  start=> DateTime->from_epoch( epoch => (time() - 80000)), end => DateTime->now(), });
my $dd = $obj1->data;
ok( $dd &&  $dd->[0], " data check ...  ") or diag("  $ERRNO". Dumper($dd));

#11


