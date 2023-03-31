PlayerJumpState = class('PlayerJumpState', EntityBaseState)

function PlayerJumpState:initialize(player, chapter)
    EntityBaseState.initialize(self, player)
    self.player = player
end

function PlayerJumpState:enter(params)
    self.player:changeAnimation('air')
    self.player.currentAnimation:clone()
    -- switch to tween approach on jump

    self.player.dy = -self.player.jumpSpeed
    self.player.jumpTween =  flux.to(self.player, self.player.jumpTime, {dy = 0}):ease("quadin"):oncomplete(function() self.player:changeState('air') end)
end

function PlayerJumpState:update(dt)
    local actualX, actualY, cols, len

    if gInput:down('left') then
        self.player.flipx = -1
        if self.player.dx > 0 then
            self.player.dx = lume.approach(self.player.dx, 0, self.player.airFriction)
        elseif self.player.dx < -self.player.dxMax then
            self.player.dx = lume.approach(self.player.dx, -self.player.dxMax, self.player.airFrictionMaxSpeed)
        else
            self.player.dx = lume.approach(self.player.dx, -self.player.dxMax, self.player.airAcceleration)
        end
    elseif gInput:down('right') then
        self.player.flipx = 1
        if self.player.dx < 0 then
            self.player.dx = lume.approach(self.player.dx, 0, self.player.airFriction)
        elseif self.player.dx > self.player.dxMax then
            self.player.dx = lume.approach(self.player.dx, self.player.dxMax, self.player.airFrictionMaxSpeed)
        else
            self.player.dx = lume.approach(self.player.dx, self.player.dxMax, self.player.airAcceleration)
        end
    else
        self.player.dx = lume.approach(self.player.dx, 0, self.player.airFriction) -- airFrictionMaxSpeed
    end

    if gInput:pressed('blink') then
        local x = self.player.flipx
        x = (gInput:down('up') or gInput:down('down')) and 0 or x
        x = gInput:down('left') and -1 or gInput:down('right') and 1 or x
        local y = gInput:down('up') and -1 or gInput:down('down') and 1 or 0

        self.player:changeState('blink', {x = x, y = y})
        return
    end

    if gInput:released('jump') then
        self.player:changeState('air')
        return
    end

    local goalX = self.player.x + self.player.dx * dt
    local goalY = self.player.y + self.player.dy * dt

    actualX, actualY, cols, len = self.player.world:move(self.player, goalX+self.player.hitbox.x, goalY+self.player.hitbox.y, self.player.filter)
    self.player.x, self.player.y = actualX - self.player.hitbox.x, actualY - self.player.hitbox.y

    for i, collision in pairs(cols) do
        if collision.normal.x ~= 0 then
            if collision.type ~= 'cross' then
                self.player.dx = 0
            end
        end
        if collision.normal.y == 1 then -- top
            if collision.type ~= 'cross' then
                self.player.dy = 0
                self.player:changeState('air')
                return
            end
        end
    end
end

function PlayerJumpState:exit()
    self.player.jumpTween:stop()
end

function PlayerJumpState:__tostring()
    return 'Jump'
end