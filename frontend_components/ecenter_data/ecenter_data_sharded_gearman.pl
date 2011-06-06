#!/usr/local/bin/perl -w

use Dancer;
use Dancer::Plugin::REST;
our $VERSION = '';  
use English;
use Data::Dumper;
use lib "/home/netadmin/ecenter_git/ecenter/frontend_components/ecenter_data/lib";
use DateTime;
use DateTime::Format::MySQL;
use Ecenter::Exception;
use Ecenter::DB;
use Ecenter::Utils;
use Ecenter::ADS::Detector::APD;

 # for simple SQL stuff

use Dancer::Plugin::DBIC qw(schema);
use POSIX qw(strftime);
use Params::Validate qw(:all);
# for complex SQL stuff
use Dancer::Plugin::Database;
use Dancer::Logger;

use Log::Log4perl qw(:easy); 

use Gearman::Client;
use NetAddr::IP::Util qw(inet_n2ad ipv6_n2x isIPv4);
use JSON::XS qw(encode_json decode_json);


my $DAYS7_SECS = 604800;
my $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
my $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;
my @HEALTH_NAMES = qw/nasa.gov pnl.gov llnl.gov   pppl.gov anl.gov lbl.gov bnl.gov dmz.net nersc.gov jgi.doe.gov snll.gov ornl.gov slac.stanford.edu es.net/;
my $TABLEMAP = { bwctl      => {table => 'BwctlData',  class => 'Bwctl',      data => [qw/throughput/]},
   		 owamp      => {table => 'OwampData',  class => 'Owamp',      data => [qw/sent loss min_delay max_delay duplicates/]},
    		 pinger     => {table => 'PingerData', class => 'PingER',     data => [qw/meanRtt maxRtt medianRtt maxIpd meanIpd minIpd minRtt iqrIpd lossPercent/]},
		 traceroute => {table => 'HopData',    class => 'Traceroute', data => [qw/hop_ip	hop_num  hop_delay/]},
    	       };
#set serializer => 'JSON';
#set content_type =>  'application/json';
prepare_serializer_for_format;

my $output_level = config->{debug} && config->{debug}> 0 ?$DEBUG:$INFO;
#my $output_level =  $INFO;
my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
our  $logger = Log::Log4perl->get_logger(__PACKAGE__);
 
=head1 NAME

   ecenter_data.pl - standalone RESTfull service, provides interface for the Ecenter data and dispatch

=cut
##  ADS service, too much data, need to POST

any ['post'] =>  "/ads/algo.:format" => 
       sub {
	       return  detect_anomaly(algo => params->{algo}, params('query'));
       };

##  status URL
any ['get'] =>  "/status.:format" => 
       sub {
 	       return  { status => 'ok' }
       };
# health service
any ['get'] =>  "/health.:format" => 
       sub {
 	      return get_health(params('query'));
       };

## get all hubs for src_ip/dst_ip
any ['get'] =>  "/source.:format" => 
       sub {
 	       return process_source();
       };
### get destination IPs for the source IP ( based on avail traceroutes)
any ['get'] =>  "/destination/:ip.:format" => 
       sub {
 	       return process_source(src_ip => params->{ip});
       };
       
## get all hubs for src_hub
any ['get'] =>  "/hubs/:src_hub.:format" => 
       sub {
 	       return   process_source(src_hub => params->{src_hub});
       };
## get all hubs  
any ['get'] =>  "/hub.:format" => 
       sub {
 	       return   database('ecenter')->selectall_hashref( qq|select distinct hub_name, longitude, latitude from  hub|, 'hub_name');
       };
 ## get all hubs for src_ip/dst_ip
any ['get'] =>  "/node/:ip.:format" => 
       sub {
 	      return process_source(node_ip => params->{ip});
       };  
#########   get services(all of them -------------------------------------
 
any ['get', 'post'] =>  "/service.:format" => 
       sub {
 	       return process_service();
       };

#########   get service --------------------------------------------------
{
    my %map2sql = ( id => 'service', 
                    ip => 'node.ip_noted',
                    url => 'service', 
		    name => 'name',
	          );
    foreach my $route (keys %map2sql) {    
        any ['get', 'post'] =>  "/service/$route/:$route.:format" => 
            sub {
                return process_service( value => params->{$route}, mapping =>  $map2sql{$route});

        };
    }
}
#########   get data - only one type ----------------------------------------------------------
any ['get', 'post'] =>  '/data/:data.:format' => 
    sub {
        my $data = {};
        eval {
	   $data = process_data( data => params->{data}, params('query'));
	};
	if(my $e = Exception::Class->caught()) {
	    send_error("Failed with " . $e->trace->as_string);
	}
	return $data;
    };

