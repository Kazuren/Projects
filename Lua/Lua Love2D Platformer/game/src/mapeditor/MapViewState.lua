MapViewState = class('MapViewState', BaseState)

local function collides(point, box)
	local collided = point.x < box.x + box.w and
        box.x < point.x and
		point.y < box.y + box.h and
		box.y < point.y
	return collided
end


function MapViewState:initialize(stack)
    self.stack = stack
    self.x = 0
    self.y = 0
    self.w = UI_WIDTH
    self.h = UI_HEIGHT
    self.scale = 1
    self.font = gFonts['medium']

    --TODO: make chapter objects such as, change map position based on event
    self.chapters = {}
    self.displacement = {x=0,y=0}

    for i, name in pairs(love.filesystem.getDirectoryItems('chapters')) do
        local contents, size = love.filesystem.read('chapters/'.. name)
        local chapter, len = binser.deserializeN(contents)
        table.insert(self.chapters, chapter)
    end  

    self.chapterSelection = 1
    self.mapSelection = nil
    self.collidedPoint = nil
    if #self.chapters[self.chapterSelection].maps > 0 then
        self.followPoint = {
            x=self.chapters[self.chapterSelection].maps[1].x + self.chapters[self.chapterSelection].maps[1].w * TILE_SIZE / 2,
            y=self.chapters[self.chapterSelection].maps[1].y + self.chapters[self.chapterSelection].maps[1].h * TILE_SIZE / 2
        }
    else
        self.followPoint = {x=0,y=0}
    end
    self.camera = Camera(UI_WIDTH/2, UI_HEIGHT/2, UI_WIDTH, UI_HEIGHT)
    self.camera:follow(self.followPoint.x * self.scale, self.followPoint.y * self.scale)
    self.camera:update()

    self.mouse = Mouse('crosshair')

    -- TODO: fix mouse position when dragging map and zooming in/out
    self.wheelHandler = Event.on('wheelmoved', function(x, y)
        self.scale = lume.clamp(self.scale + y * 0.05, 0.3, 2)
    end)
end

function MapViewState:update(dt)
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    self.mouse:update(dt)

    if gInput:pressed('cancel') then
        self.stack:pop()
        return
    end

    if gInput:pressed('mouse1') then
        self.mapSelection = nil
        self.collidedPoint = nil
        for i, map in pairs(self.chapters[self.chapterSelection].maps) do
            local x, y = self.camera:toWorldCoords(self.mouse.x / s, self.mouse.y / s)
            if collides({x=x,y=y}, {x = map.x * self.scale, y = map.y * self.scale, w = map.w * TILE_SIZE * self.scale, h = map.h * TILE_SIZE * self.scale}) then
                self.mapSelection = i
                self.collidedPoint = {x = x - map.x * self.scale, y = y - map.y * self.scale}
            end
        end
    end

    if gInput:down('mouse1') then
        if self.mapSelection then
            local map = self.chapters[self.chapterSelection].maps[self.mapSelection]
            map.x, map.y = self.camera:toWorldCoords(self.mouse.x / s - self.collidedPoint.x, self.mouse.y / s - self.collidedPoint.y)
            map.x, map.y = lume.round(map.x / TILE_SIZE / self.scale) * TILE_SIZE, lume.round(map.y / TILE_SIZE / self.scale) * TILE_SIZE
        end
    elseif gInput:down('mouse2') then
        self.followPoint.x = self.followPoint.x - self.mouse.dx
        self.followPoint.y = self.followPoint.y - self.mouse.dy
    end

    if gInput:released('mouse1') then
        if self.mapSelection then
            local chapter = self.chapters[self.chapterSelection]
            local success, message = love.filesystem.write('chapters/'..chapter.name..'.bin', binser.serialize(chapter))
        end
    end

    if gInput:pressed('make') then
        local map = {
            x = 0,
            y = 0,
            w = 40,
            h = 23,
            objects = {
                {
                    id = 2,
                    x = 16,
                    y = 16
                },
                {
                    id = 2,
                    x = 16,
                    y = 24
                },
                {
                    id = 2,
                    x = 16,
                    y = 32
                }
            },
            tiles = {
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
            }
        }
        table.insert(self.chapters[self.chapterSelection].maps, map)
    elseif gInput:pressed('delete') then
        local chapter = self.chapters[self.chapterSelection]
        if self.mapSelection then
            table.remove(chapter.maps, self.mapSelection)
            self.mapSelection = nil
        end
        local success, message = love.filesystem.write('chapters/'..chapter.name..'.bin', binser.serialize(chapter))
    elseif gInput:pressed('confirm') then
        local chapter = self.chapters[self.chapterSelection]
        if self.mapSelection then
            local map = chapter.maps[self.mapSelection]
            self.stack:push(MapEditState(self.stack, chapter, map))
        end
    end

    self.camera:follow(self.followPoint.x * self.scale, self.followPoint.y * self.scale)
    self.camera:update()
