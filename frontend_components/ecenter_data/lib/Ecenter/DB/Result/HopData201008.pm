package Ecenter::DB::Result::HopData201008;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::HopData201008

=cut

__PACKAGE__->table("hop_data_201008");

=head1 ACCESSORS

=head2 hop_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 hop_ip

  data_type: 'varbinary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 hop_num

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 hop_delay

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=head2 timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "hop_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "metaid",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "hop_ip",
  { data_type => "varbinary", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "hop_num",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "hop_delay",
  { data_type => "float", default_value => 0, is_nullable => 0 },
  "timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("hop_id");
__PACKAGE__->add_unique_constraint("meta_time", ["metaid", "hop_ip", "timestamp"]);

=head1 RELATIONS

=head2 metaid

Type: belongs_to

Related object: L<Ecenter::DB::Result::Metadata>

=cut

__PACKAGE__->belongs_to(
  "metaid",
  "Ecenter::DB::Result::Metadata",
  { metaid => "metaid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 hop_ip

Type: belongs_to

Related object: L<Ecenter::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "hop_ip",
  "Ecenter::DB::Result::Node",
  { ip_addr => "hop_ip" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-18 15:39:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:igc186EgFqAWK7jz/VAAxg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
