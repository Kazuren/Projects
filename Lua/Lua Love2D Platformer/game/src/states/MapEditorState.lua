MapEditorState = class('MapEditorState', BaseState)

function MapEditorState:initialize()
    self.stack = StateManager:new({renderAll = false})
    self.stack:push(MapViewState:new(self.stack))
end

function MapEditorState:update(dt)
    if #self.stack.states == 0 then
        gStateStack:pop()
        return
    end
    self.stack:update(dt)
end

function MapEditorState:render()
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    love.graphics.clear(gColorManager:getColor('black'))
    love.graphics.push()
    love.graphics.scale(s)
    self.stack:render()
    love.graphics.pop()
end
