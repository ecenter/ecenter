#!/usr/bin/perl -w

use strict;
use warnings;

=head1 NAME

data_worker.pl -  Gearman based collection of various workers to get data from the  ECenter DB

=head1 DESCRIPTION

 Gearman based worker to get data from the  ECenter DB. It connects to the gearmand and then sends requests
 to the local DB data cache or to the remote pS-PS services. Returns data encoded in JSON. Accepts request
 in JSON as well.

=head1 SYNOPSIS

 run as ./data_worker.pl --host=localhost &
 
=head1 OPTIONS

=over

=item --debug

debugging info logged, check corresponded logger.conf file

=item --host=<hostname|localhost>

hostname of the server where db is located
Default: localhost

=item --g_host=<hostname|localhost>

hostname of the server where gearmand is running
Default: localhost

=item --port=<port number>

port to connect to gearmand
Default: 10221

=item --period=<time period in seconds>

time period to check if we have complete data cached in the DB
Default: 1800 seconds from the start and 1800 from the end of the request time slice

=item --timeout=<time period in seconds>

time period to timeout call to the remote perfSONAR-PS service
Default: 120 seconds
   
=item --help

print help, usage

=item --metrics

log remote call performance response
Default: not set

=item -db=[database name]

local backend DB name
Default: ecenter_data


=item --user=[db username]

local backend DB username
Default: ecenter

=item --pass=[db password]

local backend DB password   
Default: read from /etc/my_ecenter

=back

=cut

use FindBin;
use lib  ("$FindBin::Bin/topo_lib", "$FindBin::Bin");

use Gearman::Worker;
use Gearman::Client;
use Ecenter::DB;
###use Ecenter::Schema;
use Getopt::Long;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use POSIX qw(strftime :sys_wait_h);
use Pod::Usage;
use Ecenter::Utils;
use Ecenter::Data::Snmp;
use Ecenter::Data::PingER;
use Ecenter::Data::Bwctl;
use Ecenter::Data::Owamp;
use Ecenter::Data::Traceroute;
use JSON::XS;
use English qw(-no_match_vars);
use Log::Log4perl qw(:easy);
use DBI;

my $DATA = { bwctl	=> {table => 'BwctlData',   class => 'Bwctl',      data => [qw/throughput/]},
     	     owamp	=> {table => 'OwampData',   class => 'Owamp',      data => [qw/sent loss min_delay max_delay duplicates/]},
     	     pinger	=> {table => 'PingerData',  class => 'PingER',     data => [qw/meanRtt maxRtt medianRtt minRtt maxIpd meanIpd minIpd iqrIpd lossPercent/]},
     	     traceroute => {table => 'HopData',     callback  => \&process_trace,
	                                            db_callback => \&process_db_trace,
	                                            class => 'Traceroute',  data => [qw/hop_ip hop_num hop_delay/]},
     	   };
my %OPTIONS;
my @string_option_keys = qw/port host g_host pass user db period timeout/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help metrics/,
) or pod2usage(1);
my $output_level = $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(-verbose => 2) if ( $OPTIONS{help} || ($OPTIONS{procs} && $OPTIONS{procs} !~ /^\d\d?$/));

my $worker = new Gearman::Worker;
$OPTIONS{host} ||= 'ecenterprod1.fnal.gov';
$OPTIONS{g_host} ||= 'xenmon.fnal.gov';

$OPTIONS{port} ||= 10221;
$OPTIONS{user} ||= 'ecenter';
$OPTIONS{period} ||= 1800;
$OPTIONS{timeout} ||= 120;
$OPTIONS{db} ||= 'ecenter_data';
my $ready = 0;
my $pid;
my %WORKERS= ();
local $SIG{USR1} = 'IGNORE';
local $SIG{PIPE} = 'IGNORE';
local $SIG{CHLD} = 'IGNORE';

unless($OPTIONS{pass}) {
    $OPTIONS{pass} = `cat /etc/my_ecenter_$OPTIONS{host}`;
    chomp $OPTIONS{pass};
} 
$worker->job_servers( "$OPTIONS{g_host}:$OPTIONS{port}" );
##   -try to get local data and then send request for remote data if no data
$worker->register_function("dispatch_data" => \&dispatch_data);
##   - get local data
$worker->register_function("get_data"  => \&get_data);
## - get remote data
$worker->register_function("get_remote_data"   =>  \&get_remote_data);
## - get remote snmp data   
$worker->register_function("get_remote_snmp"  =>  \&get_remote_snmp);
## - get remote snmp data   
$worker->register_function("get_dbi_data"  =>  \&get_dbi_data);
#
$worker->register_function("dispatch_snmp" => \&dispatch_snmp);
while (1) {
   $worker->work();
}

