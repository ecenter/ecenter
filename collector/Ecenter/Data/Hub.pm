package Ecenter::Data::Hub;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
 
use English qw( -no_match_vars ); 
use Data::Dumper;
use Log::Log4perl qw(get_logger);
use Net::Netmask; 
use Ecenter::Types;
use MooseX::Params::Validate;
use JSON::XS  qw(decode_json);
use LWP::UserAgent;


=head1 NAME

 E-Center::Data::Hub - wrapper for the hardcoded lookup table of the hubs accociated with the end-sites

=head1 DESCRIPTION

   wrapper for the hardcoded lookup table of the hubs accociated with the end-sites
  
=head1 SYNOPSIS 
   
    my $hub = E-Center::Data::Hub->new();
   
    my $ips = $hub->get_ips('FNAL'); # returns hashref with keys as IP addresses of the subnets and   netmasks values
    
=head1 ATTRIBUTES

=over

=item  hub_name

=back

=head1 METHODS

=cut

has 'logger'     => (is => 'rw', isa => 'Log::Log4perl::Logger');
has 'hub_name' => (is => 'rw', isa => 'Ecenter::Types::HubName');
# handle is the registered handle at whois.arin.net  - ARIN IP registar
my %HUBS = ( FNAL  => {nets => {'131.225.0.0' => 16, '198.49.208.0' => 24, '198.124.252.101' => 31}, handle => 'FERMIL'}, #FERMIL
             LBL   => {names => [qw/LLBL/], 
	               nets => {'134.55.219.9' => 31, '198.129.252.142' => 31,
		                '131.243.0.0' => 16, '128.3.121.0' => 24, '198.128.1.0' => 24},  handle => 'LBNL'}, # LBNL
	     ORNL  => {nets => {'192.31.0.0' => 16,  '134.55.220.30' => 31, '198.124.238.85' => 31},
	               handle => 'ORNL'},
	     SLAC  => {nets => {'134.79.0.0' => 16,  '198.51.111.0' => 24, 
	                        '198.129.254.146' => 32, '134.55.217.1' => 31}, handle => 'THELE-44-Z'},
	     BNL   => {nets => {'192.12.15.0' => 24, '134.55.221.138' => 31,
	                        '198.124.238.38' => 31, '198.124.238.49' => 31}, handle => 'BNL'},
             ANL   => {nets => { '164.54.0.0' => 16,  '146.137.0.0' => 16,
        		       '130.202.0.0' => 16, '198.124.252.97' => 31, '198.124.252.117' => 31,
         		      '140.221.15.0' => 24,'134.55.220.38' => 31,
         		      '140.221.8.0' => 24 }, 
		       handle => 'ANLB'
			      }, # ANLB - commented for SC
	     NERSC => {nets => {'128.55.00.0'  => 16, '198.129.254.34' => 32, '134.55.217.22'=>31}, handle => 'NET-128-55-0-0-1'},
	     PNNL  => {names => [qw/PNL PNNL PNWG/], nets => {'192.101.100.0' => 22,'192.101.104.0' => 22, '130.20.248.0' => 24 }, 
	               handle => 'PNNL-Z'
	     },
	     NASA  => {nets => {'198.9.0.0' => 16},                         handle => 'NASA'},
	     PPPL  => {nets => {'192.188.10.0' => 24, '198.124.238.166' => 31, '134.55.219.85' => 31}, handle => 'PPPL'},
	     LLNL  => {nets => {'198.128.240.0' => 20},                     handle => 'LLNL-1'},
	     JGI   => {nets => {'198.129.96.0' => 24},                      handle => 'JGI'},
	     SNLL  => {names => [qw/SANDIA/], nets => {'192.203.226.0' => 24}, handle => 'NET-192-203-226-0-1'},
	   );
my $WHOIS_ORG = 'http://whois.arin.net/rest/org'; # add /<handle>/nets.json	
my $WHOIS_NET = 'http://whois.arin.net/rest/net';  # add /<handle>.json

sub BUILD {
      my $self = shift;
   
      $self->logger(get_logger(__PACKAGE__));  
};

=head2 get_aliases

=cut

sub get_aliases {
    my $self = shift;
    $self->_set_hub(@_);
    return  $HUBS{$self->hub_name}{names};
};

=head2 get_ips

=cut

sub get_ips {
    my $self = shift;
    $self->_set_hub(@_);
    return  $HUBS{$self->hub_name}{nets};
}; 

=head2 get_hubnames

=cut

sub get_hubnames  {
    my $self = shift; 
    return  keys %HUBS;
};


=head2 get_hub_blocks

get IP blocks from the ARIN registrant - should be run once on the whole object to populate %HUBS - takes some time.
returns list of HUB names

=cut

