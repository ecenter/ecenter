--
--   Schema for  ECenter data
--
--    author: Maxim Grigoriev, 2010, maxim_at_fnal_dot_gov
--
--
drop  database if exists ecenter;
create database ecenter;
grant all privileges on ecenter.* to ecenter@localhost identified by 'ecenter2010';
grant select on ecenter.* to www@localhost identified by 'www_user';
use ecenter;
--
--   nodes - all of them
--
drop  table if exists node;
CREATE TABLE  node (
 ip_addr  varchar(40)  NOT NULL,
 nodename varchar(255)  NULL,
 PRIMARY KEY  (ip_addr)
 )  ENGINE=InnoDB CHARSET=latin1  COMMENT='nodes';


--
--    list of keywords, stores most recent regexp used to obtain that keyword as well
--
drop  table if exists keyword;
CREATE TABLE  keyword (
 keyword  varchar(255) NOT NULL,
 pattern  varchar(255)  NULL
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
 FOREIGN KEY fk_evnt_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
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
FOREIGN KEY fk_kws_keyword (keyword) REFERENCES keyword  (keyword) on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY fk_kws_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
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
src_ip  varchar(40) NOT NULL,
rtr_ip  varchar(40) NULL,
dst_ip  varchar(40) NULL,
capacity  bigint  unsigned   NULL,
service bigint  unsigned  NOT NULL,
subject varchar(1023) NOT NULL,
parameters varchar(1023) NULL,
PRIMARY KEY  (metadata),
KEY  (metaid),
UNIQUE KEY metaid_service (metaid, service, src, dst),
FOREIGN KEY fk_md_src_ip (src_ip) REFERENCES  node (ip_addr),
FOREIGN KEY fk_md_dst_ip (dst_ip) REFERENCES  node (ip_addr)
FOREIGN KEY fk_md_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
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
metadata  varchar(255) NOT NULL,
param    varchar(255) NOT NULL,
value   float NOT NULL, 
PRIMARY KEY  (data),
KEY  (param),
FOREIGN KEY fk_dat_meta (metadata) REFERENCES  metadata (metadata)  on DELETE CASCADE ON UPDATE CASCADE
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
 iqrIpd float  NOT NULL DEFAULT '0.0'
 lossPercent  float NOT NULL DEFAULT '0.0',
 PRIMARY KEY (pinger_data), 
 KEY (timestamp),
 INDEX (meanRtt, medianRtt, lossPercent, meanIpd, clp),
 FOREIGN KEY fk_ping_meta (metadata) references metadata (metadata)
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
   FOREIGN KEY fk_bwctl_meta (metadata) REFERENCES  metadata (metadata)
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
   FOREIGN KEY fk_owamp_meta (metadata) REFERENCES  metadata (metadata)
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
   FOREIGN KEY fk_snmp_meta (metadata) REFERENCES  metadata (metadata)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps snmp data  cache';
--
--  traceroute data table - update only timestamp if nothing changed ( delay < 10% )
--
--
--
drop table if exists  traceroute_data;
create table traceroute_data (
trace_id SERIAL,
src_ip varchar(40) NOT NULL,
number_hops tinyint(3) NOT NULL DEFAULT '1', 
delay float NOT NULL DEFAULT '0.0', 
dst_ip varchar(40) NOT NULL, 
created bigint(20) unsigned NOT NULL, 
updated bigint(20) unsigned NOT NULL, 
PRIMARY KEY (trace_id),
KEY (created, updated),
FOREIGN KEY fk_trace_src (src_ip) REFERENCES  node (ip_addr),
FOREIGN KEY fk_trace_dst (dst_ip) REFERENCES  node (ip_addr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps traceroute';
--
--  per hop info
--
--
--
drop table if exists hops;
create table hops (
hop_id SERIAL,
trace_id bigint unsigned NOT NULL,
hop_ip varchar(40) NOT NULL,
hop_num tinyint(3) NOT NULL DEFAULT '1', 
hop_delay  float NOT NULL DEFAULT '0.0', 
PRIMARY KEY (hop_id), 
FOREIGN KEY CONSTRAINT fk_hop_tr (trace_id) REFERENCES traceroute(trace_id),
FOREIGN KEY fk_hop_ip (hop_ip) REFERENCES  node (ip_addr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ps-ps traceroute hops';
