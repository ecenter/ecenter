package Ecenter::Data::Bwctl;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars ); 
use Data::Dumper;
use XML::LibXML;
use perfSONAR_PS::Client::MA; 
use Time::Local 'timelocal_nocheck';
use perfSONAR_PS::Common qw( extract find );
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

has 'meta_keys'  => (is => 'rw', isa => 'ArrayRef');

sub BUILD {
      my $self = shift;
      my $args = shift; 
      $self->logger(get_logger(__PACKAGE__));
      return  $self->url($args->{url}) if $args->{url};
};

after 'url' => sub {
    my ( $self, $arg ) = @_;
    $self->type('pinger');
    if($arg) {
        $self->ma(new perfSONAR_PS::Client::PingER( { instance => $arg } ));
        $self->logger->debug(' MA ' .  $arg  .  ' connected ');
    }
}; 

after 'get_metadata' => sub {


};


after  'get_data' => sub   {
    my ( $self ) = shift;
    my $ma = new perfSONAR_PS::Client::MA( { instance => $self->url } );
    my @eventTypes = ();
    my $parser     = XML::LibXML->new();
    my $sec        = time;
    my $subject = "  <nmwg:key id=\"key-1\">\n";
    $subject .= "    <nmwg:parameters id=\"parameters-key-1\">\n";
    $subject .= "      <nmwg:parameter name=\"maKey\">" . $cgi->param( 'key' ) . "</nmwg:parameter>\n";
    $subject .= "    </nmwg:parameters>\n";
    $subject .= "  </nmwg:key>  \n";
    
    
    
    
    $self->bwctl_data();
};


=head2 retrieveData ( { params } )

Retrieve data based on a key using the given parameters

=cut

sub retrieveData{
    my @eventTypes = ();
    
    my $subject = "  <nmwg:key id=\"key-1\">\n";
    $subject .= "    <nmwg:parameters id=\"parameters-key-1\">\n";
    $subject .= "      <nmwg:parameter name=\"maKey\">" . $self->metaid .  "</nmwg:parameter>\n";
    $subject .= "    </nmwg:parameters>\n";
    $subject .= "  </nmwg:key>  \n";

    my $result = self->->setupDataRequest(
        {
            start      => $parameters->{'start'},
            end        => $parameters->{'end'},
            subject    => $subject,
            eventTypes => \@eventTypes
        }
    );

    my $doc1 = q{};
    eval { $doc1 = $parameters->{'parser'}->parse_string( $result->{"data"}->[0] ); };
    if ( $EVAL_ERROR ) {
        print "<html><head><title>perfSONAR-PS perfAdmin Bandwidth Graph</title></head>";
        print "<body><h2 align=\"center\">Cannot parse XML response from service.</h2></body></html>";
        exit( 1 );
    }

    my $datum1 = find( $doc1->getDocumentElement, "./*[local-name()='datum']", 0 );
    if ( $datum1 ) {
        foreach my $dt ( $datum1->get_nodelist ) {
            my $secs = UnixDate( $dt->getAttribute( "timeValue" ), "%s" );
            $parameters->{'store'}->{$secs}{$parameters->{'storeType'}} = eval( $dt->getAttribute( "throughput" ) ) if $secs and $dt->getAttribute( "throughput" );
        }
    }
};

1;
