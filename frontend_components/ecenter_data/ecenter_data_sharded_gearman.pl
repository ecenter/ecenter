#!/bin/env perl

use Dancer;
use Dancer::Plugin::REST;
our $VERSION = '3.7';  
use English qw( -no_match_vars );
use Data::Dumper;
use lib "/home/netadmin/ecenter_git/ecenter/frontend_components/ecenter_data/lib";
use DateTime;
use DateTime::Format::MySQL;
use Ecenter::Exception;
use Ecenter::Utils;
use Ecenter::TracerouteParser;
use Ecenter::Data::Hub;
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
 set serializer => 'JSON';
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

# default error to send back - Not Implemented - 501
#
my $DEFAULT_ERROR = 501;
 
=head1 NAME

   ecenter_data.pl - standalone RESTfull service, provides interface for the Ecenter data and dispatch

=cut
##  status URL
any ['get'] =>  "/status.:format" =>
       sub {
               my $status = {};
	       foreach my $drs (keys %{config->{monitor}{gearman}} ) {
	           foreach my $host (keys  %{config->{monitor}{gearman}{$drs}} ) {
    	               map { $status->{$drs}{$host}{$_} = gearman_status($host, $_) }
		           @{config->{monitor}{gearman}{$drs}{$host}};
                   }
 	       }
	       return  { status => 'ok', gearman => $status }
       };
# health service
any ['get'] =>  "/health.:format" =>
       sub {
 	      return get_health(params('query'));
       };

## get all hubs for src_ip/dst_ip
any ['get'] =>  "/source.:format" =>
       sub {   
 	       return (config->{status_instance}?{ error => 'not supported' }:process_source());
       };
### get destination IPs for the source IP ( based on avail traceroutes)
any ['get'] =>  "/destination/:ip.:format" => 
       sub {
 	       return (config->{status_instance}?{ error => 'not supported' }:process_source(src_ip => params->{ip}));
       };
       
## get all hubs for src_hub
any ['get'] =>  "/hubs/:src_hub.:format" =>
       sub {
 	       return   (config->{status_instance}?{ error => 'not supported' }:process_source(src_hub => params->{src_hub}));
       };
## get all hubs  
any ['get'] =>  "/hub.:format" =>
       sub {
 	       return   (config->{status_instance}?{ error => 'not supported' }:
	                        database('ecenter')->selectall_hashref( qq|select distinct hub_name, longitude, latitude from  hub|, 'hub_name'));
       };
 ## get all hubs for src_ip/dst_ip
any ['get'] =>  "/node/:ip.:format" =>
       sub {
 	      return (config->{status_instance}?{ error => 'not supported' }:process_source(node_ip => params->{ip}));
       };  
#########   get services(all of them -------------------------------------
 
any ['get', 'post'] =>  "/service.:format" =>
       sub {
 	       return return (config->{status_instance}?{ error => 'not supported' }:process_service());
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
                return (config->{status_instance}?{ error => 'not supported' }:process_service( value => params->{$route}, mapping =>  $map2sql{$route}));

        };
    }
}
#########   get data - only one type POST with trace parameter---------------------------------
any [ 'post' ] =>  '/data/:data.:format' => 
    sub {
        return { error => 'not supported' } 
	    if config->{status_instance};
        my $data = {};
        eval { 
	    my $request = params;
            my $post = params('body');
	    $request->{data_type} = $request->{data};
	    delete $request->{data} 
                if exists $request->{data};
            $logger->debug("POST::::" . Dumper  $request);
	    ParameterException->throw(error => "trace paramter is mandatory")  
	        unless $request && $request->{trace};
	    delete $request->{format} 
               if exists $request->{format};
	       
	    $data = process_data( %{$request}, %{$post} );
	};
	if(my $e = Exception::Class->caught()) {
	    return send_error("Failed with " .  ($logger->is_debug?$e->trace->as_string:$e->error), $DEFAULT_ERROR );
	}
	return $data;
    };
#########   get data - all POST with trace parameter -------------------------------------------
any [ 'post'] =>  '/data.:format' => 
    sub { 
        return { error => 'not supported' } 
	    if config->{status_instance};
        my $data = {};
        eval {
	    my $request = params;
            my $post = params('body');
            $logger->debug("POST::::" . Dumper  $request); 
	    ParameterException->throw(error => "trace paramter is mandatory")  
	        unless $request && $request->{trace};
	    delete $request->{format} 
               if exists $request->{format};
	    $data = process_data( %{$request}, %{$post} );
	};
	if(my $e = Exception::Class->caught()) { 
	    return send_error("Failed with " .  ($logger->is_debug?$e->trace->as_string:$e->error), $DEFAULT_ERROR);
	}
	return $data;
    };
#########   get data - only one type ----------------------------------------------------------
any ['get'] =>  '/data/:data.:format' => 
    sub {
        return { error => 'not supported' } 
	    if config->{status_instance};
        my $data = {};
        eval {
	   $data = process_data( data_type => params->{data}, params('query'));
	};
	if(my $e = Exception::Class->caught()) {
	    return send_error("Failed with " .  ($logger->is_debug?$e->trace->as_string:$e->error), $DEFAULT_ERROR);
	}
	return $data;
    };
