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
use Net::IPv6Addr;
use Net::CIDR;
use Data::Validate::IP qw(is_ipv4 is_ipv6);
use Data::Validate::Domain qw( is_domain is_hostname);
use Socket;
use Socket6;
use Net::DNS;
use English qw(-no_match_vars);
use Data::Dumper;
use Log::Log4perl;
use Time::HiRes qw(usleep);

use base 'Exporter';


=head1 NAME

Ecenter::Utils - utilities for ecenter scripts

=head1 DESCRIPTION



=head1 SYNOPSIS

=cut

our $logger =   Log::Log4perl->get_logger(__PACKAGE__);
 
# exported functions  

our @EXPORT = qw/get_ip_name update_create_fixed pool_control ip_ton nto_ip/;
 
=head1 FUNCTIONS

=head2 get_ip_name()

=cut
 
sub get_ip_name {
    my $ip_addr = shift;
    return () unless $ip_addr;
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
	    return ();
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
        $logger->debug(" Found IP: $ip_addr2  "); 
       return  ($ip_addr2,  $unt_test);
    } 
    return ();
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
    $logger->info("Threads::" . join(' : ', map {$_->tid}  @running) );
    
    while( $num_threads >= $max_threads) {
  	foreach my $tidx (@running) {
  	    if( $tidx->is_running() ) {
  		usleep 10;
  		$num_threads = threads->list(threads::running);
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

