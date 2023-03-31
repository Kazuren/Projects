ColorManager = class('ColorManager')

local clamp = lume.clamp
local lerp = lume.lerp

local function querp(a,b,c,t)
    return  (1-t)^2 * a +
            (1-t)*2 * t * b +
            t^2 * c
end
local function cuberp(a,b,c,d,t)
    return  (1-t)^3 * a +
            (1-t)^2 * 3*t * b +
            (1-t) * 3 * t^2 * c +
            t^3 * d
end

-- TODO: add ColorManager:invert(color)

function ColorManager:initialize(palette, baseColor)
    self.palette = palette or {}
    self.baseColor = baseColor or {1, 1, 1, 1}
end

-- Implement adding multiple at once with --> {}
function ColorManager:add(name, color)
    self.palette[name] = color
end

function ColorManager:remove(name)
    self.palette[name] = nil
end

function ColorManager:clear(color)
    if type(color) == 'string' then
        color = self.palette[color]
    end
    love.graphics.clear(color)
end

function ColorManager:revert()
    self:setColor(self.baseColor)
end

function ColorManager:getColor(color)
    if type(color) == 'string' then
        color = self.palette[color]
    end
    return color
end

function ColorManager:setColor(color, alpha)
    local r, g, b, a = love.graphics.getColor()
    
    if type(color) == 'string' then
        color = self.palette[color]
    end
    if color[1] ~= r or color[2] ~= g or color[3] ~= b or color[4] ~= a or alpha ~= a then
        love.graphics.setColor({color[1], color[2], color[3], alpha or color[4]})
    end
end

function ColorManager:darken(color, p)
    if type(color) == 'string' then
        color = self.palette[color]
    end
    return {color[1] * (1 - p), color[2] * (1 - p), color[3] * (1 - p), color[4]}
end

function ColorManager:lighten(color, p)
    if type(color) == 'string' then
        color = self.palette[color]
    end
    return {color[1] + (1 - color[1]) * p, color[2] + (1 - color[2]) * p, color[3] + (1 - color[3]) * p, color[4]}
end

-- Implement mixing any number of colors together
function ColorManager:mix(color,alpha,shade, color2,factor)
    local s
    if shade then s=clamp(0,(1-shade)/1,1) else s=0 end
    if not color2 then
        local color = self:getColor(color)
        local r, g, b = color[1], color[2], color[3]
        return  {
            clamp(0,r*s,1),
            clamp(0,g*s,1),
            clamp(0,b*s,1),
            clamp(0,alpha,1)
        }
    else
        local color = self:getColor(color)
        local color2 = self:getColor(color2)
        local r1, g1, b1 = color[1], color[2], color[3]
        local r2, g2, b2 = color2[1], color2[2], color2[3]
        local t = clamp(0,factor,1)
        return   {
            clamp(0, lerp(r1,r2,t)*s, 1),
            clamp(0, lerp(g1,g2,t)*s, 1),
            clamp(0, lerp(b1,b2,t)*s, 1),
            clamp(0,alpha,1)
        }
    end
end

function ColorManager:gradient(range, distance, colorTable)
    local size = 0
    local c,a,t,s = {}, colorTable['alpha'] or 1, clamp(0,distance/range,1), 1
    if colorTable['shade'] then s=clamp(0,(1-colorTable['shade'])/1,1) end
    for _,color in pairs(colorTable) do
       if type(color) == 'string' then
            table.insert(c, self:getColor(color))
            size = size+1
       end
    end
    if size == 2 then 
        return {
            clamp(0, lerp(c[1][1]*s,c[2][1]*s,t), 1),
            clamp(0, lerp(c[1][2]*s,c[2][2]*s,t), 1),
            clamp(0, lerp(c[1][3]*s,c[2][3]*s,t), 1),
            clamp(0,a,1)
        }
    elseif size == 3 then 
        return {
            clamp(0, querp(c[1][1]*s,c[2][1]*s,c[3][1]*s,t), 1),
            clamp(0, querp(c[1][2]*s,c[2][2]*s,c[3][2]*s,t), 1),
            clamp(0, querp(c[1][3]*s,c[2][3]*s,c[3][3]*s,t), 1),
            clamp(0,a,1)
        }
    elseif size == 4 then 
        return {
            clamp(0, cuberp(c[1][1]*s,c[2][1]*s,c[3][1]*s,c[4][1]*s,t), 1),
            clamp(0, cuberp(c[1][2]*s,c[2][2]*s,c[3][2]*s,c[4][2]*s,t), 1),
            clamp(0, cuberp(c[1][3]*s,c[2][3]*s,c[3][3]*s,c[4][3]*s,t), 1),
            clamp(0,a,1)
        }
    end
end