package Ecenter::Data::PingER;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Requester';

use English qw( -no_match_vars );
use Log::Log4perl qw(get_logger); 
use Data::Dumper;
use perfSONAR_PS::Client::PingER; 
use Ecenter::Types qw(IP_addr PositiveInt);
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


has 'packetsize'  => (is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '1000');
has 'src_regexp' => (is => 'rw', isa => 'Str'); 
has 'dst_regexp' => (is => 'rw', isa => 'Str');
has 'meta_keys'  => (is => 'rw', isa => 'ArrayRef');

sub BUILD {
      my $self = shift;
      my $args = shift; 
      $self->logger(get_logger(__PACKAGE__));
      return  $self->url($args->{url}) if $args->{url};
};


after 'url' => sub {
    my ( $self, $arg ) = @_;
    if($arg) {
        $self->ma(new perfSONAR_PS::Client::PingER( { instance => $arg } ));
        $self->logger->debug(' MA ' .  $arg  .  ' connected ');
    }
}; 


after 'get_metadata' => sub  {
    my ( $self,  $args ) = @_; 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    my $metaids = {};
    my $metad_hr = {};
    my $params = {};
    $params =  { parameters => { packetSize => $self->packetsize} } if $self->packetsize;
 
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
    $self->meta_keys([keys %{$metad_hr}]);
    $self->metadata($metad_hr);
};

after 'get_data' => sub  {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_})  if $self->can($_)} keys %$params if $params && ref $params eq ref {};
   
    my $dresult = $self->ma->setupDataRequest(
        {
            start => $self->start->epoch,
            end   => $self->end->epoch,
            keys  => $self->meta_keys,
            resolution => $self->resolution,
            cf =>  $self->cf,
        }
    );
    my $metaids    = $self->ma->getData($dresult);   
    my @data = ();
    $self->logger->debug(" DATA :: ", sub{ Dumper $metaids  } );
    foreach my $key_id  (keys %{$metaids}) {
	foreach my $id ( keys %{$metaids->{$key_id}{data}}) {
	   foreach my $timev   (sort {$a <=> $b} keys %{$metaids->{$key_id}{data}{$id}}) {
	            push   @data,  [$timev ,  $metaids->{$key_id}{data}{$id}{$timev}];
	    }  
	   
	 } 
     }
    
    return $self->data(\@data);
};  

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
