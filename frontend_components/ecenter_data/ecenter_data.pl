#!/usr/bin/perl

use Dancer;
use Dancer::Plugin::REST;

use English;
use Data::Dumper;

use DateTime;
use Ecenter::Utils;
# for simple SQL stuff
use Plugin::DBIx;
use Params::Validate qw(:all);
# for complex SQL stuff
use Dancer::Plugin::Database;
 
my $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
my $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;

#set serializer => 'JSON';
#set content_type =>  'application/json';
prepare_serializer_for_format;

=head1 NAME

   ecenter_data.pl - standalone RESTfull service, provides interface for the Ecenter data and dispatch

=cut

any ['get', 'post'] =>  "/hub.:format" => 
       sub {
 	       return process_hub();
       };
any ['get', 'post'] =>  "/hub/src_ip/:ip.:format" => 
       sub {
 	       return process_hub(src_ip => params->{ip});
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
                    url => 'url', 
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
        return process_data( data => params->{data}, params('query'));
    };

#########   get data - all ----------------------------------------------------------
any ['get', 'post'] =>  '/data.:format' => 
    sub {
        debug "Request:" . Dumper(request->params);
        return process_data( params('query'));
    };


sub process_hub {
    my %params = validate(@_, {src_ip => {type => SCALAR, regex => $REG_IP, optional => 1} }); 
    my @hubs =(); 
    my $hash_ref;
    if( %params && $params{src_ip}) {
         $hash_ref =  database->selectall_hashref(
            qq|select distinct n.ip_noted, n.nodename, h.hub  from
     		   traceroute_data td 
     	      join metadata m using(metaid) 
     	      join node n on(m.dst_ip = n.ip_addr)
     	left  join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
     	left  join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
     	left  join hub h using(hub) 
     	where m.dst_ip is not NULL  and m.src_ip = inet6_pton('$params{src_ip}')|, 'ip_noted');
    } else {
        $hash_ref =  database->selectall_hashref(
	      qq| select distinct(n.ip_noted), n.nodename  from 
    		       traceroute_data td 
                  join metadata m using(metaid) 
                  join node n on(m.src_ip = n.ip_addr)|, 'ip_noted');
    }
    foreach my $ip (keys %$hash_ref) {
    	push @hubs, $hash_ref->{$ip};
    }
    #debug Dumper(\@hubs);
    return \@hubs;
}

    
sub process_service {
    my %params = validate(@_, {value => SCALAR, mapping =>  SCALAR });
 
    
    my @services = ();
    my %search = ();
    $search{ $params{mapping} } =  $params{value}  if( %params && $params{value});
    my @rows =   dbix->resultset('Service')->search( { %search },
		                                     { join => 'node', 
						       '+columns' => ['node.ip_noted']
						     }
						   );
    foreach my $row (@rows) {
     	my %row_h = $row->get_columns;
    	delete $row_h{ip_addr};
    	push @services, \%row_h;
    }
    debug Dumper(\@services);
    return \@services;
}
#
#   get  end to end traceroute data and reverse and then associated data - per hop (utilization) and end to end
#  if data is not in the db then get it from remote site
#
sub process_data {
    my %params = validate(@_, { data => {type => SCALAR, regex => qr/^(snmp|bwctl|owamp|pinger)$/, optional => 1}, 
                               id     => {type => SCALAR, regex => qr/^\d+$/, optional => 1}, 
                           src_ip => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
                           dst_ip => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		           start  => {type => SCALAR, regex => $REG_DATE, optional => 1},
		           end    => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      }
		 );
    my $data = {};
    debug Dumper(\%params );
    ### query allowed  as:?src_ip=131.225.1.1&dst_ip=212.4.4.4&start=2010-05-02%20:01:02&end=2010-05-02%20:01:02
    
    ### where dst_ip is optional and it will return only data for the metadata where src_ip is defined and not dst_ip
    ##  i.e. utilization data for the IP(interface)
    # 
    #  when id is provided then it superseeds src_ip and dst_ip, id means metadata id
    #
    #  if start/end is missed then default values will be used - NOW - 1 hour and NOW
    #  data service first will consult local archive and then send request to remote MA if no data or too old data found
    ###
    my %data_map = ( snmp   =>   { id => 'snmp_data',   data => 'Snmp',   table  => 'Snmp_data'   }, 
                     pinger =>   { id => 'pinger_data', data => 'PingER', table  => 'Pinger_data' }, 
		     owamp  =>   { id => 'owamp_data',  data => 'Owamp',  table  => 'Owamp_data'  },
		     bwctl  =>   { id => 'bwctl_data',  data => 'Bwctl',  table  => 'Bwctl_Data'  },
		   );
    if($params{data}) {
        eval {require "Ecenter::Data::$data_map{$params{data}}{data}"};
        if($EVAL_ERROR) {
            error "Failed: $EVAL_ERROR  - to load Ecenter::Data::$data_map{$params{data}}{data}";
	   return;
       } 
    }
    my $dst_cond = $params{dst_ip}?"md.dst_ip = inet6_pton('$params{dst_ip}')":"md.dst_ip = '0'";
   
    my $traces_ref =  database->selectall_hashref(qq|select  td.updated, td.trace_id, md.metaid, td.number_hops,
                                                             h.hop_id, h.hop_delay, inet6_ntop(h.hop_ip) as hop_ip, h.hop_num 
					             from
						            hop h 
						       join traceroute_data td using(trace_id) 
						       join metadata md       using(metaid) 
						     where  
						            md.src_ip = inet6_pton('$params{src_ip}') 
							and $dst_cond order by   h.hop_id asc|, 'hop_id');
    my $traceroute  = get_traceroute($traces_ref);
    $data->{traceroute} = $traceroute->{traceroute} 
                              if($traceroute && $traceroute->{traceroute} && 
			         ref $traceroute->{traceroute} &&  %{$traceroute->{traceroute}});
    
    my $rev_traceroute;
    if($params{dst_ip}) {
        my $rev_traces_ref =  database->selectall_hashref(qq|select  td.updated, td.trace_id, md.metaid, td.number_hops,
                                                             h.hop_id, h.hop_delay, inet6_ntop(h.hop_ip) as hop_ip, h.hop_num 
					             from
						            hop h 
						       join traceroute_data td using(trace_id) 
						       join metadata md       using(metaid) 
						     where  
						            md.dst_ip = inet6_pton('$params{src_ip}') 
							and  md.src_ip = inet6_pton('$params{dst_ip}') order by   h.hop_id asc|, 'hop_id');
        $rev_traceroute = get_traceroute($rev_traces_ref);
        $data->{reverse_traceroute} = $rev_traceroute->{traceroute} 
	                                  if($rev_traceroute && $rev_traceroute->{traceroute} && 
					     ref $rev_traceroute->{traceroute} &&  %{$rev_traceroute->{traceroute}});
    }	
   
   
    ### snmp data for each hop
    my %allhops = (%{$traceroute->{hops}}, %{$rev_traceroute->{hops}});
    foreach my $hop_ip (keys %allhops) {
        my $data_ref =  database->selectall_hashref(qq|select   l2.capacity,  sd.timestamp, AVG(sd.utilization) as utilization  
	                                               from 
						            snmp_data sd 
					              join  metadata m  on(sd.metaid = m.metaid) 
                                                      join  node n on(m.src_ip = n.ip_addr) 
						      join  l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
						      join  l2_port l2 using(l2_urn) 
						      join  hub h using(hub) 
						      where inet6_mask(m.src_ip,n.netmask) = inet6_mask(inet6_pton('$hop_ip'), n.netmask) group by sd.timestamp|,
						 'timestamp');
      
        foreach my $time (sort {$a<=>$b} keys %$data_ref) { 
	    push @{$data->{snmp}{$allhops{$hop_ip}}},   $data_ref ->{$time};
	}
    }
    # end to end data 
     
    #debug Dumper($data);
    return $data;
}


sub get_traceroute {
    my $trace_ref = shift;
    my %traces = ();
    my %hops = ();
    foreach my $hop_id (sort {$a<=>$b} keys %$trace_ref) {
        push @{$traces{$trace_ref->{$hop_id}{trace_id}}}, $trace_ref->{$hop_id};
	$hops{$trace_ref->{$hop_id}{hop_ip}} = $trace_ref->{$hop_id}{hop_id} 
	                                            if !(exists $hops{$trace_ref->{$hop_id}{hop_ip}}) ||
	                                                $hops{$trace_ref->{$hop_id}{hop_ip}} < $trace_ref->{$hop_id}{hop_id};
    }
    return {traceroute => \%traces, hops => \%hops};
}
dance;
