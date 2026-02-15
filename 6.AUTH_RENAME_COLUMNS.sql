--
-- 6. AUTH: Rename columns from TrinityCore to AzerothCore naming
-- MySQL 8.4 compatible (no DELIMITER, uses prepared statements for conditionals)
--

SET FOREIGN_KEY_CHECKS=0;

-- ============================================================================
-- Conditionally rename SecurityLevel -> gmlevel in account_access
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account_access' AND column_name = 'SecurityLevel');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account_access` CHANGE `SecurityLevel` `gmlevel` tinyint unsigned NOT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Conditionally rename AccountID -> id in account_access
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account_access' AND column_name = 'AccountID');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account_access` CHANGE `AccountID` `id` int unsigned NOT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Conditionally rename Comment -> comment in account_access (case-sensitive rename + default change)
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account_access' AND BINARY column_name = 'Comment');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account_access` CHANGE `Comment` `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT \'\'',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Conditionally rename session_key_auth -> session_key in account
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account' AND column_name = 'session_key_auth');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account` CHANGE `session_key_auth` `session_key` binary(40) DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Conditionally drop session_key_bnet from account (TC-only column)
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account' AND column_name = 'session_key_bnet');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account` DROP COLUMN `session_key_bnet`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Conditionally drop timezone_offset from account (TC-only column, not in AC)
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'account' AND column_name = 'timezone_offset');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `account` DROP COLUMN `timezone_offset`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS=1;
