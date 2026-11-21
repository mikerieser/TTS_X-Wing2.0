local lu = require("Test.luaunit_tts")
local Fixture = require("Test.Game.HotAC.Setup.TransportFreighterFixture")

local TestTransportFreighterDeploy = {}

function TestTransportFreighterDeploy:setUp()
    self.fixture = Fixture.new()
end

function TestTransportFreighterDeploy:tearDown()
    if self.fixture then self.fixture:destroy() end
end

function TestTransportFreighterDeploy:test_deploy_restores_packed_object_and_clears_manifest()
    local f = self.fixture
    f:ready()
    local obj = f:spawnBlock("LuaUnit deploy fixture")
    obj.setRotation(Vector(0, 45, 0))
    local originalPosition = obj.getPosition()
    local guid = obj.getGUID()
    f.bag.call("packOneObject", obj)
    f:waitFor(function() return f:contains(guid) end, 180, "The test block was not packed")

    f.bag.call("deployObjects")
    f:waitFor(function()
        return #f:state().transportedCargo == 0 and getObjectFromGUID(guid) ~= nil
    end, 1500, "The freighter did not finish deploying the test block")

    local restored = getObjectFromGUID(guid)
    lu.assertAlmostEquals(originalPosition.x, restored.getPosition().x, 0.01)
    lu.assertAlmostEquals(originalPosition.z, restored.getPosition().z, 0.01)
    lu.assertAlmostEquals(45, restored.getRotation().y, 0.01)
    lu.assertTrue(restored.getLock())
    lu.assertEquals(0, #f:state().transportedCargo)
end

function TestTransportFreighterDeploy:test_missing_cargo_is_removed_from_retry_list()
    local f = self.fixture
    f:ready()
    lu.assertNil(getObjectFromGUID("ffffff"), "Reserve ffffff for missing-cargo test")
    f:loadState({
        transportedCargo = { { guid = "ffffff", name = "missing" } },
        excludeList = {},
    })

    f.bag.call("deployObjects")

    lu.assertEquals(0, #f:state().transportedCargo)
end

return TestTransportFreighterDeploy
