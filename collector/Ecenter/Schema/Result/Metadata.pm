package Ecenter::Schema::Result::Metadata;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('metadata');
__PACKAGE__->add_columns(qw/metadata metaid service subject parameters/); 
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->set_primary_key('metadata');
__PACKAGE__->add_unique_constraint( metaid_service => [ qw/metaid service/ ]);

1;
