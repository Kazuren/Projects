Tile = class('Tile')

function Tile:initialize(def)
    self.tileset = def.tileset
    self.id = def.id
    self.x = def.x
    self.y = def.y
    self.world = def.world
    self.zindex = self.tileset.tiles[self.id].zindex or 1000
    self.w = self.tileset.tilewidth
    self.h = self.tileset.tileheight
    self.mapEditor = self.tileset.tiles[self.id].mapEditor or {}
    self.properties = self.tileset.tiles[self.id].properties or {}
    self.objects = table.deepcopy(self.tileset.tiles[self.id].objects or {})
end

function Tile:create()
    if self.world then
        self.world:add(
            self,
            self.x,
            self.y,
            self.w,
            self.h
        )
        for _, object in pairs(self.objects) do
            self.world:add(
                object,
                self.x+object.x,
                self.y+object.y,
                object.w,
                object.h
            )
        end
    end
end

function Tile:destroy()
    if self.world then
        self.world:remove(self)
        for _, object in pairs(self.objects) do
            self.world:remove(object)
        end
    end
end

function Tile:update() -- update animation? :thinking:
end

function Tile:render(x, y, coords)
    local x, y = x or 0, y or 0
    if self.id ~= 0 then
        if coords then
            love.graphics.draw(gAssets.graphics[self.tileset.name], gFrames[self.tileset.name][self.id], coords.x, coords.y)
        else
            love.graphics.draw(gAssets.graphics[self.tileset.name], gFrames[self.tileset.name][self.id], self.x+x, self.y+y)
        end
    end
end