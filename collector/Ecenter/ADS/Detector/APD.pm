package Ecenter::ADS::Detector::APD;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use English qw( -no_match_vars );
use List::Util qw[min max];

 
use Log::Log4perl qw(get_logger);
extends 'Ecenter::ADS::Detector';

=head1 NAME

E-Center::ADS::Detector::APD -   adaptive and static  plateau detection algorithms

=head1 DESCRIPTION

 
=head1 SYNOPSIS 

   my $detector = Ecenter::ADS::Detector::APD->new({ data => \@data_array, algo => 'spd' });
  my $results = $detector->process_data;
  ### and results are in the results attribute:
  $results = $detector->results;
  
  # In case if no critical anomaly was detected the $results  data structure will look as:
  # Notice the separate data for each source/destination pair:
  
  $VAR1 = {
          '198.124.252.101' => {
                                 '198.129.254.146' => {
                                                        'sensitivity' => 2,
                                                        'status' => 'OK',
                                                        'elevation1' => '0.2',
                                                        'elevation2' => '0.4',
                                                        'plateau_size' => 7,
                                                        'swc' => 20
                                                      }
                               },
          '198.129.254.146' => {
                                 '198.124.252.101' => {
                                                        'sensitivity' => 2,
                                                        'status' => 'OK',
                                                        'elevation1' => '0.2',
                                                        'elevation2' => '0.4',
                                                        'plateau_size' => 7,
                                                        'swc' => 20
                                                      }
						      
                               }
        };
	
 ## if there is a critical anomaly then:
 
     $VAR1 = {
          '198.124.252.101' => {
                                 '198.129.254.146' => {
                                                        'sensitivity' => 2,
                                                        'status' =>  { 
							    critical => {
							       12132134124 =>
								            {
							                      anomaly_type => 'plateau',  
			                                                        value        =>'0.3232',
							    	             },
							      },
							       warning => {
							       1213243443344 =>
								            {
							                      anomaly_type => 'plateau',  
			                                                        value        =>'0.434343',
							    	           },
							      },
							},
                                                        'elevation1' => '0.2',
                                                        'elevation2' => '0.4',
                                                        'plateau_size' => 7,
                                                        'swc' => 20
                                                      }
                               },
        
        }; 

=head1 ATTRIBUTES

=over

=item  


=item  logger

logging  agent via C<Log::Log4perl>

=back

=head1 METHODS


=cut
has algo        =>  (is => 'rw', isa => 'Str', required => 1);
has elevation1  =>  (is => 'rw', isa => 'Num', default => .2);
has elevation2  =>  (is => 'rw', isa => 'Num', default => .4);
has swc         =>  (is => 'rw', isa => 'Int', default => 20);
has sensitivity =>  (is => 'rw', isa => 'Num', default => 2);
 
my $ANA_METRIC = {owamp =>  'max_delay', bwctl => 'throughput'};
 
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
	my %metadata =   map {$_ => $self->parsed_data->{metadata}{$key}{$_}} qw/src_hub dst_hub metaid/;
	my $data_size = scalar @data;
	next unless $data_size;

	my ($mean,$sigma,$cu,$wu,$wl,$cl,%status);
	#timer for trigger elevation
	my $timer=0;
	my $p=0;
	my $tricnt=0;
	my $tri_duration=int(($self->swc+2)/3);
	my @ele=($self->elevation1, $self->elevation2);
	#buffers
	my (@warning,@critical);
	#take the first $self->swc number data as normal status
	my @normal =  @data[0..(min($self->swc, $data_size -1))];
	#main apd(or spd) algorithm
	 $self->logger->debug("Normal::", sub{Dumper(\@normal)});
	 
	#detection analysis on the data begin with index $self->swc 
	for (my $i = $self->swc; $i < $data_size; $i++){
    	    if($timer==0){
    	    	($mean,$sigma)=$self->_getstat(\@normal);
    	    	if($self->algo eq 'spd'){
    	    	    ($cu,$wu,$wl,$cl)=$self->_getthreshold($mean, $sigma);
    	    	} else{
    	    	    $self->sensitivity($self->_newsensitivity($i, $sigma, \@data, $data_size));
    	    	    ($cu,$wu,$wl,$cl)=$self->_getthreshold($mean, $sigma);
    	    	}
    	    } else{
    	    	$timer--;
    	    }
    	    if($data[$i]>$cu || $data[$i]<$cl){
    	    	push(@critical,$data[$i]);
    	    	$tricnt++;
    	    } elsif($data[$i]>$wu || $data[$i]<$wl){
    	    	push(@warning,$data[$i]);
    	    	$tricnt++;
    	    } else {
    	    	$normal[$p]=$data[$i];
    	    	$p++;
    	    	if($p==$self->swc){ $p=0;}
    	    	$tricnt=max($tricnt-1,0);
    	    }
    	    if($tricnt==0 && $#warning>0 ){
    	    	$self->_cp_warning_normal(\$p, \@normal,\@warning);
    	    	@warning = ();
    	    	@critical = ();
    	    }
            my $response = { anomaly_type => 'plateau',
			     value        => $data[$i]  
			   };
	   $self->logger->debug("Tricnt=$tricnt Tri_duration=$tri_duration Sen=" . $self->sensitivity . " Data=$data[$i]");
	   if($tricnt==$tri_duration){
	        $self->logger->debug("Critical::" . $data_ip->{$key}->[$i][0]  . " value=" . $data[$i] );
    	    	$tricnt=0;
    	    	$status{critical}{$data_ip->{$key}->[$i][0]}=  $response; #   src:dst => timestamp
    	    	($cu,$wu,$wl,$cl)=$self->_elevation(\@critical,\@warning,\@ele);
    	    	$timer=$self->swc;
    	    	$self->_cp_warning_normal(\$p, \@normal,\@warning);
    	    	@warning = ();
    	    } elsif ($tricnt> .75*$tri_duration){
	        $self->logger->debug("Warning::" . $data_ip->{$key}->[$i][0] . " value=" . $data[$i]);
    	    	$status{warning}{$data_ip->{$key}->[$i][0]}= $response; #   src:dst => timestamp
    	    }
	    
	}
	$self->logger->debug("Results Data $key - ", sub{Dumper( \%status )});
	$self->add_result(  $key,   \%status, { plateau_size => $tri_duration,
                                                swc          => $self->swc,
                                                sensitivity  => $self->sensitivity,
                                                elevation1   => $ele->[0],
                                                elevation2   => $ele->[1] }
	);
    }
    return $self->results;
};
#copy @warning to the end of @normal, overwrite old elements if @normal if necessary
sub _cp_warning_normal{
     my ($self, $p, $normal, $warning)=@_;
     for(my $i=0;$i<=$#$warning;$i++){
        $normal->[$$p]=$warning->[$i];
        $$p++;
        if($$p==$self->swc) { $$p=0; }
    }
}

