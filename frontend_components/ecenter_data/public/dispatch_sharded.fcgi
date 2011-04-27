#!/usr/local/bin/perl
use Plack::Handler::FCGI;
$ENV{DANCER_ENVIRONMENT} =  "production";
my $app = do('/home/netadmin/ecenter_git/ecenter/frontend_components/ecenter_data/ecenter_data_sharded_gearman.pl');
my $server = Plack::Handler::FCGI->new(nproc  => 20, detach => 1);
$server->run($app);
