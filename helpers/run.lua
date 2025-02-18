local awful = require("awful")

local tostring = tostring
local string = string
local ipairs = ipairs
local math = math
local os = os

local _run = {}

function _run.run_once_pgrep(findme, cmd)
    awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

function _run.run_once_ps(findme, cmd)
    awful.spawn.easy_async_with_shell(string.format("ps -C %s|wc -l", findme), function(stdout)
        if tonumber(stdout) ~= 2 then
            awful.spawn(cmd, false)
        end
    end)
end

function _run.run_once_grep(command)
    awful.spawn.easy_async_with_shell(string.format("ps aux | grep '%s' | grep -v 'grep'", command), function(stdout)
        if stdout == "" or stdout == nil then
            awful.spawn(command, false)
        end
    end)
end

function _run.check_if_running(command, running_callback, not_running_callback)
    awful.spawn.easy_async_with_shell(string.format("ps aux | grep '%s' | grep -v 'grep'", command), function(stdout)
        if stdout == "" or stdout == nil then
            if not_running_callback ~= nil then
                not_running_callback()
            end
        else
            if running_callback ~= nil then
                running_callback()
            end
        end
    end)
end

function _run._is_pid_running(pid, callback)
    awful.spawn.easy_async_with_shell(string.format("ps -o pid= -p %s", pid), function(stdout)
        -- If empty, program is not running
        callback(stdout ~= "")
    end)
end

local AWESOME_SENSIBLE_TERMINAL_PATH =
     debug.getinfo(1).source:match("@?(.*/)").."../external/awesome-sensible-terminal"

function _run.exec_terminal_app(command)
    awful.spawn.with_shell(AWESOME_SENSIBLE_TERMINAL_PATH .. " -e " .. command)
end

return _run