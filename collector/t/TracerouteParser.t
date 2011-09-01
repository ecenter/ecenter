use warnings;
use strict;    
use Test::More tests => 25;
use Log::Log4perl qw(:easy);
use English qw( -no_match_vars );
use Data::Dumper;
use_ok('Ecenter::TracerouteParser');
use DateTime;
use Net::Traceroute;
use URI::Escape;

Log::Log4perl->easy_init($INFO); 
my $trace_str = 
'traceroute%20to%20nettest.lbl.gov%20%28131.243.24.11%29%2C%2030%20hops%20max%2C%2040%20byte%20packets%0A%201%20%20r-s-fcc2-server3-vlan110.fnal.gov%20%28131.225.110.200%29%20%200.393%20ms%20%200.430%20ms%20%200.449%20ms%0A%202%20%20r-s-hub-fcc-vlan358.fnal.gov%20%28131.225.15.129%29%20%200.256%20ms%20%200.270%20ms%20%200.279%20ms%0A%203%20%20r-s-edge-1-vlan608.fnal.gov%20%28131.225.102.1%29%20%200.644%20ms%20%200.637%20ms%20%200.245%20ms%0A%204%20%20r-s-bdr-vlan375.fnal.gov%20%28131.225.15.202%29%20%200.433%20ms%20%200.354%20ms%20%200.393%20ms%0A%205%20%20fnal-mr2.fnal.gov%20%28198.49.208.229%29%20%200.234%20ms%20%200.226%20ms%20%200.209%20ms%0A%206%20%20fnalmr3-ip-fnalmr2.es.net%20%28134.55.41.41%29%20%202.341%20ms%20%200.332%20ms%20%200.254%20ms%0A%207%20%20chiccr1-ip-fnalmr3.es.net%20%28134.55.219.121%29%20%201.850%20ms%20%201.841%20ms%20%201.847%20ms%0A%208%20%20kanscr1-ip-chiccr1.es.net%20%28134.55.221.57%29%20%2012.235%20ms%20%2012.204%20ms%20%2012.218%20ms%0A%209%20%20denvcr2-ip-kanscr1.es.net%20%28134.55.209.45%29%20%2025.334%20ms%20%2025.360%20ms%20%2025.339%20ms%0A10%20%20sunncr1-denvcr2.es.net%20%28134.55.220.50%29%20%2052.545%20ms%20%2052.547%20ms%20%2052.532%20ms%0A11%20%20sunnsdn2-sunncr1.es.net%20%28134.55.209.97%29%20%2052.439%20ms%20%2052.458%20ms%20%2052.453%20ms%0A12%20%20slacmr2-ip-sunnsdn2.es.net%20%28134.55.217.1%29%20%2052.823%20ms%20%2052.795%20ms%20%2052.827%20ms%0A13%20%20lblmr2-ip-slacmr2.es.net%20%28134.55.219.9%29%20%2053.895%20ms%20%2053.883%20ms%20%2053.874%20ms%0A14%20%20lbnl-ge-lblmr2.es.net%20%28198.129.224.1%29%20%2054.166%20ms%20%2054.147%20ms%20%2054.127%20ms%0A15%20%20ir2gw.lbl.gov%20%28131.243.128.12%29%20%2054.283%20ms%20%2054.314%20ms%20%2054.326%20ms%0A16%20%20nettest.lbl.gov%20%28131.243.24.11%29%20%2054.046%20ms%20%2054.037%20ms%20%2053.998%20ms%0As';
my $tr = undef;
$trace_str = uri_unescape($trace_str);
#2
eval {
    $tr =  Ecenter::TracerouteParser->new(  );
    $tr->text($trace_str);
};
ok( $tr  && !$EVAL_ERROR , "Create object  ..  $EVAL_ERROR") ;
$EVAL_ERROR = undef; 
my $net_tr;
eval {
    $net_tr =   Net::Traceroute->new(  );
    $net_tr->text($trace_str);
};
ok( $net_tr  && !$EVAL_ERROR , "Create Net::Traceroute  object  ..  $EVAL_ERROR") ;
my $net_parsed;
eval {
    $net_parsed = $net_tr->parse();
};
ok( $net_tr->hops && !$EVAL_ERROR , "Parsed text  with Net::Traceroute ") or diag ( "Failed  $EVAL_ERROR");
$EVAL_ERROR = undef; 

my $parsed;
eval {
    $parsed = $tr->parse();
};
ok( $tr->hops && !$EVAL_ERROR , "Parsed text") or diag ( "Failed  $EVAL_ERROR") ;
$EVAL_ERROR = undef;

#3-10
ok($parsed && ref $parsed eq ref {}, " Parser check ...  ") or diag("  $ERRNO " . Dumper($tr));
ok($parsed->{hops} && ref $parsed->{hops} eq ref {}, " Parser check content...  ") or diag("  $ERRNO " . Dumper($parsed));

is($tr->hops(), 16, "check number of hops") or diag(" Got:: " . $tr->hops() );
is($tr->hop_queries(1), 3, "hop 1 has 3 queries");
foreach my $q (1..3) {
    is($tr->hop_query_host(1, $q), "131.225.110.200", "hop 1, query $q is 131.225.110.200 ");
    is($tr->hop_query_stat(1, $q), TRACEROUTE_OK, "hop 1, query $q is TRACEROUTE_OK");
}
foreach my $q (1..3) {
    is($tr->hop_query_host($tr->hops(), $q), "131.243.24.11", "hop 16, query $q is   131.243.24.11 ");
    is($tr->hop_query_stat($tr->hops(), $q), TRACEROUTE_OK, "hop 16, query $q is TRACEROUTE_OK");
}
$tr = parsefh(*DATA);

#11


is($tr->hop_query_host(1, 1), "2001:470:1f06:177::1", "can extract first v6 addr");
is($tr->hop_query_time(1, 1), 27.047, "hop 1, query 1 time is correct");
is($tr->hop_query_time(1, 2), 23.471, "hop 1, query 2 time is correct");
is($tr->hop_query_host(8, 1), "2001:4f8:3:7:2e0:81ff:fe52:9a6b", "can extract last v6 addr");

sub parsefh {
    my $fh = shift;
    my $text;
    { local $/ = undef; $text = <$fh>; }
    close($fh);
    parsetext($text);
}

sub parsetext {
    my $text = shift;
    my $tr = Ecenter::TracerouteParser->new();
    $tr->text($text);
    $tr->parse();
    return($tr);
}

__END__
 1  2001:470:1f06:177::1  27.047 ms  23.471 ms  25.256 ms
 2  2001:470:0:5d::1  25.026 ms  24.045 ms  24.046 ms
 3  2001:470:0:4e::1  45.484 ms  44.195 ms  45.763 ms
 4  2001:470:1:34::2  45.18 ms  47.433 ms  43.312 ms
 5  2001:500:71:6::1  46.941 ms  45.953 ms  62.494 ms
 6  2001:4f8:0:1::4a:1  100.9 ms  100.014 ms  103.981 ms
 7  2001:4f8:1b:1::8:2  100.119 ms  99.906 ms  100.206 ms
 8  2001:4f8:3:7:2e0:81ff:fe52:9a6b  98.68 ms  98.704 ms  98.183 ms
