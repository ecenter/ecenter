package Ecenter::Schema::Result::Keyword;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('keyword');
__PACKAGE__->add_columns(qw/keyword  pattern created/);
__PACKAGE__->set_primary_key('keyword');
__PACKAGE__->has_many(keywords_services =>  'Ecenter::Schema::Result::Keywords_Service');

1;
