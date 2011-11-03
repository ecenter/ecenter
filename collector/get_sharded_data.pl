#!/bin/env perl

use strict;
use warnings;

=head1 NAME

get_sharded_data.pl - cache script for the  E-Center data

=head1 DESCRIPTION

grabs, parses and inserts into the ecenter db all found data from the remote MAs. Based on the pre-collected metadata.
Also, it  looks for the last week worth of data to find anomalies using SPD algo. It treats anoma;ies the same way as data.


=head1 SYNOPSIS

./get_sharded_data.pl

=head1 OPTIONS

=over


=item --debug

debugging info logged

=item --help

$logger->debug(usage info

=item --[pinger|owamp|bwctl|hop|anomaly]

setting any of these flags will force collection of the corresponded data from the all known remote MAs.
Or it will search for anomalies. 

=item --past=<N days>

get SNMP data for the past N days, limited by 1000 days. 
It will search for the week or more of the data for anomalies.
Default:7 days
 
=item --snmp

get SNMP data as well

=item --circuits

get ESnet OSCAR circuits data

=item --db=[database name]

backend DB name
Default: ecenter_data

=item --procs

number of asynchronous procs to spawn ( requests to remote MAs)
Max number is 40.
Default: 10

=item --host=[db hostname]

backend DB hostname
Default: ecenterprod1.fnal.gov

=item --user=[db username]

backend DB username
Default: ecenter

=item --password=[db password]

backend DB password   
Default: from /etc/my_ecenter

=back

=cut
 
use FindBin qw($Bin);
use lib ($Bin, "$Bin/circuits_lib", "$Bin/client_lib", "$Bin/ps_trunk/perfSONAR_PS-PingER/lib");
use forks;
use forks::shared;

use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;
use Data::Dumper;
use XML::LibXML;
use Net::Netmask;
use POSIX qw(strftime);
#use Parallel::ForkManager;
use DBI;
use English;
use perfSONAR_PS::Client::MA;
use perfSONAR_PS::Client::Topology;
use perfSONAR_PS::Client::TopologyOld;
use perfSONAR_PS::Client::Circuits;

use perfSONAR_PS::Common qw(  extract find unescapeString escapeString );
use perfSONAR_PS::Error_compat qw/:try/;
use perfSONAR_PS::Error;
use Ecenter::Utils;
use Ecenter::DB;
use Ecenter::Data::Hub;
use Ecenter::Client;
use Ecenter::Data::Snmp;
use DateTime;
use Ecenter::ADS::Detector::APD;
 
# Maximum working threads
my $MAX_THREADS = 10;
local $SIG{CHLD} = 'IGNORE';
my %OPTIONS;

my @E2E = qw/pinger owamp bwctl hop/;
my @string_option_keys = qw/password user db host procs past/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help v snmp no_topo anomaly circuits sites_fix/, @E2E
) or pod2usage(1);
my $output_level =  $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(-verbose => 2) 
    if (  $OPTIONS{help} || 
         ($OPTIONS{procs} && $OPTIONS{procs} !~ /^\d{1,2}$/) || 
	 ($OPTIONS{past}  && ($OPTIONS{past}<0 || $OPTIONS{past}>1000)) ||
	 ($OPTIONS{host} && $OPTIONS{host} !~ /^[\w\.-]+$/)
       );

$OPTIONS{host} ||= 'ecenterprod1.fnal.gov';
$MAX_THREADS = $OPTIONS{procs} if $OPTIONS{procs}  && $OPTIONS{procs}  < 40;
# number days back from now for the data ( more than 7 days for anomalies search)
my $PAST_START =  $OPTIONS{past} && (!$OPTIONS{anomaly} || $OPTIONS{past}>7)?$OPTIONS{past}:7;
# snmp data cache request time limit - one day back - epoch
$PAST_START = (time() - $PAST_START*24*3600);

