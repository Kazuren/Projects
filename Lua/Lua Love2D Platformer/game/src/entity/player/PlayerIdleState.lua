PlayerIdleState = class('PlayerIdleState', EntityBaseState)

function PlayerIdleState:initialize(player, chapter)
    EntityBaseState.initialize(self, player)
    self.player = player
end

function PlayerIdleState:enter(params)
    self.player:changeAnimation('idle')
    self.player.currentAnimation:clone()
end

function PlayerIdleState:update(dt)
    local actualX, actualY, cols, len

    actualX, actualY, cols, len = self.player.world:check(self.player, self.player.x+self.player.hitbox.x, self.player.y+self.player.hitbox.y+1, self.player.filter)
    if len == 0 or lume.all(cols, function(collision) return collision.type == 'cross' end) then
        self.player:changeState('air')
        return
    end

    if gInput:pressed('jump') then
        self.player:changeState('jump')
        return
    end

    if gInput:pressed('blink') then
        local x = self.player.flipx
        x = (gInput:down('up') or gInput:down('down')) and 0 or x
        x = gInput:down('left') and -1 or gInput:down('right') and 1 or x
        local y = gInput:down('up') and -1 or gInput:down('down') and 1 or 0

        self.player:changeState('blink', {x = x, y = y})
        return
    end

    if gInput:down('left') then
        self.player.flipx = -1
        actualX, actualY, cols, len = self.player.world:check(self.player, self.player.x+self.player.hitbox.x-1, self.player.y+self.player.hitbox.y, self.player.filter)
        if len == 0 or lume.all(cols, function(collision) return collision.type == 'cross' end) then
            self.player:changeState('walk')
            return
        end
    elseif gInput:down('right') then
        self.player.flipx = 1
        actualX, actualY, cols, len = self.player.world:check(self.player, self.player.x+self.player.hitbox.x+1, self.player.y+self.player.hitbox.y, self.player.filter)
        if len == 0 or lume.all(cols, function(collision) return collision.type == 'cross' end) then
            self.player:changeState('walk')
            return
        end
    end
end

function PlayerIdleState:__tostring()
    return 'Idle'
end