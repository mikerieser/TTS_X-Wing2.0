-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
-- ~~~~~~

local BombBase = require("Device.Bomb.BombBase")

local bomb = BombBase.new(self, { toggle_function_name = "ToggleRuler" })

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
