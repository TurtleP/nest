local bit = require("bit")

local PATH    = (...):gsub('%.[^%.]+$', '')
local utility = require(PATH .. ".utility")

local flags  = {}
local config = {}

-- Enable Nintendo Switch // 1
flags.USE_HAC = bit.lshift(1, 0)
--< Enable Nintendo 3DS   // 2
flags.USE_CTR = bit.lshift(1, 1)
--< Internal flag for checking either console // 3
flags.HORIZON = bit.bor(flags.USE_CTR, flags.USE_HAC)

local sizes = {}

sizes[flags.USE_HAC] = {}
sizes[flags.USE_CTR] = {}

local function map(t, values)
    for _, value in ipairs(values) do
        table.insert(t, value)
    end
end

local ctrMapping =
{
    { {0,  0  }, {400, 240}, "left",     nil       },
    { {0,  0  }, {400, 240}, "right",    nil       },
    { {40, 240}, {320, 240}, "bottom", { 40, 240 } }
}

map(sizes[flags.USE_CTR], ctrMapping)

local hacMapping =
{
    { {0, 0}, {1280, 720}, nil, nil }
}

map(sizes[flags.USE_HAC], hacMapping)

-- Add flags
flags.base = 0
function config.addFlags(...)
    local add = {...}

    assert(#add > 0, "Cannot append zero flags")

    local success, typename = utility.any(add, "number")
    assert(success, string.format("Number expected, got %s", typename))

    flags.base = bit.bor(unpack(add))

    -- make sure we don't enable both consoles
    if bit.band(flags.HORIZON, flags.base) == flags.HORIZON then
        error("Cannot set both USE_HAC and USE_CTR flags.")
    end
end

-- Remove flags
function config.remFlags(...)
    local args = {...}

    -- use ipairs for explicit logic
    for _, value in ipairs(args) do
        flags.base = bit.band(flags.base, bit.bnot(value))
    end
end

function config.areEmpty()
    return flags.base == 0
end

function config.getFlags()
    return flags.base
end

-- Check if we have a specific flag
function config.hasFlag(flag)
    return bit.band(flags.base, flag) == flag
end

-- Get which flag is used
-- @flags should be bor'd already
-- Returns the value of the flag
function config.whichFlag(borFlags)
    return bit.band(flags.base, borFlags)
end

config.flags = flags
config.sizes = sizes

return config