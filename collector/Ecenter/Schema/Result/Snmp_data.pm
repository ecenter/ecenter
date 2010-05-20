package Ecenter::Schema::Result::Snmp_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('snmp_data');
__PACKAGE__->add_columns(qw/snmp_data metadata  timestamp  utilization errors drops/); 
__PACKAGE__->belongs_to(metadatas => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->set_primary_key('snmp_data');


1;
