


Project at a Glance
Concern	Solution used in this project
State management	flutter_bloc (Bloc + Cubit)
State immutability	Manual copyWith + Equatable
Dependency injection	Constructor injection in Blocs; repos use DioUtil() singleton
Navigation	NavigationService singleton + CustomRouter.generateRoute
Networking	DioUtil (Dio wrapper) + ApiConfig constants
Storage	SharedPreferenceHelper + PrefData
Routing constants	RouteConstants (not AppRoutes)
String constants	AppStrings
Icon/asset constants	AppIcons
Colour constants	AppColors
Barrel import	import '../../../../core/router/exports.dart';

Dart / Flutter General Rules
Language
Write all code and documentation in English.
Always declare explicit types for variables, parameters, and return values. Avoid dynamic or var unless unavoidable.
Use final for everything that does not reassign.
Prefer const constructors and widget instantiations wherever possible.

Naming
Entity	Convention	Example
Classes	PascalCase	BusinessHomeBloc
Variables / functions / methods	camelCase	fetchBusinessProfile()
Files and directories	snake_case	business_home_bloc.dart
Constants (compile-time)	SCREAMING_SNAKE_CASE inside dedicated constant classes	AppStrings.appName
Boolean variables	Verb prefix	isLoading, hasError, canDelete
Start every method/function name with a descriptive verb (fetch, load, create, update, delete, build, handle, navigate, show…).
Use complete words; abbreviate only established terms (API, URL, OTP, FCM, DIO).

Functions & Methods
Keep functions < 20 statements; extract helpers when a function grows beyond that.
Use early returns instead of deeply nested if/else blocks.
Prefer named parameters with required when a function accepts multiple arguments.
Avoid blank lines within a function body; group logic with a single blank line between logical sections at the top level only.

Classes
Follow SOLID principles.
A single class should have one responsibility.
Prefer composition over inheritance.
Keep classes < 200 lines with < 10 public methods.

Feature-First Architecture
Every feature lives under lib/features/<feature_name>/ and follows this structure:

features/
└── feature_name/
		├── bloc/          # Bloc + Event + State (split into separate part files)
		├── model/         # Request/response DTOs  (fromJson / toJson)
		├── repo/          # Repository – wraps DioUtil or Firebase calls
		├── view/          # Page widgets (one per route)
		└── widget/        # Small, reusable widgets scoped to this feature

Shared code lives in lib/core/:

core/
├── components/   # Reusable UI widgets (buttons, dialogs…)
├── constants/    # AppStrings, AppColors, AppIcons, AppDimensions, enums
├── data/
│   ├── network/  # DioUtil, ApiConfig, ApiResponse, ResponseExtension
│   └── shared_preferences/
├── models/       # Cross-feature domain models (e.g. UserModel)
├── router/       # CustomRouter, RouteConstants, exports.dart (barrel)
├── services/     # NavigationService, PushNotificationService, PaymentService
├── theme/        # AppThemeExtension
├── types/        # Result<T>, Success<T>, Failure<T>
└── utils/        # DebugUtils, ApplicationUtils, DialogMixin, SnackBar helpers

Important: always import via the barrel file:

import '../../../../core/router/exports.dart';

Bloc Pattern
File Layout
Each Bloc is split into three part files:

feature/bloc/
├── feature_bloc.dart   ← Bloc class (imports exports.dart, declares parts)
├── feature_event.dart  ← Events  (part of 'feature_bloc.dart')
└── feature_state.dart  ← State   (part of 'feature_bloc.dart')

State
Base state extends Equatable.
Use an enum for status (initial, loading, success, error, and any domain-specific variants like verificationPending).
Provide a copyWith method for every field.
Override List<Object?> get props to include every field.
Annotate with @immutable and declare as final class for leaf states.
Do not use Freezed (the project does not depend on it).

Events
Use @immutable final class for every event.
Name events as <Verb><Noun>Event: LoadBusinessHomeDataEvent, SubmitLoginEvent.

Bloc Class
Register handlers in the constructor with on<EventType>(_handlerMethod).
Name private handlers _on<EventName>: _onLoadFooItems.
Always emit(state.copyWith(status: FooStatus.loading)) before async work.
Handle errors in try/catch; emit an error state with the message.
Do not perform navigation or show dialogs inside a Bloc; dispatch events and react via BlocListener in the UI.

