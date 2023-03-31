Menu = class('Menu')

function Menu:initialize(def)
    self.items = def.items or {}
    self.labels = def.labels or {}
    self.title = def.title or nil
    self.x = def.x
    self.y = def.y
    self.w = def.w
    self.h = def.h
    self.font = def.font
    self.titleFont = def.titleFont or self.font
    self.labelFont = def.labelFont or self.font
    self.color = def.color
    self.activeColor = def.activeColor
    self.titleColor = def.titleColor or self.color
    self.labelColor = def.labelColor

    self.selection = 1

    local currentY = self.y
    if self.title then currentY = currentY + self.titleFont:getHeight() * 2 end

    local labelIndex = 1
    for i, item in pairs(self.items) do
        if self.labels[labelIndex] and i == self.labels[labelIndex].index then
            local label = self.labels[labelIndex]
            label.x = self.x
            label.y = currentY
            label.w = self.w
            label.font = self.labelFont
            label.color = self.labelColor

            labelIndex = labelIndex + 1
            currentY = currentY + self.labelFont:getHeight() * 2
        end
        item.x = self.x
        item.y = currentY
        item.w = self.w
        item.font = self.font
        item.color = self.color

        if self.labels[labelIndex] and i + 1 == self.labels[labelIndex].index then
            currentY = currentY + def.font:getHeight() * 4
        else
            currentY = currentY + def.font:getHeight() * 2
        end
    end
    self.items[self.selection].color = self.activeColor
end

function Menu:update(dt)
    if gInput:down('up', 0.15, 0.35) then
        if self.selection ~= 1 then
            self.selection = self.selection - 1
            gAssets.sfx.select:stop()
            gAssets.sfx.select:play()
        end
    elseif gInput:down('down', 0.15, 0.35) then
        if self.selection ~= #self.items then
            self.selection = self.selection + 1
            gAssets.sfx.select:stop()
            gAssets.sfx.select:play()
        end
    end

    for i, item in pairs(self.items) do
        item.color = self.color
        if i == self.selection then item.color = self.activeColor end
    end

    local item = self.items[self.selection]
    item:update()
end

function Menu:render()
    love.graphics.push()
    local s = math.min(love.graphics:getWidth() / UI_WIDTH, love.graphics:getHeight() / UI_HEIGHT)
    love.graphics.setScissor(self.x * s, self.y * s, self.w * s, self.h * s)

    if self.title then
        love.graphics.printf({self.titleColor, self.title}, self.titleFont, self.x, self.y, self.w, 'center')
    end

    for _, label in pairs(self.labels) do
        love.graphics.printf({label.color, label.name}, label.font, label.x, label.y, label.w)
    end

    for i, item in pairs(self.items) do
        item:render()
    end
    love.graphics.setScissor()
    love.graphics.pop()
    --love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

function Menu:enter()
    self.selection = 1
end

function Menu:exit()

end