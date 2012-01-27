package Ecenter::DB::Result::Hub;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Hub

=cut

__PACKAGE__->table("hub");

=head1 ACCESSORS

=head2 hub

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 hub_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 longitude

  data_type: 'float'
  is_nullable: 1

=head2 latitude

  data_type: 'float'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "hub",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "hub_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "longitude",
  { data_type => "float", is_nullable => 1 },
  "latitude",
  { data_type => "float", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("hub");

=head1 RELATIONS

=head2 circuit_201111_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201111>

=cut

__PACKAGE__->has_many(
  "circuit_201111_dst_hubs",
  "Ecenter::DB::Result::Circuit201111",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201111_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201111>

=cut

__PACKAGE__->has_many(
  "circuit_201111_src_hubs",
  "Ecenter::DB::Result::Circuit201111",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201112_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201112>

=cut

__PACKAGE__->has_many(
  "circuit_201112_dst_hubs",
  "Ecenter::DB::Result::Circuit201112",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201112_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201112>

=cut

__PACKAGE__->has_many(
  "circuit_201112_src_hubs",
  "Ecenter::DB::Result::Circuit201112",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201201_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201201>

=cut

__PACKAGE__->has_many(
  "circuit_201201_src_hubs",
  "Ecenter::DB::Result::Circuit201201",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201201_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201201>

=cut

__PACKAGE__->has_many(
  "circuit_201201_dst_hubs",
  "Ecenter::DB::Result::Circuit201201",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201202_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201202>

=cut

__PACKAGE__->has_many(
  "circuit_201202_src_hubs",
  "Ecenter::DB::Result::Circuit201202",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201202_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201202>

=cut

__PACKAGE__->has_many(
  "circuit_201202_dst_hubs",
  "Ecenter::DB::Result::Circuit201202",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201203_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201203>

=cut

__PACKAGE__->has_many(
  "circuit_201203_src_hubs",
  "Ecenter::DB::Result::Circuit201203",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201203_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201203>

=cut

__PACKAGE__->has_many(
  "circuit_201203_dst_hubs",
  "Ecenter::DB::Result::Circuit201203",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201204_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201204>

=cut

__PACKAGE__->has_many(
  "circuit_201204_src_hubs",
  "Ecenter::DB::Result::Circuit201204",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201204_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201204>

=cut

__PACKAGE__->has_many(
  "circuit_201204_dst_hubs",
  "Ecenter::DB::Result::Circuit201204",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201205_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201205>

=cut

__PACKAGE__->has_many(
  "circuit_201205_src_hubs",
  "Ecenter::DB::Result::Circuit201205",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201205_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201205>

=cut

__PACKAGE__->has_many(
  "circuit_201205_dst_hubs",
  "Ecenter::DB::Result::Circuit201205",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201206_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201206>

=cut

__PACKAGE__->has_many(
  "circuit_201206_src_hubs",
  "Ecenter::DB::Result::Circuit201206",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201206_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201206>

=cut

__PACKAGE__->has_many(
  "circuit_201206_dst_hubs",
  "Ecenter::DB::Result::Circuit201206",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201207_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201207>

=cut

__PACKAGE__->has_many(
  "circuit_201207_src_hubs",
  "Ecenter::DB::Result::Circuit201207",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201207_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201207>

=cut

__PACKAGE__->has_many(
  "circuit_201207_dst_hubs",
  "Ecenter::DB::Result::Circuit201207",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201208_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201208>

=cut

__PACKAGE__->has_many(
  "circuit_201208_src_hubs",
  "Ecenter::DB::Result::Circuit201208",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201208_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201208>

=cut

__PACKAGE__->has_many(
  "circuit_201208_dst_hubs",
  "Ecenter::DB::Result::Circuit201208",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201209_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201209>

=cut

__PACKAGE__->has_many(
  "circuit_201209_src_hubs",
  "Ecenter::DB::Result::Circuit201209",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201209_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201209>

=cut

__PACKAGE__->has_many(
  "circuit_201209_dst_hubs",
  "Ecenter::DB::Result::Circuit201209",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201210_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201210>

=cut

__PACKAGE__->has_many(
  "circuit_201210_src_hubs",
  "Ecenter::DB::Result::Circuit201210",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201210_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201210>

=cut

__PACKAGE__->has_many(
  "circuit_201210_dst_hubs",
  "Ecenter::DB::Result::Circuit201210",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201211_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201211>

=cut

__PACKAGE__->has_many(
  "circuit_201211_src_hubs",
  "Ecenter::DB::Result::Circuit201211",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201211_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201211>

=cut

__PACKAGE__->has_many(
  "circuit_201211_dst_hubs",
  "Ecenter::DB::Result::Circuit201211",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201212_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201212>

=cut

__PACKAGE__->has_many(
  "circuit_201212_src_hubs",
  "Ecenter::DB::Result::Circuit201212",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201212_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201212>

=cut

__PACKAGE__->has_many(
  "circuit_201212_dst_hubs",
  "Ecenter::DB::Result::Circuit201212",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201301_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201301>

=cut

__PACKAGE__->has_many(
  "circuit_201301_src_hubs",
  "Ecenter::DB::Result::Circuit201301",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201301_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201301>

=cut

__PACKAGE__->has_many(
  "circuit_201301_dst_hubs",
  "Ecenter::DB::Result::Circuit201301",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201302_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201302>

=cut

__PACKAGE__->has_many(
  "circuit_201302_src_hubs",
  "Ecenter::DB::Result::Circuit201302",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201302_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201302>

=cut

__PACKAGE__->has_many(
  "circuit_201302_dst_hubs",
  "Ecenter::DB::Result::Circuit201302",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201303_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201303>

=cut

__PACKAGE__->has_many(
  "circuit_201303_src_hubs",
  "Ecenter::DB::Result::Circuit201303",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201303_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201303>

=cut

__PACKAGE__->has_many(
  "circuit_201303_dst_hubs",
  "Ecenter::DB::Result::Circuit201303",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201304_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201304>

=cut

__PACKAGE__->has_many(
  "circuit_201304_src_hubs",
  "Ecenter::DB::Result::Circuit201304",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201304_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201304>

=cut

__PACKAGE__->has_many(
  "circuit_201304_dst_hubs",
  "Ecenter::DB::Result::Circuit201304",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201305_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201305>

=cut

__PACKAGE__->has_many(
  "circuit_201305_src_hubs",
  "Ecenter::DB::Result::Circuit201305",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201305_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201305>

=cut

__PACKAGE__->has_many(
  "circuit_201305_dst_hubs",
  "Ecenter::DB::Result::Circuit201305",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201306_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201306>

=cut

__PACKAGE__->has_many(
  "circuit_201306_src_hubs",
  "Ecenter::DB::Result::Circuit201306",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201306_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201306>

=cut

__PACKAGE__->has_many(
  "circuit_201306_dst_hubs",
  "Ecenter::DB::Result::Circuit201306",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201307_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201307>

=cut

__PACKAGE__->has_many(
  "circuit_201307_src_hubs",
  "Ecenter::DB::Result::Circuit201307",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201307_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201307>

=cut

__PACKAGE__->has_many(
  "circuit_201307_dst_hubs",
  "Ecenter::DB::Result::Circuit201307",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201308_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201308>

=cut

__PACKAGE__->has_many(
  "circuit_201308_src_hubs",
  "Ecenter::DB::Result::Circuit201308",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201308_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201308>

=cut

__PACKAGE__->has_many(
  "circuit_201308_dst_hubs",
  "Ecenter::DB::Result::Circuit201308",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201309_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201309>

=cut

__PACKAGE__->has_many(
  "circuit_201309_src_hubs",
  "Ecenter::DB::Result::Circuit201309",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201309_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201309>

=cut

__PACKAGE__->has_many(
  "circuit_201309_dst_hubs",
  "Ecenter::DB::Result::Circuit201309",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201310_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201310>

=cut

__PACKAGE__->has_many(
  "circuit_201310_src_hubs",
  "Ecenter::DB::Result::Circuit201310",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201310_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201310>

=cut

__PACKAGE__->has_many(
  "circuit_201310_dst_hubs",
  "Ecenter::DB::Result::Circuit201310",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201311_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201311>

=cut

__PACKAGE__->has_many(
  "circuit_201311_src_hubs",
  "Ecenter::DB::Result::Circuit201311",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201311_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201311>

=cut

__PACKAGE__->has_many(
  "circuit_201311_dst_hubs",
  "Ecenter::DB::Result::Circuit201311",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201312_src_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201312>

=cut

__PACKAGE__->has_many(
  "circuit_201312_src_hubs",
  "Ecenter::DB::Result::Circuit201312",
  { "foreign.src_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 circuit_201312_dst_hubs

Type: has_many

Related object: L<Ecenter::DB::Result::Circuit201312>

=cut

__PACKAGE__->has_many(
  "circuit_201312_dst_hubs",
  "Ecenter::DB::Result::Circuit201312",
  { "foreign.dst_hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 l2_ports

Type: has_many

Related object: L<Ecenter::DB::Result::L2Port>

=cut

__PACKAGE__->has_many(
  "l2_ports",
  "Ecenter::DB::Result::L2Port",
  { "foreign.hub" => "self.hub" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-12-09 17:22:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6JD/jsAIhTike/bR58eLWA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
