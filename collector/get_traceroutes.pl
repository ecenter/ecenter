#!/usr/bin/perl -w

use strict;
use warnings;

# $Id: $

=head1 NAME

get_traceroutes.pl -  asynchronous calls to the NPToolkit based reverse traceroute cgi scripts

=head1 DESCRIPTION

  it runs traceroutes remotely and parses resulted HTML page and stores all traceroute data.

=head1 SYNOPSIS

 ## get all ESnet traceroutes
 
 >get_traceroutes.pl  --match='es\.net' --procs=20 --password=<db password> --user=<db username>
 
=head1 OPTIONS

=over

=item --debug

debugging info logged

=item  --src_match=[regexp]

match with service's nodename and filter only desired nodenames 
(for example 'es.net' will run traceroute only within the ESnet domain)

=item  --dst_match=[key]

match with  destination nodename via SQL like '%xxx%'


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

  
use WWW::Mechanize;
use URI;
use English;

use FindBin;
use lib  "$FindBin::Bin";

use Ecenter::Schema;
use HTML::TreeBuilder::XPath;

use forks;
use forks::shared 
    deadlock => {
    detect => 1,
    resolve => 1
};
use Getopt::Long;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use Pod::Usage;
use Ecenter::Utils;
use Digest::MD5 qw(md5_hex);
use Time::HiRes;
use POSIX qw(ceil floor);

use vars qw( $VERSION );
$VERSION = '0.01';

# Maximum working threads
my $MAX_THREADS = 10;
my %threads   = ();
  
our $TRACE_CMD = 'gui/reverse_traceroute.cgi';


my %OPTIONS;
my @string_option_keys = qw/dst_match src_match password db user procs/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help/,
) or pod2usage(1);

$OPTIONS{debug}?Log::Log4perl->easy_init($DEBUG):Log::Log4perl->easy_init($INFO);
our  $logger = Log::Log4perl->get_logger(__PACKAGE__);

pod2usage(-verbose => 2) if ( $OPTIONS{help}    || ($OPTIONS{procs} && $OPTIONS{procs} !~ /^\d\d?$/));

$MAX_THREADS = $OPTIONS{procs} if $OPTIONS{procs} &&  $OPTIONS{procs} > 0 && $OPTIONS{procs}  < 40;

$OPTIONS{db} ||= 'ecenter_data';
$OPTIONS{user} ||= 'ecenter';

unless($OPTIONS{password}) {
    $OPTIONS{password} = `cat /etc/my_ecenter`;
    chomp $OPTIONS{password};
} 
$logger->debug(" MAX THREADS = $MAX_THREADS ");

my $dbh =  Ecenter::Schema->connect("DBI:mysql:$OPTIONS{db}",  $OPTIONS{user},
                                     $OPTIONS{password}, 
				    {RaiseError => 1, PrintError => 1});
$dbh->storage->debug(1)  if $OPTIONS{debug};
my $services = $dbh->resultset('Service')->search({},{join => 'ip_addr', group_by => 'ip_addr'});
my $src_match = $OPTIONS{src_match}?qr/$OPTIONS{src_match}/:'';
my $dst_match = $OPTIONS{dst_match}?" and me.nodename   like '\%$OPTIONS{dst_match}\%' ":'';

