MapEditState = class('MapEditState', BaseState)

--TODO: ability to move and drag objects if holding click on an already selected object
--TODO: BACKGROUNDS TABLE, CAN HAVE BACKGROUNDS WITH THEIR OWN UPDATE/RENDER FUNCTION, EITHER ANIMATION OR STILL IMAGES
--TODO: can select any number of backgrounds/animations for each map

-- TODO: potential rework --> have a UI manager and make a giant for loop for every element
-- TODO: and if on click a UI element collides then break the loop
-- TODO: also use events for actions such as save game or increase/decrease map size(params-->side)

-- TODO: if clicking on a position where a selected Tile exists dont open the popup menu

local function collides(point, box)
	return point.x < box.x + box.w and
        box.x < point.x and
		point.y < box.y + box.h and
		box.y < point.y
end

local plus_update, plus_render, minus_update, minus_render

function MapEditState:initialize(stack, chapter, map)
    self.stack = stack
    self.chapter = chapter
    self.map = map
    self.font = gFonts['small']
    self.mouse = Mouse('arrow')

    self.x = 320
    self.y = 180
    self.w = GAME_WIDTH * 5
    self.h = GAME_HEIGHT * 5
    self.scale = 5
    self.selectedTile = nil
    self.activeItem = nil

    self.availableTiles = (function()
        local tiles = {}

        lume.each(TILESETS, function(tileset)
            for id, tile in pairs(tileset.tiles) do
                if tile.mapEditor and tile.mapEditor.visible then
                    table.insert(tiles, id+tileset.firstgid)
                end
            end
        end)
        return tiles
    end)()
    self.availableObjects = (function()
        local objects = {}

        for id, object in pairs(OBJECTS) do
            if object.mapEditor and object.mapEditor.visible then
                table.insert(objects, id)
            end
        end
        return objects
    end)()

    self.inBounds = function()
        local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
        return self.mouse.x / s >= self.x and self.mouse.x / s <= self.x + self.w and self.mouse.y / s >= self.y and self.mouse.y / s <= self.y + self.h
    end

    self.camera = Camera(self.w/2, self.h/2, self.w, self.h)
    self.camera:setBounds(-TILE_SIZE * self.scale, -TILE_SIZE * self.scale, (self.map.w + 2) * TILE_SIZE * self.scale, (self.map.h + 2) * TILE_SIZE * self.scale)
    self.followPoint = {x=0, y=0}
    self.boxes = {
        Box:new({
            x = self.x,
            y = 40,
            w = 120,
            h = 120,
            properties = {
                tiles=self.availableTiles,
                objects=self.availableObjects,
                currentItem = nil
            },
            onClick = function(box) self.activeItem = box.properties.currentItem end,
            onRightClick = function(box) self.stack:push(MapSelectItemState:new(self.stack, box)) end
        }),
        Box:new({
            x = self.x + 160,
            y = 40,
            w = 120,
            h = 120,
            properties = {
                tiles=self.availableTiles,
                objects=self.availableObjects,
                currentItem = nil
            },
            onClick = function(box) self.activeItem = box.properties.currentItem end,
            onRightClick = function(box) self.stack:push(MapSelectItemState:new(self.stack, box)) end
        })
    }

    self.objects = {}
    self.tiles = {}

    self.popup = {
        update = function() end,
        render = function() end,
        clear = function(popup)
            popup.x = nil
            popup.y = nil
            popup.w = nil
            popup.h = nil
            popup.candidates = nil
            popup.update = function() end
            popup.render = function() end
        end,
        resize = function(popup)
            -- if popup.candidates then
            --     local mouse_x = 40 * #popup.candidates + self.x + popup.x
            --     local mouse_y = self.y + popup.y + 90
            --     popup.x = (mouse_x - self.x - (#popup.candidates * 80) / 2)
            --     popup.y = (mouse_y - self.y - 90)
            -- end
        end
    }

    -- make tiles from data
    for y = 1, self.map.h do
        self.tiles[y] = {}
        for x = 1, self.map.w do
            local id = self.map.tiles[y][x]
            local tileset = (function()
                for _, tileset in pairs(TILESETS) do
                    if id <= tileset.firstgid + tileset.tilecount then
                        id = id - tileset.firstgid
                        return tileset
                    end
                end
            end)()
            if id > 0 and tileset then
                self.tiles[y][x] = Tile:new({
                    id = id,
                    tileset = tileset,
                    x = (x - 1) * TILE_SIZE,
                    y = (y - 1) * TILE_SIZE,
                    world = nil
                })
            else
                self.tiles[y][x] = {}
            end
        end
    end
    -- make objects from data
    for _, object in pairs(self.map.objects) do
        table.insert(self.objects, Object:new({
            id = object.id,
            x = object.x,
            y = object.y
        }))
    end

    self.buttons = {}
    plus_update = function(button)
        local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
        local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
        button.rectmode = 'line'
        button.textColor = 'silvertree'
        if collides({x=mouse_x,y=mouse_y}, {x = self.x + button.x, y = self.y + button.y, w = button.w, h = button.h}) and self.inBounds() and not (self.popup.x and collides({x=mouse_x,y=mouse_y}, {x = self.x + self.popup.x, y = self.y + self.popup.y, w = self.popup.w, h = self.popup.h})) then
            self.mouse:set('hand')
            button.rectmode = 'fill'
            button.textColor = 'whitesmoke'
            if gInput:pressed('mouse1') then
                if button.w == TILE_SIZE * self.scale then
                    if button.x == -TILE_SIZE * self.scale then
                        self.map.w = self.map.w + 1
                        self.map.x = self.map.x - TILE_SIZE
                        for y = 1, self.map.h do
                            table.insert(self.tiles[y], 1, {})
                            for x = 1, self.map.w do
                                local tile = self.tiles[y][x]
                                if next(tile) then
                                    tile.x = tile.x + tile.w
                                end
                            end
                        end
                        for _, object in pairs(self.objects) do
                            object.x = object.x + TILE_SIZE
                        end
                    elseif button.x == self.map.w * TILE_SIZE * self.scale then
                        self.map.w = self.map.w + 1
                        for y = 1, self.map.h do
                            table.insert(self.tiles[y], {})
                        end
                    end
                elseif button.h == TILE_SIZE * self.scale then
                    if button.y == -TILE_SIZE * self.scale then
                        self.map.h = self.map.h + 1
                        self.map.y = self.map.y - TILE_SIZE
                        table.insert(self.tiles, 1, {})
                        for x = 1, self.map.w do
                            self.tiles[1][x] = {}
                            for y = 1, self.map.h do
                                local tile = self.tiles[y][x]
                                if next(tile) then
                                    tile.y = tile.y + tile.h
                                end
                            end
                        end
                        for _, object in pairs(self.objects) do
                            object.y = object.y + TILE_SIZE
                        end
                    elseif button.y == self.map.h * TILE_SIZE * self.scale then
                        self.map.h = self.map.h + 1
                        table.insert(self.tiles, {})
                        for x = 1, self.map.w do
                            table.insert(self.tiles[self.map.h], {})
                        end
                    end
                end
                self.camera:setBounds(-TILE_SIZE * self.scale, -TILE_SIZE * self.scale, (self.map.w + 2) * TILE_SIZE * self.scale, (self.map.h + 2) * TILE_SIZE * self.scale)
            end
        end
    end
    plus_render = function(button)
        gColorManager:setColor(button.color)
        love.graphics.rectangle(button.rectmode, button.x, button.y, button.w, button.h)
        gColorManager:setColor(button.textColor)
        love.graphics.printf('+', self.font, button.x, button.y + button.h / 2 - self.font:getHeight() / 2, button.w, 'center')
        gColorManager:revert()
    end
    
    minus_update = function(button)
        local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
        local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
        button.textColor = 'sunset'
        button.alpha = 0.3
        if collides({x=mouse_x,y=mouse_y}, {x = self.x + button.x, y = self.y + button.y, w = button.w, h = button.h}) and self.inBounds() and not (self.popup.x and collides({x=mouse_x,y=mouse_y}, {x = self.x + self.popup.x, y = self.y + self.popup.y, w = self.popup.w, h = self.popup.h})) then
            self.mouse:set('hand')
            button.alpha = 1
            button.textColor = 'whitesmoke'
            if gInput:pressed('mouse1') then
                if button.w == TILE_SIZE * self.scale then
                    if button.x == 0 then
                        self.map.w = self.map.w - 1
                        self.map.x = self.map.x + TILE_SIZE
                        for y = 1, self.map.h do
                            table.remove(self.tiles[y], 1)
                            for x = 1, self.map.w do
                                local tile = self.tiles[y][x]
                                if next(tile) then
                                    tile.x = tile.x - tile.w
                                end
                            end
                        end
                        for _, object in pairs(self.objects) do
                            object.x = object.x - TILE_SIZE
                        end
                    elseif button.x == (self.map.w - 1) * TILE_SIZE * self.scale then
                        self.map.w = self.map.w - 1
                        for y = 1, self.map.h do
                            table.remove(self.tiles[y], self.map.w + 1)
                        end
                    end
                elseif button.h == TILE_SIZE * self.scale then
                    if button.y == 0 then
                        self.map.h = self.map.h - 1
                        table.remove(self.tiles, 1)
                        for y = 1, self.map.h do
                            for x = 1, self.map.w do
                                local tile = self.tiles[y][x]
                                if next(tile) then
                                    tile.y = tile.y - tile.h
                                end
                            end
                        end
                        for _, object in pairs(self.objects) do
                            object.y = object.y - TILE_SIZE
                        end
                    elseif button.y == (self.map.h - 1) * TILE_SIZE * self.scale then
                        self.map.h = self.map.h - 1
                        table.remove(self.tiles, self.map.h + 1)
                    end
                end
                self.camera:setBounds(-TILE_SIZE * self.scale, -TILE_SIZE * self.scale, (self.map.w + 2) * TILE_SIZE * self.scale, (self.map.h + 2) * TILE_SIZE * self.scale)
            end
        end
    end
    minus_render = function(button)
        gColorManager:setColor(button.color, button.alpha)
        love.graphics.rectangle(button.rectmode, button.x, button.y, button.w, button.h)
        gColorManager:setColor(button.textColor)
        love.graphics.printf('-', self.font, button.x, button.y + button.h / 2 - self.font:getHeight() / 2, button.w, 'center')
        gColorManager:revert()
    end

    self.buttons = {
        -- Plus button left
        {
            x = -TILE_SIZE * self.scale,
            y = 0,
            w = TILE_SIZE * self.scale,
            h = self.map.h * TILE_SIZE * self.scale,
            color = 'silvertree',
            textColor = 'silvertree',
            rectmode = 'line',
            update = plus_update,
            render = plus_render,
            resize = function(button)
                button.x = -TILE_SIZE * self.scale
                button.y = 0
                button.w = TILE_SIZE * self.scale
                button.h = self.map.h * TILE_SIZE * self.scale
            end
        },
        -- Plus button right
        {
            x = self.map.w * TILE_SIZE * self.scale,
            y = 0,
            w = TILE_SIZE * self.scale,
            h = self.map.h * TILE_SIZE * self.scale,
            color = 'silvertree',
            textColor = 'silvertree',
            rectmode = 'line',
            update = plus_update,
            render = plus_render,
            resize = function(button)
                button.x = self.map.w * TILE_SIZE * self.scale
                button.y = 0
                button.w = TILE_SIZE * self.scale
                button.h = self.map.h * TILE_SIZE * self.scale
            end
        },
        -- Plus button top
        {
            x = 0,
            y = -TILE_SIZE * self.scale,
            w = self.map.w * TILE_SIZE * self.scale,
            h = TILE_SIZE * self.scale,
            color = 'silvertree',
            textColor = 'silvertree',
            rectmode = 'line',
            update = plus_update,
            render = plus_render,
            resize = function(button)
                button.x = 0
                button.y = -TILE_SIZE * self.scale
                button.w = self.map.w * TILE_SIZE * self.scale
                button.h = TILE_SIZE * self.scale
            end
        },
        -- Plus button bottom
        {
            x = 0,
            y = self.map.h * TILE_SIZE * self.scale,
            w = self.map.w * TILE_SIZE * self.scale,
            h = TILE_SIZE * self.scale,
            color = 'silvertree',
            textColor = 'silvertree',
            rectmode = 'line',
            update = plus_update,
            render = plus_render,
            resize = function(button)
                button.x = 0
                button.y = self.map.h * TILE_SIZE * self.scale
                button.w = self.map.w * TILE_SIZE * self.scale
                button.h = TILE_SIZE * self.scale
            end
        }
    }

    self.wheelHandler = Event.on('wheelmoved', function(x, y)
        --TODO: zoom in/out only if all tiles covered(no overshooting)
        self.scale = lume.clamp(self.scale + 1 * lume.sign(y), 2, 5)
        self.camera:setBounds(-TILE_SIZE * self.scale, -TILE_SIZE * self.scale, (self.map.w + 2) * TILE_SIZE * self.scale, (self.map.h + 2) * TILE_SIZE * self.scale)
        for _, button in pairs(self.buttons) do
            button:resize()
        end
        self.popup:resize()
    end)
end

function MapEditState:update(dt)
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    self.mouse:update(dt)
    self.mouse:set('arrow')
    
    -- add minus buttons
    -- left
    local empty = true
    for y = 1, self.map.h do
        if next(self.tiles[y][1]) ~= nil then
            empty = false
            break
        end
    end
    for _, object in pairs(self.objects) do
        if object.x < TILE_SIZE then
            empty = false
            break
        end
    end
    if self.activeItem then empty = false end
    local value, key = lume.match(self.buttons, function(button) return button.x == 0 and button.y == 0 and button.w == TILE_SIZE * self.scale end)
    if key ~= nil and (not empty or not (self.map.w > lume.round(GAME_WIDTH / TILE_SIZE))) then
        table.remove(self.buttons, key)
    end

    if empty and not lume.any(self.buttons, function(button) return button.x == 0 and button.y == 0 and button.w == TILE_SIZE * self.scale end) and self.map.w > lume.round(GAME_WIDTH / TILE_SIZE) then
        table.insert(self.buttons, {
            x = 0,
            y = 0,
            w = TILE_SIZE * self.scale,
            h = self.map.h * TILE_SIZE * self.scale,
            alpha = 0.3,
            color = 'sunset',
            textColor = 'whitesmoke',
            rectmode = 'fill',
            update = minus_update,
            render = minus_render,
            resize = function(button)
                button.x = 0
                button.y = 0
                button.w = TILE_SIZE * self.scale
                button.h = self.map.h * TILE_SIZE * self.scale
            end
        })
    end

    -- right
    local empty = true
    for y = 1, self.map.h do
        if next(self.tiles[y][self.map.w]) ~= nil then
            empty = false
            break
        end
    end
    for _, object in pairs(self.objects) do
        if object.x + object.w >= self.map.w * TILE_SIZE then
            empty = false
            break
        end
    end
    if self.activeItem then empty = false end
    local value, key = lume.match(self.buttons, function(button) return button.x == (self.map.w - 1) * TILE_SIZE * self.scale and button.y == 0 end)
    if key ~= nil and (not empty or not (self.map.w > lume.round(GAME_WIDTH / TILE_SIZE))) then
        table.remove(self.buttons, key)
    end

    if empty and not lume.any(self.buttons, function(button) return button.x == (self.map.w - 1) * TILE_SIZE * self.scale and button.y == 0 end) and self.map.w > lume.round(GAME_WIDTH / TILE_SIZE) then
        table.insert(self.buttons, {
            x = (self.map.w - 1) * TILE_SIZE * self.scale,
            y = 0,
            w = TILE_SIZE * self.scale,
            h = self.map.h * TILE_SIZE * self.scale,
            alpha = 0.3,
            color = 'sunset',
            textColor = 'whitesmoke',
            rectmode = 'fill',
            update = minus_update,
            render = minus_render,
            resize = function(button)
                button.x = (self.map.w - 1) * TILE_SIZE * self.scale
                button.y = 0
                button.w = TILE_SIZE * self.scale
                button.h = self.map.h * TILE_SIZE * self.scale
            end
        })
    end

    -- top
    local empty = true
    for x = 1, self.map.w do
        if next(self.tiles[1][x]) ~= nil then
            empty = false
            break
        end
    end
    for _, object in pairs(self.objects) do
        if object.y < TILE_SIZE then
            empty = false
            break
        end
    end
    if self.activeItem then empty = false end
    local value, key = lume.match(self.buttons, function(button) return button.x == 0 and button.y == 0 and button.w == self.map.w * TILE_SIZE * self.scale end)
    if key ~= nil and (not empty or not (self.map.h > lume.round(GAME_HEIGHT / TILE_SIZE))) then
        table.remove(self.buttons, key)
    end
    if empty and not lume.any(self.buttons, function(button) return button.x == 0 and button.y == 0 and button.w == self.map.w * TILE_SIZE * self.scale end) and self.map.h > lume.round(GAME_HEIGHT / TILE_SIZE) then
        table.insert(self.buttons, {
            x = 0,
            y = 0,
            w = self.map.w * TILE_SIZE * self.scale,
            h = TILE_SIZE * self.scale,
            alpha = 0.3,
            color = 'sunset',
            textColor = 'whitesmoke',
            rectmode = 'fill',
            update = minus_update,
            render = minus_render,
            resize = function(button)
                button.x = 0
                button.y = 0
                button.w = self.map.w * TILE_SIZE * self.scale
                button.h = TILE_SIZE * self.scale
            end
        })
    end

    -- bottom
    local empty = true
    for x = 1, self.map.w do
        if next(self.tiles[self.map.h][x]) ~= nil then
            empty = false
            break
        end
    end
    for _, object in pairs(self.objects) do
        if object.y + object.h >= self.map.h * TILE_SIZE then
            empty = false
            break
        end
    end
    if self.activeItem then empty = false end
    local value, key = lume.match(self.buttons, function(button) return button.x == 0 and button.y == (self.map.h - 1) * TILE_SIZE * self.scale end)
    if key ~= nil and (not empty or not (self.map.h > lume.round(GAME_HEIGHT / TILE_SIZE))) then
        table.remove(self.buttons, key)
    end

    if empty and not lume.any(self.buttons, function(button) return button.x == 0 and button.y == (self.map.h - 1) * TILE_SIZE * self.scale end) and self.map.h > lume.round(GAME_HEIGHT / TILE_SIZE) then
        table.insert(self.buttons, {
            x = 0,
            y = (self.map.h - 1) * TILE_SIZE * self.scale,
            w = self.map.w * TILE_SIZE * self.scale,
            h = TILE_SIZE * self.scale,
            alpha = 0.3,
            color = 'sunset',
            textColor = 'whitesmoke',
            rectmode = 'fill',
            update = minus_update,
            render = minus_render,
            resize = function(button)
                button.x = 0
                button.y = (self.map.h - 1) * TILE_SIZE * self.scale
                button.w = self.map.w * TILE_SIZE * self.scale
                button.h = TILE_SIZE * self.scale
            end
        })
    end

    for _, button in pairs(self.buttons) do
        button:update()
        button:resize()
    end

    if gInput:pressed('mouse1') then
        local mouse_x, mouse_y = self.mouse.x / s, self.mouse.y / s
        for _, box in pairs(self.boxes) do
            if collides({x=mouse_x,y=mouse_y}, box) then
                box:onClick()
            end
        end
    elseif gInput:pressed('mouse2') then
        local mouse_x, mouse_y = self.mouse.x / s, self.mouse.y / s
        self.activeItem = nil
        for _, box in pairs(self.boxes) do
            if collides({x=mouse_x,y=mouse_y}, box) then
                box:onRightClick()
            end
        end
    end

    if gInput:pressed('cancel') then
        self.stack:pop()
        return
    end
    if gInput:down('mouse2') then
        self.followPoint.x = self.followPoint.x - self.mouse.dx * dt
        self.followPoint.y = self.followPoint.y - self.mouse.dy * dt
    end

    -- clamp based on scaling
    -- clamp from further away if less scaling
    --TODO: fix "deadzone" on zoomed out map
    self.followPoint.x = lume.clamp(self.followPoint.x, 19 * 5/self.scale, self.map.w - 19 * 5/self.scale)
    self.followPoint.y = lume.clamp(self.followPoint.y, 10 * 5/self.scale, self.map.h - 10 * 5/self.scale)

    self.camera:follow(lume.round(self.followPoint.x * TILE_SIZE * self.scale), lume.round(self.followPoint.y * TILE_SIZE * self.scale))
    self.camera:update()

    if gInput:pressed('mouse1') then
        local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
        self.selectedTile = nil
        if self.activeItem == nil then
            if self.inBounds() and not (self.popup.x and collides({x=mouse_x,y=mouse_y}, {x = self.x + self.popup.x, y = self.y + self.popup.y, w = self.popup.w, h = self.popup.h})) then
                self.popup:clear()
                local x = math.floor((mouse_x - self.x) / TILE_SIZE / self.scale) + 1
                local y = math.floor((mouse_y - self.y) / TILE_SIZE / self.scale) + 1
                local tile = self.tiles[y] and self.tiles[y][x]

                -- used for selecting a tile/object when multiple exist on the same spot
                local candidates = {}

                if tile and next(tile) then
                    tile.index = {x=x,y=y}
                    table.insert(candidates, tile)
                    -- self.selectedTile = tile
                    -- self.selectedTile.index = {x=x,y=y}
                end
                for i, object in pairs(self.objects) do
                    if collides({x=mouse_x,y=mouse_y}, {x = self.x + object.x * self.scale, y = self.y + object.y * self.scale, w = object.w * self.scale, h = object.h * self.scale}) then
                        object.index = i
                        table.insert(candidates, object)
                        -- self.selectedTile = object
                        -- self.selectedTile.index = i
                    end
                end
                if #candidates == 1 then
                    self.selectedTile = candidates[1]
                elseif #candidates > 0 then
                    self.popup = {
                        candidates = candidates,
                        w = #candidates * 40,
                        h = 80,
                        x = mouse_x - self.x - (#candidates * 40) / 2,
                        y = mouse_y - self.y - 90,
                        update = function(popup, dt)
                            if gInput:pressed('mouse1') then
                                local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
                                for i, candidate in pairs(popup.candidates) do
                                    local x = (popup.x + popup.w / 2 - candidate.w / 2) - (#candidates - 1) * 20 + (i - 1) * 40
                                    local y = popup.y + popup.h / 2 - candidate.h / 2
                                    if collides({x=mouse_x,y=mouse_y}, {x = self.x + x, y = self.y + y, w = candidate.w, h = candidate.h}) then
                                        self.selectedTile = candidate
                                        popup:clear()
                                        break
                                    end
                                end
                            end
                        end,
                        render = function(popup)
                            gColorManager:setColor('whitesmoke')
                            love.graphics.rectangle('fill',popup.x,popup.y,popup.w,popup.h, 2, 2)
                            gColorManager:setColor('silver')
                            love.graphics.rectangle('line',popup.x,popup.y,popup.w,popup.h, 2, 2)

                            gColorManager:setColor('whitesmoke')
                            love.graphics.polygon('fill', popup.x + popup.w / 2 - 20, popup.y + popup.h - 1, popup.x + popup.w / 2 + 20, popup.y + popup.h - 1, popup.x + popup.w / 2, popup.y + popup.h + 5)
                            gColorManager:setColor('silver')
                            love.graphics.polygon('line', popup.x + popup.w / 2 - 20, popup.y + popup.h - 1, popup.x + popup.w / 2 + 20, popup.y + popup.h - 1, popup.x + popup.w / 2, popup.y + popup.h + 5)
                            gColorManager:revert()

                            for i, candidate in pairs(popup.candidates) do
                                local x = (popup.x + popup.w / 2 - candidate.w / 2) - (#candidates - 1) * 20 + (i - 1) * 40
                                local y = popup.y + popup.h / 2 - candidate.h / 2
                                candidate:render(0, 0, {x=x-candidate.x, y=y-candidate.y})
                                gColorManager:setColor('silver')
                                love.graphics.rectangle('line', x, y,candidate.w,candidate.h, 2, 2)
                                gColorManager:revert()
                            end
                        end,
                        clear = self.popup.clear,
                        resize = self.popup.resize
                    }
                end
            end
        else -- self.activeItem ~= nil
            local item = self.activeItem
            if self.inBounds() then
                local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
                if item.tileset then
                    local x = math.floor((mouse_x - self.x) / self.scale / TILE_SIZE) * TILE_SIZE
                    local y = math.floor((mouse_y - self.y) / self.scale / TILE_SIZE) * TILE_SIZE
                    self.tiles[y/TILE_SIZE + 1][x/TILE_SIZE + 1] = Tile:new({
                        id = item.id,
                        tileset = item.tileset,
                        x = x,
                        y = y,
                        world = nil
                    })
                elseif item.tiles then
                    local x = math.floor((mouse_x - self.x) / self.scale / TILE_SIZE) * TILE_SIZE
                    local y = math.floor((mouse_y - self.y) / self.scale / TILE_SIZE) * TILE_SIZE
                    table.insert(self.objects, Object:new({
                        id = item.id,
                        x = x,
                        y = y
                    }))
                end
            end
        end
    end
    if gInput:pressed('delete') then
        if self.selectedTile then
            if self.selectedTile:isInstanceOf(Tile) then
                local x, y = self.selectedTile.index.x, self.selectedTile.index.y
                self.tiles[y][x] = {}
            elseif self.selectedTile:isInstanceOf(Object) then
                table.remove(self.objects, self.selectedTile.index)
            end
            self.selectedTile = nil
        end
    end

    self.popup:update(dt)
end

function MapEditState:renderGrid()
    gColorManager:setColor('whitesmoke', 0.5)
    for x = 1, self.map.w do
        for y = 1, self.map.h do
            love.graphics.rectangle('line', (x - 1) * TILE_SIZE * self.scale, (y - 1) * TILE_SIZE * self.scale, TILE_SIZE * self.scale, TILE_SIZE * self.scale)
        end
    end
    gColorManager:revert()
end

function MapEditState:render()
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.setScissor(self.x * s, self.y * s, self.w * s, self.h * s)
    self.camera:attach()
    for y = 1, self.map.h do
        for x = 1, self.map.w do
            local tile = self.tiles[y][x]
            if next(tile) ~= nil then
                deep.queue(tile.zindex, function()
                    love.graphics.push()
                    love.graphics.scale(self.scale)
                    if not (self.selectedTile and type(self.selectedTile.index) == 'table' and self.selectedTile.index.x == x and self.selectedTile.index.y == y) then
                        tile:render()
                    end

                    local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
                    if collides({x=mouse_x,y=mouse_y}, {x = self.x + tile.x * self.scale, y = self.y + tile.y * self.scale, w = tile.w * self.scale, h = tile.h * self.scale}) and self.inBounds() and not (self.selectedTile and type(self.selectedTile.index) == 'table' and self.selectedTile.index.x == x and self.selectedTile.index.y == y) then
                        gColorManager:setColor('whitesmoke', 0.5)
                        love.graphics.rectangle('fill', tile.x, tile.y, tile.w, tile.h)
                        gColorManager:revert()
                    end
                    love.graphics.pop()
                end)
            end
        end
    end
    
    for i, object in pairs(self.objects) do
        deep.queue(object.zindex, function()
            love.graphics.push()
            love.graphics.scale(self.scale)
            if not (self.selectedTile and self.selectedTile.index == i) then
                object:render()
            end

            local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
            if collides({x=mouse_x,y=mouse_y}, {x = self.x + object.x * self.scale, y = self.y + object.y * self.scale, w = object.w * self.scale, h = object.h * self.scale}) and self.inBounds() and not (self.selectedTile and self.selectedTile.index == i) then
                gColorManager:setColor('whitesmoke', 0.5)
                love.graphics.rectangle('fill', object.x, object.y, object.w, object.h)
                gColorManager:revert()
            end
            love.graphics.pop()
        end)
    end

    deep.execute()

    if self.selectedTile then
        love.graphics.push()
        love.graphics.scale(self.scale)
        self.selectedTile:render()
        gColorManager:setColor('whitesmoke', 0.5)
        love.graphics.rectangle('fill', self.selectedTile.x, self.selectedTile.y, self.selectedTile.w, self.selectedTile.h)
        gColorManager:revert()
        love.graphics.pop()
    end

    local item = self.activeItem
    if item and self.inBounds() then
        local mouse_x, mouse_y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
        love.graphics.push()
        love.graphics.scale(self.scale)
        if item.tileset then
            love.graphics.draw(gAssets.graphics[item.tileset.name], gFrames[item.tileset.name][item.id], 
                math.floor((mouse_x - self.x) / self.scale / TILE_SIZE) * TILE_SIZE, 
                math.floor((mouse_y - self.y) / self.scale / TILE_SIZE) * TILE_SIZE
            )
        elseif item.tiles then
            for _, tile in pairs(item.tiles) do
                love.graphics.draw(gAssets.graphics[tile.tileset], gFrames[tile.tileset][tile.id], 
                    math.floor((mouse_x - self.x) / self.scale / TILE_SIZE) * TILE_SIZE + tile.x, 
                    math.floor((mouse_y - self.y) / self.scale / TILE_SIZE) * TILE_SIZE + tile.y
                )
            end
        end
        love.graphics.pop()
    end

    self:renderGrid()

    for _, button in pairs(self.buttons) do
        button:render()
    end

    -- gColorManager:setColor({0, 0, 1, 1})
    -- love.graphics.rectangle('line', self.followPoint.x * TILE_SIZE * self.scale, self.followPoint.y * TILE_SIZE * self.scale, TILE_SIZE * self.scale, TILE_SIZE * self.scale)
    -- gColorManager:revert()

    self.popup:render()
    self.camera:detach()

    love.graphics.setScissor()
    love.graphics.pop()

    gColorManager:setColor({1, 0, 0, 1})
    love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    gColorManager:revert()

    for _, box in pairs(self.boxes) do
        box:render()
    end
end

function MapEditState:exit()
    self.wheelHandler:remove()
    self.map.tiles = (function()
        local tiles = {}
        for y = 1, self.map.h do
            table.insert(tiles, {})
            for x = 1, self.map.w do
                local tile = self.tiles[y][x]
                table.insert(tiles[y], next(tile) and (tile.id + tile.tileset.firstgid) or 0)
            end
        end
        return tiles
    end)()
    self.map.objects = (function()
        local objects = {}
        for _, object in pairs(self.objects) do
            table.insert(objects, {
                id = object.id,
                x = object.x,
                y = object.y
            })
        end
        return objects
    end)()
    local success, message = love.filesystem.write('chapters/'..self.chapter.name..'.bin', binser.serialize(self.chapter))
end