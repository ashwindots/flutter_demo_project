---
agent: agent
description: End-to-end feature scaffold driven by acceptance criteria AND a Figma design. Orchestrates all sub-prompts in sequence to produce the complete controller/model/repo/view/widget/test suite.
argument-hint: "Feature name, Figma file key, Figma node ID, parent flow folder, acceptance criteria"
---

# End-to-End Feature

Feature: `${input:featureName}` | PascalCase: `${input:featurePascalName}` | Flow: `${input:parentFolder}`
Figma file key: `${input:figmaFileKey}`
Figma node ID: `${input:figmaNodeId}`

## Acceptance Criteria

```
${input:acceptanceCriteria}
```

---

## How this prompt works

This is an **orchestrator**. Each phase below delegates to a dedicated sub-prompt that owns
the detailed rules for that concern. Read each linked sub-prompt **in full** before executing
its phase — the rules there are the authoritative source of truth. Do not re-interpret or
relax them here.

Work through phases **strictly in order**. Do not start Phase N+1 until Phase N is complete.

---

## Phase 1 – Parse & Plan (no code)

Before touching any file:

1. **Derive the Feature Design Table from the AC** using the derivation rules in
   [create-feature.prompt.md](./create-feature.prompt.md) (the _Acceptance Criteria_ section).
   Produce:

   | #   | AC Clause | Controller method | State variable | Repo method | Edge case / guard |
   | --- | --------- | ---------- | -------------------- | ----------- | ----------------- |

2. **Fetch the Figma design** — call Figma MCP `get_figma_data`:
   - `fileKey`: `${input:figmaFileKey}`
   - `nodeId`: `${input:figmaNodeId}`

3. **Build the Design Token Map** using the token-extraction rules in
   [create-screen-from-figma.prompt.md](./create-screen-from-figma.prompt.md) (Steps 1–2).
   Produce:

   | Token type | Figma value | Project constant | Action (use / add) |
   | ---------- | ----------- | ---------------- | ------------------ |

4. **Download assets** via Figma MCP `download_figma_images` per the rules in
   [create-screen-from-figma.prompt.md](./create-screen-from-figma.prompt.md) (Step 2).

Present both tables. Do not proceed until both are complete.

---

## Phase 2 – Constants & Assets

Apply the token-mapping rules from
[create-screen-from-figma.prompt.md](./create-screen-from-figma.prompt.md) (Step 3).

Update: `AppColors`, `AppStrings`, `AppIcons`, `FontStyles`, `AppDimensions`, and
`pubspec.yaml` (new asset paths).

---

## Phase 3 – Models

Follow every rule in [create-model.prompt.md](./create-model.prompt.md).

Context:

- `modelName` → `${input:featurePascalName}`
- `modelFolderPath` → `lib/features/${input:parentFolder}/${input:featureName}/model/`
- API methods come from the _Repo method_ column of the Feature Design Table

---

## Phase 4 – Repository

Follow every rule in [create-repo.prompt.md](./create-repo.prompt.md).

Context:

- `featureName` → `${input:featureName}`
- `featurePascalName` → `${input:featurePascalName}`
- `apiDescription` → the _Repo method_ + _Edge case_ columns of the Feature Design Table

---

## Phase 5 – Bloc

Follow every rule in [create-bloc.prompt.md](./create-bloc.prompt.md).

Context:

- `featureName` → `${input:featureName}`
- `featurePascalName` → `${input:featurePascalName}`
- `eventDescription` → the full _Event name_ + _State status variant_ + _Edge case_ columns
  of the Feature Design Table

The State status enum must include every variant listed in the Feature Design Table in
addition to the baseline `initial, loading, success, error`.

---

## Phase 6 – View & Widgets

Follow the view-generation rules in
[create-screen-from-figma.prompt.md](./create-screen-from-figma.prompt.md) (Steps 4–5)
**combined with** the _View_ bullet in [create-feature.prompt.md](./create-feature.prompt.md)
(the _Per-file rules_ → View section).

Additional wiring from AC:

- Every _navigation_ clause → `BlocListener` branch calling `NavigationService`
- Every _UI state_ clause → `BlocBuilder` / `BlocSelector` branch
- Bloc events dispatched from the UI must match the Feature Design Table exactly

---

## Phase 7 – Route & Exports

Follow the _Route_ and _Exports_ bullets in
[create-feature.prompt.md](./create-feature.prompt.md) (the _Per-file rules_ section).

---

## Phase 8 – Tests

Follow every rule in [write-tests.prompt.md](./write-tests.prompt.md).

Context:

- `blocFilePath` → `lib/features/${input:parentFolder}/${input:featureName}/bloc/${input:featureName}_bloc.dart`
- `acceptanceCriteria` → (same AC provided at the top of this prompt)

Every row of the Feature Design Table must map to at least one `blocTest` case.

---

## Phase 9 – Security & Quality Gate

Run [security-review.prompt.md](./security-review.prompt.md) scoped to all files generated
or modified in Phases 2–8 (`targetScope` = the feature path, `recentChanges` = list of
created files). All 🔴 Critical findings must be resolved before the feature is considered
complete. All 🟠 High findings must be documented as follow-up issues.

Additionally verify:

- [ ] Every AC clause is covered by at least one test from Phase 8
- [ ] Every Figma token from Phase 1 is accessed through a project constant — no inlined values
- [ ] Every row of the Feature Design Table is implemented across Bloc, Repo, and View
- [ ] Full Code Style Checklist (all five pillars) in `copilot-instructions.md` passes

Do not end until all nine phases are complete and every checklist item passes.