while( my $service = $services->next) {
    my $nodename = $service->ip_addr->nodename;
    next unless $nodename; 
    next if($src_match && $nodename !~  $src_match);
   
    my $service_ip = $service->ip_addr->ip_noted;
    my $mask = ( $service_ip  =~ /^[\d\.]+$/)?'31':'64';
    my $where = "inet6_mask(me.ip_addr, $mask) != inet6_mask(inet6_pton('". $service->ip_addr->ip_noted ."'), $mask) $dst_match";
  
    pool_control($MAX_THREADS, 0);
    threads->new( sub {    
	my $mech = WWW::Mechanize->new(   agent  => 'Mozilla/5.0 (compatible; MSIE 7.0; Windows 2000; .NET CLR 1.1.4322)',
              stack_depth => 1,
              env_proxy   => 1,
              cookie_jar  => {},
              autocheck => 1, 
	      timeout => 10,
	      );

	my $result;
	eval {
            $result = $mech->get("http://$nodename/$TRACE_CMD");
	};
	if($EVAL_ERROR) {
            $logger->error(" Failed to get URL:  $nodename " );
	    threads->exit();
	}
	if($result->is_success) {
            my $dbh_node =  Ecenter::Schema->connect('DBI:mysql:' . $OPTIONS{db}, 
	    			$OPTIONS{user}, $OPTIONS{password}, 
	    			{RaiseError => 1, PrintError => 1});
	    $dbh_node->storage->debug(1) if $OPTIONS{debug};	
            my $nodes = $dbh_node->resultset('Node')->search({  '' => \$where});  

            while( my $node = $nodes->next) {
		my $metaid = $dbh_node->resultset('Metadata')->update_or_create({  
	                                                        	 perfsonar_id => md5_hex( $service_ip . $node->ip_noted), 
	    								 service	  => $service->service,
	    								 src_ip	  => $service->ip_addr->ip_addr,
	    								 dst_ip	  => $node->ip_addr,
	    						     },
	    						     {key => 'metaid_service'}
	    						  );
		my $node_ip = $node->ip_noted;
		my $now_sec = floor(Time::HiRes::time() * 1000);
        	$logger->debug(" TRying: http://$nodename/$TRACE_CMD -> $node_ip");
        	my $result2 = $mech->get("http://$nodename/$TRACE_CMD?choice=yes&target=$node_ip");
		if($result2->is_success) {         
            	    my $tree = HTML::TreeBuilder->new_from_content($result2->content());
            	    my ($pre) = $tree->findnodes('//pre');
	    	    if($pre) {
	    		my $trace = parse_trace($pre->as_text);
	    		my $trace_data = $dbh->resultset('Traceroute_data')->update_or_create({ metaid =>  $metaid,
	    										   number_hops  =>   $trace->{max_hops},
	    										   updated =>   $now_sec,
	    										},
	    										{key => 'updated_metaid'}
	    										);
	    		 #$logger->debug(" HOPS: ", sub {Dumper ($trace->{hops})});
	    		foreach my $hop (sort {$a <=> $b} keys %{$trace->{hops}}) {
	    		    if($trace->{hops}{$hop}{ip}) {
	    			update_create_fixed($dbh_node->resultset('Node'),
	    						      { ip_addr =>  \"=inet6_pton('$trace->{hops}{$hop}{ip}')"},
	    						      { ip_addr => \"inet6_pton('$trace->{hops}{$hop}{ip}')",
	    							nodename =>  $trace->{hops}{$hop}{host},
	    							ip_noted => $trace->{hops}{$hop}{ip} 
	    						      }
	    					    ); 
	    			#$logger->info(" ip_addr " , sub {Dumper($ip_addr$ip_addr_obj )});
	    			my $hop_addr_obj =  $dbh->resultset('Node')->find({ip_noted =>  $trace->{hops}{$hop}{ip}});
	    			my $hop = $dbh->resultset('Hop')->update_or_create({  
	    									     trace_id => $trace_data,
	    									     hop_ip => $hop_addr_obj->ip_addr,
	    									     hop_num => $hop,
	    									     hop_delay => $trace->{hops}{$hop}{delay}
	    									} 
	    								 );
	    		    }
	    		}
	    	    } else {
	    		$logger->debug("NOT FOUND:: " . $tree->as_HTML);
	    	    }
	    	    $tree->delete if $tree;
		} else {
  	    	    $logger->error(" Failed to run  URL:  $nodename -> " . $node->ip_noted  . " ERROR: " . $result->status_line );
		} 
            } 
	    $dbh_node->storage->disconnect if $dbh_node;   
        } else {
            $logger->error(" Failed to get URL:  $nodename- " . $result->status_line );
        }
    });
}	
pool_control($MAX_THREADS, 'finish_it');
 


