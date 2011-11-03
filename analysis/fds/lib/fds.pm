package fds;
use Dancer ':syntax';

use Dancer::Plugin::REST;
our $VERSION = '1.1';
use English qw( -no_match_vars );
use Data::Dumper;
use lib "/home/netadmin/ecenter_git/ecenter/analysis";
use Ecenter::Exception;
use Ecenter::DRS::DataClient;
use Ecenter::ADS::Detector::FFF;
use Ecenter::Utils;

use POSIX qw(strftime);
use Params::Validate qw(:all);
use Dancer::Logger;
use Dancer::Plugin::DBIC qw(schema);
use Dancer::Plugin::Database;

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
my @DATA_ARGS = ('src_hub', 'dst_hub','src_ip','dst_ip','start','end','data_type', 'future_points', 'resolution', 'timeout');

##  status URL
any ['get'] =>  "/fds/status.:format" =>
       sub {
            return  { status => 'ok' }
       };
##  FDS service - normal query - will get data from the DRS
get  "/fds.:format" => 
       sub {
	       return  forecast(params('query'));
       };
##  FDS service, too much data, need to POST
post "/fds.:format" => 
       sub {   my $request = params;
               my $post = params('body');
               debug "POST::::" . Dumper  $request;
	       delete $request->{format} 
                   if exists $request->{format};
	       return  forecast( %{$request}, %{$post});
       };
#
# return forecasted values
#
#

sub  forecast {
    my %req_params =  validate(@_, {  
                                     data => {type => SCALAR,  optional => 1},
				     src_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
			      src_hub	 => {type => SCALAR, regex => qr/^\w+$/i,   optional => 1}, 
                              dst_hub	 => {type => SCALAR, regex => qr/^\w+$/i,    optional => 1}, 
                              dst_ip	 => {type => SCALAR, regex => $REG_IP,   optional => 1}, 
		              start	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
		              end	 => {type => SCALAR, regex => $REG_DATE, optional => 1},
			      future_points => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      resolution => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      timeout	 => {type => SCALAR, regex => qr/^\d+$/, optional => 1},
			      data_type  => {type => SCALAR, regex => qr/^snmp|bwctl|owamp$/i},
			      
				});
    my $data = {};
    my $drs;
    if($req_params{data}) {
        $data  = decode_json $req_params{data};
    } else {
        my %request = map { $_ => $req_params{$_}} grep($req_params{$_},  @DATA_ARGS); 
	eval {
            $drs =  Ecenter::DRS::DataClient->new({%request, url => config->{drs_url}, data_type => $req_params{data_type}});
            $data =  $drs->get_data;
	};
	if(!($data && ref $data eq ref {} && %{$data}) || $EVAL_ERROR) {
            $logger->error("Remote call to DRS  failed with: $EVAL_ERROR or/and there ws no data returned");
	    return { status => 'error', error => "Remote call to DRS  failed with: $EVAL_ERROR"};
        }
    }
    $req_params{data} = $data;
    unless($data && ref $data eq ref {} && %{$data}) {
            $logger->error("Data is not supplied or supplied but empty or  malformed"); 
            return { status => 'error', error => "Data is not supplied or supplied but empty or  malformed"};
    }
    map {delete $req_params{$_} if $req_params{$_} } qw/start end/;
   
    my $fds = Ecenter::ADS::Detector::FFF->new({ data => $data, %req_params, g_client => get_gearman(config->{gearman}{servers}) });
    my $results = {};
    eval {
         $fds->process_data();
    };
    if(!$fds->results || $EVAL_ERROR) {
       $logger->error("Forecasting failed with: $EVAL_ERROR");
       return { status => 'failed', error => $EVAL_ERROR};
    }
    return $fds->results;
}

true;
