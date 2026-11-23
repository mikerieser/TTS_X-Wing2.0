--[[ Tranport Freighter
Aid to migrate HotAC-type games. Add this script to any ship model
e.g. "Rebel Transport" or "Bulk Freighter," and convert it to a "Transport Freighter"
(Memory Bag). It's intended to collect all player artifacts and transport
them to a new release of the Unified Mod.
    1. Create a baseline of all default in-game objects this should be done from an unmodified game (as released).
        * this creates an exclusion list of objects which will not be packed up.
    2. `Pack up` player's objects and store them in the Transport Freighter.
    3. Save the Transport Freighter as an external object
    4. Load the new version of the X-Wing Mod
    5. Spawn the saved Transport Freighter external object into the game
    6. Deploy the transported game objects
]]
require("TTS_lib.Util.Table")
local Sequence = require("TTS_lib.Sequence.Sequence")

local name = "Transport Freighter"
local desc = [[
[b]Pack Up Game[/b]:
Adds all objects on the table (except those in its exclusion list) to the freighter.

[b]Deploy Game[/b]:
Redeploys all stored objects from the freighter out to the current table.

[b]Baseline Game Mod[/b]:
Creates an exclusion list based on the current table's objects.  Excluded items will not be packed for transport.
(This should be done first from an unmodified game.)
]]

-- Table to store the exclude list of base game object GUIDs
local excludeList = {}

-- Table to store transported objects' data
local transportCargo = {}

local DEPLOY_TIMEOUT_SECONDS = 20
local deploying = false

-- Respawns any ship with this script to turn it into a Transport Freighter "Memory Bag"
function createTransportFreighterBag()
    self.setName(name)
    self.setDescription(desc)

    local info = self.getCustomObject()
    info.type = 6
    info.cast_shadows = true
    self.setCustomObject(info)
    self.removeTag("Ship")
    self.reload()
end

-- Adds action buttons for packing and unpacking
function createFreighterButtons(obj)
    local bounds = obj.getBounds()
    local position = Vector(-1.25, 0.05, bounds.size.z)

    obj.createButton({
        label = "Pack Up",
        click_function = "packObjects",
        function_owner = obj,
        position = position,
        rotation = { 0, 0, 0 },
        width = 1000,
        height = 400,
        font_size = 200,
        color = { 0, 0, 0 },
        font_color = { 1, 1, 1 },
    })

    obj.createButton({
        label = "Deploy",
        click_function = "deployObjects",
        function_owner = obj,
        position = position:scale(Vector(-1, 1, 1)),
        rotation = { 0, 0, 0 },
        width = 1000,
        height = 400,
        font_size = 200,
        color = { 0, 0, 0 },
        font_color = { 1, 1, 1 },
    })
end

