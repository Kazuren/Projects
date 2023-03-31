-- Collision objects
local block = {
    id = 1,
    name = "Block",
    type = "block",
    x = 0,
    y = 0,
    w = 8,
    h = 8,
    properties = {
        collidable = true
    }
}
-- TILES cant update themselves except animation/color/graphics while OBJECTS can
TILESETS = {
    {
        name = "sprites",
        firstgid = 0,
        filename = "../../graphics/sprites.png",
        tilewidth = 8,
        tileheight = 8,
        imagewidth = 128,
        imageheight = 32,
        properties = {},
        tilecount = 64,
        groups = {},
        tiles = {
            [58] = {
                mapEditor = {
                    visible = true
                },
                properties = {},
                objects = {
                    block
                }
            }
        }
    },
    {
        name = "summer",
        firstgid = 64,
        filename = "../../graphics/summer.png",
        tilewidth = 8,
        tileheight = 8,
        imagewidth = 272,
        imageheight = 96,
        properties = {},
        tilecount = 408,
        groups = {
            {name = 'ground', 33}
        },
        tiles = {
            [21] = {},
            [22] = {},
            [55] = {},
            [56] = {},
            [89] = {},
            [90] = {},
            [123] = {},
            [124] = {},
            [157] = {},
            [158] = {},
            [191] = {},
            [192] = {},
            [33] = {
                mapEditor = {
                    visible = true,
                    group = 'ground'
                },
                properties = {},
                objects = {
                    block
                }
            }
        }
    }
}
TILESETS['sprites'] = TILESETS[1]
TILESETS['summer'] = TILESETS[2]