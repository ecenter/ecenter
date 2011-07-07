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
use Dancer::Plugin::DBIC qw(schema);
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
    my $ads = Ecenter::ADS::Detector::APD->new({ data => $data, %req_params });
    my $results = {};
    eval {
         $ads->process_data();
    };
    if(!$ads->results || $EVAL_ERROR) {
       error "ADS failed with: $EVAL_ERROR";
    }else {
        my $anomalies = $ads->results;
        foreach my  $src_ip (keys %{$anomalies}) {
            foreach my $dst_ip (keys %{$anomalies->{$src_ip}}) {
	        next if ref $anomalies->{$src_ip}{$dst_ip}{status} eq ref 'ok' && 
		        $anomalies->{$src_ip}{$dst_ip}{status} eq 'ok';
	        my $anomaly = schema('dbix')->resultset('Anomaly')->find_or_create({ metaid     =>  $anomalies->{$src_ip}{$dst_ip}{metaid},
		                                                                     elevation1 =>  $anomalies->{$src_ip}{$dst_ip}{elevation1},
									             elevation2 =>  $anomalies->{$src_ip}{$dst_ip}{elevation2},
									             swc    =>  $anomalies->{$src_ip}{$dst_ip}{swc},
									             algo  => $req_params{algo},
									             start_time   =>   $ads->start,
									             end_time	 =>   $ads->end,
										     resolution =>  $drs->resolution
										   },
									           {key => 'metaid_algo_when'});
		foreach my $type (qw/warning critical/) {								
		    foreach my $time (sort {$a <=> $b} keys %{$anomalies->{$src_ip}{$dst_ip}{$type}} ) {
		        my $data_table = strftime "%Y%m", localtime($time);
		        schema('dbix')->resultset("AnomalyData$data_table")
			                  ->find_or_create({anomaly        => $anomaly, 
					                    anomaly_status => $type,
							    anomaly_type   => $anomalies->{$src_ip}{$dst_ip}{$type}{$time}{anomaly_type},
							    timestamp      => $time,
							    value          => $anomalies->{$src_ip}{$dst_ip}{$type}{$time}{value},
							   },
							   { key => 'anomaly_time'} );
		    }
		}								    
            }
        }
    }
    return $ads->results;
}

true;
