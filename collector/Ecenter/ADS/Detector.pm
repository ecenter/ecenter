package Ecenter::ADS::Detector;

use Moose;
use namespace::autoclean;
use Data::Dumper;

use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );

=head1 NAME

E-Center::ADS::Detector -  base  class for the Anomalous Detection Algorithm implmentation or any other data analysis

=head1 DESCRIPTION

base calss for the Anomalous Detection Algorithm implmentation. Might be subclassed for the
more specific analysis implementations.
It accepts some parameters ( named attributes to the class ) and  parses data from the 'data' attribute and 
then it processess  data and returns results where results
are stored in the 'results' attribute.
It serves as the base class for any other data analysis service ( forecasting for example).

=head1 SYNOPSIS 

see Ecenter::DataClient, Ecenter::Client for the subclassing examples. Normal usage:

 use Moose;
 extends 'Ecenter::ADS::Detector';

 after 'process_data' => {
     # actual implementation
 };

=head1 ATTRIBUTES

=over

=item


=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut

has data        =>  (is => 'rw', isa => 'HashRef');
has results     =>  (is => 'rw', isa => 'HashRef');
has start       =>  (is => 'rw', isa => 'Num');
has end         =>  (is => 'rw', isa => 'Num');
has logger      =>  (is => 'rw', isa => 'Log::Log4perl::Logger');
has parsed_data =>  (is => 'rw', isa => 'HashRef');
has data_type   =>  (is => 'rw', isa => 'Str', required => 1);

my $METRIC = {owamp => [qw/max_delay min_delay/], bwctl => [qw/throughput/], snmp => [qw/utilization/]};

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__));
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    $self->results({});
}

=head1 process_data

  data processing 

=cut

sub process_data {
    my ( $self, $params ) = @_;
    map {$self->$_($params->{$_}) if $self->can($_)} keys %$params if $params && ref $params eq ref {};
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
	    map { $parsed_data->{metadata}{"$src_ip\__$dst_ip"}{$_} = $data->{$src_ip}{$dst_ip}{$_} } qw/src_hub dst_hub metaid/;
    	    foreach my $timestamp (keys %{$data->{$src_ip}{$dst_ip}{data}}) {
		foreach my $name (@{$METRIC->{$self->data_type}}) {
		    $parsed_data->{$name}{"$src_ip\__$dst_ip"}{$timestamp} = $data->{$src_ip}{$dst_ip}{data}{$timestamp}{$name};
    	        }
    	    }
        }
    }
    foreach my $name (@{$METRIC->{$self->data_type}}) {
	foreach my $key (keys   %{$parsed_data->{$name}}) {
	    my %tmp =  %{$parsed_data->{$name}{$key}};
	    $parsed_data->{$name}{$key} = [];
	    my $timestamps =    scalar (keys %tmp);
	    @{$parsed_data->{$name}{$key}} =  sort {$a->[0] <=> $b->[0] } map {[$_ , $tmp{$_} ]} 
	                                        keys %tmp;
	   $self->start($parsed_data->{$name}{$key}->[0][0]) 
	       if !$self->start || 
	           $self->start > $parsed_data->{$name}{$key}->[0][0];
	   my $last_timestamp = $timestamps?$timestamps-1:0;
	   $self->end($parsed_data->{$name}{$key}->[$last_timestamp][0]) 
	       if !$self->end || 
	           $self->end > $parsed_data->{$name}{$key}->[$last_timestamp][0];			
        }
    }
    
    #$self->logger->debug("Parsed Data", sub{Dumper($parsed_data)});
    return $self->parsed_data($parsed_data);
}
=head1 add_results

add result for the src/dst pair to the results hashref

=cut

sub add_result {
    my ( $self,  $key,  $status, $response) = @_;
    my ($src, $dst) = split('__', $key);
    if($status && !$status->{critical}){
        $response->{status} = 'OK';
    } else {
        $response->{status} = $status?$status:'ok';
    }
    return $self->results( { %{$self->results},  $src => { $dst => $response} } );
}

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


