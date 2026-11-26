## 2.0.0

* **`RatingBarThemeData` now extends `ThemeExtension` from `material_ui`.** This breaks theme registration in apps that mix bundled and standalone Material types. The migration guide covers both libraries and Flutter 3.38.5 support. [Migration guide](MIGRATION.md)
* Taps commit on release, so scrolling from the bar keeps the selected rating. Drags report each distinct selection even before a controlled parent rebuilds, and paint the last fractional fill when the pointer lifts.
* Hover uses the snap rule for the active gesture mode and gives way to keyboard and accessibility input. Small fractional steps and large rating scales preserve distinct selections.
* Interactive ratings expose one labeled slider to assistive technology. Keyboard changes honor the widget and theme feedback settings.
* Read-only indicators clamp negative values to zero. Selecting the minimum rating can now validate a form initialized below its minimum.

## 1.0.0

* Initial release of `ratings_plus`.
* Features:
  * Interactive `RatingBar` with tap and drag support.
  * Read-only `RatingBarIndicator`.
  * Fractional ratings (0.5, 0.1, etc.).
  * `RatingBar.form` for `Form` validation support.
  * Full keyboard accessibility and semantics support.
  * Mouse hover preview.
  * Global theming via `RatingBarThemeData`.
