--
-- 3. Alter existing tables to match AzerothCore structure
-- MySQL 8.4 compatible (no DELIMITER, uses prepared statements for conditionals)
-- Backtick-quotes reserved words: `groups`, `order`
--

SET FOREIGN_KEY_CHECKS=0;

-- ============================================================================
-- character_spell_cooldown: add `category` (int unsigned), add `needSend`
-- drop `categoryEnd`, drop `categoryId`
-- AC: guid, spell, category (int unsigned), item, time, needSend
-- TC: guid, spell, item, time, categoryId, categoryEnd
-- ============================================================================

-- Add category column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell_cooldown' AND column_name = 'category');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `character_spell_cooldown` ADD COLUMN `category` int unsigned DEFAULT 0 AFTER `spell`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add needSend column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell_cooldown' AND column_name = 'needSend');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `character_spell_cooldown` ADD COLUMN `needSend` tinyint unsigned NOT NULL DEFAULT 1 AFTER `time`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop categoryEnd if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell_cooldown' AND column_name = 'categoryEnd');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_spell_cooldown` DROP COLUMN `categoryEnd`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop categoryId if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell_cooldown' AND column_name = 'categoryId');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_spell_cooldown` DROP COLUMN `categoryId`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- pet_spell_cooldown: add `category` (int unsigned), drop `categoryEnd`, `categoryId`
-- AC: guid, spell (int unsigned), category (int unsigned), time
-- TC: guid, spell (mediumint unsigned), time, categoryId, categoryEnd
-- ============================================================================

-- Add category column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_spell_cooldown' AND column_name = 'category');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `pet_spell_cooldown` ADD COLUMN `category` int unsigned DEFAULT 0 AFTER `spell`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop categoryEnd if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_spell_cooldown' AND column_name = 'categoryEnd');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `pet_spell_cooldown` DROP COLUMN `categoryEnd`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop categoryId if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_spell_cooldown' AND column_name = 'categoryId');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `pet_spell_cooldown` DROP COLUMN `categoryId`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- channels: add channelId auto_increment, change PK, drop bannedList
-- AC: channelId (auto_increment PK), name, team, announce, ownership, password, lastUsed
-- TC: name+team (composite PK), announce, ownership, password, bannedList, lastUsed
-- ============================================================================

-- Add channelId column if missing (must be done before PK change)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'channels' AND column_name = 'channelId');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `channels` ADD COLUMN `channelId` int unsigned NOT NULL AUTO_INCREMENT FIRST, DROP PRIMARY KEY, ADD PRIMARY KEY (`channelId`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop bannedList if it exists (AC uses channels_bans table instead)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'channels' AND column_name = 'bannedList');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `channels` DROP COLUMN `bannedList`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- character_talent: TRUNCATE, rename talentGroup -> specMask, change PK
-- AC: guid, spell (int unsigned), specMask -- PK(guid, spell)
-- TC: guid, spell (mediumint unsigned), talentGroup -- PK(guid, spell, talentGroup)
-- ============================================================================
TRUNCATE TABLE `character_talent`;

-- Rename talentGroup -> specMask if needed
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_talent' AND column_name = 'talentGroup');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_talent` CHANGE `talentGroup` `specMask` tinyint unsigned NOT NULL DEFAULT 0, DROP PRIMARY KEY, ADD PRIMARY KEY (`guid`, `spell`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- character_instance: rename extendState -> extended
-- AC: guid, instance, permanent, extended
-- TC: guid, instance, permanent, extendState
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_instance' AND column_name = 'extendState');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_instance` CHANGE `extendState` `extended` tinyint unsigned NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- character_arena_stats: add maxMMR column
-- AC: guid, slot, matchMakerRating, maxMMR
-- TC: guid, slot, matchMakerRating (no maxMMR)
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_arena_stats' AND column_name = 'maxMMR');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `character_arena_stats` ADD COLUMN `maxMMR` smallint NOT NULL DEFAULT 0 AFTER `matchMakerRating`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- character_spell: drop active, drop disabled, add specMask
-- AC: guid, spell (int unsigned), specMask
-- TC: guid, spell (mediumint unsigned), active, disabled
-- ============================================================================

-- Drop active column if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell' AND column_name = 'active');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_spell` DROP COLUMN `active`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop disabled column if it exists
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell' AND column_name = 'disabled');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_spell` DROP COLUMN `disabled`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add specMask column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell' AND column_name = 'specMask');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `character_spell` ADD COLUMN `specMask` tinyint unsigned NOT NULL DEFAULT 255',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- characters table: add `order`, creation_date, extraBonusTalentCount
-- change transguid type (mediumint unsigned -> int), latency type (mediumint -> int unsigned)
-- change idx_name from UNIQUE to non-unique KEY
-- AC has innTriggerId but that is added in file 1 already
-- ============================================================================

