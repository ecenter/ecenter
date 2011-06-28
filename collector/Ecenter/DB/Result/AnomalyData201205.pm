package Ecenter::DB::Result::AnomalyData201205;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::AnomalyData201205

=cut

__PACKAGE__->table("anomaly_data_201205");

=head1 ACCESSORS

=head2 anomaly_data

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 anomaly

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 anomaly_status

  data_type: 'enum'
  default_value: 'critical'
  extra: {list => ["critical","warning"]}
  is_nullable: 0

=head2 anomaly_type

  data_type: 'varchar'
  default_value: 'plateau'
  is_nullable: 0
  size: 16

=head2 timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 value

  data_type: 'float'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "anomaly_data",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "anomaly",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "anomaly_status",
  {
    data_type => "enum",
    default_value => "critical",
    extra => { list => ["critical", "warning"] },
    is_nullable => 0,
  },
  "anomaly_type",
  {
    data_type => "varchar",
    default_value => "plateau",
    is_nullable => 0,
    size => 16,
  },
  "timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "value",
  { data_type => "float", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("anomaly_data");
__PACKAGE__->add_unique_constraint("anomaly_time", ["anomaly", "timestamp"]);

=head1 RELATIONS

=head2 anomaly

Type: belongs_to

Related object: L<Ecenter::DB::Result::Anomaly>

=cut

__PACKAGE__->belongs_to(
  "anomaly",
  "Ecenter::DB::Result::Anomaly",
  { anomaly => "anomaly" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-06-24 14:51:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pHnBjogbI+D4Pa96QpdzWQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
