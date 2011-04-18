package Ecenter::ADS::Detector;

use Moose;
use namespace::autoclean;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );

=head1 NAME

 E-Center::ADS::Detector -  base  class for the Anomalous Detection Algorithm implmentation

=head1 DESCRIPTION

base client for the   Anomalous Detection Algorithm implmentation. Assumed to be subclassed for some
more specific algorithms.
  
=head1 SYNOPSIS 
 
see Ecenter::DataClient, Ecenter::Client for the subclassing examples. Normal usage:

 use Moose;
 extends 'Ecenter::ADS::Detector';



=head1 ATTRIBUTES

=over

=item  


=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut


has logger     => (is => 'rw', isa => 'Log::Log4perl::Logger');

sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
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