Repository Pattern
Each repository wraps DioUtil (or Firebase SDK) calls.
Inject DioUtil via the constructor (with a default fallback) so repos are testable: dart class FooRepo { final DioUtil _dioUtil; FooRepo({DioUtil? dioUtil}) : _dioUtil = dioUtil ?? DioUtil(); }
For create / update / delete operations return Result<T> (Success<T> / Failure).
For read operations that can silently fail, returning T? (nullable) is acceptable.
Always call showSnackBar() on failure before returning null.
Always wrap network calls in try/catch; log with DebugUtils.showPrint().
Never rethrow unless the caller is designed to handle it.

Models (DTOs)
Place request models in feature/model/ named <Noun>RequestModel.
Place response models in feature/model/ named <Noun>ResponseModel.
Implement factory <Model>.fromJson(Map<String, dynamic> json) and Map<String, dynamic> toJson().
Use ?? '', ?? 0, ?? false, ?? [] for nullable JSON fields.
Mark models with @immutable and make all fields final.

Navigation
Use NavigationService for all programmatic navigation.
Use RouteConstants — not AppRoutes — for route name strings.
Pass typed argument objects, not raw Maps.

UI / Widgets
Page vs. Widget
Break complex build methods into small, private widget classes (not helper methods returning Widget).
Use BlocBuilder for state-driven UI; use BlocListener for side-effects (navigation, snack bars, dialogs).
Use BlocConsumer only when both building and listening are needed in the same scope.
Prefer context.read<Bloc>() for dispatching events from callbacks.
Prefer context.watch<Bloc>().state or BlocSelector for reading specific state slices.

General Widget Rules
All widgets must use const constructors where possible.
Use flutter_screenutil (16.w, 20.h, 14.sp) for all dimensions and font sizes. Never use MediaQuery for sizing.
Use AppColors for every colour value; never hard-code hex/RGB. Never use .withOpacity() — encode alpha into the hex value and add a named constant.
Use AppStrings for every user-facing string.
Use AppIcons for every asset path (SVG assets live in assets/svg/).
All TextStyles must use named FontStyles constants from lib/core/constants/font_styles.dart; no inline TextStyle(...).
Use TextWidget (lib/core/utils/text_widget.dart) for all text — no raw Text(...) in screen code.
All tappable buttons must use CommonButton (lib/core/components/common_button.dart) with a fixed .w width — never double.infinity.
Wrap screens that need the standard header/background in CommonScreenLayout (lib/core/utils/common_screen_layout.dart).
Use CachedNetworkImage (with errorWidget) for all remote images.
Never use print(); use DebugUtils.showPrint().
Use showSnackBar(message, SnackType.success/failed) for user feedback.
Keep widget trees shallow: extract logical sub-trees into StatelessWidget classes in widget/.
Always pass a key to list items.

Error Handling & Result Type
The project exposes Result<T>, Success<T>, and Failure in core/types/. Use them for any operation that can meaningfully fail and whose caller must differentiate success from failure. Switch on the result in the Bloc handler: Success(:final data) emits a success state; Failure(:final message) emits an error state with that message.

Firebase Guidelines
Use FirebaseAuth.instance for authentication; never store tokens manually beyond what SharedPreferenceHelper.saveAuthToken() already does.
Use FirebaseStorage.instance for file uploads; always include the authenticated UID in the storage path: images/$uid/<feature>/<uuid>/<filename>.
Delete the old storage object before uploading a replacement.
Wrap every Firebase SDK call in try/catch; log with DebugUtils.showPrint().
Use FirebaseMessaging only through PushNotificationService.

Security
These rules apply to every file generated or modified in this project.

Secrets & Keys
Never hardcode API keys, DSNs, tokens, or secrets in Dart source, platform manifests, or strings.xml. Inject all secrets at build time via --dart-define=KEY=value and read them with String.fromEnvironment('KEY').
Never add a Stripe secret key or any payment-processor secret anywhere on the client. Only publishable keys and server-issued client secrets are permitted on device.
All platform API keys (Google Maps, Firebase, etc.) must have application restrictions applied in their respective developer consoles (Android package name / iOS bundle ID).

Local Storage
Use flutter_secure_storage for all security-sensitive values: auth token, refresh token, user email, and any government/identity identifiers.
Use SharedPreferenceHelper only for non-sensitive app state flags (theme, notification toggles, onboarding steps).
Never store a password, card number, or credential in SharedPreferences or in Bloc state.

