package Ecenter::Schema::Result::Data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('data');
__PACKAGE__->add_columns(qw/data metadata  param value/); 
__PACKAGE__->belongs_to(metadatas => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->set_primary_key('data');


1;
