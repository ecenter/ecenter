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

=head2 hop_data_200912s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData200912>

=cut

__PACKAGE__->has_many(
  "hop_data_200912s",
  "Ecenter::DB::Result::HopData200912",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "services",
  "Ecenter::DB::Result::Service",
  { "foreign.ip_addr" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "src_ips",
  "Ecenter::DB::Result::Metadata",
  { "foreign.src_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "dst_ips",
  "Ecenter::DB::Result::Metadata",
  { "foreign.dst_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201001s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201001>

=cut

__PACKAGE__->has_many(
  "hop_data_201001s",
  "Ecenter::DB::Result::HopData201001",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201002s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201002>

=cut

__PACKAGE__->has_many(
  "hop_data_201002s",
  "Ecenter::DB::Result::HopData201002",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201003s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201003>

=cut

__PACKAGE__->has_many(
  "hop_data_201003s",
  "Ecenter::DB::Result::HopData201003",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201004s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201004>

=cut

__PACKAGE__->has_many(
  "hop_data_201004s",
  "Ecenter::DB::Result::HopData201004",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201005s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201005>

=cut

__PACKAGE__->has_many(
  "hop_data_201005s",
  "Ecenter::DB::Result::HopData201005",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201006s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201006>

=cut

__PACKAGE__->has_many(
  "hop_data_201006s",
  "Ecenter::DB::Result::HopData201006",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201007s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201007>

=cut

__PACKAGE__->has_many(
  "hop_data_201007s",
  "Ecenter::DB::Result::HopData201007",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201008s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201008>

=cut

__PACKAGE__->has_many(
  "hop_data_201008s",
  "Ecenter::DB::Result::HopData201008",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201009s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201009>

=cut

__PACKAGE__->has_many(
  "hop_data_201009s",
  "Ecenter::DB::Result::HopData201009",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201010s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201010>

=cut

__PACKAGE__->has_many(
  "hop_data_201010s",
  "Ecenter::DB::Result::HopData201010",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 hop_data_201012s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201012>

=cut

__PACKAGE__->has_many(
  "hop_data_201012s",
  "Ecenter::DB::Result::HopData201012",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201101s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201101>

=cut

__PACKAGE__->has_many(
  "hop_data_201101s",
  "Ecenter::DB::Result::HopData201101",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201102s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201102>

=cut

__PACKAGE__->has_many(
  "hop_data_201102s",
  "Ecenter::DB::Result::HopData201102",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201103s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201103>

=cut

__PACKAGE__->has_many(
  "hop_data_201103s",
  "Ecenter::DB::Result::HopData201103",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201104s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201104>

=cut

__PACKAGE__->has_many(
  "hop_data_201104s",
  "Ecenter::DB::Result::HopData201104",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201105>

=cut

__PACKAGE__->has_many(
  "hop_data_201105s",
  "Ecenter::DB::Result::HopData201105",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201106>

=cut

__PACKAGE__->has_many(
  "hop_data_201106s",
  "Ecenter::DB::Result::HopData201106",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201107>

=cut

__PACKAGE__->has_many(
  "hop_data_201107s",
  "Ecenter::DB::Result::HopData201107",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201108>

=cut

__PACKAGE__->has_many(
  "hop_data_201108s",
  "Ecenter::DB::Result::HopData201108",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201109>

=cut

__PACKAGE__->has_many(
  "hop_data_201109s",
  "Ecenter::DB::Result::HopData201109",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201110>

=cut

__PACKAGE__->has_many(
  "hop_data_201110s",
  "Ecenter::DB::Result::HopData201110",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201111>

=cut

__PACKAGE__->has_many(
  "hop_data_201111s",
  "Ecenter::DB::Result::HopData201111",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201112>

=cut

__PACKAGE__->has_many(
  "hop_data_201112s",
  "Ecenter::DB::Result::HopData201112",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201201>

=cut

__PACKAGE__->has_many(
  "hop_data_201201s",
  "Ecenter::DB::Result::HopData201201",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201202>

=cut

__PACKAGE__->has_many(
  "hop_data_201202s",
  "Ecenter::DB::Result::HopData201202",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201203>

=cut

__PACKAGE__->has_many(
  "hop_data_201203s",
  "Ecenter::DB::Result::HopData201203",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201204>

=cut

__PACKAGE__->has_many(
  "hop_data_201204s",
  "Ecenter::DB::Result::HopData201204",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201205>

=cut

__PACKAGE__->has_many(
  "hop_data_201205s",
  "Ecenter::DB::Result::HopData201205",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201206>

=cut

__PACKAGE__->has_many(
  "hop_data_201206s",
  "Ecenter::DB::Result::HopData201206",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201207>

=cut

__PACKAGE__->has_many(
  "hop_data_201207s",
  "Ecenter::DB::Result::HopData201207",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201208>

=cut

__PACKAGE__->has_many(
  "hop_data_201208s",
  "Ecenter::DB::Result::HopData201208",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201209>

=cut

__PACKAGE__->has_many(
  "hop_data_201209s",
  "Ecenter::DB::Result::HopData201209",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201210>

=cut

__PACKAGE__->has_many(
  "hop_data_201210s",
  "Ecenter::DB::Result::HopData201210",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201211>

=cut

__PACKAGE__->has_many(
  "hop_data_201211s",
  "Ecenter::DB::Result::HopData201211",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201212>

=cut

__PACKAGE__->has_many(
  "hop_data_201212s",
  "Ecenter::DB::Result::HopData201212",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201301>

=cut

__PACKAGE__->has_many(
  "hop_data_201301s",
  "Ecenter::DB::Result::HopData201301",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201302>

=cut

__PACKAGE__->has_many(
  "hop_data_201302s",
  "Ecenter::DB::Result::HopData201302",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201303>

=cut

__PACKAGE__->has_many(
  "hop_data_201303s",
  "Ecenter::DB::Result::HopData201303",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201304>

=cut

__PACKAGE__->has_many(
  "hop_data_201304s",
  "Ecenter::DB::Result::HopData201304",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201305>

=cut

__PACKAGE__->has_many(
  "hop_data_201305s",
  "Ecenter::DB::Result::HopData201305",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201306>

=cut

__PACKAGE__->has_many(
  "hop_data_201306s",
  "Ecenter::DB::Result::HopData201306",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201307>

=cut

__PACKAGE__->has_many(
  "hop_data_201307s",
  "Ecenter::DB::Result::HopData201307",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201308>

=cut

__PACKAGE__->has_many(
  "hop_data_201308s",
  "Ecenter::DB::Result::HopData201308",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201309>

=cut

__PACKAGE__->has_many(
  "hop_data_201309s",
  "Ecenter::DB::Result::HopData201309",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201310>

=cut

__PACKAGE__->has_many(
  "hop_data_201310s",
  "Ecenter::DB::Result::HopData201310",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201311>

=cut

__PACKAGE__->has_many(
  "hop_data_201311s",
  "Ecenter::DB::Result::HopData201311",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201312>

=cut

__PACKAGE__->has_many(
  "hop_data_201312s",
  "Ecenter::DB::Result::HopData201312",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201401>

=cut

__PACKAGE__->has_many(
  "hop_data_201401s",
  "Ecenter::DB::Result::HopData201401",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201402>

=cut

__PACKAGE__->has_many(
  "hop_data_201402s",
  "Ecenter::DB::Result::HopData201402",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201403>

=cut

__PACKAGE__->has_many(
  "hop_data_201403s",
  "Ecenter::DB::Result::HopData201403",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201404>

=cut

__PACKAGE__->has_many(
  "hop_data_201404s",
  "Ecenter::DB::Result::HopData201404",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201405>

=cut

__PACKAGE__->has_many(
  "hop_data_201405s",
  "Ecenter::DB::Result::HopData201405",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201406>

=cut

__PACKAGE__->has_many(
  "hop_data_201406s",
  "Ecenter::DB::Result::HopData201406",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201407>

=cut

__PACKAGE__->has_many(
  "hop_data_201407s",
  "Ecenter::DB::Result::HopData201407",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201408>

=cut

__PACKAGE__->has_many(
  "hop_data_201408s",
  "Ecenter::DB::Result::HopData201408",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201409>

=cut

__PACKAGE__->has_many(
  "hop_data_201409s",
  "Ecenter::DB::Result::HopData201409",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201410>

=cut

__PACKAGE__->has_many(
  "hop_data_201410s",
  "Ecenter::DB::Result::HopData201410",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201411>

=cut

__PACKAGE__->has_many(
  "hop_data_201411s",
  "Ecenter::DB::Result::HopData201411",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201412>

=cut

__PACKAGE__->has_many(
  "hop_data_201412s",
  "Ecenter::DB::Result::HopData201412",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201501s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201501>

=cut

__PACKAGE__->has_many(
  "hop_data_201501s",
  "Ecenter::DB::Result::HopData201501",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201502s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201502>

=cut

__PACKAGE__->has_many(
  "hop_data_201502s",
  "Ecenter::DB::Result::HopData201502",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201503s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201503>

=cut

__PACKAGE__->has_many(
  "hop_data_201503s",
  "Ecenter::DB::Result::HopData201503",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201504s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201504>

=cut

__PACKAGE__->has_many(
  "hop_data_201504s",
  "Ecenter::DB::Result::HopData201504",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201505s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201505>

=cut

__PACKAGE__->has_many(
  "hop_data_201505s",
  "Ecenter::DB::Result::HopData201505",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201506s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201506>

=cut

__PACKAGE__->has_many(
  "hop_data_201506s",
  "Ecenter::DB::Result::HopData201506",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201507s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201507>

=cut

__PACKAGE__->has_many(
  "hop_data_201507s",
  "Ecenter::DB::Result::HopData201507",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201508s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201508>

=cut

__PACKAGE__->has_many(
  "hop_data_201508s",
  "Ecenter::DB::Result::HopData201508",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201509s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201509>

=cut

__PACKAGE__->has_many(
  "hop_data_201509s",
  "Ecenter::DB::Result::HopData201509",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201510s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201510>

=cut

__PACKAGE__->has_many(
  "hop_data_201510s",
  "Ecenter::DB::Result::HopData201510",
  { "foreign.hop_ip" => "self.ip_addr" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hop_data_201511s

Type: has_many

Related object: L<Ecenter::DB::Result::HopData201511>

=cut

__PACKAGE__->has_many(
  "hop_data_201511s",
  "Ecenter::DB::Result::HopData201511",
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-03-23 14:03:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OSkADf7ELyxemIfXTPOnPg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
