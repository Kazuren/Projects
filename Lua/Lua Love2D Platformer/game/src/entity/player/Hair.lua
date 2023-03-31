Hair = class('Hair')

function Hair:initialize(player, length, scale)
    self.player = player
    self.scale = scale
    self.hair = {}
    self.hairColor = 'prelude'
    for i=1, length do
        self.hair[i] = {x=self.player.x, y=self.player.y, size = math.max(24,math.min(28,32-i))}
    end
end

function Hair:update(dt)
    local last={x=self.player.x, y=self.player.y}
    for _, h in pairs(self.hair) do
        h.x = h.x + (last.x-h.x)/1.5
        h.y = h.y + (last.y+0.5-h.y)/1.5
        last = h
    end
end

function Hair:render()
    gColorManager:setColor(self.hairColor)
    for _, h in pairs(self.hair) do
        love.graphics.rectangle('fill',
            h.x * self.scale,
            h.y * self.scale,
            h.size,
            h.size,
            8,
            8
        )
    end
    gColorManager:revert()
end