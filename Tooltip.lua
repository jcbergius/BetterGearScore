-- Tooltip.lua

BetterGearScore.Tooltip = BetterGearScore.Tooltip or {}

local Tooltip = BetterGearScore.Tooltip

local function GetTooltipItemLink(tooltip)
    local _, itemLink = tooltip:GetItem()
    return itemLink
end

function Tooltip:AddGearScoreToTooltip(tooltip)
    local itemLink = GetTooltipItemLink(tooltip)

    if not itemLink then
        return
    end

    local profileKey = BetterGearScore.Profiles:GetSelectedProfile()
    local rawScore, weightedScore = BetterGearScore.Calculator:CalculateItemScore(itemLink, profileKey)

    if not rawScore or rawScore <= 0 then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddLine("|cff00ff00BetterGearScore|r - " .. BetterGearScore.Profiles:GetProfileDisplayName(profileKey))
    tooltip:AddDoubleLine("Weighted Score", math.floor(weightedScore), 1, 1, 1, 0, 1, 0)
    tooltip:AddDoubleLine("Raw Stat Budget", math.floor(rawScore), 1, 1, 1, 0.8, 0.8, 0.8)
    
    tooltip:Show()
end

function Tooltip:HookTooltips()
    if self.hooked then
        return
    end

    GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        BetterGearScore.Tooltip:AddGearScoreToTooltip(tooltip)
    end)

    ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
        BetterGearScore.Tooltip:AddGearScoreToTooltip(tooltip)
    end)

    self.hooked = true
end

Tooltip:HookTooltips()