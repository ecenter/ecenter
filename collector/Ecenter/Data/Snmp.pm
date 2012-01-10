package Ecenter::Data::Snmp;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars );
use Log::Log4perl qw(get_logger); 
use Data::Dumper;
use perfSONAR_PS::Client::MA;  
use perfSONAR_PS::Common qw( find findvalue extract);
use Ecenter::Types;

=head1 NAME

 E-Center::Data::Snmp  data retrieval API for snmp  personar-ps service

=head1 DESCRIPTION

perfSONAR-PS - snmp  data retrieval API,see L<Ecenter::Data::Requester> fro more info
it supports SNMP data for statuc and dynamic circuits
  
=head1 SYNOPSIS 
   
     ## initiate remote query object for the service based on url provided
    my $snmp = E-Center::Data::Snmp( {  url => 'http://xxxxxxxxx' } );
    
    ## send request for metadata related to ip
    my $metadata_hashref = $snmp->get_metadata({  ifAddress => ['131.225.8.10']});
     
   
    ## send request for snmp data from time to time for interface IP address
    my $data_hash_ref = $snmp->get_data({  ifAddress => ['131.225.8.10'], start => '01-03-2010' , end => '01-05-2010'});
     
   
   
   
=head1 ATTRIBUTES

=over

=item  direction

=item  urn

=item  ifName

=item  ifAddress

=item  ifIndex

=item subject
 
=item eventtypes

=back

=cut

 
has 'direction'  => (is => 'rw', isa => 'Str');
has 'urn'        => (is => 'rw', isa => 'ArrayRef');
has 'ifName'     => (is => 'rw', isa => 'ArrayRef');
has 'ifIndex'    => (is => 'rw', isa => 'ArrayRef');
has 'ifAddress'  => (is => 'rw', isa => 'ArrayRef');
has 'hostName'   => (is => 'rw', isa => 'ArrayRef');
has 'subject'    => (is => 'rw', isa => 'ArrayRef');
has 'eventtypes' => (is => 'rw', isa => 'ArrayRef');
has 'lookup_md'  => (is => 'rw', isa => 'HashRef');
has 'data'       => (is => 'rw', isa => 'HashRef');

# local lookup table
my $lookup_md = {};
my %VALUES_MAP = ( 'http://ggf.org/ns/nmwg/characteristic/utilization/2.0/' => 'utilization',
                   'http://ggf.org/ns/nmwg/characteristic/errors/2.0/'      => 'errors',
		   'http://ggf.org/ns/nmwg/characteristic/discards/2.0/'     => 'drops');
sub BUILD {
      my $self = shift;
      my $args = shift;
      $self->resolution(5);
      $self->logger(get_logger(__PACKAGE__));
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/snmp/2.0")]);
      $self->parse_params($args);
      return  $self->url($args->{url}) if $args->{url};
      
};


after 'url' => sub {
    my ( $self, $arg ) = @_;
    if($arg) {
        $self->ma(new perfSONAR_PS::Client::MA( { instance => $arg, timeout => $self->timeout} ));
        $self->logger->debug(' MA ' .  $arg  .  ' connected ');
    }
}; 

after 'get_metadata' => sub  {
    my ( $self, $params ) = @_;
    $self->parse_params($params);
    # Standard eventType, we could add more
    $self->logger->debug( "Subjects::", sub{Dumper($self->subject)});
    $self->logger->debug( "EventTypes::", sub{Dumper($self->eventtypes)});
    
    my $ma_result =  $self->ma->metadataKeyRequest(
        {
            subject               => $self->subject,
            eventTypes            => $self->eventtypes,
        }
    );
    $self->parse_metadata($ma_result); 
};