sub parse_trace {
     my $trace = shift;
     my $result = {};
     return $result unless $trace;
     #
     #    this parser was taken with several modifications from Traceroute.pm,v 1.25 2007/01/10 02:30:13
     #    Author:	Daniel Hagerty, hag@ai.mit.edu
     #         modified by Maxim Grigoriev
     #    see: http://cpansearch.perl.org/src/HAG/Net-Traceroute-1.10/Traceroute.pm
     #
     my %CODE = (TRACEROUTE_OK => 0,  TRACEROUTE_TIMEOUT => 1,  TRACEROUTE_UNKNOWN => 2, TRACEROUTE_BSDBUG => 3,
                 TRACEROUTE_UNREACH_NET => 4, TRACEROUTE_UNREACH_HOST => 5,    TRACEROUTE_UNREACH_PROTO  => 6, 
                 TRACEROUTE_UNREACH_NEEDFRAG => 7, TRACEROUTE_UNREACH_SRCFAIL => 8, TRACEROUTE_UNREACH_FILTER_PROHIB => 9,
		 TRACEROUTE_UNREACH_ADDR => 10);
     my $hops=0;
     my %icmp_map = (N => $CODE{TRACEROUTE_UNREACH_NET},
		H => $CODE{TRACEROUTE_UNREACH_HOST},
		P => $CODE{TRACEROUTE_UNREACH_PROTO},
		F => $CODE{TRACEROUTE_UNREACH_NEEDFRAG},
		S => $CODE{TRACEROUTE_UNREACH_SRCFAIL},
		A => $CODE{TRACEROUTE_UNREACH_ADDR},
		X => $CODE{TRACEROUTE_UNREACH_FILTER_PROHIB});

    line:
     foreach my $line (split(/\n/, $trace)) {
	$line =~ /^\s?([0-9]+) / or  next;
	my $hopno = $1 + 0;
	$hops = $hopno;
	my $addr;
	my $nodename;
	my $time = 0;
        my $counter = 0;
	
	$_ = substr($line,length($MATCH));

       query:
	while($_) {
	    # ip address of a response
	    /^ (\d+\.\d+\.\d+\.\d+)/ && do {
		$addr = $1;
		$_ = substr($_, length($MATCH));
		next query;
	    };  
	 
	    # ipv6 address of a response
	    /^ ([0-9a-fA-F:]+)/ && do {
		$addr = $1;
		$_ = substr($_, length($MATCH));
		next query;
	    };
	    /^ ([\w\-\.]+)/ && do {
		$nodename = $1;
		$_ = substr($_, length($MATCH));
		next query;
	    };   
	    # Redhat FC5 traceroute does this; it's redundant.
	    /^ \((\d+\.\d+\.\d+\.\d+)\)/ && do {
	        $addr = $1;
		$_ = substr($_, length($MATCH));
		next query;
	    };
	    # round trip time of query
	    /^   ?([0-9.]+) ms/ && do {
		$time += $1;
		$counter++;
		$result->{$hopno}{code}=$CODE{TRACEROUTE_OK};
		$result->{$hopno}{ip} = $addr;
		$result->{$hopno}{host} = $nodename;
		$result->{$hopno}{delay} = $time;
		 
		$_ = substr($_, length($MATCH));
		next query;
	    };
	    # query timed out
	    /^ +\*/ && do {
		$result->{$hopno}{code}  = $CODE{TRACEROUTE_TIMEOUT};
		$_ = substr($_, length($MATCH));
		next query;
	    };
	    /^ (!<\d+>|![NHPFSAX]?)/ && do {
		my $flag = $1;
		my $matchlen = length($MATCH);
		if($flag =~ /^!<\d>$/) {
		    $result->{$hopno}{code} =  $CODE{TRACEROUTE_UNKNOWN};
		} elsif($flag =~ /^!$/) {
		    $result->{$hopno}{code} =  $CODE{TRACEROUTE_BSDBUG};
		} elsif($flag =~ /^!([NHPFSAX])$/) {
		    my $icmp = $1;
		    # Shouldn't happen
		    $logger->logdie("Unable to traceroute output (flag $icmp)!")
			unless(defined($icmp_map{$icmp}));
		    $result->{$hopno}{code} =  $icmp_map{$icmp};
		}
		$_ = substr($_, $matchlen);
		next query;
	    };
	    /^$/ && do {
		next line;
	    };
	    /^ \(ttl ?= ?\d+!\)/ && do {
		$_ = substr($_, length($MATCH));
		next query;
	    };
	    last;
	}
	if(!$result->{$hopno}{ip} || !$result->{$hopno}{host}) {
	    my ($ip, $name) = (!$result->{$hopno}{ip} && $result->{$hopno}{host})?get_ip_name($result->{$hopno}{host}):
	                        get_ip_name($result->{$hopno}{ip});
	    $result->{$hopno}{ip} = $ip;
	    $result->{$hopno}{host}= $name;		
	}
	$result->{$hopno}{delay} = $counter?$result->{$hopno}{delay}/$counter:0;
   }
   return {hops => $result, max_hops => $hops};
}

__END__

=head1 SEE ALSO

L<XML::LibXML>, L<Carp>, L<Getopt::Long>, L<Data::Dumper>,
L<Data::Validate::IP>, L<Data::Validate::Domain>, L<Net::IPv6Addr>,
L<Net::CIDR>, <DBIx::Class>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov 

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2010, Fermitools

All rights reserved.

=cut
