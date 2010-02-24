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
--  operational table for the most recent status of the hls
--
drop  table if exists hls;
CREATE TABLE   hls (
 hls  bigint AUTO_INCREMENT NOT NULL, 
 name varchar(255) NOT NULL,
 keyword   varchar(255)   NOT NULL,
 url varchar(255) NOT NULL,
 type varchar(5) NOT NULL DEFAULT 'hLS',
 comments  varchar(255) NULL,
 is_alive boolean,
 updated   DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
 PRIMARY KEY  (hLS),
 KEY url (url), 
 KEY is_alive (is_alive),
 FOREIGN KEY fk_key_hls (keyword) REFERENCES keyword (keyword) 
 ) ENGINE=InnoDB CHARSET=utf8 COMMENT='hls operational table';

