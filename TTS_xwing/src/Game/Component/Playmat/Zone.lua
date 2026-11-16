-- Component/Playmat/Zone.lua
local PlayArea = require("Game.Component.Playmat.PlayArea")

local Zone = {}

local function copyDimsFrom(area)
  -- Keep board's R1 basis stable across all Zones
  return { length = area.dims.length, width = area.dims.width, height = area.dims.height, radius = area.dims.radius }
end

local function inheritFace(area, opts)
  return (opts and opts.face) or area.face
end

function Zone.fromRect(area, name, TL, TR, BL, BR, opts)
  local z = PlayArea.newRect(TL, TR, BL, BR, { face = inheritFace(area, opts) })
  z.kind = "rect"
  z.name = name
  z.dims = copyDimsFrom(area)
  return z
end

function Zone.fromCircle(area, name, C, R, opts)
  local z = PlayArea.newCircle(C, R, { face = inheritFace(area, opts) })
  z.kind = "circle"
  z.name = name
  z.dims = copyDimsFrom(area)
  return z
end

function Zone.fromPoly(area, name, verts, opts)
  local z = PlayArea.newPoly(verts, { face = inheritFace(area, opts) })
  z.kind = "poly"
  z.name = name
  z.dims = copyDimsFrom(area)
  return z
end

-- Composite zone support: includes/excludes are arrays of zones or raw shape tables
function Zone.composite(area, name, includes, excludes, opts)
  return {
    kind = "composite",
    name = name,
    includes = includes or {},
    excludes = excludes or {},
    dims = copyDimsFrom(area),
    face = inheritFace(area, opts)
  }
end

return Zone