function round(num, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function getObjectLabel(item)
    local label = item.name or "object"
    if item.guid then
        label = label .. " [" .. item.guid .. "]"
    end
    return label
end

local function printDeployError(item, message)
    printToAll(name .. ": " .. message .. " " .. getObjectLabel(item), Color.Red)
end

local function printDeployWarning(item, message)
    printToAll(name .. ": " .. message .. " " .. getObjectLabel(item), Color.Yellow)
end

local function tryDeployCall(item, action, func)
    local ok, err = pcall(func)
    if not ok then
        printToAll(name .. ": " .. action .. " failed for " .. getObjectLabel(item) .. ": " .. tostring(err), Color.Red)
        return false
    end
    return true
end

local function getObjectBottomY(obj)
    local pos = obj.getPosition()
    local bottomY = pos and pos.y or 0
    local ok, bounds = pcall(function()
        if obj.getBounds then
            return obj.getBounds()
        end
        return nil
    end)

    if ok and bounds and bounds.center and bounds.size then
        bottomY = bounds.center.y - (bounds.size.y / 2)
    end

    return round(bottomY, 4)
end

local function getCargoBottomY(item)
    if item.bottomY ~= nil then return item.bottomY end
    if item.pos and item.pos.y ~= nil then return item.pos.y end
    return 0
end

local function findContainedCargo(guid)
    for _, contained in ipairs(self.getObjects() or {}) do
        if contained.guid == guid then
            return contained
        end
    end
    return nil
end

local function isDeployedObjectReady(obj)
    return obj ~= nil
        and obj.resting
        and not obj.spawning
        and not obj.loading_custom
end

local function prepareSpawnedObject(spawnedObj, item)
    tryDeployCall(item, "Lock", function() spawnedObj.setLock(true) end)
    tryDeployCall(item, "Position", function() spawnedObj.setPosition(item.pos) end)
    tryDeployCall(item, "Rotation", function() spawnedObj.setRotation(item.rot) end)
    tryDeployCall(item, "Script state", function() spawnedObj.script_state = item.state or "" end)
end

local function finalizeSpawnedObject(spawnedObj, item)
    if spawnedObj == nil then return end
    tryDeployCall(item, "Final position", function() spawnedObj.setPosition(item.pos) end)
    tryDeployCall(item, "Final rotation", function() spawnedObj.setRotation(item.rot) end)
    tryDeployCall(item, "Final lock", function() spawnedObj.setLock(item.locked == true) end)
end

-- Pack up objects from the table, excluding those in the base mod (exclude list)
function packObjects()
    if #transportCargo > 0 then
        printToAll(name .. ": Deploy or clear the existing cargo before packing again.", Color.Red)
        return
    end
    transportCargo = {} -- Reset storage

    local toPack = {}
    for _, obj in ipairs(getAllObjects()) do
        if not isExcluded(obj) then
            table.insert(toPack, { object = obj, bottomY = getObjectBottomY(obj) })
        end
    end

    table.sort(toPack, function(a, b)
        if a.bottomY == b.bottomY then
            return a.object.getPosition().y > b.object.getPosition().y
        end
        return a.bottomY > b.bottomY
    end)

    -- 3) Build sequence
    local seq = Sequence:new()
    for _, packItem in ipairs(toPack) do
        seq:addTask(packOneObject, packItem.object, packItem.bottomY)
        seq:waitFrames(1)
    end

    seq:addTask(function()
        printToAll("Packing complete. " .. #transportCargo .. " objects packed into " .. name, Color.Yellow)
    end)

    seq:start()
end

function packOneObject(obj, bottomY)
    -- we already filtered excluded objects, but double‐check if you like
    if isExcluded(obj) then
        printToAll("Skipping “" .. obj.getName() .. "”", Color.Red)
        return
    end

    -- record its final data
    local pos = obj.getPosition()
    local rot = obj.getRotation()
    local item = {
        guid   = obj.getGUID(),
        name   = obj.getName(),
        pos    = { x = round(pos.x, 4), y = round(pos.y, 4), z = round(pos.z, 4) },
        rot    = { x = round(rot.x, 4), y = round(rot.y, 4), z = round(rot.z, 4) },
        bottomY = bottomY or getObjectBottomY(obj),
        state  = obj.script_state or "",
        locked = obj.getLock(),
    }

    -- move it into the bag
    local ok, err = pcall(function()
        obj.setPositionSmooth(self.getPosition())
        self.putObject(obj)
    end)
    if ok then
        table.insert(transportCargo, item)
    else
        local restored, restoreError = pcall(function() obj.setPosition(pos) end)
        printToAll(name .. ": Failed to pack " .. getObjectLabel(item) .. ": " .. tostring(err), Color.Red)
        if not restored then
            printToAll(name .. ": Could not restore " .. getObjectLabel(item) .. ": " .. tostring(restoreError), Color.Red)
        end
    end
end

function isExcluded(obj)
    local guid = obj.getGUID()
    if guid == self.getGUID()
        or obj.hasTag("TempLayoutElement")
        or obj.tag == "Hand"
    then
        return true
    end

    for _, ex in ipairs(excludeList) do
        if guid == ex then return true end
    end
    return false
end

-- Deploy stored objects from the Transport Freighter back to the table
function deployObjects()
    if deploying then
        printToAll(name .. ": Deployment is already in progress.", Color.Yellow)
        return
    end
    deploying = true
    printToAll('[b]Redeploying objects...[/b] wait for message: "All objects deployed."', Color.Yellow)

    table.sort(transportCargo, function(a, b)
        local aBottom = getCargoBottomY(a)
        local bBottom = getCargoBottomY(b)
        if aBottom == bBottom then
            return (a.name or a.guid or "") < (b.name or b.guid or "")
        end
        return aBottom < bBottom
    end)

    local stats = { deployed = 0, skipped = 0, failed = 0, warnings = 0 }

    local function finishDeploy()
        deploying = false
        local summary = name .. ": Deploy complete. Deployed " .. stats.deployed .. " object(s)."
        if stats.skipped > 0 then summary = summary .. " Skipped " .. stats.skipped .. "." end
        if stats.failed > 0 then summary = summary .. " Retryable failures " .. stats.failed .. "." end
        if stats.warnings > 0 then summary = summary .. " Warnings " .. stats.warnings .. "." end
        if #transportCargo == 0 then
            summary = summary .. " All objects deployed."
        else
            summary = summary .. " " .. #transportCargo .. " object(s) remain in the freighter for retry."
        end
        printToAll("[b]" .. summary .. "[/b]", Color.Yellow)
    end

    -- Deploy each object sequentially
    local function deployNext(index)
        if index > #transportCargo then
            finishDeploy()
            return
        end

        local item = transportCargo[index]
        local contained = findContainedCargo(item.guid)
        if contained == nil then
            printDeployWarning(item, "Skipping missing cargo; it is no longer inside the freighter.")
            table.remove(transportCargo, index)
            stats.skipped = stats.skipped + 1
            deployNext(index)
            return
        end

        if getObjectFromGUID(item.guid) ~= nil then
            printDeployWarning(item, "GUID collision with an active table object; deploying by freighter index.")
            stats.warnings = stats.warnings + 1
        end

        local spawnedObj = nil
        local spawnFailed = false
        local finished = false
        local takeParams = {
            position = item.pos,
            rotation = item.rot,
            smooth = false, -- Skip smooth placement to avoid physics issues
            callback_function = function(newObj)
                if newObj and not finished then
                    spawnedObj = newObj
                    prepareSpawnedObject(spawnedObj, item)
                elseif newObj then
                    prepareSpawnedObject(newObj, item)
                    finalizeSpawnedObject(newObj, item)
                else
                    spawnFailed = true
                end
            end,
        }

        if contained.index ~= nil then
            takeParams.index = contained.index
        else
            printDeployWarning(item, "Contained item has no index; falling back to GUID.")
            takeParams.guid = item.guid
            stats.warnings = stats.warnings + 1
        end

        local ok, err = pcall(function() self.takeObject(takeParams) end)
        if not ok then
            printToAll(name .. ": takeObject failed for " .. getObjectLabel(item) .. ": " .. tostring(err), Color.Red)
            stats.failed = stats.failed + 1
            deployNext(index + 1)
            return
        end

        -- Wait for the object to settle before deploying the next
        Wait.condition(function()
            if finished then return end
            finished = true

            if spawnFailed and spawnedObj == nil then
                printDeployError(item, "Failed before spawning; leaving in freighter for retry.")
                stats.failed = stats.failed + 1
                deployNext(index + 1)
                return
            end

            finalizeSpawnedObject(spawnedObj, item)
            table.remove(transportCargo, index)
            stats.deployed = stats.deployed + 1
            deployNext(index)
        end, function()
            return spawnFailed or isDeployedObjectReady(spawnedObj)
        end, DEPLOY_TIMEOUT_SECONDS, function()
            if finished then return end
            finished = true

            if spawnedObj ~= nil then
                finalizeSpawnedObject(spawnedObj, item)
                printDeployWarning(item, "Timed out waiting for object to settle; leaving deployed and continuing.")
                table.remove(transportCargo, index)
                stats.deployed = stats.deployed + 1
                stats.warnings = stats.warnings + 1
                deployNext(index)
                return
            end

            if findContainedCargo(item.guid) == nil then
                printDeployWarning(item, "Left the freighter but did not report a spawned object; removing from retry list.")
                table.remove(transportCargo, index)
                stats.skipped = stats.skipped + 1
                stats.warnings = stats.warnings + 1
                deployNext(index)
                return
            end

            printDeployError(item, "Timed out before spawning; leaving in freighter for retry.")
            stats.failed = stats.failed + 1
            deployNext(index + 1)
        end)
    end

    -- Start deploying from the first item
    deployNext(1)
end

function baselineExclusions()
    excludeList = {}
    for _, obj in ipairs(getObjects()) do
        table.insert(excludeList, obj.guid)
    end
end

-- Utility functions to save state persistently
function onSave()
    return JSON.encode({ transportedCargo = transportCargo, excludeList = excludeList })
end

-- Initializes the transport freighter on load or spawn
function onLoad(saved_data)
    local loadedCargo = nil
    if saved_data and saved_data ~= "" then
        local ok, decoded = pcall(function() return JSON.decode(saved_data) end)
        if ok then
            loadedCargo = decoded
        else
            printToAll(name .. ": Failed to load saved cargo data: " .. tostring(decoded), Color.Red)
        end
    end

    if loadedCargo then
        transportCargo = loadedCargo.transportedCargo or {}
        excludeList = loadedCargo.excludeList or { self.getGUID() }
    end

    local objInfo = self.getCustomObject()
    if objInfo and objInfo.type == 6 then -- Type 6 corresponds to "Bag"
        self.addContextMenuItem("Packup Game", packObjects, false)
        self.addContextMenuItem("Deploy Game", deployObjects, false)
        self.addContextMenuItem("Baseline Game Mod", baselineExclusions, false)

        Wait.condition(
            function() createFreighterButtons(self) end,
            function() return self.resting and not self.spawning and not self.loading_custom end
        )
    else
        self.addContextMenuItem("Convert To Freighter", createTransportFreighterBag, false)
    end
end