Bloc State
Bloc state must not include passwords, raw credentials, or payment secrets as fields.
Clear any credential field immediately after the event handler that consumed it by emitting a copyWith with the field set to '' or null.

WebView
Every WebViewController.loadRequest call must validate the URL against a domain allowlist derived from ApiConfig constants before loading. Reject any URL whose host is not in the allowlist and show a showSnackBar error instead.

Network
All API communication must use HTTPS. Never add a cleartext exception to network_security_config.xml without explicit security review.
Never disable certificate validation (badCertificateCallback: (_,__,___) => true).
Environment-specific base URLs must be constants in ApiConfig; switching environments is done only by changing ApiConfig.baseUrl — never by conditionals scattered in feature code.

Fallback / Placeholder Data
Fallback image URLs and placeholder data must reference ApiConfig domain constants — never hardcode a UAT or dev hostname in a repo, bloc, or view file.

Reliability
Repository Methods
Every repository method must terminate at a DioUtil or Firebase SDK call. A method must never call itself (no self-recursion). If shared logic is needed, extract it to a private helper method with a different name.
Pin every third-party Gradle/CocoaPods dependency to an explicit version — never use latest.release or an open version range. Unpinned dependencies cause non-deterministic builds.
Pin all pubspec.yaml dependencies to a concrete version range (^x.y.z). Never leave a line as null or without a version.

Error Handling
Every async function that calls a network or Firebase method must have a try/catch. Do not let exceptions surface uncaught to the Flutter framework.


GitHub Copilot Instructions (Flutter/Dart)

You are a senior Dart/Flutter engineer working on this Flutter project. Adhere to all conventions already established in the codebase when generating, correcting, or refactoring code.

## Project at a Glance

| Concern              | Solution used in this project                       |
|----------------------|----------------------------------------------------|
| State management     | flutter_bloc (Bloc + Cubit)                        |
| State immutability   | Manual copyWith + Equatable                        |
| Dependency injection | Constructor injection in Blocs; repos use DioUtil() singleton |
| Navigation           | NavigationService singleton + CustomRouter.generateRoute |
| Networking           | DioUtil (Dio wrapper) + ApiConfig constants        |
| Storage              | SharedPreferenceHelper + PrefData                  |
| Routing constants    | RouteConstants (not AppRoutes)                     |
| String constants     | AppStrings                                         |
| Icon/asset constants | AppIcons                                           |
| Colour constants     | AppColors                                          |
| Barrel import        | import '../../../../core/router/exports.dart';     |

## Dart / Flutter General Rules

- Write all code and documentation in English.
- Always declare explicit types for variables, parameters, and return values. Avoid dynamic or var unless unavoidable.
- Use final for everything that does not reassign.
- Prefer const constructors and widget instantiations wherever possible.

### Naming

| Entity                | Convention                                   | Example                       |
|-----------------------|----------------------------------------------|-------------------------------|
| Classes               | PascalCase                                   | BusinessHomeBloc              |
| Variables/functions   | camelCase                                    | fetchBusinessProfile()        |
| Files/directories     | snake_case                                   | business_home_bloc.dart       |
| Constants             | SCREAMING_SNAKE_CASE inside constant classes | AppStrings.appName            |
| Boolean variables     | Verb prefix                                  | isLoading, hasError, canDelete|

- Start every method/function name with a descriptive verb (fetch, load, create, update, delete, build, handle, navigate, show…).
- Use complete words; abbreviate only established terms (API, URL, OTP, FCM, DIO).

### Functions & Methods
- Keep functions < 20 statements; extract helpers when a function grows beyond that.
- Use early returns instead of deeply nested if/else blocks.
- Prefer named parameters with required when a function accepts multiple arguments.
- Avoid blank lines within a function body; group logic with a single blank line between logical sections at the top level only.

### Classes
- Follow SOLID principles.
- A single class should have one responsibility.
- Prefer composition over inheritance.
- Keep classes < 200 lines with < 10 public methods.

## Feature-First Architecture

Every feature lives under `lib/features/<feature_name>/` and follows this structure:

```
features/
└── feature_name/
	├── bloc/          # Bloc + Event + State (split into separate part files)
	├── model/         # Request/response DTOs  (fromJson / toJson)
	├── repo/          # Repository – wraps DioUtil or Firebase calls
	├── view/          # Page widgets (one per route)
	└── widget/        # Small, reusable widgets scoped to this feature
```

