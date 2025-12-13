local RangeRuler = require("Device.Bomb.RangeRuler")

-- Shared helpers for bomb tokens.
-- Provides standard onDropped/update handlers and a RangeRuler wrapper so each
-- bomb script only needs to keep its unique bits.
local BombBase = {}

local function isAoESource(obj)
    return obj.getName() == "AoE Bomb source"
end

-- opts:
--   default_range          (number) range to use for default toggle (default 1)
--   update_range           (number) range used when description=="r" (default default_range)
--   mesh_template          (string) passed to RangeRuler
--   static_mesh            (string) passed to RangeRuler
--   collider               (string) passed to RangeRuler
--   tint                   (color)  passed to RangeRuler
--   button                 (table)  passed to RangeRuler
--   offset                 (vec3)   passed to RangeRuler
--   distance_per_range_mm  (number) passed to RangeRuler
--   toggle_function_name   (string) click_function for ruler delete button
--   delete_function_name   (string) click_function for explicit delete handler
--   menu_label             (string) label for default context menu item
--   skip_default_menu      (bool)   do not add the default context item
function BombBase.new(owner, opts)
    local config = opts or {}
    local defaultRange = config.default_range or 1
    local updateRange = config.update_range or defaultRange
    local menuLabel = config.menu_label or ("Toggle Range " .. tostring(defaultRange))
    local toggleFnName = config.toggle_function_name or "ToggleRuler"
    local deleteFnName = config.delete_function_name

    local state = { disableUpdate = isAoESource(owner) }

    local ruler = RangeRuler.new(owner, {
        mesh_template = config.mesh_template,
        static_mesh = config.static_mesh,
        collider = config.collider,
        tint = config.tint,
        button = config.button,
        offset = config.offset,
        toggle_click_function = toggleFnName,
        delete_click_function = deleteFnName,
        distance_per_range_mm = config.distance_per_range_mm,
    })

    local function onDropped()
        Global.call("API_BombTokenDrop", { token = owner })
    end

    local function toggle(range, quiet)
        local spawned = ruler.toggle(range or defaultRange)
        if spawned and not quiet then
            printToAll("Spawning " .. owner.getName() .. " guide", { 0, 1, 1 })
        end
        return spawned
    end

    local function deleteRuler()
        return ruler.delete()
    end

    local function update()
        if state.disableUpdate then
            return
        end
        if owner.getDescription() == "r" then
            if toggle(updateRange, true) then
                printToAll("Spawning " .. owner.getName() .. " guide", { 0, 1, 1 })
            end
            owner.setDescription("")
        end
    end

    local function onLoad(extraMenus)
        if isAoESource(owner) then
            owner.setPosition({ 0, -3, 18.28 })
            owner.setRotation({ 0, 0, 0 })
            owner.lock()
            owner.tooltip = false
            owner.interactable = false
            state.disableUpdate = true
            return
        end

        if not config.skip_default_menu then
            owner.addContextMenuItem(menuLabel, function() return toggle(defaultRange) end, false)
        end

        if extraMenus then
            for _, menu in ipairs(extraMenus) do
                if menu and menu.label and menu.fn then
                    owner.addContextMenuItem(menu.label, menu.fn, menu.stayOpen or false)
                end
            end
        end
    end

    local function toggleFor(range)
        return function()
            return toggle(range)
        end
    end

    return {
        onDropped = onDropped,
        update = update,
        toggle = toggle,
        toggleFor = toggleFor,
        deleteRuler = deleteRuler,
        onLoad = onLoad,
        ruler = ruler,
    }
end

return BombBase