#########   get data - all ----------------------------------------------------------
any ['get', 'post'] =>  '/data.:format' => 
    sub {
        my $data = {};
        eval {
	   $data = process_data( params('query'));
	};
	if(my $e = Exception::Class->caught()) {
	    send_error("Failed with " . $e->trace->as_string);
	}
	return $data;
    };
#
#   deal with dates
#
sub _params_to_date {
     my %params = validate(@_, { start  => {type => SCALAR, regex => $REG_DATE, optional =>  1},
		                 end    => {type => SCALAR, regex => $REG_DATE, optional =>  1},
			    }
	       );
    $params{end}  =  $params{end}?DateTime::Format::MySQL->parse_datetime( $params{end} )->epoch:time();
    $params{start}  = $params{start}?DateTime::Format::MySQL->parse_datetime($params{start})->epoch:$params{end} - 12*3600;
    map { $params{$_}{end} =  $params{end};   
          $params{$_}{start} =  $params{start}
	} 
    qw/owamp pinger snmp bwctl traceroute/;
	      
    if(  ($params{end}-$params{start}) <   $DAYS7_SECS) {
	    my $median = $params{start} + int(($params{end}-$params{start})/2);
	    $params{bwctl}{start} = $median -  $DAYS7_SECS; # 7 days
	    $params{bwctl}{end}   = $median +  $DAYS7_SECS; #  7 days
    }
    return \%params;
}

#
# return hash with anomalies found
#
#

sub detect_anomaly {
    my %req_params =  validate(@_, { algo => {type => SCALAR, regex => qr/^apd|spd$/i},
                                     data => {type => SCALAR},
				     data_type   => {type => SCALAR, regex => qr/^owamp|bwctl|pinger$/i},
				     sensitivity => {type => SCALAR, regex => qr/^\d+$/i,     default => 2, optional => 1},
				     elevation1  => {type => SCALAR, regex => qr/^[\.\d]+$/i, default => .2, optional => 1},
				     elevation2  => {type => SCALAR, regex => qr/^[\.\d]+$/i, default => .4, optional => 1},
				     swc         => {type => SCALAR, regex => qr/^\d+$/i,     default => 20, optional => 1},
				   });
    my $data_request = decode_json $req_params{data};
    delete $req_params{data};
    unless($data_request && ref $data_request eq ref {} && %{$data_request}) {
        return error "Data is not supplied or malformatted";
    }
    my $algo = "\U$req_params{algo}";
    delete $req_params{algo};
    my $ads = ("Ecenter::ADS::Detector::$algo")->new({ data => $data_request, %req_params });
    my $results = {};
    eval {
        $results = $ads->process_data();
    };
    if(!$results || $EVAL_ERROR) {
       error "ADS failed with: $EVAL_ERROR";
    }
    return $results;
}
#
# return hash with error string for each non-healthy part of the data service
#
#

