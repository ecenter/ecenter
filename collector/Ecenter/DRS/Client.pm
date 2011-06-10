package Ecenter::DRS::Client;

use Moose;
use namespace::autoclean;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

use Log::Log4perl qw(get_logger);
use LWP::UserAgent;
use JSON::XS;

use English qw( -no_match_vars );

=head1 NAME

 E-Center::DRS::Client -  base client for the DRS data consumer

=head1 DESCRIPTION

   base client for the DRS data consumer, subclass it to get implementation for the specific DRS call
  
=head1 SYNOPSIS 
 
see Ecenter::DRS::DataClient for the subclassing example. Normal usage:

 use Moose;
 extends 'Ecenter::DRS::Client';



=head1 ATTRIBUTES

=over

=item  request

LWP request object

=item  data 

returned data hashref

=item  url

base URL for the DRS service
default: http://ecenter.fnal.gov:8055

=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut

has url        => (is => 'rw', isa => 'Str', default => 'http://ecenter.fnal.gov:8055' );
has request    => (is => 'rw', isa => 'LWP::UserAgent');
has logger     => (is => 'rw', isa => 'Log::Log4perl::Logger');
has data       => (is => 'rw', isa => 'HashRef');

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    return  $self->url if $args->{url};
}

=head1  send_request

sends request to the DRS, accepts single parameter - complete URL for the request

=cut 

sub send_request {
    my ($self, $request_url) = @_;
    unless($request_url) {
        $self->logger->error("Failed, URL must be provided as argumnet");
	return;
    }   
    $self->request(LWP::UserAgent->new(agent => 'DRS useragent 1.001')) 
        unless $self->request;
    $self->request->default_header( 'Content-Type' => 'application/json' );
 
    my $response_http = $self->request->get( $request_url );
    if ($response_http->is_success) {
        eval {
            $self->data( decode_json($response_http->content) );
	    
        };
        if($EVAL_ERROR || !($self->data && ref $self->data eq ref {})) {
            $self->logger->error("E-Center DRS webservice failed with  $EVAL_ERROR for: $request_url");
            return $self->data({status => 'error'});
        }
    }
    else {
        $self->logger->error("Failed request::   $request_url " . $response_http->status_line);
	return $self->data({status => 'error'});
    }
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


