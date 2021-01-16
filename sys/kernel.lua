local w, h = term.getSize()
ccemux.echo("Kernel start")

local function main()
    local applications = {}
    local mode = "menu"

    local drawing = require("/lib/draw")

    local applicationPosition = 0

    local function choose(p1, p2)
        if p1 == nil then
            return p2
        else 
            return p1
        end
    end

    local function createApplication(path, settings)
        settings = {
            title = choose(settings.title, path),
            width = choose(settings.width, 10),
            height = choose(settings.height, 5),
            x = choose(settings.x, applicationPosition),
            y = choose(settings.x, applicationPosition)
        }
    end

    local function drawApplication()

    end

    local function drawDockbar()
        term.setCursorPos(1, h)
        drawing.setBgAndText(colors.white, mode == "menu" and colors.lightBlue or colors.lightGray)
        term.clearLine()
        term.write("@")

        drawing.writeAt(drawing.alignRight(_ZOS_VERSION or "????", 1, w), h, _ZOS_VERSION or "????")
    end

    local function drawMenu()
        ccemux.echo("Menu")
        paintutils.drawFilledBox(1, h - 12, 15, h - 1, colors.white)

        -- todo: finish lol

        drawing.writeWithTextAndBgAt(colors.lightGray, colors.white, 2, h - 11, "Menu      \7 \7")

        drawing.writeWithTextAndBgAt(colors.gray, colors.lightGray, 3, h - 2, "Search      ")
        drawing.writeWithTextAndBgAt(colors.white, colors.lightGray, 2, h - 2, "\149")
        drawing.writeWithTextAndBgAt(colors.lightGray, colors.white, 14, h - 3, "\144")
        drawing.writeWithTextAndBgAt(colors.lightGray, colors.white, 14, h - 2, "\149")
        drawing.writeWithTextAndBgAt(colors.white, colors.lightGray, 2, h - 3, "\159" .. string.rep("\143", 11))
        drawing.writeWithTextAndBgAt(colors.lightGray, colors.white, 2, h - 1, "\130" .. string.rep("\131", 11) .. "\129")
    end

    local function draw()
        term.setBackgroundColor(colors.blue)
        term.clear()

        if mode == "menu" then
            drawMenu()
        end
        
        drawDockbar()
    end

    draw()

    while true do
        draw()
        sleep() -- to provent oopsies
    end
end

term.setCursorBlink(false)
term.setBackgroundColor(colors.black)
term.clear()
ccemux.echo("2")
ccemux.echo("hello")
term.setCursorPos(w / 2 - string.len("zOS 3") / 2, h / 2)
term.setTextColor(colors.white)
print("zOS 3")

term.setCursorPos(w / 2 - string.len("- - -") / 2, h / 2 + 1)
term.setTextColor(colors.lightGray)
print("\7 \7 \7")

local files = {"/sys/kernel.lua"}

for i, v in pairs(files) do
    if fs.exists(v) == false then
        term.setCursorPos(1, 1)
        term.clear()
        term.setTextColor(colors.red)
        print("Missing file:", v)
        print("Restarting with CraftOS mode")
        sleep(3)

        local f = fs.open("/.restartOption", "w")
        f.write(tostring(3))
        f.close()

        os.reboot()
    end
end

term.setTextColor(colors.gray)
term.setCursorPos(1, h)
term.write("Press LCTRL for BIOS")

local result = false

parallel.waitForAny(function()
    while true do
        local e = {os.pullEvent("key")}
        if e[2] == keys.leftCtrl then
            result = true
            break
        end
    end
end, function()
    sleep(1)
end)

if result == false then
    local oTerm = term.current()
    local nTerm = window.create(term.current(), 1, 1, term.getSize())
    nTerm.setVisible(false)
    term.redirect(nTerm)
    local function render()
        local w, h = nTerm.getSize()
        while true do
            for t=0, 15, 1 do
                oTerm.setPaletteColor(2^t, table.unpack({nTerm.getPaletteColor(2^t)}))
            end
            local ocursor = {nTerm.getCursorPos()}
            local otext = nTerm.getCursorBlink()
            oTerm.setCursorBlink(false)
            for t=1, h do
                oTerm.setCursorPos(1, t)
                oTerm.blit(nTerm.getLine(t))
            end
            oTerm.setCursorBlink(otext)
            oTerm.setCursorPos(table.unpack(ocursor))
            sleep(0.05)
        end
    end
    local ok, err = pcall(function() 
        parallel.waitForAny(main, render) 
    end)

    if not ok then
        ccemux.echo("STOP " .. err)
        term.setBackgroundColor(colors.red)
        term.clear()
        term.setCursorPos(1, 1)
        print("Something happened. We don't know why this happened, but here's the error:", err, "\n\nPlease report this to the Z3 team.\n\nPress any key to restart...")
        sleep(0.5)
        os.pullEvent("key")
        os.reboot()
    end  
else
    local ok, err = pcall(function()
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        term.write("Z3 BIOS")
        term.setCursorPos(1, 2)
        term.write("Select an option")

        local sel = 1
        local selections = {
            "Restart with advanced logging",
            "Restart with no TLCO",
            "Restart and enter CraftOS 1.8",
            "Restart"
        }

        local function drawOptions()
            for i, v in pairs(selections) do
                term.setCursorPos(1, 3 + i)
                term.write(sel == i and "\7 " .. v or "  " .. v)
            end
        end

        drawOptions()

        local function setRebootOption(value)
            local f = fs.open("/.restartOption", "w")
            f.write(tostring(value))
            f.close()
        end

        while true do
            local e, k = os.pullEvent("key")
            if k == keys.down then
                if selections[sel + 1] then sel = sel + 1 else sel = 1 end
            elseif k == keys.up then
                if selections[sel - 1] then sel = sel - 1 else sel = #selections end
            elseif k == keys.enter then
                if sel < 4 then setRebootOption(sel) end
                os.reboot()
            end
            drawOptions()
        end
    end)

    if not ok then
        term.setBackgroundColor(colors.red)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        print("BIOS Error:", err, "\n\nPlease report this to the Z3 developers. Press any key to reboot")
        sleep(0.5)
        os.pullEvent("key")
        os.reboot()
    end  
end