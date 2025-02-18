-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------

pcall(require, "luarocks.loader")

local gtimer = require("gears.timer")
local collectgarbage = collectgarbage

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gtimer({
	timeout = 5,
	autostart = true,
	call_now = true,
	callback = function()
		collectgarbage("collect")
	end,
})

local beautiful = require("beautiful")
local helpers = require("helpers")
beautiful.init(helpers.filesystem.get_awesome_config_dir("presentation") .. "theme/theme.lua")

require("config")
require("presentation")

local persistent_daemon = require("daemons.system.persistent")
persistent_daemon:enable()