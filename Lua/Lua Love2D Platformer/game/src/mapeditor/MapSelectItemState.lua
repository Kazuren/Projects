MapSelectItemState = class('MapSelectItemState', BaseState)

local function collides(point, box)
	return point.x < box.x + box.w and
        box.x < point.x and
		point.y < box.y + box.h and
		box.y < point.y
end

function MapSelectItemState:initialize(stack, box)
    self.stack = stack
    self.box = box
    self.scale = 3
    self.mouse = Mouse('arrow')

    self.tiles = (function()
        local tiles = {}
        local offset_x, offset_y = 0, 0

        for i, id in pairs(self.box.properties.tiles) do
            local tileset = (function()
                for _, tileset in pairs(TILESETS) do
                    if id <= tileset.firstgid + tileset.tilecount then
                        id = id - tileset.firstgid
                        return tileset
                    end
                end
            end)()

            table.insert(tiles, {
                x = 64 + offset_x,
                y = 64 + offset_y,
                w = tileset.tilewidth,
                h = tileset.tileheight,
                tileset = tileset,
                id = id
            })
            offset_x = offset_x + tileset.tilewidth
            if offset_x > UI_WIDTH - 64 then offset_x = 0 offset_y = offset_y + tileset.tileheight end
        end
        return tiles
    end)()

    self.objects = (function()
        local objects = {}
        local offset_x, offset_y = 0, 0

        for i, id in pairs(self.box.properties.objects) do
            table.insert(objects, {
                x = 64 + offset_x,
                y = 128 + offset_y,
                w = OBJECTS[id].w,
                h = OBJECTS[id].h,
                tiles = OBJECTS[id].tiles,
                id = id
            })
            -- TODO: make this a bit smarter and put the items wherever they fit
            offset_x = offset_x + OBJECTS[id].w
            if offset_x > UI_WIDTH - 64 then offset_x = 0 offset_y = offset_y + OBJECTS[id].h end
        end
        return objects
    end)()
end

function MapSelectItemState:update(dt)
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)

    self.mouse:update(dt)

    if gInput:pressed('mouse1') then
        for _, tile in pairs(self.tiles) do
            if collides({x=self.mouse.x/s,y=self.mouse.y/s}, {x=tile.x*self.scale,y=tile.y*self.scale,w=tile.w*self.scale,h=tile.h*self.scale}) then
                self.box.properties.currentItem = tile
                self.stack:pop()
                return
            end
        end

        for _, object in pairs(self.objects) do
            if collides({x=self.mouse.x/s,y=self.mouse.y/s}, {x=object.x*self.scale,y=object.y*self.scale,w=object.w*self.scale,h=object.h*self.scale}) then
                self.box.properties.currentItem = object
                self.stack:pop()
                return
            end
        end
    end
end

function MapSelectItemState:render()
    local offset_x, offset_y = 0, 0
    love.graphics.push()
    love.graphics.scale(self.scale)
    for _, tile in pairs(self.tiles) do
        love.graphics.draw(gAssets.graphics[tile.tileset.name], gFrames[tile.tileset.name][tile.id], tile.x, tile.y)
    end

    for _, object in pairs(self.objects) do
        for _, tile in pairs(object.tiles) do
            love.graphics.draw(gAssets.graphics[tile.tileset], gFrames[tile.tileset][tile.id], object.x+tile.x, object.y+tile.y)
        end
    end

    love.graphics.pop()
end
