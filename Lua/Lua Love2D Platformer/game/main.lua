require 'src/Dependencies'

function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Game')
    love.filesystem.setIdentity('platformer')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(1)
    love.mouse.setVisible(false)

    -- Files
    if not love.filesystem.getInfo('settings.lua') then
        gSettings = {
            window = {
                fullscreen=true,
                vsync=1,
                display=1
            },
            game = {
                rumble=true,
                photosensitive_mode=false,
                screen_shake_effects=true,
                music=5,sound=5,
                speedrun_clock=false
            }
        }
        -- TODO: use bin files instead
        love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))

        love.window.setMode(0, 0, {
            fullscreen = true,
            vsync = 1,
            display = 1,
            resizable = true
        })
    else
        local ok, chunk, result
        ok, chunk = pcall(love.filesystem.load, 'settings.lua')
        if ok then
            ok, result = pcall(chunk)
            if ok then
                gSettings = result
            end
        end

        love.window.setMode(0, 0, {
            fullscreen=gSettings.window.fullscreen,
            vsync=gSettings.window.vsync,
            display=gSettings.window.display,
            resizable=true
        })
    end

    if not love.filesystem.getInfo('chapters') then
        local success = love.filesystem.createDirectory('chapters')
        local file = love.filesystem.newFile('chapters/ChapterOne.bin')
        -- TODO: when done have these completed maps in a directory that's not the save game dir and get the single player chapters from there in lua format
        local chapter = {
            name = 'ChapterOne',
            maps = {
                {
                    x = 0,
                    y = 0,
                    w = 40,
                    h = 23,
                    objects = {
                        {
                            id = 1,
                            x = 0,
                            y = 0
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
            }
        }
        file:open("w")
        file:write(binser.serialize(chapter))
        file:close()
    end

    --Resolution
    push:setupScreen(GAME_WIDTH, GAME_HEIGHT, love.graphics.getDimensions())

    -- Assets
    local function makeSound(path)
        local info = love.filesystem.getInfo(path, 'file')
        return audio:newSource(path, (info and info.size and info.size < 5e5) and 'static' or 'stream')
    end

    gAssets = cargo.init({
        dir = 'assets',
        loaders = {
            wav = makeSound,
            ogg = makeSound,
            mp3 =  makeSound
        },
        processors = {
            ['graphics/'] = function(image, filename)
                image:setFilter('nearest', 'nearest')
            end,
            ['sfx/'] = function(source, filename)
                source:setVolume(gSettings.game.sound/10)
            end,
            ['music/'] = function(source, filename)
                source:setVolume(gSettings.game.music/10)
            end
        }
    })
    -- preload sound effects
    gAssets.sfx()

    -- Fonts are a bit different since I have to define a size
    gFonts = {
        ['tiny'] = gAssets.fonts.font(8),
        ['small'] = gAssets.fonts.font(16),
        ['medium'] = gAssets.fonts.font(24),
        ['large'] = gAssets.fonts.font(32)
    }
    for _, font in pairs(gFonts) do font:setFilter('nearest', 'nearest') end

    -- Generate sprites from spritesheets
    -- TODO: possibly combine these
    gFrames = {
        ['player'] = GenerateQuads(gAssets.graphics.player, 24, 24),
        ['sprites'] = GenerateQuads(gAssets.graphics.sprites, 8, 8),
        ['summer'] = GenerateQuads(gAssets.graphics.summer, 8, 8),
    }
    gAnimationGrids = {
        ['player'] = anim8.newGrid(24, 24, gAssets.graphics.player:getWidth(), gAssets.graphics.player:getHeight()),
    }
    -- Setup Time
    gStartTime = love.timer.getTime()
    gTime = love.timer.getTime() - gStartTime

    -- Setup fixed timestep model.
    tick.rate = 1/60
    tick.timescale = 1
    tick.framerate = 60

    -- Setup Input
    -- TODO: Make input work with axis Example: allow binding of leftx+ leftx- lefty+ lefty-,
    -- TODO: allow setting a deadzone(circular too maybe) and if leftx+ >= deadzone return true etc
    gInput = Input()
    gInput:bind('f1', 'debug')
    gInput:bind('delete', 'delete')
    gInput:bind('m', 'make')

    gInput:bind('mouse1', 'mouse1')
    gInput:bind('mouse2', 'mouse2')
    gInput:bind('mouse3', 'mouse3')
    gInput:bind('wheelup', 'wheelup')
    gInput:bind('wheeldown', 'wheeldown')

    gInput:bind('up', 'up')
    gInput:bind('dpup', 'up')

    gInput:bind('down', 'down')
    gInput:bind('dpdown', 'down')

    -- gInput:bind('lefty-', 'up')
    -- gInput:bind('lefty+', 'down')

    gInput:bind('left', 'left')
    gInput:bind('dpleft', 'left')

    gInput:bind('right', 'right')
    gInput:bind('dpright', 'right')

    -- gInput:bind('leftx-', 'left')
    -- gInput:bind('leftx+', 'right')

    gInput:bind('z', 'jump')
    gInput:bind('x', 'blink')
    gInput:bind('c', 'grab')
    gInput:bind('v', 'recall')
    gInput:bind('b', 'talk')

    gInput:bind('return', 'confirm')
    gInput:bind('fdown', 'confirm')
    gInput:bind('escape', 'cancel')
    gInput:bind('backspace', 'cancel')
    gInput:bind('fright', 'cancel')
    gInput:bind('escape', 'pause')
    gInput:bind('start', 'pause')

    -- Color Manager
    gColorManager = ColorManager:new()
    gColorManager:add('red', {1, 0, 0})
    gColorManager:add('black', {17/255, 17/255, 17/255})
    gColorManager:add('nero', {34/255, 34/255, 34/255})
    gColorManager:add('nightrider', {51/255, 51/255, 51/255})
    gColorManager:add('grey', {119/255, 119/255, 119/255})
    gColorManager:add('silver', {187/255, 187/255, 187/255})
    gColorManager:add('whitesmoke', {238/255, 238/255, 238/255})

    gColorManager:add('silvertree', {111/255, 194/255, 138/255})
    gColorManager:add('snowymint', {193/255, 237/255, 202/255})

    gColorManager:add('sunset', {197/255, 76/255, 76/255})

    gColorManager:add('palerose', {243/255, 224/255, 224/255})
    gColorManager:add('pinkflare', {219/255, 185/255, 184/255})
    gColorManager:add('cuttysark', {89/255, 123/255, 103/255})
    gColorManager:add('verylightgrey', {207/255, 201/255, 206/255})
    gColorManager:add('gainsboro', {221/255, 218/255, 218/255})
    gColorManager:add('whisper', {241/255, 235/255, 234/255})

    gColorManager:add('prelude', {188/255, 160/255, 201/255})
    gColorManager:add('eastbay', {77/255, 80/255, 117/255})
    gColorManager:add('shocking', {229/255, 153/255, 171/255})
    gColorManager:add('sundown', {247/255, 184/255, 180/255})
    gColorManager:add('yourpink', {255/255, 208/255, 191/255})
    gColorManager:add('mimosa', {245/255, 239/255, 200/255})

    gColorManager:add('bananamania', {252/255, 232/255, 174/255})
    gColorManager:add('resolutionblue', {43/255, 64/255, 113/255})
    gColorManager:add('freespeechblue', {63/255, 106/255, 191/255})
    gColorManager:add('mayablue', {117/255, 195/255, 248/255})
    gColorManager:add('columbiablue', {180/255, 231/255, 253/255})
    gColorManager:add('lightcyan', {218/255, 245/255, 253/255})

    -- Debug Manager
    gDebugManager = DebugManager:new(gColorManager:getColor('whitesmoke'), gColorManager:getColor('mayablue'), gFonts['tiny'])

    gDebugManager:add('FPS: ', function()
        return love.timer.getFPS()
    end)

    gDebugManager:add('Memory (KB): ', function()
        return math.floor(collectgarbage('count') * 10) / 10
    end)

    gDebugManager:add('Time (S): ', function()
        return lume.round(gTime, 0.001)
    end)

    -- State Stack
    gStateStack = StateManager:new()
    gStateStack:push(SplashState:new())

    -- Menu Manager
    gMenuManager = MenuManager:new()

    -- Main Menu 
    -- TODO: make only the tables here and when MenuManager:getMenu() gets called return a table with multiple --> Menu:new()
    -- TODO: make items not dependent on menus
    -- TODO: add the ability to add individual items instead of copy + pasting them, example: options item in both main menu + pause menu
    -- TODO: add pause menu and cutscene menu and map edit menu
    local mainMenu = {main = nil, options = nil, keyboardconfig = nil, controllerconfig = nil}
    mainMenu.stack = StateManager:new({renderAll = false})

    mainMenu['main'] = Menu:new({
        x = UI_WIDTH / 4,
        y = 64,
        w = UI_WIDTH / 2,
        h = UI_HEIGHT - 128,
        font = gFonts['medium'],
        color = gColorManager:getColor('whitesmoke'),
        activeColor = gColorManager:getColor('bananamania'),
        items = {
            {
                properties = {
                    text = 'Play'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        gStateStack:clear()
                        gStateStack:push(PlayState:new())
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            },
            {
                properties = {
                    text = 'Map Editor'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        gStateStack:push(MapEditorState:new())
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            },
            {
                properties = {
                    text = 'Options'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        mainMenu.stack:push(mainMenu['options'])
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            },
            {
                properties = {
                    text = 'Exit'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        gStateStack:clear()
                        love.event.quit()
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            }
        }
    })
    mainMenu['options'] = Menu:new({
        x = UI_WIDTH/4,
        y = 64,
        w = UI_WIDTH/2,
        h = UI_HEIGHT - 128,
        font = gFonts['medium'],
        color = gColorManager:getColor('whitesmoke'),
        titleColor = gColorManager:getColor('mayablue'),
        activeColor = gColorManager:getColor('bananamania'),
        labelColor = gColorManager:getColor('mayablue'),
        title = 'Options',
        labels = {
            {name = 'Controls', index=1},
            {name = 'Video', index=4},
            {name = 'Audio', index=9},
            {name = 'Gameplay', index=11}
        },
        items = {
            {
                properties = {
                    text = 'Rumble',
                    values = {'Off', 'On'},
                    value = gSettings.game.rumble and 2 or 1
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = math.max(1, item.properties.value - 1)
                            gSettings.game.rumble = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.rumble = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Keyboard Config'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        mainMenu.stack:push(mainMenu['keyboardconfig'])
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            },
            {
                properties = {
                    text = 'Controller Config'
                },
                update = function(item)
                    if gInput:pressed('confirm') then
                        mainMenu.stack:push(mainMenu['controllerconfig'])
                    end
                end,
                render = function(item)
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w)
                end
            },
            {
                properties = {
                    text = 'Fullscreen',
                    values = {'Off', 'On'},
                    value = gSettings.window.fullscreen and 2 or 1
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.window.fullscreen = item.properties.value == 2
                            love.window.setFullscreen(gSettings.window.fullscreen)
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.window.fullscreen = item.properties.value == 2
                            love.window.setFullscreen(gSettings.window.fullscreen)
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Vertical Sync',
                    values = {'Off', 'On'},
                    value = gSettings.window.vsync + 1
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = math.max(1, item.properties.value - 1)
                            gSettings.window.vsync = item.properties.value - 1
                            love.window.setVSync(gSettings.window.vsync)
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.window.vsync = item.properties.value - 1
                            love.window.setVSync(gSettings.window.vsync)
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Display',
                    values = (function()
                        local t = {}
                        for i = 1, love.window.getDisplayCount() do
                            table.insert(t, i)
                        end
                        return t
                    end)(),
                    value = gSettings.window.display
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.window.display = item.properties.values[item.properties.value]
                            love.window.setMode(0, 0, {
                                fullscreen = gSettings.window.fullscreen,
                                vsync = gSettings.window.vsync,
                                display = gSettings.window.display,
                                resizable = true
                            })
                            push:resize(love.graphics.getDimensions())
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.window.display = item.properties.values[item.properties.value]
                            love.window.setMode(0, 0, {
                                fullscreen = gSettings.window.fullscreen,
                                vsync = gSettings.window.vsync,
                                display = gSettings.window.display,
                                resizable = true
                            })
                            push:resize(love.graphics.getDimensions())
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth('Off')
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Photosensitive Mode',
                    values = {'Off', 'On'},
                    value = gSettings.game.photosensitive_mode and 2 or 1
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.game.photosensitive_mode = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.photosensitive_mode = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Screen Shake Effects',
                    values = {'Off', 'On'},
                    value = gSettings.game.screen_shake_effects and 2 or 1
                },
                update = function(item)
                    if gInput:pressed('left') then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.game.screen_shake_effects = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:pressed('right') then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.screen_shake_effects = item.properties.value == 2
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Music',
                    values = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
                    value = gSettings.game.music + 1
                },
                update = function(item)
                    if gInput:down('left', 0.15, 0.35) then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.game.music = item.properties.values[item.properties.value]
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                        for path, source in pairs(gAssets.music) do
                            if path ~= '_path' then
                                gAssets.music[path]:setVolume(gSettings.game.music/10)
                            end
                        end
                        gAssets.sfx.select_2:stop()
                        gAssets.sfx.select_2:play()
                    elseif gInput:down('right', 0.15, 0.35) then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.music = item.properties.values[item.properties.value]
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                        for path, source in pairs(gAssets.music) do
                            if path ~= '_path' then
                                gAssets.music[path]:setVolume(gSettings.game.music/10)
                            end
                        end
                        gAssets.sfx.select_2:stop()
                        gAssets.sfx.select_2:play()
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Sound',
                    values = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
                    value = gSettings.game.sound + 1
                },
                update = function(item)
                    if gInput:down('left', 0.15, 0.35) then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.game.sound = item.properties.values[item.properties.value]
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                            for path, source in pairs(gAssets.sfx) do
                                if path ~= '_path' then
                                    gAssets.sfx[path]:setVolume(gSettings.game.sound/10)
                                end
                            end
                            gAssets.sfx.select_2:stop()
                            gAssets.sfx.select_2:play()
                        end
                    elseif gInput:down('right', 0.15, 0.35) then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.sound = item.properties.values[item.properties.value]
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                            for path, source in pairs(gAssets.sfx) do
                                if path ~= '_path' then
                                    gAssets.sfx[path]:setVolume(gSettings.game.sound/10)
                                end
                            end
                            gAssets.sfx.select_2:stop()
                            gAssets.sfx.select_2:play()
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[1])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            },
            {
                properties = {
                    text = 'Speedrun Clock',
                    values = {'Off', 'File', 'Chapter'},
                    value = gSettings.game.speedrun_clock == 'file' and 2 or gSettings.game.speedrun_clock == 'chapter' and 3 or 1
                },
                update = function(item)
                    if gInput:down('left', 0.15, 0.35) then
                        if item.properties.value ~= 1 then
                            item.properties.value = item.properties.value - 1
                            gSettings.game.speedrun_clock = string.lower(item.properties.values[item.properties.value])
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    elseif gInput:down('right', 0.15, 0.35) then
                        if item.properties.value ~= #item.properties.values then
                            item.properties.value = item.properties.value + 1
                            gSettings.game.speedrun_clock = string.lower(item.properties.values[item.properties.value])
                            love.filesystem.write('settings.lua', 'return ' .. lume.serialize(gSettings))
                        end
                    end
                end,
                render = function(item)
                    local valueTextWidth = 96 + item.font:getWidth(item.properties.values[3])
                    love.graphics.printf({item.properties.value == 1 and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '<'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'left'
                    )
                    love.graphics.printf({item.properties.value == #item.properties.values and gColorManager:getColor('grey') or gColorManager:getColor('whitesmoke'), '>'}, 
                        item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'right'
                    )
                    love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                    love.graphics.printf({item.color, item.properties.values[item.properties.value]}, item.font, item.x + item.w - valueTextWidth, item.y, valueTextWidth, 'center')
                end
            }
        }
    })
    -- TODO: fix config menus
    mainMenu['keyboardconfig'] = Menu:new(
        {
            x = UI_WIDTH / 4,
            y = 64,
            w = UI_WIDTH / 2,
            h = UI_HEIGHT - 128,
            font = gFonts['medium'],
            color = gColorManager:getColor('whitesmoke'),
            titleColor = gColorManager:getColor('mayablue'),
            activeColor = gColorManager:getColor('bananamania'),
            labelColor = gColorManager:getColor('mayablue'),
            title = 'Keyboard Config',
            labels = { -- make this a function that makes them based on gInput.groups
                {name = 'Movement', index = 1},
                {name = 'Actions', index = 5},
                {name = 'Menu', index = 10}
            },
            items = (function()
                local items = {}
                for action, keys in pairs(gInput.binds) do
                    local item = {
                        properties = {
                            text = capitalize(action),
                            keys = {}
                        }
                    }
                    for _, key in pairs(keys) do
                        table.insert(item.properties.keys, capitalize(key))
                    end
                    item.update = function(item)

                    end
                    item.render = function(item)
                        love.graphics.printf({item.color, item.properties.text}, item.font, item.x, item.y, item.w, 'left')
                        for i, key in pairs(item.properties.keys) do
                            love.graphics.printf({item.color, key}, item.font, item.x, item.y, item.w, 'right')
                        end
                    end
                    table.insert(items, item)
                end
                return items
            end)()
        }
    )
    -- mainMenu['controllerconfig'] = Menu:new(
    --     {
    --         x = UI_WIDTH / 4,
    --         y = 64,
    --         w = UI_WIDTH / 2,
    --         h = UI_HEIGHT - 128,
    --         font = gFonts['medium'],
    --         color = gColorManager:getColor('whitesmoke'),
    --         activeColor = gColorManager:getColor('bananamania'),
    --         items = {
                
    --         }
    --     }
    -- )
    gMenuManager:add('main_menu', mainMenu)
end

function love.resize(w, h)
    Event.dispatch('resize', {w=w, h=h})
    push:resize(w, h)
end

function love.keypressed(key)
    Event.dispatch('keypressed', key)
    if key == 'r' then
        gStateStack:clear()
        gStateStack:push(MenuState:new(gMenuManager:getMenu('main_menu')))
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    Event.dispatch('mousemoved', x, y, dx, dy)
end

function love.wheelmoved(x, y)
    Event.dispatch('wheelmoved', x, y)
end

function love.update(dt)
    gTime = love.timer.getTime() - gStartTime
    Timer.update(dt)
    flux.update(dt)

    gStateStack:update(dt)
    gDebugManager:update()
end

function love.draw()
    gColorManager:clear('black')
    gStateStack:render()
    gDebugManager:render()
end

function love.quit()

end