after 'get_data' => sub  {
    my ( $self, $params ) = @_;
    $self->parse_params($params);
    my $ma_result;
    eval  { 
        $ma_result =  $self->ma->setupDataRequest(
            {
            consolidationFunction => $self->cf,
            resolution            => $self->resolution,
            start                 => $self->start->epoch,
            end                   => $self->end->epoch,
            subject               => $self->subject,
            eventTypes            => $self->eventtypes
            }
        );
        $self->parse_metadata($ma_result); 
    };
    if($EVAL_ERROR){
     	$self->logger->error("Unhandled exception or crash: $EVAL_ERROR");
    }
    return unless $ma_result;
    $self->logger->debug("SNMP MA Result::", sub{Dumper($ma_result)});
    my $parser = XML::LibXML->new();
    my %data_response=();
    my $metadata = $self->metadata;
    $self->logger->debug("SNMP MDS::", sub{Dumper($metadata)});
    foreach my $d ( @{ $ma_result->{"data"} } ) {
        my $data = $parser->parse_string($d);
        my $idref = $data->getDocumentElement->getAttribute('metadataIdRef');
	my $uniq_id = $metadata->{$idref}{ip}?$metadata->{$idref}{ip}:
	                   $metadata->{$idref}{urn};
	unless($uniq_id) {
	    $self->logger->debug(" URN or IP must be assigned to the SNMP metirc:: " . Dumper($metadata->{$idref}));
	    next;
	}
        # Extract the datum elements.
	 $self->logger->debug("MD reffed::", sub{Dumper($metadata->{$idref})});
        foreach my $dt ( $data->getDocumentElement->getChildrenByTagNameNS( "http://ggf.org/ns/nmwg/base/2.0/", "datum" ) ) {

            # Make sure the time and data are legit.
            if ( $dt->getAttribute("timeValue") =~ m/^\d{10}$/ ) {
		$self->logger->debug("Got valid time: ".$dt->getAttribute("timeValue"));

                if ( $dt->getAttribute("value") and $dt->getAttribute("value") ne "nan" ) {
		    $self->logger->debug("Data value: ".$dt->getAttribute("value"));
                    my $data_value = eval { $dt->getAttribute("value")  };
		    
		    $data_response{$uniq_id}{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{$VALUES_MAP{$metadata->{$idref}{eventtype}}} =  $data_value;
		    $self->logger->debug("Post-mod data value: ".$data_value);
                }
                else {
		    $self->logger->error("Unidentified eventtype=$metadata->{$idref}{eventtype}") unless $VALUES_MAP{$metadata->{$idref}{eventtype}};
                    $data_response{$uniq_id}{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{$VALUES_MAP{$metadata->{$idref}{eventtype}}}=  0;

		}
		$data_response{$uniq_id}{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{capacity} = $metadata->{$idref}{capacity};
            }
	}
	
   }
   return $self->data(\%data_response);
};

sub parse_metadata {
    my ($self, $xml) = @_;
    my $mds = {};
    my $parser = XML::LibXML->new();
    foreach my $md (@{$xml->{"metadata"}}){
        my $metadata = $parser->parse_string($md);
	my $id = $metadata->getDocumentElement->getAttribute('id');
	my $xpath     = "./*[local-name()='subject']/*[local-name()='interface']";
	my $port      =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='ifName']",    1), 0);
 	my $ip        =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='ifAddress']", 1), 0);
 	my $name      =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='hostName']",  1), 0);
	my $urn       =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='urn']",  1), 0);	
 	my $direction =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='direction']", 1), 0);
 	my $capacity  =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='capacity']",  1), 0);
	my $eventtype =  extract( find($metadata->getDocumentElement, "./*[local-name()='eventType']",  1), 0);
	$eventtype  ||=  extract( find($metadata->getDocumentElement, "./*[local-name()='subject']/*[local-name()='eventType']",  1), 0);
	# filter only requested ones
	
	next unless ($lookup_md->{urn} && $urn && $lookup_md->{urn}{$urn}) ||
	            ($lookup_md->{ifAddress} && $ip && $lookup_md->{ifAddress}{$ip}) ||
		    ($lookup_md->{ifName} && $port &&  $lookup_md->{ifName}{$port}) ||
		    ($lookup_md->{hostName} && $name &&  $lookup_md->{hostName}{$name});
 	$mds->{$id} = {port => $port, ip => $ip, urn => $urn, name => $name, direction => $direction, capacity => $capacity, eventtype=>$eventtype};
    }
    $self->metadata($mds);
}

sub parse_params {
    my ($self, $params) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)}  keys %$params if $params && ref $params eq ref {};
    return $self->subject
        if $self->subject;
    unless($self->hostName or $self->ifAddress or $self->urn) {
        $self->logger->logdie(" subjects or hostName or ifAddress or urn MUST be provided");
	return;
    }
    my $subject = [];
    foreach my $key (qw/ifName ifIndex urn hostName  ifAddress/) {
	if($self->$key && @{$self->$key} ) {
	    foreach my $el ( @{$self->$key} ) {
                my $subj = qq|  <nmwg:subject id="s-in-16"><nmwgt:interface xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">|;
	        $subj  .=    "<nmwgt:$key>" . $el . "</nmwgt:$key>";
		$subj  .=    "<nmwgt:direction>" . $self->direction . "</nmwgt:direction>\n" if $self->direction;
		$lookup_md->{$key}{$el}++;
                push @{$subject}, $subj . q|</nmwgt:interface></nmwg:subject>|;
	    }
	}
   }
   $self->subject($subject);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010-2011, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010-2011, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
