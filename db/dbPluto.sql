CREATE DATABASE  IF NOT EXISTS `pluto` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pluto`;
-- MySQL dump 10.13  Distrib 5.7.12, for Win64 (x86_64)
--
-- Host: 172.27.87.69    Database: pluto
-- ------------------------------------------------------
-- Server version	5.5.53-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `detail`
--

DROP TABLE IF EXISTS `detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detail` (
  `DETAIL_ID` int(11) NOT NULL AUTO_INCREMENT,
  `SERVICE_ID` int(11) DEFAULT NULL,
  `PAYMENT_ID` int(11) DEFAULT NULL,
  `SUMM_NF` decimal(12,2) DEFAULT NULL COMMENT 'Summary without fee',
  PRIMARY KEY (`DETAIL_ID`),
  KEY `FK_DETAIL_SERVICE_idx` (`SERVICE_ID`),
  KEY `FK_DETAIL_PAYMENT_idx` (`PAYMENT_ID`),
  CONSTRAINT `FK_DETAIL_PAYMENT` FOREIGN KEY (`PAYMENT_ID`) REFERENCES `payment` (`PAYMENT_ID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_DETAIL_SERVICE` FOREIGN KEY (`SERVICE_ID`) REFERENCES `service` (`SERVICE_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=987236 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization`
--

DROP TABLE IF EXISTS `organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization` (
  `ORGANIZATION_ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(100) DEFAULT NULL,
  `NAME_KASPY` varchar(100) DEFAULT NULL,
  `CODE_KASPY` varchar(45) DEFAULT NULL,
  `NAME_STREAM` varchar(100) DEFAULT NULL,
  `CODE_STREAM` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ORGANIZATION_ID`),
  UNIQUE KEY `UQ_CODE_KASPY` (`CODE_KASPY`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment` (
  `PAYMENT_ID` int(11) NOT NULL AUTO_INCREMENT,
  `PAYNUMBER` int(11) DEFAULT NULL,
  `PROG` varchar(45) DEFAULT NULL COMMENT '1-Stream, 2-Kaspy',
  `ORDER_TYPE` int(11) DEFAULT NULL,
  `STORNO_FOR` int(11) DEFAULT NULL,
  `STATUS` int(11) DEFAULT NULL,
  `STATUS_TIME` datetime DEFAULT NULL,
  `ACCOUNT` varchar(20) DEFAULT NULL,
  `FIO` varchar(100) DEFAULT NULL,
  `ADDRESS` varchar(150) DEFAULT NULL,
  `ORGANIZATION_ID` int(11) DEFAULT NULL COMMENT 'Избыточное',
  `EXTERNAL_ID` varchar(25) DEFAULT NULL,
  `EXTERNAL_TIME` datetime DEFAULT NULL,
  `BACKEND_TIME` datetime DEFAULT NULL,
  `SUMM` decimal(12,2) DEFAULT NULL,
  `FEE` decimal(12,2) DEFAULT NULL,
  `PAYNODE_ID` int(11) DEFAULT NULL,
  `CASHIER` varchar(80) DEFAULT NULL,
  `REGISTRY_ID` int(11) DEFAULT NULL,
  `REGISTRY_OUT_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`PAYMENT_ID`),
  UNIQUE KEY `UQ_PAYNUMBER` (`PROG`,`PAYNUMBER`),
  KEY `FK_PAYMENT_PAYNODE_idx` (`PAYNODE_ID`),
  KEY `FK_PAYMENT_ORGANIZATION_idx` (`ORGANIZATION_ID`),
  KEY `IDX_PAYNUMBER` (`PAYNUMBER`),
  KEY `IDX_ACCOUNT` (`ACCOUNT`),
  KEY `IDX_ORGANIZATION` (`ORGANIZATION_ID`),
  KEY `IDX_EXTERNAL_ID` (`EXTERNAL_ID`),
  KEY `IDX_EXTERNAL_TIME` (`EXTERNAL_TIME`),
  KEY `IDX_BACKEND_TIME` (`BACKEND_TIME`),
  KEY `IDX_PAYNODE` (`PAYNODE_ID`),
  KEY `IDX_REGNUM` (`REGISTRY_ID`,`REGISTRY_OUT_ID`),
  KEY `IDX_STORNO_FOR` (`STORNO_FOR`),
  CONSTRAINT `FK_PAYMENT_ORGANIZATION` FOREIGN KEY (`ORGANIZATION_ID`) REFERENCES `organization` (`ORGANIZATION_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_PAYMENT_PAYNODE` FOREIGN KEY (`PAYNODE_ID`) REFERENCES `paynode` (`PAYNODE_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_PAYMENT_REGISTRY` FOREIGN KEY (`REGISTRY_ID`) REFERENCES `registry` (`REGISTRY_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=915189 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paynode`
--

DROP TABLE IF EXISTS `paynode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paynode` (
  `PAYNODE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `CODE_KASPY` int(11) DEFAULT NULL,
  `CODE_STREAM` int(11) DEFAULT NULL,
  `IS_TERMINAL` int(11) DEFAULT '0' COMMENT '0 - касса, 1 - терминал',
  `ADDRESS` varchar(150) DEFAULT NULL,
  `SHORT_ADDRESS` varchar(45) DEFAULT NULL,
  `ADDRESS_KASPY` varchar(150) DEFAULT NULL,
  `ADDRESS_STREAM` varchar(150) DEFAULT NULL,
  `UNIT` varchar(45) DEFAULT NULL,
  `MODIFIED_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CREATED_TIME` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`PAYNODE_ID`),
  UNIQUE KEY `UQ_CODE_KASPY` (`CODE_KASPY`),
  UNIQUE KEY `UQ_CODE_STREAM` (`CODE_STREAM`)
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER autoUpdate_CREATED_TIME_in_paynode BEFORE INSERT ON paynode FOR EACH ROW SET NEW.CREATED_TIME = NOW() */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `registry`
--

