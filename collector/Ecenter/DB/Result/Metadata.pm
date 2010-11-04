package Ecenter::DB::Result::Metadata;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Metadata

=cut

__PACKAGE__->table("metadata");

=head1 ACCESSORS

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 src_ip

  data_type: 'varbinary'
  is_nullable: 0
  size: 16

=head2 dst_ip

  data_type: 'varbinary'
  default_value: 0
  is_nullable: 0
  size: 16

=head2 direction

  data_type: 'enum'
  default_value: 'in'
  extra: {list => ["in","out"]}
  is_nullable: 0

=head2 eventtype_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 subject

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 1023

=head2 parameters

  data_type: 'varchar'
  is_nullable: 1
  size: 1023

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
  "metaid",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "src_ip",
  { data_type => "varbinary", is_nullable => 0, size => 16 },
  "dst_ip",
  { data_type => "varbinary", default_value => 0, is_nullable => 0, size => 16 },
  "direction",
  {
    data_type => "enum",
    default_value => "in",
    extra => { list => ["in", "out"] },
    is_nullable => 0,
  },
  "eventtype_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "subject",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 1023 },
  "parameters",
  { data_type => "varchar", is_nullable => 1, size => 1023 },
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
__PACKAGE__->set_primary_key("metaid");
__PACKAGE__->add_unique_constraint("md_ips_type", ["src_ip", "dst_ip", "eventtype_id"]);

=head1 RELATIONS

=head2 bwctl_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201011>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201011s",
  "Ecenter::DB::Result::BwctlData201011",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201011>

=cut

__PACKAGE__->has_many(
  "hop_data_201011s",
  "Ecenter::DB::Result::HopData201011",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 eventtype

Type: belongs_to

Related object: L<Ecenter::DB::Result::Eventtype>

=cut

__PACKAGE__->belongs_to(
  "eventtype",
  "Ecenter::DB::Result::Eventtype",
  { ref_id => "eventtype_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 owamp_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201011>

=cut

__PACKAGE__->has_many(
  "owamp_data_201011s",
  "Ecenter::DB::Result::OwampData201011",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201011>

=cut

__PACKAGE__->has_many(
  "pinger_data_201011s",
  "Ecenter::DB::Result::PingerData201011",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201011s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201011>

=cut

__PACKAGE__->has_many(
  "snmp_data_201011s",
  "Ecenter::DB::Result::SnmpData201011",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rQYQftKGtlkILFauGP1Nlg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
