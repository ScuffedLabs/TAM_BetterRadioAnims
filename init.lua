LoadedResource = false

assert(lib,
    "ox_lib is either missing or outdated, please ensure you have the latest version installed! \n https://github.com/communityox/ox_lib/releases/latest")
assert(lib.checkDependency("ox_lib", '3.31.3'),
    "ox_lib is outdated! Please ensure you upgrade to the latest version! \n https://github.com/communityox/ox_lib/releases/latest")

Config = lib.load("data.configuration")
local resourceCfg = {
    expectedName = "scfd_radioanims",
    expectedAuthor = "Scuffed Labs",
    expectedDescription = "Better Radio Animations by Scuffed Labs",
    fileCheck = {
        "locales/en.json",
        "LICENSE.md",
        "data/configuration.lua",
        "data/animations.lua",
    },
}

local function fail()
    CreateThread(function()
        while true do
            Wait(15000)
            Logger.warn("Failed to start resource! Please fix failed startup checks.")
        end
    end)

    return false
end

local function checkFiles()
    for i = 1, #resourceCfg.fileCheck do
        local file = resourceCfg.fileCheck[i]
        local exists = LoadResourceFile(resourceCfg.expectedName, file)

        if not exists then
            return false
        end
    end

    return true
end

local function validate()
    local name = GetCurrentResourceName()
    local author = GetResourceMetadata(name, "author", 0)
    local description = GetResourceMetadata(name, "description", 0)
    local version = GetResourceMetadata(name, "version", 0)
    local metaName = GetResourceMetadata(name, "name", 0)

    if name ~= resourceCfg.expectedName then
        return false, ("Resource name mismatch (expected '%s', got '%s')."):format(resourceCfg.expectedName, name)
    end

    if metaName ~= resourceCfg.expectedName then
        return false, "Resource metadata check failed."
    end

    if author ~= resourceCfg.expectedAuthor then
        return false, "Resource metadata check failed."
    end

    if description ~= resourceCfg.expectedDescription then
        return false, "Resource metadata check failed."
    end

    if not version:match("^v%d+%.%d+%.%d+$") then
        return false, "Resource metadata check failed."
    end

    if lib.context == "server" and not checkFiles() then
        return false, "Resource file validation failed."
    end

    return true
end

local checkVersion

if lib.context == "server" and Config.enableVersionCheck then
    function checkVersion()
        local resourceName = GetCurrentResourceName()
        local currentVersion = GetResourceMetadata(resourceName, "version", 0)

        if not currentVersion then
            Logger.error("[Version Checker] Failed to check version. Missing version in fxmanifest.lua")
            return
        end

        local url = ("https://api.scuffedlabs.com/versions/%s"):format(resourceCfg.expectedName)

        PerformHttpRequest(url, function(statusCode, response)
            if statusCode ~= 200 then
                Logger.error(("[Version Checker] Failed to check version. status: %s"):format(statusCode))
                return
            end

            local jsonData = json.decode(response)

            if not jsonData or not jsonData.latestVersion then
                Logger.error("[Version Checker] Invalid API response")
                return
            end

            local latestVersion = jsonData.latestVersion

            if currentVersion ~= latestVersion then
                Logger.warn("[Version Checker] OUTDATED")
                Logger.kv("Installed", currentVersion)
                Logger.kv("Latest", latestVersion)
                Logger.kv("Download", "https://portal.cfx.re/assets")
            else
                Logger.success(("[Version Checker] Up to date (%s)"):format(currentVersion))
            end
        end, "GET")
    end
end

Logger.header(resourceCfg.expectedName, GetResourceMetadata(cache.resource, "version", 0))

if Config.debug then
    Logger.kv("Debug", "enabled")
end

if lib.context == "server" and Config.enableVersionCheck then
    checkVersion()
end

local ok, reason = validate()

if not ok then
    Logger.error("FAILED TO LOAD")
    Logger.error(reason)

    Logger.footer("docs.scuffedlabs.com/troubleshooting")

    return fail()
end

Logger.success("Loaded successfully")
Logger.footer("docs.scuffedlabs.com")
LoadedResource = true
