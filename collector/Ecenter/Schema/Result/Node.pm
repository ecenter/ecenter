package Ecenter::Schema::Result::Node;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(qw/ip_addr nodename ipv4_dot/);
__PACKAGE__->set_primary_key('ip_addr');
__PACKAGE__->has_many(metadatas =>  'Ecenter::Schema::Result::Metadata');
__PACKAGE__->has_many(hop_ids =>  'Ecenter::Schema::Result::Hop');
1;
