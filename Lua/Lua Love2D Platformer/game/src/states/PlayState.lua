PlayState = class('PlayState', BaseState)

-- TODO: go to select save state first -- has 3 save files that each one stores chapter data such as spawnpoint on that chapter
-- TODO: after select save state go to select chapter state
-- TODO: each chapter has data about it(Example: collectibles 5 out of 64 5/64)

local function collides(point, box)
	return point.x < box.x + box.w and
        box.x < point.x and
		point.y < box.y + box.h and
		box.y < point.y
end

function PlayState:initialize()
    self.world = bump.newWorld(16)
    self.chapter = Chapter:new('ChapterOne', self.world)

    local g = gAnimationGrids.player
    self.player = Player:new({
        animations = {
            idle = {g(1, 1), 0.3},
            walk = {g('2-6', 1), 0.3},
            -- ascend = {g(3,1), 25},
            air = {g(1,1), 25},
            blink = {g(1,1), 25}
            -- slideback = {g(7,1), 0.15},
            -- slideforward = {g(8,1), 0.15},
            -- wallslide = {g(9,1), 0.15},
            -- lookdown = {g(11,1), 0.15},
            -- lookup = {g(12,1), 0.15}
        }, -- table of anim8 animations (Possibly define these somehow in another file and include them here)
        texture = 'player',
        w = 24,
        h = 24,
        x = self.chapter.maps[1].x + TILE_SIZE, -- chapter save file --> currentMap --> currentMap spawnpoint
        y = self.chapter.maps[1].y + TILE_SIZE, -- chapter save file --> currentMap --> currentMap spawnpoint
        --TODO: fix hitbox
        hitbox = {x=-2,y=-5,w=4,h=13},
        world = self.world
    })

    self.player.stateMachine = StateMachine:new({
        ['idle'] = function() return PlayerIdleState:new(self.player, self.chapter) end,
        ['walk'] = function() return PlayerWalkState:new(self.player, self.chapter) end,
        ['air'] = function() return PlayerAirState:new(self.player, self.chapter) end,
        ['jump'] = function() return PlayerJumpState:new(self.player, self.chapter) end,
        ['blink'] = function() return PlayerBlinkState:new(self.player, self.chapter) end,
    })
    self.player:changeState('idle')

    self.camera = Camera(GAME_WIDTH/2, GAME_HEIGHT/2, GAME_WIDTH, GAME_HEIGHT)
    self.camera.draw_deadzone = true
    self.camera:setFollowStyle('PLATFORMER')

    local map = self.chapter.maps[self.chapter.currentMap]
    self.camera:setBounds(map.x, map.y, map.w * TILE_SIZE, map.h * TILE_SIZE)

    self.camera:follow(lume.round(self.player.x), lume.round(self.player.y))
    self.camera:update()
end

function PlayState:update(dt)
    self.player:update(dt)

    self.camera:follow(lume.round(self.player.x), lume.round(self.player.y))
    self.camera:update()

    local map = self.chapter.maps[self.chapter.currentMap]
    if (self.player.x < map.x or self.player.x > map.x + map.w * TILE_SIZE or self.player.y < map.y or self.player.y > map.y + map.h * TILE_SIZE) and self.chapter.previousMap == nil then
        for _, connection in pairs(map.connections) do
            local connected_map = self.chapter.maps[connection]
            if collides({x=self.player.x, y=self.player.y}, {x=connected_map.x,y=connected_map.y,w=connected_map.w * TILE_SIZE,h=connected_map.h * TILE_SIZE}) then
                self.chapter.previousMap = self.chapter.currentMap
                self.chapter.currentMap = connection
                local newMap = self.chapter.maps[connection]
                newMap:create()
                
                -- variable time depending how fast you go
                --TODO: fix camera getting stuck for a bit when player touches camera deadzone
                -- tip: use minimum width rectangle when transitioning and set to actual bounds when finishing
                self.camera:setBounds(self.camera.x - GAME_WIDTH / 2, self.camera.y - GAME_HEIGHT / 2, GAME_WIDTH, GAME_HEIGHT)
                Timer.tween(0.8, {
                    [self.camera] = {
                        bounds_min_x = newMap.x,
                        bounds_min_y = newMap.y,
                        bounds_max_x = newMap.x + newMap.w * TILE_SIZE,
                        bounds_max_y = newMap.y + newMap.h * TILE_SIZE
                    }
                }):ease(easing.outSine)
                :finish(function() 
                    map:destroy()
                    
                    self.chapter.previousMap = nil
                    self.camera:setBounds(newMap.x, newMap.y, newMap.w * TILE_SIZE, newMap.h * TILE_SIZE)
                end)
                break
            end
        end
    end
end

function PlayState:render()
    love.graphics.rectangle('line',self.camera.bounds_min_x,self.camera.bounds_min_y,self.camera.bounds_max_x - self.camera.bounds_min_x,self.camera.bounds_max_y - self.camera.bounds_min_y)
    love.graphics.printf(tostring(self.player.stateMachine.current),gFonts['medium'], 16, 64, UI_WIDTH, 'left')
    
    self.chapter:render() -- put chapter in deep stack
    self.player:render() -- put player in deep stack

    push:start()

    self.camera:draw()
    self.camera:attach()

    deep.execute() -- execute deepstack

    self.camera:detach()

    push:finish()

    local s = math.min(love.graphics:getWidth() / GAME_WIDTH, love.graphics:getHeight() / GAME_HEIGHT)
    love.graphics.push()
    love.graphics.translate(self.camera.w * s / 2, self.camera.h * s / 2)
    love.graphics.scale(self.camera.scale)
    love.graphics.rotate(self.camera.rotation)
    love.graphics.translate(-self.camera.x * s, -self.camera.y * s)
    gColorManager:setColor('red')
    for _, rect in pairs(self.world.rects) do
        love.graphics.rectangle('line', lume.round(rect.x) * s, lume.round(rect.y) * s, lume.round(rect.w) * s, lume.round(rect.h) * s)
    end
    gColorManager:revert()
    love.graphics.pop()
end