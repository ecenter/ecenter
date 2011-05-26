package Ecenter::DB::Result::Service;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Ecenter::DB::Result::Service

=cut

__PACKAGE__->table("service");

=head1 ACCESSORS

=head2 service

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 ip_addr

  data_type: 'varbinary'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 comments

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 is_alive

  data_type: 'tinyint'
  is_nullable: 1

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
  "service",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "ip_addr",
  { data_type => "varbinary", is_foreign_key => 1, is_nullable => 0, size => 16 },
  "comments",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "is_alive",
  { data_type => "tinyint", is_nullable => 1 },
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
__PACKAGE__->belongs_to(
  "node",
  "Ecenter::DB::Result::Node",
  { ip_addr => "ip_addr" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->set_primary_key("service");

=head1 RELATIONS

=head2 eventtypes

Type: has_many

Related object: L<Ecenter::DB::Result::Eventtype>

=cut

__PACKAGE__->has_many(
  "eventtypes",
  "Ecenter::DB::Result::Eventtype",
  { "foreign.service" => "self.service" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 keywords_services

Type: has_many

Related object: L<Ecenter::DB::Result::KeywordsService>

=cut

__PACKAGE__->has_many(
  "keywords_services",
  "Ecenter::DB::Result::KeywordsService",
  { "foreign.service" => "self.service" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_addr

Type: belongs_to

Related object: L<Ecenter::DB::Result::Node>

=cut

__PACKAGE__->belongs_to(
  "ip_addr",
  "Ecenter::DB::Result::Node",
  { ip_addr => "ip_addr" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-03-23 13:54:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4ZW2hjzttpiZWtaUVJDftQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
