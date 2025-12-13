-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
-- ~~~~~~

local BombBase = require("Device.Bomb.BombBase")
local Dim = require("Dim")

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

SpawnBlaze = function()
    local position = self.getPosition() - Dim.Convert_mm_igu(53) * self.getTransformRight()
    cloneItemFromBag("Blaze", function(blaze)
        blaze.setPositionSmooth(position, false, true)
        blaze.setRotationSmooth(self.getRotation(), false, true)
        blaze.lock()
        Global.call("API_MineDrop", { mine = blaze })
    end)
    fuseBag = getObjectFromGUID('568727')
    fuseBag.takeObject({
        position = self.getPosition() - Dim.Convert_mm_igu(53) * self.getTransformRight() + vector(0, 1, 0),
        smooth   = true,
    })
end

function cloneItemFromBag(name, client_callback_function)
    local obstacleBag = getObjectFromGUID('203cb8')
    if obstacleBag == nil then
        printToAll("Obstacles Bag has gone missing!", { 1, 0, 0 })
        return
    end

    local itemGuid = nil
    for _, item in ipairs(obstacleBag.getObjects()) do
        if item.name == name then
            itemGuid = item.guid
            break
        end
    end

    if itemGuid then
        obstacleBag.takeObject({
            guid = itemGuid,
            position = obstacleBag.getPosition() + Vector(3, 1, 0),
            callback_function = function(obj)
                local clone = obj.clone()
                obstacleBag.putObject(obj)
                client_callback_function(clone)
            end
        })
    else
        print("Obstacle not found in Obstacles Bag.")
    end
end

function onLoad()
    bomb.onLoad({
        { label = "Place Blaze", fn = SpawnBlaze },
    })
end