sub get_health {
    my %req_params =  validate(@_, { start   => {type => SCALAR, regex => $REG_DATE, optional => 1},
    	                             end     => {type => SCALAR, regex => $REG_DATE, optional => 1}, 
				     src_hub => {type => SCALAR, regex => qr/^\w+$/i,optional => 1},
				     data    => {type => SCALAR, regex => qr/^(snmp|traceroute|bwctl|owamp|pinger)$/i, optional => 1}, 
				  });
    debug Dumper(@_);
    my $params  =  {};
    $params->{end}  =  $req_params{end}?DateTime::Format::MySQL->parse_datetime( $req_params{end} )->epoch:time();
    $params->{start}  = $req_params{start}?DateTime::Format::MySQL->parse_datetime($req_params{start})->epoch:$params->{end} - 24*3600;
    my @services = ();
    my %health = (); 
    $health{start} =   $params->{start};
    $health{end} =   $params->{end};
    my $hub_sql =  ' AND 1';
    if( $req_params{src_hub} ) { 
        $hub_sql =  ' AND h.hub_name =' . database('ecenter')->quote($req_params{src_hub});
        my $hub_check = database('ecenter')->selectall_hashref(qq|select distinct h.hub_name from  hub h where  $hub_sql|);
        return { error => "\usrc_hub -  $req_params{src_hub} is invalid" } 
            if $hub_check &&  ref $hub_check  eq ref {};
    }
    my $hubs =  database('ecenter')->selectall_hashref( qq|select distinct hub_name from  hub where 1 $hub_sql |, 'hub_name');
    foreach my $site  ( sort  keys %{$hubs} ) {
        next if $req_params{hub} && $req_params{hub} ne $site;
	$hub_sql =  ' AND hub_name =' . database('ecenter')->quote($site);
	foreach my $type (qw/snmp bwctl pinger owamp traceroute/) {
	    next if $req_params{data} && $type ne $req_params{data};
	    my $e2e_sql = qq|select  distinct m.metaid  from metadata m
    								join node n_src on(m.src_ip = n_src.ip_addr)	    
    								join l2_l3_map llm on(n_src.ip_addr = llm.ip_addr) 
								join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
								join hub h using(hub) 
    								join eventtype e on(m.eventtype_id = e.ref_id)
    								join service s  on (e.service = s.service)
    							  where  
    								1  $hub_sql  and 
    								e.service_type  = '$type' and
    								s.service  like 'http%' |;
    	    #debug " E2E SQL::  $site";
    	    my @mds=  @{database('ecenter')->selectall_arrayref($e2e_sql)}; 
    	    ##debug " MDS::" . Dumper \@mds;
    	    $health{metadata}{$site}{$type}{metadata_count} = scalar @mds;
    	    if(@mds) {
    		my $md_ins = join("','", map {$_->[0]} @mds);
    		my $table = $type eq 'traceroute'?'hop':$type;
    		my $shards = _get_shards({data => $table, start => $params->{start},end => $params->{end}});
    		foreach my $shard (sort  { $a <=> $b } keys %$shards) {
    		   my $sql = qq|select count(*) from  $shards->{$shard}{table}{dbi}  
    				 where metaid in  ('$md_ins') and  timestamp >=  $shards->{$shard}{start} and  timestamp <= $shards->{$shard}{end} |;
    		   debug "Data::sql::$sql";
    		   $health{metadata}{$site}{$type}{$shard}{cached_data_count} = database('ecenter')->selectrow_array($sql);
    		}
    	    }

	}
    }
    # debug Dumper(\@services);
    return \%health;
}