#########   get data - all ----------------------------------------------------------
any ['get'] =>  '/data.:format' => 
    sub {
        return { error => 'not supported' } 
	    if config->{status_instance};
	my $servers = {};
	foreach my $host (keys  %{config->{monitor}{gearman}{'drs'}} ) {
    	    foreach my $port ( @{config->{monitor}{gearman}{'drs'}{$host}} ) {
	         my $stats =  gearman_status($host, $port);
	   	 foreach my $worker (keys %{$stats} ) {
		   $servers->{$worker} +=  $stats->{$worker}{queued};
		     return { error => 'too many requests, try later' }  
	                if $servers->{$worker} > 100;
		 }
	    }
        }
        my $data = {};
        eval {
	   $data = process_data( params('query'));
	};
	if(my $e = Exception::Class->caught()) {
	    return send_error("Failed with " .  ($logger->is_debug?$e->trace->as_string:$e->error), $DEFAULT_ERROR);
	}
	return $data;
    };    
#########   get data - Site Centric View (SCV)  ----------------------------------------------------------
any ['get', 'post'] =>  '/site.:format' => 
    sub {
        return { error => 'not supported' } 
	    if config->{status_instance};
        my $data = {};
        eval {
	   $data = process_site( params('query'));
	};
	if(my $e = Exception::Class->caught()) {
	    return send_error("Failed with " .  ($logger->is_debug?$e->trace->as_string:$e->error), $DEFAULT_ERROR);
	}
	return $data;
    };

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
    my $date_params  =  params_to_date({start => $req_params{start}, end => $req_params{end}});
    map { $params->{$_} = $date_params->{$_} } keys %{$date_params};
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
    		my $shards =  get_shards({data => $table, start => $params->{start},end => $params->{end}}, database('ecenter'));
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
                               src_ip  => {type => SCALAR, regex => $REG_IP, optional => 1},
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
#   get site (HUB)  centric view - utilization for all first hop interfaces in/out in the timeperiod
sub process_site {
   my $data = {};
   my $task_set;
   my %params = ();
   eval {
        %params = validate(@_, { src_hub	 => {type => SCALAR, regex => qr/^\w+$/i }, 
		              start	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
		              end	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      timeout	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			   }
		 );
	$params{site_view} =  $params{src_hub};
	if($params{resolution}) {
            $params{resolution} =  $params{resolution} > 0 && $params{resolution} <= 1000?$params{resolution}:1000;
	} else {
            $params{resolution} = 20;
	} 
	if($params{timeout}) {
            $params{timeout} =  $params{timeout} > 0 && $params{timeout} <= 500?$params{timeout}:500;
	} else {
            $params{timeout} = 500;
	}
        my $date_params  =  params_to_date({start => $params{start},end => $params{end}});
        map { $params{$_} = $date_params->{$_} } keys %{$date_params};
        my $g_client = get_gearman(config->{gearman}{servers}); 
	$params{table_map} = $TABLEMAP;
	my $traceroute = {};
	my $trace_cond = { direct_traceroute  => { src => qq| AND  ( hb2.hub is not NULL  AND hb2.hub  not like   '%$params{src_hub}%'  AND n_src.nodename like   '%$params{src_hub}%') |},
	                   reverse_traceroute => { src => qq| AND  ( hb1.hub is not NULL  AND hb1.hub  not like   '%$params{src_hub}%'  AND n_dst.nodename like   '%$params{src_hub}%') |}
			 };
	my $utilization = {};
	my %all_ips = ();
	foreach my $way (qw/direct_traceroute reverse_traceroute/) {
            $traceroute->{$way}  = get_traceroute($g_client, $trace_cond->{$way},\%params);
            
            ##$logger->debug("$way HOPS:::", sub{Dumper $traceroute->{$way}{hops}});
            $utilization->{$way} = {};
	    my %checked_mds = ();
	    foreach my $ip (  keys %{$traceroute->{$way}{hop_ips}} ) {
	      ##next  if($traceroute->{$way}{hop_ips}{$ip}{hub_name} eq $params{src_hub});
	      
	      while (my($tm,$datum) =  each %{$traceroute->{$way}{hops}{$ip}}) {
	          my $other_hub = $way eq 'direct_traceroute'?$traceroute->{$way}{mds}{$datum->{metaid}}{dst_hub}:
	     	 		       $traceroute->{$way}{mds}{$datum->{metaid}}{src_hub};			 
	          $utilization->{$way}{$other_hub}{$ip}++;
		  $data->{$way}{$other_hub}{$ip} = $datum;
		  $all_ips{$ip}++;
		  
	      }
	    	 
	    }
	} 
	$data->{traceroute_nodes} = {%{$traceroute->{direct_traceroute}{hop_ips}}, %{$traceroute->{reverse_traceroute}{hop_ips}}};
	$logger->debug("Utilization:: ", sub{Dumper($utilization)});
        $task_set = $g_client->new_task_set; 
        my $snmp = {};
	eval {
	    get_snmp($task_set, $snmp, \%all_ips, \%params);
        }; 
        if($EVAL_ERROR) {
	    $logger->error("  No SNMP data - failed $EVAL_ERROR");
        }
	my @data_keys = qw/bwctl owamp pinger/;
	map {$data->{$_} = {}} @data_keys;
	eval {
	    foreach my $dir (qw/direct reverse/) {
		foreach my $e_type (@data_keys)  {
		    my $md_href = get_e2e_mds($e_type, $trace_cond->{"$dir\_traceroute"}{src} );
		    #debug " MD for the E2E ::: " . Dumper $md_href;
		    unless($md_href && %{$md_href}) {
		       $logger->error("No metadata for e2e on $dir ....");
		       next;
		    }   
		    $logger->debug(" ...  Running  ------------  $e_type");
		    get_e2e($task_set, $data->{$e_type}, \%params, $md_href, $e_type, 'site_view');
		    $logger->debug(" +++++ Done  $dir ------------  $e_type");
		}
	    }
        };
        if($EVAL_ERROR) {
            $logger->error( "e2e data call  failed - $EVAL_ERROR");
        }
	$task_set->wait(timeout => $params{timeout});
	my $hub = Ecenter::Data::Hub->new;
	foreach my $way (qw/direct_traceroute reverse_traceroute/) {
	    foreach my $dst_hub (keys %{$utilization->{$way}}) {
	       $data->{$way}{$dst_hub}{snmp} = {  utilization => {ip => 'NA', value => 0},
	                                          errors      => {ip => 'NA', value => 0},
						  drops       => {ip => 'NA', value => 0},
					       };
	       foreach my $ip  (keys %{$utilization->{$way}{$dst_hub}}) {
	            foreach my $time (sort {$a<=>$b} grep {$_} keys %{$snmp->{$ip}}) {
		        next unless $snmp->{$ip}{$time}{capacity};
		        my %tmp =  %{$snmp->{$ip}{$time}};
			$tmp{utilization} = $tmp{utilization}?($tmp{utilization}/$tmp{capacity})*100.:0;
			foreach my $metric (qw/utilization  errors drops/) {
		            if( $tmp{$metric} &&  
			       ($tmp{$metric}  > $data->{$way}{$dst_hub}{snmp}{$metric}{value})) {
		                $data->{$way}{$dst_hub}{snmp}{$metric}{value} = $tmp{$metric};
		                $data->{$way}{$dst_hub}{snmp}{$metric}{ip} = $ip;
			    }
		        }
	    	    }
	        }
	    }
	}
    };
    if($EVAL_ERROR) {
      $logger->error("site centric call  failed - $EVAL_ERROR");
      GeneralException->throw(error => $EVAL_ERROR ); 
    } 
    return $data;
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
        %params = validate(@_, { data_type  => {type => SCALAR, regex => qr/^(snmp|bwctl|owamp|pinger|traceroute|circuit)$/i, optional => 1}, 
                              id	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1}, 
                              src_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
			      src_hub	 => {type => SCALAR, regex => qr/^\w+$/i,optional => 1}, 
                              dst_hub	 => {type => SCALAR, regex => qr/^\w+$/i,optional => 1}, 
                              dst_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		              start	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
		              end	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      timeout	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      only_data  => {type => SCALAR, regex => qr/^(0|1)$/, optional => 1},
      		              trace      => {type => SCALAR, regex => qr/traceroute/xim, optional => 1},
			      no_snmp    => {type => SCALAR, regex => qr/^(0|1)$/, optional => 1},
			   }
		 );
    };
    if($EVAL_ERROR) {
        $logger->error("parameters failed - $EVAL_ERROR");
        GeneralException->throw(error => $EVAL_ERROR ); 
    }
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
   
    my $date_params  =  params_to_date({start => $params{start},end => $params{end}});
    map { $params{$_} = $date_params->{$_} } keys %{$date_params};
    my $traceroute = {};
    my %allhops = ();
    ################ starting the client
    #
    #
    my $g_client =   get_gearman(config->{gearman}{servers});
    ### parse traceroute and get hops, reverse trqaceoute between identified HUBs and e2e metrics
    ### 
    eval {
        if($params{trace}) {
            my $tr  = Ecenter::TracerouteParser->new();
	    $tr->text($params{trace}); 
            my $hops = $tr->parse();# get hops
	    MalformedParameterException->throw( error => 'No hops were found in the provided traceroute')
		unless $tr->hops;

	    my $ips_str = join (',', map {database('ecenter')->quote($_)} keys %{$hops->{hops}});
	    $traceroute->{direct_traceroute}{hops} = $hops->{hops};
            _fix_sites($hops->{hops}, $ips_str);
	    my $cmd =    qq|select  distinct   n_hop.netmask, n_hop.ip_noted, n_hop.nodename, hb.hub, hb.hub_name, hb.longitude, hb.latitude  
					        	 from 
						        	node   n_hop 
							  left join l2_l3_map    llm on( n_hop.ip_addr = llm.ip_addr) 
     	                                        	  left join l2_port      l2p on(llm.l2_urn = l2p.l2_urn) 
     	                                        	  left join hub          hb using(hub) 
							 where  
						        	n_hop.ip_noted in ($ips_str) and hb.hub is not NULL|;
            $logger->debug(" TRACEROUTE SQL_hhops: $cmd");		
            my $hops_ref = database('ecenter')->selectall_hashref($cmd, 'ip_noted');
            $traceroute->{direct_traceroute}{hop_ips} =  $hops_ref;
	    MalformedParameterException->throw( error => 'No HUBs were found for the provided traceroute')
		unless    $hops->{src_ip} && $hops->{dst_ip} 
	               && $hops_ref->{$hops->{src_ip}}{hub_name} &&  $hops_ref->{$hops->{dst_ip}}{hub_name};
            $params{src_hub} = $hops_ref->{$hops->{src_ip}}{hub_name};
	    $params{dst_hub} = $hops_ref->{$hops->{dst_ip}}{hub_name};
        }
    };
    if($EVAL_ERROR) {
        $logger->error("parsing traceroute failed - $EVAL_ERROR");
        GeneralException->throw(error => $EVAL_ERROR ); 
    }
    my $trace_cond = get_trace_conditions( %params );
    #
    #
    # my $dst_cond = $params{dst_ip}?"inet6_mask(md.dst_ip, 24)= inet6_mask(inet6_pton('$params{dst_ip}'), 24)":"md.dst_ip = '0'";
    ##
    ## get direct and reverse traceroutes
    ## 
    # my $trace_cond = qq|  inet6_mask(md.src_ip, 24) = inet6_mask(inet6_pton('$params{src_ip}'), 24) and $dst_cond |;
    $params{table_map} = $TABLEMAP;
    $logger->debug("Traceroute results:", sub {Dumper({ trace_cond => $trace_cond, traceroute => $traceroute, params => \%params})});
    #
    #    circuit data
    #
    if($params{data_type} && $params{data_type} eq 'circuit') {
        eval {
            $data = get_circuit_data($g_client, $trace_cond,  \%params);
	    reduce_snmp_dataset($data->{snmp}, \%params) 
	        unless $params{no_snmp};
        };
        if($EVAL_ERROR) {
            $logger->error("parsing traceroute failed - $EVAL_ERROR");
            GeneralException->throw(error => $EVAL_ERROR ); 
        } else {
	    return $data;
	}
    }
    eval {
	if(!$params{only_data} || ($params{data_type} && $params{data_type} eq 'snmp')) {
            foreach my $way (qw/direct_traceroute reverse_traceroute/) {
		unless( $way eq 'direct_traceroute' && $params{trace}) { ### skip direct raceroute because we got it from the request
                    $traceroute->{$way} = get_traceroute($g_client, $trace_cond->{$way}, \%params);
        	}
		$data->{$way} = $traceroute->{$way}{hops}
                        	  if($traceroute->{$way} && $traceroute->{$way}{hops} && 
			             ref $traceroute->{$way}{hops} &&  %{$traceroute->{$way}{hops}}); 
            }
            ### snmp data for each hop - all unique hop IPs
    	    %allhops = (%{$traceroute->{direct_traceroute}{hop_ips}}, %{$traceroute->{reverse_traceroute}{hop_ips}});
	    $data->{traceroute_nodes} = \%allhops;
	    return $data unless $traceroute->{direct_traceroute}{hop_ips} || $traceroute->{reverse_traceroute}{hop_ips};
	} else {
            %allhops = ( $params{src_ip} => 1 );
	}

	$logger->debug("HOPS:::", sub{Dumper(\%allhops)});

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
	# return $data;
	# end to end data  stats if available
	### return $data unless $params{src_ip} && $params{dst_ip};
	my @data_keys = ();
	if($params{data_type}) {
            @data_keys = ($params{data_type}) if  $params{data_type} =~ /^bwctl|owamp|pinger$/i;
	} else {
            @data_keys =  qw/bwctl owamp pinger/;
	}
	# my @data_keys = qw/owamp/;
	map {$data->{$_} = {}} @data_keys;
	#
	# B logic - get list of slowest pinger and owamp services and creat exclusion list to avoid them  
	#
	if(@data_keys) {
	    foreach my $dir (qw/direct reverse/) {
		foreach my $e_type (@data_keys)  {
		    $logger->debug(" ...  Running  ------------  $e_type");
		     my $md_href = get_e2e_mds($e_type, $trace_cond->{"$dir\_traceroute"}{src}, $trace_cond->{"$dir\_traceroute"}{dst});
	             unless($md_href && %{$md_href}) {
	        	$logger->error("!!!! No metadata for $e_type on $dir ....");
	        	 next;
	             }
		    get_e2e($task_set, $data->{$e_type}, \%params, $md_href, $e_type );
		    $logger->debug(" +++++ Done  $dir ------------  $e_type");
		}
	     }
	}
  };
  if($EVAL_ERROR) {
      $logger->error("data calls  failed - $EVAL_ERROR");
      GeneralException->throw(error => $EVAL_ERROR ); 
  }
  $logger->debug(" +++++ Waiting  +++++++++++");
  $task_set->wait(timeout => $params{timeout}) if $task_set;
  $logger->debug(" +++++ E2E is DONE  +++++++++++");
  reduce_snmp_dataset($data->{snmp}, \%params);
  return $data; 
}

