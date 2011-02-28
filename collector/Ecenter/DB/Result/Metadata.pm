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

=head2 bwctl_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData200912>

=cut

__PACKAGE__->has_many(
  "bwctl_data_200912s",
  "Ecenter::DB::Result::BwctlData200912",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201001>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201001s",
  "Ecenter::DB::Result::BwctlData201001",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201002>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201002s",
  "Ecenter::DB::Result::BwctlData201002",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201003>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201003s",
  "Ecenter::DB::Result::BwctlData201003",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201004>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201004s",
  "Ecenter::DB::Result::BwctlData201004",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201005>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201005s",
  "Ecenter::DB::Result::BwctlData201005",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201006>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201006s",
  "Ecenter::DB::Result::BwctlData201006",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201007>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201007s",
  "Ecenter::DB::Result::BwctlData201007",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201008>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201008s",
  "Ecenter::DB::Result::BwctlData201008",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201009>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201009s",
  "Ecenter::DB::Result::BwctlData201009",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201010>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201010s",
  "Ecenter::DB::Result::BwctlData201010",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 bwctl_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201012>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201012s",
  "Ecenter::DB::Result::BwctlData201012",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201101>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201101s",
  "Ecenter::DB::Result::BwctlData201101",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201102>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201102s",
  "Ecenter::DB::Result::BwctlData201102",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201103>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201103s",
  "Ecenter::DB::Result::BwctlData201103",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201104>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201104s",
  "Ecenter::DB::Result::BwctlData201104",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201105>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201105s",
  "Ecenter::DB::Result::BwctlData201105",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201106>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201106s",
  "Ecenter::DB::Result::BwctlData201106",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201107>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201107s",
  "Ecenter::DB::Result::BwctlData201107",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201108>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201108s",
  "Ecenter::DB::Result::BwctlData201108",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201109>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201109s",
  "Ecenter::DB::Result::BwctlData201109",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201110>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201110s",
  "Ecenter::DB::Result::BwctlData201110",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201111>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201111s",
  "Ecenter::DB::Result::BwctlData201111",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201112>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201112s",
  "Ecenter::DB::Result::BwctlData201112",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201201>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201201s",
  "Ecenter::DB::Result::BwctlData201201",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201202>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201202s",
  "Ecenter::DB::Result::BwctlData201202",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201203>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201203s",
  "Ecenter::DB::Result::BwctlData201203",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201204>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201204s",
  "Ecenter::DB::Result::BwctlData201204",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201205>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201205s",
  "Ecenter::DB::Result::BwctlData201205",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201206>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201206s",
  "Ecenter::DB::Result::BwctlData201206",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201207>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201207s",
  "Ecenter::DB::Result::BwctlData201207",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201208>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201208s",
  "Ecenter::DB::Result::BwctlData201208",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201209>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201209s",
  "Ecenter::DB::Result::BwctlData201209",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201210>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201210s",
  "Ecenter::DB::Result::BwctlData201210",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201211>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201211s",
  "Ecenter::DB::Result::BwctlData201211",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201212>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201212s",
  "Ecenter::DB::Result::BwctlData201212",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201301>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201301s",
  "Ecenter::DB::Result::BwctlData201301",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201302>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201302s",
  "Ecenter::DB::Result::BwctlData201302",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201303>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201303s",
  "Ecenter::DB::Result::BwctlData201303",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201304>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201304s",
  "Ecenter::DB::Result::BwctlData201304",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201305>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201305s",
  "Ecenter::DB::Result::BwctlData201305",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201306>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201306s",
  "Ecenter::DB::Result::BwctlData201306",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201307>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201307s",
  "Ecenter::DB::Result::BwctlData201307",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201308>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201308s",
  "Ecenter::DB::Result::BwctlData201308",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201309>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201309s",
  "Ecenter::DB::Result::BwctlData201309",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201310>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201310s",
  "Ecenter::DB::Result::BwctlData201310",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201311>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201311s",
  "Ecenter::DB::Result::BwctlData201311",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201312>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201312s",
  "Ecenter::DB::Result::BwctlData201312",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201401>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201401s",
  "Ecenter::DB::Result::BwctlData201401",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201402>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201402s",
  "Ecenter::DB::Result::BwctlData201402",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201403>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201403s",
  "Ecenter::DB::Result::BwctlData201403",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201404>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201404s",
  "Ecenter::DB::Result::BwctlData201404",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201405>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201405s",
  "Ecenter::DB::Result::BwctlData201405",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201406>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201406s",
  "Ecenter::DB::Result::BwctlData201406",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201407>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201407s",
  "Ecenter::DB::Result::BwctlData201407",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201408>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201408s",
  "Ecenter::DB::Result::BwctlData201408",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201409>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201409s",
  "Ecenter::DB::Result::BwctlData201409",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201410>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201410s",
  "Ecenter::DB::Result::BwctlData201410",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201411>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201411s",
  "Ecenter::DB::Result::BwctlData201411",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201412>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201412s",
  "Ecenter::DB::Result::BwctlData201412",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201501>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201501s",
  "Ecenter::DB::Result::BwctlData201501",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201502>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201502s",
  "Ecenter::DB::Result::BwctlData201502",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201503>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201503s",
  "Ecenter::DB::Result::BwctlData201503",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201504>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201504s",
  "Ecenter::DB::Result::BwctlData201504",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201505>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201505s",
  "Ecenter::DB::Result::BwctlData201505",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201506>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201506s",
  "Ecenter::DB::Result::BwctlData201506",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201507>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201507s",
  "Ecenter::DB::Result::BwctlData201507",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201508>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201508s",
  "Ecenter::DB::Result::BwctlData201508",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201509>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201509s",
  "Ecenter::DB::Result::BwctlData201509",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201510>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201510s",
  "Ecenter::DB::Result::BwctlData201510",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201511>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201511s",
  "Ecenter::DB::Result::BwctlData201511",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bwctl_data_201512s

Type: has_many

Related object: L<Ecenter::DB::Result::BwctlData201512>

=cut

__PACKAGE__->has_many(
  "bwctl_data_201512s",
  "Ecenter::DB::Result::BwctlData201512",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData200912>

=cut

__PACKAGE__->has_many(
  "hop_data_200912s",
  "Ecenter::DB::Result::HopData200912",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201001>

=cut

__PACKAGE__->has_many(
  "hop_data_201001s",
  "Ecenter::DB::Result::HopData201001",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201002>

=cut

__PACKAGE__->has_many(
  "hop_data_201002s",
  "Ecenter::DB::Result::HopData201002",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201003>

=cut

__PACKAGE__->has_many(
  "hop_data_201003s",
  "Ecenter::DB::Result::HopData201003",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201004>

=cut

__PACKAGE__->has_many(
  "hop_data_201004s",
  "Ecenter::DB::Result::HopData201004",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201005>

=cut

__PACKAGE__->has_many(
  "hop_data_201005s",
  "Ecenter::DB::Result::HopData201005",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201006>

=cut

__PACKAGE__->has_many(
  "hop_data_201006s",
  "Ecenter::DB::Result::HopData201006",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201007>

=cut

__PACKAGE__->has_many(
  "hop_data_201007s",
  "Ecenter::DB::Result::HopData201007",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201008>

=cut

__PACKAGE__->has_many(
  "hop_data_201008s",
  "Ecenter::DB::Result::HopData201008",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201009>

=cut

__PACKAGE__->has_many(
  "hop_data_201009s",
  "Ecenter::DB::Result::HopData201009",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201010>

=cut

__PACKAGE__->has_many(
  "hop_data_201010s",
  "Ecenter::DB::Result::HopData201010",
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

=head2 hop_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201012>

=cut

__PACKAGE__->has_many(
  "hop_data_201012s",
  "Ecenter::DB::Result::HopData201012",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201101>

=cut

__PACKAGE__->has_many(
  "hop_data_201101s",
  "Ecenter::DB::Result::HopData201101",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201102>

=cut

__PACKAGE__->has_many(
  "hop_data_201102s",
  "Ecenter::DB::Result::HopData201102",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201103>

=cut

__PACKAGE__->has_many(
  "hop_data_201103s",
  "Ecenter::DB::Result::HopData201103",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201104>

=cut

__PACKAGE__->has_many(
  "hop_data_201104s",
  "Ecenter::DB::Result::HopData201104",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201105>

=cut

__PACKAGE__->has_many(
  "hop_data_201105s",
  "Ecenter::DB::Result::HopData201105",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201106>

=cut

__PACKAGE__->has_many(
  "hop_data_201106s",
  "Ecenter::DB::Result::HopData201106",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201107>

=cut

__PACKAGE__->has_many(
  "hop_data_201107s",
  "Ecenter::DB::Result::HopData201107",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201108>

=cut

__PACKAGE__->has_many(
  "hop_data_201108s",
  "Ecenter::DB::Result::HopData201108",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201109>

=cut

__PACKAGE__->has_many(
  "hop_data_201109s",
  "Ecenter::DB::Result::HopData201109",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201110>

=cut

__PACKAGE__->has_many(
  "hop_data_201110s",
  "Ecenter::DB::Result::HopData201110",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201111>

=cut

__PACKAGE__->has_many(
  "hop_data_201111s",
  "Ecenter::DB::Result::HopData201111",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201112>

=cut

__PACKAGE__->has_many(
  "hop_data_201112s",
  "Ecenter::DB::Result::HopData201112",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201201>

=cut

__PACKAGE__->has_many(
  "hop_data_201201s",
  "Ecenter::DB::Result::HopData201201",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201202>

=cut

__PACKAGE__->has_many(
  "hop_data_201202s",
  "Ecenter::DB::Result::HopData201202",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201203>

=cut

__PACKAGE__->has_many(
  "hop_data_201203s",
  "Ecenter::DB::Result::HopData201203",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201204>

=cut

__PACKAGE__->has_many(
  "hop_data_201204s",
  "Ecenter::DB::Result::HopData201204",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201205>

=cut

__PACKAGE__->has_many(
  "hop_data_201205s",
  "Ecenter::DB::Result::HopData201205",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201206>

=cut

__PACKAGE__->has_many(
  "hop_data_201206s",
  "Ecenter::DB::Result::HopData201206",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201207>

=cut

__PACKAGE__->has_many(
  "hop_data_201207s",
  "Ecenter::DB::Result::HopData201207",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201208>

=cut

__PACKAGE__->has_many(
  "hop_data_201208s",
  "Ecenter::DB::Result::HopData201208",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201209>

=cut

__PACKAGE__->has_many(
  "hop_data_201209s",
  "Ecenter::DB::Result::HopData201209",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201210>

=cut

__PACKAGE__->has_many(
  "hop_data_201210s",
  "Ecenter::DB::Result::HopData201210",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201211>

=cut

__PACKAGE__->has_many(
  "hop_data_201211s",
  "Ecenter::DB::Result::HopData201211",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201212>

=cut

__PACKAGE__->has_many(
  "hop_data_201212s",
  "Ecenter::DB::Result::HopData201212",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201301>

=cut

__PACKAGE__->has_many(
  "hop_data_201301s",
  "Ecenter::DB::Result::HopData201301",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201302>

=cut

__PACKAGE__->has_many(
  "hop_data_201302s",
  "Ecenter::DB::Result::HopData201302",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201303>

=cut

__PACKAGE__->has_many(
  "hop_data_201303s",
  "Ecenter::DB::Result::HopData201303",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201304>

=cut

__PACKAGE__->has_many(
  "hop_data_201304s",
  "Ecenter::DB::Result::HopData201304",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201305>

=cut

__PACKAGE__->has_many(
  "hop_data_201305s",
  "Ecenter::DB::Result::HopData201305",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201306>

=cut

__PACKAGE__->has_many(
  "hop_data_201306s",
  "Ecenter::DB::Result::HopData201306",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201307>

=cut

__PACKAGE__->has_many(
  "hop_data_201307s",
  "Ecenter::DB::Result::HopData201307",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201308>

=cut

__PACKAGE__->has_many(
  "hop_data_201308s",
  "Ecenter::DB::Result::HopData201308",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201309>

=cut

__PACKAGE__->has_many(
  "hop_data_201309s",
  "Ecenter::DB::Result::HopData201309",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201310>

=cut

__PACKAGE__->has_many(
  "hop_data_201310s",
  "Ecenter::DB::Result::HopData201310",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201311>

=cut

__PACKAGE__->has_many(
  "hop_data_201311s",
  "Ecenter::DB::Result::HopData201311",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201312>

=cut

__PACKAGE__->has_many(
  "hop_data_201312s",
  "Ecenter::DB::Result::HopData201312",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201401>

=cut

__PACKAGE__->has_many(
  "hop_data_201401s",
  "Ecenter::DB::Result::HopData201401",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201402>

=cut

__PACKAGE__->has_many(
  "hop_data_201402s",
  "Ecenter::DB::Result::HopData201402",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201403>

=cut

__PACKAGE__->has_many(
  "hop_data_201403s",
  "Ecenter::DB::Result::HopData201403",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201404>

=cut

__PACKAGE__->has_many(
  "hop_data_201404s",
  "Ecenter::DB::Result::HopData201404",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201405>

=cut

__PACKAGE__->has_many(
  "hop_data_201405s",
  "Ecenter::DB::Result::HopData201405",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201406>

=cut

__PACKAGE__->has_many(
  "hop_data_201406s",
  "Ecenter::DB::Result::HopData201406",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201407>

=cut

__PACKAGE__->has_many(
  "hop_data_201407s",
  "Ecenter::DB::Result::HopData201407",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201408>

=cut

__PACKAGE__->has_many(
  "hop_data_201408s",
  "Ecenter::DB::Result::HopData201408",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201409>

=cut

__PACKAGE__->has_many(
  "hop_data_201409s",
  "Ecenter::DB::Result::HopData201409",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201410>

=cut

__PACKAGE__->has_many(
  "hop_data_201410s",
  "Ecenter::DB::Result::HopData201410",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201411>

=cut

__PACKAGE__->has_many(
  "hop_data_201411s",
  "Ecenter::DB::Result::HopData201411",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201412>

=cut

__PACKAGE__->has_many(
  "hop_data_201412s",
  "Ecenter::DB::Result::HopData201412",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201501>

=cut

__PACKAGE__->has_many(
  "hop_data_201501s",
  "Ecenter::DB::Result::HopData201501",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201502>

=cut

__PACKAGE__->has_many(
  "hop_data_201502s",
  "Ecenter::DB::Result::HopData201502",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201503>

=cut

__PACKAGE__->has_many(
  "hop_data_201503s",
  "Ecenter::DB::Result::HopData201503",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201504>

=cut

__PACKAGE__->has_many(
  "hop_data_201504s",
  "Ecenter::DB::Result::HopData201504",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201505>

=cut

__PACKAGE__->has_many(
  "hop_data_201505s",
  "Ecenter::DB::Result::HopData201505",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201506>

=cut

__PACKAGE__->has_many(
  "hop_data_201506s",
  "Ecenter::DB::Result::HopData201506",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201507>

=cut

__PACKAGE__->has_many(
  "hop_data_201507s",
  "Ecenter::DB::Result::HopData201507",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201508>

=cut

__PACKAGE__->has_many(
  "hop_data_201508s",
  "Ecenter::DB::Result::HopData201508",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201509>

=cut

__PACKAGE__->has_many(
  "hop_data_201509s",
  "Ecenter::DB::Result::HopData201509",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201510>

=cut

__PACKAGE__->has_many(
  "hop_data_201510s",
  "Ecenter::DB::Result::HopData201510",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201511>

=cut

__PACKAGE__->has_many(
  "hop_data_201511s",
  "Ecenter::DB::Result::HopData201511",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201512s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201512>

=cut

__PACKAGE__->has_many(
  "hop_data_201512s",
  "Ecenter::DB::Result::HopData201512",
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

=head2 owamp_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData200912>

=cut

__PACKAGE__->has_many(
  "owamp_data_200912s",
  "Ecenter::DB::Result::OwampData200912",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201001>

=cut

__PACKAGE__->has_many(
  "owamp_data_201001s",
  "Ecenter::DB::Result::OwampData201001",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201002>

=cut

__PACKAGE__->has_many(
  "owamp_data_201002s",
  "Ecenter::DB::Result::OwampData201002",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201003>

=cut

__PACKAGE__->has_many(
  "owamp_data_201003s",
  "Ecenter::DB::Result::OwampData201003",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201004>

=cut

__PACKAGE__->has_many(
  "owamp_data_201004s",
  "Ecenter::DB::Result::OwampData201004",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201005>

=cut

__PACKAGE__->has_many(
  "owamp_data_201005s",
  "Ecenter::DB::Result::OwampData201005",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201006>

=cut

__PACKAGE__->has_many(
  "owamp_data_201006s",
  "Ecenter::DB::Result::OwampData201006",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201007>

=cut

__PACKAGE__->has_many(
  "owamp_data_201007s",
  "Ecenter::DB::Result::OwampData201007",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201008>

=cut

__PACKAGE__->has_many(
  "owamp_data_201008s",
  "Ecenter::DB::Result::OwampData201008",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201009>

=cut

__PACKAGE__->has_many(
  "owamp_data_201009s",
  "Ecenter::DB::Result::OwampData201009",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201010>

=cut

__PACKAGE__->has_many(
  "owamp_data_201010s",
  "Ecenter::DB::Result::OwampData201010",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 owamp_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201012>

=cut

__PACKAGE__->has_many(
  "owamp_data_201012s",
  "Ecenter::DB::Result::OwampData201012",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201101>

=cut

__PACKAGE__->has_many(
  "owamp_data_201101s",
  "Ecenter::DB::Result::OwampData201101",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201102>

=cut

__PACKAGE__->has_many(
  "owamp_data_201102s",
  "Ecenter::DB::Result::OwampData201102",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201103>

=cut

__PACKAGE__->has_many(
  "owamp_data_201103s",
  "Ecenter::DB::Result::OwampData201103",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201104>

=cut

__PACKAGE__->has_many(
  "owamp_data_201104s",
  "Ecenter::DB::Result::OwampData201104",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201105>

=cut

__PACKAGE__->has_many(
  "owamp_data_201105s",
  "Ecenter::DB::Result::OwampData201105",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201106>

=cut

__PACKAGE__->has_many(
  "owamp_data_201106s",
  "Ecenter::DB::Result::OwampData201106",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201107>

=cut

__PACKAGE__->has_many(
  "owamp_data_201107s",
  "Ecenter::DB::Result::OwampData201107",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201108>

=cut

__PACKAGE__->has_many(
  "owamp_data_201108s",
  "Ecenter::DB::Result::OwampData201108",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201109>

=cut

__PACKAGE__->has_many(
  "owamp_data_201109s",
  "Ecenter::DB::Result::OwampData201109",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201110>

=cut

__PACKAGE__->has_many(
  "owamp_data_201110s",
  "Ecenter::DB::Result::OwampData201110",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201111>

=cut

__PACKAGE__->has_many(
  "owamp_data_201111s",
  "Ecenter::DB::Result::OwampData201111",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201112>

=cut

__PACKAGE__->has_many(
  "owamp_data_201112s",
  "Ecenter::DB::Result::OwampData201112",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201201>

=cut

__PACKAGE__->has_many(
  "owamp_data_201201s",
  "Ecenter::DB::Result::OwampData201201",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201202>

=cut

__PACKAGE__->has_many(
  "owamp_data_201202s",
  "Ecenter::DB::Result::OwampData201202",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201203>

=cut

__PACKAGE__->has_many(
  "owamp_data_201203s",
  "Ecenter::DB::Result::OwampData201203",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201204>

=cut

__PACKAGE__->has_many(
  "owamp_data_201204s",
  "Ecenter::DB::Result::OwampData201204",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201205>

=cut

__PACKAGE__->has_many(
  "owamp_data_201205s",
  "Ecenter::DB::Result::OwampData201205",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201206>

=cut

__PACKAGE__->has_many(
  "owamp_data_201206s",
  "Ecenter::DB::Result::OwampData201206",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201207>

=cut

__PACKAGE__->has_many(
  "owamp_data_201207s",
  "Ecenter::DB::Result::OwampData201207",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201208>

=cut

__PACKAGE__->has_many(
  "owamp_data_201208s",
  "Ecenter::DB::Result::OwampData201208",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201209>

=cut

__PACKAGE__->has_many(
  "owamp_data_201209s",
  "Ecenter::DB::Result::OwampData201209",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201210>

=cut

__PACKAGE__->has_many(
  "owamp_data_201210s",
  "Ecenter::DB::Result::OwampData201210",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201211>

=cut

__PACKAGE__->has_many(
  "owamp_data_201211s",
  "Ecenter::DB::Result::OwampData201211",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201212>

=cut

__PACKAGE__->has_many(
  "owamp_data_201212s",
  "Ecenter::DB::Result::OwampData201212",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201301>

=cut

__PACKAGE__->has_many(
  "owamp_data_201301s",
  "Ecenter::DB::Result::OwampData201301",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201302>

=cut

__PACKAGE__->has_many(
  "owamp_data_201302s",
  "Ecenter::DB::Result::OwampData201302",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201303>

=cut

__PACKAGE__->has_many(
  "owamp_data_201303s",
  "Ecenter::DB::Result::OwampData201303",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201304>

=cut

__PACKAGE__->has_many(
  "owamp_data_201304s",
  "Ecenter::DB::Result::OwampData201304",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201305>

=cut

__PACKAGE__->has_many(
  "owamp_data_201305s",
  "Ecenter::DB::Result::OwampData201305",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201306>

=cut

__PACKAGE__->has_many(
  "owamp_data_201306s",
  "Ecenter::DB::Result::OwampData201306",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201307>

=cut

__PACKAGE__->has_many(
  "owamp_data_201307s",
  "Ecenter::DB::Result::OwampData201307",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201308>

=cut

__PACKAGE__->has_many(
  "owamp_data_201308s",
  "Ecenter::DB::Result::OwampData201308",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201309>

=cut

__PACKAGE__->has_many(
  "owamp_data_201309s",
  "Ecenter::DB::Result::OwampData201309",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201310>

=cut

__PACKAGE__->has_many(
  "owamp_data_201310s",
  "Ecenter::DB::Result::OwampData201310",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201311>

=cut

__PACKAGE__->has_many(
  "owamp_data_201311s",
  "Ecenter::DB::Result::OwampData201311",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201312>

=cut

__PACKAGE__->has_many(
  "owamp_data_201312s",
  "Ecenter::DB::Result::OwampData201312",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201401>

=cut

__PACKAGE__->has_many(
  "owamp_data_201401s",
  "Ecenter::DB::Result::OwampData201401",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201402>

=cut

__PACKAGE__->has_many(
  "owamp_data_201402s",
  "Ecenter::DB::Result::OwampData201402",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201403>

=cut

__PACKAGE__->has_many(
  "owamp_data_201403s",
  "Ecenter::DB::Result::OwampData201403",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201404>

=cut

__PACKAGE__->has_many(
  "owamp_data_201404s",
  "Ecenter::DB::Result::OwampData201404",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201405>

=cut

__PACKAGE__->has_many(
  "owamp_data_201405s",
  "Ecenter::DB::Result::OwampData201405",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201406>

=cut

__PACKAGE__->has_many(
  "owamp_data_201406s",
  "Ecenter::DB::Result::OwampData201406",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201407>

=cut

__PACKAGE__->has_many(
  "owamp_data_201407s",
  "Ecenter::DB::Result::OwampData201407",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201408>

=cut

__PACKAGE__->has_many(
  "owamp_data_201408s",
  "Ecenter::DB::Result::OwampData201408",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201409>

=cut

__PACKAGE__->has_many(
  "owamp_data_201409s",
  "Ecenter::DB::Result::OwampData201409",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201410>

=cut

__PACKAGE__->has_many(
  "owamp_data_201410s",
  "Ecenter::DB::Result::OwampData201410",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201411>

=cut

__PACKAGE__->has_many(
  "owamp_data_201411s",
  "Ecenter::DB::Result::OwampData201411",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201412>

=cut

__PACKAGE__->has_many(
  "owamp_data_201412s",
  "Ecenter::DB::Result::OwampData201412",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201501>

=cut

__PACKAGE__->has_many(
  "owamp_data_201501s",
  "Ecenter::DB::Result::OwampData201501",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201502>

=cut

__PACKAGE__->has_many(
  "owamp_data_201502s",
  "Ecenter::DB::Result::OwampData201502",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201503>

=cut

__PACKAGE__->has_many(
  "owamp_data_201503s",
  "Ecenter::DB::Result::OwampData201503",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201504>

=cut

__PACKAGE__->has_many(
  "owamp_data_201504s",
  "Ecenter::DB::Result::OwampData201504",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201505>

=cut

__PACKAGE__->has_many(
  "owamp_data_201505s",
  "Ecenter::DB::Result::OwampData201505",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201506>

=cut

__PACKAGE__->has_many(
  "owamp_data_201506s",
  "Ecenter::DB::Result::OwampData201506",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201507>

=cut

__PACKAGE__->has_many(
  "owamp_data_201507s",
  "Ecenter::DB::Result::OwampData201507",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201508>

=cut

__PACKAGE__->has_many(
  "owamp_data_201508s",
  "Ecenter::DB::Result::OwampData201508",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201509>

=cut

__PACKAGE__->has_many(
  "owamp_data_201509s",
  "Ecenter::DB::Result::OwampData201509",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201510>

=cut

__PACKAGE__->has_many(
  "owamp_data_201510s",
  "Ecenter::DB::Result::OwampData201510",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201511>

=cut

__PACKAGE__->has_many(
  "owamp_data_201511s",
  "Ecenter::DB::Result::OwampData201511",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 owamp_data_201512s

Type: has_many

Related object: L<Ecenter::DB::Result::OwampData201512>

=cut

__PACKAGE__->has_many(
  "owamp_data_201512s",
  "Ecenter::DB::Result::OwampData201512",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData200912>

=cut

__PACKAGE__->has_many(
  "pinger_data_200912s",
  "Ecenter::DB::Result::PingerData200912",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201001>

=cut

__PACKAGE__->has_many(
  "pinger_data_201001s",
  "Ecenter::DB::Result::PingerData201001",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201002>

=cut

__PACKAGE__->has_many(
  "pinger_data_201002s",
  "Ecenter::DB::Result::PingerData201002",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201003>

=cut

__PACKAGE__->has_many(
  "pinger_data_201003s",
  "Ecenter::DB::Result::PingerData201003",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201004>

=cut

__PACKAGE__->has_many(
  "pinger_data_201004s",
  "Ecenter::DB::Result::PingerData201004",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201005>

=cut

__PACKAGE__->has_many(
  "pinger_data_201005s",
  "Ecenter::DB::Result::PingerData201005",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201006>

=cut

__PACKAGE__->has_many(
  "pinger_data_201006s",
  "Ecenter::DB::Result::PingerData201006",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201007>

=cut

__PACKAGE__->has_many(
  "pinger_data_201007s",
  "Ecenter::DB::Result::PingerData201007",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201008>

=cut

__PACKAGE__->has_many(
  "pinger_data_201008s",
  "Ecenter::DB::Result::PingerData201008",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201009>

=cut

__PACKAGE__->has_many(
  "pinger_data_201009s",
  "Ecenter::DB::Result::PingerData201009",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201010>

=cut

__PACKAGE__->has_many(
  "pinger_data_201010s",
  "Ecenter::DB::Result::PingerData201010",
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

=head2 pinger_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201012>

=cut

__PACKAGE__->has_many(
  "pinger_data_201012s",
  "Ecenter::DB::Result::PingerData201012",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201101>

=cut

__PACKAGE__->has_many(
  "pinger_data_201101s",
  "Ecenter::DB::Result::PingerData201101",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201102>

=cut

__PACKAGE__->has_many(
  "pinger_data_201102s",
  "Ecenter::DB::Result::PingerData201102",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201103>

=cut

__PACKAGE__->has_many(
  "pinger_data_201103s",
  "Ecenter::DB::Result::PingerData201103",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201104>

=cut

__PACKAGE__->has_many(
  "pinger_data_201104s",
  "Ecenter::DB::Result::PingerData201104",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201105>

=cut

__PACKAGE__->has_many(
  "pinger_data_201105s",
  "Ecenter::DB::Result::PingerData201105",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201106>

=cut

__PACKAGE__->has_many(
  "pinger_data_201106s",
  "Ecenter::DB::Result::PingerData201106",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201107>

=cut

__PACKAGE__->has_many(
  "pinger_data_201107s",
  "Ecenter::DB::Result::PingerData201107",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201108>

=cut

__PACKAGE__->has_many(
  "pinger_data_201108s",
  "Ecenter::DB::Result::PingerData201108",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201109>

=cut

__PACKAGE__->has_many(
  "pinger_data_201109s",
  "Ecenter::DB::Result::PingerData201109",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201110>

=cut

__PACKAGE__->has_many(
  "pinger_data_201110s",
  "Ecenter::DB::Result::PingerData201110",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201111>

=cut

__PACKAGE__->has_many(
  "pinger_data_201111s",
  "Ecenter::DB::Result::PingerData201111",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201112>

=cut

__PACKAGE__->has_many(
  "pinger_data_201112s",
  "Ecenter::DB::Result::PingerData201112",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201201>

=cut

__PACKAGE__->has_many(
  "pinger_data_201201s",
  "Ecenter::DB::Result::PingerData201201",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201202>

=cut

__PACKAGE__->has_many(
  "pinger_data_201202s",
  "Ecenter::DB::Result::PingerData201202",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201203>

=cut

__PACKAGE__->has_many(
  "pinger_data_201203s",
  "Ecenter::DB::Result::PingerData201203",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201204>

=cut

__PACKAGE__->has_many(
  "pinger_data_201204s",
  "Ecenter::DB::Result::PingerData201204",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201205>

=cut

__PACKAGE__->has_many(
  "pinger_data_201205s",
  "Ecenter::DB::Result::PingerData201205",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201206>

=cut

__PACKAGE__->has_many(
  "pinger_data_201206s",
  "Ecenter::DB::Result::PingerData201206",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201207>

=cut

__PACKAGE__->has_many(
  "pinger_data_201207s",
  "Ecenter::DB::Result::PingerData201207",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201208>

=cut

__PACKAGE__->has_many(
  "pinger_data_201208s",
  "Ecenter::DB::Result::PingerData201208",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201209>

=cut

__PACKAGE__->has_many(
  "pinger_data_201209s",
  "Ecenter::DB::Result::PingerData201209",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201210>

=cut

__PACKAGE__->has_many(
  "pinger_data_201210s",
  "Ecenter::DB::Result::PingerData201210",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201211>

=cut

__PACKAGE__->has_many(
  "pinger_data_201211s",
  "Ecenter::DB::Result::PingerData201211",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201212>

=cut

__PACKAGE__->has_many(
  "pinger_data_201212s",
  "Ecenter::DB::Result::PingerData201212",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201301>

=cut

__PACKAGE__->has_many(
  "pinger_data_201301s",
  "Ecenter::DB::Result::PingerData201301",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201302>

=cut

__PACKAGE__->has_many(
  "pinger_data_201302s",
  "Ecenter::DB::Result::PingerData201302",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201303>

=cut

__PACKAGE__->has_many(
  "pinger_data_201303s",
  "Ecenter::DB::Result::PingerData201303",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201304>

=cut

__PACKAGE__->has_many(
  "pinger_data_201304s",
  "Ecenter::DB::Result::PingerData201304",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201305>

=cut

__PACKAGE__->has_many(
  "pinger_data_201305s",
  "Ecenter::DB::Result::PingerData201305",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201306>

=cut

__PACKAGE__->has_many(
  "pinger_data_201306s",
  "Ecenter::DB::Result::PingerData201306",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201307>

=cut

__PACKAGE__->has_many(
  "pinger_data_201307s",
  "Ecenter::DB::Result::PingerData201307",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201308>

=cut

__PACKAGE__->has_many(
  "pinger_data_201308s",
  "Ecenter::DB::Result::PingerData201308",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201309>

=cut

__PACKAGE__->has_many(
  "pinger_data_201309s",
  "Ecenter::DB::Result::PingerData201309",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201310>

=cut

__PACKAGE__->has_many(
  "pinger_data_201310s",
  "Ecenter::DB::Result::PingerData201310",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201311>

=cut

__PACKAGE__->has_many(
  "pinger_data_201311s",
  "Ecenter::DB::Result::PingerData201311",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201312>

=cut

__PACKAGE__->has_many(
  "pinger_data_201312s",
  "Ecenter::DB::Result::PingerData201312",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201401>

=cut

__PACKAGE__->has_many(
  "pinger_data_201401s",
  "Ecenter::DB::Result::PingerData201401",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201402>

=cut

__PACKAGE__->has_many(
  "pinger_data_201402s",
  "Ecenter::DB::Result::PingerData201402",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201403>

=cut

__PACKAGE__->has_many(
  "pinger_data_201403s",
  "Ecenter::DB::Result::PingerData201403",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201404>

=cut

__PACKAGE__->has_many(
  "pinger_data_201404s",
  "Ecenter::DB::Result::PingerData201404",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201405>

=cut

__PACKAGE__->has_many(
  "pinger_data_201405s",
  "Ecenter::DB::Result::PingerData201405",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201406>

=cut

__PACKAGE__->has_many(
  "pinger_data_201406s",
  "Ecenter::DB::Result::PingerData201406",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201407>

=cut

__PACKAGE__->has_many(
  "pinger_data_201407s",
  "Ecenter::DB::Result::PingerData201407",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201408>

=cut

__PACKAGE__->has_many(
  "pinger_data_201408s",
  "Ecenter::DB::Result::PingerData201408",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201409>

=cut

__PACKAGE__->has_many(
  "pinger_data_201409s",
  "Ecenter::DB::Result::PingerData201409",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201410>

=cut

__PACKAGE__->has_many(
  "pinger_data_201410s",
  "Ecenter::DB::Result::PingerData201410",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201411>

=cut

__PACKAGE__->has_many(
  "pinger_data_201411s",
  "Ecenter::DB::Result::PingerData201411",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201412>

=cut

__PACKAGE__->has_many(
  "pinger_data_201412s",
  "Ecenter::DB::Result::PingerData201412",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201501>

=cut

__PACKAGE__->has_many(
  "pinger_data_201501s",
  "Ecenter::DB::Result::PingerData201501",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201502>

=cut

__PACKAGE__->has_many(
  "pinger_data_201502s",
  "Ecenter::DB::Result::PingerData201502",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201503>

=cut

__PACKAGE__->has_many(
  "pinger_data_201503s",
  "Ecenter::DB::Result::PingerData201503",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201504>

=cut

__PACKAGE__->has_many(
  "pinger_data_201504s",
  "Ecenter::DB::Result::PingerData201504",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201505>

=cut

__PACKAGE__->has_many(
  "pinger_data_201505s",
  "Ecenter::DB::Result::PingerData201505",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201506>

=cut

__PACKAGE__->has_many(
  "pinger_data_201506s",
  "Ecenter::DB::Result::PingerData201506",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201507>

=cut

__PACKAGE__->has_many(
  "pinger_data_201507s",
  "Ecenter::DB::Result::PingerData201507",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201508>

=cut

__PACKAGE__->has_many(
  "pinger_data_201508s",
  "Ecenter::DB::Result::PingerData201508",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201509>

=cut

__PACKAGE__->has_many(
  "pinger_data_201509s",
  "Ecenter::DB::Result::PingerData201509",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201510>

=cut

__PACKAGE__->has_many(
  "pinger_data_201510s",
  "Ecenter::DB::Result::PingerData201510",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201511>

=cut

__PACKAGE__->has_many(
  "pinger_data_201511s",
  "Ecenter::DB::Result::PingerData201511",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 pinger_data_201512s

Type: has_many

Related object: L<Ecenter::DB::Result::PingerData201512>

=cut

__PACKAGE__->has_many(
  "pinger_data_201512s",
  "Ecenter::DB::Result::PingerData201512",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData200912>

=cut

__PACKAGE__->has_many(
  "snmp_data_200912s",
  "Ecenter::DB::Result::SnmpData200912",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201001>

=cut

__PACKAGE__->has_many(
  "snmp_data_201001s",
  "Ecenter::DB::Result::SnmpData201001",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201002>

=cut

__PACKAGE__->has_many(
  "snmp_data_201002s",
  "Ecenter::DB::Result::SnmpData201002",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201003>

=cut

__PACKAGE__->has_many(
  "snmp_data_201003s",
  "Ecenter::DB::Result::SnmpData201003",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201004>

=cut

__PACKAGE__->has_many(
  "snmp_data_201004s",
  "Ecenter::DB::Result::SnmpData201004",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201005>

=cut

__PACKAGE__->has_many(
  "snmp_data_201005s",
  "Ecenter::DB::Result::SnmpData201005",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201006>

=cut

__PACKAGE__->has_many(
  "snmp_data_201006s",
  "Ecenter::DB::Result::SnmpData201006",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201007>

=cut

__PACKAGE__->has_many(
  "snmp_data_201007s",
  "Ecenter::DB::Result::SnmpData201007",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201008>

=cut

__PACKAGE__->has_many(
  "snmp_data_201008s",
  "Ecenter::DB::Result::SnmpData201008",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201009>

=cut

__PACKAGE__->has_many(
  "snmp_data_201009s",
  "Ecenter::DB::Result::SnmpData201009",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201010>

=cut

__PACKAGE__->has_many(
  "snmp_data_201010s",
  "Ecenter::DB::Result::SnmpData201010",
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

=head2 snmp_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201012>

=cut

__PACKAGE__->has_many(
  "snmp_data_201012s",
  "Ecenter::DB::Result::SnmpData201012",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201101>

=cut

__PACKAGE__->has_many(
  "snmp_data_201101s",
  "Ecenter::DB::Result::SnmpData201101",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201102>

=cut

__PACKAGE__->has_many(
  "snmp_data_201102s",
  "Ecenter::DB::Result::SnmpData201102",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201103>

=cut

__PACKAGE__->has_many(
  "snmp_data_201103s",
  "Ecenter::DB::Result::SnmpData201103",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201104>

=cut

__PACKAGE__->has_many(
  "snmp_data_201104s",
  "Ecenter::DB::Result::SnmpData201104",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201105>

=cut

__PACKAGE__->has_many(
  "snmp_data_201105s",
  "Ecenter::DB::Result::SnmpData201105",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201106>

=cut

__PACKAGE__->has_many(
  "snmp_data_201106s",
  "Ecenter::DB::Result::SnmpData201106",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201107>

=cut

__PACKAGE__->has_many(
  "snmp_data_201107s",
  "Ecenter::DB::Result::SnmpData201107",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201108>

=cut

__PACKAGE__->has_many(
  "snmp_data_201108s",
  "Ecenter::DB::Result::SnmpData201108",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201109>

=cut

__PACKAGE__->has_many(
  "snmp_data_201109s",
  "Ecenter::DB::Result::SnmpData201109",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201110>

=cut

__PACKAGE__->has_many(
  "snmp_data_201110s",
  "Ecenter::DB::Result::SnmpData201110",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201111>

=cut

__PACKAGE__->has_many(
  "snmp_data_201111s",
  "Ecenter::DB::Result::SnmpData201111",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201112>

=cut

__PACKAGE__->has_many(
  "snmp_data_201112s",
  "Ecenter::DB::Result::SnmpData201112",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201201>

=cut

__PACKAGE__->has_many(
  "snmp_data_201201s",
  "Ecenter::DB::Result::SnmpData201201",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201202>

=cut

__PACKAGE__->has_many(
  "snmp_data_201202s",
  "Ecenter::DB::Result::SnmpData201202",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201203>

=cut

__PACKAGE__->has_many(
  "snmp_data_201203s",
  "Ecenter::DB::Result::SnmpData201203",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201204>

=cut

__PACKAGE__->has_many(
  "snmp_data_201204s",
  "Ecenter::DB::Result::SnmpData201204",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201205>

=cut

__PACKAGE__->has_many(
  "snmp_data_201205s",
  "Ecenter::DB::Result::SnmpData201205",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201206>

=cut

__PACKAGE__->has_many(
  "snmp_data_201206s",
  "Ecenter::DB::Result::SnmpData201206",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201207>

=cut

__PACKAGE__->has_many(
  "snmp_data_201207s",
  "Ecenter::DB::Result::SnmpData201207",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201208>

=cut

__PACKAGE__->has_many(
  "snmp_data_201208s",
  "Ecenter::DB::Result::SnmpData201208",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201209>

=cut

__PACKAGE__->has_many(
  "snmp_data_201209s",
  "Ecenter::DB::Result::SnmpData201209",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201210>

=cut

__PACKAGE__->has_many(
  "snmp_data_201210s",
  "Ecenter::DB::Result::SnmpData201210",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201211>

=cut

__PACKAGE__->has_many(
  "snmp_data_201211s",
  "Ecenter::DB::Result::SnmpData201211",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201212>

=cut

__PACKAGE__->has_many(
  "snmp_data_201212s",
  "Ecenter::DB::Result::SnmpData201212",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201301>

=cut

__PACKAGE__->has_many(
  "snmp_data_201301s",
  "Ecenter::DB::Result::SnmpData201301",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201302>

=cut

__PACKAGE__->has_many(
  "snmp_data_201302s",
  "Ecenter::DB::Result::SnmpData201302",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201303>

=cut

__PACKAGE__->has_many(
  "snmp_data_201303s",
  "Ecenter::DB::Result::SnmpData201303",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201304>

=cut

__PACKAGE__->has_many(
  "snmp_data_201304s",
  "Ecenter::DB::Result::SnmpData201304",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201305>

=cut

__PACKAGE__->has_many(
  "snmp_data_201305s",
  "Ecenter::DB::Result::SnmpData201305",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201306>

=cut

__PACKAGE__->has_many(
  "snmp_data_201306s",
  "Ecenter::DB::Result::SnmpData201306",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201307>

=cut

__PACKAGE__->has_many(
  "snmp_data_201307s",
  "Ecenter::DB::Result::SnmpData201307",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201308>

=cut

__PACKAGE__->has_many(
  "snmp_data_201308s",
  "Ecenter::DB::Result::SnmpData201308",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201309>

=cut

__PACKAGE__->has_many(
  "snmp_data_201309s",
  "Ecenter::DB::Result::SnmpData201309",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201310>

=cut

__PACKAGE__->has_many(
  "snmp_data_201310s",
  "Ecenter::DB::Result::SnmpData201310",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201311>

=cut

__PACKAGE__->has_many(
  "snmp_data_201311s",
  "Ecenter::DB::Result::SnmpData201311",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201312>

=cut

__PACKAGE__->has_many(
  "snmp_data_201312s",
  "Ecenter::DB::Result::SnmpData201312",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201401>

=cut

__PACKAGE__->has_many(
  "snmp_data_201401s",
  "Ecenter::DB::Result::SnmpData201401",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201402>

=cut

__PACKAGE__->has_many(
  "snmp_data_201402s",
  "Ecenter::DB::Result::SnmpData201402",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201403>

=cut

__PACKAGE__->has_many(
  "snmp_data_201403s",
  "Ecenter::DB::Result::SnmpData201403",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201404>

=cut

__PACKAGE__->has_many(
  "snmp_data_201404s",
  "Ecenter::DB::Result::SnmpData201404",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201405>

=cut

__PACKAGE__->has_many(
  "snmp_data_201405s",
  "Ecenter::DB::Result::SnmpData201405",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201406>

=cut

__PACKAGE__->has_many(
  "snmp_data_201406s",
  "Ecenter::DB::Result::SnmpData201406",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201407>

=cut

__PACKAGE__->has_many(
  "snmp_data_201407s",
  "Ecenter::DB::Result::SnmpData201407",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201408>

=cut

__PACKAGE__->has_many(
  "snmp_data_201408s",
  "Ecenter::DB::Result::SnmpData201408",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201409>

=cut

__PACKAGE__->has_many(
  "snmp_data_201409s",
  "Ecenter::DB::Result::SnmpData201409",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201410>

=cut

__PACKAGE__->has_many(
  "snmp_data_201410s",
  "Ecenter::DB::Result::SnmpData201410",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201411>

=cut

__PACKAGE__->has_many(
  "snmp_data_201411s",
  "Ecenter::DB::Result::SnmpData201411",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201412>

=cut

__PACKAGE__->has_many(
  "snmp_data_201412s",
  "Ecenter::DB::Result::SnmpData201412",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201501>

=cut

__PACKAGE__->has_many(
  "snmp_data_201501s",
  "Ecenter::DB::Result::SnmpData201501",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201502>

=cut

__PACKAGE__->has_many(
  "snmp_data_201502s",
  "Ecenter::DB::Result::SnmpData201502",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201503>

=cut

__PACKAGE__->has_many(
  "snmp_data_201503s",
  "Ecenter::DB::Result::SnmpData201503",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201504>

=cut

__PACKAGE__->has_many(
  "snmp_data_201504s",
  "Ecenter::DB::Result::SnmpData201504",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201505>

=cut

__PACKAGE__->has_many(
  "snmp_data_201505s",
  "Ecenter::DB::Result::SnmpData201505",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201506>

=cut

__PACKAGE__->has_many(
  "snmp_data_201506s",
  "Ecenter::DB::Result::SnmpData201506",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201507>

=cut

__PACKAGE__->has_many(
  "snmp_data_201507s",
  "Ecenter::DB::Result::SnmpData201507",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201508>

=cut

__PACKAGE__->has_many(
  "snmp_data_201508s",
  "Ecenter::DB::Result::SnmpData201508",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201509>

=cut

__PACKAGE__->has_many(
  "snmp_data_201509s",
  "Ecenter::DB::Result::SnmpData201509",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201510>

=cut

__PACKAGE__->has_many(
  "snmp_data_201510s",
  "Ecenter::DB::Result::SnmpData201510",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201511>

=cut

__PACKAGE__->has_many(
  "snmp_data_201511s",
  "Ecenter::DB::Result::SnmpData201511",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 snmp_data_201512s

Type: has_many

Related object: L<Ecenter::DB::Result::SnmpData201512>

=cut

__PACKAGE__->has_many(
  "snmp_data_201512s",
  "Ecenter::DB::Result::SnmpData201512",
  { "foreign.metaid" => "self.metaid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-18 15:43:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5D7EWpd1UIJ/EXefnlRWBA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
