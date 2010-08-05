package Ecenter::Data::Bwctl;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars ); 
use Log::Log4perl qw(get_logger); 
use Data::Dumper;
use XML::LibXML;
use perfSONAR_PS::Client::MA; 
use Time::Local 'timelocal_nocheck';
use perfSONAR_PS::Common qw( extract find );
use Ecenter::Types qw(IP_addr PositiveInt);
use DateTime;

=head1 NAME

 E-Center::Data::Bwctl  data retrieval API for Bwctl  personar-ps service

=head1 DESCRIPTION

  perfSONAR-PS - Bwctl  data retrieval API 
  
=head1 SYNOPSIS 
   
    # initiate remote query object for the service based on url provided
    my $pinger = E-Center::Data::PingER( {  url => 'http://xxxxxxxxx' } );
    
    ## send request for pinger metadata  
    $pinger->get_metadata({src_regexp => '131.225.*'} );
      
    ## send request for bwctl data from time to time for the metadata keys
    $pinger->get_data({  meta_keys => ['3333'], start => '01-03-2010' , end => '01-05-2010'});
     
    The same could be repeated for OWMAP or PingER, just initialize different object
    
     my $owamp = E-Center::Data::Owamp( {  url => 'http://xxxxxxxxx' } );
    
    
    ## send request for bwctl data from time to time for the metadata id  - internal to E-Center id
    $requester->get_data({type => 'bwctl',metadata => '3333',from => '01-03-2010' , to => '01-05-2010'});
  
   
=head1 ATTRIBUTES

=over

=item  bwctl_data 


=back


=head2 
=cut
has 'src' => (is => 'rw', isa => 'Str');
has 'dst' => (is => 'rw', isa => 'Str');
has eventtypes => (is => 'rw', isa => 'ArrayRef');
 
sub BUILD {
      my $self = shift;
      my $args = shift; 
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/iperf/2.0",
                          "http://ggf.org/ns/nmwg/characteristics/bandwidth/acheiveable/2.0",
                          "http://ggf.org/ns/nmwg/characteristics/bandwidth/achieveable/2.0",
                          "http://ggf.org/ns/nmwg/characteristics/bandwidth/achievable/2.0")]);
 
      $self->logger(get_logger(__PACKAGE__));
      return  $self->url($args->{url}) if $args->{url};
};

after 'url' => sub {
    my ( $self, $arg ) = @_;
    if($arg) {
        $self->ma(new perfSONAR_PS::Client::MA( { instance => $arg } ));
        $self->logger->debug(' MA ' .  $arg  .  ' connected ');
    }
}; 

after 'get_metadata' => sub {
    my ( $self,  $args ) = @_; 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    my $metaids = {};
    my $metad_hr = {};
    unless( ($self->src && $self->dst ) || $self->subject) {
        $self->logger->logdie(" Missed src and  dst or subject");
    }
    unless($self->subject) {
      $self->subject(qq|<iperf:subject xmlns:iperf= "http://ggf.org/ns/nmwg/tools/iperf/2.0/" id="s-in-iperf-1">
      <nmwgt:endPointPair xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">
        <nmwgt:src type="ipv4" value="| .  $self->src . qq|" />
        <nmwgt:dst type="ipv4" value="| .  $self->dst . qq|" />
      </nmwgt:endPointPair>
    </iperf:subject>|);
    } 
    $self->logger->info(" ------------------- METADATA REQUEST:: ", sub{ Dumper  $self->subject} );    
    my $result = {};
    eval {
        $result = $self->ma->metadataKeyRequest({ subject    => $self->subject,
                                                  eventTypes => $self->eventtypes });
    };
    if($EVAL_ERROR) {
	$self->logger->logdie(" Problem with MA $EVAL_ERROR ");
    }
    $self->logger->info("  MDKrrequest Result ", sub{ Dumper    $result });
    my $md_keys = {};
    foreach my $d ( @{ $result->{"data"} } ) {
            my $data = q{};
            eval { $data = $self->parser->parse_string( $d ); };
            if ( $EVAL_ERROR ) {
                $self->logger->logdie(" Failed to parse response from MA: $EVAL_ERROR ");
            }

            my $metadataIdRef = $data->getDocumentElement->getAttribute( "metadataIdRef" );
            my $key = extract( find( $data->getDocumentElement, ".//nmwg:parameter[\@name=\"maKey\"]", 1 ), 0 );
            $md_keys->{$metadataIdRef} = $key if $key and $metadataIdRef;
    }  
	
    $self->logger->debug(" MD :: ", sub{ Dumper $metaids  } );
    $self->meta_keys([ (keys %{$md_keys}) ] );
    $self->metadata($md_keys);
};


after  'get_data' => sub   {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_})  if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    unless($self->meta_keys || ($self->src && $self->dst )  || $self->subject) {
        $self->logger->logdie(" Missed src_name and  dst_name or meta_keys parameter ");
    } 
    $self->get_metadata() unless $self->meta_keys; 
    $self->logger->info(" -------------------METADATA :: ", sub{ Dumper $self->meta_keys } );
    unless($self->meta_keys) {
          $self->logger->error(" No metadata returned !!! ");
	  return;
    }
    my @data = ();
    foreach my $key_id  (@{$self->meta_keys}) {
        my $subject = "  <nmwg:key id=\"key-1\">\n";
        $subject .= "    <nmwg:parameters id=\"parameters-key-1\">\n";
        $subject .= "      <nmwg:parameter name=\"maKey\">$key_id</nmwg:parameter>\n";
        $subject .= "    </nmwg:parameters>\n";
        $subject .= "  </nmwg:key>  \n";
	my $doc1;
        eval { 
            my $result = $self->setupDataRequest( {
                				    start => $self->start->epoch,
                				    end   => $self->end->epoch,   
                				    subject    =>  $subject,
                				    eventTypes =>  $self->eventtypes  
						} );
            $doc1 =  $self->parser->parse_string( $result->{"data"}->[0] ); };
        if ( $EVAL_ERROR ) {
           $self->logger->logdie(" Problem with MA $EVAL_ERROR ");
        }
        my $datum1 = find( $doc1->getDocumentElement, "./*[local-name()='datum']", 0 );
        if ( $datum1 ) {
            foreach my $dt ( $datum1->get_nodelist ) {
                 my $secs = UnixDate( $dt->getAttribute( "timeValue" ), "%s" );
                 push  @data,  [$secs , eval( $dt->getAttribute( "throughput" ) ) ] if $secs and $dt->getAttribute( "throughput" );
            }
        } 
    }
    return $self->data(\@data);
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
