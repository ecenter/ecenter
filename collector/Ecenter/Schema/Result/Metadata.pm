package Ecenter::Schema::Result::Metadata;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('metadata');
__PACKAGE__->add_columns(qw/metadata metaid src dst service subject parameters/); 
__PACKAGE__->belongs_to(service => 'Ecenter::Schema::Result::Service');
__PACKAGE__->belongs_to( src => 'Ecenter::Schema::Result::Node' );
__PACKAGE__->belongs_to( dst => 'Ecenter::Schema::Result::Node' );
__PACKAGE__->has_many(datas => 'Ecenter::Schema::Result::Data');
__PACKAGE__->has_many(pinger_datas => 'Ecenter::Schema::Result::Pinger_data');
__PACKAGE__->has_many(bwctl_datas => 'Ecenter::Schema::Result::Bwctl_data');
__PACKAGE__->has_many(owamp_datas => 'Ecenter::Schema::Result::Owamp_data');


__PACKAGE__->set_primary_key('metadata');
__PACKAGE__->add_unique_constraint( metaid_service => [ qw/metaid service/ ]);


1;
