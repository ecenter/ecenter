package Ecenter::DB::Result::Anomaly;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Anomaly

=cut

__PACKAGE__->table("anomaly");

=head1 ACCESSORS

=head2 anomaly

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 sensitivity

  data_type: 'float'
  is_nullable: 0

=head2 elevation1

  data_type: 'float'
  is_nullable: 0

=head2 elevation2

  data_type: 'float'
  is_nullable: 0

 

=head2 swc

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 algo

  data_type: 'enum'
  default_value: 'spd'
  extra: {list => ["apd","spd"]}
  is_nullable: 0

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
  "anomaly",
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
  "sensitivity",
  { data_type => "float", is_nullable => 0 },
  "elevation1",
  { data_type => "float", is_nullable => 0 },
  "elevation2",
  { data_type => "float", is_nullable => 0 },
  "resolution",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "swc",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "algo",
  {
    data_type => "enum",
    default_value => "spd",
    extra => { list => ["apd", "spd"] },
    is_nullable => 0,
  },
  "start_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "end_time",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("anomaly");
__PACKAGE__->add_unique_constraint(
  "metaid_algo_when",
  ["metaid", "algo", "start_time", "end_time"],
);

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

=head2 anomaly_data_201105s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201105>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201105s",
  "Ecenter::DB::Result::AnomalyData201105",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201106s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201106>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201106s",
  "Ecenter::DB::Result::AnomalyData201106",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201107s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201107>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201107s",
  "Ecenter::DB::Result::AnomalyData201107",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201108s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201108>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201108s",
  "Ecenter::DB::Result::AnomalyData201108",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201109s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201109>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201109s",
  "Ecenter::DB::Result::AnomalyData201109",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201110s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201110>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201110s",
  "Ecenter::DB::Result::AnomalyData201110",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201111s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201111>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201111s",
  "Ecenter::DB::Result::AnomalyData201111",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201112s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201112>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201112s",
  "Ecenter::DB::Result::AnomalyData201112",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201201s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201201>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201201s",
  "Ecenter::DB::Result::AnomalyData201201",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201202s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201202>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201202s",
  "Ecenter::DB::Result::AnomalyData201202",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201203s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201203>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201203s",
  "Ecenter::DB::Result::AnomalyData201203",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201204s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201204>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201204s",
  "Ecenter::DB::Result::AnomalyData201204",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201205s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201205>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201205s",
  "Ecenter::DB::Result::AnomalyData201205",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201206s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201206>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201206s",
  "Ecenter::DB::Result::AnomalyData201206",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201207s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201207>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201207s",
  "Ecenter::DB::Result::AnomalyData201207",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201208s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201208>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201208s",
  "Ecenter::DB::Result::AnomalyData201208",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201209s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201209>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201209s",
  "Ecenter::DB::Result::AnomalyData201209",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201210s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201210>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201210s",
  "Ecenter::DB::Result::AnomalyData201210",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201211s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201211>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201211s",
  "Ecenter::DB::Result::AnomalyData201211",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201212s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201212>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201212s",
  "Ecenter::DB::Result::AnomalyData201212",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201301s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201301>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201301s",
  "Ecenter::DB::Result::AnomalyData201301",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201302s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201302>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201302s",
  "Ecenter::DB::Result::AnomalyData201302",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201303s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201303>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201303s",
  "Ecenter::DB::Result::AnomalyData201303",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201304s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201304>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201304s",
  "Ecenter::DB::Result::AnomalyData201304",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201305s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201305>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201305s",
  "Ecenter::DB::Result::AnomalyData201305",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201306s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201306>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201306s",
  "Ecenter::DB::Result::AnomalyData201306",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201307s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201307>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201307s",
  "Ecenter::DB::Result::AnomalyData201307",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201308s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201308>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201308s",
  "Ecenter::DB::Result::AnomalyData201308",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201309s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201309>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201309s",
  "Ecenter::DB::Result::AnomalyData201309",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201310s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201310>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201310s",
  "Ecenter::DB::Result::AnomalyData201310",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201311s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201311>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201311s",
  "Ecenter::DB::Result::AnomalyData201311",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201312s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201312>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201312s",
  "Ecenter::DB::Result::AnomalyData201312",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201401s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201401>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201401s",
  "Ecenter::DB::Result::AnomalyData201401",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201402s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201402>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201402s",
  "Ecenter::DB::Result::AnomalyData201402",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201403s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201403>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201403s",
  "Ecenter::DB::Result::AnomalyData201403",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201404s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201404>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201404s",
  "Ecenter::DB::Result::AnomalyData201404",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201405s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201405>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201405s",
  "Ecenter::DB::Result::AnomalyData201405",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201406s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201406>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201406s",
  "Ecenter::DB::Result::AnomalyData201406",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201407s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201407>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201407s",
  "Ecenter::DB::Result::AnomalyData201407",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201408s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201408>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201408s",
  "Ecenter::DB::Result::AnomalyData201408",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201409s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201409>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201409s",
  "Ecenter::DB::Result::AnomalyData201409",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201410s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201410>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201410s",
  "Ecenter::DB::Result::AnomalyData201410",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201411s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201411>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201411s",
  "Ecenter::DB::Result::AnomalyData201411",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 anomaly_data_201412s

Type: has_many

Related object: L<Ecenter::DB::Result::AnomalyData201412>

=cut

__PACKAGE__->has_many(
  "anomaly_data_201412s",
  "Ecenter::DB::Result::AnomalyData201412",
  { "foreign.anomaly" => "self.anomaly" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-06-24 14:51:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Qroc4++eqYqYu/NkhgXMGg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
