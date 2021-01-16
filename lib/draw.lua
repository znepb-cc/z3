local a = {}

function a.setBgAndText(bg, tc)
    term.setBackgroundColor(bg)
    term.setTextColor(tc)
end

function a.writeAt(x, y, ...)
    term.setCursorPos(x, y)
    local out = write(unpack({...}))
    return out
end

function a.writeAtRaw(x, y, ...)
    term.setCursorPos(x, y)
    local out = term.write(unpack({...}))
    return out
end

function a.writeWithBgAt(bg, x, y, ...)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bg)
    local out = write(unpack({...}))
    return out
end

function a.writeWithBgAtRaw(bg, x, y, ...)
    term.setCursorPos(x, y)
    term.setBackgroundColor(bg)
    local out = term.write(unpack({...}))
    return out
end

function a.writeWithTextAt(bg, x, y, ...)
    term.setCursorPos(x, y)
    term.setTextColor(tc)
    local out = write(unpack({...}))
    return out
end

function a.writeWithTextRaw(tc, x, y, ...)
    term.setCursorPos(x, y)
    term.setTextColor(tc)
    local out = term.write(unpack({...}))
    return out
end

function a.writeWithTextAndBgAt(tc, bg, x, y, ...)
    term.setCursorPos(x, y)
    a.setBgAndText(bg, tc)
    local out = write(unpack({...}))
    return out
end

function a.writeWithTextAndBgRaw(tc, bg, x, y, ...)
    term.setCursorPos(x, y)
    a.setBgAndText(bg, tc)
    local out = term.write(unpack({...}))
    return out
end

function a.clearColor(bg)
    term.setBackgroundColor(bg)
    term.clear()
end

function a.clearLineColor(bg, y)
    term.setCursorPos(1, y)
    term.setBackgroundColor(bg)
    term.clearLine()
end

function a.alignRight(str, offset, width)
    return width - #str + offset
end

return a