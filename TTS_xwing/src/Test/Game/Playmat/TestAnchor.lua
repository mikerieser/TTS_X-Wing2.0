local lu       = require("Test.luaunit_tts")
local Anchor   = require("Game.Component.Playmat.Anchor")
local PlayArea = require("Game.Component.Playmat.PlayArea")

local function rectScope()
  local C    = Vector(0, 1, 0)
  local TL   = Vector(-9, 1, 9)
  local TR   = Vector(9, 1, 9)
  local BL   = Vector(-9, 1, -9)
  local BR   = Vector(9, 1, -9)
  local dims = { length = 18 } -- R1 = 6
  return { kind = "rect", C = C, TL = TL, TR = TR, BL = BL, BR = BR, dims = dims }
end

local T = {}

function T.test_named_corner()
  local p = Anchor.ref("TL"):resolve(rectScope())
  lu.assertEquals(Vector(-9, 1, 9), p)
end

function T.test_edge_param()
  local p = Anchor.ref("edge:top@0.5"):resolve(rectScope())
  lu.assertEquals(Vector(0, 1, 9), p)
end

function T.test_offsetR_and_towards()
  local scope = rectScope()
  local a = Anchor.ref("C"):offsetR(1, -1) -- +R1 x, -R1 z
  local b = Anchor.ref("TR")
  local p = a:towards(b, 3):resolve(scope)

  local base = Vector(6, 1, -6)
  local dir = (Vector(9, 1, 9) - base); dir.y = 0; dir = dir:normalized() * 3
  lu.assertEquals(base + dir, p)
end

return T
