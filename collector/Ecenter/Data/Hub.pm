package Ecenter::Data::Hub;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
 
use English qw( -no_match_vars ); 

use Log::Log4perl qw(get_logger);
 
use Ecenter::Types qw(HubName);
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
my %hubs = ( fnal => {'131.225.0.0' => 16, '198.49.208.0' => 24},
             lbl => {'131.243.0.0' => 16, '128.3.121.0' => 24},
	     ornl => {'192.31.0.0' => 16 },
	     slac => {'134.79.0.0' => 16, '198.129.191.0' => 24},
	     bnl => {'192.12.0.0' => 16},
	     anl => {'164.54.56.0' => 24, '146.137.252.0' => 24, '130.202.222.0' => 24, '140.221.83.0' => 24},
	     );  
 
sub BUILD {
      my $self = shift;
      my $args = shift;  
      $self->logger(get_logger(__PACKAGE__));  
};

sub get_ips {
    my ( $self, $arg ) =   validated_list(
                             \@_,
                             hub_name   => { isa => 'Ecenter::Types::HubName', optional => 1});
    $self->logger->logdie("Missed hub_name argument") unless $arg || $self->hub_name;
    $arg ||= $self->hub_name;
    $arg = lc($arg);
    return $hubs{$arg};
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
