# Spec: TTS Lua Runtime Testing Baseline

## Intent

Define baseline, testable behavior for in-sandbox verification using TTS-LuaUnit and checker-triggered execution.

## Baseline Scenarios

### BASE-001: Checker triggers test suite
Given checker object is dropped into the configured zone
When TTS script event fires for checker trigger
Then the configured test suite execution starts

### BASE-002: Test output appears in console
Given suite execution is started
When tests run to completion
Then pass or fail output is emitted to the TTS/Console++ output stream

### BASE-003: Failures are visible with test identity
Given at least one failing test exists
When suite execution completes
Then output includes failing test name and failure reason summary

### BASE-004: Passing suite produces summary
Given all tests pass
When suite execution completes
Then output includes a final pass summary for executed tests

## Notes

- This spec captures existing behavior before feature changes.
- Future changes should reference these baseline IDs in tasks.
