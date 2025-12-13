-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
-- ~~~~~~

local BombBase = require("Device.Bomb.BombBase")

local bomb = BombBase.new(self, {
    default_range = 1,
    update_range = 2,
    delete_function_name = "DeleteRuler",
    skip_default_menu = true,
})

local toggleRange1 = bomb.toggleFor(1)
local toggleRange2 = bomb.toggleFor(2)

function onDropped()
    bomb.onDropped()
end

function update()
    bomb.update()
end

function ToggleRuler1()
    return toggleRange1()
end

function ToggleRuler2()
    return toggleRange2()
end

function DeleteRuler()
    return bomb.deleteRuler()
end

function onLoad()
    bomb.onLoad({
        { label = "Toggle Range 1", fn = ToggleRuler1 },
        { label = "Toggle Range 2", fn = ToggleRuler2 },
    })
end
