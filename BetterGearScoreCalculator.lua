-- BetterGearScoreCalculator.lua

local Calculator = BetterGearScore.Calculator

function Calculator:CalculateRawStatBudget(stats)
    local budget = 0

    for _, value in pairs(stats or {}) do
        budget = budget + value
    end

    return budget
end

function Calculator:CalculateWeightedScore(stats, profileKey)
    local score = 0

    for statType, value in pairs(stats or {}) do
        local weight = BetterGearScore.Weights:GetWeight(profileKey, statType)
        score = score + (value * weight)
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