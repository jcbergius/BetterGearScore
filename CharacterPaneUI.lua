-- CharacterPaneUI.lua

BetterGearScore = BetterGearScore or {}
BetterGearScore.CharacterPaneUI = BetterGearScore.CharacterPaneUI or {}

local CharacterPaneUI = BetterGearScore.CharacterPaneUI

CharacterPaneUI.frame = CharacterPaneUI.frame or nil
CharacterPaneUI.labelText = CharacterPaneUI.labelText or nil
CharacterPaneUI.scoreText = CharacterPaneUI.scoreText or nil
CharacterPaneUI.profileText = CharacterPaneUI.profileText or nil
CharacterPaneUI.eventFrame = CharacterPaneUI.eventFrame or nil
CharacterPaneUI.hooked = CharacterPaneUI.hooked or false

function CharacterPaneUI:GetParentFrame()
    if PaperDollFrame then
        return PaperDollFrame
    end

    if CharacterFrame then
        return CharacterFrame
    end

    return UIParent
end

function CharacterPaneUI:Create()
    if self.frame then
        return self.frame
    end

    local parent = self:GetParentFrame()

    if not parent then
        return nil
    end

    local frame = CreateFrame("Frame", "BetterGearScoreCharacterPaneFrame", parent, "BackdropTemplate")
    frame:SetSize(165, 44)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(999)
    frame:EnableMouse(true)

    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 10,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3,
        },
    })

    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:SetBackdropBorderColor(0, 1, 0, 0.9)

    frame:ClearAllPoints()

    if PaperDollFrame then
        frame:SetPoint("BOTTOMLEFT", PaperDollFrame, "BOTTOMLEFT", 78, 42)
    elseif CharacterFrame then
        frame:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", 78, 48)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    local labelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    labelText:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -6)
    labelText:SetText("|cff00ff00BetterGearScore|r")

    local scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    scoreText:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -2)
    scoreText:SetText("|cffffffff0|r")

    local profileText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    profileText:SetPoint("LEFT", scoreText, "RIGHT", 8, 0)
    profileText:SetWidth(90)
    profileText:SetJustifyH("LEFT")
    profileText:SetText("")

    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")

        local data = BetterGearScore.Calculator:GetPlayerBetterGearScore()

        GameTooltip:AddLine("|cff00ff00BetterGearScore|r")
        GameTooltip:AddLine("Profile: " .. (data.profileName or "Unknown"), 1, 1, 1)
        GameTooltip:AddLine("Weighted Score: " .. math.floor(data.totalWeightedScore or 0), 0, 1, 0)
        GameTooltip:AddLine("Budget Score: " .. math.floor(data.totalRawScore or 0), 0.8, 0.8, 0.8)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Use /bgs show for item details.", 0.7, 0.7, 0.7)

        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.frame = frame
    self.labelText = labelText
    self.scoreText = scoreText
    self.profileText = profileText

    self:Update()

    if CharacterFrame and not CharacterFrame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end

    return frame
end

function CharacterPaneUI:Reanchor()
    if not self.frame then
        return
    end

    local parent = self:GetParentFrame()

    if parent then
        self.frame:SetParent(parent)
    end

    self.frame:ClearAllPoints()
    self.frame:SetFrameStrata("DIALOG")
    self.frame:SetFrameLevel(999)

    if PaperDollFrame then
        self.frame:SetPoint("BOTTOMLEFT", PaperDollFrame, "BOTTOMLEFT", 78, 42)
    elseif CharacterFrame then
        self.frame:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", 78, 48)
    else
        self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

function CharacterPaneUI:Update()
    if not self.frame then
        self:Create()
    end

    if not self.frame or not self.scoreText then
        return
    end

    local data = BetterGearScore.Calculator:GetPlayerBetterGearScore()
    local weightedScore = math.floor(data.totalWeightedScore or 0)

    self.scoreText:SetText("|cffffffff" .. weightedScore .. "|r")

    if self.profileText then
        self.profileText:SetText(data.profileName or "")
    end
end

function CharacterPaneUI:Show()
    local frame = self:Create()

    if not frame then
        return
    end

    self:Reanchor()
    self:Update()
    frame:Show()
end

function CharacterPaneUI:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function CharacterPaneUI:HookCharacterFrame()
    if self.hooked then
        return
    end

    self.hooked = true

    if CharacterFrame then
        CharacterFrame:HookScript("OnShow", function()
            BetterGearScore.CharacterPaneUI:Show()
        end)

        CharacterFrame:HookScript("OnHide", function()
            BetterGearScore.CharacterPaneUI:Hide()
        end)
    end

    if PaperDollFrame then
        PaperDollFrame:HookScript("OnShow", function()
            BetterGearScore.CharacterPaneUI:Show()
        end)

        PaperDollFrame:HookScript("OnHide", function()
            BetterGearScore.CharacterPaneUI:Hide()
        end)
    end
end

function CharacterPaneUI:CreateEventFrame()
    if self.eventFrame then
        return
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")

    eventFrame:SetScript("OnEvent", function()
        BetterGearScore.CharacterPaneUI:HookCharacterFrame()
        BetterGearScore.CharacterPaneUI:Update()

        if CharacterFrame and CharacterFrame:IsShown() then
            BetterGearScore.CharacterPaneUI:Show()
        end
    end)

    self.eventFrame = eventFrame
end

function CharacterPaneUI:Initialize()
    self:CreateEventFrame()
    self:HookCharacterFrame()
    self:Create()

    if CharacterFrame and CharacterFrame:IsShown() then
        self:Show()
    end
end

CharacterPaneUI:Initialize()