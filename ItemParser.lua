-- ItemParser.lua

BetterGearScore = BetterGearScore or {}
BetterGearScore.ItemParser = BetterGearScore.ItemParser or {}

local ItemParser = BetterGearScore.ItemParser

ItemParser.EQUIPMENT_SLOTS = {
    { key = "HeadSlot",          name = "Head" },
    { key = "NeckSlot",          name = "Neck" },
    { key = "ShoulderSlot",      name = "Shoulder" },
    { key = "BackSlot",          name = "Back" },
    { key = "ChestSlot",         name = "Chest" },
    { key = "WristSlot",         name = "Wrist" },
    { key = "HandsSlot",         name = "Hands" },
    { key = "WaistSlot",         name = "Waist" },
    { key = "LegsSlot",          name = "Legs" },
    { key = "FeetSlot",          name = "Feet" },
    { key = "Finger0Slot",       name = "Finger 1" },
    { key = "Finger1Slot",       name = "Finger 2" },
    { key = "Trinket0Slot",      name = "Trinket 1" },
    { key = "Trinket1Slot",      name = "Trinket 2" },
    { key = "MainHandSlot",      name = "Main Hand" },
    { key = "SecondaryHandSlot", name = "Off Hand" },
    { key = "RangedSlot",        name = "Ranged" },
}

ItemParser.STAT_MAPPING = {
    ITEM_MOD_STRENGTH_SHORT = "STRENGTH",
    ITEM_MOD_AGILITY_SHORT = "AGILITY",
    ITEM_MOD_INTELLECT_SHORT = "INTELLECT",
    ITEM_MOD_STAMINA_SHORT = "STAMINA",
    ITEM_MOD_SPIRIT_SHORT = "SPIRIT",

    ITEM_MOD_ARMOR = "ARMOR",
    ITEM_MOD_ATTACK_POWER_SHORT = "ATTACKPOWER",
    ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "RANGED_ATTACKPOWER",
    ITEM_MOD_SPELL_POWER_SHORT = "SPELLPOWER",
    ITEM_MOD_HEALING_DONE_SHORT = "HEALING",

    ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "DEFENSE",
    ITEM_MOD_DODGE_RATING_SHORT = "DODGE",
    ITEM_MOD_PARRY_RATING_SHORT = "PARRY",
    ITEM_MOD_BLOCK_RATING_SHORT = "BLOCK",
    ITEM_MOD_CRIT_RATING_SHORT = "CRITICAL",
    ITEM_MOD_HIT_RATING_SHORT = "HIT",
    ITEM_MOD_HASTE_RATING_SHORT = "HASTE",
    ITEM_MOD_EXPERTISE_RATING_SHORT = "EXPERTISE",
    ITEM_MOD_MP5_SHORT = "MP5",
}

function ItemParser:ParseItemStats(itemLink)
    if not itemLink then
        return {}
    end

    local itemName = GetItemInfo(itemLink)

    if not itemName then
        return {}
    end

    local stats = {}

    local itemStats = GetItemStats(itemLink)

    if itemStats then
        for apiStatKey, value in pairs(itemStats) do
            local internalStat = self.STAT_MAPPING[apiStatKey]

            if internalStat and value and value > 0 then
                self:AddStat(stats, internalStat, value)
            end
        end
    end

    self:ScanTooltipStats(itemLink, stats)

    return stats
end

function ItemParser:AddStat(stats, statName, value)
    value = tonumber(value)

    if not value or value <= 0 then
        return
    end

    stats[statName] = math.max(stats[statName] or 0, value)
end

function ItemParser:ScanTooltipStats(itemLink, stats)
    if not itemLink then
        return
    end

    local scannerName = "BetterGearScoreTooltipScanner"
    local scanner = _G[scannerName]

    if not scanner then
        scanner = CreateFrame("GameTooltip", scannerName, nil, "GameTooltipTemplate")
    end

    scanner:SetOwner(UIParent, "ANCHOR_NONE")
    scanner:ClearLines()
    scanner:SetHyperlink(itemLink)

    for i = 1, scanner:NumLines() do
        local leftLine = _G[scannerName .. "TextLeft" .. i]
        local rightLine = _G[scannerName .. "TextRight" .. i]

        local leftText = leftLine and leftLine:GetText()
        local rightText = rightLine and rightLine:GetText()

        if leftText then
            self:ParseTooltipLine(leftText, stats)
        end

        if rightText then
            self:ParseTooltipLine(rightText, stats)
        end
    end

    self:FinalizeWeaponStats(stats)

    scanner:Hide()
