#!/bin/env perl
##
##
use strict;
use warnings;
 
use FindBin qw($Bin);
use lib ($Bin,  "$Bin/client_lib", "$Bin/ps_trunk/perfSONAR_PS-PingER/lib");

=head1 NAME

run_drs.pl - run DRS

=head1 DESCRIPTION

wrapper script for the DRS deployment

=head1 SYNOPSIS

./run_drs.pl --ports="10500,10501,10502,10503" --logdir=/home/netadmin/ecenter_logs

=head1 OPTIONS

=over

=item --debug

debugging info logged

=item --help

print usage info

=item --ports=[port_number,port_number,...,port_number]

list of ports to run DRS on, comma separated list
Default: 10500

=item --logdir

logdir for the worker logs
Default: /tmp

=item --clean

kill all previously running DRS instances
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
my @string_option_keys = qw/ports  logdir/;
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
push @ports, ($OPTIONS{ports}?split(',',$OPTIONS{ports}):10500);
$OPTIONS{db}      ||= 'ecenter_data';
$OPTIONS{logdir}  ||= '/tmp'; 

`/bin/ps auxwww | grep plackup |     grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};
`/bin/ps auxwww | grep ecenter_data_sharded_gearman  | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};
`/bin/ps auxwww | grep starman  | grep master | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};
`/bin/ps auxwww | grep starman  | grep worker | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};

foreach my $port (@ports) {
    my $cmd = "plackup  -E production -s Twiggy -a ecenter_data_sharded_gearman.pl -p $port > $OPTIONS{logdir}/drs_$port.log 2>&1 &";
    $logger->debug("CMD:$cmd");
    system($cmd)==0 or $logger->error("....failed");;
}
exit 0;
