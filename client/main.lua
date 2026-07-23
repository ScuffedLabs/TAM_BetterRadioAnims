if not LoadedResource then return end

local CONST <const> = require "shared.const"
local ANIMATIONS <const> = require "data.animations"

local radioProps = {}
local activeAnimationId
local radioRequested = false
local animationMonitorRunning = false

---@param ped integer
local function removeRadioProp(ped)
    local prop = radioProps[ped]
    if not prop then return end

    radioProps[ped] = nil

    if DoesEntityExist(prop) then
        DeleteEntity(prop)
    end
end

---@param ped integer
local function stopRadioAnimation(ped)
    local currentId = activeAnimationId
    local animation = currentId and ANIMATIONS[currentId]

    if animation and DoesEntityExist(ped) then
        StopAnimTask(ped, animation.dictionary, animation.clip, 2.0)
    end

    if ped == cache.ped then
        activeAnimationId = nil
    end

    removeRadioProp(ped)
end

---@param ped integer
---@param propDefinition RadioPropDefinition
local function createRadioProp(ped, propDefinition)
    removeRadioProp(ped)

    local modelHash = lib.requestModel(propDefinition.model)
    if not modelHash then return end

    local coords = GetEntityCoords(ped)
    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)

    SetModelAsNoLongerNeeded(modelHash)

    if not DoesEntityExist(prop) then
        return
    end

    SetEntityCollision(prop, false, false)
    SetEntityCompletelyDisableCollision(prop, false, false)

    local boneIndex = GetPedBoneIndex(ped, propDefinition.bone)
    local position = propDefinition.position
    local rotation = propDefinition.rotation

    AttachEntityToEntity(prop, ped, boneIndex, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z,
        true, true, false, true, 1, true)

    radioProps[ped] = prop
end

---@param bagName string
---@return integer?
local function resolvePedFromBag(bagName)
    for _ = 1, CONST.LIMITS.ENTITY_RESOLVE_ATTEMPTS do
        local entity = GetEntityFromStateBagName(bagName)

        if entity ~= 0 and DoesEntityExist(entity) and IsEntityAPed(entity) then
            return entity
        end

        Wait(CONST.LIMITS.ENTITY_RESOLVE_DELAY_MS)
    end
end

---@param value unknown
---@return string?
local function validateReplicatedAnimation(value)
    if value == false or value == nil then
        return
    end

    if type(value) ~= "string" or not ANIMATIONS[value] then
        return
    end

    return value
end

---@param ped integer
---@return boolean
local function canUseRadioAnimation(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) then
        return false
    end

    if lib.table.contains(Config.radio.blacklistedPeds, GetEntityModel(ped)) then
        return false
    end

    if Config.radio.disableInVehicles and cache.vehicle then
        return false
    end

    if cache.vehicle then
        local vehicleClass = GetVehicleClass(cache.vehicle)

        if lib.table.contains(Config.radio.blacklistedVehicleClasses, vehicleClass) then
            return false
        end
    end

    return true
end

---@class RadioClothingVariation
---@field collection? string
---@field drawable integer
---@field texture? integer

---@class RadioClothingRule
---@field animation string
---@field priority? integer
---@field clothing? table<string, RadioClothingVariation>
---@field props? table<string, RadioClothingVariation>

---@param ped integer
---@return "male" | "female" | nil
local function getPedGender(ped)
    local model = GetEntityModel(ped)

    if model == CONST.PED_MODELS.MALE then
        return "male"
    end

    if model == CONST.PED_MODELS.FEMALE then
        return "female"
    end
end

---@param ped integer
---@param componentId integer
---@param expected RadioClothingVariation
---@return boolean
local function matchesClothingComponent(ped, componentId, expected)
    local collection = GetPedDrawableVariationCollectionName(ped, componentId) or ""
    local drawable = GetPedDrawableVariationCollectionLocalIndex(ped, componentId)
    local texture = GetPedTextureVariation(ped, componentId)

    return collection == (expected.collection or "") and drawable == expected.drawable and
        (expected.texture == nil or texture == expected.texture)
