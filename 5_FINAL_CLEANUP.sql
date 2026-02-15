--
-- 5. Final cleanup: remove orphaned records, drop TC-only tables,
--    set up updates/updates_include for AzerothCore characters DB
-- MySQL 8.4 compatible - backtick-quotes reserved words: `groups`, `order`
--

SET FOREIGN_KEY_CHECKS=0;

-- ============================================================================
-- 1. Cleanup tables referencing characters.guid
-- ============================================================================
DELETE FROM `auctionhouse` WHERE `itemowner` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_account_data` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_achievement` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_achievement_progress` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_action` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_arena_stats` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_aura` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_banned` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_battleground_random` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_declinedname` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_equipmentsets` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_gifts` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_glyphs` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_homebind` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_instance` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_inventory` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_pet` WHERE `owner` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_queststatus` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_queststatus_daily` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_queststatus_rewarded` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_queststatus_weekly` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_reputation` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_skills` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_social` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_social` WHERE `friend` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_spell` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_spell_cooldown` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_stats` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `character_talent` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `corpse` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `item_instance` WHERE `owner_guid` <> 0 AND `owner_guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `item_refund_instance` WHERE `player_guid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `mail` WHERE `sender` NOT IN (SELECT `guid` FROM `characters`) AND `messageType` = 0;
DELETE FROM `mail` WHERE `receiver` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `mail_items` WHERE `receiver` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `petition` WHERE `ownerguid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `petition_sign` WHERE `ownerguid` NOT IN (SELECT `guid` FROM `characters`);
DELETE FROM `petition_sign` WHERE `playerguid` NOT IN (SELECT `guid` FROM `characters`);

-- ============================================================================
-- 2. Cleanup group tables (backtick-quote `groups` - reserved word in MySQL 8.4)
-- ============================================================================
-- 2.1. Delete inexistent group members
DELETE FROM `group_member` WHERE `memberGuid` NOT IN (SELECT `guid` FROM `characters`);
-- 2.2. Delete members for inexistent groups
DELETE FROM `group_member` WHERE `guid` NOT IN (SELECT `guid` FROM `groups`);
-- 2.3. Delete empty groups
DELETE FROM `groups` WHERE `guid` NOT IN (SELECT `guid` FROM `group_member`);

