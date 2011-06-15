#!/usr/local/bin/perl
use Dancer ':syntax';
use Plack::Handler::FCGI;

# For some reason Apache SetEnv directives dont propagate
# correctly to the dispatchers, so forcing PSGI and env here 
# is safer.
 
$ENV{DANCER_ENVIRONMENT} =  "production";
 
my $app = do('/home/netadmin/ecenter_git/ecenter/analysis/ads/lib/app.pl');
die "Unable to read startup script: $@" if $@;
my $server = Plack::Handler::FCGI->new(nproc => 5, detach => 1, port =>  9055 );

$server->run($app);
