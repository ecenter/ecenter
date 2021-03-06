package Ecenter::Types;

use strict;
use warnings;
 
use English qw( -no_match_vars );
use Net::IP;

=head1 NAME

 E-Center::Types  - added types for the Ecenter with builtin validation

=head1 DESCRIPTION

  E-Center::Types  - added types for the Ecenter with builtin validation, among them:
   MyDateTime -  datetime , initialized from the hashref
   IP_addr -  ipv4 or ipv6 addresses
   PositiveInt
  
=head1 SYNOPSIS 
   
    use Ecenter::Types qw(DateTime PositiveInt);
   
=head1 TYPES

 
=cut


use MooseX::Types -declare => [qw( PositiveInt  IPAddr  HubName MyDateTime )];

         # import builtin types
         use MooseX::Types::Moose qw/Int HashRef Str/;
          
	 # type definition.
         subtype HubName,
             as Str,
             where { $_ =~ /^bnl|anl|ornl|nasa|lbl|fnal|slac|jgi|pppl|pnnl|pnl|pnwg|sc11|nersc|snll|llnl|nash$/i},
             message { 'Name from the list - bnl|anl|ornl|nasa|lbl|fnal|slac|jgi|pnnl|ppppl|pnl|pnwg|sc11|nersc|snll|llnl|nash  ' };
         # type coercion
         coerce HubName,
             from Str,
                 via { 1 };
		 
         # type definition.
         subtype PositiveInt,
             as Int,
             where { $_ > 0 },
             message { "$_ is not larger than 0" };
         # type coercion
         coerce PositiveInt,
             from Int,
                 via { 1 };

          # type definition.
	 class_type MyDateTime, { class => 'DateTime' };
         # type coercion
	 coerce MyDateTime,
           from HashRef,
           via { DateTime->new(%$_) };
	
	coerce MyDateTime,
           from Str,
           via { DateTime->new($_) };
	 
	  # type definition.
	 subtype IPAddr,
	    as Str,
	    where  { defined Net::IP->new($_) },
	    message {"$_ must be IP address"};
           # type coercion
	 coerce IPAddr,
           from Str,
           via { 1 };
	   

1;

=head1   AUTHOR

    Maxim Grigoriev, 2010, maxim@fnal.gov
         

=head1 COPYRIGHT

Copyright (c) 2010, Fermi Research Alliance (FRA)

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut
