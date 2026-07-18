if not LoadedResource then return end

local CONST <const> = require "shared.const"
local ANIMATIONS <const> = require "data.animations"

---@type table<integer, integer>
local cooldowns = {}

---@param source integer
---@return boolean
local function isValidPlayer(source)
    return source > 0 and GetPlayerEndpoint(source) ~= nil
end

---@param source integer
---@return boolean
local function checkCooldown(source)
    local now = GetGameTimer()
    local expiresAt = cooldowns[source]

    if expiresAt and expiresAt > now then
        return false
    end

    cooldowns[source] = now + CONST.LIMITS.EVENT_COOLDOWN_MS
    return true
end

---@param source integer
---@param animationId string?
local function setRadioState(source, animationId)
    local player = Player(source)
    if not player then return end

    player.state:set(CONST.STATES.RADIO_ANIMATION, animationId or false, true)
end

RegisterNetEvent("scfd_radioanims:server:setRadioState", function(animationId)
    local source = source

    if not isValidPlayer(source) or not checkCooldown(source) then
        return
    end

    if animationId == false or animationId == nil then
        setRadioState(source, nil)
        return
    end

    if type(animationId) ~= "string" then
        return
    end

    if not ANIMATIONS[animationId] then
        Logger.warn(("Player %s requested invalid radio animation %q"):format(source, animationId))

        setRadioState(source, nil)
        return
    end

    local ped = GetPlayerPed(source)

    if ped == 0 or not DoesEntityExist(ped) or IsEntityDead(ped) then
        setRadioState(source, nil)
        return
    end

    setRadioState(source, animationId)
end)

AddEventHandler("playerDropped", function()
    cooldowns[source] = nil
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= cache.resource then return end

    for _, playerId in ipairs(GetPlayers()) do
        setRadioState(tonumber(playerId), nil)
    end
end)