#
# reduce snmp data set to resolution
#
sub reduce_snmp_dataset {
    my ($snmp, $params) = @_;
    foreach my $direction (qw/in out/) {
      foreach my $ip_noted (keys %{$snmp->{$direction}}) { 
        my @result = (); 
        foreach my $time  (sort {$a<=>$b} grep {$_} keys %{$snmp->{$direction}{$ip_noted}}) { 
     	    push @result,[ $time,  { capacity =>  $snmp->{$direction}{$ip_noted}{$time}{capacity},  
     				  utilization => $snmp->{$direction}{$ip_noted}{$time}{utilization},
     				  errors => $snmp->{$direction}{$ip_noted}{$time}{errors},
     				  drops => $snmp->{$direction}{$ip_noted}{$time}{drops}
     				}
     		        ];
        }
        ### debug "Data for ip=$hop_ip hop_id=$hops_ref->{$hop_ip}:: " . Dumper( $snmp{$hops_ref->{$hop_ip}});
        delete $snmp->{$direction}{$ip_noted};
	$snmp->{$direction}{$ip_noted}  = refactor_result(\@result, 'snmp', $params->{resolution}) if @result;
	##$snmp->{$ip_noted} = \@result;
      }
    }
    return $snmp;
}
#
# get list of metadata ids for the e2e data and some src/dts conditions
sub get_e2e_mds {
    my ($e2e_type, $src_cond, $dst_cond) = @_;
    my $e2e_conditions = $src_cond;
    $e2e_conditions .= " $dst_cond" if $dst_cond;
    my  $exclude_services_sql ;
    if($e2e_type =~ /pinger|owamp/) {
       my $slow_services  =  database('ecenter')->selectall_hashref(q|select distinct s.service   from service_performance sp 
                                                            join metadata md using(metaid)
							    join  node n_src on(md.src_ip = n_src.ip_addr)
							    join  node n_dst on(md.dst_ip = n_dst.ip_addr)
							    join l2_l3_map    llm1 on(n_src.ip_addr=llm1.ip_addr)
							    join l2_port      l2p1 on(llm1.l2_urn =l2p1.l2_urn)
                                                            join hub	      hb1  on(hb1.hub =l2p1.hub)
							    join l2_l3_map    llm2 on(n_dst.ip_addr=llm2.ip_addr)
                                                            join l2_port      l2p2 on(llm2.l2_urn =l2p2.l2_urn)
							    join hub	      hb2  on(hb2.hub =l2p2.hub)
							    join eventtype e on(md.eventtype_id = e.ref_id)
							    join service s using(service) 
							    where e.service_type in ('pinger') 
							    and sp.response > | . config->{slow_service_limit} . 
							    qq|  $e2e_conditions |, 'service');  
        $exclude_services_sql =  join (' AND ', map {  "  s.service !='$_' " } keys %{$slow_services});
    }
    
    $exclude_services_sql =  $exclude_services_sql?"($exclude_services_sql)":'1';
    my $e2e_sql = qq|select   md.metaid, n_src.ip_noted as src_ip, md.subject, e.service_type as type, hb1.hub_name as src_hub, hb2.hub_name as dst_hub,
                              n_dst.ip_noted  as dst_ip, 
                                                	  n_src.nodename as src_name, n_dst.nodename as dst_name, s.service
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
						      where  
							    $exclude_services_sql and e.service_type  = '$e2e_type'
							    $e2e_conditions
				        	 group by src_ip, dst_ip, service, type|;
    $logger->debug(" E2E SQL:: $e2e_sql");
    return database('ecenter')->selectall_hashref($e2e_sql, 'metaid');
}
#
#
#   fix new sites from the user provided traceroute
#
sub _fix_sites {
    my ($hops_href, $ips_str) = @_;
    my $now_time = strftime('%Y-%m-%d %H:%M:%S', localtime());
    my $sql_ips = qq|select ip_noted from node where ip_noted in  ($ips_str)|;
    $logger->debug("Get list of existing IPs::: $sql_ips");
    my $skip_these = database('ecenter')->selectall_hashref($sql_ips, 'ip_noted');
    foreach my $ip (keys %{$hops_href}) {
        next if exists $skip_these->{$ip};
	my (undef, $nodename) = get_ip_name($ip);
        my $hub = Ecenter::Data::Hub->find_hub($ip, $nodename);
	unless ($hub) { 
	    $logger->error(" Could not find hub - $ip, skipping ");
            next;
	}
	my $hub_name = $hub->hub_name;
	my %subnets =  %{$hub->get_ips()};
        foreach my $subnet (keys %subnets) {
            my $sql = qq|select inet6_pton('$ip') as ip_addr, n.ip_noted, n.netmask, l2p.l2_urn from  node n   join l2_l3_map llm using(ip_addr) 
	                   join l2_port l2p on (llm.l2_urn =l2p.l2_urn) 
	              where   
			    inet6_mask(inet6_pton('$ip'), $subnets{$subnet}) =  inet6_mask(n.ip_addr, $subnets{$subnet})
			    and llm.l2_urn is not NULL  limit 1|;
	    $logger->debug("Found hub IPs SQL::: $sql"); 
            my $nodes =   database('ecenter')->selectrow_hashref($sql);
	    # found all ips for the endsite, lets mark them with made up urns and hub names
	    $logger->debug("Checking::: $ip");
	    unless ($nodes && $nodes->{ip_addr}) {
	         $logger->error(" No matching netblock for $ip");
		 next;
	    }
	    
	    schema('dbix')->resultset('Node')->update_or_create({ ip_addr => $nodes->{ip_addr},
	                                                  ip_noted => $ip,
							  nodename => $nodename,
							  netmask => $nodes->{netmask}
							 });
	    schema('dbix')->resultset('L2L3Map')->update_or_create({ ip_addr => $nodes->{ip_addr},
	                                                   l2_urn => $nodes->{l2_urn},
							   updated => $now_time,
							 },
							 { key => 'ip_l2_time'});
	    
        } 
    }
}
#
#  get bwctl/owamp/pinger data for end2end, first for the src_ip, then for the dst_ip
#
sub get_e2e{
    my ($task_set,  $data_hr,  $params,   $md_href, $type, $site_view) = @_; 
    my %result = ();
    ### my $task_set = $g_client->new_task_set;
    my $FAILED = 0;
    my %data_filter = map {$_ => 1}  @{$TABLEMAP->{$type}{data}};
    my $time_slice = ($type =~ /pinger|owamp/)?config->{time_slice_secs}:($params->{$type}{end} - $params->{$type}{start});
    foreach my $metaid  ( keys %{$md_href} ) {
        my  $md_row =  $md_href->{$metaid}; 
	debug " ------  $type md  $metaid  :::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} "; 
        next if $md_row->{type} ne $type || !$metaid;
        $logger->info(" ------ FOUND METADATA:: $type md =$metaid  :::" .
	              " SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} start=$params->{$type}{start} " .
		      " end=$params->{$type}{end} slice=$time_slice");
	$data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}} = {} unless $site_view;
	for(my $st_time = $params->{$type}{start}; $st_time < $params->{$type}{end}; $st_time +=  $time_slice) {
	    my $data_table = strftime "%Y%m", localtime($st_time);
	    my $st_end_i = $st_time +  $time_slice;   
	    my $end_time = ($params->{$type}{end} && $params->{$type}{end}<$st_end_i)?$params->{$type}{end}:$st_end_i;
	    my $table = $type eq 'traceroute'?'hop':$type;
	    my $shards =  get_shards({data =>  $type, start => $st_time, end =>  $end_time}, database('ecenter'));
    	    foreach my $shard (sort  { $a <=> $b } keys %$shards) {
	        $logger->info(" ------ MD=$metaid  start= $st_time -  $end_time slice = $time_slice  $shards->{$shard}{table}{dbic} ");
	        my $ret =  $task_set->add_task("dispatch_data" =>
	                                      encode_json {metaid => $metaid, 
					        	   table =>   $shards->{$shard}{table}{dbic},
							   md_row => $md_row,
                                                	   start  => $st_time,
							   type => $type,
							   resolution => $params->{resolution},
					     	 	   end    =>  $end_time
					     	 	  },
					  {
					   on_fail     => sub {$FAILED++;
					                      $logger->error("FAILED: $metaid  $shards->{$shard}{table}{dbic}  ".
					                                                " start= $st_time -  $st_end_i");},
					   on_complete => sub { 
					                     my $returned = decode_json  ${$_[0]};  
							     if($returned->{status} eq 'ok' && $returned->{data} && ref $returned->{data} eq ref []) {
                                                                 foreach my $datum ( @{$returned->{data}} ) {
							             unless($datum && ref $datum eq ref []) {
								         $logger->error("FAILED: datum malformed", sub{Dumper($datum)});
									 next;
								     }
								     my %result_clip =    map {$_ => $datum->[1]{$_}} grep($data_filter{$_}, keys %{$datum->[1]});
								     if($site_view) {
								         # for site view get extreme values
								         map{ $data_hr->{$md_row->{dst_hub}}{$_} = $result_clip{$_} 
									         if $result_clip{$_} && (!$data_hr->{$md_row->{dst_hub}}{$_} ||
										  ($_ =~ /min/ && $data_hr->{$md_row->{dst_hub}}{$_} > $result_clip{$_}) ||
										  $data_hr->{$md_row->{dst_hub}}{$_} < $result_clip{$_}) 
									 } keys %result_clip;
								     } else {
								         $data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}}{metaid}  = $metaid;
								         $data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}}{src_hub} = $md_row->{src_hub};
								         $data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}}{dst_hub} = $md_row->{dst_hub};
				                                         $data_hr->{$md_row->{src_ip}}{$md_row->{dst_ip}}{data}{$datum->[0]} = \%result_clip;
								     }
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
    }
    return;
}

