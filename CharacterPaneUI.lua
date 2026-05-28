-- CharacterPaneUI.lua - Embed gear score into character pane

local UI = BetterGearScore.UI

-- Character pane frame info
UI.CHAR_PANE_PARENT = "PaperDollFrame"
UI.charPaneFrame = nil
UI.charPaneText = nil

function UI:CreateCharacterPaneFrame()
    if self.charPaneFrame then
        return
    end

    -- Create frame to hold gear score info in character pane
    local parent = _G[self.CHAR_PANE_PARENT]
    if not parent then
        return
    end

    -- Create container frame below the attribute list
    local frame = CreateFrame("Frame", "BetterGearScoreCharPaneFrame", parent)
    frame:SetSize(200, 60)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -420)

    -- Background
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.15, 0.7)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.8)

    -- Title
    local titleText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -5)
    titleText:SetText("|cff00ff00Gear Score|r")
    titleText:SetWidth(185)
    titleText:SetJustifyH("LEFT")

    -- Score display
    local scoreText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    scoreText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -8)
    scoreText:SetText("0")
    scoreText:SetTextColor(1, 1, 0.5)

    -- Profile name
    local profileText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    profileText:SetPoint("TOPLEFT", scoreText, "BOTTOMLEFT", 0, -5)
    profileText:SetText("")
    profileText:SetWidth(185)
    profileText:SetJustifyH("LEFT")
    profileText:SetTextColor(0.8, 0.8, 0.8)

    self.charPaneFrame = frame
    self.charPaneScoreText = scoreText
    self.charPaneProfileText = profileText
end

function UI:UpdateCharacterPane()
    -- Make sure frame exists
    if not self.charPaneFrame then
        self:CreateCharacterPaneFrame()
    end

    if not self.charPaneFrame or not self.charPaneFrame:IsVisible() then
        return
    end

    local data = BetterGearScore.Calculator:GetPlayerBetterGearScore()

    if self.charPaneScoreText then
        self.charPaneScoreText:SetText(math.floor(data.totalWeightedScore or 0))
    end

    if self.charPaneProfileText then
        self.charPaneProfileText:SetText("Profile: " .. (data.profileName or "Unknown"))
    end
end

-- Hook into character pane updates
local origPaperDollFrame_UpdateStats = PaperDollFrame_UpdateStats
function PaperDollFrame_UpdateStats()
    origPaperDollFrame_UpdateStats()
    if BetterGearScore.UI then
        BetterGearScore.UI:UpdateCharacterPane()
    end
end

-- Show the frame when character pane opens
local orig_ShowUIPanel = ShowUIPanel
function ShowUIPanel(frame, show)
    if frame == CharacterFrame then
        if not show then
            if BetterGearScore.UI and BetterGearScore.UI.charPaneFrame then
                BetterGearScore.UI.charPaneFrame:Hide()
            end
        else
            if BetterGearScore.UI then
                BetterGearScore.UI:CreateCharacterPaneFrame()
                if BetterGearScore.UI.charPaneFrame then
                    BetterGearScore.UI.charPaneFrame:Show()
                    BetterGearScore.UI:UpdateCharacterPane()
                end
            end
        end
    end
    return orig_ShowUIPanel(frame, show)
end
