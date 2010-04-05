package Ecenter::Schema::Result::Keywords_Service;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('keywords_service');
__PACKAGE__->add_columns(qw/ref_id keyword service/);
__PACKAGE__->add_unique_constraint(  keywords_service=> [ qw/keyword service/ ]);
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->belongs_to(keyword => 'Ecenter::Schema::Result::Keyword');
__PACKAGE__->set_primary_key('ref_id'); 

1;
