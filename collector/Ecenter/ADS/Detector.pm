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

has data    =>  (is => 'rw', isa => 'ArrayRef');
has results => (is => 'rw', isa => 'ArrayRef');
has logger  => (is => 'rw', isa => 'Log::Log4perl::Logger');

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


