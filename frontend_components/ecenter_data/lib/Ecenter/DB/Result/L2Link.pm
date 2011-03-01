package Ecenter::DB::Result::L2Link;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::L2Link

=cut

__PACKAGE__->table("l2_link");

=head1 ACCESSORS

=head2 l2_link

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 l2_src_urn

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 512

=head2 l2_dst_urn

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 512

=cut

__PACKAGE__->add_columns(
  "l2_link",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "l2_src_urn",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 512 },
  "l2_dst_urn",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 512 },
);
__PACKAGE__->set_primary_key("l2_link");

=head1 RELATIONS

=head2 l2_src_urn

Type: belongs_to

Related object: L<Ecenter::DB::Result::L2Port>

=cut

__PACKAGE__->belongs_to(
  "l2_src_urn",
  "Ecenter::DB::Result::L2Port",
  { l2_urn => "l2_src_urn" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 l2_dst_urn

Type: belongs_to

Related object: L<Ecenter::DB::Result::L2Port>

=cut

__PACKAGE__->belongs_to(
  "l2_dst_urn",
  "Ecenter::DB::Result::L2Port",
  { l2_urn => "l2_dst_urn" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-28 16:15:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S44uxszkwIOrm05dYoZVjQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
