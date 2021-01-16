local a = {}

local function updateMax(elements)
    local max = 0
    for i, v in pairs(elements) do
        if v.y > max then max = v.y end
    end
    return max
end

function a:new(parentTerm, x, y, w, h, visible)
    local win = window.create(parentTerm, x, y, w, h, visible)
    local o = {
        x = x,
        y = y,
        w = w,
        h = h, 
        window = win,
        background = colors.black,
        elements = {},
        scroll = 0,
        maxY = 0
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function a:createElement(textColor, backgroundColor, text, x, y, click)
    return {
        textColor = textColor or colors.white,
        backgroundColor = backgroundColor or self.background or colors.black,
        text = text or "",
        x = x or 1,
        y = y or 1,
        click = click
    }
end

function a:setBackgroundColor(color)
    self.background = color
end

local function genId()
    local chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    local out = ""
    for i = 1, 8 do
        local chose = math.random(1, #chars)
        out = out .. chars:sub(chose, chose + 1)
    end
    return out
end

function a:addElement(element)
    local id = genId()
    self.elements[id] = element
    self.maxY = updateMax(self.elements)
    return id 
end

function a:removeElement(id)
    self.elements[id] = nil
    self.maxY = updateMax(self.elements)
end

function a:clearElements()
    self.elements = {}
    self.maxY = updateMax(self.elements)
end

function a:getElements()
    return self.elements
end

function a:draw()
    if self.visible == false then return end
    local w = self.window
    w.setBackgroundColor(self.background)
    w.clear()
    for i, v in pairs(self.elements) do

        if v.y > self.scroll and v.y <= self.scroll + self.h then
            -- check if it is in bounds, otherwise don't bother drawing the element
            w.setBackgroundColor(v.backgroundColor)
            w.setTextColor(v.textColor)
            w.setCursorPos(v.x, v.y - self.scroll)
            w.write(v.text)
        end
    end
end

function a:setVisiblity(value)
    self.window.setVisible(value)
    self.visible = value
end

function a:reposition(x, y)
    self.window.reposition(x, y)
end

function a:resize(w, h)
    self.window.reposition(self.x, self.y, w, h)
end

function a:redirectEvents(e)
    if not self.visible then return end
    if e[1] == "mouse_scroll" then
        local d, x, y = e[2], e[3], e[4]
        local nscroll = self.scroll + d
        if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h and nscroll >= 0 and nscroll < self.maxY then
            self.scroll = nscroll
            self:draw()
        end
    elseif e[1] == "mouse_click" then
        local m, x, y = e[2], e[3], e[4]
        
        for i, v in pairs(self.elements) do
            -- Check 1: Has a click funcion?
            -- Check 2: Is it above limits?
            -- Check 3: Is it below limits?
            -- Check 4: Is it <= minx?
            -- Check 5: Is it >= maxx?
            -- Check 6: Is the Y correct?
            
            if v.click and v.y > self.scroll and v.y <= self.scroll + self.h and x - self.x + 1 >= v.x and x - self.x <= v.x + v.text:len() - 2 and y == self.y - self.scroll then
                v.click(m, self.x - v.x, self.scroll - y, x, y)
            end
        end
    end
end

return a