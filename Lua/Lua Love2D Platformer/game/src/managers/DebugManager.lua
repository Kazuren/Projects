DebugManager = class('DebugManager')

function DebugManager:initialize(textColor, valueColor, font)
    self.monitors = {}
    self.debug = true

    self.textColor = textColor or {1, 1, 1, 1}
    self.valueColor = valueColor or {1, 1, 1, 1}
    self.font = font
end

function DebugManager:add(text, update)
    table.insert(self.monitors, {text=text, update=update})
end

function DebugManager:update()
    if gInput:pressed('debug') then
        self.debug = not self.debug
    end

    if self.debug then
        for _, monitor in pairs(self.monitors) do
            monitor.value = monitor.update()
        end
    end
end

function DebugManager:render()
    if self.debug then
        for i, monitor in pairs(self.monitors) do
            love.graphics.printf(
                {self.textColor, monitor.text, self.valueColor, monitor.value}, self.font,
                self.font:getHeight(), lume.round(self.font:getHeight() * 2 * i - self.font:getHeight()),
                self.font:getWidth(monitor.text) + self.font:getWidth(monitor.value), 'left'
            )
        end
    end
end
