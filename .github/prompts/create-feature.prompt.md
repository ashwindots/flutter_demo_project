---
agent: agent
description: Scaffold a complete feature folder (controller / model / repo / view / widget) from acceptance criteria following project architecture standards.
argument-hint: "Feature name in snake_case, e.g. agent_earnings, customer_booking_detail"
---

# Create Feature

Feature: `${input:featureName}` | PascalCase: `${input:featurePascalName}` | Flow: `${input:parentFolder}`

## Acceptance Criteria

```
${input:acceptanceCriteria}
```

> **Before writing any code**, parse the acceptance criteria above and derive:
>
> | Concern                   | How to derive from AC                                                                                                                |
> | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
> | **Events**                | One event per user action or system trigger described (e.g. "user taps Book" → `SubmitBookingEvent`)                                 |
> | **State status variants** | One enum value per observable UI state beyond `initial/loading/success/error` (e.g. "show confirmation screen" → `bookingConfirmed`) |
> | **API calls**             | One repo method per data exchange described                                                                                          |
> | **Edge cases**            | Every "when X fails / empty / unauthorised" clause → error state + snackbar                                                          |
> | **Navigation**            | Each "navigates to …" clause → `NavigationService` call in `BlocListener`                                                            |
> | **Validation**            | Each "must / cannot / required" clause → guard in event handler before API call                                                      |

**Reference example** (read all files before coding):
[bloc](../../lib/features/business_flow/home/bloc/business_home_bloc.dart) · [event](../../lib/features/business_flow/home/bloc/business_home_event.dart) · [state](../../lib/features/business_flow/home/bloc/business_home_state.dart) · [repo](../../lib/features/business_flow/home/repo/business_home_repo.dart) · [view](../../lib/features/business_flow/home/view/business_home_view.dart) · [model](../../lib/features/business_flow/home/model/business_home_details_model.dart)

**Read before writing any string/colour/icon/style/route:**
[app_strings](../../lib/core/constants/app_strings.dart) · [app_colors](../../lib/core/constants/app_colors.dart) · [icons](../../lib/core/constants/icons.dart) · [font_styles](../../lib/core/constants/font_styles.dart) · [route_constants](../../lib/core/router/route_constants.dart) · [api_constants](../../lib/core/data/network/api_constants.dart) · [exports.dart](../../lib/core/router/exports.dart)

## Folder structure

```
lib/features/${input:parentFolder}/${input:featureName}/
├── controller/  ${input:featureName}_controller.dart
├── model/ ${input:featureName}_{request,response}_model.dart
├── repo/  ${input:featureName}_repo.dart
├── view/  ${input:featureName}_view.dart
└── widget/
```

## Per-file rules

**Bloc** – barrel import only; `part` both sibling files; constructor-inject repo (`?? ${input:featurePascalName}Repo()`); `on<E>(_handler)` per event; emit `loading` → try/catch → emit `success`/`error`; log with `DebugUtils.showPrint`; no navigation or UI calls.

**Event** – `part of` bloc; `@immutable sealed class ${input:featurePascalName}Event extends Equatable`; each event `@immutable final class <Verb><Noun>Event`; `props` for all fields.

**State** – `part of` bloc; `enum ${input:featurePascalName}Status { initial, loading, success, error }`; `@immutable` class, all `final` fields, `status` defaults to `initial`; full `copyWith`; `props`.

**Repo** – barrel import; constructor-inject `DioUtil ?? DioUtil()`; reads → `Future<T?>` (snackbar + return null on fail); writes → `Future<Result<T>>`; all paths from `ApiConfig`; `try/catch` + `DebugUtils.showPrint`.

**Models** – `@immutable`, all `final`; `fromJson` factory + `toJson`; null-safe defaults (`?? ''`, `?? 0`, `?? false`, `?? []`); nested objects as separate classes in the same file.

**View** – `BlocProvider` at root fires initial event; delegates to private `_${input:featurePascalName}Body`; `BlocListener` for side-effects, `BlocBuilder` for UI; `CommonScreenLayout` if standard header; every string → `AppStrings`, colour → `AppColors`, icon → `AppIcons`, text → `TextWidget`, button → `CommonButton` (fixed `.w` width), dims → ScreenUtil; extract logical sub-trees to `widget/` as `StatelessWidget` classes.

**Route** – add `static const` to `RouteConstants`; add `case` in `CustomRouter.generateRoute`; use `NavigationService().pushNamed(RouteConstants.${input:featureName})`.

**Exports** – add all cross-feature files to `exports.dart`.

**AC coverage check** – after generating all files, scan the acceptance criteria again and confirm every criterion is handled. If any criterion is not covered, implement it before finishing.

No `TODO` comments — implement minimally but completely.
