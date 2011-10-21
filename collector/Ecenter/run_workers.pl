#!/bin/env perl
##
##
use strict;
use warnings;
 
use FindBin qw($Bin);
use lib ($Bin,  "$Bin/client_lib", "$Bin/ps_trunk/perfSONAR_PS-PingER/lib");

=head1 NAME

run_workers.pl - spawn as many workers as you want

=head1 DESCRIPTION

wrapper script for the Gearman workers control

=head1 SYNOPSIS

./run_workers.pl --workers=5 --wname='data_worker.pl' --procs=15 --db=ecenter_data --logdir=/tmp

=head1 OPTIONS

=over

=item --debug

debugging info logged

=item --help

print usage info

=item --wname=[executable name]

name of the worker node executable, just a filename, not the full path. It will  use current directory.
Default: data_worker.pl

=item --workers=[number or workers]

number  of worker nodes
Default: 4

=item --host=[hostname]

hostname for the backend DB server
Default: ecenterprod1.fnal.gov

=item --g_host=[hostname]

hostname for the Gearmand server
Default: xenmon.fnal.gov

=item --db=[database name]

backend DB name
Default: ecenter_data

=item --port=[port number]

port for the Gearman worker to connect
Default: 10221

=item --timeout=<time period in seconds>

time period to timeout call to the remote perfSONAR-PS service
Default: 120 seconds
  
=item --logdir=[dirname]

logdir for the worker logs
Default: /tmp

=item --clean

kill all previously running worker nodes
Default: not set

=back

=cut

use Pod::Usage;
use Log::Log4perl qw(:easy);
use Getopt::Long;
my %OPTIONS;
my @string_option_keys = qw/workers port db logdir timeout host wname  g_host/;
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
    if (  $OPTIONS{help} || 
	 ($OPTIONS{workers} && $OPTIONS{workers} !~ /^\d{1,2}$/) || 
	 ($OPTIONS{port} && $OPTIONS{port} !~ /^\d+$/) || 
	 ($OPTIONS{logdir} && !(-d $OPTIONS{logdir})) );
$OPTIONS{port}    ||= 10121;
$OPTIONS{timeout} ||= 120;
$OPTIONS{workers} ||= 4;
$OPTIONS{logdir}  ||= '/tmp';
$OPTIONS{host}    ||= 'ecenterprod1.fnal.gov';
$OPTIONS{g_host}  ||= 'xenmon.fnal.gov';
$OPTIONS{db}      ||= 'ecenter_data';
$OPTIONS{wname}   ||= 'data_worker.pl';

`/bin/ps auxwww | grep '$OPTIONS{wname}' | grep $OPTIONS{port} | grep -v run | grep -v grep | grep -v  nedit  | awk '{print \$2}' | xargs kill -9` if $OPTIONS{clean};
for(my $i=0;$i<$OPTIONS{workers};$i++) {
    my $cmd = "$Bin/$OPTIONS{wname} --db=$OPTIONS{db} " . ($OPTIONS{debug}?'--debug':'') . " --host=$OPTIONS{host}  --g_host=$OPTIONS{g_host} --port=$OPTIONS{port}  > $OPTIONS{logdir}/log_worker_$OPTIONS{port}\_$i.log  2>&1 &";
    $logger->debug("CMD:$cmd");
    system($cmd)==0 or $logger->error("....failed");;
}
exit 0;
