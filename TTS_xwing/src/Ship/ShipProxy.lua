-- ~~~~~~
-- Script by Eirik 'Flippster' Munthe
-- Issues, history at: https://github.com/JohnnyCheese/TTS_X-Wing2.0
--
-- Module for handling ship proxies, used in barrel rolls and more
-- ~~~~~~
local Dim = require("Dim")
local EventSub = require("TTS_Lib.EventSub.EventSub")
local AnnModule = require("Player.Announcements")

local ShipProxyInstance = {
    state        = nil,
    proxy_table  = {},
    proxy_status = {},
}

function ShipProxyInstance:new()
    o = {}
    setmetatable(o, self)
    self.__index = self

    self.state = "init"
    return o
end

function ShipProxyInstance:setActive()
    self.state = "active"
end

function ShipProxyInstance:ready()
    if not self.proxy_table then return false end

    for _, proxy in pairs(self.proxy_table) do
        if proxy.getGUID() ~= "" then return true end
    end

    return false
end

function ShipProxyInstance:add(position, proxy)
    if not proxy then
        return
    end

    self.proxy_table[position] = proxy
end

function ShipProxyInstance:destroy()
    self.state = "term"

    for position, proxy in pairs(self.proxy_table) do
        proxy.destruct()
        self.proxy_table[position] = nil
    end
end

ShipProxyModule = {}
ShipProxyModule.proxyTable = {}
ShipProxyModule.hiddenShips = {}
ShipProxyModule.finalPosOffset = {
    small = Vector(0, 0, Dim.Convert_mm_igu(10)),
    medium = Vector(0, 0, Dim.Convert_mm_igu(20)),
    large = Vector(0, 0, Dim.Convert_mm_igu(20))
}

ShipProxyModule.barrelRollOffset = {}
ShipProxyModule.barrelRollOffset = {
    small = Vector(Dim.Convert_mm_igu(80), 0, 0),
    medium = Vector(Dim.Convert_mm_igu(80), 0, 0),
    large = Vector(Dim.Convert_mm_igu(100), 0, 0)
}

ShipProxyModule.proxyXmlGui = {}
ShipProxyModule.proxyXmlGui.markShip = [[
<Defaults>
    <Button class="InvisibleButton" color="#22222255" outline="#BBBBBB" outlineSize="2 2" fontSize="22" textColor="#FFFFFF" fontStyle="Bold"/>
</Defaults>
<Panel id="Center"
    width="200"
    height="200"
    position="0 0 -20"
    rotation="0 0 180"
    color="#aaffaa00"
    onMouseExit="hideBtn"
    active="false">

    <Button id="Select" class="InvisibleButton" offsetXY="0 0" width="225" height="225" active="true" onClick="select">
    </Button>
</Panel>

]]
ShipProxyModule.proxyXmlGui.finalPos = [[
<Defaults>
    <Button class="InvisibleButton" color="#22222255" outline="#BBBBBB" outlineSize="2 2" fontSize="22" textColor="#FFFFFF" fontStyle="Bold"/>
</Defaults>
<Panel id="Center"
    width="200"
    height="200"
    position="0 0 -20"
    rotation="0 0 180"
    color="#aaffaa00"
    onMouseExit="hideBtn"
    active="false">

    <Button id="Select" class="InvisibleButton" offsetXY="0 0" width="225" height="225" active="true" onClick="select">
    </Button>
</Panel>

]]


ShipProxyModule.proxyScripts = {}
ShipProxyModule.proxyScripts.markShip = [[

sizeScale = {
    small = {width = 1, height = 1},
    medium = {width = 1.5, height = 1.5},
    large = {width = 2.0, height = 2.0},
    huge = {width = 2.0, height = 5}
}

function onLoad(save_state)
    self.AddContextMenuItem("Return ship", function() Global.call("UnMarkShip", {shipGUID = self.getVar("shipGUID"), proxy = self})
end, false)
end

function onContextOpen(player)
    self.UI.setAttribute("Select", "width", tostring(225 * sizeScale[self.getVar("size")].width))
    self.UI.setAttribute("Select", "height", tostring(225 * sizeScale[self.getVar("size")].height))
    self.UI.show("Center")
end

function select(player)
    Global.call("UnMarkShip", {shipGUID = self.getVar("shipGUID"), proxy = self})
end
]]

