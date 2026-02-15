--
-- 4. Cleanup and convert spells from TrinityCore to AzerothCore format
-- MySQL 8.4 compatible: uses ROW_NUMBER() window function instead of user variables
-- Backtick-quotes reserved words where needed
--

-- Fix talentGroupsCount=0 (AC expects at least 1)
UPDATE `characters` SET `talentGroupsCount` = 1 WHERE `talentGroupsCount` = 0;

-- ============================================================================
-- Remove spells that should not be in character_spell
-- Uses lookup tables created in file 1
-- ============================================================================

DELETE s FROM `character_spell` s JOIN `__del_ability_spell` t ON s.spell = t.spell; -- Remove all spells from spellability.dbc
DELETE s FROM `character_spell` s JOIN `__del_override_spell` t ON s.spell = t.spell; -- Remove all spells from overridespell.dbc
DELETE s FROM `character_spell` s JOIN `__del_shapeshift_spell` t ON s.spell = t.spell; -- Remove all spells from shapeshift.dbc
DELETE s FROM `character_spell` s JOIN `__del_spell_learn_spell` t ON s.spell = t.spell; -- Remove all spells from old spell_learn_spell table
DELETE s FROM `character_spell` s JOIN `__del_talent_rest_ranks` t ON s.spell = t.spell; -- Remove all talents which should not be in character_spell table
DELETE s FROM `character_spell` s JOIN `__playercreateinfo_spell` t ON s.spell = t.spell JOIN `characters` c ON s.guid = c.guid WHERE (t.racemask = 0 OR (1 << (c.race - 1)) & t.racemask) AND (t.classmask = 0 OR (1 << (c.class - 1)) & t.classmask); -- Remove all spells from playercreateinfo_spell
DELETE s FROM `character_spell` s JOIN `__profession_autolearn` t ON s.spell = t.spell; -- Remove all spells that are automatically learned from certain skill level
DELETE s FROM `character_spell` s JOIN `characters` c ON s.guid = c.guid WHERE s.spell = 674 AND c.class = 7; -- Remove Dual Wield From shamans
DELETE s FROM `character_spell` s JOIN `__del_talent_pyroblast` t1 ON s.spell = t1.spell LEFT JOIN `__del_talent_pyroblast2` t2 ON t1.spell = t2.spell WHERE t2.spell IS NULL;

-- ============================================================================
-- Restore lower ranks not saved (dependant was not saved)
-- ============================================================================
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 16);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 15);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 14);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 13);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 12);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 11);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 10);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 9);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 8);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 7);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 6);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 5);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 4);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 3);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell_id, 255 FROM `character_spell` s JOIN `__spell_ranks` t ON s.spell = t.spell_id JOIN `__spell_ranks` t2 ON t.first_spell_id = t2.first_spell_id AND (t.rank - 1) = t2.rank WHERE t.rank = 2);

-- ============================================================================
-- Set specMask for all spells
-- ============================================================================
UPDATE `character_spell` SET `specMask` = 255; -- Set specMask of all spells to 255
UPDATE `character_spell` s JOIN `__del_talent_pyroblast` t ON s.spell = t.spell SET s.specMask = 0; -- Set specMask to 0 for spells added to spellbook

-- ============================================================================
-- Add missing profession spells
-- ============================================================================
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell, 255 FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell JOIN `__profession_skill` t2 ON t.skill = t2.skill AND (t.rank - 1) = t2.rank WHERE t.rank = 6);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell, 255 FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell JOIN `__profession_skill` t2 ON t.skill = t2.skill AND (t.rank - 1) = t2.rank WHERE t.rank = 5);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell, 255 FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell JOIN `__profession_skill` t2 ON t.skill = t2.skill AND (t.rank - 1) = t2.rank WHERE t.rank = 4);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell, 255 FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell JOIN `__profession_skill` t2 ON t.skill = t2.skill AND (t.rank - 1) = t2.rank WHERE t.rank = 3);
INSERT IGNORE INTO `character_spell` (SELECT s.guid, t2.spell, 255 FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell JOIN `__profession_skill` t2 ON t.skill = t2.skill AND (t.rank - 1) = t2.rank WHERE t.rank = 2);

-- ============================================================================
-- Insert skill if missing (core would do this, but we need it for the queries below)
-- ============================================================================
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 6);
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 5);
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 4);
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 3);
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 2);
INSERT IGNORE INTO `character_skills` (SELECT s.guid, t.skill, 1, t.maxvalue FROM `__profession_skill` t JOIN `character_spell` s ON t.spell = s.spell WHERE t.rank = 1);

