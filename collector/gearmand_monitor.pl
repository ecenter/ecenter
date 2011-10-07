#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Net::Telnet;

my $options = { 'k' => '', 'H' => 'localhost', 'r' => 4730, 'w' => 25,
'c' => 50 };

GetOptions($options, "k=s", "H=s", "r=i", "w=i", "c=i");

if (defined $options->{'help'}) {
        print <<INFO;
$0: Check the status of gearmand job queues. {

}.

 check_gearmand.pl -k workername [ -H <hostname> ] [ -r <port> ] [ -w <warning> ] [ -c <critical> ]

  -k <workername>         - Name of the worker to check
  -H <hostname>                   - Host where gearmand is running (default:localhost)
  -r <port>                               - Port number gearmand is listening on (default: 4730)
  -w <position>                   - Number of jobs in queue for warning state(default: 25)
  -c <position>                   - Number of jobs in queue for critical state(default: 50)
  --help                - This help page

INFO
exit;

}

if ( !defined $options->{'k'} || !defined $options->{'H'} || !defined
$options->{'r'} || !defined $options->{'w'} || !defined $options->
{'c'} )
{
        print "ERROR: invalid input";
        exit 3;

}

my $worker = $options->{'k'};
my $host = $options->{'H'};
my $port = $options->{'r'};
my $warn_threshold = $options->{'w'};
my $critical_threshold = $options->{'c'};
my $return_status = 2;
my $return_string = "GEARMAND CRITICAL: Worker not registered with server\n";

# Connect to the gearmand server
my $telnet = new Net::Telnet( Host => $host, Port => $port , Timeout=> 10, Errmode => sub{&telnet_error} );
$telnet->print( "status" );
my ($status) = $telnet->waitfor('/\./');
$telnet->close;

# Process the output from telnet
my @rows = split(/\n/, $status);
foreach ( @rows )
{
        my @line = split(/\t/);
        my $line_worker = $line[0];

        if (!$worker  || ($line_worker eq $worker))
        {
                my $queued = $line[1];
                my $running = $line[2];
                my $available = $line[3];

                if ( $queued < $warn_threshold )
                {
                        # set OK
                        $return_status = 0;
                        $return_string = "GEARMAND OK: $line_worker -> avail: $available,run: $running, queue: $queued\n";
                }
                elsif ( $queued < $critical_threshold )
                {
                        # set warning
                        $return_status = 1;
                        $return_string = "GEARMAND WARN: $line_worker -> avail: $available,run: $running, queue: $queued\n";
                }
                else
                {
                        # set critical
                        $return_status = 2;
                        $return_string = "GEARMAND CRITICAL: $line_worker -> avail:$available, run: $running, queue: $queued\n";
                }
        print $return_string;
	}

}
exit $return_status;

sub telnet_error
{
        print "ERROR: Telnet Connection Failed!\n";
        exit 3;

} 
