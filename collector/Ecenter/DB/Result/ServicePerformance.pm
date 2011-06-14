package Ecenter::DB::Result::ServicePerformance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::ServicePerformance

=cut

__PACKAGE__->table("service_performance");

=head1 ACCESSORS

=head2 service_performance

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 requested_start

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 requested_time

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 response

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 is_data

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "service_performance",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "metaid",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "requested_start",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "requested_time",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "response",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "is_data",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "updated",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("service_performance");
__PACKAGE__->add_unique_constraint("metaid_updated", ["metaid", "updated"]);

=head1 RELATIONS

=head2 metaid

Type: belongs_to

Related object: L<Ecenter::DB::Result::Metadata>

=cut

__PACKAGE__->belongs_to(
  "metaid",
  "Ecenter::DB::Result::Metadata",
  { metaid => "metaid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-06-14 11:31:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eaS7w1vIIp/20CaKv9T+PQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
