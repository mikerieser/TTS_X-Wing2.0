-- Component/Playmat/PlayArea.lua
local PlayArea = {}

local function vcopy(v) return Vector(v.x, v.y, v.z) end
local function avg4(a, b, c, d)
  return Vector((a.x + b.x + c.x + d.x) / 4, a.y, (a.z + b.z + c.z + d.z) / 4)
end

local function dimsForRect(TL, TR, BL)
  local width  = (TR - TL):magnitude()
  local height = (TL - BL):magnitude()
  return { length = math.max(width, height), width = width, height = height }
end

local function faceDefault()
  -- TTS yaw (Y) degrees: east = 0°, north = +90°
  return { east = Vector(0, 0, 0), north = Vector(0, 90, 0) }
end

function PlayArea.newRect(TL, TR, BL, BR, opts)
  local TLc, TRc, BLc, BRc = vcopy(TL), vcopy(TR), vcopy(BL), vcopy(BR)
  local C = avg4(TLc, TRc, BLc, BRc)
  local dims = dimsForRect(TLc, TRc, BLc)
  local face = (opts and opts.face) or faceDefault()
  return {
    kind = "rect",
    TL = TLc, TR = TRc, BL = BLc, BR = BRc, C = C,
    dims = dims,
    face = face
  }
end

function PlayArea.newCircle(C, R, opts)
  local Cc = vcopy(C)
  local dims = { length = 3 * R, radius = R }
  local face = (opts and opts.face) or faceDefault()
  return {
    kind = "circle",
    C = Cc, R = R,
    dims = dims,
    face = face
  }
end

local function centroid(verts)
  local sx, sz = 0, 0
  local y = verts[1] and verts[1].y or 1
  for _, v in ipairs(verts) do sx = sx + v.x; sz = sz + v.z end
  local n = math.max(1, #verts)
  return Vector(sx / n, y, sz / n)
end

function PlayArea.newPoly(verts, opts)
  local cloned = {}
  for i, v in ipairs(verts) do cloned[i] = vcopy(v) end
  local C = centroid(cloned)

  -- bounding box for a stable 'length' basis
  local minx, maxx, minz, maxz = cloned[1].x, cloned[1].x, cloned[1].z, cloned[1].z
  for i = 2, #cloned do
    local v = cloned[i]
    if v.x < minx then minx = v.x end
    if v.x > maxx then maxx = v.x end
    if v.z < minz then minz = v.z end
    if v.z > maxz then maxz = v.z end
  end
  local width  = maxx - minx
  local height = maxz - minz
  local dims = { length = math.max(width, height), width = width, height = height }

  local face = (opts and opts.face) or faceDefault()
  return {
    kind = "poly",
    verts = cloned,
    C = C,
    dims = dims,
    face = face
  }
end

function PlayArea.r1(scope)
  return (scope.dims and scope.dims.length or 0) / 3
end

return PlayArea