end

function MapViewState:render()
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    love.graphics.push()
    love.graphics.setScissor(self.x * s, self.y * s, self.w * s, self.h * s)
    gColorManager:setColor('whitesmoke')
    local offset = 0
    for i, chapter in pairs(self.chapters) do
        local textWidth = self.font:getWidth(chapter.name)
        love.graphics.rectangle('line', self.x + offset, self.y, textWidth + 128, self.font:getHeight() * 4)
        if i == self.chapterSelection then
            gColorManager:setColor('mayablue')
        end
        love.graphics.printf(chapter.name, self.font, self.x + offset, self.y + self.font:getHeight() * 1.5, textWidth + 128, 'center')
        gColorManager:revert()
        offset = offset + textWidth + 128
    end
    love.graphics.line(self.x, self.y + self.font:getHeight() * 4, self.x + self.w, self.y + self.font:getHeight() * 4)
    love.graphics.setScissor()
    love.graphics.setScissor(self.x * s, self.y * s + self.font:getHeight() * 4 + 1, self.w * s, self.h * s - self.font:getHeight() * 4 - 1)
    self.camera:attach()
    --TODO: draw map background
    for i, map in pairs(self.chapters[self.chapterSelection].maps) do
        love.graphics.push()
        love.graphics.scale(self.scale)
        for y = 1, map.h do
            for x = 1, map.w do
                local id = map.tiles[y][x]
                local tileset = (function()
                    for _, tileset in pairs(TILESETS) do
                        if id <= tileset.firstgid + tileset.tilecount then
                            id = id - tileset.firstgid
                            return tileset
                        end
                    end
                end)()
                if id ~= 0 then
                    deep.queue(tileset.tiles[id].zindex or 1000, function()
                        love.graphics.draw(gAssets.graphics[tileset.name], gFrames[tileset.name][id], map.x + (x - 1) * TILE_SIZE, map.y + (y - 1) * TILE_SIZE)
                    end)
                end
            end
        end

        for _, object in pairs(map.objects) do
            for _, tile in pairs(OBJECTS[object.id].tiles) do
                local tileset = TILESETS[tile.tileset]
                if tile.id ~= 0 then
                    deep.queue(OBJECTS[object.id].zindex or 1000, function()
                        love.graphics.draw(gAssets.graphics[tileset.name], gFrames[tileset.name][tile.id], map.x + object.x + tile.x, map.y + object.y + tile.y)
                    end)
                end
            end
        end

        deep.execute()

        love.graphics.pop()

        love.graphics.push()
        love.graphics.scale(self.scale)
        local lw = love.graphics.getLineWidth()
        local ls = love.graphics.getLineStyle()
        --TODO: overlapping maps render a rectangle on the overlapping part
        love.graphics.setLineWidth(3)
        love.graphics.setLineStyle('rough')
        gColorManager:setColor('resolutionblue', 0.3)
        if i == self.mapSelection then gColorManager:setColor('freespeechblue', 0.8) end
        love.graphics.printf(i, self.font, map.x, map.y + map.h * TILE_SIZE / 2 - self.font:getHeight() / 2, map.w * TILE_SIZE, 'center')
        gColorManager:revert()
        love.graphics.pop()

        gColorManager:setColor('resolutionblue', 0.3)
        if i == self.mapSelection then gColorManager:setColor('freespeechblue', 0.8) end
        love.graphics.rectangle('line', map.x * self.scale, map.y * self.scale, map.w * TILE_SIZE * self.scale, map.h * TILE_SIZE * self.scale)
        gColorManager:revert()
        love.graphics.setLineStyle(ls)
        love.graphics.setLineWidth(lw)
    end
    self.camera:detach()
    gColorManager:revert()
    love.graphics.setScissor()
    love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    love.graphics.pop()
end


function MapViewState:exit()
    self.wheelHandler:remove()
    self.mouse:destroy()
end