#compute adptive sensitivity based on the variance of data, for adaptive palteau detection
#Output: new sensitivity
sub _newsensitivity {
    my ($self, $cp, $sigma, $data, $data_size)=@_;
    my $newsigma=0;
    my $mmean=0;
    my $ns;
    if(($cp+$self->swc)>= $data_size){
    	return 2;
    }
    for(my $k=0;$k<$self->swc;$k++){
    	$mmean+=$data->[$cp+$k];
    }
    $mmean/=$self->swc;
    for(my $k=0;$k<$self->swc;$k++){
    	$newsigma+=($mmean-$data->[$k+$cp])*($mmean-$data->[$k+$cp]);
    }
    $newsigma=sqrt($newsigma/($self->swc-1));
    $ns=min(5, .4*($newsigma/$sigma)*($newsigma/$sigma)+2);
    return $ns;
}
#compute trigger elevation 
#Output:  elevated (upper_threshold2,upper_threshold1,lower_threshold1,lower_threshold2)
sub _elevation{
    my ($self, $critical,$warning,$ele)=@_;
    my $max=max(@$critical,@$warning);
    my $min=min(@$critical,@$warning);
    my @up=($$ele[0]+1,$$ele[1]+1);
    my @down=(1-$ele->[0],1-$ele->[1]);
    return ($max*$up[1],$max*$up[0],$min*$down[0],$min*$down[1]);
}
#compute the threshold based on the mean,standard_deviation and sensitivity
#Output:  upper_threshold2,upper_threshold1,lower_threshold1,lower_threshold2
sub _getthreshold {
    my ($self, $mean, $sigma)=  @_;
    return ($mean+2*$self->sensitivity*$sigma,$mean+$self->sensitivity*$sigma,
    	    $mean-$self->sensitivity*$sigma,$mean-2*$self->sensitivity*$sigma);
}
#compute the mean and standard_deviation of @normal buffer
#Output:  $mean,$sigma of @normal
sub _getstat {
    my ($self, $data)=@_;
    my $mmean=0;
    my $sigma=0;
    for (my $k = 0; $k < $self->swc; $k++){
   	$mmean += $data->[$k];
    }
    $mmean /= $self->swc;
    for (my $k = 0; $k <  $self->swc; $k++){
   	$sigma+=($mmean-$data->[$k])*($mmean-$data->[$k]);
    }
    $sigma=sqrt($sigma/($self->swc - 1));
    return ($mmean,$sigma);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1   AUTHOR

Maxim Grigoriev, 2011, maxim@fnal.gov
    
SPD/APD implementation:  
Mukundan Sridharan,Prasad Calyam,Jialu Pu - The Ohio Supercomputer Center

=head1 COPYRIGHT

Copyright (c) 2011, Fermi Research Alliance (FRA)

On APD/SPD algorithm implementation:
Copyright (c) 2011, The Ohio Supercomputer Center

=head1 LICENSE

You should have received a copy of the Fermitool license along with this software.
  

=cut