#
#     get traceroute md ids   from the db
# 
sub  get_traceroute_mds {
    my ($trace_cond) = @_;
    my $trace_cond_string =  $trace_cond->{src};
    $trace_cond_string .= " $trace_cond->{dst}" if $trace_cond->{dst};
    my  $cmd =   qq|select  distinct md.metaid as metaid, md.src_ip, inet6_ntop(md.src_ip) as src_ipaddr, md.dst_ip, inet6_ntop(md.dst_ip) as dst_ipaddr, md.subject, hb1.hub_name as src_hub, hb2.hub_name as dst_hub,
                             s.service  from 
	                                                    metadata md 
	                                               join eventtype e on(md.eventtype_id = e.ref_id)  
						       join node n_src  on(md.src_ip = n_src.ip_addr)
						       join node n_dst  on(md.dst_ip = n_dst.ip_addr) 
						       left join l2_l3_map	llm1 on( n_src.ip_addr=llm1.ip_addr) 
     	                                               left join l2_port	l2p1 on(llm1.l2_urn =l2p1.l2_urn) 
     	                                               left join hub         hb1  on(hb1.hub =l2p1.hub)
						       left join l2_l3_map	llm2 on( n_dst.ip_addr=llm2.ip_addr) 
     	                                               left join l2_port	l2p2 on(llm2.l2_urn =l2p2.l2_urn) 
     	                                               left join hub         hb2  on(hb2.hub =l2p2.hub)
						       join service s   on(s.service = e.service)
						    where  
							  e.service_type = 'traceroute' and   s.service like '%raceroute%'
							  $trace_cond_string|;
  
    $logger->debug(" TRACEROUTE SQL_mds: $cmd");						     
    my $trace_ref =  database('ecenter')->selectall_hashref($cmd, 'metaid');
    return $trace_ref;
}
#
#  get_traceroute_conditions
#
sub get_trace_conditions {
    my %params = @_;
    my $trace_cond = {};
    if($params{src_ip}) {
    	$trace_cond->{direct_traceroute}{src}  = qq| AND md.src_ip =  inet6_pton('$params{src_ip}')|;
    	$trace_cond->{reverse_traceroute}{src} = qq| AND  md.dst_ip  =  inet6_pton('$params{src_ip}') |;
    } 
    if ($params{src_hub}) {
       $trace_cond->{direct_traceroute}{src}  = qq| AND  n_src.nodename like   '%$params{src_hub}%' |;
       $trace_cond->{reverse_traceroute}{src} = qq| AND  n_src.nodename like   '%$params{dst_hub}%' |;
    }
    if($params{dst_ip}) {
    	$trace_cond->{direct_traceroute}{dst}	=   qq| AND   md.dst_ip =  inet6_pton('$params{dst_ip}') |;
    	$trace_cond->{reverse_traceroute}{dst}  =   qq|  AND  md.src_ip =  inet6_pton('$params{dst_ip}')  |; 
    } 
    if ($params{dst_hub}) {
      $trace_cond->{direct_traceroute}{dst}   = qq| AND   n_dst.nodename like	'%$params{dst_hub}%' |;
      $trace_cond->{reverse_traceroute}{dst}  = qq| AND  n_dst.nodename like	'%$params{src_hub}%' |;
    }
    return $trace_cond;
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
    $logger->debug(" TRACEroute MDS:", sub{Dumper $md_traces}); 
    my @metaids = ();
    my @md_rows = ();
    #if($trace_cond->{src} &&  $trace_cond->{dst}) {
     #    ($metaids[0], $md_rows[0]) = each  %{$md_traces};
     #} else {
     foreach my $md (keys %{ $md_traces }) {
        if($md_traces->{$md}{src_ipaddr} !~ /^::/ && $md_traces->{$md}{dst_ipaddr} !~ /^::/) {
	  push @metaids, $md;
	  push @md_rows, $md_traces->{$md};
	  last;
	}
    }
    return {hops => {}, hop_ips => {}}  unless @md_rows && ref $md_rows[0] eq ref {} && $md_rows[0]->{service};
    #######
    my $FAILED = 0;
    my $task_set = $g_client->new_task_set();
    foreach my $metaid (@metaids) {
        my $md_row = shift @md_rows;
	for(my $st_time = $params->{traceroute}{start}; $st_time <= $params->{traceroute}{end}; $st_time += config->{time_slice_secs}) {
            my $data_table = strftime "%Y%m", localtime($st_time);
	    my $st_end_i = $st_time +  config->{time_slice_secs};
	    my $request_start_time = $st_time; 
	    my $shards =  get_shards({data =>  'hop', start => $st_time, end => $st_end_i  }, database('ecenter'));
    	    foreach my $shard (sort  { $a <=> $b } keys %$shards) {
	        ### most recent traceroute - if not found then return the latest available, unset start time
		#if((time() - $st_end_i) < 3600) {
		#    $request_start_time = 0; 
		#}
	        $logger->debug("Dispatching:: $shards->{$shard}{table}{dbic} md=$metaid st=$request_start_time " , sub{Dumper($md_row)});
                $task_set->add_task("dispatch_data" => 
     				encode_json {md_row => $md_row, 
			                      table =>   $shards->{$shard}{table}{dbic},
			    		      resolution => $params->{resolution}, 
			    		      type=> 'traceroute', 
					      metaid => $metaid, 
			    		      start =>  $request_start_time, 
			    		      end =>   ($params->{traceroute}{end}<$st_end_i?$params->{traceroute}{end}:$st_end_i)},
				{  on_fail     => sub {$FAILED++;
					                      $logger->error("FAILED TRACEROUTE: $metaid  $shards->{$shard}{table}{dbic}  ".
					                                                " start=  $request_start_time -  $st_end_i");},
				    on_complete => sub { 
			    	       my $returned = decode_json  ${$_[0]};  
			    	       if($returned->{status} eq 'ok' && $returned->{data} && @{$returned->{data}}) {
			    		  foreach my $datum ( @{$returned->{data}} ) {
					     next unless $datum->{ip_noted};
				             $datum->{hop_ip} =  $datum->{ip_noted};
					     $datum->{hop_ip} = $datum->{nodename} if !$datum->{hop_ip} && $datum->{nodename} && $datum->{nodename} =~ /^[abcdfe0-9:\.]+]$/i;
					     $hop_ips->{$datum->{ip_noted}}++;
					     $hops->{$datum->{ip_noted}}{$datum->{timestamp}}  = $datum;
			    		  }
			    	       } else {
					   $logger->error("Traceroute request md=$metaid st=$st_time is not OK (no data or status) = $returned->{status} - ", sub{Dumper($returned)});
				       }
				       $logger->debug("HOP-IPS:::", sub{Dumper($hop_ips)});
			    	    }
				}
		);
	    }
	}
    }
    $task_set->wait(timeout => $params->{timeout});
    
    return {hops => {}, hop_ips => {}} unless  %$hops && %$hop_ips;
    my $ips_str = join (',', map {database('ecenter')->quote($_)} keys %$hop_ips);
    ##  get hub info for each hop in the traceroute
    my $cmd =    qq|select  distinct   n_hop.netmask, n_hop.ip_noted,  n_hop.nodename, hb.hub, hb.hub_name, hb.longitude, hb.latitude  
					             from 
						            node        n_hop 
						      left join l2_l3_map    llm on( n_hop.ip_addr=llm.ip_addr) 
     	                                              left join l2_port      l2p on(llm.l2_urn =l2p.l2_urn) 
     	                                              left join hub          hb using(hub) 
						     where  
						            n_hop.ip_noted in ($ips_str) |; 
    $logger->debug(" TRACEROUTE SQL_hhops: $cmd");		
    my $hops_ref = database('ecenter')->selectall_hashref($cmd, 'ip_noted');		
    return {hops => $hops, hop_ips =>  $hops_ref, mds => $md_traces};
}
#
#   get circuit data
#
sub get_circuit_data {
    my ($g_client, $trace_cond,  $params) = @_;
    my $snmp = {};
    my $FAILED = 0;
    $logger->debug(" get_circuit_data ---------- ");
    my $task_set = $g_client->new_task_set;
    my $shards =  get_shards({data =>  'snmp', start => $params->{snmp}{start} , end =>  $params->{snmp}{end} }, database('ecenter'));
    foreach my $shard (sort  { $a <=> $b } keys %$shards) {
       $logger->debug(" Circuits table:$shard start=$shards->{$shard}{start} end=$shards->{$shard}{end}");
       my $sql = qq|select   h_src.hub_name  as src_hub, h_dst.hub_name as dst_hub, hop_l2p.l2_urn as hop_urn, h_hop.hub_name as hub_name, 
	                                                                 clink.link_num as hop_num, h_hop.longitude as longitude, 
									 h_hop.latitude as latitude,
	                                                                 c.circuit, c.description, c.start_time, c.end_time
	                                                     from 
							               circuit_link_$shard clink 
								  join l2_port hop_l2p on(clink.l2_urn=hop_l2p.l2_urn) 
							          join circuit_$shard c on(clink.circuit=c.circuit)
	                                                          join hub h_src on(c.src_hub = h_src.hub)
								  join hub h_dst on(c.dst_hub=h_dst.hub)
								  join hub h_hop on(hop_l2p.hub=h_hop.hub)
                                                                where  clink.direction = 'forward' and 
								      ((h_src.hub_name = '$params->{src_hub}' and h_dst.hub_name = '$params->{dst_hub}')
								          OR
								       (h_dst.hub_name = '$params->{src_hub}' and h_src.hub_name = '$params->{dst_hub}'))
								       and  c.end_time >=   $shards->{$shard}{start}|;
	$logger->debug(" Circuits table	SQL:$sql");
        my $hops = database('ecenter')->selectall_hashref($sql, 'hop_num');
        #$snmp->{hops}{$shard} = $hops;
        my %urns = ();
	$logger->debug(" Circuits hops:", sub{Dumper($hops)});
        foreach my $hop (keys %{$hops}) {
	    map {  $snmp->{circuits}{$hops->{$hop}{src_hub}}{$hops->{$hop}{dst_hub}}{$hops->{$hop}{circuit}}{circuit}{$_} = $hops->{$hop}{$_} }
	        qw/start_time end_time description/;
	    map { $snmp->{circuits}{$hops->{$hop}{src_hub}}{$hops->{$hop}{dst_hub}}{$hops->{$hop}{circuit}}{hops}{$hops->{$hop}{hop_urn}}{$_} =  $hops->{$hop}{$_}}
	        qw/hop_num hub_name longitude latitude/;
	    $urns{$hops->{$hop}{hop_urn}}++;
        }
	## skipping
	next if $params->{no_snmp};
	## data
        foreach my $urn (keys %urns) {
	    $snmp->{snmp}{in}{$urn} = {}; 
    	    $snmp->{snmp}{out}{$urn} = {}; 
    	    
	    $task_set->add_task("get_remote_snmp" =>  
    			  encode_json {
	 			   start =>  $shards->{$shard}{start},
	 			   urn =>    $urn,
	 			   end =>    $shards->{$shard}{end},
				   service => config->{circuits_ma},
	 			      },
	 	     {  
	 		on_fail     => sub {$FAILED++;
	 					       $logger->error("FAILED:  CIRCUITS snmp_data_$shard ".
	 									 " start=$shards->{$shard}{start}-$shards->{$shard}{end}");},
	 		on_complete => sub { 
	 		    my $returned = decode_json  ${$_[0]};  
	 		    if($returned->{status} eq 'ok' && $returned->{data} && ref $returned->{data} eq ref {}) {
	 			$logger->debug(" Circuits DATA OK:::", sub{Dumper($returned->{data})});
				%{$snmp->{snmp}{in}{$urn}} =  (%{$snmp->{snmp}{in}{$urn}},  %{$returned->{data}{in}}) if $returned->{data}{in};
	 			%{$snmp->{snmp}{out}{$urn}} =  (%{$snmp->{snmp}{out}{$urn}},  %{$returned->{data}{out}}) if $returned->{data}{out};
	 		     } else {
	 			$logger->error("request is not OK:::", sub{Dumper($returned)});
	 		     }
	 		 }
	 	     }
            );
        }
    }
    $task_set->wait(timeout => $params->{timeout})
        if $task_set;
    return $snmp;
}

