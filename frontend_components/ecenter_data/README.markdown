This is a directory for the DRS service
=======================================

Its based on perl's Dancer API - google "cpan dancer" for docs.
It was tested on perl 5.12.2 or better.

You need to install nginx proxy, MySQL DB (5.5.7++), gearmnd job submission manager.
You will need next CPAN modules:

 AnyEvent-5.31
 Dancer-1.3020
 Dancer-Plugin-REST-0.05
 Log::Log4perl
 Devel-StackTrace-AsHTML-0.11
 HTTP-Parser-XS-0.13
 Net-Server-0.99
 Plack-0.9976
 Test-Simple-0.98
 Test-TCP-1.12
 Twiggy-0.1010
 DBIx::Class
 Gearman::Client
 Plack::Handler::Twiggy
 ------------------

 
 Next lines starts Gearman daemons on specific ports. 
 Make sure the same ports are configured on DRS in the
 ~/netadmin/ecenter_git/ecenter/frontend_components/ecenter_data/environments/production.yml file.
 -------------this sets 3 ports for the gearmand servers on the localhost---------------------
 gearman:
   server: localhost
       ports: [10121, 10111, 10131]
 -----------------------------------------------------------------------------------------------
 
 Copy drs_nginx.conf to /etc/nginx/
 As root or sudo ( next set of commands for the quasi-production deployment, number of procs can change):
 
 /usr/local/nginx/sbin -c /etc/nginx/drs_nginx.conf 
 /usr/local/sbin/gearmand -v -p 10111 -d -u netadmin
 /usr/local/sbin/gearmand -v -p 10121 -d -u netadmin 
 /usr/local/sbin/gearmand -v -p 10131 -d -u netadmin
 
 ----------------------------------------------------
 
 
 Next commnds will start worker processes and start 4 DRS instances.
 as user netadmin:
 
 ------------------
 
 cd ~/netadmin/ecenter_git/ecenter/collector
 ./run_workers.pl --logdir=/home/netadmin/ecenter_logs/ --port=10121  --workers=6 --timeout=300 --clean
 ./run_workers.pl --logdir=/home/netadmin/ecenter_logs/ --port=10131  --workers=6 --timeout=300 --clean
 
 cd ~/netadmin/ecenter_git/ecenter/frontend_components/ecenter_data
 ./run_drs.pl  --logdir=/home/netadmin/ecenter_logs/  --ports="10500,10501,10502,10503" --clean
 ------------------------------------------------
 
 last command starts 4 DRS instances on different ports, each under the asynchronous 
 Plack::Handler::Twiggy. The nginx proxy is configured to use any of the available DRS servers. 
 Any DRS servers can be hot-swapped or replaced with a new one.
 Try to call each command with --help or -h option to see the full list of  options and with --clean option in 
 the run_workers.pl and run_drs.pl commnds will kill all running processes before starting new ones.
 
 The Gearman can run on multiple hosts/ports and the whole system can live on the cloud or any number of hosts.
 
 ---------------------------------
 
 Author: Maxim Grigoriev, 2011


 
