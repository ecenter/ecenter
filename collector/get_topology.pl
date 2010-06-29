#!/usr/bin/perl -w

use strict;
use warnings;

=head1 NAME

get_topology.pl - cache script for the ESnet topology data

=head1 DESCRIPTION

grabs, parses and inserts into the ecenter db all found ESnet topology info

=head1 SYNOPSIS

./get_topology.pl 

=head1 OPTIONS

=over

=item --debug

debugging info logged

=item --help

print help

=item -db=[database name]

backend DB name
Default: ecenter_data


=item --user=[db username]

backend DB username
Default: ecenter

=item --password=[db password]

backend DB password   
Default: from /etc/my_ecenter

=back

=cut
 
use FindBin qw($Bin);
use lib "$Bin/../lib";

use POSIX qw(strftime);
use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;
use Data::Dumper;
use XML::LibXML;

use perfSONAR_PS::Client::MA;
use perfSONAR_PS::Client::Topology;
use perfSONAR_PS::Common qw(  extract find unescapeString escapeString );
use perfSONAR_PS::Error_compat qw/:try/;
use perfSONAR_PS::Error;
use Ecenter::Data::Snmp;
use Ecenter::Utils;
use Ecenter::Schema;

our %ESNET_HUB = (
        "sunn-cr1" => "SUNN", 
        "ornl-rt1" =>  "ORNL",
        "chic-cr1"  =>  "CHIC", 
        "bnl-mr2"   => "BNL", 
        "pnwg-cr1"  =>  "PNWG", 
        "wash-cr1"  => "WASH",
        "pantex-rt1"  => "PANTEX",
        "bois-cr1"  => "BOIS",
        "atla-cr1"  => "ATLA",
        "denv-cr2"  => "DENV",
        "albu-cr1"  =>  "ALBU",
        "clev-cr1"  =>  "CLEV",
        "elpa-cr1"  => "ELPA",
        "bost-cr1" =>  "BOST",
        "losa-sdn1"  =>  "LOSA",
        "inl-rt1"  => "INL",
        "ameslab-rt1"   => "AMES",
        "sdsc-sdn2"  =>  "SDSC",
        "aofa-cr2"  =>  "NEWY",
        "nash-cr1"  => "NASH",
        "hous-cr1"  => "HOUS",
        "kans-cr1"  => "KANS",
        "lasv-rt1"  => "LASV",
        "srs-rt1"   =>  "SRS",
	);

my %OPTIONS;
my @string_option_keys = qw/password user db/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help/,
) or pod2usage(1);

$OPTIONS{debug}?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(-verbose => 2) if ( $OPTIONS{help} );

$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';
unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{password};
}

my $parser = XML::LibXML->new();
my $ip_topology = 'ps.es.net';
my @esnet_hosts = qw/ps1 ps2 ps3/;
my $dbh =  Ecenter::Schema->connect('DBI:mysql:' . $OPTIONS{db},  $OPTIONS{user}, $OPTIONS{password}, 
                                    {RaiseError => 1, PrintError => 1});
$dbh->storage->debug(1)  if $OPTIONS{debug};
		
foreach my $service ( qw/ps3/ ) {
    my $ts_instance =  "http://$service.es.net:8012/perfSONAR_PS/services/topology";
    try {  
        $logger->debug("\t\t Service at:\t$ts_instance ");
        my $client = perfSONAR_PS::Client::Topology->new($ts_instance);
        my $urn = "domain=$ip_topology";
        my ($status, $res) = $client->xQuery("//*[matches(\@id, '$urn', 'xi')]", 'encoded');
        throw  perfSONAR_PS::Error if $status;
	parse_topo($dbh, $res);
    }
    catch perfSONAR_PS::Error   with {
        $logger->error( shift);
    } catch perfSONAR_PS::Error_compat with {
        $logger->error( shift);
    }
    otherwise {
        my $ex  = shift; 
        $logger->error("Unhandled exception or crash: $ex");
    }
    finally {
        $dbh->storage->disconnect if $dbh;
    };
}

=head2  parse_topo

 parse esnet topology service, translation from PerfsonarTP.java
 first it stores all found nodes and ports and then it links them
 
