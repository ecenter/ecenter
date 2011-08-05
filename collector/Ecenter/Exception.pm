package Ecenter::Exception;

=head1 NAME

Ecenter::Exception  -  Ecenter exceptions

=head1 DESCRIPTION

  declarative package for the Ecenter daat service exceptions

=cut

use Exception::Class (
      'GeneralException',
      'GearmanException',
      'RemoteServiceException',
      'DBException',
      'ParameterException' => { isa => 'GeneralException',
                                description => 'Parameter is missing or wrong'},

      'RemoteServiceFailureException' => {
          isa         => 'RemoteServiceException',
          description => 'remote service failed'
      },
      'MalformedParameterException' => {
          isa         => 'ParameterException',
          description => 'supplied parameter is malformed'
      },
      'GearmanServerException' => {
          isa         => 'GearmanException',
          description => 'failed to connect to the Gearman server'
      },

      'LocalDataServiceFailureException' => {
          isa         => 'DBException',
          description => 'local cache data request failed'
      }
);

1;

__END__


=head1 SEE ALSO

L<Exception::Class>

The E-center subversion repository is located at:
 
   https://ecenter.googlecode.com/svn
   

The perfSONAR-PS subversion repository is located at:

  https://svn.internet2.edu/svn/perfSONAR-PS

Questions and comments can be directed to the author, or the mailing list.  Bugs,
feature requests, and improvements can be directed here:

  http://code.google.com/p/ecenter/issues/list
  
=head1 VERSION

$Id: $

=head1 AUTHOR

Maxim Grigoriev, maxim_at_fnal_dot_gov

=head1 LICENSE

You should have received a copy of the  Fermitools license
with this software.  If not, see <http://fermitools.fnal.gov/about/terms.html>

=head1 COPYRIGHT

Copyright (c) 2011, Fermitools

All rights reserved.

=cut