#
# return list of destinations for the source ip or just list of source ips, or even detailes of some IP
#
sub process_source {
    my %params = validate(@_, {node_ip => {type => SCALAR, regex => $REG_IP, optional => 1},  
                               src_hub => {type => SCALAR, regex =>   qr/^\w+$/i, optional => 1},
                               src_ip => {type => SCALAR, regex => $REG_IP, optional => 1},
			      }); 
    my @hubs =(); 
    my $hash_ref;
    if( %params) {
        if($params{src_ip}) {
            $hash_ref =  database('ecenter')->selectall_hashref(
               qq|select distinct n.ip_noted, n.netmask, n.nodename, h.hub_name, h.hub, h.longitude, h.latitude  from
     	              metadata m 
		 join eventtype e on(e.ref_id=m.eventtype_id)
     		 join node n on(m.dst_ip = n.ip_addr)
            join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
            join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
            join hub h using(hub) 
     	    where m.dst_ip is not NULL  and e.service_type = 'traceroute' and m.src_ip = inet6_pton('$params{src_ip}')|, 'ip_noted');
        } elsif($params{node_ip}) {
            return database('ecenter')->selectrow_hashref(
               qq|select distinct n.ip_noted, n.netmask, n.nodename, h.hub_name, h.hub, h.longitude, h.latitude  from
     	             node n
            join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
            join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
            join hub h using(hub) 
     	    where n.ip_noted = '$params{node_ip}'|);
	} elsif($params{src_hub}) {
	   $hash_ref =  database('ecenter')->selectall_hashref(
               qq|select distinct n.ip_noted, n.netmask, n.nodename, h.hub_name, h.hub, h.longitude, h.latitude  from
     	              metadata m 
		 join eventtype e on(e.ref_id=m.eventtype_id)
     		 join node n on(m.dst_ip = n.ip_addr)
            join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
            join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
            join hub h on(h.hub = l2p.hub)
	    join node n_src on(m.src_ip = n_src.ip_addr)
            join l2_l3_map llm_src on(n_src.ip_addr = llm_src.ip_addr) 
            join l2_port l2p_src on(llm_src.l2_urn =l2p_src.l2_urn) 
            join hub h_src on(h_src.hub = l2p_src.hub)
     	    where m.dst_ip is not NULL  and e.service_type = 'traceroute' and h_src.hub_name = | . 
	    database('ecenter')->quote($params{src_hub}) . 'GROUP by hub_name', 'ip_noted');
	}
    } else {
        $hash_ref =  database('ecenter')->selectall_hashref(
	      qq| select  n.ip_noted, n.netmask,  n.nodename,  h.hub_name, h.hub, h.longitude, h.latitude   from 
    		       metadata m  
		       join eventtype e on(e.ref_id=m.eventtype_id) 
                       join node n on(m.src_ip = n.ip_addr)  
		       join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
                       join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
                       join hub h using(hub) 
		   where e.service_type = 'traceroute'|, 'ip_noted');
    }
    foreach my $ip (keys %$hash_ref) {
    	push @hubs, $hash_ref->{$ip};
    }
    #debug Dumper(\@hubs);
    return \@hubs;
}
#
# return list of services 
#
sub process_service {
    my %params = validate(@_, {value =>  {type => SCALAR, optional => 1}, mapping =>  {type => SCALAR, optional => 1}});
 
    
    my @services = ();
    my %search = ();
    $search{ $params{mapping} } =  $params{value}  if( %params && $params{value});
    my @rows =   schema('dbix')->resultset('Service')->search( { %search },
		                                     { join => [('node','eventtypes')],
						       '+columns' => [('node.ip_noted','eventtypes.service_type')]
						     }
						   );
    foreach my $row (@rows) {
     	my %row_h = $row->get_columns;
    	delete $row_h{ip_addr};
    	push @services, \%row_h;
    }
    # debug Dumper(\@services);
    return \@services;
}
#
#   get  end to end traceroute data and reverse and then associated data - per hop (utilization) and end to end
#  if data is not in the db then get it from remote site
#
sub process_data {
   my $data = {};
   my $task_set;
   my %params = ();
   eval {
     %params = validate(@_, { data_type  => {type => SCALAR, regex => qr/^(snmp|bwctl|owamp|pinger|traceroute)$/i, optional => 1}, 
                              id	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1}, 
                              src_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
			      src_hub	 => {type => SCALAR, regex => qr/^\w+$/i,   optional => 1}, 
                              dst_hub	 => {type => SCALAR, regex => qr/^\w+$/i,    optional => 1}, 
                              dst_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		              start	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
		              end	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      timeout	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			   }
		 );
    # debug Dumper(\%params );
    ### query allowed  as:?src_ip=131.225.1.1&dst_ip=212.4.4.4&start=2010-05-02%20:01:02&end=2010-05-02%20:01:02
    
    ### where dst_ip is optional and it will return only data for the metadata where src_ip is defined and not dst_ip
    ##  i.e. utilization data for the IP(interface)
    # 
    #  when id is provided then it superseeds src_ip and dst_ip, id means metadata id
    if($params{resolution}) {
        $params{resolution} =  $params{resolution} > 0 && $params{resolution} <= 1000?$params{resolution}:1000;
    } else {
        $params{resolution} = 20;
    } 
    if($params{timeout}) {
        $params{timeout} =  $params{timeout} > 0 && $params{timeout} <= 1000?$params{timeout}:1000;
    } else {
        $params{timeout} = 120;
    }
    #   get epoch or set end default to NOW and start to end-12 hours
   
    my $date_params  =  _params_to_date({start => $params{start},end => $params{end}});
    map { $params{$_} = $date_params->{$_} } keys %{$date_params};
    my $trace_cond = {};
    
    if($params{src_ip}) {
        $trace_cond->{direct_traceroute}{src}  = qq|  md.src_ip =  inet6_pton('$params{src_ip}')|;
        $trace_cond->{reverse_traceroute}{src} = qq|  md.dst_ip  =  inet6_pton('$params{src_ip}') |;
    } 
    if ($params{src_hub}) {
        $trace_cond->{direct_traceroute}{src}  = qq| hb1.hub =   '$params{src_hub}'  |;
        $trace_cond->{reverse_traceroute}{src} = qq| hb2.hub =   '$params{src_hub}'  |;
    }
    if($params{dst_ip}) {
        $trace_cond->{direct_traceroute}{dst}   =   qq|  md.dst_ip =  inet6_pton('$params{dst_ip}') |;
        $trace_cond->{reverse_traceroute}{dst}  =   qq|  md.src_ip =  inet6_pton('$params{dst_ip}')  |; 
    } 
    if ($params{dst_hub}) {
        $trace_cond->{direct_traceroute}{dst}   = qq|   hb2.hub =   '$params{dst_hub}' |;
        $trace_cond->{reverse_traceroute}{dst}  = qq|   hb1.hub =   '$params{dst_hub}'  |;
    }
    ################ starting the client
    #
    #
    my $g_client = new Gearman::Client;
    my @servers = ();
    foreach my $host ( %{config->{gearman}{servers}}) {
        push @servers, (map { $host . ":$_"} @{config->{gearman}{servers}{$host}});
    }
    unless($g_client->job_servers( @servers ) ) {
         error "Failed to add Gearman  servera ";
	 GearmanServerException->throw(" Failed to add Gearman  servers  ");
    }
    #
#
    # my $dst_cond = $params{dst_ip}?"inet6_mask(md.dst_ip, 24)= inet6_mask(inet6_pton('$params{dst_ip}'), 24)":"md.dst_ip = '0'";
    ##
    ## get direct and reverse traceroutes
    ## 
    # my $trace_cond = qq|  inet6_mask(md.src_ip, 24) = inet6_mask(inet6_pton('$params{src_ip}'), 24) and $dst_cond |;
    $params{table_map} = $TABLEMAP;
    my $traceroute = {};
    foreach my $way (qw/direct_traceroute reverse_traceroute/) {
        $traceroute->{$way}  = get_traceroute($g_client, $trace_cond->{$way}, \%params);
	 
        $data->{$way} = $traceroute->{$way}{hops} 
                              if($traceroute->{$way} && $traceroute->{$way}{hops} && 
			         ref $traceroute->{$way}{hops} &&  %{$traceroute->{$way}{hops}}); 
    }
    
    ### snmp data for each hop - all unique hop IPs
    my %allhops = (%{$traceroute->{direct_traceroute}{hop_ips}}, %{$traceroute->{reverse_traceroute}{hop_ips}});
    $data->{traceroute_nodes} = \%allhops;
    debug "HOPS:::" . Dumper(\%allhops);
    return $data unless $traceroute->{direct_traceroute}{hop_ips} || $traceroute->{reverse_traceroute}{hop_ips};
    $task_set = $g_client->new_task_set; 
    $data->{snmp} = {};
    if(!$params{data_type} || $params{data_type} =~ /^snmp$/i) {
        eval {
	    get_snmp($task_set, $data->{snmp}, \%allhops, \%params);
        }; 
        if($EVAL_ERROR) {
	    error "  No SNMP data - failed $EVAL_ERROR";
        }
    }
     #return $data;
    # end to end data  stats if available
    ### return $data unless $params{src_ip} && $params{dst_ip};
    my %directions = (direct => ['src_ip', 'dst_ip'], reverse => ['dst_ip', 'src_ip'] );
    
    my @data_keys = ();
    if($params{data_type}) {
        @data_keys = ($params{data_type}) if  $params{data_type} =~ /^bwctl|owamp|pinger$/i;
    } else {
        @data_keys =  qw/bwctl owamp pinger/;
    }
    # my @data_keys = qw/owamp/;
    my %e2e_mds = ();
    map {$data->{$_} = {}} @data_keys;
    
    
    foreach my $dir (keys %directions) {
	my $e2e_sql = qq|select   md.metaid, n_src.ip_noted as src_ip, md.subject, e.service_type as type, hb1.hub as src_hub, hb2.hub as dst_hub,
	                          n_dst.ip_noted  as dst_ip, 
                                                              n_src.nodename as src_name, n_dst.nodename as dst_name, s.service
	                                        	   from 
						        	      metadata md
					        		join  node n_src on(md.src_ip = n_src.ip_addr) 
								join  node n_dst on(md.dst_ip = n_dst.ip_addr) 
								join l2_l3_map    llm1 on( n_src.ip_addr=llm1.ip_addr) 
     	                                                        join l2_port      l2p1 on(llm1.l2_urn =l2p1.l2_urn) 
     	                                                        join hub         hb1  on(hb1.hub =l2p1.l2_urn)
								join l2_l3_map    llm2 on( n_dst.ip_addr=llm2.ip_addr) 
     	                                                        join l2_port      l2p2 on(llm2.l2_urn =l2p2.l2_urn) 
     	                                                        join hub         hb2  on(hb2.hub =l2p2.l2_urn)
								join eventtype e on(md.eventtype_id = e.ref_id)
								join service s  on (e.service = s.service)
							  where  
								$trace_cond->{"$dir\_traceroute"}{src} and $trace_cond->{"$dir\_traceroute"}{dst} and 
								e.service_type in ('pinger','bwctl','owamp') and
								s.service  like 'http%'
					             group by src_ip, dst_ip, service, type|;
	debug " E2E SQL:: $e2e_sql";
	my $md_href =  database('ecenter')->selectall_hashref($e2e_sql, 'metaid');   
	#debug " MD for the E2E ::: " . Dumper $md_href;	
       
	unless($md_href && %{$md_href}) {
	   $logger->error("No metadata for e2e on $dir ....");
	   next;
	}
        %e2e_mds = (%e2e_mds, %{$md_href});

	foreach my $e_type (@data_keys)  {
	    debug " ...  Running  ------------  $e_type";
	    get_e2e($task_set, $data->{$e_type}, \%params, $md_href, $e_type );
	    debug " +++++ Done  $dir ------------  $e_type";
	}
     }
  };
  if($EVAL_ERROR) {
      error "data call  failed - $EVAL_ERROR";
      GeneralException->throw(error => $EVAL_ERROR ); 
  }
  $task_set->wait(timeout => $params{timeout});
  foreach my $ip_noted (keys %{$data->{snmp}}) { 
        my @result =(); 
        foreach my $time  (sort {$a<=>$b} grep {$_} keys %{$data->{snmp}{$ip_noted}}) { 
	    push @result,[ $time,  { capacity =>  $data->{snmp}{$ip_noted}{$time}{capacity},  
		                     utilization => $data->{snmp}{$ip_noted}{$time}{utilization},
				     errors => $data->{snmp}{$ip_noted}{$time}{errors},
				     drops => $data->{snmp}{$ip_noted}{$time}{drops},
		   	           }
		         ];
        }
        ### debug "Data for ip=$hop_ip hop_id=$hops_ref->{$hop_ip}:: " . Dumper( $snmp{$hops_ref->{$hop_ip}});
       $data->{snmp}{$ip_noted} = refactor_result(\@result, 'snmp', $params{resolution});
	 ##$data->{snmp}{$ip_noted} = \@result;
  }
  return $data; 
}
 

