-- TILES cant update themselves except animation/color/graphics while OBJECTS can
-- TODO: objects can have their own mapEditor update/render function to define what they do in the map editor
-- TODO: ^ this allows us to make custom size platforms etc
-- TODO: ^ probably scrap this because we want to save id,x,y only on server side and just make multiple different objects
-- TODO: BUT the update function on each object can change to other objects (for example a small platform can change to a medium platform and a medium one to a big one)
-- TODO: objects can have onPlace onRemove effects for the mapEditor(example: collectible object add/remove from chapter data)

-- TODO: objects can have custom image for the map editor?

OBJECTS = {
    [1] = {
        name = 'Platform',
        type = 'platform',
        w = 8,
        h = 8,
        update = function(self, dt)

        end,
        render = function(self)

        end,
        mapEditor = {
            visible = true
        },
        properties = {
            platform = true
        },
        tiles = {
            {
                id = 33,
                tileset = 'summer',
                x = 0,
                y = 0
            }
        }
    },
    [2] = {
        name = 'Tree',
        type = 'tree',
        w = 16,
        h = 48,
        zindex = 990,
        update = function(self, dt)

        end,
        render = function(self, x, y, coords)
            local x, y = x or 0, y or 0
            for _, tile in pairs(self.tiles) do
                if tile.id ~= 0 then
                    if coords then
                        love.graphics.draw(gAssets.graphics[tile.tileset.name], gFrames[tile.tileset.name][tile.id], coords.x+tile.x, coords.y+tile.y)
                    else
                        love.graphics.draw(gAssets.graphics[tile.tileset.name], gFrames[tile.tileset.name][tile.id], tile.x+x, tile.y+y)
                    end
                end
            end
        end,
        mapEditor = {
            visible = true
        },
        properties = {
            platform = true
        },
        tiles = {
            {
                id = 21,
                tileset = 'summer',
                x = 0,
                y = 0
            },
            {
                id = 22,
                tileset = 'summer',
                x = 8,
                y = 0
            },
            {
                id = 55,
                tileset = 'summer',
                x = 0,
                y = 8
            },
            {
                id = 56,
                tileset = 'summer',
                x = 8,
                y = 8
            },
            {
                id = 89,
                tileset = 'summer',
                x = 0,
                y = 16
            },
            {
                id = 90,
                tileset = 'summer',
                x = 8,
                y = 16
            },
            {
                id = 123,
                tileset = 'summer',
                x = 0,
                y = 24
            },
            {
                id = 124,
                tileset = 'summer',
                x = 8,
                y = 24
            },
            {
                id = 157,
                tileset = 'summer',
                x = 0,
                y = 32
            },
            {
                id = 158,
                tileset = 'summer',
                x = 8,
                y = 32
            },
            {
                id = 191,
                tileset = 'summer',
                x = 0,
                y = 40
            },
            {
                id = 192,
                tileset = 'summer',
                x = 8,
                y = 40
            }
        }
    }
}