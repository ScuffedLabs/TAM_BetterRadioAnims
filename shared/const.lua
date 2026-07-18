local CONST <const> = {
    STATES = {
        RADIO_ANIMATION = "scfd_radioanims:radioAnimation"
    },

    COMMANDS = {
        TOGGLE_PROPS = "radioprops",
        DEBUG_CLOTHING = "getclothing",
    },

    KVP = {
        USE_PROP_MAPPINGS = "scfd_radioanims:usePropMappings"
    },

    ANIMATION_FLAGS = {
        LOOP = 1,
        UPPER_BODY = 16,
        ENABLE_PLAYER_CONTROL = 32,

        -- Looping upper-body animation that allows movement.
        MOVING = 49,
    },

    LIMITS = {
        EVENT_COOLDOWN_MS = 250,
        ENTITY_RESOLVE_ATTEMPTS = 20,
        ENTITY_RESOLVE_DELAY_MS = 100,
    },

    PED_MODELS = {
        MALE = `mp_m_freemode_01`,
        FEMALE = `mp_f_freemode_01`,
    },

    CLOTHING_COMPONENTS = {
        face = 0,
        mask = 1,
        hair = 2,
        torso = 3,
        leg = 4,
        bag = 5,
        shoes = 6,
        accessory = 7,
        undershirt = 8,
        kevlar = 9,
        badge = 10,
        torso2 = 11,
    },

    PROP_COMPONENTS = {
        hat = 0,
        glasses = 1,
        ears = 2,
        watch = 6,
        bracelets = 7,
    },
}

return CONST
