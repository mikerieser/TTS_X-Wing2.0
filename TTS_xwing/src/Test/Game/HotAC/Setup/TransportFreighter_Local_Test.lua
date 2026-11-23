-- Run from the repository root with:
-- lua TTS_xwing/src/Test/Game/HotAC/Setup/TransportFreighter_Local_Test.lua
-- The freighter is an object script, so these tests load it in an isolated
-- environment and model only the TTS bag and Wait behavior used below.
package.path = "./?.lua;./TTS_xwing/src/?.lua;" .. package.path

local function equal(expected, actual)
    assert(expected == actual, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function object(guid, y, worldSizeY, normalizedSizeY)
    local obj = {
        guid = guid,
        name = guid,
        position = { x = 0, y = y, z = 0 },
        rotation = { x = 0, y = 0, z = 0 },
        script_state = "state-" .. guid,
        locked = false,
        resting = true,
        spawning = false,
        loading_custom = false,
    }
    function obj.getGUID() return obj.guid end
    function obj.getName() return obj.name end
    function obj.getPosition() return obj.position end
    function obj.getRotation() return obj.rotation end
    function obj.getLock() return obj.locked end
    function obj.hasTag() return false end
    function obj.getBounds()
        return { center = obj.position, size = { y = worldSizeY or 1 } }
    end
    function obj.getBoundsNormalized()
        return { center = obj.position, size = { y = normalizedSizeY or worldSizeY or 1 } }
    end
    function obj.setPositionSmooth(pos) obj.position = pos end
    function obj.setPosition(pos) obj.position = pos end
    function obj.setRotation(rot) obj.rotation = rot end
    function obj.setLock(locked) obj.locked = locked end
    return obj
end

local function harness(savedCargo)
    local waits, frames, messages = {}, {}, {}
    local bag = { contents = {}, taken = {}, position = { x = 20, y = 3, z = 0 } }
    local env = setmetatable({}, { __index = _G })
    env.self = bag
    env.Color = { Red = "red", Yellow = "yellow" }
    env.JSON = { encode = function(value) return value end, decode = function(value) return value end }
    env.Vector = function(x, y, z) return { x = x, y = y, z = z } end
    env.printToAll = function(message) messages[#messages + 1] = message end
    env.getAllObjects = function() return {} end
    env.getObjectFromGUID = function() return nil end
    env.Wait = {
        condition = function(onReady, condition, _, onTimeout)
            waits[#waits + 1] = { onReady = onReady, condition = condition, onTimeout = onTimeout }
        end,
        frames = function(callback) frames[#frames + 1] = callback end,
    }
    _G.Wait = env.Wait -- The existing Sequence module resolves Wait from its own environment.

    function bag.getGUID() return "bag001" end
    function bag.getPosition() return bag.position end
    function bag.getCustomObject() return { type = 0 } end
    function bag.addContextMenuItem() end
    function bag.getObjects()
        local result = {}
        for i, obj in ipairs(bag.contents) do
            result[#result + 1] = { guid = obj.guid, index = i - 1 }
        end
        return result
    end
    function bag.putObject(obj) bag.contents[#bag.contents + 1] = obj end
    function bag.takeObject(params)
        bag.taken[#bag.taken + 1] = params
        for i, obj in ipairs(bag.contents) do
            if (params.index ~= nil and params.index == i - 1) or params.guid == obj.guid then
                table.remove(bag.contents, i)
                bag.pending = { obj = obj, callback = params.callback_function }
                return obj
            end
        end
        error("missing contained object")
    end

    local chunk = assert(loadfile("TTS_xwing/src/Game/HotAC/Setup/TransportFreighter.lua", "t", env))
    chunk()
    env.onLoad(savedCargo or { transportedCargo = {}, excludeList = {} })

    local h = { env = env, bag = bag, messages = messages }
    function h.frame()
        local callback = table.remove(frames, 1)
        if callback then callback() end
        return callback ~= nil
    end
    function h.flushFrames()
        while h.frame() do end
    end
    function h.deliver()
        local pending = bag.pending
        assert(pending, "no pending takeObject callback")
        bag.pending = nil
        pending.callback(pending.obj)
        return pending.obj
    end
    function h.ready()
        local wait = table.remove(waits, 1)
        assert(wait and wait.condition(), "wait condition was not ready")
        wait.onReady()
    end
    function h.timeout()
        local wait = table.remove(waits, 1)
        assert(wait and wait.onTimeout, "no timed wait")
        wait.onTimeout()
    end
    return h
end

local function cargo(guid, y)
    return {
        guid = guid, name = guid,
        pos = { x = 2, y = y or 1, z = 4 },
        rot = { x = 0, y = 90, z = 0 },
        state = "saved-" .. guid, locked = true,
    }
end

local tests = {}

function tests.pack_uses_world_bottom_for_rotated_objects()
    local h = harness()
    local upper = object("upper", 3, 1, 10) -- normalized bottom -2; actual bottom 2.5
    local lower = object("lower", 2, 1, 1) -- actual bottom 1.5
    h.env.getAllObjects = function() return { lower, upper } end
    h.env.packObjects()
    h.flushFrames()
    equal("upper", h.bag.contents[1].guid)
    equal("lower", h.bag.contents[2].guid)
end

function tests.marble_inside_bowl_packs_first_and_deploys_after_bowl()
    local h = harness()
    local bowl = object("bowl", 2, 4) -- Center is high, but its bottom is at 0.
    local marble = object("marble", 1.5, 1) -- Center is lower, bottom is at 1.
    h.env.getAllObjects = function() return { bowl, marble } end
    h.env.packObjects()
    h.flushFrames()
    equal("marble", h.bag.contents[1].guid)
    equal("bowl", h.bag.contents[2].guid)

    h.env.deployObjects()
    equal("bowl", h.bag.pending.obj.guid)
    h.deliver()
    h.ready()
    equal("marble", h.bag.pending.obj.guid)
    h.deliver()
    h.ready()
    equal(0, #h.env.onSave().transportedCargo)
end

function tests.pack_does_not_discard_existing_cargo_manifest()
    local h = harness({ transportedCargo = { cargo("existing") }, excludeList = {} })
    h.bag.contents = { object("existing", 1) }
    h.env.getAllObjects = function() return { object("new", 2) } end
    h.env.packObjects()
    h.flushFrames()
    local saved = h.env.onSave()
    equal(1, #saved.transportedCargo)
    equal("existing", saved.transportedCargo[1].guid)
    equal(1, #h.bag.contents)
end

function tests.pack_failure_does_not_claim_object_was_stored()
    local h = harness()
    local ship = object("ship", 2)
    h.env.getAllObjects = function() return { ship } end
    h.bag.putObject = function() error("simulated bag failure") end
    h.env.packObjects()
    h.flushFrames()
    equal(0, #h.env.onSave().transportedCargo)
    equal(0, #h.bag.contents)
    equal(2, ship.position.y)
end

function tests.deploy_uses_contained_index_and_callback_object_on_guid_collision()
    local h = harness({ transportedCargo = { cargo("ship") }, excludeList = {} })
    local old = object("ship", 10)
    local carried = object("ship", 20)
    h.bag.contents = { carried }
    h.env.getObjectFromGUID = function() return old end
    h.env.deployObjects()
    equal(0, h.bag.taken[1].index)
    equal(nil, h.bag.taken[1].guid)
    h.deliver()
    h.ready()
    equal(2, carried.position.x)
    equal(90, carried.rotation.y)
    equal("saved-ship", carried.script_state)
    equal(true, carried.locked)
    equal(10, old.position.y)
    equal(0, #h.env.onSave().transportedCargo)
end

function tests.deploy_timeout_keeps_unspawned_cargo_for_retry()
    local h = harness({ transportedCargo = { cargo("ship") }, excludeList = {} })
    h.bag.contents = { object("ship", 1) }
    local take = h.bag.takeObject
    h.bag.takeObject = function() end -- TTS did not return or remove an object.
    h.env.deployObjects()
    h.timeout()
    equal(1, #h.env.onSave().transportedCargo)
    h.bag.takeObject = take
    h.env.deployObjects()
    h.deliver()
    h.ready()
    equal(0, #h.env.onSave().transportedCargo)
end

function tests.deploy_repeated_click_does_not_drop_in_flight_cargo()
    local h = harness({ transportedCargo = { cargo("ship") }, excludeList = {} })
    h.bag.contents = { object("ship", 1) }
    h.env.deployObjects()
    h.env.deployObjects()
    equal(1, #h.bag.taken)
    equal(1, #h.env.onSave().transportedCargo)
    h.deliver()
    h.ready()
    equal(0, #h.env.onSave().transportedCargo)
end

function tests.deploy_continues_after_take_error_and_preserves_failed_cargo()
    local h = harness({ transportedCargo = { cargo("failed", 1), cargo("ready", 2) }, excludeList = {} })
    h.bag.contents = { object("failed", 1), object("ready", 2) }
    local take = h.bag.takeObject
    h.bag.takeObject = function(params)
        if params.index == 0 then error("simulated take failure") end
        return take(params)
    end
    h.env.deployObjects()
    equal("ready", h.bag.pending.obj.guid)
    h.deliver()
    h.ready()
    equal(1, #h.env.onSave().transportedCargo)
    equal("failed", h.env.onSave().transportedCargo[1].guid)
end

local names = {}
for name in pairs(tests) do names[#names + 1] = name end
table.sort(names)
for _, name in ipairs(names) do
    tests[name]()
    print("PASS " .. name)
end
print(#names .. " transport freighter tests passed")
