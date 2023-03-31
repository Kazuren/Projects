Object = class('Object')

function Object:initialize(def)
    self.id = def.id
    self.x = def.x -- x is always aligned to the grid on placement
    self.y = def.y -- y is always aligned to the grid on placement
    self.w = OBJECTS[self.id].w
    self.h = OBJECTS[self.id].h
    self.zindex = OBJECTS[self.id].zindex or 1000
    self.hitbox = def.hitbox or {x=0,y=0,w=self.w,h=self.h}
    self.world = def.world
    
    self.mapEditor = OBJECTS[self.id].mapEditor or {}
    self.properties = OBJECTS[self.id].properties or {}
    self.update = OBJECTS[self.id].update
    self.render = OBJECTS[self.id].render
    self.tiles = {}

    for _, tile in pairs(OBJECTS[self.id].tiles) do
        table.insert(self.tiles, Tile:new({
            id = tile.id,
            tileset = TILESETS[tile.tileset],
            x = tile.x + self.x,
            y = tile.y + self.y,
            world = self.world
        }))
    end
end

function Object:create()
    if self.world then
        for _, tile in pairs(self.tiles) do
            tile:create()
        end
        self.world:add(
            self,
            self.x+self.hitbox.x,
            self.y+self.hitbox.y,
            self.hitbox.w,
            self.hitbox.h
        )
    end
    
end

function Object:destroy()
    if self.world then
        self.world:remove(self)
        for _, tile in pairs(self.tiles) do
            tile:destroy()
        end
    end
end