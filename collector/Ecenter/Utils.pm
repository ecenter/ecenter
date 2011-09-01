package Ecenter::Utils;

use strict;
use warnings;

use forks;
use forks::shared 
    deadlock => {
    detect => 1,
    resolve => 1
};

use version;our $VERSION = qv("v1.0");
use NetAddr::IP::Util qw(ipv6_aton inet_any2n ipv4to6 isIPv4);
use Net::IPv6Addr;
use Net::CIDR;
use Data::Validate::IP qw(is_ipv4 is_ipv6);
use Data::Validate::Domain qw( is_domain is_hostname);
use Params::Validate;
use Socket;
use Socket6;
use POSIX qw(strftime);
use Net::DNS;
use English;
use Data::Dumper;
use Log::Log4perl;
use Time::HiRes qw(usleep);
use DBI;
use Params::Validate qw(:all);
use DateTime::Format::MySQL;
use base 'Exporter';


=head1 NAME

Ecenter::Utils - utilities for ecenter scripts

=head1 DESCRIPTION



=head1 SYNOPSIS

=cut

our $logger =   Log::Log4perl->get_logger(__PACKAGE__);
 
# exported functions  

our @EXPORT = qw/get_ip_name pack_snmp_data params_to_date get_shards get_datums refactor_result
                 db_connect update_create_fixed pool_control ip_ton nto_ip $DAYS7_SECS $REG_IP $REG_DATE @HEALTH_NAMES $TABLEMAP/;
 

our $DAYS7_SECS = 604800;
our $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
our $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;
our @HEALTH_NAMES = qw/nasa.gov pnl.gov llnl.gov   pppl.gov anl.gov lbl.gov bnl.gov dmz.net nersc.gov jgi.doe.gov snll.gov ornl.gov slac.stanford.edu es.net/;
our $TABLEMAP = { bwctl      => {table => 'BwctlData',  class => 'Bwctl',      data => [qw/throughput/]},
   		 owamp      => {table => 'OwampData',  class => 'Owamp',      data => [qw/sent loss min_delay max_delay duplicates/]},
    		 pinger     => {table => 'PingerData', class => 'PingER',     data => [qw/meanRtt maxRtt medianRtt maxIpd meanIpd minIpd minRtt iqrIpd lossPercent/]},
		 traceroute => {table => 'HopData',    class => 'Traceroute', data => [qw/hop_ip	hop_num  hop_delay/]},
    	       };

=head1 FUNCTIONS 
 
=head2 db_connect 

=cut

sub db_connect {
    my ($OPTIONS) = shift;
    my $dbh = DBI->connect_cached("DBI:mysql:database=$OPTIONS->{db};hostname=$OPTIONS->{host};", 
                                   $OPTIONS->{user}, $OPTIONS->{password}, {RaiseError => 1, PrintError => 1});
    $logger->logdie(" DBI connect failed:  $DBI::errstr") unless $dbh;
    return $dbh; 
}


=head2 get_shards

  get the  list of ids for the sharded table based on supplied   $param->{startTime} and  $param->{endTime} times
  returns   {dbi => \@tables, dbic => \@tables_dbic}

=cut

sub get_shards {
    my ($param, $dbh) = @_;
    unless($param && ref $param && $param->{data} && $param->{data} =~ /^snmp|owamp|pinger|bwctl|hop|anomaly$/xmis) {
        $logger->error("No shard for the absent data type");
	return;
    }
    my $startTime = $param->{start};
    $startTime ||= time();
    my $endTime   = $param->{end};
    $endTime ||= $startTime;
    
    my $list = {};
    $logger->debug("Loading data tables for time period $startTime to $endTime");
    # go through every day and populate with new months
    for ( my $i = $startTime; $i <= $endTime; $i += 86400 ) {
        my $date_fmt = strftime "%Y%m",  localtime($i);
        my $end_i = $i + 86400;
	$logger->debug("time_i=$i startime=$startTime end_time=$endTime");
	$list->{$date_fmt}{table}{dbic} = "\u$param->{data}Data$date_fmt";
        $list->{$date_fmt}{table}{dbi}  = "$param->{data}\_data_$date_fmt";
	$list->{$date_fmt}{start} = $startTime;
	$list->{$date_fmt}{end}   = ($endTime<$end_i)?$endTime:$end_i;
    }
    # check if table is there if required via - existing parameter
    if( $param->{existing} ) {
	foreach my $date_fmt ( sort { $a <=> $b } keys %{$list} ) {
            unless ( $dbh->selectrow_array( "select * from   $date_fmt  where 1=0 " )) {
        	delete $list->{$date_fmt};
            }
	}
	unless ( scalar %$list ) {
            $logger->error(" No tables found");
            return;
	}
    }
    return  $list;
}

