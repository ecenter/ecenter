package Ecenter::Client;

use Moose;
use namespace::autoclean;


use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

use Log::Log4perl qw(get_logger);
use DateTime;
use LWP::UserAgent;
use JSON::XS;

use Ecenter::Types qw(IP_addr PositiveInt);
use English qw( -no_match_vars );

=head1 NAME

 E-Center::Client -  base client for the DRS data consumer

=head1 DESCRIPTION

   base client for the DRS data consumer
  
=head1 SYNOPSIS 
 
    ## initiate remote query object for the DRS  based on url provided
    my $data= E-Center::Client( {  url => 'http://xxxxxxxxx' } );
    
    ## send request for all data between two hubs
    my $data_hashref = $data->get_data({src_hub => 'FNAL', dst_hub => 'LBL', 
                                        start => '2011-03-01 01:02:00', end => '2011-04-01 01:02:00',
				        resolution => 100, timeout => 200 } );
    
    ## send request for all data between two IPs
    my $data_hashref = $data->get_data({src_ip => '198.129.4.2', dst_ip => '131.225.110.80', 
                                        start => '2011-03-01 01:02:00', end => '2011-04-01 01:02:00',
				        resolution => 100, timeout => 200 } );
    
     ## send request for the BWCTL  data only between two IPs
     my $data_hashref = $data->get_data({data_type => 'bwctl',
                                         src_ip => '198.129.4.2', dst_ip => '131.225.110.80', 
                                         start => '2011-03-01 01:02:00', end => '2011-04-01 01:02:00',
				         resolution => 100, timeout => 200 } );
    
    
    ## send request for the list of hubs (without arguments) or for the list of available paired
    ## destination hubs for the provided  source hub name parameter
    
    my $hubs_arref = $data->get_hubs({src_hub => 'FNAL' } );
     
    ## get snmp data structure 
    my $snmp_arref = $data->snmp();
     
    #The same could be repeated for OWMAP or PingER 
    
    my $pinger_arref = $data->pinger(); 
 
  
=head1 ATTRIBUTES

=over

=item  ma

=item  data 

=item  url

=item  type

=back

=cut

 
has data_type  => (is => 'rw', isa => 'Str');
has data       => (is => 'rw', isa => 'HashRef');
has url        => (is => 'rw', isa => 'Str' );
has start      => (is => 'rw', isa => 'Str');
has end        => (is => 'rw', isa => 'Str');
has bwctl      => (is => 'rw', isa => 'HashRef' );
has pinger     => (is => 'rw', isa => 'HashRef' );
has owamp      => (is => 'rw', isa => 'HashRef' );
has snmp       => (is => 'rw', isa => 'HashRef' );
has traceroute => (is => 'rw', isa => 'HashRef' );
has logger     => (is => 'rw', isa => 'Log::Log4perl::Logger');
has resolution => (is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '20');
has timeout    => (is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '120');

sub BUILD { 
      my $self = shift;
      $self->logger(get_logger(__PACKAGE__)); 
      map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
      return  $self->url if $args->{url};
}

 }

sub get_data { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    my $agent = LWP::UserAgent();
    
    
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2011, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2011, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut


