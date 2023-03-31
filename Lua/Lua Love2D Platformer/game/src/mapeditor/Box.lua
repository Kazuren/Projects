Box = class('Box')

function Box:initialize(def)
    self.x = def.x
    self.y = def.y
    self.w = def.w
    self.h = def.h
    self.properties = def.properties
    self.onClick = def.onClick
    self.onRightClick = def.onRightClick
end

function Box:update(dt)

end

function Box:render()
    gColorManager:setColor('whitesmoke')
    love.graphics.rectangle('line',self.x,self.y,self.w,self.h, 4, 4)
    gColorManager:revert()

    local item = self.properties.currentItem
    if item then
        if item.tileset then
            love.graphics.draw(gAssets.graphics[item.tileset.name], gFrames[item.tileset.name][item.id], self.x + self.w / 2 - item.w / 2, self.y + self.h / 2 - item.h / 2)
        elseif item.tiles then
            for _, tile in pairs(item.tiles) do
                love.graphics.draw(gAssets.graphics[tile.tileset], gFrames[tile.tileset][tile.id], self.x + self.w / 2 - item.w / 2 + tile.x, self.y + self.h / 2 - item.h / 2 + tile.y)
            end
        end
    end
end
