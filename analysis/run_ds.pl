#!/bin/env perl
##
##
use strict;
use warnings;
 
use FindBin qw($Bin);
use lib ($Bin,  "$Bin/client_lib", "$Bin/ps_trunk/perfSONAR_PS-PingER/lib");

=head1 NAME

run_ds.pl - run auxiliary service

=head1 DESCRIPTION

wrapper script for the deploying auxiliary data service - ADS or FDS are supported

=head1 SYNOPSIS

    ./run_ds.pl --service=ads --ports="20500,20501,20502,20503" --logdir=/home/netadmin/ecenter_logs
    ##
    ## it will start 4 ADS services with logging to /home/netadmin/ecenter_logs directory

=head1 OPTIONS

=over

=item --service=[ads|fds]

specify type of service:
- ads for the Anomaly Detection Service
- fds for the Forecasting Service
Deafult: ads

=item --debug

debugging info logged

=item --help

print usage info

=item --g_host=[hostname]

hostname for the Gearmand server
Default: xenmon.fnal.gov

=item --ports=[port_number,port_number,...,port_number]

list of ports to run FDS on, comma separated list
Default: 20500

=item --logdir

logdir for the worker logs
Default: /tmp

=item --clean

kill   running  instances, if ports are specified then only for those ports
Default: not set

=back

=cut

use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;
BEGIN {
    exit "Install Plack and Plack::Handler::Twiggy from the cpan, see docs for installation instructions" 
        unless eval "require Plack::Handler::Twiggy" &&
	       eval "require Plack";
};
my %OPTIONS;
my @string_option_keys = qw/ports  logdir service g_host/;
GetOptions( \%OPTIONS,
            map("$_=s", @string_option_keys),
            qw/debug help clean/
) or pod2usage(1);
my $output_level =  $OPTIONS{debug} || $OPTIONS{d}?$DEBUG:$INFO;

my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
my $logger = Log::Log4perl->get_logger(__PACKAGE__);
pod2usage(-verbose => 2) 
    if ( $OPTIONS{help} ||  
	($OPTIONS{ports} && $OPTIONS{ports} !~ /^(\d+,?)+$/) || 
	($OPTIONS{logdir} && !(-d $OPTIONS{logdir})) );
my @ports = ();
push @ports, ($OPTIONS{ports}?split(',',$OPTIONS{ports}):20500);
$OPTIONS{service} ||= 'ads';
$OPTIONS{g_host}  ||= 'xenmon.fnal.gov';
$OPTIONS{logdir}  ||= '/tmp'; 

`/bin/ps auxwww | grep plackup_$OPTIONS{service}  | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};
`/bin/ps auxwww | grep '$OPTIONS{service}\_app.pl' | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};

foreach my $port (@ports) {
    my $cmd = "plackup_$OPTIONS{service} -E production -s Twiggy -a  bin/$OPTIONS{service}\_app.pl -p $port > $OPTIONS{logdir}/$OPTIONS{service}\_$port.log 2>&1 &";
    $logger->debug("CMD:$cmd");
    system($cmd)==0 or $logger->error("....failed");
    
}
exit 0;
