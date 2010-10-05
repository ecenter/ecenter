#!/usr/bin/perl

use Dancer;
use Dancer::Plugin::REST;
  
use English;
use Data::Dumper;
use lib "/home/netadmin/ecenter/trunk/frontend_components/ecenter_data/lib";
use DateTime;
use DateTime::Format::MySQL;

use Parallel::ForkControl;

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
use Ecenter::Data::Owamp;
use Ecenter::Data::Traceroute;
 
use aliased 'perfSONAR_PS::PINGER_DATATYPES::v2_0::pinger::Message::Metadata::Subject' => 'MetaSubj';
 
my $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
my $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;

#set serializer => 'JSON';
#set content_type =>  'application/json';
prepare_serializer_for_format;

#my $output_level = config->{debug} && config->{debug}> 0 ?$DEBUG:$INFO;
my $output_level =  $INFO;
my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
our  $logger = Log::Log4perl->get_logger(__PACKAGE__);
 
=head1 NAME

   ecenter_data.pl - standalone RESTfull service, provides interface for the Ecenter data and dispatch

=cut

##  status URL
any ['get'] =>  "/status.:format" => 
       sub {
 	       return  { status => 'ok'}
       };
any ['get'] =>  "/health.:format" => 
       sub {
 	      return get_health(params('query'));
       };
## get all hubs for src_ip/dst_ip
any ['get'] =>  "/source.:format" => 
       sub {
 	       return process_source();
       };
any ['get'] =>  "/destination/:ip.:format" => 
       sub {
 	       return process_source(src_ip => params->{ip});
       };
