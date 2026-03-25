---
agent: agent
description: Generate a Flutter screen (view + widgets) by reading a Figma design node via Figma MCP and mapping it to project constants.
argument-hint: "Figma file URL, node ID, and the target feature path"
---

# Create Screen from Figma

Feature: `${input:featureName}` | PascalCase: `${input:featurePascalName}` | Flow: `${input:parentFolder}`
Figma file key: `${input:figmaFileKey}` (the alphanumeric key from the Figma URL)
Figma node ID: `${input:figmaNodeId}` (the `node-id` query param, e.g. `1234:5678`)

---

## Step 1 – Fetch the Figma design

Use the Figma MCP tool `get_figma_data` with:

- `fileKey`: `${input:figmaFileKey}`
- `nodeId`: `${input:figmaNodeId}`

Read the full response carefully. Extract:

| What to extract   | Where to look in the response                                                                 |
| ----------------- | --------------------------------------------------------------------------------------------- |
| Screen dimensions | `absoluteBoundingBox` on the frame node                                                       |
| Background colour | `fills[0].color` on the frame                                                                 |
| Every text layer  | `characters` + `style.fontSize`, `style.fontWeight`, `style.letterSpacing`                    |
| Every colour used | `fills[0].color` on shapes/icons/backgrounds (RGBA 0–1 range, convert to hex)                 |
| Every image/icon  | nodes whose `type == "VECTOR"` or `type == "INSTANCE"` – download via `download_figma_images` |
| Spacing / padding | `paddingLeft`, `paddingRight`, `paddingTop`, `paddingBottom`, `itemSpacing`                   |
| Border radius     | `cornerRadius`                                                                                |
| Component names   | `name` field on INSTANCE nodes                                                                |

---

## Step 2 – Download images and icons

For every VECTOR or image node found, call `download_figma_images` with:

- Download SVGs (vectors/icons) to `assets/svg/`
- Download PNGs (photos/illustrations) to `assets/images/`
- Filename: snake_case of the Figma layer name

After downloading, add each new asset path as a `static const String` to `AppIcons`
(`lib/core/constants/icons.dart`) if it does not already exist there.

---

## Step 3 – Map design tokens to project constants

Apply the token-mapping rules from `copilot-instructions.md` (sections:
**Colours → `AppColors`**, **Typography → `FontStyles`**, **Assets → `AppIcons`**,
**Strings → `AppStrings`**, **Dimensions → `flutter_screenutil`**).

Key conversion rules (Figma-specific, not repeated elsewhere):

- Figma RGBA floats (0–1) → 8-digit hex `#AARRGGBB`; search `AppColors` before adding
- Figma px → ScreenUtil: base width 375 for `.w`, base height for `.h`
- Never add a duplicate constant; never inline a value

---

## Step 4 – Generate the view file

Output: `lib/features/${input:parentFolder}/${input:featureName}/view/${input:featureName}_view.dart`

Follow the **View** rules in [create-feature.prompt.md](./create-feature.prompt.md)
(the _Per-file rules_ → View section).

Figma-specific additions:

- Reconstruct the visual hierarchy from the Figma layer tree (frame → groups → components)
- Map each major layer group to a `StatelessWidget` class in `widget/`
- Use `CommonScreenLayout` if the Figma frame contains the standard project header/background vector

---

## Step 5 – Generate widget classes

Output: `lib/features/${input:parentFolder}/${input:featureName}/widget/`

Follow the **Widget extraction** rules in [create-feature.prompt.md](./create-feature.prompt.md)
(UI Migration Standards → rule 11).

Figma-specific additions:

- One file per logical section visible in the Figma design (header card, list tile, summary row, etc.)
- Use `CachedNetworkImage` with `errorWidget` for any remote image placeholder in the design

---

## Step 6 – Final checks

Run through the full Code Style Checklist in `copilot-instructions.md` and confirm each item
passes. Also verify:

- [ ] All downloaded assets declared in `pubspec.yaml` under `flutter.assets`
- [ ] All new constants added to `exports.dart` if cross-feature access is needed
- [ ] Generated screen matches the Figma frame pixel-for-pixel at the design base size

Do not modify Bloc, repo, model, or route files unless new assets require `AppIcons` / `AppStrings` additions.
