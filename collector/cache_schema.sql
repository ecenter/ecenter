--
--   Schema for  ECenter data
--
--    author: Maxim Grigoriev, 2010, maxim_at_fnal_dot_gov
--
--
drop  database if exists ecenter_test;
create database ecenter_test;
grant all privileges on ecenter_test.* to ecenter@localhost identified by 'ecenter2010';
grant select on ecenter_test.* to www@localhost identified by 'www_user';
flush privileges;
use ecenter_test;

--
--  topology hub ( something with coordinates, name )
--
--
drop table if exists hub;
CREATE TABLE  hub (
hub  varchar(32) NOT NULL,
hub_name  varchar(32) NOT NULL,
description varchar(100)   NOT NULL,
longitude float NULL,
latitude float NULL,
PRIMARY KEY  (hub)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='topology hub (esnet)';

--
--  topology layer2 info
--
--
drop table if exists l2_port;
CREATE TABLE  l2_port (
l2_urn varchar(512)   NOT NULL,
description varchar(100)   NOT NULL,
capacity   bigint  unsigned   NOT NULL,   
hub varchar(32) NOT NULL,
PRIMARY KEY  (l2_urn ),
FOREIGN KEY ( hub ) REFERENCES hub ( hub )  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps topology layer2 info';
--
--  topology layer2 linkage
--
--
drop table if exists l2_link;
CREATE TABLE  l2_link (
l2_link  bigint  unsigned AUTO_INCREMENT  NOT NULL,   
l2_src_urn varchar(512)   NOT NULL,   
l2_dst_urn varchar(512)   NOT NULL,   
PRIMARY KEY  (l2_link),
FOREIGN KEY ( l2_src_urn ) REFERENCES l2_port ( l2_urn)  on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( l2_dst_urn ) REFERENCES l2_port ( l2_urn )  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps topology layer2  links';
--
--   nodes - all of them
--   ip_addr supports   ipv4 and ipv6 addresses in binary form
--    
--    it holds topology info as well via layer2 id ( as http://ogf.org/schema/network/topology/base/20070828/ schema describes)
--
--    it set as INET6_PTON('131.225.1.1') and essentially a 16 byte representation of the IP
--    it allows indexing and netblock search, to get original IP address - INET6_NTOP(ip_addr)
--    to see dotted form of ipv4 or ipv6 - select ip_noted
--    
--
drop  table if exists node;
CREATE TABLE  node (
 ip_addr  varbinary(16)  NOT NULL,
 nodename  varchar(255)  NULL,
 ip_noted  varchar(40)  NOT NULL,
 netmask  smallint(3) NOT NULL default '24',
 PRIMARY KEY  (ip_addr),
 KEY (nodename),
 KEY (ip_noted),
 KEY (netmask)
)  ENGINE=InnoDB CHARSET=latin1  COMMENT='nodes';
--
--  topology layer3 mapping to layer2, 
--  use netmask from the node table to get all addresses from the block
--
--
drop table if exists l2_l3_map;
CREATE TABLE  l2_l3_map (
l2_l3_map  bigint  unsigned AUTO_INCREMENT  NOT NULL,
ip_addr   varbinary(16)  NOT NULL,
l2_urn    varchar(512)    NOT NULL,  
PRIMARY KEY  (l2_l3_map),
FOREIGN KEY (l2_urn) REFERENCES l2_port ( l2_urn )  on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY ( ip_addr ) REFERENCES node ( ip_addr )  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps topology layer2-layer3 mapping';

--
--    list of keywords, stores most recent regexp used to obtain that keyword as well
--
drop  table if exists keyword;
CREATE TABLE  keyword (
 keyword  varchar(255) NOT NULL,
 pattern  varchar(255)  NULL,
 PRIMARY KEY  (keyword)
 )  ENGINE=InnoDB CHARSET=latin1  COMMENT='project keywords';
--
--  operational table for the most recent status of the service
--  all services are here
--
drop  table if exists service;
CREATE TABLE   service (
 service  bigint  unsigned AUTO_INCREMENT NOT NULL, 
 name varchar(255) NOT NULL,
 ip_addr varbinary(16) NOT NULL,
 url varchar(255) NOT NULL,
 comments  varchar(255) NULL,
 is_alive boolean,
 created  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated  TIMESTAMP NOT NULL DEFAULT 0,
 PRIMARY KEY  (service),
 UNIQUE KEY url (url), 
 KEY is_alive (is_alive),
 FOREIGN KEY (ip_addr) REFERENCES  node (ip_addr)
 ) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps services operational table';
--
--    list of eventtypes, metadata will refere to the ref_id here, not the SERVICE !
--
drop  table if exists eventtype;
CREATE TABLE   eventtype  (
 ref_id   bigint  unsigned AUTO_INCREMENT NOT NULL, 
 eventtype  varchar(255)  NULL, 
 service bigint unsigned  NOT NULL,
 service_type  varchar(32) NOT NULL DEFAULT 'hLS',
 PRIMARY KEY  (ref_id),
 UNIQUE KEY eventtype_service_type (eventtype, service, service_type), 
 FOREIGN KEY  (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
 )  ENGINE=InnoDB CHARSET=latin1 COMMENT='project keywords';
--
--  keywords_service for  many - many rel
--  
--
drop table if exists keywords_service;
CREATE TABLE keywords_service (
ref_id bigint  unsigned AUTO_INCREMENT NOT NULL, 
keyword varchar(255) NOT NULL,
service bigint  unsigned NOT NULL, 
PRIMARY KEY  (ref_id),
UNIQUE KEY key_service (keyword, service), 
FOREIGN KEY (keyword) REFERENCES keyword  (keyword) on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB CHARSET=latin1  COMMENT='many to many for keywords_services';
--
--  metadata for the service 
--  keeping XML in the subject and parameters but extracting end-to-end data 
--
--   src - source or interface address depending on type of the service
--   dst - destination address
--   rtr - router address in caseof snmp 
--    
--
drop  table if exists  metadata;
CREATE TABLE   metadata (
metaid  bigint  unsigned AUTO_INCREMENT NOT NULL,
src_ip  varbinary(16)  NOT NULL,
dst_ip  varbinary(16)  NOT  NULL DEFAULT '0',
direction   enum('in','out') NOT NULL default 'in', 
eventtype_id  bigint  unsigned  NOT NULL,
subject varchar(1023) NOT NULL  DEFAULT '',
parameters varchar(1023) NULL,
PRIMARY KEY  (metaid),
KEY  (metaid),
UNIQUE KEY md_ips_type (src_ip, dst_ip, eventtype_id), 
FOREIGN KEY (src_ip) REFERENCES  node (ip_addr)  on DELETE CASCADE ON UPDATE CASCADE, 
FOREIGN KEY (eventtype_id) REFERENCES  eventtype(ref_id)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps metaid provided by each service-eventtype';
--
--  NEXT TABLES FOR THE  DATA CACHE
--  we are going to store pinger, owamp, bwctl, snmp data
--  based on source -> destination pairs
--
--    generic data table - all non-identified data can go here
--
--
drop  table if exists  data;
CREATE TABLE   data (
data  bigint  unsigned AUTO_INCREMENT NOT NULL, 
metaid bigint  unsigned  NOT NULL,
param     varchar(255) NOT NULL,
value   float NOT NULL, 
PRIMARY KEY  (data),
KEY  (param),
FOREIGN KEY  (metaid) REFERENCES  metadata (metaid)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  data  cache';
--
--    pinger data storage   
--
--
drop  table if exists  pinger_data;
CREATE TABLE   pinger_data  (
 pinger_data bigint  unsigned AUTO_INCREMENT NOT NULL, 
 metaid   BIGINT  unsigned   NOT NULL,
 minRtt float  NOT NULL DEFAULT  '0.0',
 meanRtt float NOT NULL DEFAULT  '0.0',
 medianRtt float NOT NULL DEFAULT  '0.0',
 maxRtt float NOT NULL DEFAULT  '0.0',
 timestamp   bigint(12) unsigned NOT NULL,
 minIpd float  NOT NULL DEFAULT  '0.0',
 meanIpd float NOT NULL DEFAULT  '0.0',
 maxIpd float NOT NULL DEFAULT  '0.0',
 duplicates tinyint(1) NOT NULL DEFAULT '0',
 outOfOrder  tinyint(1) NOT NULL DEFAULT '0',
 clp float NOT NULL DEFAULT '0.0',
 iqrIpd float  NOT NULL DEFAULT '0.0',
 lossPercent  float NOT NULL DEFAULT '0.0',
 PRIMARY KEY (pinger_data), 
 KEY (timestamp),
 INDEX (meanRtt, medianRtt, lossPercent, meanIpd, clp),
 UNIQUE KEY meta_time (metaid, timestamp),
 FOREIGN KEY (metaid) references  metadata  (metaid) on DELETE CASCADE ON UPDATE CASCADE
 ) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  pinger data  cache';
--
--    BWCTL data  storage 
--
--
--
drop  table if exists  bwctl_data;
CREATE TABLE  bwctl_data (
   bwctl_data  bigint  unsigned AUTO_INCREMENT NOT NULL, 
   metaid    BIGINT  unsigned NOT NULL,
   timestamp   bigint(12) unsigned NOT NULL,
   throughput  float default NULL,
   PRIMARY KEY  (bwctl_data),
   KEY (timestamp), 
   UNIQUE KEY meta_time (metaid, timestamp),
   FOREIGN KEY (metaid) REFERENCES   metadata  (metaid) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps  bwctl data  cache';
--
--            OWAMP data  storage 
--
--
drop  table if exists owamp_data;
CREATE TABLE  owamp_data (
   owamp_data  bigint unsigned AUTO_INCREMENT NOT NULL, 
   metaid   BIGINT  unsigned  NOT NULL,
   timestamp  bigint(12) unsigned NOT NULL,
   min_delay float  NOT NULL DEFAULT  '0.0',
   max_delay float  NOT NULL DEFAULT  '0.0',
   sent   int unsigned NOT NULL DEFAULT  '0',
   loss   int unsigned NOT NULL DEFAULT  '0',
   duplicates   int unsigned NOT NULL DEFAULT  '0',
   PRIMARY KEY  (owamp_data),
   KEY  (timestamp),
   UNIQUE KEY meta_time (metaid, timestamp),
   FOREIGN KEY  (metaid) REFERENCES   metadata  (metaid) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps  owamp  data  cache';
--
--            SNMP data  storage 
--            knows about layer2 topologies
--
drop  table if exists snmp_data;
CREATE TABLE  snmp_data (
   snmp_data  bigint unsigned AUTO_INCREMENT NOT NULL, 
   metaid   BIGINT  unsigned  NOT NULL,
   timestamp  bigint(12) unsigned NOT NULL,
   utilization float  NOT NULL DEFAULT  '0.0',
   errors int unsigned NOT NULL DEFAULT  '0',
   drops int unsigned  NOT NULL DEFAULT  '0',
   PRIMARY KEY  (snmp_data),
   KEY  (timestamp),\
   UNIQUE KEY meta_time (metaid, timestamp),
   FOREIGN KEY (metaid) REFERENCES metadata (metaid) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps snmp data  cache';
--
--  traceroute data table - update only timestamp if nothing changed ( delay < 10% )
--
--
--
drop table if exists  traceroute_data;
CREATE TABLE traceroute_data (
trace_id   bigint  unsigned AUTO_INCREMENT NOT NULL,
metaid   BIGINT  unsigned  NOT NULL,
number_hops tinyint(3) NOT NULL DEFAULT '1', 
updated bigint(12) unsigned NOT NULL, 
PRIMARY KEY (trace_id), 
UNIQUE KEY updated_metaid (metaid, updated),
FOREIGN KEY (metaid) references  metadata (metaid) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps traceroute';
--
--  per hop info
--
--
--
drop table if exists hop;
CREATE TABLE hop (
hop_id  bigint  unsigned AUTO_INCREMENT  NOT NULL,
trace_id bigint unsigned NOT NULL,
hop_ip  varbinary(16) NOT NULL,
hop_num tinyint(3) NOT NULL DEFAULT '1', 
hop_delay  float NOT NULL DEFAULT '0.0', 
PRIMARY KEY (hop_id), 
FOREIGN KEY (trace_id) REFERENCES traceroute_data(trace_id)  on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (hop_ip) REFERENCES  node(ip_addr)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps traceroute hops';
