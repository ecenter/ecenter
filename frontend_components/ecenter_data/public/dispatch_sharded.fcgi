#!/usr/local/bin/perl
use Plack::Handler::FCGI;
$ENV{DANCER_ENVIRONMENT} =  "development";
my $app = do('/home/netadmin/ecenter/trunk/frontend_components/ecenter_data/ecenter_data_sharded_gearman.pl');
my $server = Plack::Handler::FCGI->new(nproc  => 10, detach => 1);
$server->run($app);
