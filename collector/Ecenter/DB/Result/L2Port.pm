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

=head2 circuit_link_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201112>

=cut

__PACKAGE__->has_many(
  "circuit_link_201112s",
  "Ecenter::DB::Result::CircuitLink201112",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201201>

=cut

__PACKAGE__->has_many(
  "circuit_link_201201s",
  "Ecenter::DB::Result::CircuitLink201201",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201202>

=cut

__PACKAGE__->has_many(
  "circuit_link_201202s",
  "Ecenter::DB::Result::CircuitLink201202",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201203>

=cut

__PACKAGE__->has_many(
  "circuit_link_201203s",
  "Ecenter::DB::Result::CircuitLink201203",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201204>

=cut

__PACKAGE__->has_many(
  "circuit_link_201204s",
  "Ecenter::DB::Result::CircuitLink201204",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201205>

=cut

__PACKAGE__->has_many(
  "circuit_link_201205s",
  "Ecenter::DB::Result::CircuitLink201205",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201206>

=cut

__PACKAGE__->has_many(
  "circuit_link_201206s",
  "Ecenter::DB::Result::CircuitLink201206",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201207>

=cut

__PACKAGE__->has_many(
  "circuit_link_201207s",
  "Ecenter::DB::Result::CircuitLink201207",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201208>

=cut

__PACKAGE__->has_many(
  "circuit_link_201208s",
  "Ecenter::DB::Result::CircuitLink201208",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201209>

=cut

__PACKAGE__->has_many(
  "circuit_link_201209s",
  "Ecenter::DB::Result::CircuitLink201209",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201210>

=cut

__PACKAGE__->has_many(
  "circuit_link_201210s",
  "Ecenter::DB::Result::CircuitLink201210",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201211>

=cut

__PACKAGE__->has_many(
  "circuit_link_201211s",
  "Ecenter::DB::Result::CircuitLink201211",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201212>

=cut

__PACKAGE__->has_many(
  "circuit_link_201212s",
  "Ecenter::DB::Result::CircuitLink201212",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201301>

=cut

__PACKAGE__->has_many(
  "circuit_link_201301s",
  "Ecenter::DB::Result::CircuitLink201301",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201302>

=cut

__PACKAGE__->has_many(
  "circuit_link_201302s",
  "Ecenter::DB::Result::CircuitLink201302",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201303>

=cut

__PACKAGE__->has_many(
  "circuit_link_201303s",
  "Ecenter::DB::Result::CircuitLink201303",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201304>

=cut

__PACKAGE__->has_many(
  "circuit_link_201304s",
  "Ecenter::DB::Result::CircuitLink201304",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201305>

=cut

__PACKAGE__->has_many(
  "circuit_link_201305s",
  "Ecenter::DB::Result::CircuitLink201305",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201306>

=cut

__PACKAGE__->has_many(
  "circuit_link_201306s",
  "Ecenter::DB::Result::CircuitLink201306",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201307>

=cut

__PACKAGE__->has_many(
  "circuit_link_201307s",
  "Ecenter::DB::Result::CircuitLink201307",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201308>

=cut

__PACKAGE__->has_many(
  "circuit_link_201308s",
  "Ecenter::DB::Result::CircuitLink201308",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201309>

=cut

__PACKAGE__->has_many(
  "circuit_link_201309s",
  "Ecenter::DB::Result::CircuitLink201309",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201310>

=cut

__PACKAGE__->has_many(
  "circuit_link_201310s",
  "Ecenter::DB::Result::CircuitLink201310",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201311>

=cut

__PACKAGE__->has_many(
  "circuit_link_201311s",
  "Ecenter::DB::Result::CircuitLink201311",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201312>

=cut

__PACKAGE__->has_many(
  "circuit_link_201312s",
  "Ecenter::DB::Result::CircuitLink201312",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201401>

=cut

__PACKAGE__->has_many(
  "circuit_link_201401s",
  "Ecenter::DB::Result::CircuitLink201401",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201402>

=cut

__PACKAGE__->has_many(
  "circuit_link_201402s",
  "Ecenter::DB::Result::CircuitLink201402",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201403>

=cut

__PACKAGE__->has_many(
  "circuit_link_201403s",
  "Ecenter::DB::Result::CircuitLink201403",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201404>

=cut

__PACKAGE__->has_many(
  "circuit_link_201404s",
  "Ecenter::DB::Result::CircuitLink201404",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201405>

=cut

__PACKAGE__->has_many(
  "circuit_link_201405s",
  "Ecenter::DB::Result::CircuitLink201405",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201406>

=cut

__PACKAGE__->has_many(
  "circuit_link_201406s",
  "Ecenter::DB::Result::CircuitLink201406",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201407>

=cut

__PACKAGE__->has_many(
  "circuit_link_201407s",
  "Ecenter::DB::Result::CircuitLink201407",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201408>

=cut

__PACKAGE__->has_many(
  "circuit_link_201408s",
  "Ecenter::DB::Result::CircuitLink201408",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201409>

=cut

__PACKAGE__->has_many(
  "circuit_link_201409s",
  "Ecenter::DB::Result::CircuitLink201409",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201410>

=cut

__PACKAGE__->has_many(
  "circuit_link_201410s",
  "Ecenter::DB::Result::CircuitLink201410",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201411>

=cut

__PACKAGE__->has_many(
  "circuit_link_201411s",
  "Ecenter::DB::Result::CircuitLink201411",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_link_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201412>

=cut

__PACKAGE__->has_many(
  "circuit_link_201412s",
  "Ecenter::DB::Result::CircuitLink201412",
  { "foreign.l2_urn" => "self.l2_urn" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-12-12 16:41:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w9TPmoXAzeCirkjVHz0RWw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
