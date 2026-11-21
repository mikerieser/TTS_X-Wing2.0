local lu = require("Test.luaunit_tts")
local Fixture = require("Test.Game.HotAC.Setup.TransportFreighterFixture")

local TestTransportFreighterPack = {}

function TestTransportFreighterPack:setUp()
    self.fixture = Fixture.new()
end

function TestTransportFreighterPack:tearDown()
    if self.fixture then self.fixture:destroy() end
end

function TestTransportFreighterPack:test_pack_records_world_bottom_and_object_state()
    local f = self.fixture
    f:ready()
    local obj = f:spawnBlock("LuaUnit pack fixture")
    obj.setRotation(Vector(45, 0, 0))
    lu.await(0)
    obj.script_state = "freighter-test-state"
    local guid = obj.getGUID()
    local bounds = obj.getBounds()
    local expectedBottom = math.floor((bounds.center.y - bounds.size.y / 2) * 10000 + 0.5) / 10000

    f.bag.call("packOneObject", obj)
    f:waitFor(function() return f:contains(guid) end, 180, "The freighter did not contain the test block")

    local cargo = f:state().transportedCargo
    lu.assertEquals(1, #cargo)
    lu.assertEquals(guid, cargo[1].guid)
    lu.assertAlmostEquals(expectedBottom, cargo[1].bottomY, 0.0001)
    lu.assertEquals("freighter-test-state", cargo[1].state)
    lu.assertTrue(cargo[1].locked)
end

function TestTransportFreighterPack:test_temp_layout_object_is_excluded()
    local f = self.fixture
    f:ready()
    local obj = f:spawnBlock("LuaUnit excluded fixture")
    obj.addTag("TempLayoutElement")
    local guid = obj.getGUID()

    f.bag.call("packOneObject", obj)

    lu.assertEquals(0, #f:state().transportedCargo)
    lu.assertNotNil(getObjectFromGUID(guid))
end

function TestTransportFreighterPack:test_pack_does_not_replace_existing_manifest()
    local f = self.fixture
    f:ready()
    f:loadState({
        transportedCargo = { { guid = "ffffff", name = "existing" } },
        excludeList = {},
    })

    f.bag.call("packObjects")

    local cargo = f:state().transportedCargo
    lu.assertEquals(1, #cargo)
    lu.assertEquals("ffffff", cargo[1].guid)
end

return TestTransportFreighterPack
