package Ecenter::Schema::Result::Snmp_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('snmp_data');
__PACKAGE__->add_columns(qw/snmp_data metaid timestamp  utilization errors drops/);
__PACKAGE__->set_primary_key('snmp_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata','metaid');

__PACKAGE__->add_unique_constraint( meta_time => [ qw/metaid timestamp/ ]);
1;
