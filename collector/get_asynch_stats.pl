#!/usr/bin/perl -w

use strict;
use warnings;

=head1 NAME

get_async_stats.pl - cache program  with asynchronous calls to the remote LSes and mysql backend

=head1 DESCRIPTION

Builds up a list (flat file) of hLS instances that match a certain keyword
query (e.g. 'LHC' and related combinations).

=head1 SYNOPSIS

./get_lhs.pl --key=LHC_OPN

it will try to query fo all possible combinations:
LHC, lhc, LHC-OPN, LHCOPN, lhcopn, lhc-opn
Please notice the usage of '_' instead of '-' in the supplied key. It will try to match all combinations.
Default: * - all keywords

=head1 OPTIONS

=over

=item --verbose|v

=item --k|key=[project key]

keyword to query

=item --help|h|?

print help
   
=item --user|u

backend DB username

=item --pass|p

backend DB password   

=back

=head1 FUNCTIONS

=cut
use English;

use forks;
use forks::shared 
    deadlock => {
    detect => 1,
    resolve => 1
};

use XML::LibXML;
use Getopt::Long;
use Data::Dumper;
use Data::Validate::IP qw(is_ipv4);
use Data::Validate::Domain qw( is_domain );
use Net::IPv6Addr;
use Net::CIDR;
use POSIX qw(strftime);
use Pod::Usage;
use FindBin;
use Log::Log4perl qw(:easy);
use Benchmark;

use lib  "$FindBin::Bin";
use Ecenter::Schema;


#use lib "/usr/local/perfSONAR-PS/lib";

use perfSONAR_PS::Common qw( extract find unescapeString escapeString );
use perfSONAR_PS::Client::gLS;
use perfSONAR_PS::Error_compat qw/:try/;
use perfSONAR_PS::Error;
use perfSONAR_PS::Client::Echo;

our ($DEBUGFLAG, $HELP, $KEY, $PASS, $USER) = ('','','','','');

our %SERVICE_PARAM = ( url => [qw/accessPoint address/], 
		       name => [qw/serviceName name/],
        	       type => [qw/serviceType type/],
        	       comments => [qw/serviceDescription description/],
);
our %SERVICE_LOOKUP = (  'http://ggf.org/ns/nmwg/characteristic/utilization/2.0' => 'snmp',
                         'http://ggf.org/ns/nmwg/tools/snmp/2.0'    => 'snmp',
                         'http://ggf.org/ns/nmwg/tools/pinger/2.0/' => 'pinger',
			 'http://ggf.org/ns/nmwg/tools/pinger/2.0'  => 'pinger',
                         'http://ggf.org/ns/nmwg/characteristics/bandwidth/acheiveable/2.0' => 'bwctl',
			 'http://ggf.org/ns/nmwg/characteristics/bandwidth/achieveable/2.0' => 'bwctl',
			 'http://ggf.org/ns/nmwg/characteristics/bandwidth/achievable/2.0'  => 'bwctl',
			 'http://ggf.org/ns/nmwg/tools/bwctl/1.0' => 'bwctl',
			 'http://ggf.org/ns/nmwg/tools/iperf/2.0' => 'bwctl',
                         'http://ggf.org/ns/nmwg/tools/owamp/2.0' => 'owamp',
			 'http://ggf.org/ns/nmwg/tools/owamp/1.0' => 'owamp',
                         'http://ggf.org/ns/nmwg/tools/traceroute/1.0' => 'traceroute',
                         'http://ggf.org/ns/nmwg/tools/npad/1.0' => 'npad',
                         'http://ggf.org/ns/nmwg/tools/ndt/1.0'  => 'ndt',
                         'http://ggf.org/ns/nmwg/tools/ping/1.0' => 'ping',
                         'http://ggf.org/ns/nmwg/tools/phoebus/1.0' => 'phoebus',
);
our $DISCOVERY_EVENTTYPE = 'http://ogf.org/ns/nmwg/tools/org/perfsonar/service/lookup/discovery/xquery/2.0';
our $QUERY_EVENTTYPE = 'http://ogf.org/ns/nmwg/tools/org/perfsonar/service/lookup/query/xquery/2.0';

