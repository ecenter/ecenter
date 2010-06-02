package Ecenter::Schema::Result::Node;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(qw/ip_addr nodename ip_noted/);
__PACKAGE__->set_primary_key('ip_addr');
__PACKAGE__->has_many(metadatas =>  'Ecenter::Schema::Result::Metadata',  { 'foreign.src_ip' => 'self.ip_addr' });
  

__PACKAGE__->has_many(hops =>  'Ecenter::Schema::Result::Hop',   'hop_ip');
1;