Shared code lives in `lib/core/`:

```
core/
├── components/   # Reusable UI widgets (buttons, dialogs…)
├── constants/    # AppStrings, AppColors, AppIcons, AppDimensions, enums
├── data/
│   ├── network/  # DioUtil, ApiConfig, ApiResponse, ResponseExtension
│   └── shared_preferences/
├── models/       # Cross-feature domain models (e.g. UserModel)
├── router/       # CustomRouter, RouteConstants, exports.dart (barrel)
├── services/     # NavigationService, PushNotificationService, PaymentService
├── theme/        # AppThemeExtension
├── types/        # Result<T>, Success<T>, Failure<T>
└── utils/        # DebugUtils, ApplicationUtils, DialogMixin, SnackBar helpers
```

**Important:** always import via the barrel file:

```dart
import '../../../../core/router/exports.dart';
```

## Bloc Pattern

### File Layout
Each Bloc is split into three part files:

```
feature/bloc/
├── feature_bloc.dart   ← Bloc class (imports exports.dart, declares parts)
├── feature_event.dart  ← Events  (part of 'feature_bloc.dart')
└── feature_state.dart  ← State   (part of 'feature_bloc.dart')
```

### State
- Base state extends Equatable.
- Use an enum for status (initial, loading, success, error, and any domain-specific variants like verificationPending).
- Provide a copyWith method for every field.
- Override List<Object?> get props to include every field.
- Annotate with @immutable and declare as final class for leaf states.
- Do not use Freezed (the project does not depend on it).

### Events
- Use @immutable final class for every event.
- Name events as <Verb><Noun>Event: LoadBusinessHomeDataEvent, SubmitLoginEvent.

### Bloc Class
- Register handlers in the constructor with on<EventType>(_handlerMethod).
- Name private handlers _on<EventName>: _onLoadFooItems.
- Always emit(state.copyWith(status: FooStatus.loading)) before async work.
- Handle errors in try/catch; emit an error state with the message.
- Do not perform navigation or show dialogs inside a Bloc; dispatch events and react via BlocListener in the UI.

## Repository Pattern
- Each repository wraps DioUtil (or Firebase SDK) calls.
- Inject DioUtil via the constructor (with a default fallback) so repos are testable: `class FooRepo { final DioUtil _dioUtil; FooRepo({DioUtil? dioUtil}) : _dioUtil = dioUtil ?? DioUtil(); }`
- For create / update / delete operations return Result<T> (Success<T> / Failure).
- For read operations that can silently fail, returning T? (nullable) is acceptable.
- Always call showSnackBar() on failure before returning null.
- Always wrap network calls in try/catch; log with DebugUtils.showPrint().
- Never rethrow unless the caller is designed to handle it.

## Models (DTOs)
- Place request models in feature/model/ named <Noun>RequestModel.
- Place response models in feature/model/ named <Noun>ResponseModel.
- Implement factory <Model>.fromJson(Map<String, dynamic> json) and Map<String, dynamic> toJson().
- Use ?? '', ?? 0, ?? false, ?? [] for nullable JSON fields.
- Mark models with @immutable and make all fields final.

## Navigation
- Use NavigationService for all programmatic navigation.
- Use RouteConstants — not AppRoutes — for route name strings.
- Pass typed argument objects, not raw Maps.

## UI / Widgets

### Page vs. Widget
- Break complex build methods into small, private widget classes (not helper methods returning Widget).
- Use BlocBuilder for state-driven UI; use BlocListener for side-effects (navigation, snack bars, dialogs).
- Use BlocConsumer only when both building and listening are needed in the same scope.
- Prefer context.read<Bloc>() for dispatching events from callbacks.
- Prefer context.watch<Bloc>().state or BlocSelector for reading specific state slices.

