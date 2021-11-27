-- license:BSD-3-Clause
-- copyright-holders:Aaron Paden
-- Original idea by Radek Dutkiewicz AKA oomek
-- http://forum.arcadecontrols.com/index.php?topic=163525.0

local exports = {}
exports.name = 'defenderlr'
exports.version = '3'
exports.description = 'Configure left-right controls for Defender'
exports.license = 'The BSD 3-Clause License'
exports.author = { name = 'Aaron Paden' }

local defenderlr = exports
function defenderlr.startplugin()
	-- These two values can be found in the ioport_type enum
	-- found in mame at src/emu/ioport.h. They aren't yet exported
	-- into the lua API AFAIK, so you have to reference that file and
	-- count up from 0. Of course, you should delete the empty lines and
	-- comments and let your text editor count for you.
	local IPT_JOYSTICK_LEFT = 53
	local IPT_JOYSTICK_RIGHT = 54

	-- You can use MAME's built-in debugger to look for values that change
	-- after pressing an input. There's also an interactive lua console.
	-- But it's easier if someone has already done the work of reverse-engineering
	-- the game for you. A 10-second search can save you hours. In the case of Defender,
	-- there is dissassembled source on github already with helpful labels to grep through.
	local FACING_ADDRESS = 0xA0BB
	local FACING_LEFT  = 0xFD
	local FACING_RIGHT = 0x03

	local button_left = nil
	local button_right = nil
	local input = nil
	local ioport = nil
	local memory = nil
	local thrust = nil
	local function process_frame()
		if input ~= nil then
			if input:seq_pressed(button_left) then
				-- You can observe the current facing at address 0xA0BD.
				-- Originally I tried tracking that address and then triggering
				-- the Reverse input when the player was facing the wrong way.
				-- I don't understand why, but enabling the Reverse input would
				-- not reliably change the ship's direction, so I had to revert
				-- to oomek's solution of writing directly to memory.
				memory:write_u8(FACING_ADDRESS, FACING_LEFT)
				thrust:set_value(1)
			elseif input:seq_pressed(button_right) then
				memory:write_u8(FACING_ADDRESS, FACING_RIGHT)
				thrust:set_value(1)
			else
				thrust:set_value(0)
			end
		end
	end
	
	local function cleanup()
		input = nil
		ioport = nil
		memory = nil
		thrust = nil
		button_left = nil
		button_right = nil
		emu.register_frame_done(nil)		
	end

	local function init_plugin()
		if emu.romname() == "defender" then
			if tonumber(emu.app_version()) >= 0.227 then
				input = manager.machine.input
				ioport = manager.machine.ioport
				memory = manager.machine.devices[':maincpu'].spaces['program']
				thrust = ioport.ports[':IN0'].fields['Thrust']
				button_left = ioport:type_seq(IPT_JOYSTICK_LEFT)
				button_right = ioport:type_seq(IPT_JOYSTICK_RIGHT)
				emu.register_frame_done(process_frame)
			else
				print("ERROR: The 'defenderlr' plugin requires MAME version 0.227 or greater.")			
			end
		else
			cleanup()
		end
	end
	-- Unfortunately these are not listed in the documentation on
	-- docs.mamedev.org, but they're very important for any plugin.
	-- They take a function as an argument (this is called a callback).
	-- This function is called on an event. Thankfully there is documentation
	-- in a comment in luaengine.cpp, which I'll reproduce here:
	-- emu library
	-- 
	-- emu.app_name() - return application name
	-- emu.app_version() - return application version
	-- emu.gamename() - return game full name
	-- emu.romname() - return game ROM name
	-- emu.softname() - return softlist name
	-- emu.time() - return emulation time
	-- emu.pid() - return frontend process ID
	-- 
	-- emu.driver_find(driver_name) - find and return game_driver for driver_name
	-- emu.start(driver_name) - start given driver_name
	-- emu.pause() - pause emulation
	-- emu.unpause() - unpause emulation
	-- emu.step() - advance one frame
	-- emu.keypost(keys) - post keys to natural keyboard
	-- emu.wait(len) - wait for len within coroutine
	-- emu.lang_translate(str) - get translation for str if available
	-- emu.subst_env(str) - substitute environment variables with values for str (semantics are OS-specific)
	-- 
	-- emu.register_prestart(callback) - register callback before reset
	-- emu.register_start(callback) - register callback after reset
	-- emu.register_stop(callback) - register callback after stopping
	-- emu.register_pause(callback) - register callback at pause
	-- emu.register_resume(callback) - register callback at resume
	-- emu.register_frame(callback) - register callback at end of frame
	-- emu.register_frame_done(callback) - register callback after frame is drawn to screen (for overlays)
	-- emu.register_sound_update(callback) - register callback after sound update has generated new samples
	-- emu.register_periodic(callback) - register periodic callback while program is running
	-- emu.register_callback(callback, name) - register callback to be used by MAME via lua_engine::call_plugin()
	-- emu.register_menu(event_callback, populate_callback, name) - register callbacks for plugin menu
	-- emu.register_mandatory_file_manager_override(callback) - register callback invoked to override mandatory file manager
	-- emu.register_before_load_settings(callback) - register callback to be run before settings are loaded
	-- emu.show_menu(menu_name) - show menu by name and pause the machine
	-- 
	-- emu.print_verbose(str) - output to stderr at verbose level
	-- emu.print_error(str) - output to stderr at error level
	-- emu.print_info(str) - output to stderr at info level
	-- emu.print_debug(str) - output to stderr at debug level
	-- 
	-- emu.device_enumerator(dev) - get device enumerator starting at arbitrary point in tree
	-- emu.screen_enumerator(dev) - get screen device enumerator starting at arbitrary point in tree
	-- emu.image_enumerator(dev) - get image interface enumerator starting at arbitrary point in tree
	-- emu.image_enumerator(dev) - get image interface enumerator starting at arbitrary point in tree
	emu.register_start(init_plugin)
	emu.register_stop(cleanup)
end

return exports
