-- UnBIOS by JackMacWindows
-- This will undo most of the changes/additions made in the BIOS, but some things may remain wrapped
-- Here's a list of things that are irreversibly changed:
-- * old Lua 5.1 `load` function (for loading from a function)
-- * `loadstring` prefixing
-- * string metatable blocking (on old versions of CC)
-- * both `bit` and `bit32` are kept for compatibility
-- * `http.request`
-- * `os.shutdown` and `os.reboot`
if _HOST:find("UnBIOS") then return end
local keptAPIs = {loadfile = true, load = true, bit32 = true, bit = true, ccemux = true, config = true, coroutine = true, debug = true, fs = true, http = true, io = true, mounter = true, os = true, periphemu = true, peripheral = true, redstone = true, rs = true, term = true, _HOST = true, _CC_DEFAULT_SETTINGS = true, _CC_DISABLE_LUA51_FEATURES = true, _VERSION = true, assert = true, collectgarbage = true, error = true, gcinfo = true, getfenv = true, getmetatable = true, ipairs = true, loadstring = true, math = true, newproxy = true, next = true, pairs = true, pcall = true, rawequal = true, rawget = true, rawlen = true, rawset = true, select = true, setfenv = true, setmetatable = true, string = true, table = true, tonumber = true, tostring = true, type = true, unpack = true, xpcall = true, turtle = true, pocket = true, commands = true, _G = true}
local t = {}
for k in pairs(_G) do if not keptAPIs[k] then table.insert(t, k) end end
for _,k in ipairs(t) do _G[k] = nil end
_G.term = _G.term.native()
_G.http.checkURL = _G.http.checkURLAsync
_G.http.websocket = _G.http.websocketAsync
local tempOS = _G.os
local delete = {os = {"version", "pullEventRaw", "pullEvent", "run", "loadAPI", "unloadAPI", "sleep"}, http = {"get", "post", "put", "delete", "patch", "options", "head", "trace", "listen", "checkURLAsync", "websocketAsync"}, fs = {"complete"}}
for k,v in pairs(delete) do for _,a in ipairs(v) do _G[k][a] = nil end end
_G._HOST = _G._HOST .. " (UnBIOS)"
-- Set up TLCO
function _G.term.native()
    _G.term.native = nil
    term.setBackgroundColor(32768)
    term.setTextColor(1)
    term.setCursorPos(1, 1)
    term.setCursorBlink(true)
    term.clear()
    local file = fs.open("/bios.lua", "r")
    if file == nil then
        term.setCursorBlink(false)
        term.setTextColor(16384)
        term.write("Could not find /bios.lua. UnBIOS cannot continue.")
        term.setCursorPos(1, 2)
        term.write("Press any key to continue")
        coroutine.yield("key")
        os.shutdown()
    end
    local fn, err = loadstring(file.readAll(), "@bios.lua")
    file.close()
    if fn == nil then
        term.setCursorBlink(false)
        term.setTextColor(16384)
        term.write("Could not load /bios.lua. UnBIOS cannot continue.")
        term.setCursorPos(1, 2)
        term.write(err)
        term.setCursorPos(1, 3)
        term.write("Press any key to continue")
        coroutine.yield("key")
        os.shutdown()
    end
    _G.os = tempOS
    setfenv(fn, _G)
    fn()
    os.shutdown()
end
coroutine.yield()