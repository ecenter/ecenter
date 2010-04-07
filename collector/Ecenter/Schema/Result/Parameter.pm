package Ecenter::Schema::Result::Parameter;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('parameter');
__PACKAGE__->add_columns(qw/param_id name metaid/); 
__PACKAGE__->belongs_to(metaid => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->set_primary_key('param_id');
1;
