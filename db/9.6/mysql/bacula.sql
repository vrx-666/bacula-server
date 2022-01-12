-- MySQL dump 10.19  Distrib 10.3.29-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: bacula
-- ------------------------------------------------------
-- Server version	10.3.29-MariaDB-0+deb10u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `BaseFiles`
--

DROP TABLE IF EXISTS `BaseFiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BaseFiles` (
  `BaseId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `BaseJobId` int(10) unsigned NOT NULL,
  `JobId` int(10) unsigned NOT NULL,
  `FileId` bigint(20) unsigned NOT NULL,
  `FileIndex` int(11) DEFAULT 0,
  PRIMARY KEY (`BaseId`),
  KEY `basefiles_jobid_idx` (`JobId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BaseFiles`
--

LOCK TABLES `BaseFiles` WRITE;
/*!40000 ALTER TABLE `BaseFiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `BaseFiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CDImages`
--

DROP TABLE IF EXISTS `CDImages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CDImages` (
  `MediaId` int(10) unsigned NOT NULL,
  `LastBurn` datetime DEFAULT NULL,
  PRIMARY KEY (`MediaId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CDImages`
--

LOCK TABLES `CDImages` WRITE;
/*!40000 ALTER TABLE `CDImages` DISABLE KEYS */;
/*!40000 ALTER TABLE `CDImages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Client`
--

DROP TABLE IF EXISTS `Client`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Client` (
  `ClientId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` tinyblob NOT NULL,
  `Uname` tinyblob NOT NULL,
  `AutoPrune` tinyint(4) DEFAULT 0,
  `FileRetention` bigint(20) unsigned DEFAULT 0,
  `JobRetention` bigint(20) unsigned DEFAULT 0,
  PRIMARY KEY (`ClientId`),
  UNIQUE KEY `Name` (`Name`(128))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Client`
--

LOCK TABLES `Client` WRITE;
/*!40000 ALTER TABLE `Client` DISABLE KEYS */;
/*!40000 ALTER TABLE `Client` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Counters`
--

DROP TABLE IF EXISTS `Counters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Counters` (
  `Counter` tinyblob NOT NULL,
  `MinValue` int(11) DEFAULT 0,
  `MaxValue` int(11) DEFAULT 0,
  `CurrentValue` int(11) DEFAULT 0,
  `WrapCounter` tinyblob NOT NULL,
  PRIMARY KEY (`Counter`(128))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Counters`
--

LOCK TABLES `Counters` WRITE;
/*!40000 ALTER TABLE `Counters` DISABLE KEYS */;
/*!40000 ALTER TABLE `Counters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Device`
--

DROP TABLE IF EXISTS `Device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Device` (
  `DeviceId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` tinyblob NOT NULL,
  `MediaTypeId` int(10) unsigned DEFAULT 0,
  `StorageId` int(10) unsigned DEFAULT 0,
  `DevMounts` int(10) unsigned DEFAULT 0,
  `DevReadBytes` bigint(20) unsigned DEFAULT 0,
  `DevWriteBytes` bigint(20) unsigned DEFAULT 0,
  `DevReadBytesSinceCleaning` bigint(20) unsigned DEFAULT 0,
  `DevWriteBytesSinceCleaning` bigint(20) unsigned DEFAULT 0,
  `DevReadTime` bigint(20) unsigned DEFAULT 0,
  `DevWriteTime` bigint(20) unsigned DEFAULT 0,
  `DevReadTimeSinceCleaning` bigint(20) unsigned DEFAULT 0,
  `DevWriteTimeSinceCleaning` bigint(20) unsigned DEFAULT 0,
  `CleaningDate` datetime DEFAULT NULL,
  `CleaningPeriod` bigint(20) unsigned DEFAULT 0,
  PRIMARY KEY (`DeviceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Device`
--

LOCK TABLES `Device` WRITE;
/*!40000 ALTER TABLE `Device` DISABLE KEYS */;
/*!40000 ALTER TABLE `Device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `File`
--

DROP TABLE IF EXISTS `File`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `File` (
  `FileId` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `FileIndex` int(11) DEFAULT 0,
  `JobId` int(10) unsigned NOT NULL,
  `PathId` int(10) unsigned NOT NULL,
  `FilenameId` int(10) unsigned NOT NULL,
  `DeltaSeq` smallint(5) unsigned DEFAULT 0,
  `MarkId` int(10) unsigned DEFAULT 0,
  `LStat` tinyblob NOT NULL,
  `MD5` tinyblob DEFAULT NULL,
  PRIMARY KEY (`FileId`),
  KEY `JobId` (`JobId`),
  KEY `JobId_2` (`JobId`,`PathId`,`FilenameId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `File`
--

LOCK TABLES `File` WRITE;
/*!40000 ALTER TABLE `File` DISABLE KEYS */;
/*!40000 ALTER TABLE `File` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FileSet`
--

DROP TABLE IF EXISTS `FileSet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `FileSet` (
  `FileSetId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `FileSet` tinyblob NOT NULL,
  `MD5` tinyblob DEFAULT NULL,
  `CreateTime` datetime DEFAULT NULL,
  PRIMARY KEY (`FileSetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FileSet`
--

LOCK TABLES `FileSet` WRITE;
/*!40000 ALTER TABLE `FileSet` DISABLE KEYS */;
/*!40000 ALTER TABLE `FileSet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Filename`
--

DROP TABLE IF EXISTS `Filename`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Filename` (
  `FilenameId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` blob NOT NULL,
  PRIMARY KEY (`FilenameId`),
  KEY `Name` (`Name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Filename`
--

LOCK TABLES `Filename` WRITE;
/*!40000 ALTER TABLE `Filename` DISABLE KEYS */;
/*!40000 ALTER TABLE `Filename` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Job`
--

DROP TABLE IF EXISTS `Job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Job` (
  `JobId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Job` tinyblob NOT NULL,
  `Name` tinyblob NOT NULL,
  `Type` binary(1) NOT NULL,
  `Level` binary(1) NOT NULL,
  `ClientId` int(11) DEFAULT 0,
  `JobStatus` binary(1) NOT NULL,
  `SchedTime` datetime DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `EndTime` datetime DEFAULT NULL,
  `RealEndTime` datetime DEFAULT NULL,
  `JobTDate` bigint(20) unsigned DEFAULT 0,
  `VolSessionId` int(10) unsigned DEFAULT 0,
  `VolSessionTime` int(10) unsigned DEFAULT 0,
  `JobFiles` int(10) unsigned DEFAULT 0,
  `JobBytes` bigint(20) unsigned DEFAULT 0,
  `ReadBytes` bigint(20) unsigned DEFAULT 0,
  `JobErrors` int(10) unsigned DEFAULT 0,
  `JobMissingFiles` int(10) unsigned DEFAULT 0,
  `PoolId` int(10) unsigned DEFAULT 0,
  `FileSetId` int(10) unsigned DEFAULT 0,
  `PriorJobId` int(10) unsigned DEFAULT 0,
  `PurgedFiles` tinyint(4) DEFAULT 0,
  `HasBase` tinyint(4) DEFAULT 0,
  `HasCache` tinyint(4) DEFAULT 0,
  `Reviewed` tinyint(4) DEFAULT 0,
  `Comment` blob DEFAULT NULL,
  `FileTable` char(20) DEFAULT 'File',
  PRIMARY KEY (`JobId`),
  KEY `Name` (`Name`(128)),
  KEY `JobTDate` (`JobTDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Job`
--

LOCK TABLES `Job` WRITE;
/*!40000 ALTER TABLE `Job` DISABLE KEYS */;
/*!40000 ALTER TABLE `Job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `JobHisto`
--

DROP TABLE IF EXISTS `JobHisto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `JobHisto` (
  `JobId` int(10) unsigned NOT NULL,
  `Job` tinyblob NOT NULL,
  `Name` tinyblob NOT NULL,
  `Type` binary(1) NOT NULL,
  `Level` binary(1) NOT NULL,
  `ClientId` int(11) DEFAULT 0,
  `JobStatus` binary(1) NOT NULL,
  `SchedTime` datetime DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `EndTime` datetime DEFAULT NULL,
  `RealEndTime` datetime DEFAULT NULL,
  `JobTDate` bigint(20) unsigned DEFAULT 0,
  `VolSessionId` int(10) unsigned DEFAULT 0,
  `VolSessionTime` int(10) unsigned DEFAULT 0,
  `JobFiles` int(10) unsigned DEFAULT 0,
  `JobBytes` bigint(20) unsigned DEFAULT 0,
  `ReadBytes` bigint(20) unsigned DEFAULT 0,
  `JobErrors` int(10) unsigned DEFAULT 0,
  `JobMissingFiles` int(10) unsigned DEFAULT 0,
  `PoolId` int(10) unsigned DEFAULT 0,
  `FileSetId` int(10) unsigned DEFAULT 0,
  `PriorJobId` int(10) unsigned DEFAULT 0,
  `PurgedFiles` tinyint(4) DEFAULT 0,
  `HasBase` tinyint(4) DEFAULT 0,
  `HasCache` tinyint(4) DEFAULT 0,
  `Reviewed` tinyint(4) DEFAULT 0,
  `Comment` blob DEFAULT NULL,
  `FileTable` char(20) DEFAULT 'File',
  KEY `JobId` (`JobId`),
  KEY `StartTime` (`StartTime`),
  KEY `JobTDate` (`JobTDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `JobHisto`
--

LOCK TABLES `JobHisto` WRITE;
/*!40000 ALTER TABLE `JobHisto` DISABLE KEYS */;
/*!40000 ALTER TABLE `JobHisto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `JobMedia`
--

DROP TABLE IF EXISTS `JobMedia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `JobMedia` (
  `JobMediaId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `JobId` int(10) unsigned NOT NULL,
  `MediaId` int(10) unsigned NOT NULL,
  `FirstIndex` int(10) unsigned DEFAULT 0,
  `LastIndex` int(10) unsigned DEFAULT 0,
  `StartFile` int(10) unsigned DEFAULT 0,
  `EndFile` int(10) unsigned DEFAULT 0,
  `StartBlock` int(10) unsigned DEFAULT 0,
  `EndBlock` int(10) unsigned DEFAULT 0,
  `VolIndex` int(10) unsigned DEFAULT 0,
  PRIMARY KEY (`JobMediaId`),
  KEY `JobId` (`JobId`,`MediaId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `JobMedia`
--

LOCK TABLES `JobMedia` WRITE;
/*!40000 ALTER TABLE `JobMedia` DISABLE KEYS */;
/*!40000 ALTER TABLE `JobMedia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Location`
--

DROP TABLE IF EXISTS `Location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Location` (
  `LocationId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Location` tinyblob NOT NULL,
  `Cost` int(11) DEFAULT 0,
  `Enabled` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Location`
--

LOCK TABLES `Location` WRITE;
/*!40000 ALTER TABLE `Location` DISABLE KEYS */;
/*!40000 ALTER TABLE `Location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `LocationLog`
--

DROP TABLE IF EXISTS `LocationLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `LocationLog` (
  `LocLogId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Date` datetime DEFAULT NULL,
  `Comment` blob NOT NULL,
  `MediaId` int(10) unsigned DEFAULT 0,
  `LocationId` int(10) unsigned DEFAULT 0,
  `NewVolStatus` enum('Full','Archive','Append','Recycle','Purged','Read-Only','Disabled','Error','Busy','Used','Cleaning') NOT NULL,
  `NewEnabled` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`LocLogId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `LocationLog`
--

LOCK TABLES `LocationLog` WRITE;
/*!40000 ALTER TABLE `LocationLog` DISABLE KEYS */;
/*!40000 ALTER TABLE `LocationLog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Log`
--

DROP TABLE IF EXISTS `Log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Log` (
  `LogId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `JobId` int(10) unsigned DEFAULT 0,
  `Time` datetime DEFAULT NULL,
  `LogText` blob NOT NULL,
  PRIMARY KEY (`LogId`),
  KEY `JobId` (`JobId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Log`
--

LOCK TABLES `Log` WRITE;
/*!40000 ALTER TABLE `Log` DISABLE KEYS */;
/*!40000 ALTER TABLE `Log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Media`
--

DROP TABLE IF EXISTS `Media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Media` (
  `MediaId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `VolumeName` tinyblob NOT NULL,
  `Slot` int(11) DEFAULT 0,
  `PoolId` int(10) unsigned DEFAULT 0,
  `MediaType` tinyblob NOT NULL,
  `MediaTypeId` int(10) unsigned DEFAULT 0,
  `LabelType` tinyint(4) DEFAULT 0,
  `FirstWritten` datetime DEFAULT NULL,
  `LastWritten` datetime DEFAULT NULL,
  `LabelDate` datetime DEFAULT NULL,
  `VolJobs` int(10) unsigned DEFAULT 0,
  `VolFiles` int(10) unsigned DEFAULT 0,
  `VolBlocks` int(10) unsigned DEFAULT 0,
  `VolParts` int(10) unsigned DEFAULT 0,
  `VolCloudParts` int(10) unsigned DEFAULT 0,
  `VolMounts` int(10) unsigned DEFAULT 0,
  `VolBytes` bigint(20) unsigned DEFAULT 0,
  `VolABytes` bigint(20) unsigned DEFAULT 0,
  `VolAPadding` bigint(20) unsigned DEFAULT 0,
  `VolHoleBytes` bigint(20) unsigned DEFAULT 0,
  `VolHoles` int(10) unsigned DEFAULT 0,
  `LastPartBytes` bigint(20) unsigned DEFAULT 0,
  `VolType` int(10) unsigned DEFAULT 0,
  `VolErrors` int(10) unsigned DEFAULT 0,
  `VolWrites` bigint(20) unsigned DEFAULT 0,
  `VolCapacityBytes` bigint(20) unsigned DEFAULT 0,
  `VolStatus` enum('Full','Archive','Append','Recycle','Purged','Read-Only','Disabled','Error','Busy','Used','Cleaning') NOT NULL,
  `Enabled` tinyint(4) DEFAULT 1,
  `Recycle` tinyint(4) DEFAULT 0,
  `ActionOnPurge` tinyint(4) DEFAULT 0,
  `CacheRetention` bigint(20) unsigned DEFAULT 0,
  `VolRetention` bigint(20) unsigned DEFAULT 0,
  `VolUseDuration` bigint(20) unsigned DEFAULT 0,
  `MaxVolJobs` int(10) unsigned DEFAULT 0,
  `MaxVolFiles` int(10) unsigned DEFAULT 0,
  `MaxVolBytes` bigint(20) unsigned DEFAULT 0,
  `InChanger` tinyint(4) DEFAULT 0,
  `StorageId` int(10) unsigned DEFAULT 0,
  `DeviceId` int(10) unsigned DEFAULT 0,
  `MediaAddressing` tinyint(4) DEFAULT 0,
  `VolReadTime` bigint(20) unsigned DEFAULT 0,
  `VolWriteTime` bigint(20) unsigned DEFAULT 0,
  `EndFile` int(10) unsigned DEFAULT 0,
  `EndBlock` int(10) unsigned DEFAULT 0,
  `LocationId` int(10) unsigned DEFAULT 0,
  `RecycleCount` int(10) unsigned DEFAULT 0,
  `InitialWrite` datetime DEFAULT NULL,
  `ScratchPoolId` int(10) unsigned DEFAULT 0,
  `RecyclePoolId` int(10) unsigned DEFAULT 0,
  `Comment` blob DEFAULT NULL,
  PRIMARY KEY (`MediaId`),
  UNIQUE KEY `VolumeName` (`VolumeName`(128)),
  KEY `PoolId` (`PoolId`),
  KEY `StorageId` (`StorageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Media`
--

LOCK TABLES `Media` WRITE;
/*!40000 ALTER TABLE `Media` DISABLE KEYS */;
/*!40000 ALTER TABLE `Media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MediaType`
--

DROP TABLE IF EXISTS `MediaType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MediaType` (
  `MediaTypeId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `MediaType` tinyblob NOT NULL,
  `ReadOnly` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`MediaTypeId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MediaType`
--

LOCK TABLES `MediaType` WRITE;
/*!40000 ALTER TABLE `MediaType` DISABLE KEYS */;
/*!40000 ALTER TABLE `MediaType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Path`
--

DROP TABLE IF EXISTS `Path`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Path` (
  `PathId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Path` blob NOT NULL,
  PRIMARY KEY (`PathId`),
  KEY `Path` (`Path`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Path`
--

LOCK TABLES `Path` WRITE;
/*!40000 ALTER TABLE `Path` DISABLE KEYS */;
/*!40000 ALTER TABLE `Path` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PathHierarchy`
--

DROP TABLE IF EXISTS `PathHierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PathHierarchy` (
  `PathId` int(11) NOT NULL,
  `PPathId` int(11) NOT NULL,
  PRIMARY KEY (`PathId`),
  KEY `pathhierarchy_ppathid` (`PPathId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PathHierarchy`
--

LOCK TABLES `PathHierarchy` WRITE;
/*!40000 ALTER TABLE `PathHierarchy` DISABLE KEYS */;
/*!40000 ALTER TABLE `PathHierarchy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PathVisibility`
--

DROP TABLE IF EXISTS `PathVisibility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PathVisibility` (
  `PathId` int(11) NOT NULL,
  `JobId` int(10) unsigned NOT NULL,
  `Size` bigint(20) DEFAULT 0,
  `Files` int(11) DEFAULT 0,
  PRIMARY KEY (`JobId`,`PathId`),
  KEY `pathvisibility_jobid` (`JobId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PathVisibility`
--

LOCK TABLES `PathVisibility` WRITE;
/*!40000 ALTER TABLE `PathVisibility` DISABLE KEYS */;
/*!40000 ALTER TABLE `PathVisibility` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Pool`
--

DROP TABLE IF EXISTS `Pool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Pool` (
  `PoolId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` tinyblob NOT NULL,
  `NumVols` int(10) unsigned DEFAULT 0,
  `MaxVols` int(10) unsigned DEFAULT 0,
  `UseOnce` tinyint(4) DEFAULT 0,
  `UseCatalog` tinyint(4) DEFAULT 0,
  `AcceptAnyVolume` tinyint(4) DEFAULT 0,
  `CacheRetention` bigint(20) unsigned DEFAULT 0,
  `VolRetention` bigint(20) unsigned DEFAULT 0,
  `VolUseDuration` bigint(20) unsigned DEFAULT 0,
  `MaxVolJobs` int(10) unsigned DEFAULT 0,
  `MaxVolFiles` int(10) unsigned DEFAULT 0,
  `MaxVolBytes` bigint(20) unsigned DEFAULT 0,
  `AutoPrune` tinyint(4) DEFAULT 0,
  `Recycle` tinyint(4) DEFAULT 0,
  `ActionOnPurge` tinyint(4) DEFAULT 0,
  `PoolType` enum('Backup','Copy','Cloned','Archive','Migration','Scratch') NOT NULL,
  `LabelType` tinyint(4) DEFAULT 0,
  `LabelFormat` tinyblob DEFAULT NULL,
  `Enabled` tinyint(4) DEFAULT 1,
  `ScratchPoolId` int(10) unsigned DEFAULT 0,
  `RecyclePoolId` int(10) unsigned DEFAULT 0,
  `NextPoolId` int(10) unsigned DEFAULT 0,
  `MigrationHighBytes` bigint(20) unsigned DEFAULT 0,
  `MigrationLowBytes` bigint(20) unsigned DEFAULT 0,
  `MigrationTime` bigint(20) unsigned DEFAULT 0,
  PRIMARY KEY (`PoolId`),
  UNIQUE KEY `Name` (`Name`(128))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Pool`
--

LOCK TABLES `Pool` WRITE;
/*!40000 ALTER TABLE `Pool` DISABLE KEYS */;
/*!40000 ALTER TABLE `Pool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RestoreObject`
--

DROP TABLE IF EXISTS `RestoreObject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RestoreObject` (
  `RestoreObjectId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ObjectName` blob NOT NULL,
  `RestoreObject` longblob NOT NULL,
  `PluginName` tinyblob NOT NULL,
  `ObjectLength` int(11) DEFAULT 0,
  `ObjectFullLength` int(11) DEFAULT 0,
  `ObjectIndex` int(11) DEFAULT 0,
  `ObjectType` int(11) DEFAULT 0,
  `FileIndex` int(11) DEFAULT 0,
  `JobId` int(10) unsigned NOT NULL,
  `ObjectCompression` int(11) DEFAULT 0,
  PRIMARY KEY (`RestoreObjectId`),
  KEY `JobId` (`JobId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RestoreObject`
--

LOCK TABLES `RestoreObject` WRITE;
/*!40000 ALTER TABLE `RestoreObject` DISABLE KEYS */;
/*!40000 ALTER TABLE `RestoreObject` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Snapshot`
--

DROP TABLE IF EXISTS `Snapshot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Snapshot` (
  `SnapshotId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` tinyblob NOT NULL,
  `JobId` int(10) unsigned DEFAULT 0,
  `FileSetId` int(10) unsigned DEFAULT 0,
  `CreateTDate` bigint(20) NOT NULL,
  `CreateDate` datetime NOT NULL,
  `ClientId` int(10) unsigned DEFAULT 0,
  `Volume` tinyblob NOT NULL,
  `Device` tinyblob NOT NULL,
  `Type` tinyblob NOT NULL,
  `Retention` int(11) DEFAULT 0,
  `Comment` blob DEFAULT NULL,
  PRIMARY KEY (`SnapshotId`),
  UNIQUE KEY `snapshot_idx` (`Device`(255),`Volume`(255),`Name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Snapshot`
--

LOCK TABLES `Snapshot` WRITE;
/*!40000 ALTER TABLE `Snapshot` DISABLE KEYS */;
/*!40000 ALTER TABLE `Snapshot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Status`
--

DROP TABLE IF EXISTS `Status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Status` (
  `JobStatus` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `JobStatusLong` blob DEFAULT NULL,
  `Severity` int(11) DEFAULT NULL,
  PRIMARY KEY (`JobStatus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Status`
--

LOCK TABLES `Status` WRITE;
/*!40000 ALTER TABLE `Status` DISABLE KEYS */;
INSERT INTO `Status` VALUES ('A','Canceled by user',90),('B','Blocked',15),('C','Created, not yet running',15),('D','Verify found differences',15),('E','Terminated with errors',25),('F','Waiting for Client',15),('I','Incomplete Job',25),('M','Waiting for media mount',15),('R','Running',15),('S','Waiting for Storage daemon',15),('T','Completed successfully',10),('a','SD despooling attributes',15),('c','Waiting for client resource',15),('d','Waiting on maximum jobs',15),('e','Non-fatal error',20),('f','Fatal error',100),('i','Doing batch insert file records',15),('j','Waiting for job resource',15),('m','Waiting for new media',15),('p','Waiting on higher priority jobs',15),('s','Waiting for storage resource',15),('t','Waiting on start time',15);
/*!40000 ALTER TABLE `Status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Storage`
--

DROP TABLE IF EXISTS `Storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Storage` (
  `StorageId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` tinyblob NOT NULL,
  `AutoChanger` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`StorageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Storage`
--

LOCK TABLES `Storage` WRITE;
/*!40000 ALTER TABLE `Storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `Storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UnsavedFiles`
--

DROP TABLE IF EXISTS `UnsavedFiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UnsavedFiles` (
  `UnsavedId` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `JobId` int(10) unsigned NOT NULL,
  `PathId` int(10) unsigned NOT NULL,
  `FilenameId` int(10) unsigned NOT NULL,
  PRIMARY KEY (`UnsavedId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UnsavedFiles`
--

LOCK TABLES `UnsavedFiles` WRITE;
/*!40000 ALTER TABLE `UnsavedFiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `UnsavedFiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Version`
--

DROP TABLE IF EXISTS `Version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Version` (
  `VersionId` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Version`
--

LOCK TABLES `Version` WRITE;
/*!40000 ALTER TABLE `Version` DISABLE KEYS */;
INSERT INTO `Version` VALUES (16);
/*!40000 ALTER TABLE `Version` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-09-23  8:38:20
