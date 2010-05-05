package Ecenter::Schema::Result::Node;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('node');
__PACKAGE__->add_columns(qw/ip_addr nodename/);
__PACKAGE__->set_primary_key('ip_addr');
__PACKAGE__->has_many(bwctl_datas =>  'Ecenter::Schema::Result::Bwctl_data');
__PACKAGE__->has_many(metadatas =>  'Ecenter::Schema::Result::Metadata');
1;
