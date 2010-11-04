package Ecenter::DB::Result::Keyword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Keyword

=cut

__PACKAGE__->table("keyword");

=head1 ACCESSORS

=head2 keyword

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 pattern

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "keyword",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "pattern",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("keyword");

=head1 RELATIONS

=head2 keywords_services

Type: has_many

Related object: L<Ecenter::DB::Result::KeywordsService>

=cut

__PACKAGE__->has_many(
  "keywords_services",
  "Ecenter::DB::Result::KeywordsService",
  { "foreign.keyword" => "self.keyword" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-11-04 14:44:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gnsU3bcxMPmEeFYd15zfgg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