my $status = GetOptions(
    'v|verbose'   => \$DEBUGFLAG,
    'k|key=s'     => \$KEY,
    'p|password=s'    => \$PASS,
    'u|user=s'    => \$USER,
    'help|h|?'    => \$HELP,
) or pod2usage(1);

$DEBUGFLAG?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(2) if ( $HELP || !($USER && $PASS));

my $parser = XML::LibXML->new();
my $hints  = "http://www.perfsonar.net/gls.root.hints";
my @private_list = ( "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" );
my $pattern = '';
my %hls = ();
my $gls = perfSONAR_PS::Client::gLS->new( { url => $hints } );

$logger->logdie("roots not found") unless ( $#{ $gls->{ROOTS} } > -1 );
 
my %threads = ();
# 
my $thread_counter=1;
my $hls_query =  qq|declare namespace perfsonar="http://ggf.org/ns/nmwg/tools/org/perfsonar/1.0/";
 	    declare namespace nmwg="http://ggf.org/ns/nmwg/base/2.0/";
 	    declare namespace psservice="http://ggf.org/ns/nmwg/tools/org/perfsonar/service/1.0/";
 	    /nmwg:store[\@type="LSStore"]/nmwg:metadata
 	    [./perfsonar:subject/psservice:service/psservice:serviceType[matches(text(), '^[hH]?ls', 'i')]]
	    |;
if($KEY) {
    ($pattern  = $KEY) =~ s/_([^_]+)/\\\-?($1)?/g;
    $logger->debug("Pattern: $pattern");
    $hls_query =  qq|declare namespace nmwg="http://ggf.org/ns/nmwg/base/2.0/";
       for \$metadata in /nmwg:store[\@type="LSStore"]/nmwg:metadata
         let \$metadata_id := \$metadata/\@id
         let \$data := /nmwg:store[\@type="LSStore"]/nmwg:data[\@metadataIdRef=\$metadata_id]
         where \$data/nmwg:metadata[(.//nmwg:parameter[
 				     \@name="keyword" 
 					 and ( matches(\@value, '^project\:$pattern', 'xi')
 					       or matches(text(),'^project\:$pattern', 'xi')
 					      )
 				                    ]
 			         )]
        return \$metadata|;
}
 
for my $root ( @{ $gls->{ROOTS} } ) {  
    $logger->info("Root:\t$root");
    my $result = $gls->getLSQueryRaw( { ls => $root, xquery =>   $hls_query } );
    
    if ( exists $result->{eventType} && $result->{eventType} !~ m/^error/ ) {
        $logger->debug("\tEventType:\t$result->{eventType}");
        my $doc = $parser->parse_string( $result->{response} ) if exists $result->{response};
        my $service = find( $doc->getDocumentElement, ".//*[local-name()='service']", 0 );
        foreach my $s ( $service->get_nodelist ) {  
	  ### run query/echo/ping async
	    $threads{$thread_counter} = threads->new( sub {
		my $now_str = strftime('%Y-%m-%d %H:%M:%S', localtime());
		my $dbh =  Ecenter::Schema->connect('DBI:mysql:ecenter',  $USER, $PASS);
 		my $keyword_str = $pattern;
        	my $accessPoint = extract( find( $s, ".//*[local-name()='accessPoint']", 1 ), 0 );
		my $serviceName = extract( find( $s, ".//*[local-name()='serviceName']", 1 ), 0 );
        	my $serviceType = extract( find( $s, ".//*[local-name()='serviceType']", 1 ), 0 );
        	my $serviceDescription = extract( find( $s, ".//*[local-name()='serviceDescription']", 1 ), 0 );
        	try {
		    if ( $accessPoint ) {
                	$logger->debug("\t\thLS:\t$accessPoint");
                	my $test = $accessPoint;                
                	$test =~ s/^http:\/\///;
                	my ( $unt_test ) = $test =~ /^(.+):/;
                	if ( $unt_test 
			     and ( (is_ipv4( $unt_test ) && !Net::CIDR::cidrlookup( $unt_test, @private_list )) 
		        	   or  &Net::IPv6Addr::is_ipv6( $unt_test ) 
				   or  (is_domain( $unt_test ) &&  $unt_test !~ m/^localhost/ )
				 ) 
			    ) {
			    my $echo_service = perfSONAR_PS::Client::Echo->new( $accessPoint );
                	    my ( $status, $res ) = $echo_service->ping();
			    my $hls = $dbh->resultset('Service')->update_or_create({ name => $serviceName,
		                                                        	     url   =>   $accessPoint,
		                                                        	     type => $serviceType,
								        	     comments => $serviceDescription,
								        	     is_alive => (!$status?'1':'0'), 
								        	     updated =>  $now_str
								        	    },
									      { key => 'service_url'}
									     );
			    unless($status)  {
		        	get_fromHLS($accessPoint, $now_str, $hls, $dbh);
			    }
                	 }  else  {
                	    $logger->debug("\t\t\tReject:\t$unt_test");
                	 }
        	     }
		} 
		catch perfSONAR_PS::Error   with {
		    $logger->error( shift);
		} catch perfSONAR_PS::Error_compat with {
                    $logger->error( shift);
        	}
        	otherwise {
                    my $ex  = shift; 
                    $logger->error("Unhandled exception or crash: $ex");
        	}
		finally {
	            $dbh->storage->disconnect if $dbh;
		};
	    });
	}
    }
    else {
        if ( $DEBUGFLAG ) {
             $logger->debug("\tResult:\t" , sub{Dumper($result)});
        }
   }
}
foreach my $node_key (keys %threads) {
   sleep 1 while($threads{$node_key}->is_running());
   $threads{$node_key}->detach();
}
 
