#!/usr/bin/perl

use Dancer;
use Dancer::Plugin::REST;
 
use English;
use Data::Dumper;

use DateTime;
use DateTime::Format::MySQL;

use Parallel::ForkManager;

# for simple SQL stuff
use Plugin::DBIx;
use Params::Validate qw(:all);
# for complex SQL stuff
use Dancer::Plugin::Database;
use Dancer::Logger;
use Log::Log4perl qw(:easy); 
use Ecenter::Data::Snmp;
use Ecenter::Data::PingER;
use Ecenter::Data::Bwctl;

use aliased 'perfSONAR_PS::PINGER_DATATYPES::v2_0::pinger::Message::Metadata::Subject' => 'MetaSubj';
 
my $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
my $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;

#set serializer => 'JSON';
#set content_type =>  'application/json';
prepare_serializer_for_format;

config->{debug}?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);
 
=head1 NAME

   ecenter_data.pl - standalone RESTfull service, provides interface for the Ecenter data and dispatch

=cut

##  status URL
any ['get', 'post'] =>  "/status.:format" => 
       sub {
 	       return  { status => 'ok'}
       };
## get all hubs for src_ip/dst_ip
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
        my $data = {};
        eval {
	   $data = process_data( data => params->{data}, params('query'));
	};
	if($EVAL_ERROR) {
	    send_error("Failed with $EVAL_ERROR");
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
	if($EVAL_ERROR) {
	    send_error("Failed with $EVAL_ERROR");
	}
	return $data;
    };