ShipProxyModule.proxyScripts.finalPos = [[

sizeScale = {
    small = {width = 1, height = 1},
    medium = {width = 1.5, height = 1.5},
    large = {width = 2.0, height = 2.0},
    huge = {width = 2.0, height = 5}
}

function onLoad(save_state)

end

function onHoverEnter(player)
    self.UI.setAttribute("Select", "width", tostring(225 * sizeScale[self.getVar("size")].width))
    self.UI.setAttribute("Select", "height", tostring(225 * sizeScale[self.getVar("size")].height))
    self.UI.show("Center")
    self.setColorTint(hoverColor)
end

function onHoverLeave(player)
    self.UI.hide("Center")
    self.setColorTint(defaultColor)
end

function select(player)
    Global.call("SelectFinalPos", {shipGUID = shipGUID, proxy = self, move_code = move_code})
end
]]

function MarkShip(args)
    local finpos = { pos = args.ship.getPosition(), rot = args.ship.getRotation() }
    local proxy = ShipProxyModule.spawnProxy(args.ship, true, finpos, false, "markShip")

    ShipProxyModule.proxyTable[args.ship.getGUID()] = ShipProxyModule.proxyTable[args.ship.getGUID()] or {}
    table.insert(ShipProxyModule.proxyTable[args.ship.getGUID()], proxy)
end

function UnMarkShip(args)
    local pos = ShipProxyModule.hiddenShips[args.shipGUID]
    local ship = getObjectFromGUID(args.shipGUID)
    if pos ~= nil and ship ~= nil then
        ship.setPosition(pos)
        ship.interactable = true
        ShipProxyModule.hiddenShips[args.shipGUID] = nil
    end
    DeleteShipProxies({ ship_guid = args.shipGUID })
    ShipProxyModule.proxyTable[args.shipGUID] = nil;
end

function StartBarrelRoll(args)
    local ship = args.ship
    local direction = args.direction
    local code = ''
    if direction == "right" then
        code = 'rr'
    elseif direction == "left" then
        code = 'rl'
    end
    local offsets = { code .. '1', code .. '2', code .. '3' }

    local collide = true
    for _, v in ipairs(offsets) do
        local proxy, result = ShipProxyModule.CreateMoveProxy(v, ship)
        if result ~= 'overlap' then
            collide = false
        end

        if proxy then
            ShipProxyModule.proxyTable[args.ship.getGUID()] = ShipProxyModule.proxyTable[args.ship.getGUID()] or {}
            table.insert(ShipProxyModule.proxyTable[args.ship.getGUID()], proxy)
        end
    end

    if collide then
        local info = MoveData.DecodeInfo(code, ship)
        local annInfo = { type = 'overlap', note = info.collNote, code = info.code }
        AnnModule.Announce(annInfo, 'all', ship)
    end
end

local function executeFailure(move_code, ship, finType)
    if finType == 'overlap' then
        local info = MoveData.DecodeInfo(move_code:sub(1, -2), ship)
        local annInfo = { type = 'overlap', note = info.collNote, code = info.code }
        AnnModule.Announce(annInfo, 'all', ship)

        return
    end

    MoveModule.PerformMove(move_code, ship)
end

function SpawnProxyOptions(args)
    local ship          = getObjectFromGUID(args.ship_guid)
    local move_codes    = args.move_codes or {}
    local base_position = args.base_position or 'center'

    local ok = nil
    local finType = nil
    local ship_proxies  = ShipProxyInstance:new()
    for position, move_code in pairs(move_codes) do
        local proxy, finPos = ShipProxyModule.CreateMoveProxy(move_code, ship)
        if finPos.finType == 'move' and finPos.finPart == 'max' then
            ok = true
        else
            finType = finPos.finType
        end

        ship_proxies:add(position, proxy)
    end

    if not ok then
        executeFailure(move_codes[base_position], ship, finType)

        return nil, false
    end

    Wait.condition(function() ship_proxies:setActive() end, function() return ship_proxies:ready() end)

    ShipProxyModule.proxyTable[ship.getGUID()] = ShipProxyModule.proxyTable[ship.getGUID()] or {}
    table.insert(ShipProxyModule.proxyTable[ship.getGUID()], ship_proxies)
    return ship_proxies, true
end

