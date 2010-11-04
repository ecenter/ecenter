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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gQKdtniyCwgGHANistNEJw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
