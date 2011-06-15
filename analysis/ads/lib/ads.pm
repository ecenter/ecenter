package ads;
use Dancer ':syntax';
 
use Dancer::Plugin::REST;
our $VERSION = '1.1';  
use English qw( -no_match_vars );
use Data::Dumper;
use lib "/home/netadmin/ecenter_git/ecenter/analysis";
use Ecenter::Exception;
use Ecenter::DRS::DataClient; 
use Ecenter::ADS::Detector::APD;
use POSIX qw(strftime);
use Params::Validate qw(:all);
use Dancer::Logger;

use Log::Log4perl qw(:easy); 
 
use JSON::XS qw(encode_json decode_json);

prepare_serializer_for_format;

my $output_level = config->{debug} && config->{debug}> 0 ?$DEBUG:$INFO;
#my $output_level =  $INFO;
my %logger_opts = (
    level  => $output_level,
    layout => '%d (%P) %p> %F{1}:%L %M - %m%n'
);
Log::Log4perl->easy_init(\%logger_opts);
our  $logger = Log::Log4perl->get_logger(__PACKAGE__);
my $REG_IP = qr/^[\d\.]+|[a-f\d\:]+$/i;
my $REG_DATE = qr/^\d{4}\-\d{2}\-\d{2}\s+\d{2}\:\d{2}\:\d{2}$/;
my @DATA_ARGS = ('src_hub', 'dst_hub','src_ip','dst_ip','start','end','data_type', 'timeout', 'resolution');

##  status URL
any ['get'] =>  "/ads/status.:format" => 
       sub {
 	       return  { status => 'ok' }
       };
##  ADS service, too much data, need to POST
get  "/ads/:algo.:format" => 
       sub {   
	       return  detect_anomaly(algo => params->{algo}, params('query'));
       };
post "/ads/:algo.:format" => 
       sub {   my $request = params;
               my $post = params('body');
               debug "POST::::" . Dumper  $request;
	       delete $request->{format} 
                   if exists $request->{format};
	       return  detect_anomaly( %{$request}, %{$post});
       };
#
# return hash with anomalies found
#
#

sub detect_anomaly {
    my %req_params =  validate(@_, { algo => {type => SCALAR, regex => qr/^apd|spd$/i},
                                     data => {type => SCALAR,  optional => 1},
				     src_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
			      src_hub	 => {type => SCALAR, regex => qr/^\w+$/i,   optional => 1}, 
                              dst_hub	 => {type => SCALAR, regex => qr/^\w+$/i,    optional => 1}, 
                              dst_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		              start	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
		              end	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      timeout	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
				     data_type   => {type => SCALAR, regex => qr/^owamp|bwctl$/i},
				     sensitivity => {type => SCALAR, regex => qr/^[\.\d]+$/i, default => 2,  optional => 1},
				     elevation1  => {type => SCALAR, regex => qr/^[\.\d]+$/i, default => .2, optional => 1},
				     elevation2  => {type => SCALAR, regex => qr/^[\.\d]+$/i, default => .4, optional => 1},
				     swc         => {type => SCALAR, regex => qr/^\d+$/i,     default => 20, optional => 1},
				   });
    my $data = {};
    if($req_params{data}) {
        $data  = decode_json $req_params{data};
    } else {
       my %request = map { $_ => $req_params{$_}} grep($req_params{$_},  @DATA_ARGS);
       my $drs =  Ecenter::DRS::DataClient->new({%request, url => config->{drs_url}});
       $data =  $drs->get_data;
    }
    $req_params{data} = $data;
    unless($data && ref $data eq ref {} && %{$data}) {
            return error "Data is not supplied or supplied but empty or  malformed";
    }
    my $ads = Ecenter::ADS::Detector::APD->new({ data => $data, %req_params });
    my $results = {};
    eval {
         $ads->process_data();
    };
    if(!$ads->results || $EVAL_ERROR) {
       error "ADS failed with: $EVAL_ERROR";
    }
    return $ads->results;
}

true;
