How to run data workers or DRS on remote host
--------------------------------------


install perl modules from CPAN ( as sudo or root):

perl -MCPAN -e 'install CPANPLUS'

-- answer yes to all questions, if not installed then force it via:
perl -MCPAN -e 'install YAML CPAN::Meta::YAML'

perl -MCPAN -e 'force install CPANPLUS'

-- then:

cpanp -i --prereqs  YAML Exception::Class forks JSON::XS Gearman  Moose MooseX::Types MooseX::Params::Validate\
 DBD::mysql DBIx::Class\
 namespace::autoclean Dancer Dancer::Plugin::REST Dancer::Plugin::Database\
 DateTime DateTime::Format::MySQL XML::LibXML   Plack Palck::Handler::Twiggy Dancer::Plugin::DBIC\
 Log::Log4perl  NetAddr::IP::Util Net::IPv6Addr Net::CIDR Data::Validate::IP\
 Data::Validate::Domain Socket6 Net::DNS   Data::UUID  aliased Readonly Class::Fields Date::Manip

-- the XML::LibXML tests may fail, install it anyway ( choose "y" )
-- answer yes to all questions about installing prereqs  if any 
-- answer no to any questions about running tests ( mostly about network related modules)


=======================
create netadmin account and dcd group:

sudo groupadd -g 1750 dcd
sudo useradd -s /bin/bash -m -g 1750 -c "netadmin for ecenter" -u 2301 netadmin

cd ~netadmin

as netadmin:

tar -zxvf ecenter_xxxxx.tgz

or install it from the GIT repository:

git clone ssh://p-ecenter@cdcvs.fnal.gov/cvs/projects/ecenter

and install perfSONAR-PS library:

svn checkout https://svn.internet2.edu/svn/perfSONAR-PS/trunk

If GIT is not installed then install it as:


cd ecenter/collector

========================
try to run:

./data_worker.pl

any errors, then see what perl module is missing, try to re-install.

no errors, good !
------------------

sudo echo 'xxxxxxx' >  /etc/my_ecenter
sudo chmod 0640 /etc/my_ecenter
sudo chown netadmin:dcd /etc/my_ecenter

where 'xxxxxxx' is ecenter_data DB password for the ecenter user.

-------------------
start workers, change --port=xxxxx to whatever port is on:

./run_workers.pl --logdir=/home/netadmin/ecenter_logs/ --clean  --host=xenmon.fnal.gov   --port=xxxxxx --workers=10 --timeout=300