-- ============================================================================
-- 3. Cleanup guild tables
-- ============================================================================
-- 3.1. Delete inexistent guild members
DELETE FROM `guild_member` WHERE `guid` NOT IN (SELECT `guid` FROM `characters`);
-- 3.2. Delete members for inexistent guilds
DELETE FROM `guild_member` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
-- 3.3. Delete empty guilds
DELETE FROM `guild` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild_member`);
-- 3.4. Delete referencing data for inexistent guilds
DELETE FROM `guild_bank_eventlog` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
DELETE FROM `guild_bank_item` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
DELETE FROM `guild_bank_right` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
DELETE FROM `guild_bank_tab` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
DELETE FROM `guild_eventlog` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);
DELETE FROM `guild_rank` WHERE `guildid` NOT IN (SELECT `guildid` FROM `guild`);

-- ============================================================================
-- 4. Cleanup tables referencing character_pet.id
-- ============================================================================
DELETE FROM `pet_aura` WHERE `guid` NOT IN (SELECT `id` FROM `character_pet`);
DELETE FROM `pet_spell` WHERE `guid` NOT IN (SELECT `id` FROM `character_pet`);
DELETE FROM `pet_spell_cooldown` WHERE `guid` NOT IN (SELECT `id` FROM `character_pet`);

-- ============================================================================
-- 5. Cleanup mail tables
-- ============================================================================
DELETE FROM `mail_items` WHERE `mail_id` NOT IN (SELECT `id` FROM `mail`);

-- ============================================================================
-- 6. Cleanup tables referencing item_instance.guid
-- ============================================================================
-- 6.1. Delete auction records for inexistent items
DELETE FROM `auctionhouse` WHERE `itemguid` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.2. Delete gifts for inexistent items
DELETE FROM `character_gifts` WHERE `item_guid` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.3. Delete inventory records for inexistent items
DELETE FROM `character_inventory` WHERE `item` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.4. Delete guild bank records for inexistent items
DELETE FROM `guild_bank_item` WHERE `item_guid` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.5. Delete item refund records for inexistent items
DELETE FROM `item_refund_instance` WHERE `item_guid` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.6. Delete soulbound trade records for inexistent items
DELETE FROM `item_soulbound_trade_data` WHERE `itemGuid` NOT IN (SELECT `guid` FROM `item_instance`);
-- 6.7. Delete mail items records for inexistent items
DELETE FROM `mail_items` WHERE `item_guid` NOT IN (SELECT `guid` FROM `item_instance`);

-- ============================================================================
-- 7. Cleanup items not bound to anything (auction, inventory, guild bank or mail)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `items_temp` (`guid` int unsigned PRIMARY KEY);
TRUNCATE TABLE `items_temp`;
REPLACE INTO `items_temp` SELECT `itemguid` FROM `auctionhouse`;
REPLACE INTO `items_temp` SELECT `item` FROM `character_inventory`;
REPLACE INTO `items_temp` SELECT `item_guid` FROM `guild_bank_item`;
REPLACE INTO `items_temp` SELECT `item_guid` FROM `mail_items`;
DELETE FROM `item_instance` WHERE `guid` NOT IN (SELECT `guid` FROM `items_temp`);
DROP TABLE IF EXISTS `items_temp`;

-- ============================================================================
-- 8. Drop TC-only tables that do not exist in AzerothCore
-- ============================================================================
DROP TABLE IF EXISTS `auctionbidders`;
DROP TABLE IF EXISTS `character_battleground_data`;
DROP TABLE IF EXISTS `item_loot_items`;
DROP TABLE IF EXISTS `item_loot_money`;
DROP TABLE IF EXISTS `character_fishingsteps`;
DROP TABLE IF EXISTS `respawn`;
DROP TABLE IF EXISTS `group_instance`;

-- ============================================================================
-- 9. Drop old migration lookup tables
-- ============================================================================
DROP TABLE IF EXISTS `__del_ability_spell`;
DROP TABLE IF EXISTS `__del_override_spell`;
DROP TABLE IF EXISTS `__del_shapeshift_spell`;
DROP TABLE IF EXISTS `__del_spell_learn_spell`;
DROP TABLE IF EXISTS `__del_talent_rest_ranks`;
DROP TABLE IF EXISTS `__del_talent_pyroblast`;
DROP TABLE IF EXISTS `__del_talent_pyroblast2`;
DROP TABLE IF EXISTS `__del_spells_with_learn_effect`;
DROP TABLE IF EXISTS `__playercreateinfo_spell`;
DROP TABLE IF EXISTS `__profession_autolearn`;
DROP TABLE IF EXISTS `__profession_skill`;
DROP TABLE IF EXISTS `__profession_spell_req_spell`;
DROP TABLE IF EXISTS `__profession_spell_req_skill`;
DROP TABLE IF EXISTS `__spell_ranks`;

-- ============================================================================
-- 10. Create AC-only tables added by updates (not in TC, not in file 2)
-- ============================================================================

-- character_achievement_offline_updates (AC update 2024_09_03_00)
CREATE TABLE IF NOT EXISTS `character_achievement_offline_updates` (
  `guid` int unsigned NOT NULL COMMENT 'Character''s GUID',
  `update_type` tinyint unsigned NOT NULL COMMENT 'Supported types: 1 - COMPLETE_ACHIEVEMENT; 2 - UPDATE_CRITERIA',
  `arg1` int unsigned NOT NULL COMMENT 'For type 1: achievement ID; for type 2: ACHIEVEMENT_CRITERIA_TYPE',
  `arg2` int unsigned DEFAULT NULL COMMENT 'For type 2: miscValue1 for updating achievement criteria',
  `arg3` int unsigned DEFAULT NULL COMMENT 'For type 2: miscValue2 for updating achievement criteria',
  KEY `idx_guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores updates to character achievements when the character was offline';