-- Add `order` column if missing (reserved word - must be backtick-quoted)
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'characters' AND column_name = 'order');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `characters` ADD COLUMN `order` tinyint DEFAULT NULL AFTER `grantableLevels`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add creation_date column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'characters' AND column_name = 'creation_date');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `characters` ADD COLUMN `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `order`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add extraBonusTalentCount column if missing
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'characters' AND column_name = 'extraBonusTalentCount');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `characters` ADD COLUMN `extraBonusTalentCount` int NOT NULL DEFAULT 0 AFTER `innTriggerId`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change transguid from mediumint unsigned to int (AC uses signed int DEFAULT 0)
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'characters' AND column_name = 'transguid');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `characters` MODIFY `transguid` int DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change latency from mediumint unsigned to int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'characters' AND column_name = 'latency');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `characters` MODIFY `latency` int unsigned DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change idx_name from UNIQUE KEY to regular KEY
-- Check if a UNIQUE index exists on the name column
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'characters'
    AND index_name = 'idx_name' AND non_unique = 0);
SET @sql = IF(@idx_exists > 0,
    'ALTER TABLE `characters` DROP INDEX `idx_name`, ADD KEY `idx_name` (`name`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- character_aura: drop critChance, drop applyResilience
-- AC has no critChance or applyResilience columns
-- ============================================================================

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_aura' AND column_name = 'critChance');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_aura` DROP COLUMN `critChance`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_aura' AND column_name = 'applyResilience');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `character_aura` DROP COLUMN `applyResilience`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- pet_aura: drop critChance, drop applyResilience
-- Also fix amount/base_amount types: TC uses mediumint, AC uses int (nullable)
-- ============================================================================

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_aura' AND column_name = 'critChance');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `pet_aura` DROP COLUMN `critChance`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_aura' AND column_name = 'applyResilience');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `pet_aura` DROP COLUMN `applyResilience`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Fix pet_aura amount columns from mediumint to int (nullable) to match AC
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_aura' AND column_name = 'amount0');
SET @sql = IF(@col_type = 'mediumint',
    'ALTER TABLE `pet_aura` MODIFY `amount0` int DEFAULT NULL, MODIFY `amount1` int DEFAULT NULL, MODIFY `amount2` int DEFAULT NULL, MODIFY `base_amount0` int DEFAULT NULL, MODIFY `base_amount1` int DEFAULT NULL, MODIFY `base_amount2` int DEFAULT NULL',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Change pet_aura.spell from mediumint to int unsigned to match AC
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_aura' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `pet_aura` MODIFY `spell` int unsigned NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- auctionhouse: drop Flags column (AC does not have this column)
-- ============================================================================
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'auctionhouse' AND column_name = 'Flags');
SET @sql = IF(@col_exists > 0,
    'ALTER TABLE `auctionhouse` DROP COLUMN `Flags`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- corpse: just TRUNCATE (AC and TC have the same structure for corpse)
-- The old script added/removed corpseGuid which is not in either schema
-- ============================================================================
TRUNCATE TABLE `corpse`;

-- ============================================================================
-- Widen mediumint spell columns to int unsigned where AC expects int unsigned
-- These are safe type-widening changes that preserve data
-- ============================================================================

-- character_spell.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `character_spell` MODIFY `spell` int unsigned NOT NULL DEFAULT 0 COMMENT ''Spell Identifier''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- character_talent.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_talent' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `character_talent` MODIFY `spell` int unsigned NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- character_spell_cooldown.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_spell_cooldown' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `character_spell_cooldown` MODIFY `spell` int unsigned NOT NULL DEFAULT 0 COMMENT ''Spell Identifier''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- pet_spell_cooldown.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_spell_cooldown' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `pet_spell_cooldown` MODIFY `spell` int unsigned NOT NULL DEFAULT 0 COMMENT ''Spell Identifier''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- character_aura.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'character_aura' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `character_aura` MODIFY `spell` int unsigned NOT NULL DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- pet_spell.spell: mediumint unsigned -> int unsigned
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'pet_spell' AND column_name = 'spell');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `pet_spell` MODIFY `spell` int unsigned NOT NULL DEFAULT 0 COMMENT ''Spell Identifier''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- recovery_item.ItemEntry: mediumint unsigned -> int unsigned (AC uses int unsigned)
SET @col_type = (SELECT column_type FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'recovery_item' AND column_name = 'ItemEntry');
SET @sql = IF(@col_type = 'mediumint unsigned',
    'ALTER TABLE `recovery_item` MODIFY `ItemEntry` int unsigned DEFAULT 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Add petition_id columns (AC update 2025_09_03_00)
-- These columns exist in current AC base but not in TC
-- ============================================================================

-- petition.petition_id
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'petition' AND column_name = 'petition_id');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `petition` ADD COLUMN `petition_id` int unsigned NOT NULL DEFAULT 0 AFTER `petitionguid`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Populate petition_id from petitionguid
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'petition' AND column_name = 'petition_id');
SET @needs_populate = (SELECT IF(@col_exists > 0, (SELECT COUNT(*) FROM `petition` WHERE `petition_id` = 0), 0));
SET @sql = IF(@needs_populate > 0,
    'UPDATE `petition` SET `petition_id` = CASE WHEN `petitionguid` <= 2147483647 THEN `petitionguid` ELSE `petitionguid` - 2147483648 END WHERE `petition_id` = 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index on petition_id if missing
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'petition' AND index_name = 'idx_petition_id');
SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE `petition` ADD INDEX `idx_petition_id` (`petition_id`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- petition_sign.petition_id
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'petition_sign' AND column_name = 'petition_id');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `petition_sign` ADD COLUMN `petition_id` int unsigned NOT NULL DEFAULT 0 AFTER `petitionguid`',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Populate petition_sign.petition_id from petition table
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'petition_sign' AND column_name = 'petition_id');
SET @needs_populate = (SELECT IF(@col_exists > 0, (SELECT COUNT(*) FROM `petition_sign` WHERE `petition_id` = 0), 0));
SET @sql = IF(@needs_populate > 0,
    'UPDATE `petition_sign` AS `ps` JOIN `petition` AS `p` ON `p`.`petitionguid` = `ps`.`petitionguid` SET `ps`.`petition_id` = `p`.`petition_id` WHERE `ps`.`petition_id` = 0',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index on petition_sign(petition_id, playerguid) if missing
SET @idx_exists = (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE() AND table_name = 'petition_sign' AND index_name = 'idx_petition_id_player');
SET @sql = IF(@idx_exists = 0,
    'ALTER TABLE `petition_sign` ADD INDEX `idx_petition_id_player` (`petition_id`, `playerguid`)',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Update enchantments in item_instance with petition_id prefix
SET @col_exists = (SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'petition' AND column_name = 'petition_id');
SET @sql = IF(@col_exists > 0,
    'UPDATE `item_instance` AS `ii` JOIN `petition` AS `p` ON `p`.`petitionguid` = `ii`.`guid` SET `ii`.`enchantments` = CONCAT(`p`.`petition_id`, SUBSTRING(`ii`.`enchantments`, LOCATE('' '', `ii`.`enchantments`))) WHERE `ii`.`enchantments` IS NOT NULL AND `ii`.`enchantments` <> ''''',
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS=1;