=cut

sub parse_topo {
    my ($dbh, $xml) = @_;
    $xml->setNamespace("http://ogf.org/schema/network/topology/base/20070828/", "nmtb");
    my %l2_linkage = ();
  
    my $nodes =   find( $xml, "./nmtb:node", 0 );
    foreach my $node ($nodes->get_nodelist) {
        my $name        = extract( find( $node, "./nmtb:name", 1), 1);
	my $description = extract( find( $node, "./nmtb:description", 1), 1);
        my $longitude   = extract( find( $node, "./nmtb:longitude", 1), 1);
        my $latitude    = extract( find( $node, "./nmtb:latitude", 1), 1);
	 
	my ($hub_name) = $name =~ m/^([^-]+)-/;
	my $hub = $dbh->resultset('Hub')->update_or_create({  hub => $name,
	                                                      hub_name => "\U$hub_name",
		    				              longitude =>  $longitude,
							      latitude => $latitude,
							      description => $description
							  });
	$node->setNamespace("http://ogf.org/schema/network/topology/l2/20070828/", "nmtl2");
	my $l2_ports =   find( $node, "./nmtl2:port", 0 );
        foreach my $port2 ($l2_ports->get_nodelist) {
            my $urn2     = $port2->getAttribute('id');
	    my $capacity = extract( find( $port2, "./nmtl2:capacity", 1), 1);
	    my $description2 = extract( find( $port2, "./nmtl2:ifDescription", 1), 1);
	    my $l2_port  = $dbh->resultset('L2_port')->update_or_create({ 
	                                                      l2_urn => $urn2,
							      capacity =>  $capacity,
							      hub => $hub,
							      description => $description2
							    });
	    my $l2_links = find($port2, "./nmtl2:link", 0);  
	    foreach my $link2 ($l2_links->get_nodelist) {
	        my $relations = find($link2, "./nmtb:relation", 0);  
	        foreach my $rel2 ($relations->get_nodelist) {
		    my $rel2_type = $rel2->getAttribute('type');
		    if($rel2_type eq 'sibling') {
		        my $rem_link_id =  extract( find( $rel2, "./nmtb:idRef", 1), 1);
		     	$l2_linkage{$urn2}{$rem_link_id}++ unless  $l2_linkage{$rem_link_id}{$urn2};
		    }
	        }
            }  
        }
        $node->setNamespace("http://ogf.org/schema/network/topology/l3/20070828/", "nmtl3");
        my $l3_ports =   find( $node, "./nmtl3:port", 0 );
        foreach my $port3 ($l3_ports->get_nodelist) {
            my $port2_name    =  extract( find( $port3, "./nmtl3:ifName", 1), 1);
	    my $ip_notted = extract( find( $port3, "./nmtl3:ipAddress", 1), 1);
	    my $netmask = extract( find( $port3, "./nmtl3:netmask", 1), 1);
	    my ($ip_addr,$ip_name) = get_ip_name($ip_notted); 
	    unless($ip_addr) {
	        $logger->error(" wrong address: $ip_notted, skipped");
	        next;
	    }
	    update_create_fixed($dbh->resultset('Node'),
		    					      {ip_addr =>  \"=inet6_pton('$ip_addr')"},
		    					      {ip_addr => \"inet6_pton('$ip_addr')",
		    					       nodename => $ip_name,
							       netmask =>  \"inet6_pton('$netmask')",
		    					       ip_noted => $ip_addr}); 
	    my $ip_addr_obj =  $dbh->resultset('Node')->find({ip_noted => $ip_addr});
	    $dbh->resultset('L2_l3_map')->update_or_create({ ip_addr => $ip_addr_obj,
	                                                     l2_urn => $port2_name,
							  });
        }
    }
    foreach my $link_src (keys %l2_linkage) {
        foreach my $link_dst (keys %l2_linkage) {
	     $dbh->resultset('L2_link')->update_or_create({ 
	                                                    l2_src_urn => $link_src,
	                                                    l2_dst_urn => $link_dst
							 });
        }
    }
}

 
