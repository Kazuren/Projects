Mouse = class('Mouse')

function Mouse:initialize(cursor)
	self.cursor = love.mouse.getSystemCursor(cursor)
	love.mouse.setCursor(self.cursor)
	love.mouse.setVisible(true)
	self.x, self.y = love.mouse.getPosition()
	self.previousX, self.previousY = self.x, self.y
	self.dx, self.dy = 0, 0
end

function Mouse:set(cursor)
	self.cursor = love.mouse.getSystemCursor(cursor)
	love.mouse.setCursor(self.cursor)
end

function Mouse:update(dt)
	if self.cursor ~= love.mouse.getCursor() then
		love.mouse.setCursor(self.cursor)
	end
	self.x, self.y = love.mouse.getPosition()
	self.dx, self.dy = self.x - self.previousX, self.y - self.previousY
	self.previousX, self.previousY = self.x, self.y
end


function Mouse:render()
	--love.graphics.draw(self.cursor, self.x, self.y)
end

function Mouse:destroy()
	love.mouse.setVisible(false)
	love.mouse.setCursor()
end