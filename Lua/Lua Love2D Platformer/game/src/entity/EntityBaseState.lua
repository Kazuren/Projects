EntityBaseState = class('EntityBaseState')

function EntityBaseState:initialize(entity)
    self.entity = entity
end

function EntityBaseState:update(dt) end
function EntityBaseState:enter() end
function EntityBaseState:exit() end
function EntityBaseState:processAI(params, dt) end

function EntityBaseState:render()
    local s = math.min(love.graphics:getWidth() / GAME_WIDTH, love.graphics:getHeight() / GAME_HEIGHT)
    local anim = self.entity.currentAnimation
    deep.queue(self.entity.zindex, function()
        anim:draw(gAssets.graphics[self.entity.texture], lume.round(self.entity.x), lume.round(self.entity.y), 0, self.entity.flipx, self.entity.flipy, self.entity.w/2, self.entity.h/2)
        -- love.graphics.setColor(1,0,0,0.5)
        -- love.graphics.rectangle('fill', lume.round(self.entity.x + self.entity.hitbox.x), lume.round(self.entity.y + self.entity.hitbox.y), self.entity.hitbox.w, self.entity.hitbox.h)
        -- love.graphics.setColor(1,1,1,1)
    end)
end