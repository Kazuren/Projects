Chapter = class('Chapter')


function Chapter:initialize(name, world)
    local contents, size, len
    contents, size = love.filesystem.read('chapters/'.. name .. '.bin')
    self.data, len = binser.deserializeN(contents)
    self.world = world
    self.currentMap = 1
    self.previousMap = nil
    self.maps = {}
    local connections = {}
    for i, map in pairs(self.data.maps) do
        connections[i] = {}
        for j, otherMap in pairs(self.data.maps) do
            if map.x + map.w * TILE_SIZE == otherMap.x or map.x == otherMap.x + otherMap.w * TILE_SIZE then
                if (map.y < otherMap.y + otherMap.h * TILE_SIZE and map.y + map.h * TILE_SIZE > otherMap.y) then
                    table.insert(connections[i], j)
                end
            elseif map.y + map.h * TILE_SIZE == otherMap.y or map.y == otherMap.y + otherMap.h * TILE_SIZE then
                if (map.x < otherMap.x + otherMap.w * TILE_SIZE and map.x + map.w * TILE_SIZE > otherMap.x) then
                    table.insert(connections[i], j)
                end
            end
        end
        table.insert(self.maps, Map:new(map, self.world, connections[i], i))
    end
    self.maps[self.currentMap]:create()
end

function Chapter:update(dt)
    self.maps[self.currentMap]:update(dt)
end

function Chapter:render()
    -- render all adjacent maps to current map
    local map = self.maps[self.currentMap]
    for _, connection in pairs(map.connections) do
        self.maps[connection]:render()
    end
    self.maps[self.currentMap]:render()
end