package Ecenter::Data::Requester;

use Mouse;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";


use English qw( -no_match_vars );
use Utils qw(check_time validURL  get_links_ends fix_regexp);
use JSON::XS;
use Data::Dumper;
use XML::LibXML;
use perfSONAR_PS::Client::PingER; 
use perfSONAR_PS::Client::MA; 
use Time::Local 'timelocal_nocheck';
use perfSONAR_PS::Common qw( extract find );
use Ecenter::Schema;

=head1 NAME

 E-Center::Data::Requester  data retrieval API for any personar-ps service

=head1 DESCRIPTION

  perfSONAR-PS - data retrieval API 
  
=head1 SYNIPSIS 
 
    ## initiate remote query object for the service based on url provided
    my $requester = E-Center::Data::Requester( {  url => 'http://xxxxxxxxx' } );
    
    ## initiate remote query object for the service based on service id provided
    my $requester = E-Center::Data::Requester( { service => '123' } );
   
    ## send request for pinger data from time to time for the metadata id  - internal to E-Center id
    $requester->get_data({type => 'pinger', metadata => '3333',from => '01-03-2010' , to => '01-05-2010'});
  
    ## send request for pinger data from time to time for the metadata id  - own metaid
    $requester->get_data({type => 'pinger',metaid => '3333', from => '01-03-2010' , to => '01-05-2010'});
  
    ## send request for pinger data from time to time for the src->dst pair of host IP addresses
    $requester->get_data({type => 'pinger',src  => '131.225.10.10', dst => '131.225.10.10', from => '01-03-2010' , to => '01-05-2010'});
  
    ## send request for pinger data from time to time for the closest to src-> closest to dst pair of host IP addresses
    $requester->get_data({type => 'pinger',closest_src  => '131.225.10.10', closest_dst => '131.225.10.10', from => '01-03-2010' , to => '01-05-2010'});
  
    ## send request for bwctl data from time to time for the metadata id  - internal to E-Center id
    $requester->get_data({type => 'bwctl',metadata => '3333',from => '01-03-2010' , to => '01-05-2010'});
   
    ## send request for owamp data from time to time for the metadata id  - internal to E-Center id
    $requester->get_data({type => 'owamp', metadata => '3333',from => '01-03-2010' , to => '01-05-2010'});
    
    ## send request for snmp data from time to time for the metadata id  - internal to E-Center id
    $requester->get_data({type => 'snmp', metadata => '3333',from => '01-03-2010' , to => '01-05-2010'});
   
=head1 ATTRIBUTES

=over

=item  bwctl_data 

=item  pinger_data 

=item  owamp_data 

=item  snmp_data 

=item  url

=item  service

=item  metaid

=item  metadata

=item  src

=item  dst

=item  type

=item  to

=item  from

=back

=cut

has bwctl_data  => (is => 'rw', isa => 'ArrayRef');
has owamp_data  => (is => 'rw', isa => 'ArrayRef');
has pinger_data => (is => 'rw', isa => 'ArrayRef');
has snmp_data   => (is => 'rw', isa => 'ArrayRef');
has url         => (is => 'rw', isa => 'Str');
has service     => (is => 'rw', isa => 'Int');
has src         => (is => 'rw', isa => 'Str');
has dst         => (is => 'rw', isa => 'Str');
has type        => (is => 'rw', isa => 'Str');



sub get_data  {
    my ( $self ) = shift;
    
}
    my (  $self ) = @_;
    #  start a transport agent
    my $param = {};
    $param =  { parameters => { packetSize => $c->stash->{packetsize}} } if $c->stash->{packetsize} && 
                                                                            $c->stash->{packetsize} =~ /^\d+$/;
    my %truncated = ();
    $c->forward('_get_local_cache');  
    foreach my $url (keys %{$c->stash->{remote_ma}}) {
        unless(validURL($url)) {
	    $c->log->warn(" Malformed remote MA URL: $url ");
	    next;
	}
	my $metaids = {};
	unless(%{$c->stash->{remote_ma}{$url}} ) {
	    eval {
        	my $ma = new perfSONAR_PS::Client::PingER( { instance => $url } );
		$c->log->debug(" MA $url  connected: " . Dumper $ma);
        	my $result = $ma->metadataKeyRequest($param);
		$c->log->debug(' result from ma: ' . Dumper $result); 
		$metaids = $ma->getMetaData($result);
	    };
	    if($EVAL_ERROR) {
		$c->log->fatal(" Problem with MA $EVAL_ERROR ");
	    }
	 } else {
	    $metaids = $c->stash->{remote_ma}{$url};
	 }
        foreach  my $meta  (keys %{$metaids}) {
           $c->stash->{stored_links}{$url}{$meta} =  $metaids->{$meta} unless $c->stash->{stored_links}{$url}{$meta}; 
        }
	my $remote_links = $c->stash->{stored_links}{$url};
	
	foreach my $meta  (keys %{$remote_links}) {
	    next if  $remote_links->{$meta}->{src_name} eq '-1';
	    $truncated{$meta} = $remote_links->{$meta} if ((!$c->stash->{src_regexp} ||  $remote_links->{$meta}->{src_name}  =~  $c->stash->{src_regexp}) &&
							   (!$c->stash->{dst_regexp} ||  $remote_links->{$meta}->{dst_name}  =~  $c->stash->{dst_regexp}) &&
							   (!$c->stash->{packetize}  ||  $remote_links->{$meta}->{packetSize} =~  $c->stash->{packetsize}) 
							  );	    
	}	
    } 
    $c->stash->{got_links} = \%truncated;
}  
