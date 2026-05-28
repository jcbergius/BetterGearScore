-- BetterGearScoreCalculator.lua

local Calculator = BetterGearScore.Calculator

Calculator.ITEMIZATION_MODE = "TBC"
Calculator.ITEM_BUDGET_EXPONENT = 1.7095

Calculator.STAT_BUDGET_COST = {
    STRENGTH = 1.00,
    AGILITY = 1.00,
    INTELLECT = 1.00,
    SPIRIT = 1.00,

    -- TBC stamina is cheaper than primary stats in the reverse-engineered budget model.
    STAMINA = 0.67,

    ARMOR = 0.07,
    ATTACKPOWER = 0.50,
    RANGED_ATTACKPOWER = 0.40,

    SPELLPOWER = 0.86,
    HEALING = 0.45,

    DEFENSE = 1.00,
    DODGE = 1.00,
    PARRY = 1.00,
    BLOCK = 1.00,
    CRITICAL = 1.00,
    HIT = 1.00,
    HASTE = 1.00,
    EXPERTISE = 1.00,

    MP5 = 2.00,
}

Calculator.WEAPON_STAT_KEYS = {
    WEAPON_MIN_DAMAGE = true,
    WEAPON_MAX_DAMAGE = true,
    WEAPON_AVERAGE_DAMAGE = true,
    WEAPON_SPEED = true,
    WEAPON_DPS = true,
}

function Calculator:IsWeaponStat(statType)
    return self.WEAPON_STAT_KEYS[statType] == true
end

function Calculator:GetStatBudgetCost(statType)
    return self.STAT_BUDGET_COST[statType] or 1.0
end

function Calculator:CalculateBudgetAdjustedStatValue(statType, value)
    return (value or 0) * self:GetStatBudgetCost(statType)
end

function Calculator:CalculateRawStatBudget(stats)
    local exponent = self.ITEM_BUDGET_EXPONENT or 1.7095
    local total = 0

    for statType, value in pairs(stats or {}) do
        if not self:IsWeaponStat(statType) then
            local budgetValue = self:CalculateBudgetAdjustedStatValue(statType, value)

            if budgetValue > 0 then
                total = total + math.pow(budgetValue, exponent)
            end
        end
    end

    if total <= 0 then
        return 0
    end

    return math.pow(total, 1 / exponent)
end

function Calculator:CalculateWeightedStatScore(stats, profileKey)
    local exponent = self.ITEM_BUDGET_EXPONENT or 1.7095
    local total = 0

    for statType, value in pairs(stats or {}) do
        if not self:IsWeaponStat(statType) then
            local budgetValue = self:CalculateBudgetAdjustedStatValue(statType, value)
            local roleWeight = BetterGearScore.Weights:GetWeight(profileKey, statType)
            local weightedBudgetValue = budgetValue * roleWeight

            if weightedBudgetValue > 0 then
                total = total + math.pow(weightedBudgetValue, exponent)
            end
        end
    end

    if total <= 0 then
        return 0
    end

    return math.pow(total, 1 / exponent)
end

function Calculator:GetWeaponWeightKeys(slotKey, itemLink)
    if slotKey == "RangedSlot" then
        return "RANGED_WEAPON_DPS", "RANGED_WEAPON_DAMAGE"
    end

    if slotKey == "MainHandSlot" or slotKey == "SecondaryHandSlot" then
        return "MELEE_WEAPON_DPS", "MELEE_WEAPON_DAMAGE"
    end

    local equipLoc = nil

    if itemLink then
        equipLoc = select(9, GetItemInfo(itemLink))
    end

    if equipLoc == "INVTYPE_RANGED"
        or equipLoc == "INVTYPE_RANGEDRIGHT"
        or equipLoc == "INVTYPE_THROWN"
        or equipLoc == "INVTYPE_RELIC" then
        return "RANGED_WEAPON_DPS", "RANGED_WEAPON_DAMAGE"
    end

    return "MELEE_WEAPON_DPS", "MELEE_WEAPON_DAMAGE"
end

function Calculator:CalculateWeaponBudgetScore(stats)
    local weaponDps = stats and stats.WEAPON_DPS or 0
    local averageDamage = stats and stats.WEAPON_AVERAGE_DAMAGE or 0

    if not weaponDps or weaponDps <= 0 then
        return 0
    end

    return weaponDps + ((averageDamage or 0) * 0.15)
end

function Calculator:CalculateWeaponScore(stats, profileKey, slotKey, itemLink)
    if not stats then
        return 0
    end

    local weaponDps = stats.WEAPON_DPS or 0
    local averageDamage = stats.WEAPON_AVERAGE_DAMAGE or 0

    if weaponDps <= 0 then
        return 0
    end

    local dpsWeightKey, damageWeightKey = self:GetWeaponWeightKeys(slotKey, itemLink)

    local dpsWeight = BetterGearScore.Weights:GetWeight(profileKey, dpsWeightKey)
    local damageWeight = BetterGearScore.Weights:GetWeight(profileKey, damageWeightKey)

    return (weaponDps * dpsWeight) + (averageDamage * damageWeight)
end

function Calculator:CalculateWeightedScore(stats, profileKey, slotKey, itemLink)
    local weightedStatScore = self:CalculateWeightedStatScore(stats, profileKey)
    local weaponScore = self:CalculateWeaponScore(stats, profileKey, slotKey, itemLink)

    return weightedStatScore + weaponScore
end

function Calculator:CalculateItemScore(itemLink, profileKey, slotKey)
    if not itemLink then
        return 0, 0, {}
    end

    profileKey = profileKey or BetterGearScore.Profiles:GetSelectedProfile()

    local stats = BetterGearScore.ItemParser:ParseItemStats(itemLink)
    local statBudgetScore = self:CalculateRawStatBudget(stats)
    local weaponBudgetScore = self:CalculateWeaponBudgetScore(stats)
    local budgetScore = statBudgetScore + weaponBudgetScore
    local weightedScore = self:CalculateWeightedScore(stats, profileKey, slotKey, itemLink)

    return budgetScore, weightedScore, stats, statBudgetScore, weaponBudgetScore
end

function Calculator:CalculateTotalBetterGearScore(profileKey)
    profileKey = profileKey or BetterGearScore.Profiles:GetSelectedProfile()

    local equippedItems = BetterGearScore.ItemParser:GetEquippedItems()

    local totalRawScore = 0
    local totalWeightedScore = 0
    local itemScores = {}

    for slot, item in pairs(equippedItems) do
        local statBudgetScore = self:CalculateRawStatBudget(item.stats)
        local weaponBudgetScore = self:CalculateWeaponBudgetScore(item.stats)
        local rawScore = statBudgetScore + weaponBudgetScore
        local weightedScore = self:CalculateWeightedScore(item.stats, profileKey, item.slotKey, item.link)

        totalRawScore = totalRawScore + rawScore
        totalWeightedScore = totalWeightedScore + weightedScore

        itemScores[slot] = {
            rawScore = rawScore,
            weightedScore = weightedScore,
            statBudgetScore = statBudgetScore,
            weaponBudgetScore = weaponBudgetScore,
            stats = item.stats,
            link = item.link,
            slotName = item.slotName,
            slotKey = item.slotKey,
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