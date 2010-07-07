#!/usr/bin/perl
use Plack::Handler::FCGI;

my $app = do('/home/netadmin/ecenter/trunk/frontend_components/ecenter_data/app.psgi');
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
