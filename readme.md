# The defenderlr plugin

This plugin is adapted from the original by oomek here and works with MAME v0.227 or newer.

It should work with whatever you have configured to act as a joystick with no configuration.

I know someone asks about defender every few months, and I've been meaning to get this working for me for a long time, but I've just now gotten around to it. This makes the game way more playable, though I still prefer Defender II for the 2600. The enemies in the arcade original are pretty devious and dodge your laser gun like alien ninja.

A note about the implementation. I tried to avoid writing to memory by detecting the facing of the player and triggering the reverse button, but it didn't work. While I was able to successfully detect the facing, triggering the reverse button didn't reliably work and I couldn't figure out why. So I fell back to the behavior in the original plugin of writing to memory. There doesn't seem to be any side-effects from casual observation.

Anyway the fact that you can do this with no modifications to mame is pretty cool.

## Configuring MAME

Can you launch Defender in MAME?  "mame.exe defender"
\- If not, you need to find the correct version of the "defender.zip" ROM file for your version of MAME and put it the "\mame\roms" folder.  (ROM not provided here.)

If you don't already have one, create a mame.ini file using the "mame -cc" (create config) command.
\- Open it in Notepad and verify that it contains "plugins    1". (enabled)

```
#  
# SCRIPTING OPTIONS  
#  
autoboot_command  
autoboot_delay 0  
autoboot_script  
console 0  
plugins 1
```

Next, check the paths for inis and plugins so you know where to put those files so MAME can find them.
For example, "inipath    .;ini;ini/presets" indicates that MAME will look for ini files in three folders "\mame\", "\mame\ini\", and "\mame\ini\presets\".

```
#  
# CORE SEARCH PATH OPTIONS  
#  
homepath .  
rompath roms  
hashpath hash  
samplepath samples  
artpath artwork  
ctrlrpath ctrlr  
inipath .;ini;ini/presets  
fontpath .  
cheatpath cheat  
crosshairpath crosshair  
pluginspath plugins
```

Make a "\mame\plugins\defenderlr\" folder.
\- Put the init.lua and plugin.json plugin files in that folder.

Make a text file named "defender.ini" in either the ini folder or the same folder as the MAME executable.
\-  It should contain the text "plugin    defenderlr".

Enable the defenderlr plugin via the MAME user interface "plugins" menu.
  or
Edit the "plugin.ini" file and change "defenderlr        0" (disabled) to "defenderlr        1". (enabled)

```
#  
# PLUGINS OPTIONS  
#  
autofire 0  
cheat 0  
cheatfind 0  
commonui 0  
console 0  
data 1  
defenderlr 1
```

### Now you're ready to play Defender and blast those pesky aliens.