sub get_hub_blocks {
    my $self = shift;
    my $mech =   LWP::UserAgent->new(agent => 'Mozilla'); ## some unique id will be added
    $mech->default_header( 'Content-Type' => 'application/json' );
    foreach my $handle (keys %HUBS) {
        next unless  $HUBS{$handle}{handle};
        my $response = $mech->get( ($HUBS{$handle}{handle} =~ /^NET-/?"$WHOIS_NET/$HUBS{$handle}{handle}.json":"$WHOIS_ORG/$HUBS{$handle}{handle}/nets.json") );
        if ($response->is_success) {
            my $nets_obj = decode_json($response->content);
	    my @nets = ();
	    if(exists $nets_obj->{nets}) {
	        foreach my $net_el ( @{$nets_obj->{nets}{netRef}} ) {
	            if(exists  $net_el->{'$'}) {
	                 my  $resp_net = $mech->get( $net_el->{'$'} . '.json' );
                         if($resp_net->is_success) {
                             my $net_obj = decode_json($resp_net->content);
			     my $net =  $self->_get_net( $net_obj );
			     push @nets, @{$net} if $net;
			 }
		    }
	        }
	    } elsif(exists $nets_obj->{net}) {
	        my $net = $self->_get_net( $nets_obj );
	        push @nets, @{$net} if $net;
	    }  
	    map { $HUBS{$handle}{nets}{$_->[0]} = $_->[1]} @nets;
        }   else {
            ###$self->logger->debug( " Skipping this handle: $handle due " .$response->status_line);
	    next;
        }
    }
    return keys %HUBS;
}; 

=head2 find_hub 

a static call - returns found Hub object for the supplied ip address if there is anetblock match

=cut

sub find_hub {
    my ( $self, $ip, $nodename) = @_;
    my $hub;
    my $logger = ref $self && $self->logger?$self->logger:get_logger(__PACKAGE__);
    foreach my $hubname (keys %HUBS) {
        foreach my $subnet (keys %{$HUBS{$hubname}->{nets}}) {
	    ###$logger->debug( " Checking  $ip   vs $hubname=  $subnet/$HUBS{$hubname}->{nets}{$subnet} ");
            my $block = Net::Netmask->new("$subnet/$HUBS{$hubname}->{nets}{$subnet}");
	    if($nodename =~ m/$hubname\./i || $block->match($ip)) {
	        return Ecenter::Data::Hub->new(hub_name => $hubname);
	    }
	}
    }
    return $hub;
};


=head2 match
 
for the named argument - ip which is of <Ecenter::Types::IP_addr>, it will return 1 if 
it belongs to the current HUB

=cut

sub match {
    my ( $self, %arg ) =   validated_hash(
                             \@_,  
                             ip   => { isa => 'Ecenter::Types::IP_addr' });
    my $ips = $self->get_ips(@_);
    foreach my $subnet (keys %{$ips}) {
        my $block = Net::Netmask->new("$subnet/$ips->{$subnet}");
	if($block->match($arg{ip}->ip())) {
	    return 1;
	}
    }
    return;
};

#
#  auxiliary function
#
sub _get_net {
    my ($self,  $net_obj ) =  @_;
    if(exists $net_obj->{net} && $net_obj->{net}{netBlocks} && $net_obj->{net}{netBlocks}{netBlock}  ) {
        ###$self->logger->debug("netBlock::", sub{Dumper($net_obj->{net}{netBlocks}{netBlock} )});
	$net_obj->{net}{netBlocks}{netBlock} = [ $net_obj->{net}{netBlocks}{netBlock} ] 
	    unless ref $net_obj->{net}{netBlocks}{netBlock} eq ref [];
	my @return = ();
	foreach my $block (@{$net_obj->{net}{netBlocks}{netBlock}}) {
     	    push @return, [$block->{startAddress}{'$'}, $block->{cidrLength}{'$'}];
	}
	return \@return;
    }
    return;
};

sub get_ips_sql {
    my($self, %arg) =  validated_hash(
                             \@_,
			     type       => { regex => qr/^dst|src$/});
    my $ips_href = $self->get_ips(@_);
    my @ips = map{"inet6_mask(md.$arg{type}\_ip, $ips_href->{$_}) = inet6_mask(inet6_pton('$_'), $ips_href->{$_})"} keys %{$ips_href};
    my $str = join(" or ", @ips);
    return "($str)";
}; 

sub _set_hub {
    my ( $self, %arg ) =   validated_hash(
                             \@_,
                             hub_name   => { isa => 'Ecenter::Types::HubName', optional => 1});
    if (%arg && $arg{hub_name}) {
        $arg{hub_name} = uc($arg{hub_name});	     
        $self->hub_name($arg{hub_name}) 	     
    }
    $self->logger->logdie("Missed hub_name argument") unless  $self->hub_name;
    return $self->hub_name();
}; 

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
