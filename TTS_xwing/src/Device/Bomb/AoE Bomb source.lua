-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
-- ~~~~~~

local BombBase = require("Device.Bomb.BombBase")

local bomb = BombBase.new(self, {
    default_range = 2,
    menu_label = "Toggle Range 2",
    collider = "https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/Items/arcranges/new/bomb_collider.obj",
    toggle_function_name = "ToggleRuler",
})

function onDropped()
    bomb.onDropped()
end

function update()
    bomb.update()
end

function ToggleRuler()
    return bomb.toggle()
end

function onLoad()
    bomb.onLoad()
end
