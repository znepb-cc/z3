-- initalize restart options
term.clear()
term.setCursorPos(1, 1)
print("Z3 Startup Manager")

if fs.exists(".restartOption") then
    local f = fs.open("/.restartOption", "r")
    local data = tonumber(f.readAll())
    f.close()

    --fs.delete("/.restartOption")
    if data == 1 then
        print("Starting with advanced logging")
        os.run({
            unpack(_G),
            advancedLogging = true
        }, "/sys/unbios.lua")
    elseif data == 2 then
        print("Starting with no TLCO")
        os.run({require = require}, "/sys/kernel.lua")
    elseif data == 3 then
        print("Starting in CraftOS")
    else
        print("Restart option was invalid, system will start normally.")
        sleep(3)
        os.run({}, "/sys/unbios.lua")
    end
else
    os.run({}, "/sys/unbios.lua")
end