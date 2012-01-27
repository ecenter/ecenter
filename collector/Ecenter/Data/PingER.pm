package Ecenter::Data::PingER;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars );
use Log::Log4perl qw(get_logger); 
use Data::Dumper;
use perfSONAR_PS::Client::PingER; 
use Ecenter::Types qw(IPAddr PositiveInt);
use DateTime; 

=head1 NAME

 E-Center::Data::PingER  data retrieval API for pinger personar-ps service

=head1 DESCRIPTION

perfSONAR-PS - pinger  data retrieval API,see L<Ecenter::Data::Requester> fro more info
  
=head1 SYNOPSIS 
   
     ## initiate remote query object for the service based on url provided
    my $pinger = E-Center::Data::PingER( {  url => 'http://xxxxxxxxx' } );
    
    ## send request for pinger metadata  
    $pinger->get_metadata({src_regexp => '131.225.*'} );
      
    ## send request for bwctl data from time to time for the metadata keys
    $pinger->get_data({  meta_keys => ['3333'], start => '01-03-2010' , end => '01-05-2010'});
     
    The same could be repeated for OWMAP or PingER, just initialize different object
    
     my $owamp = E-Center::Data::Owamp( {  url => 'http://xxxxxxxxx' } );
   
   
=head1 ATTRIBUTES

=over

=item  src_regexp

=item  dst_regexp

=item  metadata

=back

=cut


has 'packetsize' => (is => 'rw', isa => 'Ecenter::Types::PositiveInt');
has 'src_regexp' => (is => 'rw', isa => 'Str'); 
has 'dst_regexp' => (is => 'rw', isa => 'Str');
has 'src_name'   => (is => 'rw', isa => 'Str');
has 'dst_name'   => (is => 'rw', isa => 'Str');
has 'data'       => (is => 'rw', isa => 'ArrayRef');

sub BUILD {
      my $self = shift;
      my $args = shift; 
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/pinger/2.0/")]);
      $self->namespace("http://ggf.org/ns/nmwg/tools/pinger/2.0/");
      $self->nsid("pinger");
##      $self->resolution(10000);
      $self->logger(get_logger(__PACKAGE__));  
      map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
      return  $self->url if $args->{url};
};


after 'url' => sub {
    my ( $self, $arg ) = @_;
    if($arg) {
        $self->ma(new perfSONAR_PS::Client::PingER( { instance => $arg, timeout => $self->timeout } ));
        $self->logger->debug(' MA ' .  $arg  .  ' connected ');
    }
}; 


after 'get_metadata' => sub  {
    my ( $self,  $args ) = @_; 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    my $metaids = {};
    my $metad_hr = {};
    unless( ($self->src_name && $self->dst_name ) || $self->subject) {
        $self->logger->logdie(" Missed src_name and  dst_name ");
    } 
    my $params = $self->subject?{subject => $self->subject}:{src_name => $self->src_name, dst_name => $self->dst_name};
    $params->{parameters}{packetSize} = $self->packetsize if $self->packetsize;
    $self->logger->debug(" -------------------METADATA REQUEST:: ", sub{ Dumper  $params } );    
    eval {
        my $result = $self->ma->metadataKeyRequest($params);
        $metaids = $self->ma->getMetaData($result);
    };
    if($EVAL_ERROR) {
	$self->logger->logdie(" Problem with MA $EVAL_ERROR ");
    }   
    $self->logger->debug(" MD :: ", sub{ Dumper $metaids  } );
    my $src_regexp = $self->src_regexp?$self->src_regexp:'';
    my $dst_regexp = $self->dst_regexp?$self->dst_regexp:'';
    $self->logger->debug(" REGEXPS::: $src_regexp $dst_regexp ");
    
    foreach  my $meta  (keys %{$metaids}) {
        next if  $metaids->{$meta}->{src_name} eq '-1';
	$metad_hr->{$meta} =  $metaids->{$meta} if ((!$self->src_regexp ||  $metaids->{$meta}->{src_name}  =~  m/$src_regexp/) &&
							   (!$self->dst_regexp ||  $metaids->{$meta}->{dst_name}  =~  m/$dst_regexp/) &&
							   (!$self->packetsize  ||  $metaids->{$meta}->{packetSize} == $self->packetsize) 
							  );	    
    }
    $self->meta_keys([ map {@{$metad_hr->{$_}{keys}}} keys %{$metad_hr}]);
    $self->metadata($metad_hr);
};

after 'get_data' => sub  {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_})  if $self->can($_)} keys %$params if $params && ref $params eq ref {};
    unless($self->meta_keys || ($self->src_name && $self->dst_name )  || $self->subject) {
        $self->logger->logdie(" Missed src_name and  dst_name or meta_keys parameter ");
    } 
   
    $self->get_metadata() unless $self->meta_keys;
    $self->logger->debug(" -------------------METADATA :: ", sub{ Dumper $self->meta_keys } );
    unless($self->meta_keys) {
          $self->logger->error(" No metadata returned !!! ");
	  return;
    }
    my $request =  {
            start => $self->start->epoch,
            end   => $self->end->epoch,
	    keys =>   $self->meta_keys,
            resolution => $self->resolution,
            cf =>  $self->cf
        };
    my $dresult = $self->ma->setupDataRequest( $request );
    my $metaids    = $self->ma->getData($dresult);   
    my @data = ();
    $self->logger->debug(" DATA :: ", sub{ Dumper $metaids  } );
    foreach my $key_id  (keys %{$metaids}) {
	foreach my $id ( keys %{$metaids->{$key_id}{data}}) {
	   foreach my $timev   (sort {$a <=> $b} keys %{$metaids->{$key_id}{data}{$id}}) {
	            push   @data,  [$timev,  $metaids->{$key_id}{data}{$id}{$timev}];
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