#
#  get data from the local Db, accepts json encoded request, sends json back
#  works with DBI db handler
#
sub get_dbi_data {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my $dbh  = _initialize($request,'dbh',  qw/cmd  key/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    my $result = {status => 'ok', data => []};
    $result->{data} = $dbh->selectall_hashref($request->{cmd}, $request->{key});
    return encode_json $result;
}
#
#  get data from the local Db, accepts json encoded request, sends json back
#
sub get_data  {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my $dbh  = _initialize($request,'dbic',  qw/metaid  table  start end/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    my $result = {status => 'ok', data => []};
    push @{$result->{data}}, 
             $dbh->resultset($request->{table})->search({ metaid =>  $request->{metaid},
                                                          timestamp => { '>=' => $request->{start},
							                 '<=' => $request->{end}
								      }
						       });
    return encode_json $result;
}
#
#   get db handler and validate params from the json arg
#  what_db => ['dbic','dbh']
#
sub _initialize {
    my ($request, $what_db,  @names) = @_;
    if($request && ref $request eq ref {}) {
        map {return  " Empty or malformed request - missing -  $_" 
	                         unless $_ eq 'start' ||  $request->{$_}}
	    @names if @names;
    } else {
       return ' Empty or malformed request ';
    }
    my $dbh;
    if($what_db eq 'dbic') {
        eval {
            $dbh =  Ecenter::DB->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};",$OPTIONS{user},$OPTIONS{pass},
                                     {RaiseError => 1, PrintError => 1});
        };
        if($EVAL_ERROR) {
            $logger->error("DB init failed with $EVAL_ERROR");
	    return "DB init failed with $EVAL_ERROR";
        }
        $dbh->storage->debug(1) if $OPTIONS{debug};
    } elsif($what_db eq 'dbh') {
        $dbh =  DBI->connect("DBI:mysql:database=$OPTIONS{db};hostname=$OPTIONS{host};",$OPTIONS{user},$OPTIONS{pass},
                                    {RaiseError => 1, PrintError => 1}) or return "DB error $DBI::errstr";
    } else {
        return 'Malformed request - wrong Db parameter';
    }
    return $dbh;
#
#  send remote request, store data into the db and sends json back
#  accepts request as json encoded structure: 
#      {metaid=>string,md_row=>{},type=>string,start=>timestamp,end=>timestamp,resolution=>number}
#
sub get_remote_data  {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my $dbh  = _initialize($request, 'dbic', qw/metaid table md_row start end resolution type/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    return _get_remote_data($request, $dbh);
}}
#
#  send remote request, store data into the db and sends json back
#  accepts request as json encoded structure: 
#      {metaid=>string,md_row=>{},type=>string,start=>timestamp,end=>timestamp,resolution=>number}
#
sub get_remote_snmp  {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my $dbh  = _initialize($request, 'dbic', qw/service start end/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    return  _get_remote_snmp($request, $dbh);
}
#
#  send remote request, store data into the db and sends json back
#  accepts request as json encoded structure: 
#      {metaid=>string,md_row=>{},type=>string,start=>timestamp,end=>timestamp,resolution=>number}
#
sub _get_remote_data  {
    my ($request, $dbh) = @_;
    my $result = {status => 'ok', data => [] };
    my $t1 = time();
    my $t_delta = 0;
    eval {
        my $ma =  ("Ecenter::Data::$DATA->{$request->{type}}{class}")->new({ url =>  $request->{md_row}{service} , timeout => $OPTIONS{timeout}});
        my $ns = $ma->namespace;
        my $nsid = $ma->nsid;
	my $subject = $request->{md_row}{subject};
        $subject =~ s/nmwgt:subject/$nsid:subject/gxm;
        $subject =~ s|<$nsid:subject |<$nsid:subject xmlns:$nsid="$ns" xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/" |xm
	               if  $request->{type} =~ /traceroute|pinger/; ### pinger has no ns definition in the md
	# fix for short time periods because bwctl only runs every 4 hours or even less frequently
	$logger->debug("SUBJECT::::::::: $subject");
        my $ma_request = {
        		subject =>  $subject,
        		start   =>  DateTime->from_epoch( epoch =>  $request->{start}),
        		end     =>  DateTime->from_epoch( epoch =>  $request->{end}),
###			resolution =>  $request->{resolution},
        	      };
	$ma->get_data($ma_request);
	$t_delta = time() - $t1;
	$logger->info("$request->{md_row}{service} $request->{md_row}{src_hub}-$request->{md_row}{dst_hub} - $request->{type} - Entries=" . @{$ma->data});
        $logger->debug("$request->{md_row}{service} MA - $request->{type} - Entries=", sub {Dumper($ma->data)});
	if($ma->data && @{$ma->data}) {
	    eval {
	        $dbh->resultset('ServicePerformance')->find_or_create( { metaid =>  $request->{metaid},
	                                                     requested_start => $request->{start},
	                                                     requested_time => ($request->{end}- $request->{start}),
	                                                     response => $t_delta,
							     is_data => 1} ) if $OPTIONS{metrics} && 
							                        $t_delta > 20 &&  $request->{type} =~ /owamp|pinger/i;
	    };
	    
	    $logger->debug('..process data...traceroutes found =' . @{$ma->data});
	    foreach my $ma_data (@{$ma->data}) {
                my $sql_datum = {  metaid => $request->{metaid},  timestamp => $ma_data->[0]};
                foreach my $data_id (keys %{$ma_data->[1]}) {
        	    $sql_datum->{$data_id} = $ma_data->[1]{$data_id};
                }
		#    ----------   post-processing callback - if exists
	        if(exists  $DATA->{$request->{type}}{callback} &&
		 	ref $DATA->{$request->{type}}{callback} eq ref sub{}) {
		    $DATA->{$request->{type}}{callback}->($dbh, $sql_datum, $result);
		} else {
		    push @{$result->{data}}, [$ma_data->[0], $sql_datum];
		}
                eval {
		   $dbh->resultset($request->{table})->find_or_create( $sql_datum, { key => 'meta_time'} );
		};
		if($EVAL_ERROR) {
		    $logger->error("Insertion data failed...$EVAL_ERROR");
		}
            }
        }
    };
    if($EVAL_ERROR) {
         $logger->error(" remote call failed - $EVAL_ERROR  ");
	 $result->{status} = 'error';
	 $result->{data} =  " remote call failed - $EVAL_ERROR ";
    } 
    eval {
       $dbh->resultset('ServicePerformance')->find_or_create( { metaid =>  $request->{metaid},
	                                             requested_start => $request->{start},
	                                             requested_time => ($request->{end}- $request->{start}),
	                                             response => $t_delta,
						     is_data => 0} )
        if  $OPTIONS{metrics} &&  
	   ($EVAL_ERROR || !@{$result->{data}}) && $t_delta > 20 &&  $request->{type} =~ /owamp|pinger/i;
    };
    $logger->info("..Done processing data...");
    return  $result;
}
#
#  wrapped remote call to SNMP MA
#
sub _get_remote_snmp {
    my ($request, $dbh) = @_;
    my $snmp_ma;
    my $result = {status => 'ok', data =>  { in => {}, out => {}}};
    eval {
	$snmp_ma =  Ecenter::Data::Snmp->new({ url => $request->{service} });
	my $meta_cond = {
    	    		   start     =>  DateTime->from_epoch( epoch =>   $request->{start}),
    	    		   end       =>  DateTime->from_epoch( epoch =>  $request->{end}), 
			   resolution => 5,
	    		 }; 
	$meta_cond->{direction} = $request->{direction} 
	    if $request->{direction};
     	if($request->{snmp_ip}) {
     	    $meta_cond->{ifAddress} =  $request->{snmp_ip};
        } else {
     	    $meta_cond->{urn} = $request->{urn};
        }
	$snmp_ma->get_data( $meta_cond );
    };
    if($EVAL_ERROR) {
	$logger->error(" Remote MA --  $request->{service} failed $EVAL_ERROR");
        $result->{status} = 'error';
        $result->{data} = " Remote MA -- $request->{service} failed $EVAL_ERROR";
	return encode_json  $result;
    } 
    #   $logger->info("$request->{service} :: SNMP Data=", sub {Dumper($snmp_ma->data)});
   #  $logger->info("$request->{service} :: SNMP DataN=" . scalar @{$snmp_ma->data});
    my $data_arr = $snmp_ma->data;
    if($data_arr && @{$data_arr}) {
        foreach my $direction (0,1) {
	    foreach my $data (@{$data_arr->[$direction]}) {
		eval {
	             my $datum = {  timestamp => $data->[0],
			            utilization => $data->[1],
				    errors => $data->[2],
				    drops => $data->[3]
				 };
		     if($request->{snmp_ip} && $request->{metaid}) {
			 $datum->{metaid} = $request->{metaid};
			 $dbh->resultset($request->{table})->find_or_create( $datum,   {key => 'meta_time'}  );
		     }
		     $datum->{capacity} = $data->[4];
		     $datum->{direction} = $direction?'out':'in';
	             $result->{data}{$datum->{direction}}{$data->[0]} = $datum;

		};
		if($EVAL_ERROR) {
		   $logger->error("  Some error with insertion    $EVAL_ERROR");
		}
            }
        }
    }
    return encode_json $result;
}
#
#   snmp from local db - spawns more parallel requests
#
sub _get_snmp_from_db{
    my ($dbh,  $request) = @_;
    my $end_time = -1;
    my $start_time =  4000000000;
    my $ip_quoted = $dbh->quote($request->{snmp_ip});
    my $direction_sql = $request->{direction}?" and m.direction = '$request->{direction}' ":" and 1 ";
    my $cmd = qq|select   n.ip_noted  as snmp_ip, m.metaid as metaid, m.direction, s.service, l2.capacity
	          from
		  	     metadata m
                       join  node n on(m.src_ip = n.ip_addr) 
		       join  l2_l3_map llm on(m.src_ip = llm.ip_addr) 
		       join  l2_port l2 on(llm.l2_urn = l2.l2_urn) 
		       join  eventtype e on (m.eventtype_id = e.ref_id)
		       join  service s on (e.service = s.service)
		  where 
		       e.service_type = 'snmp' and
		       n.ip_noted =   $ip_quoted
		       $direction_sql
		  |;
    my $md_href = $dbh->selectall_hashref( $cmd, 'metaid');
    $logger->debug("---------SNMP DB::", sub{Dumper($md_href)});
    return  {data => { in => {}, out => {}}, md => $md_href, start_time => $start_time, end_time => $end_time} unless $md_href && %{$md_href};
    my $mds = join(",", map {$dbh->quote($_)}  keys %{$md_href});
    $cmd = qq|select distinct  CONCAT(sd.timestamp,  m.direction) as data_id, m.metaid,  sd.timestamp as timestamp,
                                              sd.utilization as utilization,   sd.errors as errors, sd.drops as drops
	                              from
			  	       $request->{table} sd
                        	       join   metadata m on(sd.metaid = m.metaid)
				       where
			  		   sd.timestamp >=  $request->{start} and
			  		   sd.timestamp <= $request->{end}  and
			  		   m.metaid IN ($mds)|;
    my $data_ref =  $dbh->selectall_hashref( $cmd, 'data_id');
    my $result_data = {};
    if($data_ref) {    
        foreach my $data_id (grep {$_} keys %{$data_ref}) {
	    my $time    = $data_ref->{$data_id}{timestamp};
	    my $metaid = $data_ref->{$data_id}{metaid};
	    my $direction = $md_href->{$metaid}{direction};
	    $end_time   = $time if  $time > $end_time;
	    $start_time = $time if  $time < $start_time;
	    map { $result_data->{$direction}{$time}{$_} = $data_ref->{$data_id}{$_}} qw/metaid drops errors utilization/;
	    $result_data->{$direction}{$time}{capacity} = $md_href->{$metaid}{capacity};
	}
    }
    return  {data =>  $result_data, md => $md_href, start_time => $start_time, end_time => $end_time};
}
#
#  call to get local data and if not there then call remote snmp service
#
sub dispatch_snmp {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my %snmp=();
    my $dbic  = _initialize($request, 'dbic');  
    my $dbh  = _initialize($request, 'dbh', qw/table  class start end/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    my $result = {status => 'ok', data => []};
    
    my $data_ref    = _get_snmp_from_db($dbh, $request);
    my $requested_param  = $request->{snmp_ip}?$request->{snmp_ip}:$request->{urn};
    
    $logger->info("---------SNMP:: IP=$requested_param  Found Times: start= $data_ref->{start_time} start_dif=" .
                   ($data_ref->{start_time} - $request->{start}) .
    	           "... end=$data_ref->{end_time} end_dif=" . ( $request->{end} - $data_ref->{end_time}));
    ##################### no metadata, skip
    return encode_json  $result  unless  $data_ref && %{$data_ref->{md}};
    # if we have difference on any end more than 30 minutes  then run remote query
    if ($data_ref->{end_time} < 0 || 
           abs($data_ref->{start_time} - $request->{start}) > $OPTIONS{period} ||
           abs($data_ref->{end_time}  - $request->{end}) > $OPTIONS{period}
    	) {
    	my (undef, $request_params) = each(%{$data_ref->{md}});
	###$logger->info("params to ma: ip=$request_param_md start=$request->{start} end=$request->{end} ");
	my $remote_request = { table  => $request->{class},
				   service => $request_params->{service},
				   metaid => $request_params->{metaid},
				   start => $request->{start},
				   end => $request->{end}}; 
	if($request->{snmp_ip}) {
	    $remote_request->{snmp_ip} = $request_params->{snmp_ip};
	} else {
	    $remote_request->{urn} = $request_params->{urn}; 
	}
	$remote_request->{direction} = $request->{direction} 
	    if $request->{direction} && $request->{direction} =~ /in|out/;
    	return  _get_remote_snmp($remote_request, $dbic);
    } 
    else {
        $result->{data}  =  $data_ref->{data};
    }
    return encode_json $result;
}
#
#  traceroute callback
#
sub  process_trace {
    my ($dbh, $sql_datum, $results ) = @_;
    update_create_fixed($dbh->resultset('Node'),
        			 {ip_addr =>  \"=inet6_pton('$sql_datum->{ip_noted}')"},
        			 {ip_addr => \"inet6_pton('$sql_datum->{ip_noted}')",
        			  nodename =>  $sql_datum->{ip_noted},
        			  ip_noted =>  $sql_datum->{ip_noted}}, 
				  undef); # no updates
    my %tmp = %$sql_datum;
    $tmp{hop_ip} =  ref  $tmp{hop_ip}?$tmp{hop_ip}->ip_addr:$tmp{hop_ip};
    push @{$results->{data}}, \%tmp;
    delete $sql_datum->{ip_noted};
    #delete $sql_datum->{ip_noted};
}
#  traceroute db_callback
#
sub  process_db_trace {
    my ($datum ) = @_;
    my $row={};
    $row->{hop_ip} = $datum->hop_ip->ip_addr;
    $row->{hop_num} = $datum->hop_num;
    $row->{hop_delay} = $datum->hop_delay;
    $row->{nodename} = $datum->hop_ip->nodename;
    $row->{ip_noted} = $datum->hop_ip->ip_noted;
    return $row;
    #delete $sql_datum->{ip_noted};
}
#
#  call to get local data and if not there then call remote service
#
sub dispatch_data {
    my ($job) = @_;
    my $request = decode_json $job->arg();
    my $dbh  = _initialize($request, 'dbic',   qw/metaid  md_row start table end resolution type/);
    return encode_json {status => 'error', data => $dbh} unless ref $dbh;
    my $result = {status => 'ok', data => []};
    my $time_condition = { '<=' => $request->{end}  };
    $time_condition->{'>='} = $request->{start}
        if $request->{start}; # find latest if not set
    my @datas = $dbh->resultset($request->{table})->search({ metaid =>  $request->{metaid},
                                                             timestamp =>  $time_condition
						          },
							  { rows => $request->{resolution} } );
 
    my ($start_time, $end_time) = get_datums(\@datas,  $result->{data},
                                             $DATA->{$request->{type}}{data}, 
					     $request->{type}, 
					     $request->{resolution}, 
					     $DATA->{$request->{type}}{db_callback});
    $logger->debug("$request->{type} ---  Times: start_dif=" .
                     abs($start_time - $request->{start}) .  
		   "... end_dif=" . abs( $request->{end} -  $end_time ));
    if( abs($end_time   -  $request->{end})   > $OPTIONS{period} ||
     	abs($start_time -  $request->{start}) > $OPTIONS{period} ) {
     	###@{$result->{data}} = () if    $result->{data};
     	$logger->info("$request->{type} --- params to ma: ip=$request->{md_row}{service} start= $request->{start} end= $request->{end} ");
     	my $remote_data = _get_remote_data($request, $dbh);
	if( @{$remote_data->{data}} && @{$remote_data->{data}} > @{$result->{data}} ) {
	    return encode_json $remote_data;
	}
    }
    return encode_json $result;
}


__END__

=head1 SEE ALSO

L<Getopt::Long>, L<Data::Dumper>,L<perfSONAR-PS>,L<Gearman::XS>,L<DBIx::Class>

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2011, Fermitools

All rights reserved.

=cut