=head2 ls_store_request

try hls twice

=cut
 
sub ls_store_request {
   my ($ls) = @_;
   my $h_query = qq|declare namespace perfsonar="http://ggf.org/ns/nmwg/tools/org/perfsonar/1.0/";
	                  declare namespace nmwg="http://ggf.org/ns/nmwg/base/2.0/";
	                  declare namespace psservice="http://ggf.org/ns/nmwg/tools/org/perfsonar/service/1.0/";
			  /nmwg:store[\@type="LSStore"]|;
   my $result = $ls->queryRequestLS(
        {
            query     =>  $h_query,
            eventType =>  $QUERY_EVENTTYPE,
            format    => 1
        } );
    if ( exists $result->{eventType}  && $result->{eventType} eq "error.ls.query.ls_output_not_accepted" ) {
        $result = $ls->queryRequestLS(
            {
                query     => $h_query,
                eventType => $QUERY_EVENTTYPE,
            }
        );
    }
    return $result;
}


=head2  get_fromHLS

main processing unit, returns nothing  

=cut

sub get_fromHLS {
    my ($hls_url, $now_str, $hls_obj, $dbh) = @_;
    my $logger = get_logger(__PACKAGE__);
    $logger->debug("hLS: $hls_url............");
    my $ls = new perfSONAR_PS::Client::LS( { instance => $hls_url } );
    my $result = ls_store_request($ls);
    return unless   ( exists $result->{eventType} and not( $result->{eventType} =~ m/^error/ ) );
    $logger->debug("EventType: $result->{eventType}");
    $result->{response} = unescapeString( $result->{response} );
    my $doc;
    eval {
    	$doc = $parser->parse_string( $result->{response} ) if exists $result->{response};
    };
    if($EVAL_ERROR) {
        $logger->warning("This hls $hls_url failed ");
        $hls_obj->is_active(0);
        return;
    }
    my $md = find( $doc->getDocumentElement, "./nmwg:store/nmwg:metadata", 0 );
    my $d  = find( $doc->getDocumentElement, "./nmwg:store/nmwg:data",     0 );
    # create lookup hash to avoid multiple array parsing
    my %look_data_id =  map {   $_->getAttribute("metadataIdRef") => $_ } $d->get_nodelist;
    
    foreach my $m1 ( $md->get_nodelist ) {
   	my $id = $m1->getAttribute("id");  
	my %param_exist = ();
	foreach my $param (keys %SERVICE_PARAM) {
	    foreach my $try (@{$SERVICE_PARAM{$param}}) {
	        $param_exist{$param} ||=   extract( find( $m1, "./*[local-name()='subject']//*[local-name()='$try']", 1 ), 0 );
	    }
        }
	next unless $param_exist{url};
	$param_exist{is_alive} = 1;
	$param_exist{updated} =  $now_str;
	if(!$param_exist{type} || $param_exist{type} =~ /^(MA|MP)$/) {
	    ($param_exist{type}) = $param_exist{url} =~ /^http.+\/services\/(\w+)/; 
	    $param_exist{type} = lc($param_exist{type});
	    $param_exist{type} = 'bwctl' if  $param_exist{type} =~ /psb/;
	    $param_exist{type} = 'snmp' if  $param_exist{type} eq 'snmpma';
	}
	$param_exist{type} ||= 'N/A';
	$param_exist{name} ||= 'N/A';
	my $service_obj =  $dbh->resultset('Service')->update_or_create( \%param_exist,{ key => 'service_url' } ); 
      
	##############  data part processing
        my $d1 = $look_data_id{$id};
	next unless $d1;
   	# get the keywords
   	my $keywords = find( $d1, "./nmwg:metadata/summary:parameters/nmwg:parameter", 0 );
   	my %keyword_hash = map { $_ => 1 } 
			   grep {defined $_}  
	        	   map {extract($_, 0)}  
	        	   grep {$_->getAttribute("name") eq 'keyword'}
	        	   $keywords->get_nodelist;
	map { $logger->debug("DATA $id  MD element:::" . $d1->toString) }  @service_mds ;
   	# get the eventTypes
    	foreach my  $keyword_str (keys %keyword_hash) {
	    my $keyword = $dbh->resultset('Keyword')->find_or_create({ keyword => $keyword_str,
								       created => $now_str
								    });
	     $dbh->resultset('Keywords_Service')->update_or_create( { keyword => $keyword_str,
								      service =>  $hls_obj
								    },
								    { key => 'keywords_service' }
								  );
 	     $dbh->resultset('Keywords_Service')->update_or_create( { keyword => $keyword_str,
								      service =>  $service_obj
								    },
								    { key => 'keywords_service' } 
								  );
	}
	my $eventTypes = find( $d1 , "./nmwg:metadata/nmwg:eventType", 0 );
	my $type_of_service =  $param_exist{type};
        foreach my $e ( $eventTypes->get_nodelist ) {
   	    my $value = extract( $e, 0 );
	    if($SERVICE_LOOKUP{$value}) {
		$service_obj->type($SERVICE_LOOKUP{$value});
		$type_of_service = $SERVICE_LOOKUP{$value};
	    }
	    $dbh->resultset('Eventtype')->update_or_create( { eventtype =>  $value,
							       service =>  $service_obj
							    },
							    {key => 'eventtype_service'}
							  );
	}
	my ($service_mds) =  @{$d1->findnodes("./nmwg:metadata/*[local-name()='subject']")};
	my $subj =  $md_data->find("./*[local-name()='subject']");
	my $parameters = $md_data->find("./nmwg:parameters'");
	my $meta_row = $dbh->resultset('Metadata')->update_or_create( { metaid =>  $mdid,
							     service =>   $service_obj,
							     subject =>  $subj->toString(),
							     parameters => $parameters->toString(), 
							    }
							  );
    }
}

=head2     $process_subject 

processing metadata subject callbacks
must implement and return hashref of the structure:
{ '<mdid>' => {'<param1>' =>    }

=cut

my $process_subject = (
    pinger => sub {  },
    owamp=> sub {},
    bwctl => sub {},
    snmp => sub {},
    traceroute => sub {},
    npad => sub {},
    ndt => sub {},
);
 
__END__

=head1 SEE ALSO

L<XML::LibXML>, L<Carp>, L<Getopt::Long>, L<Data::Dumper>,
L<Data::Validate::IP>, L<Data::Validate::Domain>, L<Net::IPv6Addr>,
L<Net::CIDR>, <DBIx::Class>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn

To join the 'perfSONAR-PS' mailing list, please visit:

  https://mail.internet2.edu/wws/info/i2-perfsonar

The perfSONAR-PS subversion repository is located at:

  https://svn.internet2.edu/svn/perfSONAR-PS

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

inpired by Jason Zurawski's cache.pl, zurawski@internet2.edu
Maxim Grigoriev, maxim_at_fnal_dot_gov

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010, Fermitools

All rights reserved.

=cut

