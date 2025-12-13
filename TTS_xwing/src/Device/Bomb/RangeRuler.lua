local Dim = require("Dim")

-- Small helper to toggle a spawned range ruler for bombs/remotes.
-- Creates/destroys the ruler, draws vector lines to nearby ships,
-- and remembers the last range so repeated toggles remove the marker.
local RangeRuler = {}

-- opts:
--   mesh_template (string)   e.g. "https://.../bomb_range_%d.obj"
--   static_mesh  (string)    use this instead of template when range-independent
--   collider     (string)    collider url
--   tint         (color)     color(1,1,0,0.2) default
--   button       (table)     overrides for remove button fields
--   delete_click_function (string) name of owner function for remove button (defaults to toggle fn)
--   distance_per_range_mm (number) base distance per range step (default 100)
--   offset       (vec3 table) local offset for spawn (default {0,0.4,0})
--   report       (bool)      print chat output of ships in range (default true)
--   report_color (color)     chat color (default yellow)
function RangeRuler.new(owner, opts)
    local config = opts or {}
    local state = { spawned = nil, lastRange = nil }
    local tint = config.tint or color(1, 1, 0, 0.2)
    local collider = config.collider
        or "https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/colliders/minicollider.obj"
    local meshTemplate = config.mesh_template
        or "https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/Items/arcranges/new/bomb_range_%d.obj"
    local staticMesh = config.static_mesh
    local distancePerRange = config.distance_per_range_mm or 100
    local offset = config.offset or { 0, 0.4, 0 }
    local buttonOverride = config.button or {}
    local deleteClick = config.delete_click_function
    local reportHits = config.report
    if reportHits == nil then
        reportHits = true
    end
    local reportColor = config.report_color or color(1.0, 1.0, 0.2, 0.9)

    local function delete()
        if state.spawned then
            state.spawned.destruct()
            state.spawned = nil
            state.lastRange = nil
            return true
        end
        return false
    end

    local function spawn(range)
        local mesh = staticMesh or string.format(meshTemplate, range)
        local params = {
            type = "Custom_Model",
            position = owner.positionToWorld(offset),
            rotation = owner.getRotation(),
            scale = owner.getScale(),
        }
        local removeButton = {
            click_function = deleteClick or config.toggle_click_function or "ToggleRuler",
            label = buttonOverride.label or "DEL",
            function_owner = owner,
            position = buttonOverride.position or { 0, 0.1, 0 },
            rotation = buttonOverride.rotation or { 0, 270, 0 },
            width = buttonOverride.width or 750,
            height = buttonOverride.height or 750,
            font_size = buttonOverride.font_size or 250,
            color = buttonOverride.color or { 0.7, 0.7, 0.7 },
        }

        local obj = spawnObject(params)
        obj.setCustomObject({ mesh = mesh, collider = collider })
        obj.setColorTint(tint)

        local vector_lines = {}
        local hits = {}
        local maxDistance = distancePerRange * (range or 1)
        for _, other in pairs(getAllObjects()) do
            if other ~= nil and other.type == "Figurine" and other.getVar("__XW_Ship") == true then
                local my_pos = owner.getNearestPointFromObject(other)
                local closest = Global.call("API_GetClosestPointToShip", { ship = other, point = my_pos })
                local distance = Dim.Convert_igu_mm(closest.length)
                if distance < maxDistance then
                    table.insert(vector_lines, {
                        points = { owner.positionToLocal(closest.A), owner.positionToLocal(closest.B) },
                        color = { 1, 1, 1 },
                        thickness = 0.1,
                        rotation = vector(0, 0, 0),
                    })
                    table.insert(hits, {
                        name = other.getName(),
                        distance_mm = distance,
                        range_band = math.ceil(distance / distancePerRange),
                    })
                end
            end
        end
        obj.setVectorLines(vector_lines)
        obj.createButton(removeButton)
        obj.lock()
        state.spawned = obj
        state.lastRange = range
        if reportHits then
            if #hits == 0 then
                printToAll("No ships within range " .. tostring(range) .. " of " .. owner.getName(), reportColor)
            else
                table.sort(hits, function(a, b) return a.distance_mm < b.distance_mm end)
                printToAll("Checking for ships within range " .. tostring(range) .. " of " .. owner.getName() .. ":", reportColor)
                for _, hit in ipairs(hits) do
                    local distanceStr = string.format("%.0f", hit.distance_mm)
                    printToAll(" - " .. hit.name .. " at range " .. tostring(hit.range_band) .. " (" .. distanceStr .. " mm)", reportColor)
                end
            end
        end
        return true
    end

    local function toggle(range)
        range = range or 1
        if state.spawned then
            local sameRange = (state.lastRange == range)
            delete()
            if sameRange then
                return false
            end
        end
        return spawn(range)
    end

    return {
        toggle = toggle,
        delete = delete,
    }
end

return RangeRuler
