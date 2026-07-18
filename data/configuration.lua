--[[------------------------------------------------------
----                  Configuration                   ----
----        For Support - discord.gg/YzC4Du7WY        ----
----       Docs - https://docs.scuffedlabs.com        ----
--]] ------------------------------------------------------
local config = {}

config.debug = true
config.enableVersionCheck = true

radio = {
    defaultAnimation = "default",

    clothingAnimations = {
        male = {
            {
                animation = "radiochest",
                priority = 100,

                clothing = {
                    kevlar = {
                        collection = "mp_m_sum",
                        drawable = 3,
                        texture = 0,
                    },
                },
            },

            {
                animation = "earpiece",
                priority = 90,

                props = {
                    ears = {
                        collection = "mp_m_heist4",
                        drawable = 1,
                        texture = 0,
                    },
                },
            },

            {
                animation = "wt4",
                priority = 80,

                clothing = {
                    torso2 = {
                        collection = "mp_m_sum",
                        drawable = 4,
                        texture = 3,
                    },

                    accessory = {
                        collection = "",
                        drawable = 4,
                        texture = 0,
                    },
                },
            },
        },

        female = {
            {
                animation = "radiochest",
                priority = 100,

                clothing = {
                    kevlar = {
                        collection = "mp_f_sum",
                        drawable = 3,
                        texture = 0,
                    },
                },
            },

            {
                animation = "earpiece",
                priority = 90,

                props = {
                    ears = {
                        collection = "mp_f_heist4",
                        drawable = 1,
                        texture = 0,
                    },
                },
            },
        },
    },
}

return config