end

---@param ped integer
---@param componentId integer
---@param expected RadioClothingVariation
---@return boolean
local function matchesPropComponent(ped, componentId, expected)
    local drawable = GetPedPropIndex(ped, componentId)

    if drawable == -1 then
        return expected.clear == true
    end

    if expected.clear then
        return false
    end

    local collection = GetPedPropCollectionName(ped, componentId) or ""
    local localDrawable = GetPedPropCollectionLocalIndex(ped, componentId)
    local texture = GetPedPropTextureIndex(ped, componentId)

    return collection == (expected.collection or "") and localDrawable == expected.drawable and
        (expected.texture == nil or texture == expected.texture)
end

---@param ped integer
---@param componentId integer
---@param expected RadioClothingVariation
---@return boolean
local function matchesPedClothingComponent(ped, componentId, expected)
    local drawable = GetPedDrawableVariation(ped, componentId)
    local texture = GetPedTextureVariation(ped, componentId)

    return drawable == expected.drawable and (expected.texture == nil or texture == expected.texture)
end

---@param ped integer
---@param componentId integer
---@param expected RadioClothingVariation
---@return boolean
local function matchesPedPropComponent(ped, componentId, expected)
    local drawable = GetPedPropIndex(ped, componentId)

    if expected.clear then
        return drawable == -1
    end

    if drawable == -1 then
        return false
    end

    local texture = GetPedPropTextureIndex(ped, componentId)
    return drawable == expected.drawable and (expected.texture == nil or texture == expected.texture)
end

---@param ped integer
---@param clothing table<string, RadioClothingVariation>?
---@param useCollections boolean
---@return boolean
local function matchesClothingSet(ped, clothing, useCollections)
    if not clothing then
        return true
    end

    for componentName, expected in pairs(clothing) do
        local componentId = CONST.CLOTHING_COMPONENTS[componentName]

        if componentId == nil then
            Logger.warn(("Invalid clothing component configured: %s"):format(componentName))
            return false
        end

        local matches

        if useCollections then
            matches = matchesClothingComponent(ped, componentId, expected)
        else
            matches = matchesPedClothingComponent(ped, componentId, expected)
        end

        if not matches then
            return false
        end
    end

    return true
end

---@param ped integer
---@param props table<string, RadioClothingVariation>?
---@param useCollections boolean
---@return boolean
local function matchesPropSet(ped, props, useCollections)
    if not props then
        return true
    end

    for componentName, expected in pairs(props) do
        local componentId = CONST.PROP_COMPONENTS[componentName]

        if componentId == nil then
            Logger.warn(("Invalid prop component configured: %s"):format(componentName))
            return false
        end

        local matches

        if useCollections then
            matches = matchesPropComponent(ped, componentId, expected)
        else
            matches = matchesPedPropComponent(ped, componentId, expected)
        end

        if not matches then
            return false
        end
    end

    return true
end

---@param ped integer
---@param rule RadioAnimationRule
---@param useCollections boolean
---@return boolean
local function matchesAnimationRule(ped, rule, useCollections)
    return matchesClothingSet(ped, rule.clothing, useCollections) and matchesPropSet(ped, rule.props, useCollections)
end

