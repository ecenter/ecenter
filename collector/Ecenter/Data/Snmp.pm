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
    my $metadata_hashref = $snmp->get_metadata({  ifAddress => '131.225.8.10'});
     
   
    ## send request for snmp data from time to time for interface IP address
    my $data_arr_ref = $snmp->get_data({  ifAddress => '131.225.8.10', start => '01-03-2010' , end => '01-05-2010'});
     
   
   
   
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
has 'urn'        => (is => 'rw', isa => 'Str', required => 0);
has 'ifName'     => (is => 'rw', isa => 'Str');
has 'ifIndex'    => (is => 'rw', isa => 'Str');
has 'ifAddress'  => (is => 'rw', isa => 'Ecenter::Types::IPAddr');
has 'hostName'   => (is => 'rw', isa => 'Str');
has 'subject'    => (is => 'rw', isa => 'Str');
has 'eventtypes' => (is => 'rw', isa => 'ArrayRef');

sub BUILD {
      my $self = shift;
      my $args = shift;
      $self->resolution(5);
      $self->logger(get_logger(__PACKAGE__));
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/snmp/2.0")]);
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
    my $datum = [[],[]];
    my %data_response=();
    my $metadata = $self->metadata;
    $self->logger->debug("SNMP MDS::", sub{Dumper($metadata)});
    foreach my $d ( @{ $ma_result->{"data"} } ) {
        my $data = $parser->parse_string($d);
        my $idref = $data->getDocumentElement->getAttribute('metadataIdRef');
        # Extract the datum elements.
        foreach my $dt ( $data->getDocumentElement->getChildrenByTagNameNS( "http://ggf.org/ns/nmwg/base/2.0/", "datum" ) ) {

            # Make sure the time and data are legit.
            if ( $dt->getAttribute("timeValue") =~ m/^\d{10}$/ ) {
		$self->logger->debug("Got valid time: ".$dt->getAttribute("timeValue"));

                if ( $dt->getAttribute("value") and $dt->getAttribute("value") ne "nan" ) {
		    $self->logger->debug("Data value: ".$dt->getAttribute("value"));
                    my $data_value = eval { $dt->getAttribute("value")  };
		    $data_response{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{data}{$metadata->{$idref}{eventtype}} =  $data_value;
		    $self->logger->debug("Post-mod data value: ".$data_value);
                }
                else {
                    $data_response{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{data}{$metadata->{$idref}{eventtype}}=  0;
		}
		$data_response{$metadata->{$idref}{direction}}{$dt->getAttribute("timeValue")}{capacity} = $metadata->{$idref}{capacity};
            }
	}
	
   }
  # $self->logger->debug("SNMP Data response::", sub{Dumper(\%data_response)});
   foreach my $dir (0,1) {
       my $dir_name = $dir?'out':'in';
       foreach my $tm ( sort {$a <=> $b} keys %{$data_response{$dir_name}}) {
                    push @{$datum->[$dir]}, [$tm, $data_response{$dir_name}{$tm}{data}{'http://ggf.org/ns/nmwg/characteristic/utilization/2.0/'},
                          $data_response{$dir_name}{$tm}{data}{'http://ggf.org/ns/nmwg/characteristic/errors/2.0/'},
			  $data_response{$dir_name}{$tm}{data}{'http://ggf.org/ns/nmwg/characteristic/discards/2.0/'},
			  $data_response{$dir_name}{$tm}{capacity} 
			  ];
       }
   }
   return $self->data($datum);
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
	my $urn      =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='urn']",  1), 0);	
 	my $direction =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='direction']", 1), 0);
 	my $capacity  =  extract( find($metadata->getDocumentElement, "$xpath/*[local-name()='capacity']",  1), 0);
	my $eventtype  =  extract( find($metadata->getDocumentElement, "./*[local-name()='eventType']",  1), 0);
	$eventtype  ||=  extract( find($metadata->getDocumentElement, "./*[local-name()='subject']/*[local-name()='eventType']",  1), 0);
	# filter only requested ones
	next unless ($self->urn && $urn &&  $self->urn eq $urn) || 
	            ($self->ifAddress && $ip && $self->ifAddress eq $ip) || 
		    ($self->hostName && $name && $self->hostName eq $name);
 	$mds->{$id} = {port => $port, ip => $ip, urn => $urn, name => $name, direction => $direction, capacity => $capacity, eventtype=>$eventtype};
    }
    $self->metadata($mds); 
}

sub parse_params {
   my ($self, $params) = @_;
   map {$self->$_($params->{$_}) if $self->can($_)}  keys %$params if $params && ref $params eq ref {};
   return unless $self->hostName or $self->ifAddress or $self->urn;
   my $subject = qq|  <nmwg:subject id="s-in-16"><nmwgt:interface xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">|;
   foreach my $key (qw/ifName ifIndex urn hostName direction  ifAddress/) {
      $subject .=    "<nmwgt:$key>" . $self->$key . "</nmwgt:$key>\n" if  $self->$key;
   }
   $subject .=  q|</nmwgt:interface></nmwg:subject>|;

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
