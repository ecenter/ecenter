package Ecenter::Schema::Result::Owamp_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('owamp_data');
__PACKAGE__->add_columns(qw/owamp_data metaid timestamp   min_delay max_delay sent loss duplicates/); 
__PACKAGE__->set_primary_key('owamp_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata','metaid');

__PACKAGE__->add_unique_constraint( meta_time => [ qw/metaid timestamp/ ]);

1;
