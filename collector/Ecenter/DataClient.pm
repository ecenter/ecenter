package Ecenter::DataClient;

use Moose;
use namespace::autoclean;


use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
use Data::Dumper;
use Log::Log4perl qw(get_logger);

use Ecenter::Types;
use English qw( -no_match_vars );

extends 'Ecenter::Client';

=head1 NAME

 Ecenter::DataClient -    client for the DRS data call

=head1 DESCRIPTION

client for the DRS data call
  
=head1 SYNOPSIS 
 
    ## initiate remote query object for the DRS  based on url provided
    my $data= Ecenter::DataClient->new( {  url => 'http://xenmon.fnal.gov:8055' } );
    
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
    
     
    ## get snmp data structure 
    my $snmp_arref = $data->snmp;
     
    #The same could be repeated for OWMAP or PingER 
    
    my $pinger_arref = $data->pinger; 
 
  
=head1 ATTRIBUTES

=over

=item  'src_hub', 'dst_hub','src_ip','dst_ip','start','end','data_type', 'timeout', 'resolution' 

parameters for the data call

=item  bwctl, pinger ,owamp , snmp , traceroute_nodes

Hash ref to the returned data type

=back

=head1 METHODS

=cut

has ['src_hub', 'dst_hub'] =>  (is => 'rw', isa => 'Ecenter::Types::HubName');
has ['start','end','data_type']    => (is => 'rw', isa => 'Str');
has ['src_ip','dst_ip'] =>  (is => 'rw', isa => 'Ecenter::Types::IPAddr');

has resolution => ( is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '20');
has timeout    => ( is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '120');
#
has bwctl      => ( is => 'rw', isa => 'HashRef', weak_ref => 1 );
has pinger     => ( is => 'rw', isa => 'HashRef', weak_ref => 1 );
has owamp      => ( is => 'rw', isa => 'HashRef', weak_ref => 1 );
has snmp       => ( is => 'rw', isa => 'HashRef', weak_ref => 1 );
has traceroute_nodes   => ( is => 'rw', isa => 'HashRef', weak_ref => 1 );

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
}
=head2 get_data

=cut

sub get_data { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    
    $self->logger->logdie('Missing DRS url')
        unless   $self->url; 
    my $url_params = $self->url . '/data.json?'; 
    foreach my $key (qw/data_type start end timeout resolution src_hub src_ip dst_hub dst_ip/) {
       $url_params .=   ($url_params  =~ /\?$/?$key . '=' . $self->$key:'&' . $key . '='. $self->$key)
            if $self->$key;
    }
    $self->send_request($url_params);
     if($self->data && !($self->data->{status} &&  $self->data->{status} eq 'error')) {
        if($self->data_type) {
	    my $type = $self->data_type;
            $self->$type($self->data->{$type}); 
	} 
        else {
            foreach my $type (qw/pinger snmp bwctl owamp traceroute_nodes/) {
                $self->$type($self->data->{$type});
            }
        }
    }
    else {
       foreach my $type (qw/pinger snmp bwctl owamp traceroute_nodes/) {
            $self->$type({});
       }
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