#
# return list of hubs with coordinates
#
sub process_hub {
    my %params = validate(@_, {src_ip => {type => SCALAR, regex => $REG_IP, optional => 1} }); 
    my @hubs =(); 
    my $hash_ref;
    if( %params && $params{src_ip}) {
         $hash_ref =  database->selectall_hashref(
            qq|select distinct n.ip_noted, n.nodename, h.hub, h.longitude, h.latitude  from
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
#
# return list of services 
#
sub process_service {
    my %params = validate(@_, {value =>  {type => SCALAR, optional => 1}, mapping =>  {type => SCALAR, optional => 1}});
 
    
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
    # debug Dumper(\@services);
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
    # debug Dumper(\%params );
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
    #   get epoch or set default to NOW and -1 hour
    $params{start} = $params{start}?DateTime::Format::MySQL->parse_datetime( $params{start} )->epoch:(time() - 3600);
    $params{end} =   $params{end}?DateTime::Format::MySQL->parse_datetime( $params{end} )->epoch:time();
    
    my $dst_cond = $params{dst_ip}?"inet6_mask(md.dst_ip, n_dst.netmask)= inet6_mask(inet6_pton('$params{dst_ip}'), n_dst.netmask)":"md.dst_ip = '0'";
    ##
    ## get direct and reverse traceroutes
    ## 
    my $trace_cond = qq|  inet6_mask(md.src_ip, n_src.netmask) = inet6_mask(inet6_pton('$params{src_ip}'), n_src.netmask) and $dst_cond |;
     
    my $traceroute  = get_traceroute($trace_cond, \%params);
    $data->{traceroute} = $traceroute->{traceroute} 
                              if($traceroute && $traceroute->{traceroute} && 
			         ref $traceroute->{traceroute} &&  %{$traceroute->{traceroute}}); 
    my $rev_traceroute;
    if($params{dst_ip}) {
        my $rev_trace_cond =  qq|  md.dst_ip = inet6_pton('$params{src_ip}')  and  md.src_ip = inet6_pton('$params{dst_ip}') |;
	$rev_traceroute  = get_traceroute($rev_trace_cond, \%params);					      
        $data->{reverse_traceroute} = $rev_traceroute->{traceroute} 
	                                  if($rev_traceroute && $rev_traceroute->{traceroute} && 
					     ref $rev_traceroute->{traceroute} &&  %{$rev_traceroute->{traceroute}});
    }	
   
    my $pm  =   new Parallel::ForkManager(config->{max_threads});
    ### snmp data for each hop - all unique hop IPs
    my %allhops = (%{$traceroute->{hops}}, %{$rev_traceroute->{hops}});
    
    $data->{snmp} = get_snmp(\%allhops, \%params, $pm );
    # end to end data  stats if available
    return $data unless $params{src_ip} && $params{dst_ip};
    ##foreach my $e2e (qw/pinger bwctl owamp/) {
    my $e2e_sql = qq|select   m.metaid, n_src.ip_noted as src_ip, m.subject, s.type,  n_dst.ip_noted  as dst_ip, 
                                                          n_src.nodename as src_name, n_dst.nodename as dst_name, s.url, s.service
	                                               from 
						        	  metadata m
					        	    join  node n_src on(m.src_ip = n_src.ip_addr) 
							    join  node n_dst on(m.dst_ip = n_dst.ip_addr) 
							    join service s  on (m.service = s.service)
						      where  
							    inet6_mask(m.src_ip, n_src.netmask) = inet6_mask(inet6_pton('$params{src_ip}'), n_src.netmask) and
							    inet6_mask(m.dst_ip, n_dst.netmask) = inet6_mask(inet6_pton('$params{dst_ip}'), n_dst.netmask) and
							    s.type in ('pinger','bwctl','owamp') and
							    s.url  like 'http%'
					         group by src_ip|;
    ### debug " E2E SQL:: $e2e_sql";
    my $md_href =  database->selectall_hashref($e2e_sql, 'metaid');   
    ###debug " MD for the E2E ::: " . Dumper $md_href;	
    				  
    return $data  unless $md_href && %{$md_href};
    foreach my $e_type (qw/bwctl/)  {
        my %md_rows =   map {  $_ =>  $md_href->{$_}  if  $md_href->{$_}{type} eq $e_type  }    keys %{$md_href};
	next unless  %md_rows;
	if($e_type eq 'pinger') {
            get_pinger( $data,   \%params,  \%md_rows );
	} elsif($e_type eq 'bwctl') {
	    get_bwctl( $data , 'src_ip', \%params, \%md_rows   );
	    get_bwctl( $data,  'dst_ip', \%params, \%md_rows   );
	} elsif($e_type  eq 'owamp') {
	    get_owamp( $data, 'src_ip', \%params,  \%md_rows  );
	    get_owamp( $data, 'dst_ip', \%params,  \%md_rows );
	}
    }
    $pm->wait_all_children;
    return $data;
}

#
#  get bwctl  data for end2end, first for the src_ip, then for the dst_ip
#
sub get_bwctl {
    my ( $data_hr,  $params, $md_href ) = @_; 
    my %result = ();
    foreach my $metaid  ( keys %{$md_href} ) {
       my  $md_row =  $md_href->{$metaid};
       debug " ------ FOUND BWCTL md  $metaid:::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} ";
       my @datas = dbix->resultset('Bwctl_data')->search({ metaid => $metaid, 
                                                           timestamp => { '>=' => $params->{start}, '<=' => $params->{end}}  });
       my $end_time = -1; 
       my $start_time =  40000000000;
       foreach my $datum (@datas) {
	   push @{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}}, { timestamp   => $datum->timestamp,
	                                         meanRtt     => $datum->meanRtt,     
	                                         medianRtt   => $datum->medianRtt,
					         iqrIpd      => $datum->iqrIpd,
					         lossPercent => $datum->lossPercent,
					         maxRtt      => $datum->maxRtt, 
					         minRtt      => $datum->minRtt 
					       };
	   $end_time =   $datum->timestamp if $datum->timestamp > $end_time;
	   $start_time =  $datum->timestamp if  $datum->timestamp < $start_time;
       } 
    }
    $data_hr->{bwctl} = \%result;
    return $data_hr;
}

#
#  get pinger data for end2end, first for the src_ip, then for the dst_ip
#
sub get_pinger {
   my ( $data_hr,  $params, $md_href ) = @_; 
   my %result = ();
   # we have several pinger metadata for some matched pairs
   #
   no warnings;
   foreach my $metaid  ( keys %{$md_href} ) {
       my  $md_row =  $md_href->{$metaid};
       debug " ------ FOUND PINGER md  $metaid:::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} ";
       my @datas = dbix->resultset('Pinger_data')->search({ metaid => $metaid, 
                                                            timestamp => { '>=' => $params->{start}, '<=' => $params->{end}} 
   							 });
       my $end_time = -1; 
       my $start_time =  40000000000;
       foreach my $datum (@datas) {
	   push @{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}}, { timestamp   => $datum->timestamp,
	                                         meanRtt     => $datum->meanRtt,     
	                                         medianRtt   => $datum->medianRtt,
					         iqrIpd      => $datum->iqrIpd,
					         lossPercent => $datum->lossPercent,
					         maxRtt      => $datum->maxRtt, 
					         minRtt      => $datum->minRtt 
					       };
	   $end_time =   $datum->timestamp if $datum->timestamp > $end_time;
	   $start_time =  $datum->timestamp if  $datum->timestamp < $start_time;
       } 
       debug "PINGER::  Times: start= $start_time  start_dif=" . ($start_time - $params->{start}) . 
   		 "... end=$end_time   end_dif=" . ( $params->{end} -  $end_time );
       if( !%result || !@{$result{$md_row->{src_ip}}{$md_row->{dst_ip}} } || 
	   ( $end_time  < ($params->{end} - 1800) ||
   	     $start_time> ($params->{start} + 1800) ) ) {
             @{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}} = ();
   	     eval {
   		$md_row->{url} =~ s|pinger/mp|pinger/ma|;
   		debug " params to ma: ip=" .  $md_row->{url} . " . start=$params->{start} end=$params->{end} ";
		my $ma =  Ecenter::Data::PingER->new({ url =>  $md_row->{url} });
		$md_row->{subject} =~ s/nmwgt:subject/pinger:subject/gxm; 
		$md_row->{subject} =~ s|<pinger:subject |<pinger:subject xmlns:pinger="http://ggf.org/ns/nmwg/tools/pinger/2.0/"  xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/" |;
		my $pinger_subject = MetaSubj->new( { xml =>  $md_row->{subject} } );
		
		my $request = { 
   	 		         subject =>  $pinger_subject->asString,
   	 		         start =>  DateTime->from_epoch( epoch =>  $params->{start}),
   	 		         end =>  DateTime->from_epoch( epoch => $params->{end}),
   	 		         cf => 'AVERAGE',
   	 		         resolution => '100',
   	 		       };
   		$ma->get_data($request);
   		### debug "MA Data :: " .Dumper( $ma->data);
   		if($ma->data && @{$ma->data}) {
   	     	    foreach my $ma_data (@{$ma->data}) { 
			my $sql_datum = {  metaid => $metaid,  timestamp => $ma_data->[0]};
			foreach my $data_id (keys %{$ma_data->[1]}) {
		            $sql_datum->{$data_id} = $ma_data->[1]{$data_id};
			}
   	 		dbix->resultset('Pinger_data')->update_or_create( $sql_datum,  { key => 'meta_time'}  );
   	 	     }
   		}
   	     };
   	     if($EVAL_ERROR) {
   		 error " Remote MA  " .  $md_row->{url} . " failed $EVAL_ERROR";
   		 return $data_hr;
   	     }
	}
  
	unless (@{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}} ) {
 	     my @datas = dbix->resultset('Pinger_data')->search({ metaid => $metaid, 
	                                                	 timestamp => { '>=' => $params->{start}, '<=' => $params->{end}} 
         						       });
            map {  push   @{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}}, { timestamp   => $_->timestamp,
	                                                   medianRtt   => $_->medianRtt,
							   iqrIpd      => $_->iqrIpd,
							   lossPercent => $_->lossPercent,
	                                                   meanRtt     => $_->meanRtt,
							   maxRtt      => $_->maxRtt,
							   minRtt      => $_->minRtt
							  } } @datas;
	}
	debug "PINGER - " .$md_row->{src_ip}  ;
    }
    $data_hr->{pinger} = \%result;
    return $data_hr;
}
#
#   process traceroute data
#
sub get_traceroute {
    my ($trace_cond, $params) = @_;
    my %traces = ();
    my %hops = ();
    my $trace_date_cond = ' ( 1 ';
    $trace_date_cond .= $params->{start}?" AND td.updated >= $params->{start}":'';  
    $trace_date_cond .= $params->{end}?" AND td.updated <= $params->{end}":'';
    $trace_date_cond .= ') '; 
     ############################    $trace_date_cond and   ------ ADD BACK WHEN TRACEROUTE WILL BE AVAILABLE !!!!!!!!!!!!!!!
    my $trace_ref = database->selectall_hashref(qq|select  distinct td.updated, td.trace_id, md.metaid, td.number_hops,
                                                             h.hop_id, h.hop_delay, inet6_ntop(h.hop_ip) as hop_ip, h.hop_num,  hb.hub, hb.longitude, hb.latitude  
					             from
						            hop h 
						       join traceroute_data td    using(trace_id) 
						       join metadata        md    using(metaid) 
						       join node            n_src on(md.src_ip = n_src.ip_addr)
						       left join node       n_dst on(md.dst_ip = n_dst.ip_addr)
						       join node       n_hop on(h.hop_ip  = n_hop.ip_addr)     	
						       left  join l2_l3_map llm on(inet6_mask(n_hop.ip_addr, n_hop.netmask) = inet6_mask(llm.ip_addr, n_hop.netmask)) 
     	                                               left  join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
     	                                               left  join hub hb using(hub) 
						     where  
						             $trace_cond
						     order by   h.hop_id asc|, 'hop_id');
    foreach my $hop_id (sort {$a<=>$b} keys %$trace_ref) {
        push @{$traces{$trace_ref->{$hop_id}{trace_id}}}, $trace_ref->{$hop_id};
	$hops{$trace_ref->{$hop_id}{hop_ip}} = $trace_ref->{$hop_id}{hop_id} 
	                                            if !(exists $hops{$trace_ref->{$hop_id}{hop_ip}}) ||
	                                                $hops{$trace_ref->{$hop_id}{hop_ip}} < $trace_ref->{$hop_id}{hop_id};
    }
    ### debug  "Traceroutes:" . Dumper(\%traces);
    return {traceroute => \%traces, hops => \%hops};
}
#
#    for the list of hop IPs get SNMP data localy or remotely
#

