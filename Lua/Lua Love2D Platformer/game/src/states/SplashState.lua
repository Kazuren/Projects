SplashState = class('SplashState', BaseState)

-- Possibly remove this whole thing(can add it on credits maybe)

function SplashState:initialize()
    self.splash = splashes.new({
        background=gColorManager:getColor('black'),
        delay_before=0.1,
        delay_after=0.7
    })

    local once = false

    local skipHandler = Event.on('keypressed', function (key)
        if not once then
            gStateStack:push(FadeState:new(gColorManager:getColor('black'), 0.3, 'in', 'linear', function() self.splash:skip() end), {}, {updateLast = true})
            once = true
        end
    end)

    self.splash.onDone = function()
        skipHandler:remove()
        gStateStack:clear()
        gStateStack:push(MenuState:new(gMenuManager:getMenu('main_menu')))
        gStateStack:push(FadeState:new(gColorManager:getColor('black'), 0.3, 'out'))
    end
end

function SplashState:update(dt)
    self.splash:update(dt)
end

function SplashState:render()
    self.splash:draw()
end
