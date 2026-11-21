# Transport Freighter tests

The local regression script mirrors the production path. Run it from the repo root:

```bash
lua TTS_xwing/src/Test/Game/HotAC/Setup/TransportFreighter_Local_Test.lua
```

For the LuaUnit-TTS integration tests:

1. Update the Transport Freighter stored in the Extra Assets bag from the current
   `Game/HotAC/Setup/TransportFreighter.lua`. Leave it empty and in the bag;
   no freighter needs to be placed on the table.
2. Enable `require("Test.GlobalSuite")` at the end of `Global.lua`, bundle,
   and use Save & Play. The transport tests are registered in `GlobalSuite.lua`.
3. Drop the Checker with `TestMain.lua` attached, and inspect the Global suite
   results after LuaUnit-TTS finishes.

The TTS tests spawn separate copies from the bagged freighter's saved object
data, reset only each test copy's manifest, and create temporary blocks. They
never call `packObjects` on an empty manifest, which would collect every
eligible object on the live table. Cleanup removes only the test copies and
blocks; the Extra Assets bag and its template are untouched.

The local script covers bowl/marble packing order and simulated failure/retry
paths. The TTS tests exercise real object calls, container behavior, saved
state, exclusions, deployment, and cleanup. They require live TTS output for
a pass claim; a successful bundle alone is not a completed test run.
