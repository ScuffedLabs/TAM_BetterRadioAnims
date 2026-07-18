if not lib then return end
local prefix = "^5[SCFD]^0"

Logger = {}

local function line(char)
    return prefix .. " " .. string.rep(char, 42)
end

function Logger.header(name, version)
    lib.print.info(line("-"))
    lib.print.info(("%s %s ^3%s^0"):format(prefix, name, version or ""))
end

function Logger.success(msg)
    lib.print.info(("%s ^2✓^0 %s"):format(prefix, msg))
end

function Logger.warn(msg)
    lib.print.warn(("%s ^3!^0 %s"):format(prefix, msg))
end

function Logger.error(msg)
    lib.print.error(("%s ^1✗^0 %s"):format(prefix, msg))
end

function Logger.kv(key, value)
    lib.print.info(("%s %s: ^3%s^0"):format(prefix, key, value))
end

function Logger.footer(docs)
    if docs then
        lib.print.info(("%s Docs: ^5%s^0"):format(prefix, docs))
    end

    lib.print.info(line("-"))
end

