package Ecenter::DB::Result::CircuitLink201311;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::CircuitLink201311

=cut

__PACKAGE__->table("circuit_link_201311");

=head1 ACCESSORS

=head2 circuit_link

  data_type: 'varchar'
  is_nullable: 0
  size: 512

=head2 l2_urn

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 512

=head2 circuit

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 64

=head2 link_num

  data_type: 'smallint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 0

=head2 direction

  data_type: 'enum'
  default_value: 'forward'
  extra: {list => ["forward","reverse"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "circuit_link",
  { data_type => "varchar", is_nullable => 0, size => 512 },
  "l2_urn",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 512 },
  "circuit",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 64 },
  "link_num",
  {
    data_type => "smallint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "direction",
  {
    data_type => "enum",
    default_value => "forward",
    extra => { list => ["forward", "reverse"] },
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("circuit_link");

=head1 RELATIONS

=head2 circuit

Type: belongs_to

Related object: L<Ecenter::DB::Result::Circuit201311>

=cut

__PACKAGE__->belongs_to(
  "circuit",
  "Ecenter::DB::Result::Circuit201311",
  { circuit => "circuit" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-10-21 16:14:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qDkL4qkQwT7lo8uFwlzWKw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
