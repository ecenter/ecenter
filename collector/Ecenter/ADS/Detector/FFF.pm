package Ecenter::ADS::Detector::FFF;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use English qw( -no_match_vars );
use List::Util qw[min max];
use FindBin qw($Bin);

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
                                 '198.129.254.146' => { stderr =>  0.004,
				                        status => 'OK',
							future_points => 3,
				                         forecast =>  {
							    12132134124 => '0.3232',
							    12132134136 => '0.3234', 
							    12132134148 => '0.3256', 
                                                         }
						      }
                               },
        
        }; 
=cut
BEGIN {
    $ENV{PYTHONPATH} .= ":/home/netadmin/ecenter_git/ecenter/collector/Ecenter/ADS/Detector";
  
};
use Inline Config => DIRECTORY => '/home/netadmin/ecenter_git/ecenter/collector/Ecenter/ADS/Detector';
use Inline Python => <<'END';
import numpy as np
import scipy as sp
import GPRmodule
#
from scipy import *
from numpy import *
from scipy import linalg
from GPRmodule import GPR3err
#
#----------------fabricate-data----------------
#
def fff(npoints, DELT, future_points, times, observed):
  DELT2 = DELT*2
  fk =  DELT2 + times[0]     # first knot
  k = arange(fk, times[-1]+DELT,DELT2)            # knot times (locations)
  kn = len(k)             # number of knots
  u = lambda x: (sign(x)+1)/2                          # unit step function
  r = lambda x: multiply(x,u(x))                       # ramp function
  result_times = matrix(times).T
  o = matrix(ones((npoints,1)))
  X = append(o, result_times,axis=1)                               # design matrix
  X = append(X, r(result_times-k),axis=1)                          # add basis functions
  R = matrix(linalg.cholesky(X.T*X))
  D = eye(kn+2)
  D[0,0] = 0
  D[1,1] = 0
  Rinv = R.I
  U,s,Vh = linalg.svd(Rinv.T*D*Rinv)
  U = matrix(U)
  A = X*Rinv*U
  observed = matrix(observed).T
  bb = A.T*observed
  #
  #---------------find-optimal-lambda------------
  #
  # The Python scalar function minimizer "brent" used here is relatively
  # slow. This should be addressed if faster overall execution is needed.
  #
  def cv(lam):
      lam2 = lam**2
      H = A*diag(1/(1+lam2*s))*A.T                     # hat matrix
      f = H*observed
      res = observed-f                                        # residuals
      h = diag(H,0)                                    # leverages
      return sum(np.array(res/(1-h))**2)               # returns cv
  #
  from scipy.optimize import brent
  lamopt = brent(cv,tol=1e-5,maxiter=10)               # scalar function minimizer
  rlamopt = round(lamopt,1)
  #
  #------------smooth-with-optimal-lambda--------
  lam2 = lamopt**2
  b = Rinv*U*diag(1/(1+lam2*s))*bb                     # parameter estimates
  #
  #-----------------estimate-sigma---------------
  f = A*bb                                             # with lam=0
  rss = sum(np.array(observed-f)**2)                          # residual sum-of-squares
  df = npoints-kn-2
  sig = sqrt(rss/df)                                   # estimate of sigma
  rsig = round(sig,1)
  #
  #---------------get-skeleton-data--------------
  accum = lambda npoints: matrix(tri(npoints))                     # triangular matrix of ones
  delta = accum(kn+1)*b[1:]
  s = matrix(array(b[0])*ones((kn+1,1)))
  s[1:] = s[1:]+DELT*accum(kn)*delta[:kn]
  # overlay extracted data
  # 
  #-------------prepare-to-forecast--------------
  future_times = array([k[-1]+DELT2])                              # first future time
  fn = s[-1]+DELT2*delta[-1]                            # new predicted level
  forecasted = array(fn)                                        # 1st future level
  omg = []
  d3 = array(delta[-3:])                               # most recent 3 delta's
  s3 = append(array(s[-2:]),fn)                        # most recent 3 levels
  #
  #-------------flow-field-forecast--------------
  M = future_points
  for i in range(2,M+2):
      test = append(s3,d3)                             # test point for GPR
      [deltstar,omega] = GPR3err(s[1:],delta[:-1],delta[3:],test)
      fn = fn+DELT2*deltstar                            # new predicted level
      omg = append(omg,omega)                          # for error bounds
      d3 = append(d3[-2:],deltstar)                    # new most recent 3 delta's
      s3 = append(s3[-2:],fn)                          # new most recent 3 levels
      future_times = append(future_times,future_times[-1]+DELT2)                         # updated future times
      forecasted = append(forecasted ,fn)                                 # updated future levels
  #
  #---------add-forecast-sequence-to-plot--------
  print "Forecasted X:",   future_times," Values:",  forecasted 
  #
  #--------------add-error-bounds----------------  
  sderr = array(sig)
  sderr = append(sderr,sqrt(sig**2+DELT2**2*delta.var()*(arange(1,len(omg)+1)-omg.cumsum())))
  
  p50 = forecasted+0.675*sderr
  m50 = forecasted-0.675*sderr
  p95 = forecasted+1.96*sderr
  m95 = forecasted-1.96*sderr
  print forecasted, sderr
  return  {'stderr' :  stderr,  'forecast':  dict(zip(future_times,forecasted)) }
END

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

my $ANA_METRIC = {snmp =>  'utilization', bwctl => 'throughput', 'owamp' => 'max_delay'};
 
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
    foreach my $key (keys %$data_ip) {
	my @data = map {$_->[1]} @{$data_ip->{$key}};
	my @times = map {$_->[0]} @{$data_ip->{$key}};
	my %metadata =   map {$_ => $self->parsed_data->{metadata}{$key}{$_}} qw/src_hub dst_hub metaid/;
	my $data_size = scalar @data;
	my $t_delta = int(($self->end - $self->start)/$data_size);
	next unless $data_size;
	$self->logger->debug("Params delta=$t_delta size=$data_size");
	
        my $result = fff($data_size, $t_delta, $self->future_points, \@times, \@data);
	 
	$self->logger->debug("Results Data $key - ", sub{Dumper( $result)});
	$result->{future_points} = $self->future_points;
	$self->add_result(  $key,   undef, $result );
    }
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


