package Ecenter::Schema::Result::L2_l3_map;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('l2_l3_map');
__PACKAGE__->add_columns(qw/l2_l3_map ip_addr l2_urn/);
__PACKAGE__->set_primary_key('l2_l3_map'); 
__PACKAGE__->belongs_to(l2_port => 'Ecenter::Schema::Result::L2_port', 'l2_urn' ); 
__PACKAGE__->belongs_to(node => 'Ecenter::Schema::Result::Node', 'ip_addr');
1;
