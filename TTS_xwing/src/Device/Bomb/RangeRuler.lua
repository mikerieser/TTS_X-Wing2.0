local Dim = require("Dim")

-- Spawns a translucent blast bubble and vector lines on a bomb/remote.
-- Bubble sits near the bottom of the bomb, lines live on the bomb (raised so
-- they stay visible through the bubble), and a DEL button on the bomb removes
-- everything. Toggle simply deletes any prior visuals then spawns fresh ones.
local RangeRuler = {}

-- opts:
--   mesh_template (string)   e.g. "https://.../bomb_range_%d.obj"
--   static_mesh   (string)   use this instead of template when range-independent
--   collider      (string)   collider url
--   tint          (color)    bubble tint (default semi-transparent yellow)
--   button        (table)    overrides for remove button fields
--   delete_click_function (string) name of owner function for remove button (defaults to toggle fn)
--   distance_per_range_mm (number) base distance per range step (default 100)
--   offset        (vec3)     local offset for bubble spawn (default near bottom)
--   vector_line_offset (number) local Y lift for vector line endpoints (default at bomb top)
--   line_thickness (number) thickness for vector lines (default 0.15)
--   report        (bool)     print chat output of ships in range (default true)
--   report_color  (color)    chat color (default yellow)
function RangeRuler.new(owner, opts)
    local config = opts or {}
    local state = { bubble = nil, buttonIndex = nil }
    local defaultRange = config.default_range or 1

    local tint = config.tint or Color(0.7, 0.7, 0, 0.25)
    local collider = config.collider
        or "https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/colliders/minicollider.obj"
    local meshTemplate = config.mesh_template
        or "https://raw.githubusercontent.com/JohnnyCheese/TTS_X-Wing2.0/master/assets/Items/arcranges/new/bomb_range_%d.obj"
    local staticMesh = config.static_mesh
    local distancePerRange = config.distance_per_range_mm or 100
    local offsetConfig = config.offset
    local vectorLineOffset = config.vector_line_offset -- computed per-spawn if nil
    local lineThickness = config.line_thickness or 0.15

    local buttonOverride = config.button or {}
    local deleteFnName = config.delete_click_function or "__RR_Delete"

    local reportHits = config.report
    if reportHits == nil then
        reportHits = true
    end
    local reportColor = config.report_color or Color(1.0, 1.0, 0.2, 0.9)

    local function clearButton()
        if state.buttonIndex ~= nil then
            pcall(function() owner.removeButton(state.buttonIndex) end)
            state.buttonIndex = nil
        end
    end

    local function delete()
        if state.bubble and state.bubble.destruct then
            state.bubble.destruct()
        end
        state.bubble = nil
        owner.setVectorLines({})
        owner.clearButtons()
        return true
    end

    local function spawn(range)
        local scale = owner.getScale()
        local bounds = owner.getBoundsNormalized()
        local halfHeight = bounds and bounds.size.y / 2 or 0.5
        halfHeight = halfHeight / scale.y
        -- Bubble just above the bottom of the bomb
        local bubbleOffset = offsetConfig or { 0, -(halfHeight) + 0.12, 0 }
        -- Raise vector lines to the top of the bomb (or caller override)
        local lineOffset = vectorLineOffset or halfHeight

        local mesh = staticMesh or string.format(meshTemplate, range)
        local params = {
            type = "Custom_Model",
            position = owner.positionToWorld(bubbleOffset),
            rotation = owner.getRotation(),
            scale = owner.getScale(),
        }

        local bubble = spawnObject(params)
        if not bubble then
            return false
        end
        bubble.setCustomObject({ mesh = mesh, collider = collider })
        bubble.setColorTint(tint)
        bubble.lock()
        bubble.tooltip = false
        bubble.interactable = false
        state.bubble = bubble

        printToAll("halfHeight = " .. halfHeight, Color.Pink)

        clearButton()
        local removeButton = {
            click_function = deleteFnName,
            label = buttonOverride.label or "DEL",
            function_owner = owner,
            position = { 0, math.abs(bounds.offset.y) + 2 * halfHeight + 0.05, 0 },
            rotation = buttonOverride.rotation or { 0, 270, 0 },
            width = buttonOverride.width or 750,
            height = buttonOverride.height or 750,
            font_size = buttonOverride.font_size or 250,
            color = buttonOverride.color or { 0.7, 0.7, 0.6 },
        }
        -- ensure delete handler exists on owner
        owner.setVar(deleteFnName, function() delete() end)
        state.buttonIndex = owner.createButton(removeButton)

        local vector_lines = {}
        local hits = {}
        local maxDistance = distancePerRange * (range or 1)
        for _, other in pairs(getAllObjects()) do
            if other ~= nil and other.type == "Figurine" and other.getVar("__XW_Ship") == true then
                local my_pos = owner.getNearestPointFromObject(other)
                local closest = Global.call("API_GetClosestPointToShip", { ship = other, point = my_pos })
                if closest and closest.length and closest.A and closest.B then
                    local distance = Dim.Convert_igu_mm(closest.length)
                    if distance < maxDistance then
                        local aLocal = owner.positionToLocal(closest.A)
                        local bLocal = owner.positionToLocal(closest.B)
                        aLocal.y = (aLocal.y or 0) + lineOffset
                        bLocal.y = (bLocal.y or 0) + lineOffset
                        table.insert(vector_lines, {
                            points = { aLocal, bLocal },
                            color = { 1, 1, 1 },
                            thickness = lineThickness,
                        })
                        table.insert(hits, {
                            name = other.getName(),
                            distance_mm = distance,
                            range_band = math.ceil(distance / distancePerRange),
                        })
                    end
                end
            end
        end
        owner.setVectorLines(vector_lines)

        if reportHits then
            if #hits == 0 then
                printToAll("No ships within range " .. tostring(range) .. " of " .. owner.getName(), reportColor)
            else
                table.sort(hits, function(a, b) return a.distance_mm < b.distance_mm end)
                printToAll("Checking for ships within range " .. tostring(range) .. " of " .. owner.getName() .. ":",
                    reportColor)
                for _, hit in ipairs(hits) do
                    local distanceStr = string.format("%.0f", hit.distance_mm)
                    printToAll(
                        " - " .. hit.name .. " at range " .. tostring(hit.range_band) .. " (" .. distanceStr .. " mm)",
                        reportColor)
                end
            end
        end
        return true
    end

    local function toggle(range)
        delete()
        return spawn(range or defaultRange)
    end

    return {
        toggle = toggle,
        delete = delete,
    }
end

return RangeRuler