-- world_state (AC update 2025_01_31_00, engine changed to InnoDB in 2025_07_11_00)
CREATE TABLE IF NOT EXISTS `world_state` (
  `Id` int unsigned NOT NULL COMMENT 'Internal save ID',
  `Data` longtext,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='WorldState save system';

-- Insert default Sunwell world state if table is empty
INSERT IGNORE INTO `world_state` (`Id`, `Data`) VALUES (20, '3 15 10000 10000 10000 10000 10000 10000 10000 10000 10000 10000 3 80 80 80');

-- mail_server_template_items (AC update 2025_03_09_00)
CREATE TABLE IF NOT EXISTS `mail_server_template_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `templateID` int unsigned NOT NULL,
  `faction` enum('Alliance','Horde') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item` int unsigned NOT NULL,
  `itemCount` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mail_template` (`templateID`),
  CONSTRAINT `fk_mail_template` FOREIGN KEY (`templateID`) REFERENCES `mail_server_template` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- mail_server_template_conditions (AC update 2025_03_09_00 + 2025_07_29_00)
CREATE TABLE IF NOT EXISTS `mail_server_template_conditions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `templateID` int unsigned NOT NULL,
  `conditionType` enum('Level','PlayTime','Quest','Achievement','Reputation','Faction','Race','Class','AccountFlags') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `conditionValue` int unsigned NOT NULL,
  `conditionState` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_mail_template_conditions` (`templateID`),
  CONSTRAINT `fk_mail_template_conditions` FOREIGN KEY (`templateID`) REFERENCES `mail_server_template` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Migrate mail_server_template item/condition data and drop old columns (AC update 2025_03_09_00)
-- Only if the old columns still exist (safe for re-runs)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'mail_server_template' AND column_name = 'itemA');
SET @sql = IF(@col_exists > 0,
    'INSERT INTO `mail_server_template_items` (`templateID`, `faction`, `item`, `itemCount`) SELECT `id`, ''Alliance'', `itemA`, `itemCountA` FROM `mail_server_template` WHERE `itemA` > 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@col_exists > 0,
    'INSERT INTO `mail_server_template_items` (`templateID`, `faction`, `item`, `itemCount`) SELECT `id`, ''Horde'', `itemH`, `itemCountH` FROM `mail_server_template` WHERE `itemH` > 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `mail_server_template` DROP COLUMN `itemA`, DROP COLUMN `itemCountA`, DROP COLUMN `itemH`, DROP COLUMN `itemCountH`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'mail_server_template' AND column_name = 'reqLevel');
SET @sql = IF(@col_exists > 0,
    'INSERT INTO `mail_server_template_conditions` (`templateID`, `conditionType`, `conditionValue`) SELECT `id`, ''Level'', `reqLevel` FROM `mail_server_template` WHERE `reqLevel` > 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@col_exists > 0,
    'INSERT INTO `mail_server_template_conditions` (`templateID`, `conditionType`, `conditionValue`) SELECT `id`, ''PlayTime'', `reqPlayTime` FROM `mail_server_template` WHERE `reqPlayTime` > 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `mail_server_template` DROP COLUMN `reqLevel`, DROP COLUMN `reqPlayTime`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add FK to mail_server_character if missing (AC update 2025_03_09_00)
-- First clean up orphan records
DELETE FROM `mail_server_character` WHERE `mailId` NOT IN (SELECT `id` FROM `mail_server_template`);

SET @fk_exists = (SELECT COUNT(*) FROM information_schema.table_constraints
    WHERE table_schema = DATABASE() AND table_name = 'mail_server_character'
    AND constraint_name = 'fk_mail_server_character' AND constraint_type = 'FOREIGN KEY');
SET @sql = IF(@fk_exists = 0,
    'ALTER TABLE `mail_server_character` ADD CONSTRAINT `fk_mail_server_character` FOREIGN KEY (`mailId`) REFERENCES `mail_server_template` (`id`) ON DELETE CASCADE',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add recovery_item.DeleteDate column if missing (AC update 2024_09_22_00)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'recovery_item' AND column_name = 'DeleteDate');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `recovery_item` ADD COLUMN `DeleteDate` int unsigned DEFAULT NULL AFTER `Count`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop character_homebind.posO if it exists (AC update 2024_07_05_00 removed it)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_homebind' AND column_name = 'posO');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_homebind` DROP COLUMN `posO`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- 11. Update updates/updates_include tables for AzerothCore characters DB
-- ============================================================================

-- Modify updates.state enum to AC format
SET @tbl_exists = (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'updates');
SET @sql = IF(@tbl_exists > 0,
    'ALTER TABLE `updates` MODIFY `state` enum(''RELEASED'',''CUSTOM'',''MODULE'',''ARCHIVED'',''PENDING'') NOT NULL DEFAULT ''RELEASED'' COMMENT ''defines if an update is released or archived.''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Recreate updates_include with AC format and data
DROP TABLE IF EXISTS `updates_include`;
CREATE TABLE `updates_include` (
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'directory to include. $ means relative to the source directory.',
  `state` enum('RELEASED','ARCHIVED','CUSTOM','PENDING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RELEASED' COMMENT 'defines if the directory contains released or archived updates.',
  PRIMARY KEY (`path`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='List of directories where we want to include sql updates.';

INSERT INTO `updates_include` VALUES
('$/data/sql/archive/db_characters','ARCHIVED'),
('$/data/sql/custom/db_characters','CUSTOM'),
('$/data/sql/updates/db_characters','RELEASED'),
('$/data/sql/updates/pending_db_characters','PENDING');

-- Populate updates table with AC base update records
-- This tells the AC server that all base updates have been applied
TRUNCATE TABLE `updates`;
INSERT INTO `updates` (`name`, `hash`, `state`, `speed`) VALUES
('2023_04_24_00.sql','D164A70B22B2462464484614018C3218B3259AE4','ARCHIVED',0),
('2023_05_23_00.sql','A1A442D3F5049CDA2C067761F768C08BEFFFD26A','ARCHIVED',0),
('2023_09_16_00.sql','5760BA953E3F0C73492B979A33A86771B82CE464','ARCHIVED',0),
('2024_01_20_00.sql','FB9F840C7601C4F0939D23E87377D7DD9D145094','RELEASED',0),
('2024_07_05_00.sql','1C9590EBB81D192A2DF101D6B0B2178E45306500','RELEASED',0),
('2024_09_03_00.sql','6D7992803C7747E9CDE15A6EF0A0319DEE93DA51','RELEASED',0),
('2024_09_22_00.sql','CC603A632BB6E01737A3D2DF7A85D1BEFF16C102','RELEASED',0),
('2024_11_15_00.sql','AC109BE8DC3ABD09435A700F8ADE0050B9CB5170','RELEASED',0),
('2025_01_31_00.sql','49B70E7107D57C75198BA707B849A6243A32863F','RELEASED',0),
('2025_02_12_00.sql','BF2260040A6B47500D6C24BE74DB61198E5DA966','RELEASED',0),
('2025_02_16_00.sql','BF15638A8F522A4D9DE51D42A71B860B95FB8031','RELEASED',0),
('2025_03_09_00.sql','9BC72C8A080EDC1B3ECCB81C8146C8A5EA7E4266','RELEASED',0),
('2025_07_11_00.sql','EA89D9F35FC3237E8B443902D6A7AD94DC7C8645','RELEASED',0),
('2025_07_29_00.sql','6BA914607D79FF1450D558EEDCF1CF54A9FA657C','RELEASED',0),
('2025_09_03_00.sql','195C01E5CF60AEE47D1706E684BD0EA7C040071F','RELEASED',0);

TRUNCATE TABLE `channels`;

SET FOREIGN_KEY_CHECKS=1;
