-- StatWeights.lua - TBC Stat Priorities

local Weights = BetterGearScore.Weights

Weights.BASE_STATS = {
    "STRENGTH",
    "AGILITY",
    "INTELLECT",
    "STAMINA",
    "SPIRIT",
}

Weights.OTHER_STATS = {
    "ARMOR",
    "ATTACKPOWER",
    "RANGED_ATTACKPOWER",
    "SPELLPOWER",
    "HEALING",
    "DEFENSE",
    "DODGE",
    "PARRY",
    "BLOCK",
    "CRITICAL",
    "HIT",
    "HASTE",
    "MP5",
}

-- TBC stat priority weights (normalized, 0-1 scale)
-- Hit cap is 5% for melee, 6% for casters
-- All roles prioritize hit to cap first
Weights.PROFILE_WEIGHTS = {
    WARRIOR_DPS = {
        STRENGTH = 0.95,        -- Primary stat (→ AP)
        AGILITY = 0.50,         -- Secondary (crit + dodge)
        INTELLECT = 0.0,
        STAMINA = 0.30,         -- Some for survivability
        SPIRIT = 0.0,
        ARMOR = 0.05,
        ATTACKPOWER = 1.0,      -- Highest priority after hit
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.25,
        PARRY = 0.20,
        BLOCK = 0.0,
        CRITICAL = 0.90,        -- Very high for DPS
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.75,
        MP5 = 0.0,
    },

    WARRIOR_TANK = {
        STRENGTH = 0.40,        -- Some for survivability
        AGILITY = 0.45,         -- Dodge is king for tanks
        INTELLECT = 0.0,
        STAMINA = 1.0,          -- PRIMARY - More HP
        SPIRIT = 0.0,
        ARMOR = 1.0,            -- PRIMARY - Physical mitigation
        ATTACKPOWER = 0.25,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 1.0,          -- PRIMARY - Uncrittable at 490
        DODGE = 0.95,           -- Very high
        PARRY = 0.85,           -- Second-best mitigation
        BLOCK = 0.0,
        CRITICAL = 0.10,
        HIT = 0.30,             -- Threat gen, but not mandatory
        HASTE = 0.15,
        MP5 = 0.0,
    },

    PALADIN_DPS = {
        STRENGTH = 1.0,         -- PRIMARY
        AGILITY = 0.30,
        INTELLECT = 0.25,       -- Some mana for rotation
        STAMINA = 0.35,
        SPIRIT = 0.0,
        ARMOR = 0.05,
        ATTACKPOWER = 0.95,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.20,      -- Some seal damage
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.15,
        PARRY = 0.15,
        BLOCK = 0.0,
        CRITICAL = 0.85,        -- High for burst
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.70,
        MP5 = 0.10,
    },

    PALADIN_TANK = {
        STRENGTH = 0.35,
        AGILITY = 0.50,         -- Dodge value high
        INTELLECT = 0.60,       -- Mana for healing
        STAMINA = 1.0,          -- PRIMARY
        SPIRIT = 0.0,
        ARMOR = 0.95,           -- Very high
        ATTACKPOWER = 0.20,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.30,      -- Seal/aura damage
        HEALING = 0.25,         -- Holy Light healing
        DEFENSE = 1.0,          -- PRIMARY
        DODGE = 0.90,           -- Very high
        PARRY = 0.80,
        BLOCK = 0.85,           -- Holy shield is good
        CRITICAL = 0.15,
        HIT = 0.35,
        HASTE = 0.15,
        MP5 = 0.60,             -- Important for healing
    },

    PALADIN_HEALER = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 1.0,        -- PRIMARY
        STAMINA = 0.40,
        SPIRIT = 0.50,          -- Good for regen
        ARMOR = 0.05,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.30,      -- Less important than healing
        HEALING = 1.0,          -- PRIMARY
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.60,        -- Holy crits heal
        HIT = 0.0,
        HASTE = 0.70,           -- GCD reduction
        MP5 = 0.95,             -- VERY HIGH
    },

    HUNTER_DPS = {
        STRENGTH = 0.0,
        AGILITY = 1.0,          -- PRIMARY
        INTELLECT = 0.20,
        STAMINA = 0.35,
        SPIRIT = 0.0,
        ARMOR = 0.08,
        ATTACKPOWER = 0.80,     -- Secondary priority
        RANGED_ATTACKPOWER = 0.95, -- Ranged attacks
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.25,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.90,        -- High for burst
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.85,
        MP5 = 0.15,
    },

    ROGUE_DPS = {
        STRENGTH = 0.60,        -- Some for burst damage
        AGILITY = 1.0,          -- PRIMARY
        INTELLECT = 0.0,
        STAMINA = 0.30,
        SPIRIT = 0.0,
        ARMOR = 0.03,
        ATTACKPOWER = 0.85,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.30,           -- Some survivability
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.95,        -- Very high for combo builder
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.90,
        MP5 = 0.0,
    },

    PRIEST_HEALER = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 1.0,        -- PRIMARY
        STAMINA = 0.40,
        SPIRIT = 0.80,          -- Good for regen
        ARMOR = 0.03,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.25,      -- Less than healing
        HEALING = 1.0,          -- PRIMARY
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.55,        -- Heal crit is valuable
        HIT = 0.0,
        HASTE = 0.75,
        MP5 = 0.95,             -- VERY HIGH
    },

    PRIEST_DPS = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 0.90,       -- High for mana pool
        STAMINA = 0.40,
        SPIRIT = 0.35,
        ARMOR = 0.03,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 1.0,       -- PRIMARY
        HEALING = 0.10,         -- Some value
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.80,        -- Good for burst
        HIT = 1.0,              -- MANDATORY (6%)
        HASTE = 0.85,
        MP5 = 0.40,
    },

    SHAMAN_ELEMENTAL = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 0.95,       -- High for mana
        STAMINA = 0.40,
        SPIRIT = 0.20,
        ARMOR = 0.08,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 1.0,       -- PRIMARY
        HEALING = 0.10,
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.80,
        HIT = 1.0,              -- MANDATORY (6%)
        HASTE = 0.85,
        MP5 = 0.50,
    },

    SHAMAN_ENHANCEMENT = {
        STRENGTH = 0.70,        -- Some for AP
        AGILITY = 0.80,         -- Good for crit + dodge
        INTELLECT = 0.30,       -- Mana for shields
        STAMINA = 0.40,
        SPIRIT = 0.0,
        ARMOR = 0.10,
        ATTACKPOWER = 0.95,     -- HIGH
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.15,      -- Some spell damage
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.25,
        PARRY = 0.15,
        BLOCK = 0.10,
        CRITICAL = 0.85,
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.80,
        MP5 = 0.25,
    },

    SHAMAN_HEALER = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 1.0,        -- PRIMARY
        STAMINA = 0.40,
        SPIRIT = 0.60,          -- Good for regen
        ARMOR = 0.08,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.25,      -- Less than healing
        HEALING = 1.0,          -- PRIMARY
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.55,
        HIT = 0.0,
        HASTE = 0.70,
        MP5 = 1.0,              -- PRIMARY (tide totem, mana spring)
    },

    MAGE_DPS = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 0.95,       -- High for mana
        STAMINA = 0.30,
        SPIRIT = 0.25,
        ARMOR = 0.02,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 1.0,       -- PRIMARY
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.80,        -- Good for burst
        HIT = 1.0,              -- MANDATORY (6%)
        HASTE = 0.85,
        MP5 = 0.35,
    },

    WARLOCK_DPS = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 0.90,
        STAMINA = 0.50,         -- Warlocks stack HP for survivability
        SPIRIT = 0.20,
        ARMOR = 0.02,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 1.0,       -- PRIMARY
        HEALING = 0.0,
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.75,
        HIT = 1.0,              -- MANDATORY (6%)
        HASTE = 0.70,           -- Lower than casters
        MP5 = 0.30,
    },

    DRUID_FERAL = {
        STRENGTH = 0.70,        -- Some for AP in bear
        AGILITY = 1.0,          -- PRIMARY (cat DPS)
        INTELLECT = 0.0,
        STAMINA = 0.45,         -- Important for bear form
        SPIRIT = 0.0,
        ARMOR = 0.20,           -- Bear form mitigation
        ATTACKPOWER = 0.90,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 0.15,
        DODGE = 0.50,           -- Cat dodge
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.95,        -- Very high for cat
        HIT = 1.0,              -- MANDATORY (5%)
        HASTE = 0.85,
        MP5 = 0.0,
    },

    DRUID_TANK = {
        STRENGTH = 0.30,
        AGILITY = 0.80,         -- Dodge is king
        INTELLECT = 0.0,
        STAMINA = 1.0,          -- PRIMARY
        SPIRIT = 0.0,
        ARMOR = 1.0,            -- PRIMARY
        ATTACKPOWER = 0.30,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.0,
        HEALING = 0.0,
        DEFENSE = 0.85,
        DODGE = 0.95,           -- Very high
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.15,
        HIT = 0.40,
        HASTE = 0.20,
        MP5 = 0.0,
    },

    DRUID_BALANCE = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 0.95,       -- High for mana
        STAMINA = 0.40,
        SPIRIT = 0.30,
        ARMOR = 0.05,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 1.0,       -- PRIMARY
        HEALING = 0.15,         -- Some scaling
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.75,
        HIT = 1.0,              -- MANDATORY (6%)
        HASTE = 0.80,
        MP5 = 0.40,
    },

    DRUID_RESTO = {
        STRENGTH = 0.0,
        AGILITY = 0.0,
        INTELLECT = 1.0,        -- PRIMARY
        STAMINA = 0.40,
        SPIRIT = 0.85,          -- Very high for regen
        ARMOR = 0.05,
        ATTACKPOWER = 0.0,
        RANGED_ATTACKPOWER = 0.0,
        SPELLPOWER = 0.30,      -- Less than healing
        HEALING = 1.0,          -- PRIMARY
        DEFENSE = 0.0,
        DODGE = 0.0,
        PARRY = 0.0,
        BLOCK = 0.0,
        CRITICAL = 0.50,
        HIT = 0.0,
        HASTE = 0.75,
        MP5 = 0.90,             -- Very high
    },
}

function Weights:GetWeight(profileKey, statType)
    if not profileKey then
        return 0.0
    end

    local profileWeights = self.PROFILE_WEIGHTS[profileKey]

    if not profileWeights then
        return 0.0
    end

    local weight = profileWeights[statType] or 0.0

    if weight < 0 then
        return 0.0
    end

    if weight > 1 then
        return 1.0
    end

    return weight
end

function Weights:GetProfileWeights(profileKey)
    return self.PROFILE_WEIGHTS[profileKey] or {}
end
