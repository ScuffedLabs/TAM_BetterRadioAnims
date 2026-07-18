--[[------------------------------------------------------
----          Discord - discord.gg/YzC4Du7WYm         ----
----       Docs - https://docs.scuffedlabs.com        ----
---- Do not edit if you do not know what you're doing ----
--]] ------------------------------------------------------
fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"

name "scfd_radioanims"
author "Scuffed Labs"
website "https://scuffedlabs.com"
description "Better Radio Animations by Scuffed Labs"
version "v1.0.0"

ox_lib {
    'locale'
}

files {
    "data/*",
    "bridge/**/client.lua",
    "locales/*.json"
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/logger.lua",
    "shared/const.lua",
    "init.lua",
}

client_scripts {
    "client/main.lua",
}

server_scripts {
    "server/main.lua",
}

dependencies {
    "/gameBuild:3095",
    "/server:26389",
    "/onesync",
    "ox_lib"
}

escrow_ignore {
    "**/**",
}
