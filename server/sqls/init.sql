CREATE DATABASE arpg CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `arpg`.`player` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(128) NULL,
  `account` VARCHAR(32) NOT NULL,
  `password` VARCHAR(32) NOT NULL ,
  `x` FLOAT NULL DEFAULT '0',
  `y` FLOAT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`account`)) 
  
CREATE TABLE `arpg`.`mission` (
  `id` INT NOT NULL,
  `account` VARCHAR(32) NOT NULL ,
  `status` INT NOT NULL DEFAULT '0' COMMENT 'status.Notyet = 0\nstatus.Doing = 1\nstatus.Reward = 2\nstatus.Finish = 3\nstatus.Cancle = 4',
  PRIMARY KEY (`id`, `account`));
