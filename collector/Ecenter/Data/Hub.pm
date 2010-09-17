package Ecenter::Data::Hub;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
 
use English qw( -no_match_vars ); 

use Log::Log4perl qw(get_logger);
use Net::Netmask; 
use Ecenter::Types qw(HubName IP_addr);
use MooseX::Params::Validate;

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

=head2 

=cut
has 'logger'     => (is => 'rw', isa => 'Log::Log4perl::Logger');
has 'hub_name' => (is => 'rw', isa => 'Ecenter::Types::HubName');
my %hubs = ( FNAL => {'131.225.0.0' => 16, '198.49.208.0' => 24},
             LBL => {'131.243.0.0' => 16, '128.3.121.0' => 24},
	     ORNL => {'192.31.0.0' => 16 },
	     SLAC => {'134.79.0.0' => 16, '198.129.191.0' => 24},
	     BNL => {'192.12.0.0' => 16},
	     ANL => {'164.54.56.0' => 24, '146.137.252.0' => 24, '130.202.222.0' => 24, '140.221.83.0' => 24},
	   );  
 
sub BUILD {
      my $self = shift;
   
      $self->logger(get_logger(__PACKAGE__));  
};

sub get_ips {
    my $self = shift;
    $self->_set_hub(@_);
    return  $hubs{$self->hub_name};
}; 

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