end

function ItemParser:ParseTooltipLine(text, stats)
    if not text then
        return
    end

    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")

    self:ParseWeaponTooltipLine(text, stats)
    self:ParseEquipTooltipLine(text, stats)
end

function ItemParser:ParseWeaponTooltipLine(text, stats)
    local minDamage, maxDamage = string.match(text, "^(%d+)%s*%-%s*(%d+)%s+Damage")

    if minDamage and maxDamage then
        self:AddStat(stats, "WEAPON_MIN_DAMAGE", minDamage)
        self:AddStat(stats, "WEAPON_MAX_DAMAGE", maxDamage)
        return
    end

    local speed = string.match(text, "Speed%s+(%d+%.?%d*)")

    if speed then
        self:AddStat(stats, "WEAPON_SPEED", speed)
        return
    end

    local dps = string.match(text, "%((%d+%.?%d*) damage per second%)")

    if dps then
        self:AddStat(stats, "WEAPON_DPS", dps)
        return
    end
end

function ItemParser:FinalizeWeaponStats(stats)
    local minDamage = stats.WEAPON_MIN_DAMAGE
    local maxDamage = stats.WEAPON_MAX_DAMAGE

    if minDamage and maxDamage then
        stats.WEAPON_AVERAGE_DAMAGE = (minDamage + maxDamage) / 2
    end

    if not stats.WEAPON_DPS and stats.WEAPON_AVERAGE_DAMAGE and stats.WEAPON_SPEED and stats.WEAPON_SPEED > 0 then
        stats.WEAPON_DPS = stats.WEAPON_AVERAGE_DAMAGE / stats.WEAPON_SPEED
    end
end

