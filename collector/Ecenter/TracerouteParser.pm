package Ecenter::TracerouteParser;
    
use strict;
use warnings;

use base 'Net::Traceroute';
use Ecenter::Exception;
use Log::Log4perl qw(get_logger);
use Data::Dumper;
use English qw( -no_match_vars );
$SIG{CHLD} = 'IGNORE';
my $logger = get_logger(__PACKAGE__);

#  taken from  perfSONAR_PS/Services/MP/NetTraceroute.pm - author:Andy Lake, ESnet
#override parsing so can prep output for some cases Net::Traceroute doesn't support

sub parse {
    my $self = shift;
    my $tr_output = $self->text;
    
    ##
    # Some versions of traceroute put consecutive queries with different addresses on new line.
    # This breaks Net::Traceroute so the code below puts them on same line. For example:
    # traceroute to fnal-owamp.es.net (198.124.252.101), 64 hops max, 40 byte packets
    # 1  anlmr1-anlowamp (198.124.252.98)  0.470 ms  0.277 ms  0.180 ms
    # 2  starcr1-anlmr2 (134.55.219.54)  2.215 ms  2.228 ms
    # chiccr1-ip-anlmr2 (134.55.220.37)  1.096 ms
    # ....
    #Now becomes:
    # traceroute to fnal-owamp.es.net (198.124.252.101), 64 hops max, 40 byte packets
    # 1  anlmr1-anlowamp (198.124.252.98)  0.470 ms  0.277 ms  0.180 ms
    # 2  starcr1-anlmr2 (134.55.219.54)  2.215 ms  2.228 ms chiccr1-ip-anlmr2 (134.55.220.37)  1.096 ms
    ##
    my $new_tr_output = "";
    my $ttl = -1;
    my $line_num = 0; 
    my $timestamp = time();
    foreach my $tr_line (split(/\n/, $tr_output)) {
        $line_num++;
        if($tr_line =~ /^traceroute to / ||
            $tr_line =~ /^trying to get / ||
            $tr_line =~ /^source should be / ||
            $tr_line =~ /^message too big, trying new MTU = (\d+)/ ||
            $tr_line =~ /^\s+MPLS Label=(\d+) CoS=(\d) TTL=(\d+) S=(\d+)/
           ){
             $new_tr_output .= "\n" if($line_num > 1);
             $new_tr_output .= "$tr_line";
             next;
        }
        
        if($tr_line =~ /^([0-9 ][0-9]) /){
            $ttl = $1 + 0;
            $new_tr_output .= "\n" if($line_num > 1);
            $new_tr_output .= "$tr_line";
        }elsif ($ttl == -1){
            #this is an error so reset and let Net::Traceroute deal with it
            $new_tr_output = $tr_output; 
            last;
        }else{
            $tr_line =~ s/^\s+/ /;
            $new_tr_output .= "$tr_line";
        }
    }
    $self->text($new_tr_output);
    eval {
        $self->SUPER::_parse($new_tr_output);
    };
    if($EVAL_ERROR) {
        $logger->error("Parser failed with $EVAL_ERROR");
	return {};
    }
    MalformedParameterException->throw(error => 'no hops were found, wrong traceroute format:: ' . Dumper($self))
        unless $self->hops;
    my $result = {};
    my @hops = @{$self->{hops}};
    my $src_ip; # 
    my $dst_ip;
    for(my $i = 0; $i < $self->hops; $i++) {
        next unless  $hops[$i] && ref $hops[$i] eq 'ARRAY';
	if($hops[$i]->[0][1] && $hops[$i]->[0][1] !~ /^(127\.0\.0\.1)|(10\.)|(172\.1[6-9]\.)|
                                                  (172\.2[0-9]\.)|(^172\.3[0-1]\.)|
                                              (192\.168\.)|(255\.0)|(255\.255\.)/xm) {
	    $src_ip ||= $hops[$i]->[0][1];
	    $dst_ip   = $hops[$i]->[0][1];
        }
	my $addr='';
	my $delay = 0;
	foreach my $query (@{$hops[$i]}) {
	    my ($status, $addr1, $delay1) = @$query;
	    $addr = $addr1 if $addr1;
	    $delay  = $delay1 if $delay1 > $delay; 
        }
	$result->{$addr}{$timestamp} = {hop_ip => $addr, hop_delay => $delay/3.,  hop_num => $i};
    }
    $logger->debug("Traceroute parsed:", sub {Dumper($result)});
   
    return  { hops =>  $result, src_ip =>  $src_ip, dst_ip =>  $dst_ip };
}

1;


__END__


=head1 SEE ALSO

L<Data::Dumper>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

Daniel Hagerty, hag@ai.mit.edu
Andy Lake, ESnet
Maxim Grigoriev, maxim_at_fnal_dot_gov 

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2011, Fermitools

All rights reserved.

=cut
 
