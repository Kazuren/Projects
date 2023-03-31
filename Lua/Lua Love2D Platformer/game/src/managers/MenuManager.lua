MenuManager = class('MenuManager')

function MenuManager:initialize()
    self.menus = {}
end

function MenuManager:add(name, menu)
    self.menus[name] = menu
end

function MenuManager:remove(name)
    self.menus[name] = nil
end

function MenuManager:getMenu(name)
    return self.menus[name]
end
