PlayerBlinkState = class('PlayerBlinkState', EntityBaseState)

function PlayerBlinkState:initialize(player, chapter)
    EntityBaseState.initialize(self, player)
    self.player = player
end

function PlayerBlinkState:enter(params)
    local filter = function(self, other)
        return 'cross'
    end
    -- reset dx and dy unless going bottom left/right and dx/dy is also going bottom left/right
    self.player.dx = 0
    self.player.dy = 0

    self.direction = {x=params.x, y=params.y}
    self.tween = flux.to(self.player, self.player.blinkTime, {
        x = self.player.x + self.direction.x * self.player.blinkDistance * (self.direction.y ~= 0 and self.player.halfBlinkMultiplier or 1),
        y = self.player.y + self.direction.y * self.player.blinkDistance * (self.direction.x ~= 0 and self.player.halfBlinkMultiplier or 1),
    }):ease("cubicout")
        :onupdate(function()
            local actualX, actualY, cols, len = self.player.world:move(self.player, self.player.x+self.player.hitbox.x, self.player.y+self.player.hitbox.y, filter)
            --self.player.x, self.player.y = actualX - self.player.hitbox.x, actualY - self.player.hitbox.y
        end)
        :oncomplete(function() self.player:changeState('air') end)

    self.player:changeAnimation('blink')
    self.player.currentAnimation:clone()
end

function PlayerBlinkState:update(dt)
    
end

function PlayerBlinkState:__tostring()
    return 'Blink'
end