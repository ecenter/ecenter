package Ecenter::DB::Result::KeywordsService;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::KeywordsService

=cut

__PACKAGE__->table("keywords_service");

=head1 ACCESSORS

=head2 ref_id

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 keyword

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 255

=head2 service

  data_type: 'bigint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ref_id",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "keyword",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 255 },
  "service",
  {
    data_type => "bigint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("ref_id");
__PACKAGE__->add_unique_constraint("key_service", ["keyword", "service"]);

=head1 RELATIONS

=head2 keyword

Type: belongs_to

Related object: L<Ecenter::DB::Result::Keyword>

=cut

__PACKAGE__->belongs_to(
  "keyword",
  "Ecenter::DB::Result::Keyword",
  { keyword => "keyword" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 service

Type: belongs_to

Related object: L<Ecenter::DB::Result::Service>

=cut

__PACKAGE__->belongs_to(
  "service",
  "Ecenter::DB::Result::Service",
  { service => "service" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LsDl9vLQUxRIv52uHJjwdg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
