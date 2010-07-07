#!/usr/bin/perl
use Dancer;
use Ecenter::Utils;
use Ecenter::Data::Snmp;
use Ecenter::Data::PingER;
use Plugin::DBIx;
use Data::Dumper;

set serializer => 'JSON';
set content_type =>  'application/json';


any ['get', 'post'] =>  '/data/:type' => 
    sub {
        my $service = dbix->resultset('Service')->find({ id => params->{id} }); 
        return {params->{type} => {src_ip => params('query')->{src_ip}, 
	                           dst_ip =>  params('query')->{dst_ip}}};
    };
{
  my %map2sql = ( id => 'service', 
                  ip => 'ip_addr.ip_noted',
                  url => 'url', 
		  name => 'name',
	       );
  foreach my $route (keys %map2sql) {    
    any ['get', 'post'] =>  "/service/$route/:".$route => 
        sub {
	    my @services=();
	    
            if( params->{$route} ) {
               	warning "$map2sql{$route} =>  " .  params->{$route}; 
                my @rows =   dbix->resultset('Service')->search({  $map2sql{$route} =>  params->{$route}},
		                                            {  join => 'ip_addr', 
							       '+columns' => ['ip_addr.ip_noted']}
							    ); 
		
		foreach my $row (@rows) {
		    my %row_h = $row->get_columns;
		    delete $row_h{ip_addr};
		    push @services, \%row_h;
		}
		warning  Dumper(\@services);
		 
             }
	     return   \@services;
    };
  }
}
dance;
