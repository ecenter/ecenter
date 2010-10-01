package Ecenter::Schema::Result::Hub;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('hub');
__PACKAGE__->add_columns(qw/hub hub_name description longitude latitude/);
__PACKAGE__->set_primary_key('hub');
__PACKAGE__->has_many(l2_ports =>  'Ecenter::Schema::Result::L2_port', 'hub');

1;
