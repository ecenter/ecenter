package Ecenter::Data::Hub;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
 
use English qw( -no_match_vars ); 
use Data::Dumper;
use Log::Log4perl qw(get_logger);
use Net::Netmask; 
use Ecenter::Types qw(HubName IP_addr);
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
my %HUBS = ( FNAL  => {nets => {'131.225.0.0' => 16, '198.49.208.0' => 24}, handle => 'FERMIL'}, #FERMIL
             LBL   => {nets => {'131.243.0.0' => 16, '128.3.121.0' => 24},  handle => 'LBNL'}, # LBNL
	     ORNL  => {nets => {'192.31.0.0' => 16 },                       handle => 'ORNL'},
	     SLAC  => {nets => {'134.79.0.0' => 16,  '198.51.111.0' => 24}, handle => 'THELE-44-Z'},
	     BNL   => {nets => {'192.12.15.0' => 24},                       handle => 'BNL'},
	     ANL   => {nets => {'164.54.0.0' => 16,  '146.137.0.0' => 16, '130.202.0.0' => 16, '140.221.0.0' => 16}, handle => 'ANLB'},
	     NERSC => {nets => {'128.55.00.0'  => 16},                      handle => 'NET-128-55-0-0-1'},
	     PNL   => {nets => {'192.101.100.0'=> 22,'192.101.104.0' => 22},handle => 'PNNL-Z'},
	     NASA  => {nets => {'198.9.0.0' => 16},                         handle => 'NASA'},
	     PPPL  => {nets => {'192.188.10.0' => 24},                      handle => 'PPPL'},
	     LLNL  => {nets => {'198.128.240.0' => 20},                     handle => 'LLNL-1'},
	   );
my $WHOIS_ORG = 'http://whois.arin.net/rest/org'; # add /<handle>/nets.json	
my $WHOIS_NET = 'http://whois.arin.net/rest/net';  # add /<handle>.json

sub BUILD {
      my $self = shift;
   
      $self->logger(get_logger(__PACKAGE__));  
};

=head2 get_ips

=cut

sub get_ips {
    my $self = shift;
    $self->_set_hub(@_);
    return  $HUBS{$self->hub_name}{nets};
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
            $self->logger->debug( " Skipping this handle: $handle due " .$response->status_line);
            next;
        }
    }
    return keys %HUBS;
}; 

=head2 match

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

sub _get_net {
    my ($self,  $net_obj ) =  @_;
    if(exists $net_obj->{net} && $net_obj->{net}{netBlocks} && $net_obj->{net}{netBlocks}{netBlock}  ) {
        $self->logger->debug("netBlock::", sub{Dumper($net_obj->{net}{netBlocks}{netBlock} )});
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
