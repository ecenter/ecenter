package Ecenter::DB::Result::L2Port;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::L2Port

=cut

__PACKAGE__->table("l2_port");

=head1 ACCESSORS

=head2 l2_urn

  data_type: 'varchar'
  is_nullable: 0
  size: 512

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 capacity

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 hub

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "l2_urn",
  { data_type => "varchar", is_nullable => 0, size => 512 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "capacity",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "hub",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("l2_urn");

=head1 RELATIONS

=head2 l2_l3_maps

Type: has_many

Related object: L<Ecenter::DB::Result::L2L3Map>

=cut

__PACKAGE__->has_many(
  "l2_l3_maps",
  "Ecenter::DB::Result::L2L3Map",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 l2_link_l2_src_urns

Type: has_many

Related object: L<Ecenter::DB::Result::L2Link>

=cut

__PACKAGE__->has_many(
  "l2_link_l2_src_urns",
  "Ecenter::DB::Result::L2Link",
  { "foreign.l2_src_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 l2_link_l2_dst_urns

Type: has_many

Related object: L<Ecenter::DB::Result::L2Link>

=cut

__PACKAGE__->has_many(
  "l2_link_l2_dst_urns",
  "Ecenter::DB::Result::L2Link",
  { "foreign.l2_dst_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hub

Type: belongs_to

Related object: L<Ecenter::DB::Result::Hub>

=cut

__PACKAGE__->belongs_to(
  "hub",
  "Ecenter::DB::Result::Hub",
  { hub => "hub" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-28 16:15:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aERQRy9lQATkY5Ge0HW7LQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
