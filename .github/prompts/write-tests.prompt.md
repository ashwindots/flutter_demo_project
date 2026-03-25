---
agent: agent
description: Generate unit tests for a Controller, derived from acceptance criteria, following Arrange-Act-Assert standards.
argument-hint: "Controller file path, e.g. lib/features/business_flow/home/controller/business_home_controller.dart"
---

# Write Controller Tests

Controller under test: `${input:controllerFilePath}` (also read sibling repo and model files)

## Acceptance Criteria (source of truth for test cases)

```
${input:acceptanceCriteria}
```

> Map each AC clause to one or more test cases:
>
> - A "happy path" clause → test for correct state update
> - An "error / fail / empty" clause → test for error state
> - A "validates / prevents" clause → test for guards and validation
> - A "navigates to" clause → verify the state or method that triggers navigation

**Reference:** [agent_validation_test.dart](../../test/agent_validation_test.dart) · [exports.dart](../../lib/core/router/exports.dart)

**Output:** `test/features/<feature_path>/controller/<feature_name>_controller_test.dart`

## Rules

- Packages: `flutter_test`; mock repo with `mockito` (`@GenerateMocks`) or manual stub; inject via constructor: `FeatureController(repo: mockRepo)`
- `setUp` creates fresh controller + mock; `tearDown` calls any necessary cleanup
- Group by method: `group('MethodName', ...)` → test for state changes and side effects
- Variable prefixes: `mockRepo`, `inputXxx`, `mockXxx`, `actualXxx`, `expectedXxx`
- **Per handler, write tests derived from AC clauses first**, then fill gaps with the minimum 3 baseline tests:
  1. Happy path → correct state update
  2. Null/empty response → error state
  3. Exception thrown → error state with `ApiMsgStrings.somethingWentWrong`
- Assert on observable state variables only (no private fields)
- AAA structure; one behaviour per test; `const` test data where possible
- Add a `group('AC coverage', ...)` at the end naming every AC clause and the test that covers it

Do not alter any source files.
