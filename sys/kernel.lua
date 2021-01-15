local w, h = term.getSize()
local function main()
    local applications = {}

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

    local function draw()

    end

    while true do
        drawing.writeAt(1, 1, "hello World")
        sleep(1)
    end
end

term.setCursorBlink(false)
term.setBackgroundColor(colors.black)
term.clear()
sleep(0.7)
term.setCursorPos(w / 2 - string.len("zOS 3") / 2, h / 2)
term.setTextColor(colors.white)
print("zOS 3")

term.setCursorPos(w / 2 - string.len("- - -") / 2, h / 2 + 1)
term.setTextColor(colors.lightGray)
print("\7 \7 \7")

term.setTextColor(colors.gray)
term.setCursorPos(1, h - 1)
term.write("Press CTRL for BIOS")
term.setCursorPos(1, h)
term.write("Press LALT for verbose")

sleep(10)

local ok, err = pcall(main)

if not ok then
    term.setBackgroundColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    print("Something happened. We don't know why this happened, but here's the error:", err, "\n\nPlease report this to the Z3 team.\n\nPress any key to restart...")
    sleep(0.5)
    os.pullEvent("key")
    os.reboot()
end  