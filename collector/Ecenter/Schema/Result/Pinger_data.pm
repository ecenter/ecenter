package Ecenter::Schema::Result::Pinger_data;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('pinger_data');
__PACKAGE__->add_columns(qw/pinger_data metadata  minRtt meanRtt maxRtt timestamp minIpd meanIpd maxIpd duplicates outOfOrder clp iqrIpd lossPercent/); 
__PACKAGE__->belongs_to(metadatas => 'Ecenter::Schema::Result::Metadata');
__PACKAGE__->set_primary_key('pinger_data');


1;
