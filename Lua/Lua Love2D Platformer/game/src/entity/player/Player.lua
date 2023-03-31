Player = class('Player', Entity)
--TODO: Hair class
function Player:initialize(def)
    Entity.initialize(self, def)

    self.multiplier = 1

    self.jumpSpeed = 100
    self.jumpTime = 0.3
    self.wallJumpSpeed = 165
    self.dxMax = 80
    self.dyMax = 140

    -- if above max speed then decelerate to max speed slowly
    self.groundAcceleration = 40
    self.groundFriction = 40
    self.groundFrictionMaxSpeed = 2
    
    self.airAcceleration = 40
    self.airFriction = 40
    self.airFrictionMaxSpeed = 0 -- dont lose speed on air
    self.gravity = 14
    self.gravitySlide = 7

    self.blinkTime = 0.3 -- variable time depending on speed
    self.blinkDistance = 32 -- in pixels
    self.halfBlinkMultiplier = 2/3
    self.maxBlinks = 1
    self.blinks = 1

    self.filter = function(self, other) -- default filter if there is none supplied
        if other.properties.collidable then
            return 'slide'
        end
        return 'cross'
        -- if other.properties.platform then
        --     if self.y + self.hitbox.y + self.hitbox.h > other.y then
        --         return 'cross'
        --     else
        --         return 'slide'
        --     end
        -- end
    end

    --local s = math.min(love.graphics:getWidth() / GAME_WIDTH, love.graphics:getHeight() / GAME_HEIGHT)
    --self.hair = Hair:new(self, 5, s)
    -- self.max_dx = 100
    -- self.max_dy = 120
end

function Player:update(dt)
    Entity.update(self, dt)
    --self.hair:update(dt)
end

function Player:render()
    Entity.render(self)
    --self.hair:render(self.x, self.y)
end