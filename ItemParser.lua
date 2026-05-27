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

    -- First pass: use Blizzard's parsed item stats.
    local itemStats = GetItemStats(itemLink)

    if itemStats then
        for apiStatKey, value in pairs(itemStats) do
            local internalStat = self.STAT_MAPPING[apiStatKey]
            if internalStat and value and value > 0 then
                stats[internalStat] = (stats[internalStat] or 0) + value
            end
        end
    end

    -- Second pass: scan green Equip lines that Classic often does not expose via GetItemStats.
    self:AddTooltipEquipStats(itemLink, stats)

    return stats
end

function ItemParser:AddStat(stats, statName, value)
    value = tonumber(value)

    if not value or value <= 0 then
        return
    end

    stats[statName] = math.max(stats[statName] or 0, value)
end

function ItemParser:AddTooltipEquipStats(itemLink, stats)
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
        local line = _G[scannerName .. "TextLeft" .. i]
        local text = line and line:GetText()

        if text then
            self:ParseTooltipLine(text, stats)
        end
    end

    scanner:Hide()
end

function ItemParser:ParseTooltipLine(text, stats)
    if not text then
        return
    end

    -- Example:
    -- Equip: Increases healing done by up to 42 and damage done by up to 14 for all magical spells and effects.
    local healing, spellDamage = string.match(
        text,
        "Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects"
    )

    if healing and spellDamage then
        self:AddStat(stats, "HEALING", healing)
        self:AddStat(stats, "SPELLPOWER", spellDamage)
        return
    end

    -- Example:
    -- Equip: Increases healing done by up to 42 for all magical spells and effects.
    healing = string.match(
        text,
        "Increases healing done by up to (%d+) for all magical spells and effects"
    )

    if healing then
        self:AddStat(stats, "HEALING", healing)
        return
    end

    -- Example:
    -- Equip: Increases damage and healing done by magical spells and effects by up to 23.
    local spellPower = string.match(
        text,
        "Increases damage and healing done by magical spells and effects by up to (%d+)"
    )

    if spellPower then
        self:AddStat(stats, "SPELLPOWER", spellPower)
        self:AddStat(stats, "HEALING", spellPower)
        return
    end

    -- Example:
    -- Equip: Increases damage done by magical spells and effects by up to 14.
    spellDamage = string.match(
        text,
        "Increases damage done by magical spells and effects by up to (%d+)"
    )

    if spellDamage then
        self:AddStat(stats, "SPELLPOWER", spellDamage)
        return
    end

    -- Example:
    -- Equip: Restores 7 mana per 5 sec.
    local mp5 = string.match(text, "Restores (%d+) mana per 5 sec")

    if mp5 then
        self:AddStat(stats, "MP5", mp5)
        return
    end

    -- Example:
    -- Equip: Improves your chance to hit by 1%.
    local hit = string.match(text, "Improves your chance to hit by (%d+)%%")

    if hit then
        self:AddStat(stats, "HIT", hit)
        return
    end

    -- Example:
    -- Equip: Improves your chance to get a critical strike by 1%.
    local crit = string.match(text, "Improves your chance to get a critical strike by (%d+)%%")

    if crit then
        self:AddStat(stats, "CRITICAL", crit)
        return
    end

    -- Example:
    -- Equip: Increases your chance to dodge an attack by 1%.
    local dodge = string.match(text, "Increases your chance to dodge an attack by (%d+)%%")

    if dodge then
        self:AddStat(stats, "DODGE", dodge)
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