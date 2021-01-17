local a = {}

function a:new(parentTerm, x, y, w, defaultText, typeChar, text, background, visible)
    local o = {
        x = x,
        y = y,
        w = w,
        default = defaultText or "",
        typeChar = typeChar,
        background = background or colors.black,
        text = text or colors.white,
        content = "",
        selected = false,
        cursor = 1,
        selected = false,
        changed = false
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function a:updateCursor()
    if self.selected then
        local x = self.w + self.x + 1
        if #self.content <= self.w then
            x = self.x + #self.content
        end

        term.setCursorPos(x, self.y)
    end
end

function a:draw()
    term.setCursorPos(self.x, self.y)
    term.setBackgroundColor(self.background)
    term.setTextColor(self.text)
    term.write(string.rep(" ", self.w + 2))
    term.setCursorPos(self.x, self.y)

    if self.selected then
        term.write(self.content:sub(-self.w - 1))
        self:updateCursor()
    else
        if self.content:len() - 2 > self.w then
            term.write(self.content:sub(1, self.w - 1) .. "...")
        elseif self.content == "" then
            term.write(self.default)
        else
            term.write(self.content)
        end
    end
end

function a:select()
    self.selected = true
    self.content = ""
    self:draw()
    term.setCursorBlink(true)
end

function a:deselect()
    self.selected = false

    self:draw()
    term.setCursorBlink(false)
end

function a:redirectEvents(e)
    if e[1] == "mouse_click" then
        local m, x, y = e[2], e[3], e[4]
        if x >= self.x and x <= self.x + self.w and y == self.y then
            self:select()
            self.changed = true
        elseif self.selected then
            self:deselect()
        end
    elseif e[1] == "char" and self.selected then
        if self.cursor == #self.content + 1 then
            self.content = self.content .. e[2]
        elseif self.cursor == 1 then
            self.content = e[2] .. self.content
        else
            self.content = self.content:sub(1, self.cursor) .. e[2] .. self.content:sub(self.cursor + 1, #self.content)
        end
        self.cursor = self.cursor + 1
        self:draw()
        self.changed = true
    elseif e[1] == "key" and self.selected then
        local k = e[2]
        if k == keys.enter or k == keys.numPadEnter then
            self.selected = false
            self:deselect()
            self.changed = true
        elseif k == keys.backspace then
            self.content = self.content:sub(1, -2)
            self:draw()
            self.changed = true
        else
            self.changed = false
        end
    else
        self.changed = false
    end
end

return a