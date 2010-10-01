package Ecenter::Data::Traceroute;

use Moose;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";

extends 'Ecenter::Data::Psb';

use Log::Log4perl qw(get_logger);
use English qw( -no_match_vars );
use Data::Dumper;
use Date::Manip;

=head1 NAME

 E-Center::Data::Traceroute data retrieval API for remote traceroute MA data

=head1 DESCRIPTION

  perfSONAR-PS - data retrieval API  for traceroute remote services
  
=head1 SYNOPSIS 
 
=cut

sub BUILD {
      my $self = shift;
      $self->eventtypes([("http://ggf.org/ns/nmwg/tools/traceroute/2.0")]);
      $self->namespace("http://ggf.org/ns/nmwg/tools/traceroute/2.0");
      $self->nsid("traceroute");
      $self->resolution(100);
      $self->logger(get_logger(__PACKAGE__));
};


augment  'process_datum' => sub {
   my $self = shift;
   my $dt = shift;
   my $secs =  $dt->getAttribute( "timeValue" );
   my $t_type =  $dt->getAttribute( "timeType");
   $secs = UnixDate($secs,  '%s') if($t_type ne 'unix');
   my $unit =  $dt->getAttribute( "valueUnits");
   $unit =  ($unit eq 'sec')?0.001:1;
  
   my $hop_ip    = $dt->getAttribute("hop");
   my $hop_num   = $dt->getAttribute("ttl");
   my $hop_delay = $dt->getAttribute("value");
   return unless   $hop_ip && $hop_num && $hop_delay;
   $hop_delay *= $unit;
   $self->logger->debug("parsing..  t=$secs ip=$hop_ip hop_num=$hop_num  hop_delay=$hop_delay") if $hop_ip  && $hop_num  && $hop_delay;
   return  ($secs?[ $secs, {hop_ip  =>  $hop_ip, hop_num => $hop_num,hop_delay => $hop_delay } ]:[]);
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
