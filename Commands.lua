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
    elseif command == "profile" then
        self:HandleProfileCommand(rest)
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
        print("Use |cffffff00/bgs profile warrior_tank|r to change profile.")
        return
    end

    local normalizedProfile = BetterGearScore.Profiles:NormalizeProfileKey(profileKey)

    if BetterGearScore.Profiles:SetSelectedProfile(normalizedProfile) then
        print("|cff00ff00BetterGearScore profile set to:|r "
            .. BetterGearScore.Profiles:GetProfileDisplayName(normalizedProfile))
    else
        print("|cffff0000Unknown BetterGearScore profile:|r " .. profileKey)
    end
end

function Commands:PrintHelp()
    print("|cff00ff00BetterGearScore Commands:|r")
    print("/bgs profile - Show current role profile")
    print("/bgs profile warrior_tank - Set role profile (e.g., warrior_tank, mage_dps, etc.)")
    print("/bgs profile auto - Use automatic talent detection")
    print("")
    print("|cff00ff00Gear score is displayed in your character pane automatically.|r")
end

Commands:RegisterCommands()