=head2  params_to_date
 
set start and end dates as epoch time, parse parameteres, set default values
set parameters for any metric

=cut


sub  params_to_date {
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


=head2   pack_snmp_dat
 
post-process SNMP data

=cut

sub  pack_snmp_data {
    my ($data_ref) = @_;
    my $end_time = -1;
    my @result = ();
    my $start_time =  4000000000;
    foreach my $time (sort {$a<=>$b} grep {$_} keys %{$data_ref->{data}}) { 
	push @result,   
	            [ $time, { capacity => $data_ref ->{md}{$data_ref->{data}{$time}{metaid}}{capacity},  
		               utilization => $data_ref ->{data}{$time}{utilization},
			       errors => $data_ref ->{data}{$time}{errors},
			       drops => $data_ref ->{data}{$time}{drops},
			          }];
	$end_time = $time if $time > $end_time;
	$start_time = $time if $time < $start_time;
    }
    return { data => \@result, start_time => $start_time, end_time => $end_time };
}

=head2 get_datums
    
    return data from the received datums

=cut

sub get_datums {
    my ($datas, $result, $datum_names, $type, $resolution) = @_; 
    my $end_time = -1; 
    my $start_time =  40000000000;
    my $results_raw = [];
    my $count = 0;
    return ($start_time, $end_time) unless $datas && @{$datas}; 
    foreach my $datum (@{$datas}) {
        my %result_row = (timestamp   => $datum->timestamp);
        map {$result_row{$_} = $datum->$_ } @{$datum_names}; ##$params->{table_map}{$type}{data}
	###$result_row{hop_ip} =  ipv4to6($result_row{hop_ip}) if exists $result_row{hop_ip} && isIPv4($result_row{hop_ip});
        push @{$results_raw}, [$datum->timestamp, \%result_row];
        $end_time   =  $datum->timestamp if  $datum->timestamp > $end_time;
        $start_time =  $datum->timestamp if  $datum->timestamp < $start_time;
    }
    if($type =~ /^owamp|pinger|snmp$/) {
        @{$result} = @{refactor_result($results_raw, $type, $resolution)} if $results_raw && @{$results_raw};
    } else {
        @{$result} =  @{$results_raw};
    }
    #fixing up resolution - only return no more than requested number of points
    return  ($start_time, $end_time); 
}

=head2 get_ip_name()

get IP address and hostname from the supplied arg
returns:  ($ip_addr2,  $unt_test)

=cut
 
sub get_ip_name {
    my $ip_addr = shift;
    return  unless $ip_addr;
    my $resolver   = Net::DNS::Resolver->new;
    $ip_addr =~ s{^(https?|tcp)://}{}ig;
    my ( $unt_test ) =  $ip_addr  =~ /^([^:]+):?/;
    $logger->debug(" IP_HOST: $unt_test  ");
    if($unt_test =~ /^([\d\.]+|[\dabcdef\:]+)$/i) {
        if(!Net::CIDR::cidrlookup( $unt_test, ( "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" ) ) &&
           (is_ipv4($unt_test)  ||  &Net::IPv6Addr::is_ipv6( $unt_test ))) {
	    my $ip_resolved =  gethostbyaddr(Socket::inet_aton($unt_test), Socket::AF_INET);
	    $logger->info(" Its IP: $unt_test , name= $ip_resolved");    
            return ($unt_test, $ip_resolved );
	 } else {
	    return;
	 }
    }
    if(is_hostname( $unt_test ) &&  $unt_test !~ m/^changeme|localhost/i) {
        my $query = $resolver->search(  $unt_test );
	my $ip_addr2;
	$logger->debug(" Its HOST: $unt_test  "); 
        if ($query) {
  	    foreach my $rr ($query->answer) {
  	        if($rr->type eq 'A') {
  		    $ip_addr2 = $rr->address;
  		    last;
  	        }
  	    }
        }
 	if($ip_addr2) {
            $logger->debug(" Found IP: $ip_addr2  ");
            return  ($ip_addr2,  $unt_test);
	}
    } 
    return;
}

=head2 pool_control(max_threads, finish_it)

   limits number of threads to max_threads
   when finish_it is set to 1 then just waits when all threads are done and returns

=cut

sub pool_control {
    my ($max_threads, $finish_it) = @_;
    if($finish_it) {
	while(my @running = threads->list(threads::running) ) {
	    foreach my $tidx (@running) {
  		if( $tidx->is_running() ) {
  		    $tidx->join();
  		}
  	    }
	}
	return;
    }
    my @running =  threads->list(threads::running);
    my $num_threads = scalar   @running;
    $logger->debug("Threads::$num_threads vs $max_threads");
    
    while( $num_threads >= $max_threads) {
  	foreach my $tidx (@running) {
  	    if( $tidx->is_running() ) {
  		sleep 1; 
		$tidx->join();
  		$num_threads = threads->list(threads::running);
		$logger->debug("Waiting on Threads::$num_threads");
  	    }
  	}
    }
    return;
}

=head2 update_create_fixed

   fixing broken DBIx::Class, allows to use functions in the parameters

=cut

sub update_create_fixed {
    my ($rs, $search, $set) = @_;
    my $row = $rs->find($search);
    if (defined $row) {
        $row->update($set);
        return $row;
   }
   my $created;
   eval { 
       $created = $rs->create($set)
   };
   if($EVAL_ERROR) {
       $logger->error(" Failed to insert $set - $EVAL_ERROR  ");
   }
   return $created;
}

=head2 ip_ton(ip address)

converts  dotted ipv4 address into the decimal representation

=cut

sub ip_ton{
    my $address = shift;
    my($a, $b, $c, $d) = split '\.', $address;
    $logger->error("Wrong address: $address") unless $address =~ /^[\d\.]+$/;
    return  $d + ($c * 256) + ($b * 256**2) + ($a * 256**3);
}

=head2 nto_ip

converts decimal representation of the ipv4 addres into the dotted one

=cut

sub nto_ip {
    my $addr = shift;	
    my @dotted_arr;
    foreach (1..3) {
        my $tmp = $addr % 256; 
	$addr -= $tmp; 
	$addr /= 256;
	push @dotted_arr, $tmp;
    }  
    push @dotted_arr, $addr;
    return join('.',@dotted_arr);
}

 


=head2 refactor_result 

get timestamp and aggregate to return no more than requested data points
and return as arrayref => [timestamp, {data_row}] 

=cut

sub refactor_result {
    my ($data_raw, $type, $resolution) = @_;
    my $count = scalar @{$data_raw};
    my $result = [];
    $logger->debug("refactoring -- $type resolution=$resolution  Data_raw=$count");
    if($count > $resolution) {
	my $bin = $count/$resolution;
	my $j = 0;
	my $old_j = 0;
	my $count_j = 0;
	for(my $i = 0; $i < $count ; $i++) {
	    $j = int($i/$bin);
	    $result->[$j][0] +=   $data_raw->[$i][0];
	    if($type eq 'snmp') { 
	        $result->[$j][1]{utilization}  += $data_raw->[$i][1]{utilization}?$data_raw->[$i][1]{utilization}:0;
	        $result->[$j][1]{capacity} =  $data_raw->[$i][1]{capacity};
	        map {$result->[$j][1]{$_} += $data_raw->[$i][1]{$_}?$data_raw->[$i][1]{$_}:0 }   qw/errors drops/;
	    } else {
	        foreach my $key (grep(!/timestamp/, keys %{$data_raw->[$i][1]})) {
		    if($key =~ /min/i) {
		        $result->[$j][1]{$key} = $data_raw->[$i][1]{$key} 
			    if !$result->[$j][1]{$key} || $result->[$j][1]{$key} > $data_raw->[$i][1]{$key};
		    } elsif(!$result->[$j][1]{$key} || $result->[$j][1]{$key} < $data_raw->[$i][1]{$key}) {
		        $result->[$j][1]{$key} = $data_raw->[$i][1]{$key};
		    }
		}
	    }	
 
	    if( $j > $old_j || $i == ($count-1) ) {
	        $count_j++ if $i == ($count-1);
		$result->[$old_j][0] = int(($result->[$old_j][0] &&  $count_j)?($result->[$old_j][0]/$count_j):$result->[$old_j][0]);
	        if($type eq 'snmp') { 
		    $result->[$old_j][1]{utilization} /=    $count_j  if $result->[$old_j][1]{utilization} &&  $count_j;
	        } else {
		    # map {$result->[$old_j][1]{$_} = ($result->[$old_j][1]{$_} &&  $count_j)?
		    #                                ($result->[$old_j][1]{$_}/$count_j):
		    #				     $result->[$old_j][1]{$_}  } 
		    #			        keys %{$data_raw->[$i][1]}; 
		}
		$count_j = 0;
	        $old_j = $j;
	    }
	    $count_j++;       
	    #debug "REFACTOR: i=$i j=$j old_j=$old_j count_j=$count_j  raw=$data_raw->[$i][0]  result=$result->[$old_j][0] new=$result->[$j][0] ";
	}	   
    } else {
        $result =  $data_raw;
    }
    $logger->debug("refactoring -- Data_result=" . scalar @$result);
    return $result;
}


1;

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