#
#  get bwctl/owamp/pinger data for end2end, first for the src_ip, then for the dst_ip
#
sub get_e2e{
    my ($task_set,  $data_hr,  $params,   $md_href, $type) = @_; 
    my %result = ();
    ### my $task_set = $g_client->new_task_set;
    my $FAILED = 0;
    my $time_slice = ($type =~ /pinger|owamp/)?config->{time_slice_secs}:($params->{$type}{end} - $params->{$type}{start});
    foreach my $metaid  ( keys %{$md_href} ) {
        my  $md_row =  $md_href->{$metaid}; 
	debug " ------  $type md  $metaid  :::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} "; 
        next if $md_row->{type} ne $type || !$metaid;
        $logger->info(" ------ FOUND METADATA:: $type md =$metaid  :::" .
	              " SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} start=$params->{$type}{start} " .
		      " end=$params->{$type}{end} slice=$time_slice");
	$data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}} = {};
	for(my $st_time = $params->{$type}{start}; $st_time < $params->{$type}{end}; $st_time +=  $time_slice) {
	    my $data_table = strftime "%Y%m", localtime($st_time);
	    my $st_end_i = $st_time +  $time_slice;   
	    my $end_time = ($params->{$type}{end} && $params->{$type}{end}<$st_end_i)?$params->{$type}{end}:$st_end_i;
	    $logger->info(" ------ MD=$metaid  start= $st_time -  $end_time slice = $time_slice  table=$params->{table_map}{$type}{table}$data_table");
	    my $ret =  $task_set->add_task("dispatch_data" =>
	                                      encode_json {metaid => $metaid, 
					        	   table =>  "$params->{table_map}{$type}{table}$data_table",
							   md_row => $md_row,
                                                	   start  => $st_time,
							   type => $type,
							   resolution => $params->{resolution},
					     	 	   end    =>  $end_time
					     	 	  },
					  {
					   on_fail     => sub {$FAILED++;
					                      $logger->error("FAILED: $metaid $params->{table_map}{$type}{table}$data_table ".
					                                                " start= $st_time -  $st_end_i");},
					   on_complete => sub { 
					                     my $returned = decode_json  ${$_[0]};  
							     if($returned->{status} eq 'ok' && $returned->{data} && ref $returned->{data} eq ref []) {
                                                                 foreach my $datum ( @{$returned->{data}} ) {
							             unless($datum && ref $datum eq ref []) {
								         $logger->error("FAILED: datum malformed", sub{Dumper($datum)});
									 next;
								     }
								     $datum->[1]->{src_hub} = $md_href->{src_hub};
								     $datum->[1]->{dst_hub} = $md_href->{dst_hub};
								     
				                                     $data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}}{$datum->[0]} = $datum->[1];
								 }
								 $logger->debug("DATA for $type: md=$metaid times=$st_time - $end_time :::" . scalar(@{$returned->{data}}));
			    	                                 
							     } else {
							         $logger->info("NO DATA for $type: md=$metaid times=$st_time - $end_time :::", Dumper($returned)); 
							     }
							      
						          },
					   }
	     );
	 }
    }
    return;
}
 
