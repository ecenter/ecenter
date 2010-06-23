#!/usr/bin/perl -w

use strict;
use warnings;

=head1 NAME

get_asynch_stats.pl - cache program  with asynchronous calls to the perfSONAR-PS remote LSes and mysql backend

=head1 DESCRIPTION

 Inserts found perfSONAR-PS service's metadata into the backend DB. Runs asynchrounously. Spawns many processes.

=head1 SYNOPSIS

./get_asynch_stats.pl  --key=lhc --procs=20 --password=<db password> --user=<db username>

it will try to query fo all possible combinations:
LHC, lhc, LHC-OPN, LHCOPN, lhcopn, lhc-opn
Please notice the usage of '_' instead of '-' in the supplied key. It will try to match all combinations.
Default: * - all keywords

=head1 OPTIONS

=over

=item --debug

debugging info logged

=item --key=[project key]

keyword to query

=item --procs

number of asynchronous procs to spawn ( requests to remote hLses)
Max number is 40.
Default: 10
   
=item --help

print help

=item -db=[database name]

backend DB name
Default: ecenter_data


=item --user=[db username]

backend DB username
Default: ecenter

=item --password=[db password]

backend DB password   
Default: from /etc/my_ecenter

=back


=cut

use English;

use forks;
use forks::shared 
    deadlock => {
    detect => 1,
    resolve => 1
};
use Time::HiRes qw(usleep);

use XML::LibXML;
use Getopt::Long;
use Data::Dumper;
use POSIX qw(strftime);
use Pod::Usage;
use FindBin;
use Log::Log4perl qw(:easy);
use Ecenter::Utils;

use lib  "$FindBin::Bin";
use Ecenter::Schema;
use aliased 'perfSONAR_PS::PINGER_DATATYPES::v2_0::nmwgt::Message::Metadata::Subject::EndPointPair';
use aliased 'perfSONAR_PS::PINGERTOPO_DATATYPES::v2_0::nmtl3::Topology::Domain::Node::Port';

#use lib "/usr/local/perfSONAR-PS/lib";

use perfSONAR_PS::Common qw( extract find unescapeString escapeString );
use perfSONAR_PS::Client::gLS;
use perfSONAR_PS::Error_compat qw/:try/;
use perfSONAR_PS::Error;
use perfSONAR_PS::Client::Echo;


# Maximum working threads
my $MAX_THREADS = 10;

 
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
our $QUERY_EVENTTYPE     = 'http://ogf.org/ns/nmwg/tools/org/perfsonar/service/lookup/query/xquery/2.0';


my %OPTIONS;
my @string_option_keys = qw/key password user db procs/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help/,
) or pod2usage(1);

$OPTIONS{debug}?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
my  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(-verbose => 2) if ( $OPTIONS{help} || ($OPTIONS{procs} && $OPTIONS{procs} !~ /^\d\d?$/));

$MAX_THREADS = $OPTIONS{procs} if $OPTIONS{procs} > 0 && $OPTIONS{procs}  < 40;

$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';
unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{password};
} 
my $parser = XML::LibXML->new();
my $hints  = "http://www.perfsonar.net/gls.root.hints";
my $pattern = '';
my %hls_cache = ();
my $gls = perfSONAR_PS::Client::gLS->new( { url => $hints } );
$logger->info(" MAX THREADS = $MAX_THREADS ");

