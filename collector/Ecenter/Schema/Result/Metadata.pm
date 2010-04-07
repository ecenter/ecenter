package Ecenter::Schema::Result::Metadata;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('metadata');
__PACKAGE__->add_columns(qw/metaid service/); 
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->set_primary_key('metaid');
__PACKAGE__->has_many(parameters =>  'Ecenter::Schema::Result::Parameter');


1;
