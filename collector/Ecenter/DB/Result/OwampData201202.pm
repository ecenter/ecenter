package Ecenter::DB::Result::OwampData201202;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::OwampData201202

=cut

__PACKAGE__->table("owamp_data_201202");

=head1 ACCESSORS

=head2 owamp_data

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 metaid

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 timestamp

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 min_delay

  data_type: 'float'
  is_nullable: 1

=head2 max_delay

  data_type: 'float'
  is_nullable: 1

=head2 sent

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 loss

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 duplicates

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "owamp_data",
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
  "timestamp",
  { data_type => "bigint", extra => { unsigned => 1 }, is_nullable => 0 },
  "min_delay",
  { data_type => "float", is_nullable => 1 },
  "max_delay",
  { data_type => "float", is_nullable => 1 },
  "sent",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "loss",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "duplicates",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("owamp_data");
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-03-23 13:53:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Idz1Xqm9Zsu+5gr+Pzz9zw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