sub get_snmp {
    my ($hops_ref, $params, $pm) = @_;
    my %snmp=(); 
    my $date_cond = ' ( 1 ';
    $date_cond .= $params->{start}?" AND sd.timestamp >= $params->{start}":'';  
    $date_cond .= $params->{end}?" AND sd.timestamp <= $params->{end}":'';
    $date_cond .= ') and';
    ### debug "SNMP:: hops::" .  Dumper($hops_ref);
    foreach my $hop_ip (keys %{$hops_ref}) {
        my $data_ref =  _get_snmp_from_db($hop_ip, $date_cond);
						 
        ## debug "SNMP:: DATA1::" .  Dumper($data_ref); 
        ### no data, no problem, get any data and send remote request 
	unless($data_ref && %{$data_ref}) {
	    $data_ref =    _get_snmp_from_db($hop_ip,' ');
	    ###debug "---- SNMP:$hop_ip: DATA2::" .  Dumper($data_ref); 
	}
        my $packed =   _pack_snmp_data($data_ref);
	$snmp{$hops_ref->{$hop_ip}} = $packed->{data};
	 
	debug "SNMP::  Times: start= $packed->{start_time} start_dif=" . ($packed->{start_time} - $params->{start}) . 
	                     "... end=$packed->{end_time} end_dif=" . ( $params->{end} - $packed->{end_time});
	
		     
     	##################### no metadat, skip
	next if $packed->{end_time} < 0 &&   $packed->{start_time} == 4000000000;
	# if we have difference on any end more than 30 minutes  then run remote query
	if ( $packed->{end_time}  < ($params->{end} - 1800) ||
	     $packed->{start_time}> ($params->{start} + 1800) ) {
	      my (undef, $request_params) = each(%$data_ref);
	      $snmp{$hops_ref->{$hop_ip}} = [];
	      foreach my $direction (qw/in out/) {
	 	    my $pid = $pm->start and next; 
		     eval {
		        debug " params to ma: ip=$request_params->{snmp_ip} start=$params->{start} end=$params->{end} ";
			my $snmp_ma =  Ecenter::Data::Snmp->new({ url =>   $request_params->{url} });
     	 		$snmp_ma->get_data({ direction =>  $direction, 
	 				     ifAddress =>  $request_params->{snmp_ip}, 
	 				     start =>  DateTime->from_epoch( epoch =>  $params->{start}),
	 				     end =>  DateTime->from_epoch( epoch => $params->{end}),
					     cf => 'AVERAGE',
					     resolution => '300',
					  });
	 		#debug "Data :: " .Dumper( $snmp_ma->data);
     	 		if($snmp_ma->data && @{$snmp_ma->data}) {
			    foreach my $data (@{$snmp_ma->data}) { 
     	 		        dbix->resultset('Snmp_data')->update_or_create({  metaid => $request_params->{metaid},
     	 							                  timestamp => $data->[0],
     	 							                  utilization => $data->[1],
     	 						  		       },
	 								       { key => 'meta_time'}
									       );
     	 	             }
			} 
		     };
		     if($EVAL_ERROR) {
		         error " Remote MA   $request_params->{url} failed $EVAL_ERROR";
			 $pm->finish;
		     }
	 	  $pm->finish;
     	     }
	}
    }
    ### debug "   Data  :: " .Dumper( \%snmp);
    $pm->wait_all_children;
    foreach my $hop_ip  (keys %{$hops_ref}) {
       ### debug "Data for ip=$hop_ip hop_id=$hops_ref->{$hop_ip}:: " . Dumper( $snmp{$hops_ref->{$hop_ip}});
       next if $snmp{$hops_ref->{$hop_ip}} && @{$snmp{$hops_ref->{$hop_ip}}}>0;
       my $packed = _pack_snmp_data(_get_snmp_from_db($hop_ip, $date_cond));
       $snmp{$hops_ref->{$hop_ip}} = $packed->{data};
    }
    return \%snmp;
}
#
#   pack snmp data into the array and get start/end times
#