#
#     get traceroute md ids   from the db
# 
sub  get_traceroute_mds {
    my ($trace_cond) = @_;
    my  $cmd =   qq|select  distinct md.metaid as metaid, md.src_ip, md.dst_ip, md.subject, hb1.hub as src_hub, hb2.hub as dst_hub,
                             s.service  from 
	                                                    metadata md 
	                                               join eventtype e on(md.eventtype_id = e.ref_id)  
						       join node n_src  on(md.src_ip = n_src.ip_addr)
						       join node n_dst  on(md.dst_ip = n_dst.ip_addr) 
						       join l2_l3_map	llm1 on( n_src.ip_addr=llm1.ip_addr) 
     	                                               join l2_port	l2p1 on(llm1.l2_urn =l2p1.l2_urn) 
     	                                               join hub         hb1  on(hb1.hub =l2p1.l2_urn)
						       join l2_l3_map	llm2 on( n_dst.ip_addr=llm2.ip_addr) 
     	                                               join l2_port	l2p2 on(llm2.l2_urn =l2p2.l2_urn) 
     	                                               join hub         hb2  on(hb2.hub =l2p2.l2_urn)
						       join service s   on(s.service = e.service)
						    where  
						         e.service_type = 'traceroute' and  
							 $trace_cond->{src} and 
							 $trace_cond->{dst} and 
							 s.service like '%raceroute%'|;
  
    debug " TRACEROUTE SQL_mds: $cmd";						     
    my $trace_ref =  database('ecenter')->selectall_hashref($cmd, 'metaid');
    return $trace_ref;
} 
#
#  get traceroute data 
#
sub get_traceroute {
    my ($g_client, $trace_cond, $params) = @_;
    my $hops = {};
    my $hop_ips = {};
    # get metadata
    my $md_traces =   get_traceroute_mds($trace_cond);
    debug " TRACEroute MDS:" .  Dumper $md_traces;
    my ($metaid, $md_row) = each  %{$md_traces};
    return {hops => {}, hop_ips => {}}  unless $md_row && ref $md_row eq ref {} && $md_row->{service};
    ####### 
    my $task_set = $g_client->new_task_set();
    for(my $st_time = $params->{traceroute}{start}; $st_time <= $params->{traceroute}{end}; $st_time += config->{time_slice_secs}) {
        my $data_table = strftime "%Y%m", localtime($st_time);
	my $st_end_i = $st_time + config->{time_slice_secs};
        $task_set->add_task("dispatch_data" => 
     			     encode_json {md_row => $md_row, 
			                  table =>  "$params->{table_map}{traceroute}{table}$data_table",
			    		  resolution => 100, 
			    		  type=> 'traceroute', 
					  metaid => $metaid, 
			    		  start =>  $st_time, 
			    		  end =>   ($params->{traceroute}{end}<$st_end_i?$params->{traceroute}{end}:$st_end_i)},
			     { on_complete => sub { 
			    	   my $returned = decode_json  ${$_[0]};  
			    	   if($returned->{status} eq 'ok' && $returned->{data} && @{$returned->{data}}) {
			    	      foreach my $datum ( @{$returned->{data}} ) {
				         $datum->{hop_ip} =  $datum->{ip_noted};
					 $hop_ips->{$datum->{ip_noted}}++; 
					 $hops->{$datum->{ip_noted}}{$datum->{timestamp}}  = $datum;
			    	      }
			    	   } else {
				       error "request is not OK:::" . Dumper($returned);
				   }
				   debug "HOP-IPS:::" . Dumper($hop_ips);
			    	}
			     }
			    );
    }
    $task_set->wait(timeout => $params->{timeout});
    return {hops => {}, hop_ips => {}} unless  %$hops && %$hop_ips;
    my $ips_str = join (',', map {database('ecenter')->quote($_)} keys %$hop_ips);
    ##  get hub info for each hop in the traceroute
    my $cmd =    qq|select  distinct   n_hop.netmask, n_hop.ip_noted,  n_hop.nodename, hb.hub, hb.longitude, hb.latitude  
					             from 
						            node        n_hop 
						      left join l2_l3_map    llm on( n_hop.ip_addr=llm.ip_addr) 
     	                                              left join l2_port      l2p on(llm.l2_urn =l2p.l2_urn) 
     	                                              left join hub          hb using(hub) 
						     where  
						            n_hop.ip_noted in ($ips_str) |; 
    debug " TRACEROUTE SQL_hhops: $cmd";		
    my $hops_ref = database('ecenter')->selectall_hashref($cmd, 'ip_noted');		
    return {hops => $hops, hop_ips =>  $hops_ref };
}
#
#    for the list of hop IPs get SNMP data localy or remotely ( forked )
#

