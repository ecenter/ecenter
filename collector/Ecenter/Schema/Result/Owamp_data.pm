package Ecenter::Schema::Result::Owamp_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('owamp_data');
__PACKAGE__->add_columns(qw/owamp_data metadata  timestamp   min max minttl maxttl  lossPercent  dups maxerr/); 
__PACKAGE__->set_primary_key('owamp_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata');


1;
