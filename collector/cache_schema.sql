--
--   Scheme for caching periodically pulled data
--
--
drop  database if exists ecenter;
create database ecenter;
grant all privileges on ecenter.* to ecenter@localhost identified by 'ecenter2010';
grant select on ecenter.* to www@localhost identified by 'www_user';
use ecenter;
--
--    list of keywords, stores most recent regexp used to obtain that keyword as well
--
drop  table if exists keyword;
CREATE TABLE  keyword (
 keyword  varchar(255) NOT NULL,
 pattern  varchar(255)  NULL, 
 created   DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
 PRIMARY KEY  (keyword),
 KEY created  (created)
 )  ENGINE=InnoDB CHARSET=utf8 COMMENT='project keywords';
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
 updated   DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
 PRIMARY KEY  (service),
 UNIQUE KEY url (url), 
 KEY is_alive (is_alive)
 ) ENGINE=InnoDB CHARSET=utf8 COMMENT='ps-ps services operational table';
--
--    list of eventtypes
--
drop  table if exists eventtype;
CREATE TABLE   eventtype  (
 ref_id   bigint AUTO_INCREMENT NOT NULL, 
 eventtype  varchar(255)  NULL, 
 service bigint NOT NULL, 
 PRIMARY KEY  (ref_id),
 UNIQUE KEY key_service (eventtype, service), 
 FOREIGN KEY fk_evnt_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
 )  ENGINE=InnoDB CHARSET=utf8 COMMENT='project keywords';
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
)ENGINE=InnoDB CHARSET=utf8 COMMENT='many to many for keywords_services';
--
--  metadata for the service 
--  
--
drop  table if exists metadata;
CREATE TABLE   metadata (
metadata  bigint AUTO_INCREMENT NOT NULL, 
metaid  varchar(255) NOT NULL,
service bigint  NOT NULL,
subject varchar(1023) NOT NULL,
parameters varchar(1023) NULL,
PRIMARY KEY  (metadata),
KEY  (metaid),
FOREIGN KEY fk_md_svc (service) REFERENCES  service (service)  on DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB CHARSET=utf8 COMMENT='ps-ps metadata provided by each service';