function ItemParser:ParseEquipTooltipLine(text, stats)
    local healing, spellDamage = string.match(
        text,
        "Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects"
    )

    if healing and spellDamage then
        self:AddStat(stats, "HEALING", healing)
        self:AddStat(stats, "SPELLPOWER", spellDamage)
        return
    end

    healing = string.match(
        text,
        "Increases healing done by up to (%d+) for all magical spells and effects"
    )

    if healing then
        self:AddStat(stats, "HEALING", healing)
        return
    end

    healing = string.match(
        text,
        "Increases healing done by magical spells and effects by up to (%d+)"
    )

    if healing then
        self:AddStat(stats, "HEALING", healing)
        return
    end

    local spellPower = string.match(
        text,
        "Increases damage and healing done by magical spells and effects by up to (%d+)"
    )

    if spellPower then
        self:AddStat(stats, "SPELLPOWER", spellPower)
        self:AddStat(stats, "HEALING", spellPower)
        return
    end

    spellPower = string.match(
        text,
        "Increases spell damage and healing by up to (%d+)"
    )

    if spellPower then
        self:AddStat(stats, "SPELLPOWER", spellPower)
        self:AddStat(stats, "HEALING", spellPower)
        return
    end

    local spellDamage = string.match(
        text,
        "Increases damage done by magical spells and effects by up to (%d+)"
    )

    if spellDamage then
        self:AddStat(stats, "SPELLPOWER", spellDamage)
        return
    end

    spellDamage = string.match(
        text,
        "Increases spell damage by up to (%d+)"
    )

    if spellDamage then
        self:AddStat(stats, "SPELLPOWER", spellDamage)
        return
    end

    local mp5 = string.match(text, "Restores (%d+) mana per 5 sec")

    if mp5 then
        self:AddStat(stats, "MP5", mp5)
        return
    end

    local hitRating = string.match(text, "Improves hit rating by (%d+)")

    if hitRating then
        self:AddStat(stats, "HIT", hitRating)
        return
    end

    hitRating = string.match(text, "Increases your hit rating by (%d+)")

    if hitRating then
        self:AddStat(stats, "HIT", hitRating)
        return
    end

    local spellHitRating = string.match(text, "Improves spell hit rating by (%d+)")

    if spellHitRating then
        self:AddStat(stats, "HIT", spellHitRating)
        return
    end

    local critRating = string.match(text, "Improves critical strike rating by (%d+)")

    if critRating then
        self:AddStat(stats, "CRITICAL", critRating)
        return
    end

    critRating = string.match(text, "Increases your critical strike rating by (%d+)")

    if critRating then
        self:AddStat(stats, "CRITICAL", critRating)
        return
    end

    local spellCritRating = string.match(text, "Improves spell critical strike rating by (%d+)")

    if spellCritRating then
        self:AddStat(stats, "CRITICAL", spellCritRating)
        return
    end

    local hasteRating = string.match(text, "Improves haste rating by (%d+)")

    if hasteRating then
        self:AddStat(stats, "HASTE", hasteRating)
        return
    end

    hasteRating = string.match(text, "Increases your haste rating by (%d+)")

    if hasteRating then
        self:AddStat(stats, "HASTE", hasteRating)
        return
    end

    local defenseRating = string.match(text, "Increases defense rating by (%d+)")

    if defenseRating then
        self:AddStat(stats, "DEFENSE", defenseRating)
        return
    end

    defenseRating = string.match(text, "Increases your defense rating by (%d+)")

    if defenseRating then
        self:AddStat(stats, "DEFENSE", defenseRating)
        return
    end

    local dodgeRating = string.match(text, "Increases your dodge rating by (%d+)")

    if dodgeRating then
        self:AddStat(stats, "DODGE", dodgeRating)
        return
    end

    local parryRating = string.match(text, "Increases your parry rating by (%d+)")

    if parryRating then
        self:AddStat(stats, "PARRY", parryRating)
        return
    end

    local blockRating = string.match(text, "Increases your shield block rating by (%d+)")

    if blockRating then
        self:AddStat(stats, "BLOCK", blockRating)
        return
    end

    local expertiseRating = string.match(text, "Increases your expertise rating by (%d+)")

    if expertiseRating then
        self:AddStat(stats, "EXPERTISE", expertiseRating)
        return
    end

    local oldHitPercent = string.match(text, "Improves your chance to hit by (%d+)%%")

    if oldHitPercent then
        self:AddStat(stats, "HIT", tonumber(oldHitPercent) * 15.8)
        return
    end

    local oldCritPercent = string.match(text, "Improves your chance to get a critical strike by (%d+)%%")

    if oldCritPercent then
        self:AddStat(stats, "CRITICAL", tonumber(oldCritPercent) * 22.1)
        return
    end

    local oldDodgePercent = string.match(text, "Increases your chance to dodge an attack by (%d+)%%")

    if oldDodgePercent then
        self:AddStat(stats, "DODGE", tonumber(oldDodgePercent) * 18.9)
        return
    end
end

function ItemParser:GetEquippedItems()
    local equippedItems = {}

    for _, slotInfo in ipairs(self.EQUIPMENT_SLOTS) do
        local slotId = GetInventorySlotInfo(slotInfo.key)
        local itemLink = slotId and GetInventoryItemLink("player", slotId)

        if itemLink then
            local stats = self:ParseItemStats(itemLink)

            equippedItems[slotId] = {
                link = itemLink,
                stats = stats,
                slotName = slotInfo.name,
                slotKey = slotInfo.key,
            }
        end
    end

    return equippedItems
end

function ItemParser:GetItemStatsInSlot(slotId)
    local itemLink = GetInventoryItemLink("player", slotId)

    if itemLink then
        return self:ParseItemStats(itemLink)
    end

    return {}
end

function ItemParser:GetItemName(itemLink)
    if not itemLink then
        return "Unknown"
    end

    local name = GetItemInfo(itemLink)

    return name or "Unknown"
end

function ItemParser:GetSlotName(slotId)
    for _, slotInfo in ipairs(self.EQUIPMENT_SLOTS) do
        local id = GetInventorySlotInfo(slotInfo.key)

        if id == slotId then
            return slotInfo.name
        end
    end

    return "Unknown"
end

function ItemParser:GetSlotKey(slotId)
    for _, slotInfo in ipairs(self.EQUIPMENT_SLOTS) do
        local id = GetInventorySlotInfo(slotInfo.key)

        if id == slotId then
            return slotInfo.key
        end
    end

    return nil
end