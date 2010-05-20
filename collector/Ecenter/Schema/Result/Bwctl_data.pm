package Ecenter::Schema::Result::Bwctl_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('bwctl_data');
__PACKAGE__->add_columns(qw/bwctl_data metadata   timestamp throughput jitter lost sent/);
__PACKAGE__->set_primary_key('bwctl_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata');



1;
