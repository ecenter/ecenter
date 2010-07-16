package Ecenter::Schema::Result::Pinger_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('pinger_data');
__PACKAGE__->add_columns(qw/pinger_data metaid minRtt meanRtt medianRtt maxRtt timestamp minIpd meanIpd maxIpd duplicates outOfOrder clp iqrIpd lossPercent/); 
__PACKAGE__->set_primary_key('pinger_data');
__PACKAGE__->belongs_to(metadata => 'Ecenter::Schema::Result::Metadata', 'metaid');

__PACKAGE__->add_unique_constraint( meta_time => [ qw/metaid timestamp/ ]);

1;
