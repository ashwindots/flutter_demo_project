---
agent: agent
description: Generate a GetX Controller for an existing or new feature following project standards.
argument-hint: "Feature name in snake_case, e.g. agent_earnings, customer_booking_detail"
---

# Create GetX Controller

Feature: `${input:featureName}` | PascalCase: `${input:featurePascalName}`

**Reference:** [controller](../../lib/features/business_flow/home/controller/business_home_controller.dart) · [exports.dart](../../lib/core/router/exports.dart)

## File: `controller/${input:featureName}_controller.dart`

**Controller** – `import '../../../../core/router/exports.dart';` only; extend `GetxController`; inject repo via constructor (`?? ${input:featurePascalName}Repo()`); define observable state variables using `.obs`; use methods for actions (e.g., fetch, update, delete); handle async work with `Future<void>` methods; update state via `.value` or `.assign`; handle errors with try/catch and log using `DebugUtils.showPrint('${input:featurePascalName}Controller.<method> error: $e')`.

**Security:** Never store passwords, tokens, raw credentials, or payment secrets in controller state. Clear any sensitive field immediately after use by setting it to `''` or `null`.

Do not alter repo, view, or model files.
