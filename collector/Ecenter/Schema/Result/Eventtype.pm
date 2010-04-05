package Ecenter::Schema::Result::Eventtype;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('eventtype');
__PACKAGE__->add_columns(qw/ref_id  eventtype service/);
__PACKAGE__->add_unique_constraint( eventtype_service => [ qw/eventtype service/ ]);
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->set_primary_key('ref_id'); 

1;