### General Widget Rules
- All widgets must use const constructors where possible.
- Use flutter_screenutil (16.w, 20.h, 14.sp) for all dimensions and font sizes. Never use MediaQuery for sizing.
- Use AppColors for every colour value; never hard-code hex/RGB. Never use .withOpacity() — encode alpha into the hex value and add a named constant.
- Use AppStrings for every user-facing string.
- Use AppIcons for every asset path (SVG assets live in assets/svg/).
- All TextStyles must use named FontStyles constants from lib/core/constants/font_styles.dart; no inline TextStyle(...).
- Use TextWidget (lib/core/utils/text_widget.dart) for all text — no raw Text(...) in screen code.
- All tappable buttons must use CommonButton (lib/core/components/common_button.dart) with a fixed .w width — never double.infinity.
- Wrap screens that need the standard header/background in CommonScreenLayout (lib/core/utils/common_screen_layout.dart).
- Use CachedNetworkImage (with errorWidget) for all remote images.
- Never use print(); use DebugUtils.showPrint().
- Use showSnackBar(message, SnackType.success/failed) for user feedback.
- Keep widget trees shallow: extract logical sub-trees into StatelessWidget classes in widget/.
- Always pass a key to list items.

## Error Handling & Result Type
- The project exposes Result<T>, Success<T>, and Failure in core/types/. Use them for any operation that can meaningfully fail and whose caller must differentiate success from failure. Switch on the result in the Bloc handler: Success(:final data) emits a success state; Failure(:final message) emits an error state with that message.

## Firebase Guidelines
- Use FirebaseAuth.instance for authentication; never store tokens manually beyond what SharedPreferenceHelper.saveAuthToken() already does.
- Use FirebaseStorage.instance for file uploads; always include the authenticated UID in the storage path: images/$uid/<feature>/<uuid>/<filename>.
- Delete the old storage object before uploading a replacement.
- Wrap every Firebase SDK call in try/catch; log with DebugUtils.showPrint().
- Use FirebaseMessaging only through PushNotificationService.

## Security
These rules apply to every file generated or modified in this project.

### Secrets & Keys
- Never hardcode API keys, DSNs, tokens, or secrets in Dart source, platform manifests, or strings.xml. Inject all secrets at build time via --dart-define=KEY=value and read them with String.fromEnvironment('KEY').
- Never add a Stripe secret key or any payment-processor secret anywhere on the client. Only publishable keys and server-issued client secrets are permitted on device.
- All platform API keys (Google Maps, Firebase, etc.) must have application restrictions applied in their respective developer consoles (Android package name / iOS bundle ID).

### Local Storage
- Use flutter_secure_storage for all security-sensitive values: auth token, refresh token, user email, and any government/identity identifiers.
- Use SharedPreferenceHelper only for non-sensitive app state flags (theme, notification toggles, onboarding steps).
- Never store a password, card number, or credential in SharedPreferences or in Bloc state.

### Bloc State
- Bloc state must not include passwords, raw credentials, or payment secrets as fields.
- Clear any credential field immediately after the event handler that consumed it by emitting a copyWith with the field set to '' or null.

### WebView
- Every WebViewController.loadRequest call must validate the URL against a domain allowlist derived from ApiConfig constants before loading. Reject any URL whose host is not in the allowlist and show a showSnackBar error instead.

### Network
- All API communication must use HTTPS. Never add a cleartext exception to network_security_config.xml without explicit security review.
- Never disable certificate validation (badCertificateCallback: (_,__,___) => true).
- Environment-specific base URLs must be constants in ApiConfig; switching environments is done only by changing ApiConfig.baseUrl — never by conditionals scattered in feature code.

### Fallback / Placeholder Data
- Fallback image URLs and placeholder data must reference ApiConfig domain constants — never hardcode a UAT or dev hostname in a repo, bloc, or view file.

## Reliability

### Repository Methods
- Every repository method must terminate at a DioUtil or Firebase SDK call. A method must never call itself (no self-recursion). If shared logic is needed, extract it to a private helper method with a different name.
- Pin every third-party Gradle/CocoaPods dependency to an explicit version — never use latest.release or an open version range. Unpinned dependencies cause non-deterministic builds.
- Pin all pubspec.yaml dependencies to a concrete version range (^x.y.z). Never leave a line as null or without a version.

### Error Handling
- Every async function that calls a network or Firebase method must have a try/catch. Do not let exceptions surface uncaught to the Flutter framework.
- Emit an error state with ApiMsgStrings.somethingWentWrong — never expose raw exception messages to the UI.
- A Failure result or a null response from a repo method is a normal code path; handle it explicitly, do not throw.

### State Consistency
- Always emit loading as the first state transition inside an async Bloc handler.
- Always emit a terminal state (success or error) in every code path, including the catch block. Never leave the Bloc in a loading state after an exception.

## Maintainability

