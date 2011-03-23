use warnings;
use strict;    
use Test::More tests => 9;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::Data::Snmp');
use Ecenter::Data::Requester;
#use perfSONAR_PS::Client::Snmp;
use DateTime;


Log::Log4perl->easy_init($INFO); 

my $obj1 = undef;
my $url = 'http://ps6.es.net:8080/perfSONAR_PS/services/snmpMA';
my $ifaddress = '134.55.209.42';
my %params = (type =>  'snmp', 
              url =>  $url,
         #     ma   =>  perfSONAR_PS::Client::Snmp->new( { instance =>  $url}),
	      ifAddress =>  $ifaddress
	     );
#2
eval {
$obj1 =  Ecenter::Data::Snmp->new(\%params);
};
ok( $obj1  && !$EVAL_ERROR , "Create object Ecenter::Data::Snmp...  $EVAL_ERROR") ;
$EVAL_ERROR = undef; 
#3-10
ok($obj1->logger , " Logger check ...  ") or diag("  $ERRNO " . Dumper($obj1));
ok($obj1->ma, " MA check ...  ") or diag("  $ERRNO ". Dumper($obj1));
foreach (qw/url  ifAddress/) {
  ok($obj1->$_ eq $params{$_} , " $_ check ...  ") or diag("  $ERRNO". Dumper($obj1));
} 
$obj1->get_metadata( {   ifAddress =>  $ifaddress, direction => 'in' });
my $mdd = $obj1->metadata;

ok( $mdd &&  ref $mdd eq ref {}, " metadata check ...  ") or diag("  $ERRNO". Dumper( $obj1->metadata));
my ($key, $val) = each %{$mdd};
ok( $key =~ /metadata/ &&  $mdd->{$key}{direction} eq 'in', " metadata check internal...  ") or diag("  $ERRNO". Dumper( $obj1->metadata));

$obj1->get_data({ start=> DateTime->from_epoch( epoch => (time() - 3600)), end => DateTime->now(),
                                                direction => 'out' });
my $dd = $obj1->data;
ok( $dd &&  $dd->[0] &&  $dd->[0][1] > 0 , " data check ...  ") or diag("  $ERRNO". Dumper( $obj1->data));

#11


