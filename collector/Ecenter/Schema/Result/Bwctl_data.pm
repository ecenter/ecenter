package Ecenter::Schema::Result::Bwctl_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('bwctl_data');
__PACKAGE__->add_columns(qw/bwctl_data metaid timestamp throughput/);
__PACKAGE__->set_primary_key('bwctl_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata','metaid');


__PACKAGE__->add_unique_constraint( meta_time => [ qw/metaid timestamp/ ]);

1;
