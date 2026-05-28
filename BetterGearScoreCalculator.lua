-- BetterGearScoreCalculator.lua

local Calculator = BetterGearScore.Calculator

-- Stat normalization factors: Convert all stats to equivalent value scale
-- These represent how much value 1 point of each stat is worth relative to others
-- Based on TBC stat valuations
Calculator.STAT_NORMALIZATION = {
    STRENGTH = 1.0,           -- 1 STR = 1 AP (base unit)
    AGILITY = 0.6,            -- 1 AGI ≈ 0.6 AP + dodge value
    INTELLECT = 0.5,          -- 1 INT ≈ 15 mana (less valuable than pure damage stats)
    STAMINA = 0.25,           -- 1 STA = 10 HP (10:1 ratio)
    SPIRIT = 0.35,            -- 1 SPIRIT ≈ mp5 regen + defensive value
    ARMOR = 0.01,             -- 1 ARMOR ≈ 0.01 physical damage reduction
    ATTACKPOWER = 1.0,        -- AP is base unit
    RANGED_ATTACKPOWER = 0.95, -- Ranged AP slightly less valuable
    SPELLPOWER = 0.75,        -- Spell damage is less scalable than AP
    HEALING = 0.8,            -- Healing power is valuable but not as much as SP
    DEFENSE = 0.5,            -- Defense has diminishing returns
    DODGE = 0.8,              -- Dodge is valuable for mitigation
    PARRY = 0.75,             -- Parry is slightly less valuable than dodge
    BLOCK = 0.6,              -- Block value varies by class
    CRITICAL = 1.2,           -- Crit is highly valuable
    HIT = 1.5,                -- Hit is extremely valuable (mandatory stat)
    HASTE = 0.9,              -- Haste is valuable but less critical than hit
    MP5 = 1.3,                -- MP5 is very valuable for healers
}

function Calculator:CalculateRawStatBudget(stats)
    local budget = 0

    for _, value in pairs(stats or {}) do
        budget = budget + value
    end

    return budget
end

function Calculator:CalculateNormalizedStatValue(statType, value)
    -- Convert raw stat value to normalized equivalent
    local normalizationFactor = self.STAT_NORMALIZATION[statType] or 1.0
    return (value or 0) * normalizationFactor
end

function Calculator:CalculateWeightedScore(stats, profileKey)
    local score = 0

    for statType, value in pairs(stats or {}) do
        -- First normalize the stat to common scale
        local normalizedValue = self:CalculateNormalizedStatValue(statType, value)
        -- Then apply class/role-specific weight
        local weight = BetterGearScore.Weights:GetWeight(profileKey, statType)
        score = score + (normalizedValue * weight)
    end

    return score
end

function Calculator:CalculateItemScore(itemLink, profileKey)
    if not itemLink then
        return 0, 0, {}
    end

    profileKey = profileKey or BetterGearScore.Profiles:GetSelectedProfile()

    local stats = BetterGearScore.ItemParser:ParseItemStats(itemLink)
    local rawScore = self:CalculateRawStatBudget(stats)
    local weightedScore = self:CalculateWeightedScore(stats, profileKey)

    return rawScore, weightedScore, stats
end

function Calculator:CalculateTotalBetterGearScore(profileKey)
    profileKey = profileKey or BetterGearScore.Profiles:GetSelectedProfile()

    local equippedItems = BetterGearScore.ItemParser:GetEquippedItems()

    local totalRawScore = 0
    local totalWeightedScore = 0
    local itemScores = {}

    for slot, item in pairs(equippedItems) do
        local rawScore = self:CalculateRawStatBudget(item.stats)
        local weightedScore = self:CalculateWeightedScore(item.stats, profileKey)

        totalRawScore = totalRawScore + rawScore
        totalWeightedScore = totalWeightedScore + weightedScore

        itemScores[slot] = {
            rawScore = rawScore,
            weightedScore = weightedScore,
            stats = item.stats,
            link = item.link,
            slotName = item.slotName,
        }
    end

    return {
        profileKey = profileKey,
        profileName = BetterGearScore.Profiles:GetProfileDisplayName(profileKey),
        totalRawScore = totalRawScore,
        totalWeightedScore = totalWeightedScore,
        itemScores = itemScores,
    }
end

function Calculator:GetPlayerClass()
    local _, classFileName = UnitClass("player")
    return classFileName
end

function Calculator:GetPlayerBetterGearScore()
    local profileKey = BetterGearScore.Profiles:GetSelectedProfile()
    return self:CalculateTotalBetterGearScore(profileKey)
end