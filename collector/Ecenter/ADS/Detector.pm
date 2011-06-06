package Ecenter::ADS::Detector;

use Moose;
use namespace::autoclean;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

use Ecenter::DataClient;

use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );

=head1 NAME

E-Center::ADS::Detector -  base  class for the Anomalous Detection Algorithm implmentation

=head1 DESCRIPTION

base calss for the Anomalous Detection Algorithm implmentation. Might be subclassed for the
more specific analysis implementations.
It accepts some parameters ( named attributes to the class ) and sends request to the E-Center DRS by
utilizing Ecenter::DataClient, then it processess the data from the DRS and returns results where results
are stored in the 'results' attribute.

=head1 SYNOPSIS 

see Ecenter::DataClient, Ecenter::Client for the subclassing examples. Normal usage:

 use Moose;
 extends 'Ecenter::ADS::Detector';

 ## or, if no subclasses required then somehting like
   
  my $detector = Ecenter::ADS::Detector->new({ data => \@data_array });
  my $results = $detector->process_data;
  ### and results are in the results attribute:
  $results = $detector->results;

=head1 ATTRIBUTES

=over

=item  


=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut

has data      =>  (is => 'rw', isa => 'HashRef');
has results   =>  (is => 'rw', isa => 'HashRef');
has logger    =>  (is => 'rw', isa => 'Log::Log4perl::Logger');
has parsed_data =>  (is => 'rw', isa => 'HashRef');
has data_type =>  (is => 'rw', isa => 'Str', default => 'owamp');

my $METRIC = {owamp => [qw/max_delay min_delay/], bwctl => [qw/throughput/]};

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
}

=head1 process_data

  data processing 

=cut


sub process_data {


}

=head1 parse_data

  parse data in the request according to the data_type and sort it by timestamp

=cut


sub parse_data {
    my ( $self,  $args ) = @_; 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    my $data =  $self->data->{$self->data_type};
    my $parsed_data = {};
    my %src_ips = ();
    ##
    foreach my $src_ip (keys %$data){
    	foreach my $dst_ip (keys %{$data->{$src_ip}}){
    	    foreach my $timestamp (keys %{$data->{$src_ip}{$dst_ip}}){
    	    	foreach my $name (@{$METRICS->{$self->data_type}}) {
		    $parsed_data->{$name}{"$src_ip:$dst_ip"}{$timestamp} = $data->{$src_ip}{$dst_ip}{$timestamp}{$name};
    	        }
    	    }
        }
    }
    foreach my $name (@{$METRICS->{$self->data_type}}) {
	foreach my $key (keys   %{$parsed_data->{$name}}) { 
	    @{$parsed_data->{$name}{$key}} =  sort {$a->[0] <=> $b->[0] } map {[$_ =>  $parsed_data->{$name}{$key}{$_} ]} 
	                                        keys %{$parsed_data->{$name}{$key}};
        }
    }
    return $self->parsed_data($parsed_data);
}
###################### here
sub add_result {
    my ($self, $tri_duration, $ele, $data, $status ) = @_;
    my %para=(
	 plateau_size => $tri_duration,
         swc          => $self->swc,
         sensitivity  => $self->sensitivity,
         elevation1   => $ele->[0],
         elevation2   => $ele->[1],
    );

    for (my $i = 0; $i<= $#$status;$i++){
    	     if($status->[$i] ==  2){
    		     $d{$$time[$i]}={$data_typestring=>{value=>$$data[$i],anomaly_type=>"plateau",anomaly_value=>"critical"},timestamp=>$$time[$i]};
    	     }elsif($$status[$i]==1){
    		     $d{$$time[$i]}={$data_typestring=>{value=>$$data[$i],anomaly_type=>"plateau",anomaly_value=>"warning"},timestamp=>$$time[$i]};
    		     $cnt++;
    	     }   
     }
     my $json;
     my $json_text=to_json(\%$parameter);
     if($cnt==0){
    	     $json->{$data_type."_anomaly"}{$src}{$dst}="OK";
    	     $json_text.=to_json(\%$json);
    	     return \$json_text;
     }
     $json->{$data_type."_anomaly"}{$src}{$dst}=\%d;


};

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2011, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2011, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut


