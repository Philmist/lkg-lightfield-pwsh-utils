--[[
    copyTime.lua
    Copyright (C) 2024  Philmist

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    ------
    This code is derived from mpv-copyTime(https://github.com/Arieleg/mpv-copyTime).
--]]
require 'mp'
require 'mp.msg'

-- Copy the current time of the video to clipboard.

WINDOWS = 2
UNIX = 3

local function platform_type()
    local utils = require 'mp.utils'
    local workdir = utils.to_string(mp.get_property_native("working-directory"))
    if string.find(workdir, "\\") then
        return WINDOWS
    else
        return UNIX
    end
end

local function command_exists(cmd)
    local pipe = io.popen("type " .. cmd .. " > /dev/null 2> /dev/null; printf \"$?\"", "r")
    exists = pipe:read() == "0"
    pipe:close()
    return exists
end

local function get_clipboard_cmd()
    if command_exists("xclip") then
        return "xclip -silent -in -selection clipboard"
    elseif command_exists("wl-copy") then
        return "wl-copy"
    elseif command_exists("pbcopy") then
        return "pbcopy"
    else
        mp.msg.error("No supported clipboard command found")
        return false
    end
end

local function divmod(a, b)
    return a / b, a % b
end

local function set_clipboard(text) 
    if platform == WINDOWS then
        local subprocess = {
            name = "subprocess",
            args = { "powershell", "-Command", "Set-Clipboard", "-Value", text }
        }
        --local result = mp.commandv("run", "pwsh", "set-clipboard", text)
        mp.command_native(subprocess)
        return true
    elseif (platform == UNIX and clipboard_cmd) then
        local pipe = io.popen(clipboard_cmd, "w")
        pipe:write(text)
        pipe:close()
        return true
    else
        mp.msg.error("Set_clipboard error")
        return false
    end
end

local startTimeStr = "00:00:00.000"
local function copyTime(arg)
    local time_pos = mp.get_property_number("time-pos")
    local seconds = math.floor(time_pos)
    local milliseconds = math.floor((time_pos - seconds) * 1000)
    local time = string.format("%02d.%03d", seconds, milliseconds)
    if arg.event == "down" then
        mp.osd_message(string.format("Start time: %s", time))
        startTimeStr = time
    end
    if arg.event == "up" then
        mp.osd_message(string.format("End time: %s", time))
    end
    local clipStr = "'-ss " .. startTimeStr .. " -to " .. time .. "'"
    if arg.event == "up" or arg.event == "press" then
        if set_clipboard(clipStr) then
            mp.osd_message(string.format("Copied to Clipboard: %s", clipStr))
        else
            mp.osd_message("Failed to copy clipStr to clipboard")
        end
    end
end


platform = platform_type()
if platform == UNIX then
    clipboard_cmd = get_clipboard_cmd()
end

local keyBindingFlag = {
    repeatable = false;
    complex = true;
}
mp.add_key_binding("Ctrl+c", "copyTime", copyTime, keyBindingFlag)
