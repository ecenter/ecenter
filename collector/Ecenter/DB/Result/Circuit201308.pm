package Ecenter::DB::Result::Circuit201308;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Circuit201308

=cut

__PACKAGE__->table("circuit_201308");

=head1 ACCESSORS

=head2 circuit

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 src_hub

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 dst_hub

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 start_time

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 end_time

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "circuit",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "src_hub",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "dst_hub",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "start_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "end_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("circuit");

=head1 RELATIONS

=head2 src_hub

Type: belongs_to

Related object: L<Ecenter::DB::Result::Hub>

=cut

__PACKAGE__->belongs_to(
  "src_hub",
  "Ecenter::DB::Result::Hub",
  { hub => "src_hub" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 dst_hub

Type: belongs_to

Related object: L<Ecenter::DB::Result::Hub>

=cut

__PACKAGE__->belongs_to(
  "dst_hub",
  "Ecenter::DB::Result::Hub",
  { hub => "dst_hub" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 circuit_link_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201308>

=cut

__PACKAGE__->has_many(
  "circuit_link_201308s",
  "Ecenter::DB::Result::CircuitLink201308",
  { "foreign.circuit" => "self.circuit" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-12-09 17:22:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Goz+Ku0hUzRw48R+J5yp/g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
