-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
--
-- ~~~~~~
local Dim = require("Dim")

-- Call bomb drop stick
function onDropped()
    Global.call('API_BombTokenDrop', { token = self })
end

local spawnedRuler = nil
function update()
    if self.getDescription() == 'r' then
        if ToggleRuler2() then
            printToAll('Spawning ' .. self.getName() .. ' guide', { 0, 1, 1 })
        end
        self.setDescription('')
    end
end

function ToggleRuler1()
    return ToggleRuler(1)
end

function ToggleRuler2()
    return ToggleRuler(2)
end

function DeleteRuler()
    if spawnedRuler then
        spawnedRuler.destruct()
        spawnedRuler = nil
    end
end

function ToggleRuler(range)
    if spawnedRuler then
        spawnedRuler.destruct()
        spawnedRuler = nil
        if spawnedRulerRange == range then
            return false
        end
    end
    local params = {
        type = 'Custom_Model',
        position = self.positionToWorld({ 0, 0.4, 0 }),
        rotation = self.getRotation(),
        scale = self.getScale()
    }
    local custom = {
        mesh = 'https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/Items/arcranges/new/bomb_range_'
            .. tostring(range) .. '.obj',
        collider = 'https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/colliders/minicollider.obj'
    }
    local removeButton = {
        click_function = 'DeleteRuler',
        label = 'DEL',
        function_owner = self,
        position = { 0, 0.1, 0 },
        rotation = { 0, 270, 0 },
        width = 750,
        height = 750,
        font_size = 250,
        color = { 0.7, 0.7, 0.7 }
    }
    spawnedRuler = spawnObject(params)
    spawnedRuler.setCustomObject(custom)
    spawnedRuler.setColorTint(color(1, 1, 0, 0.2))
    vector_lines = {}
    for _, obj in pairs(getAllObjects()) do
        if obj ~= nil and obj.type == 'Figurine' and obj.getVar('__XW_Ship') == true then
            my_pos = self.getNearestPointFromObject(obj)

            closest = Global.call('API_GetClosestPointToShip', { ship = obj, point = my_pos })
            distance = Dim.Convert_igu_mm(closest.length)
            if distance < 100 * range then
                table.insert(vector_lines, {
                    points = { self.positionToLocal(closest.A), self.positionToLocal(closest.B) },
                    color = { 1, 1, 1 },
                    thickness = 0.1,
                    rotation = vector(0, 0, 0)
                })
            end
        end
    end
    spawnedRuler.setVectorLines(vector_lines)
    spawnedRuler.createButton(removeButton)
    spawnedRuler.lock()
    spawnedRulerRange = range
    return true
end

function onLoad()
    if self.getName() == 'AoE Bomb source' then
        self.setPosition({ 0, -3, 18.28 })
        self.setRotation({ 0, 0, 0 })
        self.lock()
        self.tooltip = false
        self.interactable = false
        update = nil
    else
        self.addContextMenuItem("Toggle Range 1", ToggleRuler1, false)
        self.addContextMenuItem("Toggle Range 2", ToggleRuler2, false)
    end
end
