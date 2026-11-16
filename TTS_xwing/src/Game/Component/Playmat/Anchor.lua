-- Component/Playmat/Anchor.lua
-- Rect: "TL|TR|BL|BR|C", "edge:(left|right|top|bottom|north|south|east|west)@t"
-- Circle: "C", "angle@deg"
-- Poly: "centroid", "edgeN@t" (1-based)
local Anchor = {}
Anchor.__index = Anchor

local function v3(v) return v and (v.x and v or Vector(v[1], v[2] or 1, v[3])) or nil end
local function vcopy(v) return Vector(v.x, v.y, v.z) end
local function lerp(a, b, t) return a + (b - a) * t end
local function clamp01(x) if x < 0 then return 0 elseif x > 1 then return 1 else return x end end

local function normSide(side)
  if not side then return nil end
  local s = side:lower()
  if s == "north" then return "top" end
  if s == "south" then return "bottom" end
  if s == "west"  then return "left" end
  if s == "east"  then return "right" end
  if s == "top" or s == "bottom" or s == "left" or s == "right" then return s end
  return nil
end

-- minimal, robust parser
local function parseRef(ref)
  if type(ref) == "table" then return { kind = "world", world = v3(ref) } end
  if type(ref) ~= "string" then return { kind = "named", name = tostring(ref) } end

  local s = ref:match("^%s*(.-)%s*$") or ref
  local sl = s:lower()

  -- rect edge: edge:<side>@<t>    (t supports 0..1 or 0..100%)
  do
    local side, tnum, pct = sl:match("^edge%s*:%s*([%a]+)%s*@%s*([%d%.]+)(%%?)$")
    if side then
      local ns = normSide(side)
      if ns then
        local t = tonumber(tnum) or 0
        if pct == "%" then t = t / 100 end
        return { kind = "rect-edge", side = ns, t = t }
      end
    end
  end

  -- circle angle@deg
  do
    local ang = sl:match("^angle%s*@%s*([%-%d%.]+)$")
    if ang then return { kind = "circle-angle", angle = tonumber(ang) or 0 } end
  end

  if sl == "centroid" then return { kind = "poly-centroid" } end

  -- poly edgeN@t
  do
    local n, tnum, pct = sl:match("^edge(%d+)%s*@%s*([%d%.]+)(%%?)$")
    if n then
      local t = tonumber(tnum) or 0
      if pct == "%" then t = t / 100 end
      return { kind = "poly-edge", n = tonumber(n), t = t }
    end
  end

  return { kind = "named", name = s }
end

local M = {}

function M.ref(s)
  return setmetatable({ _ref = parseRef(s), _offs = Vector(0, 0, 0), _offsR = { 0, 0 }, _towards = nil }, Anchor)
end

function M.world(v)
  return setmetatable({ _ref = { kind = "world", world = v3(v) }, _offs = Vector(0, 0, 0), _offsR = { 0, 0 }, _towards = nil }, Anchor)
end

function Anchor:offset(dx, dy, dz)
  self._offs = self._offs + Vector(dx or 0, dy or 0, dz or 0)
  return self
end

function Anchor:offsetR(xR, zR)
  self._offsR = { (xR or 0), (zR or 0) }
  return self
end

function Anchor:towards(target, dist)
  self._towards = { target = target, dist = dist }
  return self
end

local function resolveRectEdge(scope, side, t)
  if not (scope.TL and scope.TR and scope.BL and scope.BR) then
    error("Anchor: rect-edge on non-rect scope")
  end
  t = clamp01(t or 0)
  if side == "top" then
    return lerp(scope.TL, scope.TR, t)
  elseif side == "bottom" then
    return lerp(scope.BL, scope.BR, t)
  elseif side == "left" then
    return lerp(scope.BL, scope.TL, t)
  elseif side == "right" then
    return lerp(scope.BR, scope.TR, t)
  else
    error("Anchor: invalid rect side")
  end
end

function Anchor:resolve(scope)
  local r = self._ref

  -- hard fail-safe: if a named value actually looks like DSL, reparse now
  if r.kind == "named" and type(r.name) == "string" then
    local nameLower = r.name:lower()
    if nameLower:match("^edge%s*:") or nameLower:match("^angle%s*@") or nameLower == "centroid" or nameLower:match("^edge%d+%s*@") then
      r = parseRef(r.name)
      self._ref = r
    end
  end

  local p

  if r.kind == "world" then
    p = vcopy(r.world)

  elseif scope.kind == "composite" then
    local inc = scope.includes or {}
    if #inc > 0 then return self:resolve(inc[1]) end
    error("Anchor: composite scope requires at least one include")

  elseif r.kind == "named" then
    local base = scope[r.name]
    if not base then error("Anchor: bad anchor name '" .. tostring(r.name) .. "'") end
    p = vcopy(base)

  elseif r.kind == "rect-edge" then
    p = resolveRectEdge(scope, r.side, r.t)

  elseif r.kind == "circle-angle" then
    if not (scope.C and scope.R) then error("Anchor: circle-angle on non-circle scope") end
    local rad = math.rad(r.angle or 0)
    p = Vector(scope.C.x + math.cos(rad) * scope.R, scope.C.y, scope.C.z + math.sin(rad) * scope.R)

  elseif r.kind == "poly-centroid" then
    if not scope.verts then error("Anchor: centroid on non-poly scope") end
    local x, z = 0, 0
    local n = #scope.verts
    local y = scope.C and scope.C.y or (n > 0 and scope.verts[1].y or 1)
    for _, v in ipairs(scope.verts) do x = x + v.x; z = z + v.z end
    p = Vector(x / math.max(1, n), y, z / math.max(1, n))

  elseif r.kind == "poly-edge" then
    if not scope.verts then error("Anchor: poly-edge on non-poly scope") end
    local n = #scope.verts
    if n < 2 then error("Anchor: poly has fewer than 2 vertices") end
    local i = ((r.n or 1) - 1) % n + 1
    local a, b = scope.verts[i], scope.verts[i % n + 1]
    p = lerp(a, b, clamp01(r.t or 0))

  else
    error("Anchor: unsupported ref kind " .. tostring(r.kind))
  end

  -- apply R1 offset (world +X/+Z)
  if self._offsR and (self._offsR[1] ~= 0 or self._offsR[2] ~= 0) then
    local r1 = (scope.dims and scope.dims.length or 0) / 3
    p = p + Vector(self._offsR[1] * r1, 0, self._offsR[2] * r1)
  end

  -- absolute offset
  p = p + (self._offs or Vector(0, 0, 0))

  -- towards(target, dist)
  if self._towards then
    local tp = self._towards.target:resolve(scope)
    local dir = tp - p
    dir.y = 0
    local m = dir:magnitude()
    if m > 0 then p = p + dir:normalized() * (self._towards.dist or 0) end
  end

  return p
end

return M