#
#    for the list of hop IPs get SNMP data localy or remotely
#

sub get_snmp {
    my ($task_set, $snmp, $hops_ref,  $params) = @_;
    #debug "+++SNMP:: hops::" .  Dumper($hops_ref);
    ### my $task_set = $g_client->new_task_set;
    ## for each IP
    my $FAILED =0;
    foreach my $ip_noted (keys %{$hops_ref}) {
        next unless $ip_noted;
        $snmp->{in}{$ip_noted} = {};
	$snmp->{out}{$ip_noted} = {};
    #####  for each time slice 
        for(my $st_time = $params->{snmp}{start}; $st_time <= $params->{snmp}{end}; $st_time += config->{time_slice_secs}) {
            my $data_table = strftime "%Y%m", localtime($st_time);
	    my $st_end_i = $st_time + config->{time_slice_secs};
	    my $end_time = ($params->{snmp}{end} && $params->{snmp}{end}<$st_end_i)?$params->{snmp}{end}:$st_end_i;
	    $logger->debug("  Sending request for::$ip_noted snmp_data_$data_table $st_time  $end_time");
	    
            $task_set->add_task("dispatch_snmp" =>  
	                         encode_json {
	                                  table =>  "snmp_data_$data_table",
					  class =>  "SnmpData$data_table",
			    		  start =>  $st_time,
					  snmp_ip => $ip_noted,
			    		  end =>  $end_time
					     },
			    {  
			       on_fail     => sub {$FAILED++;
					                      $logger->error("FAILED:   snmp_data_$data_table ".
					                                                " start= $st_time -  $end_time");},
			       on_complete => sub { 
			    	   my $returned = decode_json  ${$_[0]};  
			    	   if($returned->{status} eq 'ok' && $returned->{data} && ref $returned->{data} eq ref {}) {
				       ####debug "request is not OK:::" . Dumper($returned);
			    	       # %{$snmp->{$ip_noted}} =  (%{$snmp->{$ip_noted}},  %{$returned->{data}});
				       %{$snmp->{in}{$ip_noted}} =  (%{$snmp->{in}{$ip_noted}},  %{$returned->{data}{in}}) if $returned->{data}{in};
	 			       %{$snmp->{out}{$ip_noted}} =  (%{$snmp->{out}{$ip_noted}},  %{$returned->{data}{out}}) if $returned->{data}{out};
			    	    } else {
				       $logger->error("request is not OK:::", sub{Dumper($returned)});
				    }
			    	}
			    }
	    );
        }
    }
    return;
}

dance;
