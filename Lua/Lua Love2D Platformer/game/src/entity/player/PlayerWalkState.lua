PlayerWalkState = class('PlayerWalkState', EntityBaseState)

function PlayerWalkState:initialize(player, chapter)
    EntityBaseState.initialize(self, player)
    self.player = player
end

function PlayerWalkState:enter(params)
    self.player:changeAnimation('walk')
    self.player.currentAnimation:clone()
end

function PlayerWalkState:exit()

end

function PlayerWalkState:update(dt)
    local actualX, actualY, cols, len

    if gInput:down('left') then
        self.player.flipx = -1
        if self.player.dx > 0 then
            self.player.dx = lume.approach(self.player.dx, 0, self.player.groundFriction)
        elseif self.player.dx < -self.player.dxMax then
            self.player.dx = lume.approach(self.player.dx, -self.player.dxMax, self.player.groundFrictionMaxSpeed)
        else
            self.player.dx = lume.approach(self.player.dx, -self.player.dxMax, self.player.groundAcceleration)
        end
    elseif gInput:down('right') then
        self.player.flipx = 1
        if self.player.dx < 0 then
            self.player.dx = lume.approach(self.player.dx, 0, self.player.groundFriction)
        elseif self.player.dx > self.player.dxMax then
            self.player.dx = lume.approach(self.player.dx, self.player.dxMax, self.player.groundFrictionMaxSpeed)
        else
            self.player.dx = lume.approach(self.player.dx, self.player.dxMax, self.player.groundAcceleration)
        end
    else
        self.player.dx = lume.approach(self.player.dx, 0, self.player.groundFriction) -- groundFrictionMaxSpeed
        if self.player.dx == 0 then
            self.player:changeState('idle')
            return
        end
    end

    if gInput:pressed('blink') then
        local x = self.player.flipx
        x = (gInput:down('up') or gInput:down('down')) and 0 or x
        x = gInput:down('left') and -1 or gInput:down('right') and 1 or x
        local y = gInput:down('up') and -1 or gInput:down('down') and 1 or 0

        self.player:changeState('blink', {x = x, y = y})
        return
    end

    if gInput:pressed('jump') then
        self.player:changeState('jump') -- check if additional key press of left/right
        return
    end

    local goalX = self.player.x + self.player.dx * dt
    local goalY = self.player.y

    actualX, actualY, cols, len = self.player.world:move(self.player, goalX+self.player.hitbox.x, goalY+self.player.hitbox.y, self.player.filter)
    self.player.x, self.player.y = actualX - self.player.hitbox.x, actualY - self.player.hitbox.y

    for i, collision in pairs(cols) do
        if collision.normal.x ~= 0 then
            if collision.type ~= 'cross' then
                self.player.dx = 0
                self.player:changeState('idle')
                return
            end
        end
    end

    actualX, actualY, cols, len = self.player.world:check(self.player, goalX+self.player.hitbox.x, self.player.y+self.player.hitbox.y+1, self.player.filter)
    if len == 0 or lume.all(cols, function(collision) return collision.type == 'cross' end) then
        self.player:changeState('air')
        return
    end
end

function PlayerWalkState:__tostring()
    return 'Walk'
end