---@param ped integer
---@param rules RadioAnimationRule[]?
---@param useCollections boolean
---@return string?
local function findMatchingRule(ped, rules, useCollections)
    if not rules or #rules == 0 then
        return
    end

    local sortedRules = {}

    for index = 1, #rules do
        sortedRules[index] = rules[index]
    end

    table.sort(sortedRules, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    for index = 1, #sortedRules do
        local rule = sortedRules[index]

        if type(rule.animation) ~= "string"
            or not ANIMATIONS[rule.animation]
        then
            Logger.warn(("Invalid radio animation configured: %s"):format(tostring(rule.animation)))
        elseif matchesAnimationRule(ped, rule, useCollections) then
            return rule.animation
        end
    end
end

---@param ped integer
---@return string?
local function findPedAnimation(ped)
    local model = GetEntityModel(ped)
    local rules = Config.radio.pedAnimations and Config.radio.pedAnimations[model]

    return findMatchingRule(ped, rules, false)
end

---@param ped integer
---@return string?
local function findClothingAnimation(ped)
    local gender = getPedGender(ped)
    if not gender then return end
    local rules = Config.radio.clothingAnimations and Config.radio.clothingAnimations[gender]

    return findMatchingRule(ped, rules, true)
end

---@param ped integer
---@return string
local function getRadioAnimation(ped)
    local model = GetEntityModel(ped)

    local animationId = findMatchingRule(ped, Config.radio.pedAnimations and Config.radio.pedAnimations[model], false)

    if not animationId then
        animationId = findClothingAnimation(ped)
    end

    animationId = animationId
        or Config.radio.defaultAnimation

    if IsPlayerFreeAiming(cache.playerId) then
        local animation = ANIMATIONS[animationId]

        local aimingVariant = animation and animation.aimingVariant or ("%s_aiming"):format(animationId)

        if ANIMATIONS[aimingVariant] then
            animationId = aimingVariant
        end
    end

    return animationId
end

---@param enabled boolean
local function requestRadioState(enabled)
    if not enabled then
        radioRequested = false
        TriggerServerEvent(CONST.EVENTS.SET_RADIO_STATE, false)
        return
    end

    local ped = cache.ped

    if not canUseRadioAnimation(ped) then
        radioRequested = false
        TriggerServerEvent(CONST.EVENTS.SET_RADIO_STATE, false)
        return
    end

    radioRequested = true

    local animationId = getRadioAnimation(ped)

    TriggerServerEvent("scfd_radioanims:server:setRadioState", animationId)
end

local function startAnimationMonitor()
    if animationMonitorRunning or not activeAnimationId then
        return
    end

    animationMonitorRunning = true

    CreateThread(function()
        while activeAnimationId do
            local animationId = activeAnimationId
            local animation = ANIMATIONS[animationId]
            local ped = cache.ped

            if not animation then
                activeAnimationId = nil
                break
            end

            if not canUseRadioAnimation(ped) then
                requestRadioState(false)
                break
            end

            if not IsEntityPlayingAnim(ped, animation.dictionary, animation.clip, 3) then
                playRadioAnimation(ped, animationId, true)
            end

            Wait(250)
        end

        animationMonitorRunning = false
    end)
end

---@param ped integer
---@param animationId string
---@param isLocalPlayer boolean
local function playRadioAnimation(ped, animationId, isLocalPlayer)
    local animation = ANIMATIONS[animationId]
    if not animation or not DoesEntityExist(ped) then return end

    if not lib.requestAnimDict(animation.dictionary) then
        return
    end

    if not IsEntityPlayingAnim(ped, animation.dictionary, animation.clip, 3) then
        TaskPlayAnim(ped, animation.dictionary, animation.clip, 3.0, 3.0, -1, animation.flag, 0.0, false, false, false)
    end

    RemoveAnimDict(animation.dictionary)

    if animation.prop then
        createRadioProp(ped, animation.prop)
    else
        removeRadioProp(ped)
    end

    if isLocalPlayer then
        activeAnimationId = animationId
        startAnimationMonitor()
    end
end


AddStateBagChangeHandler(CONST.STATES.RADIO_ANIMATION, nil, function(bagName, _, value)
    local animationId = validateReplicatedAnimation(value)

    CreateThread(function()
        local ped = resolvePedFromBag(bagName)
        if not ped then return end

        local isLocalPlayer = ped == cache.ped

        if not animationId then
            stopRadioAnimation(ped)
            return
        end

        playRadioAnimation(ped, animationId, isLocalPlayer)
    end)
end)

if Config.radio.useEvents then
    AddEventHandler("pma-voice:radioActive", requestRadioState)

    AddEventHandler("SonoranRadio::API:Talking", requestRadioState)
end

if Config.radio.useKeybind then
    lib.addKeybind({
        name = ("%s_radio"):format(cache.resource),
        description = locale("command.radio_keybind"),
        defaultKey = Config.radio.keybind.keyboard,
        defaultMapper = "KEYBOARD",
        secondaryKey = Config.radio.keybind.controller,
        secondaryMapper = "PAD_DIGITALBUTTON",

        onPressed = function()
            requestRadioState(true)
        end,

        onReleased = function()
            requestRadioState(false)
        end,
    })
end

RegisterCommand("toggleprops", function(_, args)
    local option = args[1] and args[1]:lower()

    if option ~= "true" and option ~= "false" then
        lib.notify({
            title = locale("common.title"),
            description = locale("error.invalid_boolean"),
            type = "error",
        })
        return
    end

    SetResourceKvp(CONST.KVP.USE_PROP_MAPPINGS, option)

    lib.notify({
        title = locale("common.title"),
        description = locale(option == "true" and "success.prop_mappings_enabled" or "success.prop_mappings_disabled"),
        type = "success",
    })
end, false)

TriggerEvent("chat:addSuggestion", "/toggleprops", locale("command.toggle_props"), {
    {
        name = "enabled",
        help = locale("command.toggle_props_parameter"),
    },
})

lib.onCache("vehicle", function(vehicle)
    if not vehicle or not Config.radio.disableInVehicles then
        return
    end

    if radioRequested or activeAnimationId then
        requestRadioState(false)
    end
end)

lib.onCache("ped", function(newPed, oldPed)
    if oldPed and oldPed ~= 0 then
        stopRadioAnimation(oldPed)
    end

    if radioRequested and newPed then
        requestRadioState(true)
    end
end)

---@param ped integer
---@param componentId integer
---@return table
local function getClothingComponentData(ped, componentId)
    return {
        collection = GetPedDrawableVariationCollectionName(ped, componentId) or "",
        drawable = GetPedDrawableVariationCollectionLocalIndex(ped, componentId),
        texture = GetPedTextureVariation(ped, componentId),
    }
end

---@param ped integer
---@param componentId integer
---@return table
local function getPropComponentData(ped, componentId)
    if GetPedPropIndex(ped, componentId) == -1 then
        return { clear = true }
    end

    return {
        collection = GetPedPropCollectionName(ped, componentId) or "",
        drawable = GetPedPropCollectionLocalIndex(ped, componentId),
        texture = GetPedPropTextureIndex(ped, componentId),
    }
end

if Config.debug then
    RegisterCommand(CONST.COMMANDS.DEBUG_CLOTHING, function()
        local ped = cache.ped
        local gender = getPedGender(ped) or "unknown"

        local data = {
            gender = gender,

            clothing = {
                undershirt = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.undershirt),
                mask = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.mask),
                torso = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.torso),
                torso2 = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.torso2),
                badge = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.badge),
                bag = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.bag),
                shoes = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.shoes),
                accessory = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.accessory),
                kevlar = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.kevlar),
                leg = getClothingComponentData(ped, CONST.CLOTHING_COMPONENTS.leg),
            },

            props = {
                watch = getPropComponentData(ped, CONST.PROP_COMPONENTS.watch),
                hat = getPropComponentData(ped, CONST.PROP_COMPONENTS.hat),
                glasses = getPropComponentData(ped, CONST.PROP_COMPONENTS.glasses),
                ears = getPropComponentData(ped, CONST.PROP_COMPONENTS.ears),
                bracelets = getPropComponentData(ped, CONST.PROP_COMPONENTS.bracelets),
            },
        }

        local output = json.encode(data, {
            indent = true,
        })

        lib.print.info(output)
        lib.setClipboard(output)

        lib.notify({
            title = locale("common.title"),
            description = locale("success.clothing_copied"),
            type = "success",
        })
    end, false)
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= cache.resource then return end

    if activeAnimationId then
        TriggerServerEvent(CONST.EVENTS.SET_RADIO_STATE, false)
    end

    for ped in pairs(radioProps) do
        stopRadioAnimation(ped)
    end
end)
