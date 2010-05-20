package Ecenter::Schema::Result::Node;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(qw/ip_addr nodename ipv4_dot/);
__PACKAGE__->set_primary_key('ip_addr');
__PACKAGE__->has_many(metadatas =>  'Ecenter::Schema::Result::Metadata', 'metadata');
__PACKAGE__->has_many(hops =>  'Ecenter::Schema::Result::Hop',    { 'foreign.hop_ip' => 'self.ip_addr' } );
1;
