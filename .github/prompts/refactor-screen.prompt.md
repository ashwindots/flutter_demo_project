---
agent: agent
description: Refactor one or more screens to match project UI standards – remove all legacy code and replace with the canonical new implementation.
argument-hint: "Comma-separated file names to refactor, e.g. agent_home.dart, agent_profile_page.dart"
---

# Refactor Screen(s)

Target: `${input:targetFiles}`

**Canonical reference screens** (read before touching targets):
[login_view](../../lib/features/on_boarding/login/view/login_view.dart) · [business_home_view](../../lib/features/business_flow/home/view/business_home_view.dart) · [business_profile_view](../../lib/features/business_flow/profile/view/business_profile_view.dart)

**Read before writing:** [app_strings](../../lib/core/constants/app_strings.dart) · [app_colors](../../lib/core/constants/app_colors.dart) · [icons](../../lib/core/constants/icons.dart) · [font_styles](../../lib/core/constants/font_styles.dart) · [common_button](../../lib/core/components/common_button.dart) · [common_screen_layout](../../lib/core/utils/common_screen_layout.dart) · [route_constants](../../lib/core/router/route_constants.dart) · [exports](../../lib/core/router/exports.dart)

## Migration checklist (apply in order)

1. **Strings** → `AppStrings` (add constants if missing)
2. **Colours** → `AppColors`; no `.withOpacity()` — encode alpha in hex, add named constant
3. **Assets** → `AppIcons` (SVG migration done; all assets in `assets/svg/`)
4. **Typography** → named `FontStyles` constant (add if missing)
5. **Text** → `TextWidget` (no raw `Text(...)`)
6. **Buttons** → `CommonButton` with fixed `.w` width (no `double.infinity`)
7. **Dimensions** → ScreenUtil (`.h`, `.w`, `.sp`, `.r`); remove all `getScreenPercentSize` / `getScreenWidth` calls
8. **Navigation** → `NavigationService().pushNamed(RouteConstants.x)` (no `Navigator.of(context)`)
9. **Layout** → wrap with `CommonScreenLayout` if standard vector header
10. **Widget extraction** → `Widget _buildXxx` helpers → `StatelessWidget` classes in `widget/` folder
11. **Exports** → add new widget files to `exports.dart`
12. **Controller/API** → do NOT modify unless explicitly requested
13. **WebView URL validation** → if the screen contains a `WebViewController`, validate the target URL host against an allowlist derived from `ApiConfig` constants before calling `loadRequest`; reject disallowed hosts with `showSnackBar` instead of loading them

Visual UI must remain identical. Remove all legacy code.
