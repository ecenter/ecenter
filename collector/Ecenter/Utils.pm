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
use Net::DNS;
use English qw(-no_match_vars);
use Data::Dumper;
use Log::Log4perl;
use Time::HiRes qw(usleep);
use DBI;


use base 'Exporter';


=head1 NAME

Ecenter::Utils - utilities for ecenter scripts

=head1 DESCRIPTION



=head1 SYNOPSIS

=cut

our $logger =   Log::Log4perl->get_logger(__PACKAGE__);
 
# exported functions  

our @EXPORT = qw/get_ip_name pack_snmp_data get_datums refactor_result db_connect update_create_fixed pool_control ip_ton nto_ip/;
 
=head1 FUNCTIONS 
 
=head2 db_connect 

=cut

sub db_connect {
    my ($OPTIONS) = shift;
    my $dbh = DBI->connect_cached('DBI:mysql:' . $OPTIONS->{db},  $OPTIONS->{user}, $OPTIONS->{password}, {RaiseError => 1, PrintError => 1});
    $logger->logdie(" DBI connect failed:  $DBI::errstr") unless $dbh;
    return $dbh; 
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
    my ($datas, $result, $datum_names, $resolution) = @_; 
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
        $end_time =   $datum->timestamp if $datum->timestamp > $end_time;
        $start_time =  $datum->timestamp if  $datum->timestamp < $start_time;
    } 
    $result = refactor_result($results_raw, $resolution) if $results_raw && @{$results_raw};
    #fixing up resolution - only return no more than requested number of points
    return  ($start_time, $end_time); 
}

=head2 refactor_result 

get timestamp and aggregate to return no more than requested data points
and return as arrayref => [timestamp, {data_row}] 

=cut

sub refactor_result {
    my ($data_raw, $resolution) = @_;
    my $count = scalar @{$data_raw};
    my $result = [];
    #debug "refactoring..resolution=$params->{resolution}  ==  Data_raw - $count";
    if($count > $resolution) {
	my $bin = $count/$resolution;
	my $j = 0;
	my $old_j = 0;
	my $count_j = 0;
	for(my $i = 0; $i < $count ; $i++) {
	    $j = int($i/$bin);
	    $result->[$j][0] +=   $data_raw->[$i][0];
	    #map {$result->[$j][1]{$_}  = $data_raw->[$i][1]{$_}?
	     #                                ($result->[$j][1]{$_}?
	     #                                   ($result->[$j][1]{$_}+$data_raw->[$i][1]{$_}):
		#				     $data_raw->[$i][1]{$_}):
		#			                  $result->[$j][1]{$_};} 
		#			 keys %{$data_raw->[$i][1]};
	    $result->[$j][1]{utilization}  += $data_raw->[$i][1]{utilization}?$data_raw->[$i][1]{utilization}:0;
	    $result->[$j][1]{capacity} =  $data_raw->[$i][1]{capacity};
	    map {$result->[$j][1]{$_} += $data_raw->[$i][1]{$_}?$data_raw->[$i][1]{$_}:0 }   qw/errors drops/;
		
	    if( $j > $old_j || $i == ($count-1) ) {
	        $count_j++ if $i == ($count-1); 
	        #map {$result->[$old_j][1]{$_} = ($result->[$old_j][1]{$_} &&  $count_j)?
		#                                  ($result->[$old_j][1]{$_}/$count_j):
		#				     $result->[$old_j][1]{$_}; } 
		#			        keys %{$data_raw->[$i][1]};
		$result->[$old_j][1]{utilization} /=    $count_j  if $result->[$old_j][1]{utilization} &&  $count_j;
	        $result->[$old_j][0] = ($result->[$old_j][0] &&  $count_j)?int($result->[$old_j][0]/$count_j):$result->[$old_j][0];
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
	    $logger->debug(" Its IP: $unt_test  "); 
            return ($unt_test, gethostbyaddr(Socket::inet_aton($unt_test), Socket::AF_INET));
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
    $logger->info("Threads::$num_threads vs $max_threads");
    
    while( $num_threads >= $max_threads) {
  	foreach my $tidx (@running) {
  	    if( $tidx->is_running() ) {
  		sleep 1; 
		$tidx->join();
  		$num_threads = threads->list(threads::running);
		$logger->info("Waiting on Threads::$num_threads");
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

Copyright (c) 2010, Fermitools

All rights reserved.

=cut