sub _pack_snmp_data {
    my ($data_ref) = @_;
    my $end_time = -1;
    my @result = ();
    my $start_time =  4000000000; 
    foreach my $time (sort {$a<=>$b} keys %$data_ref) { 
	push @result,   
	            {timestamp => $time, capacity => $data_ref ->{$time}{capacity},  utilization => $data_ref ->{$time}{utilization} };
	$end_time = $time if $time > $end_time;
	$start_time = $time if $time < $start_time;
    }
    return { data => \@result, start_time => $start_time, end_time => $end_time };
}
#
#  get snmp data from the database with some conditions
#
sub _get_snmp_from_db{
   my ($hop_ip,  $date_cond) = @_;
   my $data_ref =  database->selectall_hashref(qq|select  inet6_ntop(m.src_ip) as snmp_ip,m.metaid, m.src_ip, s.url, s.service,  
                                                          l2.capacity,  sd.timestamp, AVG(sd.utilization) as utilization  
	                                               from 
						        	  snmp_data sd 
					        	    join  metadata m  on(sd.metaid = m.metaid) 
                                                	    join  node n on(m.src_ip = n.ip_addr) 
							    join  l2_l3_map llm on(m.src_ip = llm.ip_addr) 
							    join  l2_port l2 using(l2_urn) 
							    join  hub h using(hub) 
							    join service s on (m.service = s.service)
						      where 
						            $date_cond
							    inet6_mask(m.src_ip,n.netmask) = inet6_mask(inet6_pton('$hop_ip'), n.netmask)
						       group by sd.timestamp|,
						 'timestamp');
    return  $data_ref;
}
#---------------------------------------------------------------
dance;
