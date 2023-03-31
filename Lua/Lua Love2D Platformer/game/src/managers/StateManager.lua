StateManager = class('StateManager')
-- add update last state
function StateManager:initialize(behavior)
    self.behavior = behavior or {renderAll = true}
    self.states = {}
end

function StateManager:update(dt)
    if next(self.states) then
        local metadata = self.states[#self.states].metadata
        if metadata and metadata.updateLast then
            self.states[#self.states - 1]:update(dt)
        end

        self.states[#self.states]:update(dt)
    end
end

function StateManager:render()
    if self.behavior.renderAll then
        for i, state in ipairs(self.states) do
            state:render()
        end
    else
        if next(self.states) then
            self.states[#self.states]:render()
        end
    end
end

function StateManager:clear()
    self.states = {}
end

function StateManager:push(state, params, metadata)
    state.metadata = metadata
    table.insert(self.states, state)
    state:enter(params)
end

function StateManager:pop(params)
    self.states[#self.states]:exit()
    table.remove(self.states)
end