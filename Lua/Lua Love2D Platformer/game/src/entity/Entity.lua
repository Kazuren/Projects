Entity = class('Entity')

function Entity:initialize(def)
    self.animations = self:createAnimations(def.animations or {})
    self.texture = def.texture

    self.w = def.w
    self.h = def.h

    self.x = def.x
    self.y = def.y

    self.zindex = def.zindex or 1000

    self.hitbox = def.hitbox or nil

    self.flipx = def.flipx or 1
    self.flipy = 1

    self.dx = def.dx or 0
    self.dy = def.dy or 0

    self.world = def.world or nil
    self.properties = def.properties or {}

    if self.hitbox then
        self.world:add(
            self,
            self.x+self.hitbox.x,
            self.y+self.hitbox.y,
            self.hitbox.w,
            self.hitbox.h
        )
    end

    self.stateMachine = def.stateMachine or StateMachine:new()
end

function Entity:destroy()
    if self.hitbox and self.world then
        self.world:remove(self)
    end
end

function Entity:changeState(name, params)
    self.stateMachine:change(name, params)
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Entity:createAnimations(animations)
    local animationsReturned = {}
    for k, animationDef in pairs(animations) do
        animationsReturned[k] = anim8.newAnimation(
            animationDef[1], -- frames
            animationDef[2], -- duration
            animationDef[3] -- onLoop
        )
    end

    return animationsReturned
end

--[[
    Called when we interact with this entity, as by pressing enter.
]]
function Entity:onInteract()

end

function Entity:update(dt)
    self.stateMachine:update(dt)
    self.currentAnimation:update(dt)
end

function Entity:render()
    self.stateMachine:render()
end