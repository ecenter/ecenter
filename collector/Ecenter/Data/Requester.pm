package Ecenter::Data::Requester;

use Moose;
use namespace::autoclean;


use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

use Log::Log4perl qw(get_logger);
use DateTime;

use Ecenter::Types qw(IP_addr PositiveInt);
use English qw( -no_match_vars );

=head1 NAME

 E-Center::Data::Requester  data retrieval API for any personar-ps service

=head1 DESCRIPTION

  perfSONAR-PS - data retrieval API 
  
=head1 SYNOPSIS 
 
    ## initiate remote query object for the service based on url provided
    my $bwctl = E-Center::Data::Bwctl( {  url => 'http://xxxxxxxxx' } );
    
    ## send request for bwctl metadata  
    $bwctl->get_metadata({src_regexp => '131.225.*'} );
      
    ## send request for bwctl data from time to time for the metadata keys
    $bwctl->get_data({  meta_keys => ['3333'], start => '01-03-2010' , end => '01-05-2010'});
     
    The same could be repeated for OWMAP or PingER, just initialize different object
    
     my $bwctl = E-Center::Data::Owamp( {  url => 'http://xxxxxxxxx' } );
   
 
  
=head1 ATTRIBUTES

=over

=item  ma

=item  data 

=item  url

=item  metadata 

=item  type

=back

=cut

has 'ma'         => (is => 'rw', isa => 'Object' );
has 'data'       => (is => 'rw', isa => 'ArrayRef');
has 'metadata'   => (is => 'rw', isa => 'HashRef');
has 'url'        => (is => 'rw', isa => 'Str' );
has 'start'      => (is => 'rw', isa => 'DateTime');
has 'end'        => (is => 'rw', isa => 'DateTime');
has 'logger'     => (is => 'rw', isa => 'Log::Log4perl::Logger');
has 'resolution' => (is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '1');
has 'cf'         => (is => 'rw', isa => 'Str', default => 'AVERAGE');

 

sub get_data { 
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    
}

sub get_metadata {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
}

__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut


