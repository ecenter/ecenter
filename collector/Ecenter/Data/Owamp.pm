package Ecenter::Data::Owamp;

use Mouse;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Psb';

use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );
use Data::Dumper;


=head1 NAME

 E-Center::Data::Owamp   data retrieval API for remote owamp MA data

=head1 DESCRIPTION

  perfSONAR-PS - data retrieval API 
  
=head1 SYNOPSIS 
 
=cut

sub BUILD {
      my $self = shift;
      my $args = shift; 
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/owamp/2.0")]);
      $self->namespace("http://ggf.org/ns/nmwg/tools/owamp/2.0");
      $self->nsid("owamp");
      $self->logger(get_logger(__PACKAGE__));
      return  $self->url($args->{url}) if $args->{url};
};

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