## get all hubs for src_ip/dst_ip
any ['get'] =>  "/hub.:format" => 
       sub {
 	       return  database->selectall_hashref( qq|select distinct hub_name, longitude, latitude from  hub|, 'hub_name');
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
sub _params_to_date {
     my %params = validate(@_, { start  => {type => SCALAR, regex => $REG_DATE, optional => 1},
		                 end    => {type => SCALAR, regex => $REG_DATE, optional => 1},
			    }
	       );
    $params{end} =  DateTime::Format::MySQL->parse_datetime( $params{end} )->epoch if $params{end};
    $params{end} ||=  time();
    $params{start} = DateTime::Format::MySQL->parse_datetime($params{start})->epoch if $params{start};
    $params{start} ||=  ($params{end}  - 12*3600);
    map { $params{$_}{end} =  $params{end};   
          $params{$_}{start} =  $params{start}
	} 
    qw/owamp pinger snmp bwctl traceroute/;
	      
    if(  ($params{end}-$params{start}) < 3600*12) {
	    my $median = $params{start} + int(($params{end}-$params{start})/2);
	    $params{bwctl}{start} = $median - 6*3600; # 6 hours
	    $params{bwctl}{end}   = $median + 6*3600; # 6 hours
    }
    return \%params;
}
# 
#
# return hash with error string for each non-healthy part of the data service
#
# 
#
#

sub get_health {
    my $params = _params_to_date(@_);
    my @services = ();
    my %health = ();
    foreach my $site (qw/anl.gov lbl.gov bnl.gov dmz.net ornl.gov slac.stanford.edu es.net/) {
        foreach my $type (qw/bwctl pinger owamp traceroute/) {
    	    my $e2e_sql = qq|select  distinct m.metaid  from metadata m
					        		join node n_src on(m.src_ip = n_src.ip_addr) 
							 	join eventtype e on(m.eventtype_id = e.ref_id)
								join service s  on (e.service = s.service)
							  where  
								n_src.nodename like '%$site%'   and
								e.service_type  = '$type' and
								s.url  like 'http%' |;
	    debug " E2E SQL:: $e2e_sql";
	    my @mds=  @{database->selectall_arrayref($e2e_sql)}; 
	    debug " MDS::" . Dumper \@mds;
	    $health{metadata}{$site}{$type}{metadata_count} = scalar @mds;
	    $health{time_period}{$type}{start} =   $params->{$type}{start};
	    $health{time_period}{$type}{end} =   $params->{$type}{end};
	    if(@mds) {
	        my $md_ins = join("','", map {$_->[0]} @mds);
		my $timekey = $type eq 'traceroute'?'updated':'timestamp';
		my $date_cond = ' ( 1 ';
                $date_cond .= $params->{$type}{start}?" AND  $timekey>= $params->{$type}{start}":'';  
                $date_cond .= $params->{$type}{end}?" AND  $timekey <= $params->{$type}{end}":'';
                $date_cond .= ')';
		my $sql = qq|select count(*) from $type\_data where metaid in  ('$md_ins') and $date_cond|;
		debug "Data::sql::$sql";
	        $health{metadata}{$site}{$type}{cached_data_count} = database->selectrow_array($sql);
	    }
	    
        }
    }
    
    # debug Dumper(\@services);
    return \%health;
}

#
# return list of destinations for the source ip or just listof source ips
#
sub process_source {
    my %params = validate(@_, {src_ip => {type => SCALAR, regex => $REG_IP, optional => 1} }); 
    my @hubs =(); 
    my $hash_ref;
    if( %params && $params{src_ip}) {
         $hash_ref =  database->selectall_hashref(
            qq|select distinct n.ip_noted, n.netmask, n.nodename, h.hub_name, h.hub, h.longitude, h.latitude  from
     	           metadata m 
	      join eventtype e on(e.ref_id=m.eventtype_id)
     	      join node n on(m.dst_ip = n.ip_addr)
         join l2_l3_map llm on(n.ip_addr = llm.ip_addr) 
         join l2_port l2p on(llm.l2_urn =l2p.l2_urn) 
         join hub h using(hub) 
     	where m.dst_ip is not NULL  and e.service_type = 'traceroute' and m.src_ip = inet6_pton('$params{src_ip}')|, 'ip_noted');
    } else {
        $hash_ref =  database->selectall_hashref(
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
#
# return list of services 
#
sub process_service {
    my %params = validate(@_, {value =>  {type => SCALAR, optional => 1}, mapping =>  {type => SCALAR, optional => 1}});
 
    
    my @services = ();
    my %search = ();
    $search{ $params{mapping} } =  $params{value}  if( %params && $params{value});
    my @rows =   dbix->resultset('Service')->search( { %search },
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
  eval {
    my %params = validate(@_, { data => {type => SCALAR, regex => qr/^(snmp|bwctl|owamp|pinger)$/, optional => 1}, 
                                id     => {type => SCALAR, regex => qr/^\d+$/, optional => 1}, 
                                src_ip => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
				src_hub => {type => SCALAR, regex => qr/^bnl|anl|ornl|lbl|fnal|slac$/i,   optional => 1}, 
                                dst_hub => {type => SCALAR, regex => qr/^bnl|anl|ornl|lbl|fnal|slac$/i,    optional => 1}, 
                                dst_ip => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		                start  => {type => SCALAR, regex => $REG_DATE, optional => 1},
		                end    => {type => SCALAR, regex => $REG_DATE, optional => 1},
				resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      }
		 );
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
    if($params{resolution}) {
        $params{resolution} =  $params{resolution} > 0 && $params{resolution} <= 100?$params{resolution}:100;
    } else {
        $params{resolution} = 50;
    }
    
    #   get epoch or set end default to NOW and start to end-12 hours
   
    my $date_params  =  _params_to_date({start => $params{start},end => $params{end}});
    map { $params{$_} = $date_params->{$_} } keys %{$date_params};
    my $trace_cond = {};
    
    if($params{src_ip}) {
        $trace_cond->{direct_traceroute}{src}  = qq| inet6_mask(md.src_ip, n_src.netmask) = inet6_mask(inet6_pton('$params{src_ip}'),   n_src.netmask) |;
        $trace_cond->{reverse_traceroute}{src} = qq| inet6_mask(md.dst_ip, n_dst.netmask ) = inet6_mask(inet6_pton('$params{src_ip}'),  n_dst.netmask ) |;
    } else {
        $trace_cond->{direct_traceroute}{src}  = qq| n_src.nodename like   '%$params{src_hub}%'  |;
        $trace_cond->{reverse_traceroute}{src} = qq| n_src.nodename like   '%$params{dst_hub}%' |;
    }
    if($params{dst_ip}) {
        $trace_cond->{direct_traceroute}{dst}   =   qq|  inet6_mask(md.dst_ip, n_dst.netmask )= inet6_mask(inet6_pton('$params{dst_ip}'),  n_dst.netmask ) |;
        $trace_cond->{reverse_traceroute}{dst}  =   qq|  inet6_mask(md.src_ip, n_src.netmask)= inet6_mask(inet6_pton('$params{dst_ip}'), n_src.netmask) |; 
    } else {
        $trace_cond->{direct_traceroute}{dst}   = qq|  n_dst.nodename like   '%$params{dst_hub}%' |;
        $trace_cond->{reverse_traceroute}{dst}  = qq| n_dst.nodename like    '%$params{src_hub}%' |;
    } 
     
    # my $dst_cond = $params{dst_ip}?"inet6_mask(md.dst_ip, 24)= inet6_mask(inet6_pton('$params{dst_ip}'), 24)":"md.dst_ip = '0'";
    ##
    ## get direct and reverse traceroutes
    ## 
    # my $trace_cond = qq|  inet6_mask(md.src_ip, 24) = inet6_mask(inet6_pton('$params{src_ip}'), 24) and $dst_cond |;
    $params{table_map} = { bwctl      => {table => 'Bwctl_data',                       class => 'Bwctl',      data => [qw/throughput/]},
   		           owamp      => {table => 'Owamp_data',                       class => 'Owamp',      data => [qw/sent loss min_delay max_delay duplicates/]},
    		           pinger     => {table => 'Pinger_data',                      class => 'PingER',     data => [qw/meanRtt maxRtt medianRtt minRtt iqrIpd lossPercent/]},
		           traceroute => {table => 'Hop', callback => \&process_trace, class => 'Traceroute', data => [qw/hop_ip   hop_num  hop_delay/]},
    		    };   
    my $traceroute = {};
    foreach my $way (qw/direct_traceroute reverse_traceroute/) {
        $traceroute->{$way}  = get_traceroute($trace_cond->{$way}, \%params);
        $data->{$way} = $traceroute->{$way} {traceroute} 
                              if($traceroute->{$way} && $traceroute->{$way}{traceroute} && 
			         ref $traceroute->{$way}{traceroute} &&  %{$traceroute->{$way}{traceroute}}); 
    }
    
    ### snmp data for each hop - all unique hop IPs
    my %allhops = (%{$traceroute->{direct_traceroute}{hops}}, %{$traceroute->{reverse_traceroute}{hops}});
    return $data unless $traceroute->{direct_traceroute}{hops} || $traceroute->{reverse_traceroute}{hops};
    eval {
        $data->{snmp} = get_snmp(\%allhops, \%params);
    }; 
    if($EVAL_ERROR) {
	error "  No SNMP data - failed $EVAL_ERROR";
	$data->{snmp} = {};
    }
     
    # end to end data  stats if available
    return $data unless $params{src_ip} && $params{dst_ip};
    my %directions = (direct => ['src_ip', 'dst_ip'], reverse => ['dst_ip', 'src_ip'] );
   
    my @data_keys = qw/bwctl owamp pinger/;
    # my @data_keys = qw/owamp/;
    my %e2e_mds = ();
    foreach my $dir (keys %directions) {
	my $e2e_sql = qq|select   m.metaid, n_src.ip_noted as src_ip, m.subject, e.service_type as type,  n_dst.ip_noted  as dst_ip, 
                                                              n_src.nodename as src_name, n_dst.nodename as dst_name, s.url, s.service
	                                        	   from 
						        	      metadata m
					        		join  node n_src on(m.src_ip = n_src.ip_addr) 
								join  node n_dst on(m.dst_ip = n_dst.ip_addr) 
								join eventtype e on(m.eventtype_id = e.ref_id)
								join service s  on (e.service = s.service)
							  where  
								inet6_mask(m.src_ip, n_src.netmask) = inet6_mask(inet6_pton('$params{$directions{$dir}->[0]}'),  n_src.netmask) and
								inet6_mask(m.dst_ip, n_dst.netmask) = inet6_mask(inet6_pton('$params{$directions{$dir}->[1]}'),  n_dst.netmask) and
								e.service_type in ('pinger','bwctl','owamp') and
								s.url  like 'http%'
					             group by src_ip, dst_ip, service, type|;
	debug " E2E SQL:: $e2e_sql";
	my $md_href =  database->selectall_hashref($e2e_sql, 'metaid');   
	#debug " MD for the E2E ::: " . Dumper $md_href;	
       
	next unless $md_href && %{$md_href};
        %e2e_mds = (%e2e_mds, %{$md_href});

	foreach my $e_type (@data_keys)  {
	    debug " ...  Running  ------------  $e_type";
	    $data->{$e_type} = {};
	    get_e2e($data,  \%params,   $md_href, $e_type );
	    debug " +++++ Done  ------------  $e_type";
	}
     }
     #debug "======================  1 SNMP is :" . Dumper($data->{snmp});
     return $data unless  %e2e_mds;
     
     foreach my $e_type (@data_keys)  {
    	 foreach my $metaid  ( keys %e2e_mds) { 
	     my  $md_row =  $e2e_mds{$metaid};  
    	     next if $md_row->{type} ne $e_type;
    	     unless ($data->{$e_type}  &&  $data->{$e_type}{$md_row->{src_ip}}{$md_row->{dst_ip}} &&  
	              @{$data->{$e_type}{$md_row->{src_ip}}{$md_row->{dst_ip}}} ) {
    		  my @datas = dbix->resultset($params{table_map}->{$e_type}{table})->search({ metaid => $metaid, 
    											      timestamp => { '>=' => $params{$e_type}{start}, '<=' => $params{$e_type}{end}} 
    											   });
    		  get_datums(\@datas, $md_row,  $data, \%params, $e_type) if @datas;
		  debug "\u$e_type- " . $md_row->{src_ip} . " Data ::" . scalar @datas if @datas; 
		 # debug "\u$e_type -----------   Data dump::" . Dumper $data->{$e_type}; 
    	     }
    	 
    	 }
     }
    
   
  };
  if($EVAL_ERROR) {
      error "data call  failed - $EVAL_ERROR";
  }
   return $data; 
}
#
# traceroute callback to post-process traceroute data after remote call and store it properly
#
sub process_trace {
  my ($sql_datum,   $metaid, $data_row) = @_;
  #
  my $trace_data = dbix->resultset('Traceroute_data')->update_or_create( {metaid => $metaid,   updated =>  $sql_datum->{timestamp}}, 
                                                                       { key => 'updated_metaid'} );
  my %hop_data  =   map {$_ => $sql_datum->{$_}} @{$data_row}; 
  my $hop_addr_obj =  dbix->resultset('Node')->find({ip_noted =>   $hop_data{hop_ip}});
  $hop_data{hop_ip} =  $hop_addr_obj->ip_addr; 
  $hop_data{trace_id} =  $trace_data->trace_id;
  dbix->resultset('Hop')->update_or_create( \%hop_data,  { key => 'trace_hop'}  );								       
   
  return $sql_datum;
}
# get timestamp and aggregate to return no more than requested data points
# and return as arrayref => [timestamp, {data_row}] 
#

sub refactor_result {
    my ($data_raw, $params) = @_;
    my $count = scalar @{$data_raw};
    my $result = [];
    #debug "refactoring..resolution=$params->{resolution}  ==  Data_raw - $count";
    if($count > $params->{resolution}) {
	my $bin = $count/$params->{resolution};
	my $j = 0;
	my $old_j = 0;
	my $count_j = 0;
	for(my $i = 0; $i < $count ; $i++) {
	    $j = int($i/$bin);
	    $result->[$j][0] += $data_raw->[$i][0];
	    map {$result->[$j][1]{$_} += $data_raw->[$i][1]{$_}} keys %{$data_raw->[$i][1]};
	    if( $j > $old_j || $i == ($count-1) ) {
	        $count_j++ if $i == ($count-1); 
	        map {$result->[$old_j][1]{$_} /= $count_j if $result->[$old_j][1]{$_} &&  $count_j } keys %{$data_raw->[$i][1]};
	        $result->[$old_j][0] = int($result->[$old_j][0]/$count_j) if   $result->[$old_j][0] &&  $count_j ;
	        $count_j = 0; 
	        $old_j = $j; 
	    }
	    $count_j++;       
	    #debug "REFACTOR: i=$i j=$j old_j=$old_j count_j=$count_j  raw=$data_raw->[$i][0]  result=$result->[$old_j][0] new=$result->[$j][0] ";
	 
	}	   
    } else {
        $result =  $data_raw;
    }
    #debug "refactoring..resolution=$params->{resolution}   ==  Data_raw - " . scalar @$result;
    return $result;
}
#
#     return data from the received datums
#
#
sub get_datums {
    my ($datas, $md_row, $result, $params, $type) = @_; 
    my $end_time = -1; 
    my $start_time =  40000000000;
    my $results_raw = [];
    my $count = 0;
    return ($start_time, $end_time) unless $datas && @{$datas}; 
    foreach my $datum (@{$datas}) {
        my %result_row = (timestamp   => $datum->timestamp);
        map {$result_row{$_} = $datum->$_ } @{$params->{table_map}{$type}{data}};
        push @{$results_raw}, [$datum->timestamp, \%result_row];
        $end_time =   $datum->timestamp if $datum->timestamp > $end_time;
        $start_time =  $datum->timestamp if  $datum->timestamp < $start_time;
    } 
    $result->{$type}{$md_row->{src_ip}}{$md_row->{dst_ip}} = refactor_result($results_raw, $params) if $results_raw && @{$results_raw};
    #fixing up resolution - only return no more than requested number of points
  
    return  ($start_time, $end_time); 
}
#
#  remote async call to any e2e MA
#
sub get_remote_e2e {
    my ( $md_row,   $params, $type, $metaid) = @_;
    eval {
        my $class =  $params->{table_map}{$type}{class};
        my $ma =  ("Ecenter::Data::$class")->new({ url =>  $md_row->{url} });
        my $ns = $ma->namespace;
        my $nsid = $ma->nsid;
	my $subject =   $md_row->{subject};
        $subject =~ s/nmwgt:subject/$nsid:subject/gxm;
        $subject =~ s|<$nsid:subject |<$nsid:subject xmlns:$nsid="$ns" xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/" |xm
	               if $type =~ /traceroute|pinger/; ### pinger has no ns definition in the md
	# fix for short time periods because bwctl only runs every 4 hours or even less frequently
	debug "SUBJECT::::::::: $subject";
        my $request = { 
        		subject => $subject,
        		start =>  DateTime->from_epoch( epoch =>  $params->{$type}{start}),
        		end =>  DateTime->from_epoch( epoch => $params->{$type}{end}),
			resolution => $params->{resolution},
        	      };
        $ma->get_data($request);
        debug "MA Data Entries="  . scalar @{$ma->data};
        if($ma->data && @{$ma->data}) {
	    debug "..process data...";
	    foreach my $ma_data (@{$ma->data}) { 
                my $sql_datum = {  metaid => $metaid,  timestamp => $ma_data->[0]};
                foreach my $data_id (keys %{$ma_data->[1]}) {
        	    $sql_datum->{$data_id} = $ma_data->[1]{$data_id};
                }
		#   ----------   post-processing callback
	        if(exists $params->{table_map}{$type}{callback} && 
		       ref $params->{table_map}{$type}{callback} eq ref sub{}) {
		    $params->{table_map}{$type}{callback}->($sql_datum, $metaid,  $params->{table_map}{$type}{data})
		} else {
                    dbix->resultset($params->{table_map}{$type}{table})->update_or_create( $sql_datum,  { key => 'meta_time'}  );
		}
            }
        }
    };
    if($EVAL_ERROR) {
        error " remote call failed - $EVAL_ERROR  ";
    }
}
#
#  get bwctl/owamp/pinger data for end2end, first for the src_ip, then for the dst_ip
#
sub get_e2e{
    my ( $data_hr,  $params,   $md_href, $type) = @_; 
    my %result = ();
    my $e2e_forker = new Parallel::ForkControl( 
    				MaxKids 		=> 9,
    			   	MinKids 		=> 3,
				ProcessTimeOut          => 60,
   				Name			=> 'E2E Forker',
   				Code			=> \&get_remote_e2e);	 
    foreach my $metaid  ( keys %{$md_href} ) {
       
        my  $md_row =  $md_href->{$metaid}; 
	debug " ------  $type md  $metaid  :::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} "; 
        next if $md_row->{type} ne $type || !$metaid;
        $logger->info(" ------ FOUND $type md =$metaid  :::  SRC=$md_row->{src_ip} DST= $md_row->{dst_ip} start=$params->{$type}{start}  end=$params->{$type}{end}");
	
        my @datas = dbix->resultset($params->{table_map}{$type}{table})->search({ metaid => $metaid, 
                                                                                  timestamp => { '>=' => $params->{$type}{start}, '<=' => $params->{$type}{end}} 
								               });
        my ($start_time, $end_time) = get_datums(\@datas, $md_row,  $data_hr, $params, $type);
        debug " Times: start_dif=" . abs($start_time - $params->{$type}{start}) .   "... end_dif=" . abs( $params->{$type}{end} -  $end_time );
	
        if(  abs($end_time - $params->{$type}{end}) > 1800 ||
   	     abs($start_time - $params->{$type}{start}) > 1800  ) {
             @{$result{$md_row->{src_ip}}{$md_row->{dst_ip}}} = ();
            debug " params to ma: ip= $md_row->{url} start=$params->{$type}{start} end=$params->{$type}{end} ";	     
   	    $e2e_forker->run($md_row, $params,  $type, $metaid);
	}
    }
    debug "cleanup...";
    $e2e_forker->cleanup() if $e2e_forker->kids();
    %{$data_hr->{$type}}  =  (%{$data_hr->{$type}}, %result) if %result;
}
#
#     get traceroute id   from the db
# 
sub  get_traceroute_ids {
  my ($trace_cond, $trace_date_cond) = @_;
  my $cmd =  qq|select  distinct td.updated, td.trace_id as trace_id, td.number_hops, count(h.hop_id) as hops
					             from
						            traceroute_data td
						       join metadata     md  using(metaid)  
						       join eventtype e  on(md.eventtype_id = e.ref_id)  
						       join node n_src on(md.src_ip = n_src.ip_addr)
						       join node n_dst on(md.dst_ip = n_dst.ip_addr)
						       left join hop h on(td.trace_id = h.trace_id)
						     where  
						          e.service_type = 'traceroute' and     $trace_cond->{src} AND $trace_cond->{dst} AND $trace_date_cond
						     order by   td.trace_id limit 1|;
    debug " TRACEROUTE SQL_ids: $cmd";					     
    my $trace_ref = database->selectall_hashref($cmd, 'trace_id');
    my ($trace_id, $trace_row) = each %$trace_ref;
    return {trace_string =>  $trace_id, trace_result => $trace_row};
} 
#
#     get traceroute md ids   from the db
# 
sub  get_traceroute_mds {
    my ($trace_cond, $trace_date_cond) = @_;
    my  $cmd =   qq|select  distinct md.metaid as metaid, md.src_ip, md.dst_ip, md.subject, s.url,s.service  from 
	                                                    metadata md 
	                                               join eventtype e on(md.eventtype_id = e.ref_id)  
						       join node n_src  on(md.src_ip = n_src.ip_addr)
						       join node n_dst  on(md.dst_ip = n_dst.ip_addr)  
						       join service s   on(s.service = e.service)
						    where  
						         e.service_type = 'traceroute' and  $trace_cond->{src} and $trace_cond->{dst} and s.url like '%raceroute%'|;
  
    debug " TRACEROUTE SQL_mds: $cmd";						     
    my $trace_ref =  database->selectall_hashref($cmd, 'metaid');
    return $trace_ref;
} 

#   process traceroute data - get it from the backend if there is no traceroutes available then send request to remote tracerouteMA
#
sub get_traceroute {
    my ($trace_cond, $params) = @_;
    my %traces = ();
    my %hops = ();
    my $trace_forker = new Parallel::ForkControl( 
    				MaxKids 		=> 20,
    			   	MinKids 		=> 5,
				ProcessTimeOut          => 60,
   				Name			=> 'E2E Traceroute Forker',
   				Code			=> \&get_remote_e2e);	 
    my $trace_date_cond = ' ( 1 ';
    $trace_date_cond .= $params->{traceroute}{start}?" AND td.updated >= $params->{traceroute}{start}":'';  
    $trace_date_cond .= $params->{traceroute}{end}?" AND td.updated <= $params->{traceroute}{end}":'';
    $trace_date_cond .= ') ';
    #
    ############################    $trace_date_cond and   ------ ADD BACK WHEN TRACEROUTE WILL BE AVAILABLE !!!!!!!!!!!!!!!
    # split it up
    my $ids_result = get_traceroute_ids($trace_cond, $trace_date_cond);
    #remote call 
    unless($ids_result->{trace_result} && $ids_result->{trace_string}  &&  $ids_result->{trace_result}{hops}) {
        my $md_traces =   get_traceroute_mds($trace_cond, $trace_date_cond);
	debug " TRACEroute MDS:" .  Dumper $md_traces;
        my ($metaid, $md_row) = each  %{$md_traces};
	return {traceroute => {}, hops => {}}  unless $md_row && ref $md_row eq ref {} && $md_row->{url};
	get_remote_e2e($md_row, $params,  'traceroute', $metaid);
        $trace_forker->cleanup() if $trace_forker->kids();
        $ids_result = get_traceroute_ids($trace_cond, $trace_date_cond);
    }
    return {traceroute => {}, hops => {}} unless $ids_result->{trace_result} && $ids_result->{trace_string}  &&  $ids_result->{trace_result}{hops};
    
    ##  get hub info for each hop in the traceroute
    my $cmd =    qq|select  distinct  h.trace_id as trace_id, n_hop.netmask,  n_hop.nodename, h.hop_id, h.hop_delay, 
                                n_hop.ip_noted as hop_ip, h.hop_num,  hb.hub, hb.longitude, hb.latitude  
					             from
						            hop h 
						       join node       n_hop on(h.hop_ip  = n_hop.ip_addr)     	
						       join l2_l3_map    llm on( n_hop.ip_addr=llm.ip_addr) 
     	                                               join l2_port      l2p on(llm.l2_urn =l2p.l2_urn) 
     	                                               join hub           hb using(hub) 
						     where  
						            h.trace_id in ('$ids_result->{trace_string}')
						     order by   h.hop_id asc|; 
    debug " TRACEROUTE SQL_hhops: $cmd";		
    my $hops_ref = database->selectall_hashref($cmd, 'hop_id');
    debug " TRACEROUTE  N=hops: $cmd";					     
    foreach my $hop_id (sort {$a<=>$b} keys %$hops_ref) {
        push @{$traces{$hops_ref->{$hop_id}{trace_id}}}, {(%{$hops_ref->{$hop_id}},%{$ids_result->{trace_result}})};
	$hops{$hops_ref->{$hop_id}{hop_ip}} = $hops_ref->{$hop_id}{hop_id} 
	                                            if $hops_ref->{$hop_id}{hop_ip} && 
						       (!(exists $hops{$hops_ref->{$hop_id}{hop_ip}}) ||
	                                                 $hops{$hops_ref->{$hop_id}{hop_ip}} < $hops_ref->{$hop_id}{hop_id}
						       );
    }
    ### debug  "Traceroutes:" . Dumper(\%traces);
    return {traceroute => \%traces, hops => \%hops};
}
#
#    for the list of hop IPs get SNMP data localy or remotely ( forked )
#

sub get_snmp {
    my ($hops_ref, $params ) = @_;
    my %snmp=(); 
    my $date_cond = ' ( 1 ';
    $date_cond .= $params->{snmp}{start}?" AND sd.timestamp >= $params->{snmp}{start}":'';  
    $date_cond .= $params->{snmp}{end}?" AND sd.timestamp <= $params->{snmp}{end}":'';
    $date_cond .= ') and';
    
    #debug "+++SNMP:: hops::" .  Dumper($hops_ref);
    my $forker = new Parallel::ForkControl( 
    			   MaxKids		   => 10,
    			   MinKids		   => 3,
			   ProcessTimeOut          => 60,
    			   Debug => 2,
    			   Name 		   => 'SNMP Forker',
    			   Code 		   => \&get_remote_snmp);
    foreach my $hop_ip (keys %{$hops_ref}) {
        my $data_ref =  _get_snmp_from_db($hop_ip, $date_cond);
        debug "----SNMP:: DATA1::$hops_ref->{$hop_ip}  $hop_ip "; 
        ### no data, no problem, get any data and send remote request 
	unless($data_ref && %{$data_ref->{data}}) {
	    $data_ref =    _get_snmp_from_db($hop_ip,' ');
	    debug "----- SNMP:$hop_ip: DATA2 -0::" .  join(" :: ", each %{$data_ref->{data}}); 
	}
        my $packed =   _pack_snmp_data($data_ref);
	$snmp{$hops_ref->{$hop_ip}} = refactor_result($packed->{data}, $params);
	 
	debug "---------SNMP::  Times: start= $packed->{start_time} start_dif=" . ($packed->{start_time} - $params->{snmp}{start}) . 
	                     "... end=$packed->{end_time} end_dif=" . ( $params->{snmp}{end} - $packed->{end_time});
     	##################### no metadata, skip
	next  unless  $data_ref && %{$data_ref->{data}};
	# if we have difference on any end more than 30 minutes  then run remote query
	if ( abs($packed->{end_time}  - $params->{snmp}{end}) >  1800 ||
	     abs($packed->{start_time} - $params->{snmp}{start}) > 1800 ) {
	      my (undef, $request_params) = each(%{$data_ref->{md}});
	      $snmp{$hops_ref->{$hop_ip}} = [];
	      foreach my $direction (qw/out/) {
	           debug " params to ma: ip=$request_params->{snmp_ip} start=$params->{snmp}{start} end=$params->{snmp}{end} ";
	           $forker->run( $request_params->{url}, $request_params->{metaid},$request_params->{snmp_ip}, $direction, $params);    
		     
     	     }
	}
    }
    debug "  Waiting for  Data...";
    $forker->cleanup() if $forker->kids();
    debug " Over .... Data  :: ";
    foreach my $hop_ip  (keys %{$hops_ref}) {
       ### debug "Data for ip=$hop_ip hop_id=$hops_ref->{$hop_ip}:: " . Dumper( $snmp{$hops_ref->{$hop_ip}});
       next if $snmp{$hops_ref->{$hop_ip}} && @{$snmp{$hops_ref->{$hop_ip}}}>0;
       my $packed = _pack_snmp_data(_get_snmp_from_db($hop_ip, $date_cond));
       $snmp{$hops_ref->{$hop_ip}} = refactor_result($packed->{data},$params);
    }
    return \%snmp;
}
#
#  wrapped remote call to SNMP MA
#
sub get_remote_snmp {
    my ($url, $metaid, $snmp_ip, $direction, $params) = @_;
    my $snmp_ma;
    my $period = ($params->{snmp}{end} - $params->{snmp}{start})/$params->{resolution};
    $period = int($period/60);
   
    eval {
	$snmp_ma =  Ecenter::Data::Snmp->new({ url =>   $url });
	$snmp_ma->get_data({ direction =>  $direction, 
			     ifAddress =>  $snmp_ip, 
			     start =>  DateTime->from_epoch( epoch =>  $params->{snmp}{start}),
			     end =>  DateTime->from_epoch( epoch => $params->{snmp}{end}),
			  #   resolution => $period,
			     resolution => 5,
			  });
    };
    if($EVAL_ERROR) {
	error " Remote MA -- $url failed $EVAL_ERROR";
    }
    return unless   $snmp_ma->data && @{$snmp_ma->data};
    debug "Data Entries=" . scalar @{$snmp_ma->data};
    if($snmp_ma->data && @{$snmp_ma->data}) {
	 foreach my $data (@{$snmp_ma->data}) { 
	     eval {
		 dbix->resultset('Snmp_data')->update_or_create({  metaid => $metaid,
							           timestamp => $data->[0],
							           utilization => $data->[1],
							    },
							    { key => 'meta_time'}
							    );
	     };
	     if($EVAL_ERROR) {
		debug  "  Some error with insertion    $EVAL_ERROR";
	     }
        }
    }
}

#
#   pack snmp data into the array and get start/end times
#

sub _pack_snmp_data {
    my ($data_ref) = @_;
    my $end_time = -1;
    my @result = ();
    my $start_time =  4000000000; 
    #debug " PACKING SNMP:::" . Dumper($data_ref);
    foreach my $time (sort {$a<=>$b} grep {$_} keys %{$data_ref->{data}}) { 
	push @result,   
	            [ $time, {capacity => $data_ref ->{md}{$data_ref ->{data}{$time}{metaid}}{capacity},  utilization => $data_ref ->{data}{$time}{utilization} }];
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
   my $cmd = qq|select   n.ip_noted  as snmp_ip, m.metaid as metaid, s.url, s.service, l2.capacity 
	                                               from 
						                  metadata m
                                                	    join  node n on(m.src_ip = n.ip_addr) 
							    join  l2_l3_map llm on(m.src_ip = llm.ip_addr) 
							    join  l2_port l2 using(l2_urn) 
							    join  eventtype e on (m.eventtype_id = e.ref_id)
							    join  service s on (e.service = s.service)
						       where 
						            e.service_type = 'snmp' and
							     m.src_ip  =  inet6_pton('$hop_ip') 
						       |;
   my $md_href =  database->selectall_hashref( $cmd, 'metaid');	
   return  {data => {}, md => $md_href} unless $md_href && %{$md_href};	
   my $mds = join("', '", keys %{$md_href});				       
   $cmd = qq|select   distinct  m.metaid,  sd.timestamp as timestamp,  sd.utilization as utilization  
	                                               from 
						            metadata m
                                                	    join snmp_data sd on(sd.metaid = m.metaid)
						      where 
						            $date_cond
							    m.metaid IN ('$mds')|;
    debug " SNMP SQL: $cmd";
    my $data_ref =  database->selectall_hashref( $cmd, 'timestamp');
    return  {data => $data_ref, md => $md_href};
}
#---------------------------------------------------------------
dance;
