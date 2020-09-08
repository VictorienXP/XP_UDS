# Undertale Death Screen (Game Over) for Garry's Mod

[![Steam Views](https://img.shields.io/steam/views/587343641?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=587343641)
[![Steam Subscriptions](https://img.shields.io/steam/subscriptions/587343641?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=587343641)
[![Steam Downloads](https://img.shields.io/steam/downloads/587343641?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=587343641)
[![Steam Favorites](https://img.shields.io/steam/favorites/587343641?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=587343641)
[![Steam File Size](https://img.shields.io/steam/size/587343641?logo=steam)](https://steamcommunity.com/sharedfiles/filedetails/?id=587343641)

This Garry's Mod addon will give you an Undertale-like game over screen each time you die.

# Client cvars list

`xp_uds_enabled`: Enable(1)/disable(0) the screen for yourself.  Default: **1**

`xp_uds_playercolor`: If it should use your player color (1) or the original color (0) for the heart/soul. Default: **1**

`xp_uds_special`: Change the game over screen by a special game over screen:
* **0**: Default
* **1**: Flowey " This is all just a bad dream... "
* **2**: Sans " get dunked on!!! " / " geeettttttt dunked on!!! "

`xp_uds_name`: Change the displayed name.

`xp_uds_soul_color_r`: Red value of the heart/soul.

`xp_uds_soul_color_g`: Green value of the heart/soul.

`xp_uds_soul_color_b`: Blue value of the heart/soul.

`xp_uds_soul_color_a`: Alpha value of the heart/soul.

`xp_uds_soul_rainbow`: Make the heart/soul cycle colors. Default: **0**

`xp_uds_force`: Force the use of the death screen. Only work in servers with `sv_allowcslua 1`. (Or servers that have this addon but `xp_uds_sv_enabled 0`)

# Server cvars list

`xp_uds_sv_enabled`: Enable/disable the screen for all players. Default: **1**

`xp_uds_sv_sandbox_only`: If the screen should be only in sandbox. Default: **1**