### Single Source of Truth
- One constant class per concern: strings → AppStrings, colours → AppColors, icons → AppIcons, dimensions → AppDimensions, routes → RouteConstants, endpoints → ApiConfig. Adding a value anywhere else is not allowed.
- Feature-specific constants that will never be shared may live in the feature's folder but must still be grouped in a dedicated constants.dart file inside that feature — never inlined in widget or bloc code.

### Dependency Direction
- Features must not import each other. Shared models and services live in core/.
- Blocs must not import views or widgets. Views import Blocs, not the other way around.
- Repos must not import Blocs or views.

### Code Size Limits
- Files: < 300 lines. If a file exceeds this, split it.
- Functions / methods: < 20 statements. Extract helpers at that boundary.
- Classes: < 200 lines, < 10 public methods.

### Environment Switching
- The active environment (dev / UAT / live) must be controllable from a single place: ApiConfig.baseUrl. The build pipeline (not a developer) is responsible for setting this before a release build. Never merge code where baseUrl is hardcoded to devUrl or uatUrl.

## Coverage

### What Must Be Tested
- Every public Bloc event handler must have a corresponding blocTest.
- Every repo method that has branching logic (success path, null/empty path, exception path) must be covered by unit tests.
- Every AC clause written for a feature maps to at least one test. Use the group('AC coverage', ...) pattern from write-tests.prompt.md to make this traceable.
- Use flutter_test + bloc_test; follow Arrange–Act–Assert; name variables with prefixes input, mock, actual, expected.
- Mock repositories via constructor injection; never use real network calls in tests.

### Minimum per Handler
- For each Bloc event handler, write at minimum:
	- Happy path → emits [loading, success]
	- Null / empty API response → emits [loading, error] with ApiMsgStrings.somethingWentWrong
	- Exception thrown → emits [loading, error] with ApiMsgStrings.somethingWentWrong

### Test Isolation
- Mock all repo dependencies via constructor injection; never mock DioUtil directly in Bloc tests.
- Never use real network calls in unit tests.
- Use const test data wherever possible.

## Duplication

### Check Before Creating
- Before adding a new constant, widget, repo method, or model class, search the codebase for an existing equivalent. Reuse it; do not create a duplicate with a slightly different name.
- Before adding a new endpoint constant to ApiConfig, verify it does not already exist under a similar name.

### Shared Components
- If the same UI pattern appears in more than one feature, it belongs in core/components/ as a shared widget, not copied into each feature's widget/ folder.
- If the same business logic appears in more than one Bloc, it belongs in a shared service in core/services/ or a shared repo method in core/data/.

### Model Consolidation
- A domain model that is used by more than one feature belongs in core/models/. Do not duplicate it as separate per-feature DTOs unless the API shape genuinely differs.

## Constants Reference

| Class         | File                                 | Purpose                        |
|-------------- |--------------------------------------|--------------------------------|
| AppStrings    | core/constants/app_strings.dart       | All user-facing strings        |
| AppColors     | core/constants/app_colors.dart        | All colour values              |
| AppIcons      | core/constants/icons.dart             | SVG/PNG asset paths            |
| AppDimensions | core/constants/app_dimensions.dart    | Spacing/size constants         |
| RouteConstants| core/router/route_constants.dart      | Navigation route strings       |
| ApiConfig     | core/data/network/api_constants.dart  | API base URLs and endpoints    |
| ApiMsgStrings | core/data/network/…                  | API error/success message strs |

Always add new constant values to the appropriate constants class rather than inlining them.

## Automation Workflow – Prompt Files

Use the prompt files in `.github/prompts/` as the entry point for all structured work. Choose the right prompt based on the inputs available:

| Inputs available                        | Prompt to use                       |
|-----------------------------------------|-------------------------------------|
| Feature name only                       | create-feature.prompt.md            |
| Feature name + Acceptance Criteria      | create-feature.prompt.md (fill AC)  |
| Figma URL + node ID only                | create-screen-from-figma.prompt.md  |
| Figma URL + AC + full feature scope     | create-feature-e2e.prompt.md        |
| Existing Bloc, need tests               | write-tests.prompt.md (supply AC)   |
| Bloc or Repo only                       | create-bloc.prompt.md / create-repo.prompt.md |
| Model DTOs from JSON                    | create-model.prompt.md              |
| Screen needing migration to standards   | refactor-screen.prompt.md           |
| Pre-release or post-feature security/quality audit | security-review.prompt.md |