DROP TABLE IF EXISTS `registry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registry` (
  `REGISTRY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(45) DEFAULT NULL,
  `PROG` int(11) DEFAULT NULL COMMENT '1-stream, 2-kaspy',
  `STATUS` int(11) DEFAULT NULL COMMENT '1 - just created\n2 - loading\n3 - finished',
  `MODIFIED_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CREATED_TIME` timestamp NULL DEFAULT NULL,
  `PAYMENTS_COUNT` int(11) DEFAULT NULL,
  PRIMARY KEY (`REGISTRY_ID`),
  UNIQUE KEY `UQ_REGNAME` (`PROG`,`NAME`)
) ENGINE=InnoDB AUTO_INCREMENT=233 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER autoUpdate_CREATED_TIME_in_registry BEFORE INSERT ON registry FOR EACH ROW SET NEW.CREATED_TIME = NOW() */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service` (
  `SERVICE_ID` int(11) NOT NULL AUTO_INCREMENT,
  `ORGANIZATION_ID` int(11) DEFAULT NULL,
  `NAME_KASPY` varchar(150) DEFAULT NULL,
  `CODE_KASPY` varchar(30) DEFAULT NULL,
  `NAME_STREAM` varchar(150) DEFAULT NULL,
  `CODE_STREAM` int(11) DEFAULT NULL,
  PRIMARY KEY (`SERVICE_ID`),
  UNIQUE KEY `UQ_CODE_STREAM` (`CODE_STREAM`),
  UNIQUE KEY `UQ_CODE_KASPY` (`ORGANIZATION_ID`,`CODE_KASPY`),
  KEY `FK_SERVICE_ORGANIZATION_idx` (`ORGANIZATION_ID`),
  CONSTRAINT `FK_SERVICE_ORGANIZATION` FOREIGN KEY (`ORGANIZATION_ID`) REFERENCES `organization` (`ORGANIZATION_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1240 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_accepted_payments`
--

DROP TABLE IF EXISTS `v_accepted_payments`;
/*!50001 DROP VIEW IF EXISTS `v_accepted_payments`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_accepted_payments` AS SELECT 
 1 AS `PROG`,
 1 AS `ORGANIZATION_NAME`,
 1 AS `EXTERNAL_DATE`,
 1 AS `EXTERNAL_DAY_OF_WEEK`,
 1 AS `BACKEND_DATE`,
 1 AS `SUMM`,
 1 AS `FEE`,
 1 AS `CNT`,
 1 AS `ADDRESS`,
 1 AS `PAYNODE_TYPE`,
 1 AS `CODE_KASPY`,
 1 AS `CODE_STREAM`,
 1 AS `UNIT`,
 1 AS `CASHIER`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_forbidden_payments`
--

DROP TABLE IF EXISTS `v_forbidden_payments`;
/*!50001 DROP VIEW IF EXISTS `v_forbidden_payments`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_forbidden_payments` AS SELECT 
 1 AS `EXTERNAL_DATE`,
 1 AS `ADDRESS`,
 1 AS `CODE_KASPY`,
 1 AS `CASHIER`,
 1 AS `ORGANIZATION_NAME_STREAM`,
 1 AS `SERVICE_NAME_STREAM`,
 1 AS `SUMM`,
 1 AS `CNT`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_forbidden_services`
--

DROP TABLE IF EXISTS `v_forbidden_services`;
/*!50001 DROP VIEW IF EXISTS `v_forbidden_services`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_forbidden_services` AS SELECT 
 1 AS `SERVICE_ID`,
 1 AS `ORGANIZATION_ID`,
 1 AS `SERVICE_NAME_STREAM`,
 1 AS `ORGANIZATION_NAME_STREAM`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'pluto'
--
/*!50003 DROP FUNCTION IF EXISTS `registry_loading_allowed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `registry_loading_allowed`(_prog int, _registry_name VARCHAR(150)) RETURNS tinyint(1)
BEGIN	
	SET @status_before = (select status from registry where PROG=_prog and NAME=_registry_name);
    if (@status_before <> 1) or (@status_before is null) then
		return False;
	else
		UPDATE registry set status=2 where PROG=_prog and NAME=_registry_name;
        return True;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_accepted_payments`
--

/*!50001 DROP VIEW IF EXISTS `v_accepted_payments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`zorra`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_accepted_payments` AS select (case when (`payment`.`PROG` = 1) then 'Stream' else (case when (`payment`.`PROG` = 2) then 'Kaspy' else '' end) end) AS `PROG`,`organization`.`NAME` AS `ORGANIZATION_NAME`,cast(`payment`.`EXTERNAL_TIME` as date) AS `EXTERNAL_DATE`,dayofweek(`payment`.`EXTERNAL_TIME`) AS `EXTERNAL_DAY_OF_WEEK`,cast(`payment`.`BACKEND_TIME` as date) AS `BACKEND_DATE`,sum(`payment`.`SUMM`) AS `SUMM`,coalesce(sum(`payment`.`FEE`),0) AS `FEE`,count(0) AS `CNT`,`paynode`.`ADDRESS` AS `ADDRESS`,(case when (`paynode`.`IS_TERMINAL` = 1) then 'Терминал' else 'Касса' end) AS `PAYNODE_TYPE`,`paynode`.`CODE_KASPY` AS `CODE_KASPY`,`paynode`.`CODE_STREAM` AS `CODE_STREAM`,`paynode`.`UNIT` AS `UNIT`,`payment`.`CASHIER` AS `CASHIER` from ((`payment` left join `paynode` on((`payment`.`PAYNODE_ID` = `paynode`.`PAYNODE_ID`))) left join `organization` on((`payment`.`ORGANIZATION_ID` = `organization`.`ORGANIZATION_ID`))) group by `payment`.`PROG`,`payment`.`PAYNODE_ID`,`organization`.`NAME`,cast(`payment`.`EXTERNAL_TIME` as date),cast(`payment`.`BACKEND_TIME` as date),`payment`.`CASHIER` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_forbidden_payments`
--

/*!50001 DROP VIEW IF EXISTS `v_forbidden_payments`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`zorra`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_forbidden_payments` AS select cast(`payment`.`EXTERNAL_TIME` as date) AS `EXTERNAL_DATE`,`paynode`.`ADDRESS` AS `ADDRESS`,`paynode`.`CODE_KASPY` AS `CODE_KASPY`,`payment`.`CASHIER` AS `CASHIER`,`v_forbidden_services`.`ORGANIZATION_NAME_STREAM` AS `ORGANIZATION_NAME_STREAM`,`v_forbidden_services`.`SERVICE_NAME_STREAM` AS `SERVICE_NAME_STREAM`,sum(`payment`.`SUMM`) AS `SUMM`,count(0) AS `CNT` from (((`v_forbidden_services` left join `detail` on((`detail`.`SERVICE_ID` = `v_forbidden_services`.`SERVICE_ID`))) left join `payment` on((`detail`.`PAYMENT_ID` = `payment`.`PAYMENT_ID`))) left join `paynode` on((`payment`.`PAYNODE_ID` = `paynode`.`PAYNODE_ID`))) where ((`payment`.`EXTERNAL_TIME` >= (now() - interval 31 day)) and (`paynode`.`IS_TERMINAL` = 0)) group by cast(`payment`.`EXTERNAL_TIME` as date),`paynode`.`ADDRESS`,`payment`.`CASHIER` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_forbidden_services`
--

/*!50001 DROP VIEW IF EXISTS `v_forbidden_services`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`zorra`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_forbidden_services` AS select `service`.`SERVICE_ID` AS `SERVICE_ID`,`service`.`ORGANIZATION_ID` AS `ORGANIZATION_ID`,`service`.`NAME_STREAM` AS `SERVICE_NAME_STREAM`,`organization`.`NAME_STREAM` AS `ORGANIZATION_NAME_STREAM` from (`service` left join `organization` on((`service`.`ORGANIZATION_ID` = `organization`.`ORGANIZATION_ID`))) where (((`service`.`NAME_STREAM` like '%электроэнерг%') or (`service`.`NAME_STREAM` = 'ОДН')) and (`organization`.`NAME_STREAM` like '%читаэнергосб%')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-03 15:28:39
