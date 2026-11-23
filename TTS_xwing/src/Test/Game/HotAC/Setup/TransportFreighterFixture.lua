local lu = require("Test.luaunit_tts")

local Fixture = {}
Fixture.__index = Fixture

local function findFreighterTemplate()
    local assetBag = getObjectFromGUID(bagGuids.ExtraAssets)
    lu.assertNotNil(assetBag, "The Extra Assets bag is missing")

    local found = {}
    for _, item in ipairs(assetBag.getObjects()) do
        if item.gm_notes == "transportfreighter" then
            found[#found + 1] = item
        end
    end
    lu.assertEquals(1, #found, "Expected one tagged Transport Freighter in the Extra Assets bag")
    lu.assertTrue(type(found[1].lua_script) == "string" and found[1].lua_script ~= "",
        "Update the stored Transport Freighter's script before running these tests")

    local assetData = assetBag.getData()
    lu.assertNotNil(assetData.ContainedObjects, "The Extra Assets bag has no object data")
    for _, data in ipairs(assetData.ContainedObjects) do
        if data.GUID == found[1].guid then
            lu.assertEquals(0, #(data.ContainedObjects or {}),
                "The stored Transport Freighter must be empty; test cleanup destroys its copy")
            lu.assertTrue(type(data.LuaScript) == "string"
                and data.LuaScript:find("getObjectBottomY", 1, true) ~= nil,
                "The Transport Freighter inside Extra Assets has an outdated script; update the stored object from Game/HotAC/Setup/TransportFreighter.lua")
            return assetBag, found[1].guid, data
        end
    end
    lu.fail("The tagged Transport Freighter has no matching object data")
end

function Fixture.new()
    local assetBag, templateGuid, data = findFreighterTemplate()
    local sourcePos = assetBag.getPosition()
    local position = Vector(sourcePos.x + 20, 5, sourcePos.z + 20)
    -- Spawn a copy of the contained asset without removing or changing its template.
    data.GUID = nil
    data.LuaScriptState = ""
    local bag = spawnObjectData({ data = data, position = position, rotation = Vector(0, 0, 0) })
    lu.assertNotNil(bag, "Could not spawn the Transport Freighter test subject")

    return setmetatable({
        bag = bag,
        assetBag = assetBag,
        templateGuid = templateGuid,
        position = position,
        spawnedGuids = {},
    }, Fixture)
end

function Fixture:waitFor(predicate, maxFrames, message)
    for _ = 1, maxFrames do
        if predicate() then return end
        lu.await(0)
    end
    lu.assertTrue(predicate(), message)
end

function Fixture:ready()
    self:waitFor(function()
        if self.bag.spawning or self.bag.loading_custom then return false end
        local ok, saved = pcall(function() return self.bag.call("onSave") end)
        return ok and type(saved) == "string"
    end, 180, "The spawned freighter script did not load; check the stored asset")

    self.bagGuid = self.bag.getGUID()
    lu.assertTrue(self.bagGuid ~= self.templateGuid, "The test subject must have its own GUID")
    local info = self.bag.getCustomObject()
    lu.assertTrue(info ~= nil and info.type == 6, "The test subject is not a custom bag")
    local templateIsStored = false
    for _, item in ipairs(self.assetBag.getObjects()) do
        if item.guid == self.templateGuid then templateIsStored = true end
    end
    lu.assertTrue(templateIsStored, "Spawning a test subject removed the stored freighter")
    self.bag.setName("Transport Freighter [LuaUnit fixture]")
    self.bag.setLock(true)

    -- Only the spawned test subject's manifest is reset. Its template is untouched.
    self:loadState({ transportedCargo = {}, excludeList = {} })
end

function Fixture:loadState(state)
    self.bag.call("onLoad", JSON.encode(state))
    local loaded = self:state()
    lu.assertEquals(state.transportedCargo, loaded.transportedCargo,
        "The test freighter did not load the requested cargo manifest")
    lu.assertEquals(state.excludeList, loaded.excludeList,
        "The test freighter did not load the requested exclusion list")
end

function Fixture:state()
    return JSON.decode(self.bag.call("onSave"))
end

function Fixture:spawnBlock(name)
    local obj = spawnObject({
        type = "BlockSquare",
        position = Vector(self.position.x + 4, self.position.y + 2, self.position.z),
        sound = false,
        snap_to_grid = false,
    })
    obj.setName(name)
    self:waitFor(function() return not obj.spawning and not obj.loading_custom end,
        180, "Test block did not finish spawning")
    self.spawnedGuids[#self.spawnedGuids + 1] = obj.getGUID()
    obj.setLock(true)
    return obj
end

function Fixture:contains(guid)
    for _, item in ipairs(self.bag.getObjects()) do
        if item.guid == guid then return true end
    end
    return false
end

function Fixture:destroy()
    for _, guid in ipairs(self.spawnedGuids) do
        local obj = getObjectFromGUID(guid)
        if obj then destroyObject(obj) end
    end
    local bag = self.bagGuid and getObjectFromGUID(self.bagGuid) or self.bag
    if bag then destroyObject(bag) end
end

return Fixture
