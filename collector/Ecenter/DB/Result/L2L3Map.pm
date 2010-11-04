package Ecenter::DB::Result::L2L3Map;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::L2L3Map

=cut

__PACKAGE__->table("l2_l3_map");

=head1 ACCESSORS

=head2 l2_l3_map

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 ip_addr

  data_type: 'varbinary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 l2_urn

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 512

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 updated

  data_type: 'timestamp'
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "l2_l3_map",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "ip_addr",
  { data_type => "varbinary", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "l2_urn",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 512 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "updated",
  {
    data_type     => "timestamp",
    default_value => "0000-00-00 00:00:00",
    is_nullable   => 0,
  },
);
__PACKAGE__->set_primary_key("l2_l3_map");
__PACKAGE__->add_unique_constraint("ip_l2_time", ["ip_addr", "l2_urn", "created"]);

=head1 RELATIONS

=head2 l2_urn

Type: belongs_to

Related object: L<Ecenter::DB::Result::L2Port>

=cut

__PACKAGE__->belongs_to(
  "l2_urn",
  "Ecenter::DB::Result::L2Port",
  { l2_urn => "l2_urn" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 ip_addr

Type: belongs_to

Related object: L<Ecenter::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "ip_addr",
  "Ecenter::DB::Result::Node",
  { ip_addr => "ip_addr" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:re6LDAFKy7NIVi1wooFy1A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
