Map = class('Map')

function Map:initialize(data, world, connections, index)
    self.world = world
    self.connections = connections
    self.index = index
    self.x = data.x
    self.y = data.y
    self.w = data.w
    self.h = data.h
    self.tiles = {}
    self.objects = {}

    for _, object in pairs(data.objects) do
        table.insert(self.objects, Object:new({
            id = object.id,
            x = object.x + self.x,
            y = object.y + self.y,
            world = self.world
        }))
    end
    for y = 1, self.h do
        self.tiles[y] = {}
        for x = 1, self.w do
            local id = data.tiles[y][x]
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
                    x = (x - 1) * TILE_SIZE + self.x,
                    y = (y - 1) * TILE_SIZE + self.y,
                    world = self.world
                })
            else
                self.tiles[y][x] = nil
            end
        end
    end
end

function Map:create()
    for y = 1, self.h do
        for x = 1, self.w do
            local tile = self.tiles[y][x]
            if tile ~= nil then
                tile:create()
            end
        end
    end

    for _, object in pairs(self.objects) do
        object:create()
    end
end

function Map:destroy()
    for y = 1, self.h do
        for x = 1, self.w do
            local tile = self.tiles[y][x]
            if tile ~= nil then
                tile:destroy()
            end
        end
    end

    for i, object in pairs(self.objects) do
        object:destroy()
    end
end

function Map:tileAt(x, y)
    x, y = math.floor(x/TILE_SIZE) + 1, math.floor(y/TILE_SIZE) + 1
    if x < 1 or x > #self.tiles then return nil end
    if y < 1 or y > #self.tiles[x] then return nil end
    return self.tiles[x][y]
end

function Map:update(dt)
    for y = 1, self.h do
        for x = 1, self.w do
            local tile = self.tiles[y][x]
            if tile ~= nil then
                tile:update(dt)
            end
        end
    end
    for _, object in pairs(self.objects) do
        object:update(dt)
    end
end

function Map:render()
    for y = 1, self.h do
        for x = 1, self.w do
            local tile = self.tiles[y][x]
            if tile ~= nil then
                deep.queue(tile.zindex, function()
                    tile:render()
                end)
            end
        end
    end
    for _, object in pairs(self.objects) do
        deep.queue(object.zindex, function()
            object:render()
        end)
    end
end