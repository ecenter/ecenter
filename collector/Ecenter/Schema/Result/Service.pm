package Ecenter::Schema::Result::Service;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('service');
__PACKAGE__->add_columns(qw/service name  url type comments is_alive updated/);
__PACKAGE__->add_unique_constraint(  service_url => [ qw/url/ ]);
__PACKAGE__->set_primary_key('service'); 
__PACKAGE__->has_many(eventtypes =>  'Ecenter::Schema::Result::Eventtype');
__PACKAGE__->has_many(keywords_services =>  'Ecenter::Schema::Result::Keywords_Service');

1;
