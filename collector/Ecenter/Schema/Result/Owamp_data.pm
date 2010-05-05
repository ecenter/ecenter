package Ecenter::Schema::Result::Owamp_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('owamp_data');
__PACKAGE__->add_columns(qw/owamp_data metadata   stimestamp etimestamp  min max minttl maxttl sent lost  dups maxerr/); 
__PACKAGE__->belongs_to(metadatas => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->set_primary_key('owamp_data');


1;
