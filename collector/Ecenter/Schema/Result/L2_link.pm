package Ecenter::Schema::Result::L2_link;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('l2_link');
__PACKAGE__->add_columns(qw/l2_link l2_src_urn l2_dst_urn/);
__PACKAGE__->set_primary_key('l2_link'); 
__PACKAGE__->belongs_to(l2_src_urn => 'Ecenter::Schema::Result::L2_port',  { 'foreign.l2_urn' => 'self.l2_src_urn' } ); 
__PACKAGE__->belongs_to(l2_dst_urn => 'Ecenter::Schema::Result::L2_port',  { 'foreign.l2_urn' => 'self.l2_dst_urn' } ); 
 
1;
