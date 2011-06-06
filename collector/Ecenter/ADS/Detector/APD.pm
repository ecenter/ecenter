package Ecenter::ADS::Detector::APD;

use Moose;
use namespace::autoclean;

use FindBin qw($RealBin);
use lib  "$FindBin::Bin";
use English qw( -no_match_vars );

use List::Util qw[min max];

extends 'Ecenter::ADS::Detector';

=head1 NAME

E-Center::ADS::Detector::APD -   adaptive  plateau detection algorithm,  

=head1 DESCRIPTION

 
=head1 SYNOPSIS 

   my $detector = Ecenter::ADS::Detector::APD->new({ data => \@data_array });
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

has elevation1  =>  (is => 'rw', isa => 'Num', default => .2);
has elevation2  =>  (is => 'rw', isa => 'Num', default => .4);
has swc         =>  (is => 'rw', isa => 'Int', default => 20);
has sensitivity =>  (is => 'rw', isa => 'Int', default => 2);
 
my $ANA_METRIC = {owamp =>  'max_delay', bwctl => 'throughput'};
use constant {
	NORMAL => 0,
	WARNING => 1,
	CRITIAL => 2,
};


sub BUILD {
    my ($self, $args) = @_;
    $self->logger(get_logger(__PACKAGE__)); 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
}

=head1 process_data

  data processing 

=cut


after 'process_data' => {
    my ( $self,  $args ) = @_; 
    map {$self->$_($args->{$_}) if $self->can($_)}  keys %$args if $args && ref $args eq ref {};
    my $data_ip = $self->parse_data->{$ANA_METRIC->{$self->data_type}};
    foreach my $key (keys %$data_ip) { 
	my $data = @{$data_ip->{$key}};
	my $data_size = scalar @data;
	next unless $data_size;

	my ($mean,$sigma,$cu,$wu,$wl,$cl,@status);
	#timer for trigger elevation
	my $timer=0;
	my $p=0;
	#buffers
	my (@normal,@warning,@critical);

	#take the first $self->swc number data as normal status
	for (my $i = 0; $i < min($self->swc, $data_size); $i++){
    		push(@normal,$data[$i]->[1]);	    
    		$status[$i]=NORMAL;
	}

	#main apd(or spd) algorithm
	#detection analysis on the data begin with index $self->swc 
	for (my $i = $self->swc; $i < $data_size; $i++){
    		if($timer==0){
    			($mean,$sigma)=$self->_getstat(\@normal);
    			if($spd){
    				($cu,$wu,$wl,$cl)=$self->_getthreshold($mean, $sigma);
    			}else{
    				$self->sensitivity($self->_newsensitivity($i, $sigma, \@data));
    				($cu,$wu,$wl,$cl)=$self->_getthreshold($mean, $sigma);
    			}
    		} else{
    			$timer--;
    		}

    		if($data[$i]->[1]>$cu || $data[$i]->[1]<$cl){
    			push(@critical,$data[$i]);
    			$tricnt++;
    		} elsif($data[$i]->[1]>$wu || $data[$i]->[1]<$wl){
    			push(@warning,$data[$i]->[1]);
    			$tricnt++;
    		} else {
    			$normal[$p]=$data[$i]->[1];
    			$p++;
    			if($p==$self->swc){ $p=0;}

    			$tricnt=max($tricnt-1,0);
    		}
    		if($tricnt==0 && $#warning>0 ){
    			$self->_cp_warning_normal(\$p, \@normal,\@warning);
    			@warning = ();
    			@critical = ();
    		}

    		if($tricnt==$tri_duration){
    			$tricnt=0;
    			$status[$i]=CRITIAL;
    			($cu,$wu,$wl,$cl)=$self->_elevation(\@critical,\@warning,\@ele);
    			$timer=$self->swc;
    			$self->_cp_warning_normal(\$p, \@normal,\@warning);
    			@warning = ();
    		} elsif ($tricnt> .75*$tri_duration){
    			$status[$i]=WARNING;
    		}
    		else{
    			$status[$i]=NORMAL;
    		}
	}
	$self->add_result($tri_duration, \@ele, \@data,\@status );
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
sub _newsensitivity{
	my ($self, $cp, $sigma,$data)=@_;
	my $newsigma=0;
	my $mmean=0;
	my $ns;
	if(($cp+$self->swc)>$#$data){
		return 2;
	}
	for(my $k=0;$k<$self->swc;$k++){
		$mmean+=$data->[$cp+$k]->[1];
	}
	$mmean/=$self->swc;
	for(my $k=0;$k<$self->swc;$k++){
		$newsigma+=($mmean-$data->[$k+$cp]->[1])*($mmean-$data->[$k+$cp]->[1]);
	}
	$newsigma=sqrt($newsigma/($self->swc-1));
	$ns=min(5,.4*($newsigma/$sigma)*($newsigma/$sigma)+2);
	return $ns;
}
#compute the threshold based on the mean,standard_deviation and sensitivity
#Output:  upper_threshold2,upper_threshold1,lower_threshold1,lower_threshold2
sub _getthreshold {
	my ($self, $mean,$sigma)=  @_;
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
    $sigma=sqrt($sigma/($self->swc -1));
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


