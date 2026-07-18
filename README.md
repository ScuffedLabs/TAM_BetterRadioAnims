# SCFD Radio Animations

*Previously TAM_BetterRadioAnims*

Modern, lightweight radio animations for FiveM built with **ox_lib**, **statebags**, and **collection-based clothing support**.

Unlike TAM_BetterRadioAnims, **scfd_radioanims** does **not** require an emote menu. Animations are played natively, props are synchronized automatically using server-authoritative statebags, and clothing detection uses GTA V's newer collection-based natives for long-term compatibility.

---

## ✨ Features

* 🎭 Native animations (no RPEmotes or Scully Emote Menu required)
* 📡 Server-authoritative statebag synchronization
* 📻 Fully synchronized radio props
* 👥 Props are visible to every nearby player
* 👕 Collection-based clothing detection
* 🚔 Automatic support for uniforms, vests, and earpieces
* 🎯 Different animations while aiming
* 🚗 Automatically stops while entering blacklisted vehicles
* 🚫 Ped and vehicle blacklist support
* 🎮 Optional keybind support
* 📞 Compatible with **pma-voice**
* 📞 Compatible with **Sonoran Radio**
* ⚡ Extremely lightweight
* 🔒 Secure against client manipulation
* 🧩 Easily extendable

---

# Why Collection-Based Clothing?

Older FiveM clothing resources rely on global drawable IDs.

Whenever Rockstar releases a new DLC, those IDs can shift, causing previously configured uniforms to stop working. This resource instead uses **collection-local drawables**, meaning configurations remain stable across game updates.

So instead of configuring:

```lua
--[drawableId][componentId][textureId]
[11][394][3]
```

you configure:

```lua
torso2 = {
    collection = "mp_m_sum",
    drawable = 4,
    texture = 3,
}
```

which is significantly easier to read and maintain.

---

# Supported Animations

The resource ships with multiple built-in animation presets including:

* Radio Chest
* Radio Shoulder
* Earpiece
* Multiple Walkie Talkie styles
* Aiming variants
* Custom animations

Additional animations can easily be added inside `data/animations.lua`.

---

# Clothing Detection

Animations can automatically change depending on the player's outfit.

Example:

```lua
{
    animation = "radiochest",

    clothing = {
        kevlar = {
            collection = "mp_m_sum",
            drawable = 3,
            texture = 0,
        },
    },
},
```

Rules may match:

* Clothing components
* Props
* Multiple items simultaneously
* Priority order

making it easy to support multiple departments and uniforms.

---

# Supported Voice Resources

Currently supports:

* pma-voice
* Sonoran Radio

Additional radio systems can easily trigger the exported event.

---

# Performance

The resource was designed around minimizing idle resource usage.

* No emote framework
* No constant polling
* Statebag driven synchronization
* Animation monitor only runs while the local player is actively using the radio
* Models and animation dictionaries are unloaded after use

Idle usage is effectively zero.

---

# Dependencies

Required

* ox_lib
* Animations: https://www.gta5-mods.com/misc/leo-custom-anim/download/151122

Optional

* pma-voice
* Sonoran Radio

---

# Installation

1. Install **ox_lib**
2. Add the resource to your server
3. Download and add the animations to the `stream` folder (https://www.gta5-mods.com/misc/leo-custom-anim/download/151122)
4. Ensure the resource starts after **ox_lib**
5. Configure your preferred animations
6. Configure clothing rules (optional)

```
ensure ox_lib
ensure scfd_radioanims
```

---

# Credits

Originally developed by Marshular
Currently maintained & developed by **Scuffed Labs**
Animations by CrunchyCat - https://www.gta5-mods.com/misc/leo-custom-anim/download/151122

- https://scuffedlabs.com
- https://scuffedlabs.com/discord
- https://docs.scuffedlabs.com

---

## License

See LICENSE.md
