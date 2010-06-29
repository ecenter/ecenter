package Ecenter::Schema::Result::L2_port;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('l2_port');
__PACKAGE__->add_columns(qw/l2_urn description capacity/);
__PACKAGE__->set_primary_key('l2_urn'); 
__PACKAGE__->has_many(l2_src_links =>  'Ecenter::Schema::Result::L2_link',  { 'foreign.l2_src_urn' => 'self.l2_urn'});
__PACKAGE__->has_many(l2_dst_links =>  'Ecenter::Schema::Result::L2_link',  { 'foreign.l2_dst_urn' => 'self.l2_urn'});
__PACKAGE__->has_many(l2_l3_maps =>  'Ecenter::Schema::Result::L2_l3_map',  'l2_urn');
__PACKAGE__->belongs_to(hub => 'Ecenter::Schema::Result::Hub');
1;
