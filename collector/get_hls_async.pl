#!/usr/bin/perl -w

use strict;
use warnings;

=head1 NAME

get_hls_async.pl - cache program  with asynchronous calls to the remote LSes

=head1 DESCRIPTION

Builds up a list (flat file) of hLS instances that match a certain keyword
query (e.g. 'LHC' and related combinations).

=head1 SYNOPSIS

./get_lhs.pl --key=LHC_OPN

it will try to query fo all possible combinations:
LHC, lhc, LHC-OPN, LHCOPN, lhcopn, lhc-opn
Please notice the '_' instead of '-' in the supplied key.

=head1 OPTIONS

=over

=item --verbose

=item --key=[project key]

=item --help

=back

=cut
use lib qw(/home/netadmin/ecenter/trunk/collector);

use forks;

use XML::LibXML;
use Getopt::Long;
use Data::Dumper;
use Data::Validate::IP qw(is_ipv4);
use Data::Validate::Domain qw( is_domain );
use Net::IPv6Addr;
use Net::CIDR;
use POSIX qw(strftime);
use Pod::Usage;
use Ecenter::Schema;
use Log::Log4perl qw(:easy);
use Benchmark;
use constant HLS => {
 hls => 1,
 name => 2,
 keyword => 3,
 url => 4,
 type=> 5,
 comments => 6,
 is_alive=> 7,
 updated=> 8,
};
#use lib "/usr/local/perfSONAR-PS/lib";

use perfSONAR_PS::Common qw( extract find unescapeString escapeString );
use perfSONAR_PS::Client::gLS;
use perfSONAR_PS::Client::Echo;

our ($DEBUGFLAG, $HELP, $KEY) = ('','','');

my $status = GetOptions(
    'verbose|v'   => \$DEBUGFLAG,
    'key=s'       => \$KEY,
    'help|h|?'      => \$HELP
) or pod2usage(1);

$DEBUGFLAG?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
our  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(2) if ( $HELP || !$KEY);

my $parser = XML::LibXML->new();
my $hints  = "http://www.perfsonar.net/gls.root.hints";
my @private_list = ( "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16" );
my $base = ".";
(my $pattern  = $KEY) =~ s/_([^_]+)/\\\-?($1)?/g;
$logger->debug("Pattern: $pattern");
my %hls = ();
my $gls = perfSONAR_PS::Client::gLS->new( { url => $hints } );

$logger->logdie("roots not found") unless ( $#{ $gls->{ROOTS} } > -1 );
my $dbh =  Ecenter::Schema->connect('DBI:mysql:ecenter',  'ecenter', 'ecenter2010',);
$logger->logdie( "DB failed") unless( $dbh );
my %threads = ();
my $now_str = strftime('%Y-%m-%d %H:%M:%S', localtime());
for my $root ( @{ $gls->{ROOTS} } ) {  
    $logger->info("Root:\t$root");
    my $result = $gls->getLSQueryRaw(  {
            ls => $root,
            xquery => "declare namespace nmwg=\"http://ggf.org/ns/nmwg/base/2.0/\";
    for \$metadata in /nmwg:store[\@type=\"LSStore\"]/nmwg:metadata
       let \$metadata_id := \$metadata/\@id
       let \$data := /nmwg:store[\@type=\"LSStore\"]/nmwg:data[\@metadataIdRef=\$metadata_id]
       where \$data/nmwg:metadata[(.//nmwg:parameter[
                                      \@name=\"keyword\" 
                                          and ( matches(\@value, '^project\:$pattern', 'xi')
                                                or matches(text(),'^project\:$pattern', 'xi')
				               )
				       ]
				)]
    return \$metadata"
        }
    );
    if ( exists $result->{eventType} and not( $result->{eventType} =~ m/^error/ ) ) {
        $logger->debug("\tEventType:\t$result->{eventType}");
        my $doc = $parser->parse_string( $result->{response} ) if exists $result->{response};
        my $service = find( $doc->getDocumentElement, ".//*[local-name()='service']", 0 );
        foreach my $s ( $service->get_nodelist ) {  
	  $threads{$s} = threads->new( sub {
            my $accessPoint = extract( find( $s, ".//*[local-name()='accessPoint']", 1 ), 0 );
	    my $keyword_str = extract( find( $s, ".//*[local-name()='keyword']", 1 ), 0 );
            my $serviceName = extract( find( $s, ".//*[local-name()='serviceName']", 1 ), 0 );
            my $serviceType = extract( find( $s, ".//*[local-name()='serviceType']", 1 ), 0 );
            my $serviceDescription = extract( find( $s, ".//*[local-name()='serviceDescription']", 1 ), 0 );

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
		    my $keyword = $dbh->resultset('Keyword')->update_or_create({ keyword => $keyword_str, 
		                                                                 pattern => $pattern,
										 created => $now_str
										}
									       );
		    my $hls = $dbh->resultset('Hls')->update_or_create({ name => $serviceName,
		                                                       url   =>   $accessPoint,
		                                                       type => $serviceType,
								       keyword =>  $keyword,
								       comments => $serviceDescription,
								       is_alive => (!$status?'1':'0'), 
								       updated =>  $now_str
								      },
								      { key => 'hls_url'}
								     );
		    
		      
                 }  else  {
                    $logger->debug("\t\t\tReject:\t$unt_test");
                 }
             }
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
__END__

=head1 SEE ALSO

L<XML::LibXML>, L<Carp>, L<Getopt::Long>, L<Data::Dumper>,
L<Data::Validate::IP>, L<Data::Validate::Domain>, L<Net::IPv6Addr>,
L<Net::CIDR>

To join the 'perfSONAR-PS' mailing list, please visit:

  https://mail.internet2.edu/wws/info/i2-perfsonar

The perfSONAR-PS subversion repository is located at:

  https://svn.internet2.edu/svn/perfSONAR-PS

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/perfsonar-ps/issues/list

=head1 VERSION

$Id: LHC.pl 2640 2009-03-20 01:21:21Z zurawski $

=head1 AUTHOR

Jason Zurawski, zurawski@internet2.edu
Maxim Grigoriev, maxim_at_fnal_dot_gov

=head1 LICENSE

You should have received a copy of the Internet2 Intellectual Property Framework along
with this software.  If not, see <http://www.internet2.edu/membership/ip.html>

=head1 COPYRIGHT

Copyright (c) 2007-2009, Internet2
Copyright (c) 2010, Fermitools

All rights reserved.

=cut

