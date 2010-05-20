--
--   Schema for  ECenter data
--
--    author: Maxim Grigoriev, 2010, maxim_at_fnal_dot_gov
--
--
drop  database if exists ecenter_data;
create database ecenter_data;
grant all privileges on ecenter_data.* to ecenter@localhost identified by 'ecenter2010';
grant select on ecenter_data.* to www@localhost identified by 'www_user';
flush privileges;
use ecenter_data;
--
--   nodes - all of them
--   ip_addr supports   ipv4 addresses in ATON format ( 32bit integer )
--    
--
--    it set as INET_ATON('131.225.1.1') and essentially a 32bit representation of the IP
--    it allows indexing and netblock search, to get original IP address - INET_NTOA(2322324344)
--
drop  table if exists node;
CREATE TABLE  node (
 ip_addr  int unsigned  NOT NULL,
 nodename varchar(255)  NULL,
 ipv4_dot  varchar(15)  NOT NULL, 
 PRIMARY KEY  (ip_addr),
 KEY (nodename),
 KEY (ipv4_dot)
 )  ENGINE=InnoDB CHARSET=latin1  COMMENT='nodes';


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
 url varchar(255) NOT NULL,
 type varchar(32) NOT NULL DEFAULT 'hLS',
 comments  varchar(255) NULL, 
 is_alive boolean,
 created   DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
 updated   DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
 PRIMARY KEY  (service),
 UNIQUE KEY url (url), 
 KEY is_alive (is_alive)
 ) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps services operational table';
--
--    list of eventtypes
--
drop  table if exists eventtype;
CREATE TABLE   eventtype  (
 ref_id   bigint  unsigned AUTO_INCREMENT NOT NULL, 
 eventtype  varchar(255)  NULL, 
 service bigint unsigned  NOT NULL, 
 PRIMARY KEY  (ref_id),
 UNIQUE KEY eventtype_service (eventtype, service), 
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
--   All addresses allow  ipv6
--
drop  table if exists metadata;
CREATE TABLE   metadata (
metadata  bigint  unsigned AUTO_INCREMENT NOT NULL, 
metaid  varchar(255) NOT NULL,
src_ip int unsigned NOT NULL,
rtr_ip int unsigned  NULL,
dst_ip int unsigned  NULL,
capacity  bigint  unsigned   NULL,
service bigint  unsigned  NOT NULL,
subject varchar(1023) NOT NULL,
parameters varchar(1023) NULL,
PRIMARY KEY  (metadata),
KEY  (metaid),
UNIQUE KEY metaid_service (metaid, service, src_ip),
FOREIGN KEY (src_ip) REFERENCES  node (ip_addr),
FOREIGN KEY (dst_ip) REFERENCES  node (ip_addr),
FOREIGN KEY (rtr_ip) REFERENCES  node (ip_addr),
FOREIGN KEY (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps metadata provided by each service';
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
metadata  bigint  unsigned  NOT NULL,
param     varchar(255) NOT NULL,
value   float NOT NULL, 
PRIMARY KEY  (data),
KEY  (param),
FOREIGN KEY  (metadata) REFERENCES  metadata (metadata)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  data  cache';
--
--    pinger data storage   
--
--
drop  table if exists  pinger_data;
CREATE TABLE   pinger_data  (
 pinger_data bigint  unsigned AUTO_INCREMENT NOT NULL, 
 metadata   BIGINT  unsigned   NOT NULL,
 minRtt float  NOT NULL DEFAULT  '0.0',
 meanRtt float NOT NULL DEFAULT  '0.0',
 medianRtt float NOT NULL DEFAULT  '0.0',
 maxRtt float NOT NULL DEFAULT  '0.0',
 timestamp   bigint(20) unsigned NOT NULL,
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
 FOREIGN KEY (metadata) references metadata (metadata) on DELETE CASCADE ON UPDATE CASCADE
 ) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  pinger data  cache';
--
--    BWCTL data  storage 
--
--
--
drop  table if exists  bwctl_data;
CREATE TABLE  bwctl_data (
   bwctl_data  bigint  unsigned AUTO_INCREMENT NOT NULL, 
   metadata    BIGINT  unsigned NOT NULL,
   timestamp   bigint(20) unsigned NOT NULL,
   throughput  float default NULL,
   jitter      float default NULL,
   lost  int unsigned default NULL,
   sent  int unsigned default NULL,
   PRIMARY KEY  (bwctl_data),
   KEY (timestamp),
   FOREIGN KEY (metadata) REFERENCES  metadata (metadata) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps  bwctl data  cache';
--
--            OWAMP data  storage 
--
--
drop  table if exists owamp_data;
CREATE TABLE  owamp_data (
   owamp_data  bigint unsigned AUTO_INCREMENT NOT NULL, 
   metadata   BIGINT  unsigned  NOT NULL,
   timestamp  bigint(20) unsigned NOT NULL,
   min float  NOT NULL DEFAULT  '0.0',
   max float  NOT NULL DEFAULT  '0.0',
   minttl tinyint(3) unsigned NOT NULL DEFAULT  '0',
   maxttl tinyint(3) unsigned NOT NULL DEFAULT  '0',
   sent   int unsigned NOT NULL DEFAULT  '0',
   lost   int unsigned NOT NULL DEFAULT  '0',
   dups   int unsigned NOT NULL DEFAULT  '0',
   maxerr float  NOT NULL DEFAULT  '0.0',
   PRIMARY KEY  (owamp_data),
   KEY  (timestamp),
   FOREIGN KEY  (metadata) REFERENCES  metadata (metadata) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps  owamp  data  cache';
--
--            SNMP data  storage 
--
--
drop  table if exists snmp_data;
CREATE TABLE  snmp_data (
   snmp_data  bigint unsigned AUTO_INCREMENT NOT NULL, 
   metadata   BIGINT  unsigned  NOT NULL,
   timestamp  bigint(20) unsigned NOT NULL,
   utilization float  NOT NULL DEFAULT  '0.0',
   errors int unsigned NOT NULL DEFAULT  '0',
   drops int unsigned  NOT NULL DEFAULT  '0',
   PRIMARY KEY  (snmp_data),
   KEY  (timestamp),
   FOREIGN KEY (metadata) REFERENCES  metadata (metadata) on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps snmp data  cache';
--
--  traceroute data table - update only timestamp if nothing changed ( delay < 10% )
--
--
--
drop table if exists  traceroute_data;
CREATE TABLE traceroute_data (
trace_id   bigint  unsigned AUTO_INCREMENT NOT NULL,
metadata   BIGINT  unsigned  NOT NULL,
number_hops tinyint(3) NOT NULL DEFAULT '1', 
delay float NOT NULL DEFAULT '0.0', 
created bigint(20) unsigned NOT NULL, 
updated bigint(20) unsigned NOT NULL, 
PRIMARY KEY (trace_id),
KEY (created, updated),
FOREIGN KEY (metadata) references metadata (metadata) on DELETE CASCADE ON UPDATE CASCADE
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
hop_ip  int unsigned NOT NULL,
hop_num tinyint(3) NOT NULL DEFAULT '1', 
hop_delay  float NOT NULL DEFAULT '0.0', 
PRIMARY KEY (hop_id), 
FOREIGN KEY (trace_id) REFERENCES traceroute_data(trace_id),
FOREIGN KEY (hop_ip) REFERENCES  node(ip_addr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps traceroute hops';
