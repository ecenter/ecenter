package Ecenter::DB::Result::Circuit201312;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Circuit201312

=cut

__PACKAGE__->table("circuit_201312");

=head1 ACCESSORS

=head2 circuit

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 512

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
  "start_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "end_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("circuit");

=head1 RELATIONS

=head2 circuit_link_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::CircuitLink201312>

=cut

__PACKAGE__->has_many(
  "circuit_link_201312s",
  "Ecenter::DB::Result::CircuitLink201312",
  { "foreign.circuit" => "self.circuit" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-10-21 16:12:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GSgInD/TxCQvZUjbi2LSbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
