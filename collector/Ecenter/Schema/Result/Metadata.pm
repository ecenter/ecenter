package Ecenter::Schema::Result::Metadata;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('metadata');
__PACKAGE__->add_columns(qw/metaid perfsonar_id  src_ip dst_ip  service subject parameters/); 
__PACKAGE__->set_primary_key('metaid');
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->belongs_to(src_ip => 'Ecenter::Schema::Result::Node',  { 'foreign.ip_addr' => 'self.src_ip' }  );
 
__PACKAGE__->has_many(datas => 'Ecenter::Schema::Result::Data');
__PACKAGE__->has_many(pinger_datas => 'Ecenter::Schema::Result::Pinger_data');
__PACKAGE__->has_many(bwctl_datas => 'Ecenter::Schema::Result::Bwctl_data');
__PACKAGE__->has_many(owamp_datas => 'Ecenter::Schema::Result::Owamp_data');
__PACKAGE__->has_many(snmp_datas => 'Ecenter::Schema::Result::Snmp_data');
__PACKAGE__->has_many(traceroute_datas => 'Ecenter::Schema::Result::Traceroute_data', 'trace_id');



__PACKAGE__->add_unique_constraint( metaid_service => [ qw/perfsonar_id service/ ]);


1;
