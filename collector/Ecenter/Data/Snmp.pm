package Ecenter::Data::Snmp;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars );
use Log::Log4perl qw(get_logger); 
use Data::Dumper;
use perfSONAR_PS::Client::MA;  

=head1 NAME

 E-Center::Data::Snmp  data retrieval API for snmp  personar-ps service

=head1 DESCRIPTION

perfSONAR-PS - snmp  data retrieval API,see L<Ecenter::Data::Requester> fro more info
  
=head1 SYNOPSIS 
   
     ## initiate remote query object for the service based on url provided
    my $snmp = E-Center::Data::Snmp( {  url => 'http://xxxxxxxxx' } );
    
    ##  get_metadata is not implemented
    
    ## send request for bwctl data from time to time for interface IP address
    $snmp->get_data({  ifAddress => '131.225.8.10', start => '01-03-2010' , end => '01-05-2010'});
     
   
   
   
=head1 ATTRIBUTES

=over

=item  direction

=item  urn

=item  ifName

=item  ifAddress

=item  ifIndex

=back

=cut

 
has 'direction'  => (is => 'rw', isa => 'Str');
has 'urn'        => (is => 'rw', isa => 'Str');
has 'ifName'     => (is => 'rw', isa => 'Str');
has 'ifIndex'    => (is => 'rw', isa => 'Str');
has 'ifAddress'  => (is => 'rw', isa => 'Str');
has 'hostName'   => (is => 'rw', isa => 'Str');



sub BUILD {
      my $self = shift;
      my $args = shift; 
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

 
after 'get_data' => sub  {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)}  keys %$params if $params && ref $params eq ref {};
   
    my @datum = ();
    return unless $self->hostName or $self->ifAddress;
    my $subject = qq|  <nmwg:subject id="s-in-16"><nmwgt:interface xmlns:nmwgt="http://ggf.org/ns/nmwg/topology/2.0/">|;
    foreach my $key (qw/ifName ifIndex hostName direction  ifAddress/) {
        $subject .=    "<nmwgt:$key>" . $self->$key . "</nmwgt:$key>\n" if  $self->$key;
    }
    $subject .=  q|</nmwgt:interface></nmwg:subject>|;

    # Standard eventType, we could add more
    my @eventTypes = ("http://ggf.org/ns/nmwg/characteristic/utilization/2.0");
    my $ma_result =  $self->ma->setupDataRequest(
        {
            consolidationFunction => $self->cf,
            resolution            => $self->resolution,
            start                 => $self->start->epoch,
            end                   => $self->end->epoch,
            subject               => $subject,
            eventTypes            => \@eventTypes
        }
    );

    my $parser = XML::LibXML->new();
 
    foreach my $d ( @{ $ma_result->{"data"} } ) {
        my $data = $parser->parse_string($d);

        # Extract the datum elements.
        foreach my $dt ( $data->getDocumentElement->getChildrenByTagNameNS( "http://ggf.org/ns/nmwg/base/2.0/", "datum" ) ) {

            # Make sure the time and data are legit.
            if ( $dt->getAttribute("timeValue") =~ m/^\d{10}$/ ) {
		$self->logger->debug("Got valid time: ".$dt->getAttribute("timeValue"));

                if ( $dt->getAttribute("value") and $dt->getAttribute("value") ne "nan" ) {
		    $self->logger->debug("Data value: ".$dt->getAttribute("value"));
                    my $data_value = eval { $dt->getAttribute("value")  };
		    push @datum, [$dt->getAttribute("timeValue"), $data_value];
		    $self->logger->debug("Post-mod data value: ".$data_value);
                }
                else {

                    # these are usually 'NaN' values
                     push @datum, [$dt->getAttribute("timeValue"),$dt->getAttribute("value")];
                }
            }
        }
    }

   return $self->data(\@datum);
};


1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
