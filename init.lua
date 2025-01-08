-- license:BSD-3-Clause
-- copyright-holders:Aaron Paden
-- Original idea by Radek Dutkiewicz AKA oomek
-- http://forum.arcadecontrols.com/index.php?topic=163525.0

local exports = {}
exports.name = 'defenderlr'
exports.version = '4'
exports.description = 'Configure left-right controls for Defender (and Stargate)'
exports.license = 'The BSD 3-Clause License'
exports.author = { name = 'Aaron Paden' }

local reset_subscription = nil
local stop_subscription = nil
local frame_subscription = nil

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
	local FACING_LEFT  = 0xFD
	local FACING_RIGHT = 0x03
	local facing_address = nil
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
				-- (10yard - The facing address for Stargate is 0x9C92)
				memory:write_u8(facing_address, FACING_LEFT)
				thrust:set_value(1)
			elseif input:seq_pressed(button_right) then
				memory:write_u8(facing_address, FACING_RIGHT)
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
		if frame_subscription ~= nil then
			frame_subscription:unsubscribe()
		end
		--reset_subscription:unsubscribe()
		--stop_subscription:unsubscribe()
	end

	local function init_plugin()
		if emu.romname() == "defender" or emu.romname() == "stargate" then
			if emu.romname() == "stargate" then
				facing_address = 0x9C92
			else
				facing_address = 0xA0BB
			end
			if emu.app_version() >= "0.254" then
				input = manager.machine.input
				ioport = manager.machine.ioport
				memory = manager.machine.devices[':maincpu'].spaces['program']
				thrust = ioport.ports[':IN0'].fields['Thrust']
				button_left = ioport:type_seq(IPT_JOYSTICK_LEFT, nil, nil)
				button_right = ioport:type_seq(IPT_JOYSTICK_RIGHT, nil, nil)
				frame_subscription = emu.add_machine_frame_notifier(process_frame)
			else
				print("ERROR: The 'defenderlr' plugin requires MAME version 0.254 or greater.")			
			end
		else
			cleanup()
		end
	end
	reset_subscription = emu.add_machine_reset_notifier(init_plugin)
	stop_subscription = emu.add_machine_stop_notifier(cleanup)
end

return exports
