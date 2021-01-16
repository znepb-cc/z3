term.write("Registering APIs")

local expect

do
    local h = fs.open("rom/modules/main/cc/expect.lua", "r")
    local f, err = loadstring(h.readAll(), "@expect.lua")
    h.close()

    if not f then error(err) end
    expect = f().expect
end

function write(sText)
    expect(1, sText, "string", "number")

    local w, h = term.getSize()
    local x, y = term.getCursorPos()

    local nLinesPrinted = 0
    local function newLine()
        if y + 1 <= h then
            term.setCursorPos(1, y + 1)
        else
            term.setCursorPos(1, h)
            term.scroll(1)
        end
        x, y = term.getCursorPos()
        nLinesPrinted = nLinesPrinted + 1
    end

    -- Print the line with proper word wrapping
    sText = tostring(sText)
    while #sText > 0 do
        local whitespace = string.match(sText, "^[ \t]+")
        if whitespace then
            -- Print whitespace
            term.write(whitespace)
            x, y = term.getCursorPos()
            sText = string.sub(sText, #whitespace + 1)
        end

        local newline = string.match(sText, "^\n")
        if newline then
            -- Print newlines
            newLine()
            sText = string.sub(sText, 2)
        end

        local text = string.match(sText, "^[^ \t\n]+")
        if text then
            sText = string.sub(sText, #text + 1)
            if #text > w then
                -- Print a multiline word
                while #text > 0 do
                    if x > w then
                        newLine()
                    end
                    term.write(text)
                    text = string.sub(text, w - x + 2)
                    x, y = term.getCursorPos()
                end
            else
                -- Print a word normally
                if x + #text - 1 > w then
                    newLine()
                end
                term.write(text)
                x, y = term.getCursorPos()
            end
        end
    end

    return nLinesPrinted
end

function print(...)
    local nLinesPrinted = 0
    local nLimit = select("#", ...)
    for n = 1, nLimit do
        local s = tostring(select(n, ...))
        if n < nLimit then
            s = s .. "\t"
        end
        nLinesPrinted = nLinesPrinted + write(s)
    end
    nLinesPrinted = nLinesPrinted + write("\n")
    return nLinesPrinted
end

function sleep(nTime)
    expect(1, nTime, "number", "nil")
    local timer = os.startTimer(nTime or 0)
    repeat
        local _, param = os.pullEvent("timer")
    until param == timer
end

function os.pullEventRaw(sFilter)
    return coroutine.yield(sFilter)
end

function os.pullEvent(sFilter)
    local eventData = table.pack(os.pullEventRaw(sFilter))
    if eventData[1] == "terminate" then
        error("Terminated", 0)
    end
    return table.unpack(eventData, 1, eventData.n)
end



local function printThenWait(text)
    print(text)
    sleep()
end

printThenWait("Loaded: write")
printThenWait("Loaded: print")
printThenWait("Loaded: sleep")
printThenWait("Loaded: os.pullEventRaw")
printThenWait("Loaded: os.pullEvent")

local tAPIsLoading = {}

function dofile(_sFile)
    expect(1, _sFile, "string")

    local fnFile, e = loadfile(_sFile, nil, _G)
    if fnFile then
        return fnFile()
    else
        error(e, 2)
    end
end

printThenWait("Loaded: dofile")

function os.loadAPI(_sPath)
    expect(1, _sPath, "string")
    local sName = fs.getName(_sPath)
    if sName:sub(-4) == ".lua" then
        sName = sName:sub(1, -5)
    end
    if tAPIsLoading[sName] == true then
        printError("API " .. sName .. " is already being loaded")
        return false
    end
    tAPIsLoading[sName] = true

    local tEnv = {}
    setmetatable(tEnv, { __index = _G })
    local fnAPI, err = loadfile(_sPath, nil, tEnv)
    if fnAPI then
        local ok, err = pcall(fnAPI)
        if not ok then
            tAPIsLoading[sName] = nil
            ccemux.echo(err)
            return error("Failed to load API " .. sName .. " due to " .. err, 1)
        end
    else
        tAPIsLoading[sName] = nil
        return error("Failed to load API " .. sName .. " due to " .. err, 1)
    end

    local tAPI = {}
    for k, v in pairs(tEnv) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end

    _G[sName] = tAPI
    tAPIsLoading[sName] = nil
    return true
end

printThenWait("Loaded: loadAPI")

function os.run(_tEnv, _sPath, ...)
    expect(1, _tEnv, "table")
    expect(2, _sPath, "string")

    local tEnv = _tEnv
    setmetatable(tEnv, { __index = _G })

    local fnFile, err = loadfile(_sPath, nil, tEnv)
    if fnFile then
        local ok, err = pcall(fnFile, ...)
        if not ok then
            if err and err ~= "" then
                printError(err)
            end
            return false
        end
        return true
    end
    if err and err ~= "" then
        printError(err)
    end
    return false
end

printThenWait("Loaded: os.run")

function printError(...)
    local oldColour
    if term.isColour() then
        oldColour = term.getTextColour()
        term.setTextColour(colors.red)
    end
    print(...)
    if term.isColour() then
        term.setTextColour(oldColour)
    end
end

printThenWait("Loaded: printError")

for i, v in pairs(_G) do
    ccemux.echo(i, v)
end

-- Load APIs
local bAPIError = false
local tApis = fs.list("rom/apis")
for _, sFile in ipairs(tApis) do
    ccemux.echo(sFile)
    if string.sub(sFile, 1, 1) ~= "." then
        local sPath = fs.combine("rom/apis", sFile)
        if not fs.isDir(sPath) then
            if not os.loadAPI(sPath) then
                bAPIError = true
            end
        end
    end
end

printThenWait("Loaded base internal APIs")

if turtle and fs.isDir("rom/apis/turtle") then
    -- Load turtle APIs
    local tApis = fs.list("rom/apis/turtle")
    for _, sFile in ipairs(tApis) do
        if string.sub(sFile, 1, 1) ~= "." then
            local sPath = fs.combine("rom/apis/turtle", sFile)
            if not fs.isDir(sPath) then
                if not os.loadAPI(sPath) then
                    bAPIError = true
                end
            end
        end
    end
end

printThenWait("Loaded turtle APIs")

if pocket and fs.isDir("rom/apis/pocket") then
    -- Load pocket APIs
    local tApis = fs.list("rom/apis/pocket")
    for _, sFile in ipairs(tApis) do
        if string.sub(sFile, 1, 1) ~= "." then
            local sPath = fs.combine("rom/apis/pocket", sFile)
            if not fs.isDir(sPath) then
                if not os.loadAPI(sPath) then
                    bAPIError = true
                end
            end
        end
    end
end

printThenWait("Loaded pocket APIs")

if commands and fs.isDir("rom/apis/command") then
    -- Load command APIs
    if os.loadAPI("rom/apis/command/commands.lua") then
        -- Add a special case-insensitive metatable to the commands api
        local tCaseInsensitiveMetatable = {
            __index = function(table, key)
                local value = rawget(table, key)
                if value ~= nil then
                    return value
                end
                if type(key) == "string" then
                    local value = rawget(table, string.lower(key))
                    if value ~= nil then
                        return value
                    end
                end
                return nil
            end,
        }
        setmetatable(commands, tCaseInsensitiveMetatable)
        setmetatable(commands.async, tCaseInsensitiveMetatable)

        -- Add global "exec" function
        exec = commands.exec
    else
        bAPIError = true
    end
end

printThenWait("Loaded command APIs")

local r = dofile("/rom/modules/main/cc/require.lua")

_G.require, _G.package = r.make(_G, "/")

printThenWait("Loaded: require")

local nfte = require("/lib/nfte")
local x, y = term.getCursorPos()
term.scroll(5)
nfte.drawImage(nfte.loadImage('/sys/content/z3.nft'), 2, y - 4)

term.setCursorPos(2, y + 1)
printThenWait("\nChecking files")

local files = {"/sys/kernel.lua"}
local ok = true

for i, v in pairs(files) do
    if fs.exists(v) then
        printThenWait("[OK] " .. v)
    else
        print("[ERROR] " .. v)
        ok = false
        print("The system is not installed correctly...")
        break
    end
end

ccemux.echo("test")

if ok then
    print("Starting kernel")
    local ok, err = xpcall(function()
        os.run(_G, "/sys/kernel.lua")
    end, function(ok, err)
        if not ok then
            ccemux.echo(tostring(err))
            term.setCursorPos(1, 1)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            print("STOP:", err)
            ccemux.echo(debug.traceback())
        end
    end)
    
end