ShipProxyModule.CreateMoveProxy = function(move_code, ship)
    local info = MoveData.DecodeInfo(move_code, ship)
    local finalPos = MoveModule.GetFinalPosData(move_code, ship)

    if finalPos.finType == 'overlap' then
        return nil, finalPos
    end
    if finalPos.finPart ~= 'max' then
        return nil, finalPos
    end

    local templateData = {
        origin = ship.getPosition(),
        orientation = ship.getRotation(),
        dir = info.dir,
        speed = info.speed,
        type = info.type,
        shipSize = info.size,
        extra = info.extra
    }

    local collisions = MoveModule.CheckMineAndObstacleCollisions(ship, finalPos.finPos, false, templateData)

    local didCollide = false
    if collisions[1] ~= nil then
        didCollide = true
    end

    local proxy = ShipProxyModule.spawnProxy(ship, false, finalPos.finPos, didCollide, "finalPos", move_code)
    return proxy, finalPos
end

function SelectFinalPos(args)
    local ship = getObjectFromGUID(args.shipGUID)
    local move_code = args.move_code
    MoveModule.PerformMove(move_code, ship)

    DeleteShipProxies({ ship_guid = args.shipGUID })
end

ShipProxyModule.StartFinalPositionSelection = function(ship, positionOffset)
    local size = ship.getTable('Data').Size or "small"
    local offset = ShipProxyModule.finalPosOffset[size]
    for _, off in pairs({ offset, vector(0, 0, 0), vector(0, 0, 0) - offset }) do
        ShipProxyModule.spawnProxy(ship, false, positionOffset + off, color(0, 0.1, 1, 0.2), "finalPos")
    end
end

function DeleteShipProxies(args)
    local ship_guid = args.ship_guid

    for _ = 1, table.size(ShipProxyModule.proxyTable[ship_guid]) do
        local proxy = table.remove(ShipProxyModule.proxyTable[ship_guid])
        if proxy.destroy then
            proxy:destroy()
        else
            proxy.destruct()
        end
    end
end

ShipProxyModule.proxyModels = {
    collider = {
        small =
        '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/colliders/Small_base_proxy_collider.obj',
        medium =
        '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/colliders/Medium_base_proxy_collider.obj',
        large =
        '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/colliders/Large_base_proxy_collider.obj',
        huge =
        '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/colliders/Huge_base_proxy_collider.obj'
    },
    model = {
        small = '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/ships/proxy/small.obj',
        medium = '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/ships/proxy/medium.obj',
        large = '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/ships/proxy/large.obj',
        huge = '{verifycache}https://github.com/JohnnyCheese/TTS_X-Wing2.0/raw/master/assets/ships/proxy/huge.obj',
    },
}

ShipProxyModule.spawnProxy = function(ship, hide, finpos, didCollide, script, move_code)
    if hide and ShipProxyModule.hiddenShips[ship.getGUID()] ~= nil then
        return
    end

    local proxy = spawnObject({
        type         = "Custom_Model",
        position     = finpos.pos,
        rotation     = finpos.rot,
        scale        = ship.getScale(),
        sound        = false,
        snap_to_grid = false,
    })
    local size = ship.getTable("Data").Size or 'small'
    proxy.setCustomObject({
        type = 0,
        material = 3,
        collider = ShipProxyModule.proxyModels.collider[size],
        mesh = ShipProxyModule.proxyModels.model[size],
    })
    proxy.addTag("ProxyInstance")

    local defaultColor = {}
    local hoverColor = {}
    if didCollide then
        defaultColor = color(1.0, 0.3, 0.3, 0.1)
        hoverColor = color(1.0, 1.0, 0.5, 0.5)
    else
        defaultColor = color(0.3, 0.3, 1.0, 0.1)
        hoverColor = color(0.5, 1.0, 0.5, 0.5)
    end
    proxy.setColorTint(defaultColor)
    proxy.setTable("defaultColor", defaultColor)
    proxy.setTable("hoverColor", hoverColor)

    proxy.setLock(true)
    proxy.setLuaScript(ShipProxyModule.proxyScripts[script])
    proxy.UI.setXml(ShipProxyModule.proxyXmlGui[script])
    proxy.setVar("shipGUID", ship.getGUID())
    proxy.setVar("size", size)
    proxy.setVar("move_code", move_code)

    if hide then
        ShipProxyModule.hiddenShips[ship.getGUID()] = ship.getPosition()
        ship.setPosition(vector(0, -3, 0))
        ship.interactable = false
        ship.setLock(true)
        local playerColors = getSelectingPlayers(ship)
        for _, player in ipairs(playerColors) do
            ship.removeFromPlayerSelection(player)
        end
    end

    return proxy
end

ShipProxyModule.onLoad = function()
    for _, obj in pairs(getAllObjects()) do
        if obj.hasTag("ProxyInstance") then
            destroyObject(obj)
        end
    end
end

EventSub.Register('onLoad', ShipProxyModule.onLoad)

return ShipProxyInstance
