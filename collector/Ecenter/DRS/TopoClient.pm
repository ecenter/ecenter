package Ecenter::DRS::TopoClient;

use Moose;
use namespace::autoclean;


use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
use Data::Dumper;
use Log::Log4perl qw(get_logger);

use DRS::Types;
use English qw( -no_match_vars );

extends 'Ecenter::DRS::Client';

=head1 NAME

Ecenter::DRS::TopoClient -    client for the DRS  /hub and /[source|destination] calls

=head1 DESCRIPTION

client for the DRS data consumer, /hub and /[source|destination] calls
  
=head1 SYNOPSIS 
 
    ## initiate remote query object for the DRS  based on url provided
    my $topo_client = Ecenter::DRS::TopoClient->( {  url => 'http://xenmon.fnal.gov:8055' } );
    
    ## send request to get list of all HUBs ( like FNAL, LBL ...etc)
    my $hubs_hashref = $topo_client->get_hubs();
    
    ## get the list of destination nodes available for some source IP
    my $nodes_arref =  $topo_client->get_nodes({src_ip => 'FNAL' } );
    
    ## get list of the all available source IP nodes
    my $nodes_arref = $topo_client->get_nodes();
    
    ##  list of returned HUBs
    my $hubs_arref = $topo_client->hubs;
    
     ##  list of returned nodes
    my $nodes_arref = $topo_client->nodes;
   
  
=head1 ATTRIBUTES

=over

=item  src_ip

parameters for the data call

=item  hubs

Hash ref to the returned list of HUBs

=item  nodes

Hash ref to the returned nodes list ( source or destinations depending on the request)

=back

=head1 METHODS

=cut

has  'hubs'    => (is => 'rw', isa => 'HashRef',  weak_ref => 1);
has  'src_ip'  =>  (is => 'rw', isa => 'DRS::Types::IPAddr');
has  'src_hub'  =>  (is => 'rw', isa => 'Str');
#
has 'nodes'  => (is => 'rw', isa => 'HashRef', weak_ref => 1);

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
}
=head2 get_destination_hubs

get list of the HUBs ( as Hashref ) for some source hub ( based on the available traceroutes)

=cut

sub get_destination_hubs { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    
    $self->logger->logdie('Missing DRS url or/and src_hub parameter')
        unless   $self->url &&  $self->src_hub; 
    my $url_params = $self->url . '/hubs/' . $self->src_hub . '.json';
    $self->send_request($url_params);
     if($self->data && !($self->data->{status} &&  $self->data->{status} eq 'error')) {
        $self->hubs($self->data);
    }
    else {
        $self->hubs({});
    } 
    $self->logger->debug(" DRS response::", sub{Dumper($self->data)});
    return $self->data;
}
=head2 get_hubs

get list of the HUBs ( as Hashref )

=cut

sub get_hubs { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    
    $self->logger->logdie('Missing DRS url')
        unless   $self->url; 
    my $url_params = $self->url . '/hub.json';
    $self->send_request($url_params);
     if($self->data && !($self->data->{status} &&  $self->data->{status} eq 'error')) {
        $self->hubs($self->data);
    }
    else {
        $self->hubs({});
    } 
    $self->logger->debug(" DRS response::", sub{Dumper($self->data)});
    return $self->data;
}
 
=head2 get_nodes

get list of the nodes ( as HashRef)

=cut

sub get_nodes { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    
    $self->logger->logdie('Missing DRS url')
        unless   $self->url;
    my $url_params = $self->url . ($self->src_ip?'/destination/' . $self->src_ip . '.json':'/source.json');
    $self->send_request($url_params);
     if($self->data && !($self->data->{status} &&  $self->data->{status} eq 'error')) {
        $self->nodes($self->data);
    }
    else {
        $self->nodes({});
    } 
    $self->logger->debug(" DRS response::", sub{Dumper($self->data)});
    return $self->data;
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


