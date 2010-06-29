package Ecenter::Schema::Result::L2_l3_map;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('l2_l3_map');
__PACKAGE__->add_columns(qw/l2_l3_map ip_addr l2_urn/);
__PACKAGE__->set_primary_key('l2_l3_map'); 
__PACKAGE__->belongs_to(l2_urn => 'Ecenter::Schema::Result::L2_port'); 
__PACKAGE__->belongs_to(ip_addr => 'Ecenter::Schema::Result::Node');
1;
