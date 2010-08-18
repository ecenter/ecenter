package Ecenter::Schema::Result::Service;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('service');
__PACKAGE__->add_columns(qw/service name ip_addr  url  comments is_alive created updated/);
__PACKAGE__->set_primary_key('service'); 
__PACKAGE__->add_unique_constraint(  service_url => [ qw/url/ ]);
__PACKAGE__->belongs_to(node => 'Ecenter::Schema::Result::Node', 'ip_addr' );
__PACKAGE__->has_many(eventtypes =>  'Ecenter::Schema::Result::Eventtype', 'service');
__PACKAGE__->has_many(keywords_services =>  'Ecenter::Schema::Result::Keywords_Service');



1;
