-- Hyprland Lua entry point.
-- Ambxst owns its generated base configuration; local modules override it.

local home = assert(os.getenv("HOME"), "HOME is not set")
local ambxstConfig = home .. "/.local/share/ambxst/hyprland.lua"
local ambxstFile = io.open(ambxstConfig, "r")

ambxstConfigLoaded = ambxstFile ~= nil

if ambxstFile then
    ambxstFile:close()
    assert(loadfile(ambxstConfig))()
end

require("lua/vars")
require("lua/env")
require("lua/monitors")
require("lua/startup")
require("lua/input")
require("lua/appearance")
require("lua/layout")
require("lua/animations")
require("lua/binds")
require("lua/rules")
require("lua/local")
