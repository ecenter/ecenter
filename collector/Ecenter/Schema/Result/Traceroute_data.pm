package Ecenter::Schema::Result::Traceroute_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('traceroute_data');
__PACKAGE__->add_columns(qw/trace_id metaid number_hops  updated/);
__PACKAGE__->set_primary_key('trace_id');

__PACKAGE__->add_unique_constraint( updated_metaid  => [ qw/metaid updated/ ]);
__PACKAGE__->belongs_to(metaid => 'Ecenter::Schema::Result::Metadata', 'metaid');
__PACKAGE__->has_many(hops => 'Ecenter::Schema::Result::Hop', 'hop_id');



1;
