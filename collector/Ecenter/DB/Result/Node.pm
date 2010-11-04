package Ecenter::DB::Result::Node;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Node

=cut

__PACKAGE__->table("node");

=head1 ACCESSORS

=head2 ip_addr

  data_type: 'varbinary'
  is_nullable: 0
  size: 16

=head2 nodename

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 ip_noted

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 netmask

  data_type: 'smallint'
  default_value: 24
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ip_addr",
  { data_type => "varbinary", is_nullable => 0, size => 16 },
  "nodename",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "ip_noted",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "netmask",
  { data_type => "smallint", default_value => 24, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("ip_addr");

=head1 RELATIONS

=head2 hop_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201011>

=cut

__PACKAGE__->has_many(
  "hop_data_201011s",
  "Ecenter::DB::Result::HopData201011",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 l2_l3_maps

Type: has_many

Related object: L<Ecenter::DB::Result::L2L3Map>

=cut

__PACKAGE__->has_many(
  "l2_l3_maps",
  "Ecenter::DB::Result::L2L3Map",
  { "foreign.ip_addr" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 services

Type: has_many

Related object: L<Ecenter::DB::Result::Service>

=cut

__PACKAGE__->has_many(
  "services",
  "Ecenter::DB::Result::Service",
  { "foreign.ip_addr" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YcIyjtBN4+vDHZo2kEtw5Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
