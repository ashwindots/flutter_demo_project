---
agent: agent
description: Generate request and/or response DTO model classes from a JSON payload following project standards.
argument-hint: "Model name in PascalCase, e.g. AgentEarnings, CustomerBookingDetail"
---

# Create Model(s)

Model name (PascalCase, no suffix): `${input:modelName}`
Folder: `${input:modelFolderPath}`

Request JSON (leave empty if none):

```json
${input:requestJson}
```

Response JSON (full payload with `success`/`data`/`message`):

```json
${input:responseJson}
```

**Reference:** [business_home_details_model.dart](../../lib/features/business_flow/home/model/business_home_details_model.dart) · [exports.dart](../../lib/core/router/exports.dart)

## Files

- `${input:modelName}_request_model.dart` (skip if no request body)
- `${input:modelName}_response_model.dart`

## Rules

- Barrel import only (adjust depth); `@immutable`; all fields `final`
- `factory fromJson(Map<String, dynamic>)` + `toJson()`; null-safe defaults (`?? ''`, `?? 0`, `?? false`, `?? []`)
- Never declare a field as `dynamic` — cast all JSON values explicitly to their concrete type
- Nested JSON objects → separate `@immutable` class in same file, named after JSON key in PascalCase
- JSON arrays → `List<ItemType>` via `for` loop calling `.fromJson` per item
- **Request model** – only fields sent to API; `toJson` is primary; `fromJson` optional
- **Response model** – top level: `bool? success`, `String? message`, typed `data` field (dedicated class, not raw `Map`); implement both `fromJson` and `toJson`
- Add to `exports.dart` if cross-feature access needed

Do not alter Bloc, repo, or view files.
