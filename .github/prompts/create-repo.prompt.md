---
agent: agent
description: Generate a Repository class for a feature using DioUtil and ApiConfig following project standards.
argument-hint: "Feature name in snake_case, e.g. agent_earnings, customer_booking_detail"
---

# Create Repository

Feature: `${input:featureName}` | PascalCase: `${input:featurePascalName}`
API calls needed: `${input:apiDescription}`

**Reference:** [business_home_repo.dart](../../lib/features/business_flow/home/repo/business_home_repo.dart) · [dio_util.dart](../../lib/core/data/network/dio_util.dart) · [api_constants.dart](../../lib/core/data/network/api_constants.dart) · [exports.dart](../../lib/core/router/exports.dart)

## File: `repo/${input:featureName}_repo.dart`

```dart
class ${input:featurePascalName}Repo {
  final DioUtil _dioUtil;
  ${input:featurePascalName}Repo({DioUtil? dioUtil}) : _dioUtil = dioUtil ?? DioUtil();
}
```

**GET methods** → `Future<T?>`: `_dioUtil.getApi(path: ApiConfig.x, isManageStatusCode: true)`; on `success == false` → `showSnackBar(..., SnackType.failed)` + return null; catch → snackbar + `DebugUtils.showPrint` + return null.

**POST/PUT/PATCH/DELETE** → `Future<Result<T>>`: on success → `Success(Model.fromJson(response!.dataMap!))`; on failure → `Failure(response?.message ?? ApiMsgStrings.somethingWentWrong)`; catch → `DebugUtils.showPrint` + `Failure(ApiMsgStrings.somethingWentWrong, error: e)`.

- All paths from `ApiConfig` (add `static const` if missing); method names start with a verb; `required` named params; no `rethrow`.
- **No self-recursion:** every method must terminate at a `DioUtil` or Firebase SDK call — never at a call to itself. Extract any shared logic into a distinctly-named private helper (e.g. `_buildRequestBody`).

Do not alter controller, view, or model files.
