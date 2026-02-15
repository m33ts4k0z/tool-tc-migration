--
-- 7. AUTH: Clean TC-only tables, add AC-specific columns, update metadata tables
-- MySQL 8.4 compatible (no DELIMITER, uses prepared statements for conditionals)
--

SET FOREIGN_KEY_CHECKS=0;

-- ============================================================================
-- Add AC-specific columns to account table
-- ============================================================================

-- Add totaltime column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account' AND column_name = 'totaltime');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `account` ADD COLUMN `totaltime` int unsigned NOT NULL DEFAULT 0 AFTER `recruiter`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change online from tinyint to int unsigned (AC uses int unsigned)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account' AND column_name = 'online'
    AND column_type = 'tinyint unsigned');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account` MODIFY `online` int unsigned NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Add seed columns to build_info (AC has these, TC uses separate tables)
-- ============================================================================

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'build_info' AND column_name = 'winAuthSeed');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `build_info` ADD COLUMN `winAuthSeed` varchar(32) DEFAULT NULL AFTER `hotfixVersion`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'build_info' AND column_name = 'win64AuthSeed');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `build_info` ADD COLUMN `win64AuthSeed` varchar(32) DEFAULT NULL AFTER `winAuthSeed`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'build_info' AND column_name = 'mac64AuthSeed');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `build_info` ADD COLUMN `mac64AuthSeed` varchar(32) DEFAULT NULL AFTER `win64AuthSeed`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'build_info' AND column_name = 'winChecksumSeed');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `build_info` ADD COLUMN `winChecksumSeed` varchar(40) DEFAULT NULL AFTER `mac64AuthSeed`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'build_info' AND column_name = 'macChecksumSeed');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `build_info` ADD COLUMN `macChecksumSeed` varchar(40) DEFAULT NULL AFTER `winChecksumSeed`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Migrate build auth keys into build_info seed columns if source tables exist
-- ============================================================================
SET @tbl_exists = (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'build_auth_key');
SET @sql = IF(@tbl_exists > 0,
    'UPDATE `build_info` bi JOIN `build_auth_key` bak ON bi.build = bak.build AND bak.platform = ''Win'' AND bak.arch = ''x86'' AND bak.type = ''WoW'' SET bi.winAuthSeed = HEX(bak.`key`) WHERE bi.winAuthSeed IS NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@tbl_exists > 0,
    'UPDATE `build_info` bi JOIN `build_auth_key` bak ON bi.build = bak.build AND bak.platform = ''Win'' AND bak.arch = ''x64'' AND bak.type = ''WoW'' SET bi.win64AuthSeed = HEX(bak.`key`) WHERE bi.win64AuthSeed IS NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@tbl_exists > 0,
    'UPDATE `build_info` bi JOIN `build_auth_key` bak ON bi.build = bak.build AND bak.platform = ''Mac'' AND bak.arch = ''x64'' AND bak.type = ''WoW'' SET bi.mac64AuthSeed = HEX(bak.`key`) WHERE bi.mac64AuthSeed IS NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @tbl_exists2 = (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'build_executable_hash');
SET @sql = IF(@tbl_exists2 > 0,
    'UPDATE `build_info` bi JOIN `build_executable_hash` beh ON bi.build = beh.build AND beh.platform = ''Win'' SET bi.winChecksumSeed = HEX(beh.executableHash) WHERE bi.winChecksumSeed IS NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@tbl_exists2 > 0,
    'UPDATE `build_info` bi JOIN `build_executable_hash` beh ON bi.build = beh.build AND beh.platform = ''Mac'' SET bi.macChecksumSeed = HEX(beh.executableHash) WHERE bi.macChecksumSeed IS NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Drop TC-only auth tables
-- ============================================================================
DROP VIEW IF EXISTS vw_rbac;
DROP VIEW IF EXISTS vw_log_history;
DROP TABLE IF EXISTS `rbac_account_permissions`;
DROP TABLE IF EXISTS `rbac_default_permissions`;
DROP TABLE IF EXISTS `rbac_linked_permissions`;
DROP TABLE IF EXISTS `rbac_permissions`;
DROP TABLE IF EXISTS `build_auth_key`;
DROP TABLE IF EXISTS `build_executable_hash`;

-- ============================================================================
-- Fix logs_ip_actions: drop realm_id, change character_guid type
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'logs_ip_actions' AND column_name = 'realm_id');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `logs_ip_actions` DROP COLUMN `realm_id`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change character_guid from bigint to int if needed
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'logs_ip_actions' AND column_name = 'character_guid');
SET @sql = IF(@col_type = 'bigint unsigned',
    'ALTER TABLE `logs_ip_actions` MODIFY `character_guid` int unsigned NOT NULL COMMENT ''Character Guid''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Create AC-only auth tables
-- ============================================================================

-- motd table
CREATE TABLE IF NOT EXISTS `motd` (
  `realmid` int NOT NULL,
  `text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`realmid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default motd if table is empty
INSERT IGNORE INTO `motd` (`realmid`, `text`) VALUES (-1, 'Welcome to an AzerothCore server.');

-- motd_localized table
CREATE TABLE IF NOT EXISTS `motd_localized` (
  `realmid` int NOT NULL,
  `locale` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`realmid`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- autobroadcast_locale table
CREATE TABLE IF NOT EXISTS `autobroadcast_locale` (
  `realmid` int NOT NULL,
  `id` int NOT NULL,
  `locale` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`realmid`,`id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Update the `updates` table: change enum to AC format
-- ============================================================================

-- Recreate updates table with AC enum values
SET @tbl_exists = (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'updates');
SET @sql = IF(@tbl_exists > 0,
    'ALTER TABLE `updates` MODIFY `state` enum(''RELEASED'',''CUSTOM'',''MODULE'',''ARCHIVED'',''PENDING'') NOT NULL DEFAULT ''RELEASED'' COMMENT ''defines if an update is released or archived.''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Recreate updates_include table with AC format and data
-- ============================================================================
DROP TABLE IF EXISTS `updates_include`;
CREATE TABLE `updates_include` (
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'directory to include. $ means relative to the source directory.',
  `state` enum('RELEASED','ARCHIVED','CUSTOM','PENDING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RELEASED' COMMENT 'defines if the directory contains released or archived updates.',
  PRIMARY KEY (`path`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of directories where we want to include sql updates.';

LOCK TABLES `updates_include` WRITE;
/*!40000 ALTER TABLE `updates_include` DISABLE KEYS */;
INSERT INTO `updates_include` VALUES
('$/data/sql/archive/db_auth','ARCHIVED'),
('$/data/sql/custom/db_auth','CUSTOM'),
('$/data/sql/updates/db_auth','RELEASED'),
('$/data/sql/updates/pending_db_auth','PENDING');
/*!40000 ALTER TABLE `updates_include` ENABLE KEYS */;
UNLOCK TABLES;

-- ============================================================================
-- Populate updates table with AC base update records
-- This tells the AC server that all base updates have been applied
-- ============================================================================
TRUNCATE TABLE `updates`;

SET FOREIGN_KEY_CHECKS=1;
