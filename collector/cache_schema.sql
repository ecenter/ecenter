--
--   Scheme for caching periodically pulled data
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
 ip_addr  varchar(15)  NOT NULL,
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
 service  bigint AUTO_INCREMENT NOT NULL, 
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
 ref_id   bigint AUTO_INCREMENT NOT NULL, 
 eventtype  varchar(255)  NULL, 
 service bigint NOT NULL, 
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
ref_id bigint AUTO_INCREMENT NOT NULL, 
keyword varchar(255) NOT NULL,
service bigint NOT NULL, 
PRIMARY KEY  (ref_id),
UNIQUE KEY key_service (keyword, service), 
FOREIGN KEY fk_kws_keyword (keyword) REFERENCES keyword  (keyword) on DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY fk_kws_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB CHARSET=latin1  COMMENT='many to many for keywords_services';
--
--  metadata for the service 
--  keeping XML in the subject and parameters but extracting end-to-end data 
--
drop  table if exists metadata;
CREATE TABLE   metadata (
metadata  bigint AUTO_INCREMENT NOT NULL, 
metaid  varchar(255) NOT NULL,
src  varchar(15) NOT NULL,
dst  varchar(15) NOT NULL,
service bigint  NOT NULL,
subject varchar(1023) NOT NULL,
parameters varchar(1023) NULL,
PRIMARY KEY  (metadata),
KEY  (metaid),
UNIQUE KEY metaid_service (metaid, service),
FOREIGN KEY fk_md_src (src) REFERENCES  node (ip_addr),
FOREIGN KEY fk_md_dst (dst) REFERENCES  node (ip_addr),
FOREIGN KEY fk_md_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps metadata provided by each service';
--
--  NEXT TABLES FOR THE 1 WEEK DATA CACHE
--  we are going to store pinger, owamp, bwctl, snmp data
--  based on source -> destination pairs
--
--    generic data table - all non-identified data can go here
--
--
drop  table if exists  data;
CREATE TABLE   data (
data  bigint AUTO_INCREMENT NOT NULL, 
metadata  varchar(255) NOT NULL,
param    varchar(255) NOT NULL,
value   float NOT NULL, 
PRIMARY KEY  (data),
KEY  (param),
FOREIGN KEY fk_dat_metad (metadata) REFERENCES  metadata (metadata)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  data  cache - 1 week';
--
--    pinger data storage   
--
--
drop  table if exists  pinger_data;
CREATE TABLE   pinger_data  (
 pinger_data bigint AUTO_INCREMENT NOT NULL, 
 metadata   BIGINT   NOT NULL,
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
 iqrIpd float, NOT NULL DEFAULT '0.0'
 lossPercent  float NOT NULL DEFAULT '0.0',
 PRIMARY KEY (pinger_data), 
 KEY (timestamp),
 INDEX (meanRtt, medianRtt, lossPercent, meanIpd, clp),
 FOREIGN KEY (metadata) references metadata (metadata)
 ) ENGINE=InnoDB CHARSET=latin1 COMMENT='ps-ps  pinger data  cache - 1 week';
--
--    BWCTL data  storage 
--
--
--
drop  table if exists  bwctl_data;
CREATE TABLE  bwctl_data (
   bwctl_data  bigint AUTO_INCREMENT NOT NULL, 
   metadata   BIGINT   NOT NULL,
   timestamp   bigint(20) unsigned NOT NULL,
   send_ip     varchar(15) NOT NULL,
   recv_ip    varchar(15) NOT NULL,
   throughput         float default NULL,
   jitter      float default NULL,
   lost  bigint(20) unsigned default NULL,
   sent  bigint(20) unsigned default NULL,
  PRIMARY KEY  (bwctl_data),
  FOREIGN KEY fk_bwctl_dat_send_ip (send_ip) REFERENCES  node  (ip_addr),
  FOREIGN KEY fk_bwctl_dat_recv_ip (recv_ip) REFERENCES  node  (ip_addr),
  FOREIGN KEY fk_bwctl_meta (metadata) REFERENCES  metadata (metadata)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='ps-ps  bwctl data  cache - 1 week';
--
--            OWAMP data  storage 
--
--
drop  table if exists owamp_data;
CREATE TABLE  owamp_data (
   owamp_data  bigint AUTO_INCREMENT NOT NULL, 
   metadata   BIGINT   NOT NULL,
   stimestamp  bigint(20) unsigned NOT NULL,
   etimestamp  bigint(20) unsigned NOT NULL,
   send_ip     varchar(15) NOT NULL,
   recv_ip     varchar(15) NOT NULL,  
   min float   NOT NULL DEFAULT  '0.0',
   max float  NOT NULL DEFAULT  '0.0',
   minttl tinyint(3) unsigned NOT NULL DEFAULT  '0',
   maxttl tinyint(3) unsigned NOT NULL DEFAULT  '0',
   sent   bigint(20) unsigned NOT NULL DEFAULT  '0',
   lost   bigint(20) unsigned NOT NULL DEFAULT  '0',
   dups   bigint(20) unsigned NOT NULL DEFAULT  '0',
   maxerr float  NOT NULL DEFAULT  '0.0',
  PRIMARY KEY  (owamp_data),
  FOREIGN KEY fk_owamp_dat_send_ip (send_ip) REFERENCES  node  (ip_addr),
  FOREIGN KEY fk_owamp_dat_recv_ip (recv_ip) REFERENCES  node  (ip_addr),
  FOREIGN KEY fk_owamp_meta (metadata) REFERENCES  metadata (metadata)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='ps-ps  bwctl data  cache - 1 week';