-- ============================================================================
-- Update max allowed skill based on spells
-- ============================================================================
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 6 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 5 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 4 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 3 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 2 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
UPDATE `character_skills` cs JOIN `__profession_skill` t ON cs.skill = t.skill LEFT JOIN `character_spell` s ON cs.guid = s.guid AND t.spell = s.spell SET cs.max = (t.maxvalue - 75) WHERE t.rank = 1 AND s.guid IS NULL AND cs.max > (t.maxvalue - 75);
DELETE FROM `character_skills` WHERE `max` = 0;
UPDATE `character_skills` SET `value` = `max` WHERE `value` > `max`;

-- ============================================================================
-- Remove primary professions when having more than 2
-- MySQL 8.4 compatible: uses ROW_NUMBER() window function instead of user variables
-- (The old @cnt/@prevguid pattern is unreliable in MySQL 8.0+)
-- ============================================================================

-- First: delete excess profession skills (keep only the first 2 per character)
DELETE s FROM `character_skills` s
JOIN (
    SELECT guid, skill
    FROM (
        SELECT cs.guid, cs.skill,
               ROW_NUMBER() OVER (PARTITION BY cs.guid ORDER BY cs.skill) AS rn
        FROM `character_skills` cs
        JOIN `__profession_skill` t ON cs.skill = t.skill AND t.rank = 6
    ) ranked
    WHERE rn > 2
) excess ON s.guid = excess.guid AND s.skill = excess.skill;

-- Now delete main profession spells if skill is missing
DELETE s FROM `character_spell` s JOIN `__profession_skill` t ON s.spell = t.spell LEFT JOIN `character_skills` cs ON s.guid = cs.guid AND t.skill = cs.skill WHERE cs.guid IS NULL;

-- ============================================================================
-- Remove double specialties (always leaves last from the list)
-- ============================================================================

-- Alchemy
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 28677 WHERE s.spell = 28672;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 28675 WHERE s.spell = 28672;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 28675 WHERE s.spell = 28677;
-- Blacksmithing
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 9787 WHERE s.spell = 9788;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 17041 WHERE s.spell = 17040;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 17039 WHERE s.spell = 17040;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 17039 WHERE s.spell = 17041;
-- Leatherworking
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 10658 WHERE s.spell = 10656;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 10660 WHERE s.spell = 10656;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 10660 WHERE s.spell = 10658;
-- Tailoring
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 26801 WHERE s.spell = 26798;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 26797 WHERE s.spell = 26798;
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 26797 WHERE s.spell = 26801;
-- Engineering
DELETE s FROM `character_spell` s JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = 20219 WHERE s.spell = 20222;

-- ============================================================================
-- Remove spells missing their required spell
-- Run 3 times: first - normal specialty removed, second - recipes from specialty
-- and specialty of specialty (blacksmithing only), third - recipes of specialty of specialty
-- ============================================================================
DELETE s FROM `character_spell` s JOIN `__profession_spell_req_spell` t ON s.spell = t.spell LEFT JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = t.reqspell WHERE s2.guid IS NULL;
DELETE s FROM `character_spell` s JOIN `__profession_spell_req_spell` t ON s.spell = t.spell LEFT JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = t.reqspell WHERE s2.guid IS NULL;
DELETE s FROM `character_spell` s JOIN `__profession_spell_req_spell` t ON s.spell = t.spell LEFT JOIN `character_spell` s2 ON s.guid = s2.guid AND s2.spell = t.reqspell WHERE s2.guid IS NULL;

-- Remove spells missing their required skill (the same spells are removed when setting skill to 0)
DELETE s FROM `character_spell` s JOIN `__profession_spell_req_skill` t ON s.spell = t.spell LEFT JOIN `character_skills` cs ON s.guid = cs.guid AND t.reqskill = cs.skill WHERE cs.guid IS NULL;

-- ============================================================================
-- GBoS fix
-- ============================================================================
UPDATE `character_spell` s LEFT JOIN `character_talent` t ON s.guid = t.guid AND t.spell = 20911 SET s.specMask = 0 WHERE s.spell = 25899 AND t.guid IS NULL;
UPDATE `character_spell` s JOIN `character_talent` t ON s.guid = t.guid AND t.spell = 20911 SET s.specMask = t.specMask WHERE s.spell = 25899;

-- ============================================================================
-- Add activation spells to all characters with dual spec
-- ============================================================================
REPLACE INTO `character_spell`
SELECT guid, 63645, 255 FROM `characters` WHERE `talentGroupsCount` > 1;

REPLACE INTO `character_spell`
SELECT guid, 63644, 255 FROM `characters` WHERE `talentGroupsCount` > 1;
