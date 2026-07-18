local CONST <const> = require "shared.const"

---@class RadioPropDefinition
---@field model string
---@field bone integer
---@field position vector3
---@field rotation vector3

---@class RadioAnimationDefinition
---@field dictionary string
---@field clip string
---@field flag integer
---@field prop? RadioPropDefinition
---@field aimingVariant? string

---@type table<string, RadioAnimationDefinition>
local animations <const> = {
    default = {
        dictionary = "random@arrests",
        clip = "radio_chatter",
        flag = CONST.ANIMATION_FLAGS.MOVING,
    },

    default_aiming = {
        dictionary = "anim@radio_pose_3",
        clip = "radio_holding_gun",
        flag = CONST.ANIMATION_FLAGS.LOOP,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 60309,
            position = vector3(0.0750, 0.0470, 0.0110),
            rotation = vector3(-97.9442, 3.7058, -23.2367),
        },
    },

    radio2 = {
        dictionary = "random@arrests",
        clip = "radio_chatter",
        flag = CONST.ANIMATION_FLAGS.MOVING,
    },

    radiochest = {
        dictionary = "anim@cop_mic_pose_002",
        clip = "chest_mic",
        flag = CONST.ANIMATION_FLAGS.MOVING,
    },

    earpiece = {
        dictionary = "cellphone@",
        clip = "cellphone_call_listen_base",
        flag = CONST.ANIMATION_FLAGS.MOVING,
    },

    wt = {
        dictionary = "cellphone@",
        clip = "cellphone_text_read_base",
        flag = CONST.ANIMATION_FLAGS.MOVING,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 28422,
            position = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0),
        },
    },

    wt2 = {
        dictionary = "anim@radio_pose_3",
        clip = "radio_holding_gun",
        flag = CONST.ANIMATION_FLAGS.LOOP,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 60309,
            position = vector3(0.0750, 0.0470, 0.0110),
            rotation = vector3(-97.9442, 3.7058, -23.2367),
        },
    },

    wt3 = {
        dictionary = "anim@radio_left",
        clip = "radio_left_clip",
        flag = CONST.ANIMATION_FLAGS.MOVING,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 60309,
            position = vector3(0.0750, 0.0470, 0.0110),
            rotation = vector3(-97.9442, 3.7058, -23.2367),
        },
    },

    wt4 = {
        dictionary = "anim@male@holding_radio",
        clip = "holding_radio_clip",
        flag = CONST.ANIMATION_FLAGS.MOVING,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 28422,
            position = vector3(0.0750, 0.0230, -0.0230),
            rotation = vector3(-90.0, 0.0, -59.9999),
        },
    },

    wt5 = {
        dictionary = "missfbi3_steve_phone",
        clip = "steve_phone_idle_a",
        flag = CONST.ANIMATION_FLAGS.MOVING,
        prop = {
            model = "prop_cs_hand_radio",
            bone = 18905,
            position = vector3(0.1300, 0.0500, 0.0100),
            rotation = vector3(-113.0, 0.0, -60.0),
        },
    },
}

return animations
