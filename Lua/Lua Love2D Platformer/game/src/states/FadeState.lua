FadeState = class('FadeState', BaseState)

function FadeState:initialize(color, time, transition, easing, onFadeComplete)
    self.color = color
    self.time = time
    self.easing = easing or 'linear'
    self.onFadeComplete = onFadeComplete or function() end
    if transition == 'in' then
        self.opacity = 0
        flux.to(self, self.time, {opacity = 1})
            :ease(self.easing)
            :oncomplete(function()
                gStateStack:pop()
                self.onFadeComplete()
            end)
    else
        self.opacity = 1
        flux.to(self, self.time, {opacity = 0})
            :ease(self.easing)
            :oncomplete(function()
                gStateStack:pop()
                self.onFadeComplete()
            end)
    end
end

function FadeState:render()
    gColorManager:setColor({self.color[1], self.color[2], self.color[3], self.opacity})
    love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
    gColorManager:revert()
end