sub get_snmp {
    my ($task_set, $snmp, $hops_ref,  $params) = @_;
    #debug "+++SNMP:: hops::" .  Dumper($hops_ref);
    ### my $task_set = $g_client->new_task_set;
    ## for each IP
    my $FAILED =0;
    foreach my $ip_noted (keys %{$hops_ref}) {
        next unless $ip_noted;
        $snmp->{$ip_noted} = {};
    #####  for each time slice 
        for(my $st_time = $params->{snmp}{start}; $st_time <= $params->{snmp}{end}; $st_time += config->{time_slice_secs}) {
            my $data_table = strftime "%Y%m", localtime($st_time);
	    my $st_end_i = $st_time + config->{time_slice_secs};
	    my $end_time = ($params->{snmp}{end} && $params->{snmp}{end}<$st_end_i)?$params->{snmp}{end}:$st_end_i;
	    debug "  Sending request for::$ip_noted snmp_data_$data_table $st_time  $end_time";    
            $task_set->add_task("dispatch_snmp" =>  
	                         encode_json {
	                                  table =>  "snmp_data_$data_table",
					  class =>  "SnmpData$data_table",
			    		  start =>  $st_time,
					  snmp_ip => $ip_noted,
			    		  end =>  $end_time,
					     },
			    {  
			       on_fail     => sub {$FAILED++;
					                      $logger->error("FAILED:   snmp_data_$data_table ".
					                                                " start= $st_time -  $end_time");},
			       on_complete => sub { 
			    	   my $returned = decode_json  ${$_[0]};  
			    	   if($returned->{status} eq 'ok' && $returned->{data} && ref $returned->{data} eq ref {}) {
				       ####debug "request is not OK:::" . Dumper($returned);
			    	       %{$snmp->{$ip_noted}} =  (%{$snmp->{$ip_noted}},  %{$returned->{data}});
			    	    } else {
				       error "request is not OK:::" . Dumper($returned);
				    }
			    	}
			    }
	    );
        }
    }
    return;
}
#
# get the  list of ids for the sharded table based on supplied   $param->{startTime} and  $param->{endTime} times
# returns   {dbi => \@tables, dbic => \@tables_dbic}
#
sub _get_shards {
    my ($param) = @_;
    unless($param && ref $param && $param->{data} && $param->{data} =~ /^snmp|owamp|pinger|bwctl|hop$/xmis) {
        error "No shard for the absent data type";
	return;
    }
    my $startTime = $param->{start};
    $startTime ||= time();
    my $endTime   = $param->{end};
    $endTime ||= $startTime;
    
    my $list = {};
    debug  "Loading data tables for time period $startTime to $endTime";
    # go through every day and populate with new months
    for ( my $i = $startTime; $i <= $endTime; $i += 86400 ) {
        my $date_fmt = strftime "%Y%m",  localtime($i);
        my $end_i = $i + 86400;
	debug "time_i=$i startime=$startTime end_time=$endTime  ";
	$list->{$date_fmt}{table}{dbic} = "\u$param->{data}Data$date_fmt";
        $list->{$date_fmt}{table}{dbi}  = "$param->{data}\_data_$date_fmt";
	$list->{$date_fmt}{start} = $startTime;
	$list->{$date_fmt}{end}   = ($endTime<$end_i)?$endTime:$end_i;
    }
   
    # check if table is there if required via - existing parameter
    if( $param->{existing} ) {
	foreach my $date_fmt ( sort { $a <=> $b } keys %{$list} ) {
            unless ( database('ecenter')->selectrow_array( "select * from   $date_fmt  where 1=0 " )) {
        	delete $list->{$date_fmt};
            }
	}
	unless ( scalar %$list ) {
            error " No tables found  ";
            return;
	}
    }
    return  $list;
}
#
#  get snmp data from the database with some conditions
#

#---------------------------------------------------------------
dance;
