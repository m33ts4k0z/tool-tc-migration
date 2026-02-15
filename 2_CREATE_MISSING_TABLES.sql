--
-- 2. Create tables that exist in AzerothCore but not in TrinityCore
-- MySQL 8.4 compatible - all table definitions match current AC base structure
--

SET FOREIGN_KEY_CHECKS=0;

-- ============================================================================
-- character_brew_of_the_month
-- ============================================================================
CREATE TABLE IF NOT EXISTS `character_brew_of_the_month` (
  `guid` int unsigned NOT NULL,
  `lastEventId` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- active_arena_season
-- ============================================================================
CREATE TABLE IF NOT EXISTS `active_arena_season` (
  `season_id` tinyint unsigned NOT NULL,
  `season_state` tinyint unsigned NOT NULL COMMENT 'Supported 2 states: 0 - disabled; 1 - in progress.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default active arena season if empty
INSERT IGNORE INTO `active_arena_season` (`season_id`, `season_state`) VALUES (8, 1);

-- ============================================================================
-- log_arena_fights
-- ============================================================================
CREATE TABLE IF NOT EXISTS `log_arena_fights` (
  `fight_id` int unsigned NOT NULL,
  `time` datetime NOT NULL,
  `type` tinyint unsigned NOT NULL,
  `duration` int unsigned NOT NULL,
  `winner` int unsigned NOT NULL,
  `loser` int unsigned NOT NULL,
  `winner_tr` smallint unsigned NOT NULL,
  `winner_mmr` smallint unsigned NOT NULL,
  `winner_tr_change` smallint NOT NULL,
  `loser_tr` smallint unsigned NOT NULL,
  `loser_mmr` smallint unsigned NOT NULL,
  `loser_tr_change` smallint NOT NULL,
  `currOnline` int unsigned NOT NULL,
  PRIMARY KEY (`fight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- log_arena_memberstats
-- ============================================================================
CREATE TABLE IF NOT EXISTS `log_arena_memberstats` (
  `fight_id` int unsigned NOT NULL,
  `member_id` tinyint unsigned NOT NULL,
  `name` char(20) NOT NULL,
  `guid` int unsigned NOT NULL,
  `team` int unsigned NOT NULL,
  `account` int unsigned NOT NULL,
  `ip` char(15) NOT NULL,
  `damage` int unsigned NOT NULL,
  `heal` int unsigned NOT NULL,
  `kblows` int unsigned NOT NULL,
  PRIMARY KEY (`fight_id`,`member_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- log_encounter
-- ============================================================================
CREATE TABLE IF NOT EXISTS `log_encounter` (
  `time` datetime NOT NULL,
  `map` smallint unsigned NOT NULL,
  `difficulty` tinyint unsigned NOT NULL,
  `creditType` tinyint unsigned NOT NULL,
  `creditEntry` int unsigned NOT NULL,
  `playersInfo` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- log_money (matches current AC base with type column included)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `log_money` (
  `sender_acc` int unsigned NOT NULL,
  `sender_guid` int unsigned NOT NULL,
  `sender_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_ip` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_acc` int unsigned NOT NULL,
  `receiver_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `money` bigint unsigned NOT NULL,
  `topic` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` datetime NOT NULL,
  `type` tinyint NOT NULL COMMENT '1=COD,2=AH,3=GB DEPOSIT,4=GB WITHDRAW,5=MAIL,6=TRADE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- gm_survey: DROP and recreate to match AC structure (adds maxMMR column)
-- ============================================================================
DROP TABLE IF EXISTS `gm_survey`;
CREATE TABLE IF NOT EXISTS `gm_survey` (
  `surveyId` int unsigned NOT NULL AUTO_INCREMENT,
  `guid` int unsigned NOT NULL DEFAULT '0',
  `mainSurvey` int unsigned NOT NULL DEFAULT '0',
  `comment` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `createTime` int unsigned NOT NULL DEFAULT '0',
  `maxMMR` smallint NOT NULL,
  PRIMARY KEY (`surveyId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Player System';

-- ============================================================================
-- item_loot_storage (replaces TC's item_loot_items + item_loot_money)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `item_loot_storage` (
  `containerGUID` int unsigned NOT NULL,
  `itemid` int unsigned NOT NULL,
  `count` int unsigned NOT NULL,
  `item_index` int unsigned NOT NULL DEFAULT '0',
  `randomPropertyId` int NOT NULL,
  `randomSuffix` int unsigned NOT NULL,
  `follow_loot_rules` tinyint unsigned NOT NULL,
  `freeforall` tinyint unsigned NOT NULL,
  `is_blocked` tinyint unsigned NOT NULL,
  `is_counted` tinyint unsigned NOT NULL,
  `is_underthreshold` tinyint unsigned NOT NULL,
  `needs_quest` tinyint unsigned NOT NULL,
  `conditionLootId` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- character_entry_point (replaces TC's character_battleground_data)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `character_entry_point` (
  `guid` int unsigned NOT NULL DEFAULT '0' COMMENT 'Global Unique Identifier',
  `joinX` float NOT NULL DEFAULT '0',
  `joinY` float NOT NULL DEFAULT '0',
  `joinZ` float NOT NULL DEFAULT '0',
  `joinO` float NOT NULL DEFAULT '0',
  `joinMapId` int unsigned NOT NULL DEFAULT '0' COMMENT 'Map Identifier',
  `taxiPath0` int unsigned NOT NULL DEFAULT '0',
  `taxiPath1` int unsigned NOT NULL DEFAULT '0',
  `mountSpell` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Player System';

-- ============================================================================
-- channels_bans
-- ============================================================================
CREATE TABLE IF NOT EXISTS `channels_bans` (
  `channelId` int unsigned NOT NULL,
  `playerGUID` int unsigned NOT NULL,
  `banTime` int unsigned NOT NULL,
  PRIMARY KEY (`channelId`,`playerGUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- channels_rights
-- ============================================================================
CREATE TABLE IF NOT EXISTS `channels_rights` (
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `flags` int unsigned NOT NULL,
  `speakdelay` int unsigned NOT NULL,
  `joinmessage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `delaymessage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `moderators` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- character_settings
-- ============================================================================
CREATE TABLE IF NOT EXISTS `character_settings` (
  `guid` int unsigned NOT NULL,
  `source` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`guid`, `source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Player Settings';

-- ============================================================================
-- creature_respawn (replaces TC's respawn table for creatures)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `creature_respawn` (
  `guid` int unsigned NOT NULL DEFAULT '0' COMMENT 'Global Unique Identifier',
  `respawnTime` int unsigned NOT NULL DEFAULT '0',
  `mapId` smallint unsigned NOT NULL DEFAULT '0',
  `instanceId` int unsigned NOT NULL DEFAULT '0' COMMENT 'Instance Identifier',
  PRIMARY KEY (`guid`,`instanceId`),
  KEY `idx_instance` (`instanceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grid Loading System';

-- ============================================================================
-- gameobject_respawn (replaces TC's respawn table for gameobjects)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `gameobject_respawn` (
  `guid` int unsigned NOT NULL DEFAULT '0' COMMENT 'Global Unique Identifier',
  `respawnTime` int unsigned NOT NULL DEFAULT '0',
  `mapId` smallint unsigned NOT NULL DEFAULT '0',
  `instanceId` int unsigned NOT NULL DEFAULT '0' COMMENT 'Instance Identifier',
  PRIMARY KEY (`guid`,`instanceId`),
  KEY `idx_instance` (`instanceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Grid Loading System';

-- ============================================================================
-- instance_saved_go_state_data
-- ============================================================================
CREATE TABLE IF NOT EXISTS `instance_saved_go_state_data` (
  `id` int unsigned NOT NULL COMMENT 'instance.id',
  `guid` int unsigned NOT NULL COMMENT 'gameobject.guid',
  `state` tinyint unsigned DEFAULT '0' COMMENT 'gameobject.state',
  PRIMARY KEY (`id`, `guid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- mail_server_character
-- ============================================================================
CREATE TABLE IF NOT EXISTS `mail_server_character` (
  `guid` int unsigned NOT NULL,
  `mailId` int unsigned NOT NULL,
  PRIMARY KEY (`guid`, `mailId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- mail_server_template
-- ============================================================================
CREATE TABLE IF NOT EXISTS `mail_server_template` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `reqLevel` tinyint unsigned NOT NULL DEFAULT 0,
  `reqPlayTime` int unsigned NOT NULL DEFAULT 0,
  `moneyA` int unsigned NOT NULL DEFAULT 0,
  `moneyH` int unsigned NOT NULL DEFAULT 0,
  `itemA` int unsigned NOT NULL DEFAULT 0,
  `itemCountA` int unsigned NOT NULL DEFAULT 0,
  `itemH` int unsigned NOT NULL DEFAULT 0,
  `itemCountH` int unsigned NOT NULL DEFAULT 0,
  `subject` text NOT NULL,
  `body` text NOT NULL,
  `active` tinyint unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- recovery_item
-- ============================================================================
CREATE TABLE IF NOT EXISTS `recovery_item` (
  `Id` int unsigned NOT NULL AUTO_INCREMENT,
  `Guid` int unsigned NOT NULL DEFAULT 0,
  `ItemEntry` mediumint unsigned NOT NULL DEFAULT 0,
  `Count` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`Id`),
  KEY `idx_guid` (`Guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Recreate game_event_condition_save to match AC structure
-- ============================================================================
DROP TABLE IF EXISTS `game_event_condition_save`;
CREATE TABLE `game_event_condition_save` (
  `eventEntry` tinyint unsigned NOT NULL,
  `condition_id` int unsigned NOT NULL DEFAULT '0',
  `done` float DEFAULT '0',
  PRIMARY KEY (`eventEntry`,`condition_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS=1;
