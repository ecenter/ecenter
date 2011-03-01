package Ecenter::DB::Result::Eventtype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Eventtype

=cut

__PACKAGE__->table("eventtype");

=head1 ACCESSORS

=head2 ref_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 eventtype

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 service

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 service_type

  data_type: 'varchar'
  default_value: 'hLS'
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "ref_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "eventtype",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "service",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "service_type",
  {
    data_type => "varchar",
    default_value => "hLS",
    is_nullable => 0,
    size => 32,
  },
);
__PACKAGE__->set_primary_key("ref_id");
__PACKAGE__->add_unique_constraint(
  "eventtype_service_type",
  ["eventtype", "service", "service_type"],
);

=head1 RELATIONS

=head2 service

Type: belongs_to

Related object: L<Ecenter::DB::Result::Service>

=cut

__PACKAGE__->belongs_to(
  "service",
  "Ecenter::DB::Result::Service",
  { service => "service" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 metadatas

Type: has_many

Related object: L<Ecenter::DB::Result::Metadata>

=cut

__PACKAGE__->has_many(
  "metadatas",
  "Ecenter::DB::Result::Metadata",
  { "foreign.eventtype_id" => "self.ref_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-28 16:15:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nBbEUORHMsl5qT2ryPCFTA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
