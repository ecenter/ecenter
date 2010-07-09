package Ecenter::Schema::Result::Node;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(qw/ip_addr nodename ip_noted netmask/);
__PACKAGE__->set_primary_key('ip_addr');
__PACKAGE__->has_many( src_ip =>  'Ecenter::Schema::Result::Metadata',  { 'foreign.src_ip' => 'self.ip_addr' });
__PACKAGE__->has_many( dst_ip =>  'Ecenter::Schema::Result::Metadata',  { 'foreign.dst_ip' => 'self.ip_addr' });

__PACKAGE__->has_many(services =>  'Ecenter::Schema::Result::Service',  'ip_addr'); 
__PACKAGE__->has_many(l2_l3_maps =>  'Ecenter::Schema::Result::L2_l3_map',  'ip_addr');
__PACKAGE__->has_many(hops =>  'Ecenter::Schema::Result::Hop',   'hop_ip');
1;
