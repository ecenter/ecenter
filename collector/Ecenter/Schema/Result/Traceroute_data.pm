package Ecenter::Schema::Result::Traceroute_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('traceroute_data');
__PACKAGE__->add_columns(qw/trace_id metadata number_hops delay created updated/);
__PACKAGE__->set_primary_key('trace_id');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->has_many(hops => 'Ecenter::Schema::Result::Hop', 'hop_id');



1;
