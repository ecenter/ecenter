package Ecenter::Data::Psb;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars ); 

use Log::Log4perl qw(get_logger);
use Data::Dumper;
use XML::LibXML;
use perfSONAR_PS::Client::MA;
use perfSONAR_PS::Common qw( extract find );
use Ecenter::Types qw(IP_addr PositiveInt);
use DateTime;

=head1 NAME

 E-Center::Data::Bwctl  data retrieval API for pSB type of service ( i2 services) like Owmap and Bwctl

=head1 DESCRIPTION

  perfSONAR-PS -  pSB type of service  data retrieval API 
  
=head1 SYNOPSIS 
   
   this is an abstract class to be extended by actual service
  
   
=head1 ATTRIBUTES

=over

=item  src_ip

=item  dst_ip

=item  src_name

=item  dst_name

=item  eventtypes 

=back

=head2 

=cut

has 'src_ip' => (is => 'rw', isa => 'Str');
has 'dst_ip' => (is => 'rw', isa => 'Str');
has 'src_name' => (is => 'rw', isa => 'Str');
has 'dst_name' => (is => 'rw', isa => 'Str');
 
sub BUILD {
      my $self = shift;
      my $args = shift;  
      $self->logger(get_logger(__PACKAGE__));  
      map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
      $self->logger(get_logger(__PACKAGE__));  
      return  $self->url if $args->{url};
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
    unless(($self->src_name && $self->dst_name) || ($self->src_ip && $self->dst_ip) || $self->subject) {
        $self->logger->logdie(" Missed src and  dst or subject");
    }
    my $nsid = $self->nsid;
    my $namespace = $self->namespace;
     
    unless($self->subject) {
        $self->subject(qq|<$nsid:subject xmlns:$nsid="$namespace" id="s-in-$nsid-1">
        <nmwgt:endPointPair xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/"><nmwgt:src| . 
        ($self->src_ip?' type="ipv4" value="' .  $self->src_ip:'type="hostname" value="' .  $self->src_name) .
        '/><nmwgt:dst ' .
        ($self->dst_ip?' type="ipv4" value="' .  $self->dst_ip:'type="hostname" value="' .  $self->dst_name) .
        qq|/></nmwgt:endPointPair>
        </$nsid:subject>|);
    } 
    $self->logger->debug(" ------------------- METADATA REQUEST:: ", sub{ Dumper  $self->subject} );    
    my $result = {};
    eval {
        $result = $self->ma->metadataKeyRequest({ subject    => $self->subject,
                                                  eventTypes => $self->eventtypes });
    };
    if($EVAL_ERROR) {
	$self->logger->logdie(" Problem with MA $EVAL_ERROR ");
    }
    $self->logger->debug("  MDKrrequest Result ", sub{ Dumper    $result });
    my $md_keys = {};
    
    foreach my $d ( @{ $result->{"data"} } ) {
            my $data = q{};
            eval { $data = $self->parser->parse_string( $d ); };
            if ( $EVAL_ERROR ) {
                $self->logger->logdie(" Failed to parse response from MA: $EVAL_ERROR ");
            }

            my $metadataIdRef = $data->getDocumentElement->getAttribute( "metadataIdRef" );
            my $key = extract( find( $data->getDocumentElement, ".//nmwg:parameter[\@name=\"maKey\"]", 1 ), 0 );
            $md_keys->{$key}++ if $key and $metadataIdRef;
    }  
    my @keys = keys %{$md_keys};
    $self->logger->debug(" MD :: ", sub{ Dumper $md_keys } );
    $self->meta_keys(\@keys);
    $self->metadata($md_keys);
};


after  'get_data' => sub   {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_})  if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    unless($self->meta_keys || ($self->src_ip && $self->dst_ip )  || ($self->src_name && $self->dst_name )  || $self->subject) {
        $self->logger->logdie(" Missed src_name and  dst_name or meta_keys parameter ");
    } 
    $self->get_metadata() unless $self->meta_keys; 
    $self->logger->debug(" -------------------METADATA :: ", sub{ Dumper $self->meta_keys } );
    unless($self->meta_keys) {
          $self->logger->error(" No metadata returned !!! ");
	  return;
    }
    my @data_raw = ();
    foreach my $key_id  (@{$self->meta_keys}) {
        my $subject = "  <nmwg:key id=\"key-1\">\n";
        $subject .= "    <nmwg:parameters id=\"parameters-key-1\">\n";
        $subject .= "      <nmwg:parameter name=\"maKey\">$key_id</nmwg:parameter>\n";
        $subject .= "    </nmwg:parameters>\n";
        $subject .= "  </nmwg:key>  \n";
	my $doc1;
        eval { 
	    my $request =  { start      => $self->start->epoch,
                	     end        => $self->end->epoch,   
                	     subject	=> $subject,
                	     eventTypes => $self->eventtypes
			   };
            my $result = $self->ma->setupDataRequest( $request );
            $doc1 =  $self->parser->parse_string( $result->{"data"}->[0] ); };
        if ( $EVAL_ERROR ) {
           $self->logger->logdie(" Problem with MA $EVAL_ERROR ");
        }
        my $datum1 = find( $doc1->getDocumentElement, "./*[local-name()='datum']", 0 );
        if ( $datum1 ) {
            foreach my $dt ( $datum1->get_nodelist ) {
	         $self->logger->debug("  Datum: ". $dt->toString);
	         my $processed =  $self->process_datum($dt); ## provide implementation in the subclass
	         $self->logger->debug("  Datum Parsed ", sub{ Dumper  $processed}); 
                 push  @data_raw,  $processed if $processed &&  @{$processed};
            }
	  
	    
        } 
    } 
    $self->logger->debug("  Data Result ", sub{ Dumper  \@data_raw });
    return $self->data(\@data_raw);
};

#
#  implemented by specific class ( Bwctl/Owamp etc)
#
sub process_datum {
   inner();
}

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
