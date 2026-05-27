-- Commands.lua

local Commands = BetterGearScore.Commands

function Commands:RegisterCommands()
    SLASH_BetterGearScore1 = "/bettergearscore"
    SLASH_BetterGearScore2 = "/bgs"
    SLASH_BetterGearScore3 = "/gs"

    SlashCmdList["BetterGearScore"] = function(msg)
        BetterGearScore.Commands:HandleCommand(msg)
    end
end

function Commands:HandleCommand(msg)
    msg = string.lower(msg or "")

    local command, rest = msg:match("^(%S*)%s*(.-)$")

    if command == "" or command == "help" then
        self:PrintHelp()
    elseif command == "show" or command == "ui" then
        BetterGearScore.UI:Show()
    elseif command == "hide" or command == "close" then
        BetterGearScore.UI:Hide()
    elseif command == "toggle" then
        BetterGearScore.UI:Toggle()
    elseif command == "score" then
        self:PrintBetterGearScore()
    elseif command == "profile" then
        self:HandleProfileCommand(rest)
    elseif command == "profiles" then
        BetterGearScore.Profiles:PrintAvailableProfiles()
    elseif command == "detect" then
        BetterGearScore.TalentDetector:PrintDetectedProfile()
    else
        self:PrintHelp()
    end
end

function Commands:HandleProfileCommand(profileKey)
    
    profileKey = profileKey or ""
    profileKey = string.gsub(profileKey, "^%s+", "")
    profileKey = string.gsub(profileKey, "%s+$", "")

    if profileKey == "auto" then
        BetterGearScoreSavedVars = BetterGearScoreSavedVars or {}
        BetterGearScoreSavedVars.useManualProfile = false
        BetterGearScoreSavedVars.selectedProfile = nil

        local detectedProfile = BetterGearScore.Profiles:GetSelectedProfile()

        print("|cff00ff00BetterGearScore profile detection set to automatic:|r "
            .. BetterGearScore.Profiles:GetProfileDisplayName(detectedProfile))

        BetterGearScore:RefreshUI()
        return
    end

    if profileKey == "" then
        local selectedProfile = BetterGearScore.Profiles:GetSelectedProfile()
        print("|cff00ff00Current BetterGearScore profile:|r "
            .. BetterGearScore.Profiles:GetProfileDisplayName(selectedProfile)
            .. " |cff888888("
            .. string.lower(selectedProfile)
            .. ")|r")
        print("Use |cffffff00/bgs profiles|r to list profiles.")
        print("Use |cffffff00/bgs profile warrior_tank|r to change profile.")
        return
    end

    local normalizedProfile = BetterGearScore.Profiles:NormalizeProfileKey(profileKey)

    if BetterGearScore.Profiles:SetSelectedProfile(normalizedProfile) then
        print("|cff00ff00BetterGearScore profile set to:|r "
            .. BetterGearScore.Profiles:GetProfileDisplayName(normalizedProfile))
    else
        print("|cffff0000Unknown BetterGearScore profile:|r " .. profileKey)
        print("Use |cffffff00/bgs profiles|r to list available profiles.")
    end
end

function Commands:PrintBetterGearScore()
    local data = BetterGearScore.Calculator:GetPlayerBetterGearScore()

    print("|cff00ff00BetterGearScore:|r "
        .. data.profileName
        .. " | Weighted: "
        .. math.floor(data.totalWeightedScore)
        .. " | Raw: "
        .. math.floor(data.totalRawScore))
end

function Commands:PrintHelp()
    print("|cff00ff00BetterGearScore Commands:|r")
    print("/bgs or /gs - Show help")
    print("/bgs show - Open the gear score window")
    print("/bgs hide - Close the gear score window")
    print("/bgs toggle - Toggle the gear score window")
    print("/bgs score - Print your current gear score to chat")
    print("/bgs profile - Show current role profile")
    print("/bgs profiles - List available role profiles")
    print("/bgs detect - Detect and display the current role profile")
    print("/bgs profile warrior_tank - Set role profile")
    print("/bgs profile auto - Use automatic talent detection")
    
end

Commands:RegisterCommands()