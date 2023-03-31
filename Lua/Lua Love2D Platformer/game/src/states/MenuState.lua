MenuState = class('MenuState', BaseState)

function MenuState:initialize(menu)
    self.menu = menu
    self.menu.stack:clear()
    self.menu.stack:push(self.menu['main'])
end

function MenuState:update(dt)
    if gInput:pressed('cancel') then
        if #self.menu.stack.states > 1 then 
            self.menu.stack:pop()
        else
            gStateStack:pop()
            return
        end
    end
    self.menu.stack:update(dt)
end

function MenuState:render()
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    love.graphics.push()
    love.graphics.scale(s)
    self.menu.stack:render()
    love.graphics.pop()
end
