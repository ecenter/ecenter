package Ecenter::DB::Result::PingerData201002;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::PingerData201002

=cut

__PACKAGE__->table("pinger_data_201002");

=head1 ACCESSORS

=head2 pinger_data

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 minrtt

  data_type: 'float'
  is_nullable: 1

=head2 meanrtt

  data_type: 'float'
  is_nullable: 1

=head2 medianrtt

  data_type: 'float'
  is_nullable: 1

=head2 maxrtt

  data_type: 'float'
  is_nullable: 1

=head2 timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 minipd

  data_type: 'float'
  is_nullable: 1

=head2 meanipd

  data_type: 'float'
  is_nullable: 1

=head2 maxipd

  data_type: 'float'
  is_nullable: 1

=head2 duplicates

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 outoforder

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 clp

  data_type: 'float'
  is_nullable: 1

=head2 iqripd

  data_type: 'float'
  is_nullable: 1

=head2 losspercent

  data_type: 'float'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "pinger_data",
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
  "minrtt",
  { data_type => "float", is_nullable => 1 },
  "meanrtt",
  { data_type => "float", is_nullable => 1 },
  "medianrtt",
  { data_type => "float", is_nullable => 1 },
  "maxrtt",
  { data_type => "float", is_nullable => 1 },
  "timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "minipd",
  { data_type => "float", is_nullable => 1 },
  "meanipd",
  { data_type => "float", is_nullable => 1 },
  "maxipd",
  { data_type => "float", is_nullable => 1 },
  "duplicates",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "outoforder",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "clp",
  { data_type => "float", is_nullable => 1 },
  "iqripd",
  { data_type => "float", is_nullable => 1 },
  "losspercent",
  { data_type => "float", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("pinger_data");
__PACKAGE__->add_unique_constraint("meta_time", ["metaid", "timestamp"]);

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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-03-23 13:53:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HrQeew6peYMJo9TXK8YQ/w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