#my $pm  =   new Parallel::ForkManager($MAX_THREADS);
my $pm = '';
$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';
unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter_$OPTIONS{host}`;
    chomp $OPTIONS{password};
}

my $parser = XML::LibXML->new();
our $IP_TOPOLOGY = 'ps.es.net';
my @esnet_hosts = qw/ps1 ps2 ps3/;
my $dbh =  Ecenter::DB->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};", $OPTIONS{user}, $OPTIONS{password}, 
                                    {RaiseError => 1, PrintError => 1});
$dbh->storage->debug(1)  if $OPTIONS{debug} || $OPTIONS{v};
#
#  if asked then collect e2e stats from remote services asynchronously
#
foreach my $e2e (@E2E) {
  if($OPTIONS{$e2e}) {
     get_e2e($pm,  $PAST_START, $e2e);
  }
}
if($OPTIONS{anomaly}) {
     get_anomaly($pm,  $PAST_START);
}
#
# now collect topology and SNMP data from ESnet
# 
foreach my $service ( qw/ps2 ps1/ ) {
    my $ts_instance =  "http://$service.es.net:8012/perfSONAR_PS/services/topology";
    try {
        $logger->debug("\t\t Service at:\t$ts_instance ");
	unless($OPTIONS{no_topo}) {
            my $client = perfSONAR_PS::Client::TopologyOld->new( $ts_instance );
            my $urn = "domain=$IP_TOPOLOGY";
            my ($status, $res) = $client->xQuery("//*[matches(\@id, '$urn', 'xi')]", 'encoded');
            throw  perfSONAR_PS::Error if $status;
	    parse_topo($dbh, $res);
	}
	if($OPTIONS{circuits}) {
            my $client = new perfSONAR_PS::Client::Circuits( { urls => [$ts_instance] });
            my $circuits = $client->get_circuits();
	    get_circuits($dbh, $circuits);
	}
	get_snmp($dbh, $pm) if $OPTIONS{snmp};
	set_end_sites($dbh, $pm) if ($OPTIONS{sites_fix});
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
#$pm->wait_all_children ;
$logger->info("cleanup...");
#$e2e_threads{$_}->join foreach map($e2e_threads{$_}->is_joinable ? $_ : (),   keys %e2e_threads);
pool_control($MAX_THREADS, 1);
$logger->info("cleanup...done");
$dbh->storage->disconnect if $dbh;
exit(0);

=head2 get_circuits

Get circuits, utilization and store them in the DB

=cut

sub get_circuits {
    my ($dbh,  $circuits) = @_;
    my $now_str = strftime('%Y-%m-%d %H:%M:%S', localtime()); 
    my $date_table = strftime('%Y%m', localtime());
    foreach my $circuit_id (keys %{$circuits}){
	$logger->debug("\t[Capacity] " . $circuits->{$circuit_id}->{capacity} . 'Mbps');
	my $circuit = $dbh->resultset('Circuit' . $date_table)->update_or_create({ 
	                                                      circuit =>  $circuits->{$circuit_id}->{name},
							      description =>  $circuits->{$circuit_id}->{description},
							      start_time =>  $circuits->{$circuit_id}->{start},
							      end_time=>  $circuits->{$circuit_id}->{end},
							    });
	foreach my $link(@{$circuits->{$circuit_id}->{links}}){
            $logger->debug("\t[Link] " . $link->{id});
	    my $port_num = 1;
	    my $direction = $link->{id} =~ /atoz/?'forward':'reverse';
            foreach my $port(@{$link->{ports}}){
        	$logger->debug("\t\t[Port] $port");
		my ($hub) = $port =~ m/:node=([^:]+):/;
		my $hub_name = "\L$hub";
		
		my ($l2_port) = $dbh->resultset('L2Port')->search({'hub.hub' => $hub_name}, {join => 'hub', limit => 1});
                unless($l2_port && $l2_port->l2_urn) {
                   $logger->error("NO ports available - check topology info or hub_name:$hub_name");
                   next;
                }
		$dbh->resultset('L2Port')->update_or_create({ 
	                                                      l2_urn => $port,
							      capacity =>  $circuits->{$circuit_id}->{capacity},
							      hub =>  $l2_port->hub->hub,
							      description => '',
							    });
	       $dbh->resultset('CircuitLink' . $date_table)->update_or_create({ 
	                                                      circuit_link => $link->{id},
							      circuit =>  $circuits->{$circuit_id}->{name},
							      l2_urn => $port,
							      link_num =>  $port_num,
							      direction => $direction,
						        });
              $port_num++;
	    }
	}
    }
}

=head2  parse_topo

 parse esnet topology service, translation from PerfsonarTP.java
 first it stores all found nodes and ports and then it links them
 
=cut

sub parse_topo {
    my ($dbh, $xml) = @_;
    $xml->setNamespace("http://ogf.org/schema/network/topology/base/20070828/", "nmtb");
    my %l2_linkage = ();
    my $now_str = strftime('%Y-%m-%d %H:%M:%S', localtime());
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
	    next unless  $urn2 =~ /domain=$IP_TOPOLOGY/;
	    my $capacity = extract( find( $port2, "./nmtl2:capacity", 1), 1);
	    $capacity *= 1000000 if $capacity < 1000000; # mbps
	    my $description2 = extract( find( $port2, "./nmtl2:ifDescription", 1), 1);
	    my $l2_port  = $dbh->resultset('L2Port')->update_or_create({ 
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
			$rem_link_id =~ s/^(.+)\:link\=.+$/$1/;
		     	$l2_linkage{"$urn2,$rem_link_id"}++ 
			    if ($urn2 ne $rem_link_id) && 
			       $rem_link_id =~ /domain=$IP_TOPOLOGY/ && 
			       !(exists $l2_linkage{"$rem_link_id,$urn2"});
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
	    my $net_ip = Net::Netmask->new("$ip_addr:$netmask");
	    $ip_name ||= $ip_addr;
	    $logger->info(" Address: $ip_addr  = $ip_name");
	    update_create_fixed($dbh->resultset('Node'),
		    					      {ip_addr =>  \"=inet6_pton('$ip_addr')"},
		    					      {ip_addr => \"inet6_pton('$ip_addr')",
		    					       nodename => $ip_name,
							       netmask =>   $net_ip->bits,
		    					       ip_noted => $ip_addr});
	    my ($ip_addr_obj) =  $dbh->resultset('Node')->search({ip_noted => $ip_addr});
	    next unless $ip_addr_obj && $ip_addr_obj->ip_addr;
	    $dbh->resultset('L2L3Map')->update_or_create({ ip_addr => $ip_addr_obj->ip_addr,
	                                                   l2_urn => $port2_name,
							   updated =>  $now_str
							  },
							  {key => 'ip_l2_time'});
        }
    }
    foreach my $link_urn (keys %l2_linkage) {
             my ($link_src, $link_dst) = split(',',$link_urn);
	     $dbh->resultset('L2Link')->update_or_create({
	                                                    l2_src_urn => $link_src,
	                                                    l2_dst_urn => $link_dst
							 });
	    $dbh->resultset('L2Link')->update_or_create({ 
	                                                    l2_dst_urn => $link_src,
	                                                    l2_src_urn => $link_dst
							 });
    }
    
}
#
# assign HUB names to the end site nodes
#
sub set_end_sites {
    my ($dbh, $pm ) = @_;
    my $dbi =  db_connect(\%OPTIONS); 
    my $now_time = strftime('%Y-%m-%d %H:%M:%S', localtime());
    my $hub = Ecenter::Data::Hub->new;
    foreach my $hub_name ( $hub->get_hub_blocks ) {
      $hub->hub_name($hub_name);
      my $aliases =   $hub->get_aliases();
      my $alias_sql = " n.nodename like '%$hub_name%'"; 
      if($aliases && @{$aliases}) {
          map { $alias_sql .= " OR  n.nodename like '%$_%'"} @{$aliases};
      }
      my %subnets =  %{$hub->get_ips()};
      my ($l2_port) =   $dbh->resultset('L2Port')->search({'hub.hub_name' => $hub_name}, {join => 'hub', limit => 1});
      unless($l2_port && $l2_port->l2_urn) {
          $logger->error("NO ports available - check topology info or hub_name:$hub_name");
          next;
      }
      $logger->debug(" LT_urn: " . $l2_port->l2_urn);
      foreach my $subnet (keys %subnets) {
         my $sql = qq|select n.ip_noted, n.ip_addr    from   node n    left join l2_l3_map llm using(ip_addr) 
	              where  llm.l2_l3_map is NULL and 
			   ( (inet6_mask(ip_addr,$subnets{$subnet}) =  inet6_mask(inet6_pton('$subnet'), $subnets{$subnet})
			     )  OR  $alias_sql)|;
	 $logger->debug("SQL::: $sql"); 
         my $nodes =  $dbi->selectall_hashref($sql, 'ip_noted');
	 # found all ips for the endsite, lets mark them with made up urns and hub names
	 foreach my $ip (keys %$nodes) {
	    $logger->debug("Checking::: $ip");
	    $dbh->resultset('L2L3Map')->update_or_create({ ip_addr => $nodes->{$ip}{ip_addr},
	                                                   l2_urn => $l2_port->l2_urn,
							   updated =>   $now_time,
							 },
							 { key => 'ip_l2_time'});
	 }
     }
   }
   $logger->debug("Done");
   $dbi->disconnect if $dbi;
   $logger->debug("Back");
}
#
#  get anomalies
#
sub get_anomaly {
    my ($pm, $PAST_START ) = @_;
    my $METRIC = {owamp => [qw/max_delay/], bwctl => [qw/throughput/]};
   
    foreach my $type (qw/owamp bwctl/) {
        my $dbi_a = db_connect(\%OPTIONS); 
	my $metadata = $dbi_a->selectall_hashref(qq| select   md.metaid as metaid, n_src.ip_noted as src_ip,   hb1.hub_name as src_hub, hb2.hub_name as dst_hub,
	                              n_dst.ip_noted  as dst_ip
	                                        	       from 
						        		  metadata md
					        		    join  node n_src on(md.src_ip = n_src.ip_addr) 
								    join  node n_dst on(md.dst_ip = n_dst.ip_addr) 
								    left join l2_l3_map    llm1 on(n_src.ip_addr=llm1.ip_addr) 
     	                                                            left join l2_port      l2p1 on(llm1.l2_urn =l2p1.l2_urn) 
     	                                                            left join hub          hb1  on(hb1.hub =l2p1.hub)
								    left join l2_l3_map    llm2 on(n_dst.ip_addr=llm2.ip_addr) 
     	                                                            left join l2_port      l2p2 on(llm2.l2_urn =l2p2.l2_urn) 
     	                                                            left join hub          hb2  on(hb2.hub =l2p2.hub)
								    join eventtype e on(md.eventtype_id = e.ref_id)
								    join service s  on (e.service = s.service)
							      where   e.service_type = '$type' AND s.is_alive = '1'|, 'metaid');
	 
	 my $date_table = strftime('%Y%m', localtime());
	 foreach my $md (keys %$metadata) {
	     pool_control($MAX_THREADS,undef);
	     threads->new({'context' => 'scalar'},
	                              sub { 
		my $dbh =  Ecenter::DB->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};",  $OPTIONS{user}, $OPTIONS{password},
                                	        { RaiseError => 1, PrintError => 1 } );
        	$dbh->storage->debug(1)  if $OPTIONS{debug} || $OPTIONS{v};
        	my $dbi =  db_connect(\%OPTIONS);
		  
		$logger->debug("SRC/DST =  $metadata->{$md}{src_ip}   $metadata->{$md}{dst_ip}");
		return unless  $metadata->{$md}{src_ip}  &&  $metadata->{$md}{dst_ip} ;					 
		my $data = $dbi->selectall_hashref( "select * from  $type\_data_$date_table   where  metaid='" . 
	                        	            $md  . "' AND  timestamp > $PAST_START", 'timestamp' );
		$dbi->disconnect if $dbi;
		my $swc = $type eq 'bwctl'?21:99;
		my $apd =  Ecenter::ADS::Detector::APD->new({ data_type => $type, algo => 'spd', swc => $swc});
		my $key = "$metadata->{$md}{src_ip}\__$metadata->{$md}{dst_ip}";
		my $data_prepared  = {};
		$data_prepared->{metadata}{$key}{src_hub} =  $metadata->{$md}{src_hub};
		$data_prepared->{metadata}{$key}{dst_hub} =  $metadata->{$md}{dst_hub};
		$data_prepared->{metadata}{$key}{metaid}  =  $md;
	        my $resolution =  100; 
		
		foreach my $name (@{$METRIC->{$type}}) {
	            $data_prepared->{$name} = {$key => []};
		    @{$data_prepared->{$name}{$key}} = sort {$a->[0] <=> $b->[0] } map {[$_, $data->{$_}{$name}]} keys %{$data};
		    next unless @{$data_prepared->{$name}{$key}};
		    #$logger->debug("Parsed data", sub{Dumper($data_prepared)});
		    $apd->start($data_prepared->{$name}{$key}->[0][0]) 
		        if !$apd->start || 
	                    $apd->start > $data_prepared->{$name}{$key}->[0][0];
		    my $timestamps = scalar (keys %$data);
		    my $last_timestamp = $timestamps?$timestamps-1:0;
	            $apd->end($data_prepared->{$name}{$key}->[$last_timestamp][0])
		        if !$apd->end || 
	                    $apd->end > $data_prepared->{$name}{$key}->[$last_timestamp][0];
	      	    $resolution = $type eq 'owamp'?int($timestamps/3):$timestamps;
                } 
		$apd->parsed_data( $data_prepared );
	        eval {
                    $apd->process_data();
                };
                if(!$apd->results || $EVAL_ERROR) {
                    $logger->error("ADS failed for $type md=" .  $md . " - with: $EVAL_ERROR");
		    $dbh->storage->disconnect if $dbh;
		    return;
                } else {
	            eval { 
		        my $anomalies = $apd->results;
                        foreach my  $src_ip (keys %{$anomalies}) {
                            foreach my $dst_ip (keys %{$anomalies->{$src_ip}}) {
	                        next if ref $anomalies->{$src_ip}{$dst_ip}{status} eq ref 'OK' && 
		                $anomalies->{$src_ip}{$dst_ip}{status} eq 'OK';
	                        $logger->info("Creating... " , sub { Dumper($anomalies->{$src_ip}{$dst_ip}) } );
				my $anomaly = $dbh->resultset('Anomaly')->find_or_create({ metaid  =>  $anomalies->{$src_ip}{$dst_ip}{metaid},
		                                                                		   elevation1 =>  $anomalies->{$src_ip}{$dst_ip}{elevation1},
									        		   elevation2 =>  $anomalies->{$src_ip}{$dst_ip}{elevation2},
									        		   swc    =>  $anomalies->{$src_ip}{$dst_ip}{swc},
									        		   algo  => 'spd',
									        		   start_time	=>   $apd->start,
									        		   end_time    =>   $apd->end,
												   resolution =>  $resolution
												   },
									        		   {key => 'metaid_algo_when'});
				foreach my $type (qw/warning critical/) {								
				    foreach my $time (sort {$a <=> $b} keys %{$anomalies->{$src_ip}{$dst_ip}{status}{$type}} ) {
		        		my $anomaly_table = strftime "%Y%m", localtime($time);

		        		$dbh->resultset("AnomalyData$anomaly_table")
			                		  ->find_or_create({anomaly        => $anomaly->anomaly, 
					                		    anomaly_status => $type,
									    anomaly_type   => $anomalies->{$src_ip}{$dst_ip}{status}{$type}{$time}{anomaly_type},
									    timestamp      => $time,
									    value          => $anomalies->{$src_ip}{$dst_ip}{status}{$type}{$time}{value},
									   },
									   { key => 'anomaly_time'} );
				    }
				}
		            }
		        }
		    };
		    if($EVAL_ERROR) {
			$logger->error("DB failed::$EVAL_ERROR");
		    }	
	        }	
		$dbh->storage->disconnect if $dbh;
	    });
	    ##$pm->finish;
	}
	$dbi_a->disconnect if $dbi_a;
    }
    
}
#
#  send async request to get remote data from e2e MAs
#
sub get_e2e {
    my ($pm, $PAST_START, $e2e) = @_;
    my $type = $e2e;
    $type = 'traceroute' if $e2e eq 'hop';
    my $dbi1 =  db_connect(\%OPTIONS);
    my $metadata_hr = $dbi1->selectall_hashref(q|SELECT m.metaid as metaid,   m.subject as subject, s.service as service
                         FROM metadata m 
			 JOIN eventtype e  ON (e.ref_id = m.eventtype_id)
			 JOIN service   s  ON (s.service = e.service)
			 WHERE  e.service_type = | .  $dbi1->quote($type) . q| AND s.is_alive = '1'|, 'metaid');
      	
     my $now_table = strftime('%Y%m', localtime());
     my $table_name = ucfirst($e2e);
     
     my $hosts  =  $dbi1->selectall_hashref('select ip_noted, nodename from node','ip_noted');
     $dbi1->disconnect if $dbi1;
     foreach my $md (keys %{$metadata_hr}) {
         #my $pid = $pm->start and next;
	 ###next unless  $md->eventtype->service->service =~ /bnl|anl/;
	 unless($metadata_hr->{$md}{service}) {
             $logger->error("NO Service for MD::", sub{Dumper($metadata_hr->{$md})});
	     next;
	 }
	 pool_control($MAX_THREADS,undef);
	 threads->new({'context' => 'scalar'},
	                          sub { 
	    my $dbh =  Ecenter::DB->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};",  $OPTIONS{user}, $OPTIONS{password},
                                    {RaiseError => 1, PrintError => 1});
            $dbh->storage->debug(1)  if $OPTIONS{debug} || $OPTIONS{v};
            my $dbi =  db_connect(\%OPTIONS);
	    my $last_time = $dbi->selectall_hashref( "select metaid, timestamp from $e2e\_data_$now_table where metaid='" . 
	                             $md . "' ORDER BY timestamp DESC LIMIT 1", 'metaid');
	    # my $last_time = $dbh->resultset("${table_name}Data$now_table")->search( { metaid => $md->metaid },
	    #						      {   order_by => { -desc => 'timestamp'} }
	    #						    )->single;
	     my $secs_past = ($last_time && $last_time->{$md}{timestamp} && $last_time->{$md}{timestamp} >  $PAST_START)?
	                         $last_time->{$md}{timestamp}:$PAST_START;
    	     my $e2e_data = []; 
	     $dbi->disconnect if $dbi;
	     my $t1 = time();
             my $t_delta = 0; 
	     eval {
		$e2e_data =   Ecenter::Client->new({ type    => $type,  
	                                             url     => $metadata_hr->{$md}{service},
	                                             start   => $secs_past,
    	    			                     end     => $t1,
						     resolution => 10000,
						     args => {
						        subject =>  $metadata_hr->{$md}{subject}
						     }
	    		      })->get_data;
		 $t_delta = time() - $t1;
		 $dbh->resultset('ServicePerformance')->create( { metaid =>   $md,
	                                                     requested_start =>  $secs_past,
	                                                     requested_time => ($t1 - $secs_past), 
	                                                     response => $t_delta, 
							     is_data => (($e2e_data  && @{  $e2e_data })?1:0) 
							     } ); 
	     };
	     if($EVAL_ERROR) {
	       $dbh->resultset('ServicePerformance')->create( { metaid =>  $md,
	                                                     requested_start =>  $secs_past,
	                                                     requested_time => ($t1 - $secs_past), 
	                                                     response => $t_delta, 
							     is_data => 0} ); 
	        $dbh->storage->disconnect if $dbh;
		$logger->error("Data ::Failed - $EVAL_ERROR");
		##$pm->finish;
		return;
	     }
    	     ##$logger->debug("Data :: ", sub{Dumper(  $e2e_data )});
    	     ##$pm->finish unless   $e2e_data  && @{  $e2e_data };
	     unless($e2e_data  && @{  $e2e_data }) { 
	        $logger->error(" No Data for $type: start=$secs_past " . $metadata_hr->{$md}{service}  . ' md=' . $metadata_hr->{$md}{subject} );
	        $dbh->storage->disconnect if $dbh;
		return;
	     }
    	     foreach my $data (@{ $e2e_data }) {
	         if($type eq 'traceroute' ) {
		     my  $ip_noted  =  $data->[1]->{ip_noted};
		     delete $data->[1]->{ip_noted};
		     my $nodename = '';
		     unless(exists $hosts->{$ip_noted}) {
		        ($ip_noted, $nodename) =   get_ip_name( $ip_noted );
			$hosts->{$ip_noted}{nodename} = $nodename if $nodename && $nodename =~ /^[a-z]+/;
		     }
		     ##$logger->info("Data[1]:: ", sub{Dumper( $data->[1] )});
		     $nodename = $hosts->{$ip_noted} && $hosts->{$ip_noted}{nodename}?$hosts->{$ip_noted}{nodename}:$ip_noted;
		     $dbh->resultset('Node')->find_or_create(
    		         		   {ip_addr =>   $data->[1]->{hop_ip},
    		      	 		    nodename =>  $nodename,
    		      	 		    ip_noted =>  $ip_noted});
					    
		 }
		 eval {
    		     $dbh->resultset("${table_name}Data$now_table")->update_or_create({ metaid =>  $md,
    	    									   timestamp => $data->[0],
    	    									   %{$data->[1]},
    	    									},
    	    									{ key => 'meta_time'});
		};
		if($EVAL_ERROR) {
		   $logger->error("$EVAL_ERROR  -- n\ Failed Data[1]:: ", sub{Dumper( $data->[1] )});
		}
    	    } 
	    $dbh->storage->disconnect if $dbh;
	});
	##$pm->finish;
    }
  
}
#
#   get SNMP data from ESnet SNMP 
#
sub get_snmp { 
    my ($dbh, $pm ) = @_;
    my $SERVICE_ES = 'ps6';
    my ($service) = $dbh->resultset('Service')->search({'eventtypes.service_type' => 'snmp', 
                                                      'me.service' => {like => "\%$SERVICE_ES.es.net\%"}}, 
                                                     { 'join' => 'eventtypes',
						       '+select' => ['eventtypes.ref_id'],
						     
						      }
						    );
    my $now_table = strftime('%Y%m', localtime());
    # harcoded fix for miserable  ESnet service
    my $eventtype_obj; 
    unless($service) {
        my $ps3_node =   $dbh->resultset('Node')->find({nodename => "$SERVICE_ES.es.net"});
        my $service_obj = $dbh->resultset('Service')->update_or_create({ name => 'ESnet SNMP MA',
	                                				 ip_addr  => $ps3_node->ip_addr, 
									 comments => 'ESnet SNMP MA',
									 is_alive => 1,
									 updated  => \"NOW()",
									 service  => "http://$SERVICE_ES.es.net:8080/perfSONAR_PS/services/snmpMA"});
	$eventtype_obj = $dbh->resultset('Eventtype')->update_or_create( { eventtype =>  'http://ggf.org/ns/nmwg/tools/snmp/2.0',
								           service =>  $service_obj->service,
								           service_type =>  'snmp',
								         },
								         { key => 'eventtype_service_type' }
							      );				    
	$service = $dbh->resultset('Service')->find({ 'eventtypes.service_type' => 'snmp', 
	                                                'me.service' => {like => "\%$SERVICE_ES.es.net\%"}}, 
                                                       {join => 'eventtypes', '+select' => ['eventtypes.ref_id'] } );
    }
    my $eventtype_id =  $service->eventtypes->first->ref_id;
    my @ports = $dbh->resultset('L2Port')->search({ }, { 'join'  =>  'l2_link_l2_src_urns' });
    # get SNMP MA handler
    ###my $snmp_ma =  Ecenter::Data::Snmp->new({ url => $service->service});
    
    #$logger->info("=====---- SERVICE eventtype ---------", sub{Dumper($service->eventtypes)});
    unless(@ports) {
    	$logger->error(" !!! NO Ports !!! ");
    	return;
    }
    my $num_ports = @ports;
    $logger->info("PORTS::" . @ports);
    my $counter = 1;
    my %addressess = ();
    foreach my  $port (@ports) {
        $logger->info(sprintf("Progressed ... %5.2f %% out of %d", ($counter/$num_ports)*100., $num_ports));
    	my @ifAddresses = $dbh->resultset('L2L3Map')->search( { l2_urn => $port->l2_urn }, 
    							      { 'join' => 'ip_addr', '+select' => ['ip_addr.ip_noted'] }
    							    );
    	unless (@ifAddresses) {
    	    $logger->error(" !!! NO Addresses !!! ");
    	    next;
    	}
	foreach my  $l3 (@ifAddresses) {
	    $addressess{$l3->ip_addr->ip_noted}{port} = $port;
	    $addressess{$l3->ip_addr->ip_noted}{l3} =  $l3;
	}
	$counter++;
   }
   foreach my $addr (keys %addressess) {
            my $l3 = $addressess{$addr}{l3};
	    my $port = $addressess{$addr}{port};
	    
	    $logger->debug("=====---------------===== \n ifAddress:: $addr URN:" . $port->l2_urn );
	
    	    ### my $pid = $pm->start and next;
	    pool_control($MAX_THREADS, undef);
	    my $src_ip = $l3->ip_addr->ip_addr;
	    threads->new({'context' => 'scalar'}, 
	                          sub { 
		# get last timestamp
		 my $dbh =  Ecenter::DB->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};",  $OPTIONS{user}, $OPTIONS{password}, 
                                	    {RaiseError => 1, PrintError => 1});
        	$dbh->storage->debug(1)  if $OPTIONS{debug}|| $OPTIONS{v};
		my $snmp_ma =  Ecenter::Data::Snmp->new({ url => $service->service});
   
		my ($last_time) = $dbh->resultset("SnmpData$now_table")->search( {  
	                                                	 'metaid.eventtype_id' => $eventtype_id,
    	    							 'metaid.src_ip'       =>  $src_ip,
    	    							 'metaid.dst_ip'       => '0'
	    						      },
	    						      { 'join' => 'metaid', limit => 1,  order_by => { -desc => 'timestamp'} }
	    						    );

        	my $secs_past = $last_time && ($last_time->timestamp >  $PAST_START)?$last_time->timestamp:$PAST_START;
		my $t1 = time();
                my $t_delta = 0; 
    		$snmp_ma->get_data({ direction => 'out',
    	    			     ifAddress => $addr, 
    	    			     start     => DateTime->from_epoch( epoch =>  $secs_past),
    	    			     end       => DateTime->now()	
	    			  });
    		$logger->debug("Data :: ", sub{Dumper( $snmp_ma->data)});
		
    		my $meta = $dbh->resultset('Metadata')->update_or_create({ 
    	    						 eventtype_id => $eventtype_id ,
    	    						 src_ip	  => $src_ip,
    	    						 dst_ip => '0',
							 l2_urn => $port->l2_urn,
    	    					      },
	    					      {key => 'md_ips_type'}
    	    					      );
    		if($snmp_ma->data && @{$snmp_ma->data}) {
		    $dbh->resultset('ServicePerformance')->create( { metaid =>  $meta->metaid,
	                                                     requested_start =>   $secs_past ,
	                                                     requested_time => ($t1 - $secs_past), 
	                                                     response => $t_delta, 
							     is_data => 1 
							     } ); 
    		    foreach my $data (@{ $snmp_ma->data}) { 
    	    	       eval {
		       
		        my ($got_snmp) = $dbh->resultset("SnmpData$now_table")->search({ metaid =>  $meta->metaid,
    	    								                 timestamp => $data->[0]  },
										      { limit => 1} );
		         $dbh->resultset("SnmpData$now_table")->create({ metaid =>  $meta->metaid,
    	    								        timestamp => $data->[0],
    	    								        utilization => $data->[1],
										errors => $data->[2],
										drops => $data->[3]
    	    								     },
    	    								     { key => 'meta_time'}) unless $got_snmp;
		      };
		      if($EVAL_ERROR) {
		         $logger->error($meta->metaid . " metaid failed due some error $EVAL_ERROR skipping ...  ");
		      }
    		    }
		} else {
		   $dbh->resultset('ServicePerformance')->create( { metaid =>  $meta->metaid,
	                                                     requested_start =>   $secs_past ,
	                                                     requested_time => ($t1 - $secs_past), 
	                                                     response => $t_delta, 
							     is_data => 0 
							     } ); 
		}
		$dbh->storage->disconnect if $dbh;
		return;
	    });
    	    #$pm->finish;
    }
}
__END__

 =head1 SEE ALSO

L<XML::LibXML>, L<Carp>, L<Getopt::Long>, L<Data::Dumper>,
L<Data::Validate::IP>, L<Data::Validate::Domain>, L<Net::IPv6Addr>,
L<Net::CIDR>, <DBIx::Class>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id:$

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov 

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010-2011, Fermitools

All rights reserved.

=cut
