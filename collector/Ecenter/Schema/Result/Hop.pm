package Ecenter::Schema::Result::Hop;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('hop');
__PACKAGE__->add_columns(qw/hop_id trace_id hop_ip hop_num hop_delay/);
__PACKAGE__->set_primary_key('hop_id');
__PACKAGE__->belongs_to(hop_ip => 'Ecenter::Schema::Result::Node', {'foreign.ip_addr' => 'self.hop_ip'});
__PACKAGE__->belongs_to(trace_id => 'Ecenter::Schema::Result::Traceroute_data', 'trace_id');


1;