$logger->logdie("roots not found") unless ( $#{ $gls->{ROOTS} } > -1 );
 
my %threads   = ();
# 
my $thread_counter=1;
my $hls_query =  qq|declare namespace perfsonar="http://ggf.org/ns/nmwg/tools/org/perfsonar/1.0/";
 	    declare namespace nmwg="http://ggf.org/ns/nmwg/base/2.0/";
 	    declare namespace psservice="http://ggf.org/ns/nmwg/tools/org/perfsonar/service/1.0/";
 	    /nmwg:store[\@type="LSStore"]/nmwg:metadata
 	    [./perfsonar:subject/psservice:service/psservice:serviceType[matches(text(), '^[hH]?ls', 'i')]]
	    |;
if($OPTIONS{key}) {
    ($pattern  = $OPTIONS{key}) =~ s/_([^_]+)/\\\-?($1)?/g;
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
        $logger->debug("\tEvenType:\t$result->{eventType}");
        my $doc = $parser->parse_string( $result->{response} ) if exists $result->{response};
        my $service = find( $doc->getDocumentElement, ".//*[local-name()='service']", 0 );
        foreach my $s ( $service->get_nodelist ) {  
	  ### run query/echo/ping async	   
	    
	    pool_control($MAX_THREADS, 0);
	    $threads{$thread_counter} = threads->new( sub {
		my $now_str = strftime('%Y-%m-%d %H:%M:%S', localtime());
		$logger->debug("Connecting... 'DBI:mysql:$OPTIONS{db}");
		my $dbh =  Ecenter::Schema->connect('DBI:mysql:' . $OPTIONS{db},  $OPTIONS{user}, $OPTIONS{password}, {RaiseError => 1, PrintError => 1});
		$dbh->storage->debug(1) if $OPTIONS{debug};
		
 		my $keyword_str = $pattern;
        	my $accessPoint = extract( find( $s, ".//*[local-name()='accessPoint']", 1 ), 0 );
		my $serviceName = extract( find( $s, ".//*[local-name()='serviceName']", 1 ), 0 );
        	my $serviceType = extract( find( $s, ".//*[local-name()='serviceType']", 1 ), 0 );
        	my $serviceDescription = extract( find( $s, ".//*[local-name()='serviceDescription']", 1 ), 0 );
		return if exists $hls_cache{$accessPoint};
		return  if !$accessPoint || $serviceType =~ /^ping$/i;
		#return unless $accessPoint =~ /ps\d+\.es|fnal\.gov/;
        	try {		  
                    $logger->debug("\t\thLS:\t$accessPoint");
                    my ($ip_addr,$ip_name) = get_ip_name($accessPoint); 	       
                    if($ip_addr) {
		    	my $echo_service = perfSONAR_PS::Client::Echo->new( $accessPoint );
                    	my ( $status, $res ) = $echo_service->ping();
			 
			$hls_cache{$accessPoint}++;
		    	update_create_fixed($dbh->resultset('Node'),
		    					      {ip_addr =>  \"=inet6_pton('$ip_addr')"},
		    					      {ip_addr => \"inet6_pton('$ip_addr')",
		    					       nodename => $ip_name,
		    					       ip_noted => $ip_addr}); 
		    	#$logger->info(" ip_addr " , sub {Dumper($ip_addr$ip_addr_obj )});
		    	my $ip_addr_obj =  $dbh->resultset('Node')->find({ip_noted => $ip_addr});
		    	my $hls = $dbh->resultset('Service')->update_or_create({ name => $serviceName,
		    								 url   =>   $accessPoint,
		    								 type => $serviceType,
		    								 ip_addr =>  $ip_addr_obj,
		    								 comments => $serviceDescription,
		    								 is_alive => (!$status?'1':'0'), 
		    								 updated =>  \"NOW()",
										},
		    							  { key => 'service_url'}
		    							 );
		    	unless($status)  {
		    	    get_fromHLS($accessPoint, $now_str, $hls, $dbh);
		    	}
                     }  else  {
                    	$logger->debug("\t\t\tReject:\t$accessPoint)");
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
       $logger->debug("\tResult:\t" , sub{Dumper($result)});
   }
}
pool_control($MAX_THREADS, 'finish_it');  


=head2 ls_store_request

try hls twice

=cut
 
sub ls_store_request {
   my ($ls, $eventtype) = @_;
   my $h_query = qq|declare namespace perfsonar="http://ggf.org/ns/nmwg/tools/org/perfsonar/1.0/";
	                  declare namespace nmwg="http://ggf.org/ns/nmwg/base/2.0/";
			  declare namespace nmwgt="http://ggf.org/ns/nmwg/topology/2.0/";
	                  declare namespace psservice="http://ggf.org/ns/nmwg/tools/org/perfsonar/service/1.0/";
			  /nmwg:store[\@type="LSStore"]|;
   my $result = $ls->queryRequestLS(
        {
            query     =>  $h_query,
            eventType =>  $eventtype,
        } );
    if ( exists $result->{eventType}  && $result->{eventType} eq "error.ls.query.ls_output_not_accepted" ) {
        $result = $ls->queryRequestLS(
            {
                query     => $h_query,
                eventType =>  $eventtype,
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
    my $result_disc  = ls_store_request($ls, $DISCOVERY_EVENTTYPE);
    my $result_query = ls_store_request($ls, $QUERY_EVENTTYPE);
    
    unless( exists $result_disc->{eventType} and not( $result_disc->{eventType} =~ m/^error/ ) ) {
        $logger->error(" HLS:: $hls_url got an error when running discovery query", sub {Dumper($result_query)});
	return;
    }
    unless( exists $result_query->{eventType} and not( $result_query->{eventType} =~ m/^error/ ) ) {
        $logger->error(" HLS:: $hls_url got an error when running  query", sub {Dumper($result_query)});
	return;
    }
    $logger->debug("EventType: $result_disc->{eventType}");
    $result_disc->{response} = unescapeString( $result_disc->{response} );
    $result_query->{response} = unescapeString( $result_query->{response} );
    my ($doc_disc,$doc_query);
    eval {
    	$doc_disc  = $parser->parse_string( $result_disc->{response} )  if exists $result_disc->{response};
	$doc_query = $parser->parse_string( $result_query->{response} ) if exists $result_query->{response};
    };
    if($EVAL_ERROR) {
        $logger->error("This hls $hls_url failed ");
        $hls_obj->is_alive(0);
        return;
    }
    my $md_query = find( $doc_query->getDocumentElement, "./nmwg:store/nmwg:metadata", 0 );
    my $d_disc   = find( $doc_disc->getDocumentElement, "./nmwg:store/nmwg:data",      0 );
    my $d_query  = find( $doc_query->getDocumentElement, "./nmwg:store/nmwg:data",     0 );
    # create lookup hash to avoid multiple array parsing
    my %look_data_query_id= ();
    foreach my $data_obj ($d_query->get_nodelist)  {
        push @{$look_data_query_id{$data_obj->getAttribute("metadataIdRef")}}, $data_obj if $data_obj && ref $data_obj eq 'XML::LibXML::Element';
    }
    foreach my $m1 ( $md_query->get_nodelist ) {
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
	if(!$param_exist{type} || $param_exist{type} =~ /^(MA|MP|TS)$/i) {
	    ($param_exist{type}) = $param_exist{url} =~ /^http.+\/services\/(\w+)/; 
	    $param_exist{type} = lc($param_exist{type});
	    $param_exist{type} = 'bwctl' if  $param_exist{type} =~ /psb/;
	    $param_exist{type} = 'snmp' if  $param_exist{type} eq 'snmpma';
	}
	$param_exist{type} ||= 'N/A';
	$param_exist{name} ||= 'N/A';
	my ( $ip_noted , $nodename) = get_ip_name(  $param_exist{url} );
	next unless $ip_noted;
	update_create_fixed($dbh->resultset('Node'),
			                              {ip_addr =>  \"=inet6_pton('$ip_noted')"},
			                              {ip_addr => \"inet6_pton('$ip_noted')",
			                               nodename =>  $nodename,
						       ip_noted => $ip_noted,
						      }); 
						      
	  my   $ip_addr = $dbh->resultset('Node')->find({ip_noted => $ip_noted  });
	 $param_exist{ip_addr}	 =  $ip_addr->ip_addr;						   
	 my $service_obj =$dbh->resultset('Service')->find_or_create( \%param_exist,{ key => 'service_url' } ); 
       ## my $service_obj =  $dbh->resultset('Service')->find({url => $param_exist{url}});
	$logger->info(" Found for url $param_exist{url} service=" .$service_obj->service);
	
	next unless $service_obj;
	##############  data part processing
        ###my $d1_disc = $look_data_disc_id{$id};
	next unless $look_data_query_id{$id};
	my @d1_query = @{$look_data_query_id{$id}};
	$logger->info(" Found  something  ", sub{Dumper($look_data_query_id{$id})});
   	# get the keywords
	foreach my $d1_el (@d1_query) {
	    my $data_id =  $d1_el->getAttribute("id");
   	    my $keywords = find( $d1_el, "./nmwg:metadata/nmwg:parameters/nmwg:parameter", 0 );
   	    my %keyword_hash = map { $_ => 1 } 
			       grep {defined $_}  
	        	       map {extract($_, 0)}  
	        	       grep {$_->getAttribute("name") eq 'keyword'}
	        	       $keywords->get_nodelist;
            my $param_md =  find( $d1_el, "./nmwg:metadata/nmwg:parameters", 1);
             # get the eventTypes
    	    foreach my  $keyword_str (keys %keyword_hash) {
	        $logger->debug("KEYWORD=$keyword_str");
		my $keyword = $dbh->resultset('Keyword')->find_or_create({ keyword => $keyword_str });
		$dbh->resultset('Keywords_Service')->update_or_create( { keyword => $keyword_str,
									  service =>  $hls_obj
									},
									{ key => 'keywords_service' }
								      );
 		 $dbh->resultset('Keywords_Service')->update_or_create( { keyword => $keyword_str,
									  service =>  $service_obj->service
									},
									{ key => 'keywords_service' } 
								      );
	    }
	    my $eventTypes = find( $d1_el , "./nmwg:metadata/nmwg:eventType", 0 );
	    my $type_of_service =  $param_exist{type};
	    my $snmp;
            foreach my $e ( $eventTypes->get_nodelist ) {
   		my $value = extract( $e, 0 );
		if($SERVICE_LOOKUP{$value}) {
		    $service_obj->type($SERVICE_LOOKUP{$value});
		    $type_of_service = $SERVICE_LOOKUP{$value};
		}
		$dbh->resultset('Eventtype')->update_or_create( { eventtype =>  $value,
								  service =>  $service_obj->service
								},
								{ key => 'eventtype_service' }
							      );
	        $snmp ||= $SERVICE_LOOKUP{$value} if $SERVICE_LOOKUP{$value} && $SERVICE_LOOKUP{$value} eq 'snmp';
	    }
	    
	    my $subj_md =  find($d1_el, "./nmwg:metadata/*[local-name()='subject']", 1);
	    $logger->info("TID=" .  threads->tid . "====DATA $id  MD element:::" . $subj_md->toString) if $subj_md;
   	  
	    if($subj_md) {
	        my %ip_addr_h = ( rtr => '', src => '', dst => '');
		my %ip_addr_rs = ( rtr => '', src => '', dst => '');
	        $subj_md->setNamespace('http://ggf.org/ns/nmwg/topology/2.0/','nmwgt');
                foreach my $try_src ("./*[local-name()='endPointPair']/*[local-name()='src']", 
		                     "./*[local-name()='node']/*[local-name()='port']/*[local-name()='address']",
				     "./*[local-name()='interface']/*[local-name()='ipAddress']",
				     "./*[local-name()='interface']/*[local-name()='ifAddress']", ) {
		    
		    my ($ips) = $subj_md->findnodes($try_src);
		    if($ips) {
		      $ip_addr_h{src} = extract(  $ips, 0);
		      $logger->info("TID=" .  threads->tid . " ======  $try_src=$ip_addr_h{src} ------");
		      last if  $ip_addr_h{src}; 
		    }
		}
	        my ($dst) =  $subj_md->findnodes( "./*[local-name()='endPointPair']/*[local-name()='dst']");
	        $ip_addr_h{dst} =  extract(  $dst, 0) if $dst;  
		my $capacity    =  extract( find( $subj_md, "./*[local-name()='interface']/*[local-name()='capacity']", 1), 0 );
		$ip_addr_h{rtr} =  extract( find( $subj_md, "./*[local-name()='interface']/*[local-name()='hostName']", 1), 0 );
	        $logger->info("TID=" .  threads->tid . " ====== src=$ip_addr_h{src}========== \n" . $subj_md->toString);
                next unless $ip_addr_h{src};
		foreach my $ip_key (qw/rtr src dst/) {
		    my ($ip_cidr,$ip_name) = get_ip_name($ip_addr_h{$ip_key});
		    if($ip_addr_h{$ip_key} && $ip_cidr) {
	                  update_create_fixed(   $dbh->resultset('Node'),
			                                             { ip_addr  =>  \"=inet6_pton('$ip_cidr')"},
			                                             { ip_addr  => \"inet6_pton('$ip_cidr')",
			                                               nodename => $ip_name,
								       ip_noted => $ip_cidr 
								     }
								    );
			  $ip_addr_rs{$ip_key} =  $dbh->resultset('Node')->find({ip_noted => $ip_cidr });				    
		    }
		}
	        ##$logger->debug('End ======  MISSING:' . $subj_md->toString) unless $ip_addr{src};
	 
	        eval {
	               
	               $dbh->resultset('Metadata')->update_or_create ({ perfsonar_id =>  $data_id, 
							      service	 => $service_obj->service,
							      src_ip	    =>   $ip_addr_rs{src}->ip_addr,
							      dst_ip	    =>   ($ip_addr_rs{dst}?$ip_addr_rs{dst}->ip_addr:0),
							      rtr_ip	    =>   ($ip_addr_rs{rtr}?$ip_addr_rs{rtr}->ip_addr:0),
							      capacity   => $capacity,
							      subject	 => ($subj_md?$subj_md->toString:''),
							      parameters => ($param_md?$param_md->toString:''),
							     },
							     {key => 'metaid_service'}
	                                                  ) ;
	        };
	        if($EVAL_ERROR) {
	            $logger->error(" Catched $EVAL_ERROR");
	        }
	         
	    }
	}
    }
}

__END__

=head1 SEE ALSO

L<XML::LibXML>, L<Carp>, L<Getopt::Long>, L<Data::Dumper>,
L<Data::Validate::IP>, L<Data::Validate::Domain>, L<Net::IPv6Addr>,
L<Net::CIDR>, <DBIx::Class>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn

The perfSONAR-PS subversion repository is located at:

  https://svn.internet2.edu/svn/perfSONAR-PS

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov
inspired by Jason Zurawski's cache.pl, zurawski@internet2.edu

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010, Fermitools

All rights reserved.

=cut

