
DROP TABLE IF EXISTS `mqtt_message`;

CREATE TABLE mqtt_message (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  id_packet varchar(100) NOT NULL ,
  pktid int(10) DEFAULT NULL,
  _from varchar(60) DEFAULT NULL COMMENT 'IpAddress',
  topic varchar(100) DEFAULT NULL COMMENT 'Username',
  qos int(1) DEFAULT NULL COMMENT '0,1,2',
  flags VARCHAR(10) DEFAULT FALSE COMMENT '[retain | dup | sys]',
  retain BOOLEAN DEFAULT FALSE ,
  dup BOOLEAN DEFAULT FALSE ,
  sys BOOLEAN DEFAULT false,
  headers VARCHAR(100),
  payload VARCHAR(100),
  _timestamp VARCHAR(60),
  PRIMARY KEY (id)
) ENGINE=RocksDB DEFAULT CHARSET=utf8;

