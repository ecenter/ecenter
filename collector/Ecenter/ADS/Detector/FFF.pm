package Ecenter::ADS::Detector::FFF;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use English qw( -no_match_vars );
use List::Util qw[min max];
use FindBin qw($Bin);
use Ecenter::Utils;
use Ecenter::Types;
use POSIX qw(strftime :sys_wait_h);

use JSON::XS qw(encode_json decode_json);
use Gearman::Client;
use Log::Log4perl qw(get_logger);
extends 'Ecenter::ADS::Detector';

=head1 NAME

E-Center::ADS::Detector::FFF -    forecasting algorithm

=head1 DESCRIPTION

 
=head1 SYNOPSIS 

   my $detector = Ecenter::ADS::Detector::FFF->new({ data => \@data_array });
   my $results = $detector->process_data;
   ### and results are in the results attribute:
   $results = $detector->results;
   
   
	
    ## returning list of forecasted values and stderr
 
     $VAR1 = {
          '198.124.252.101' => {
                                 '198.129.254.146' => { throughput =>
				                         {
						           stderr =>  0.004, 
							   forecast =>  {
							       12132134124 => '0.3232',
							       12132134136 => '0.3234', 
							       12132134148 => '0.3256', 
                                                           }
						         }
                                                     },
			    }, 
        
        }; 
=cut

=head1 ATTRIBUTES

=over

=item  


=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut
has stderr    =>  (is => 'rw', isa => 'Num', required => 0  );
has future_points =>  (is => 'rw', isa => 'Int', default => 10);
has timeout =>  (is => 'rw', isa => 'Ecenter::Types::PositiveInt', default => '120');

my $ANA_METRIC = {snmp =>  'utilization', bwctl => 'throughput', 'owamp' => 'max_delay'};

local $SIG{USR1} = 'IGNORE';
local $SIG{PIPE} = 'IGNORE';
local $SIG{CHLD} = 'IGNORE';

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__));  
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
}

=head1 process_data

process data for the 

=cut

after 'process_data' => sub {
    my ( $self,  $args ) = @_;
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    unless( $self->data || $self->parsed_data) {
       $self->logger->logdie("NO data was supplied, aborting");
    }
    $self->parse_data if  !$self->parsed_data;
    unless( $self->parsed_data) {
       $self->logger->logdie("NO data was found, aborting");
    }
    my $data_ip = $self->parsed_data->{$ANA_METRIC->{$self->data_type}};
    my $g_client;
    my $task_set;
    eval {
	$g_client =   get_gearman({'xenmon.fnal.gov' => ['10121']});
	$task_set = $g_client->new_task_set;
	foreach my $key (keys %$data_ip) {
	    my @data = map {$_->[1]} @{$data_ip->{$key}};
	    my @times = map {$_->[0]} @{$data_ip->{$key}};
	    my %metadata =   map {$_ => $self->parsed_data->{metadata}{$key}{$_}} qw/src_hub dst_hub metaid/;
	    $self->logger->debug(" Trying to forecast -- $key  ", sub{Dumper(\@times,\@data)});   
	    next unless scalar @data;
	 
	    my $ret =  $task_set->add_task( 'forecast' =>
	                                	  encode_json { times => \@times,
					                	data  => \@data,
								future_points => $self->future_points
							      },
					     on_fail     => sub {
					                      $self->logger->error("FAILED: $key  ");
					     },
					     on_complete => sub {
					                       my $returned = decode_json  ${$_[0]};
							       $self->add_results($key, { $ANA_METRIC->{$self->data_type} => $returned });
							       $self->logger->debug("Results Data $key - ",
							                        	sub{Dumper( $returned)});
					     }
	    );

	}
    };
    if($EVAL_ERROR) {
        $self->logger->error("data call  failed - $EVAL_ERROR");
        GeneralException->throw(error => $EVAL_ERROR ); 
    }
    $task_set->wait(timeout => $self->timeout) if $task_set;
    return $self->results;
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


