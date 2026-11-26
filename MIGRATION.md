# Upgrading from ratings_plus 1.x to 2.0

`RatingBarThemeData` now extends the `ThemeExtension` exported by `material_ui`.
Use the same Material library for the `MaterialApp` or `Theme` above a rating
widget so it reads your colors and theme extensions. This includes the
`ThemeData(extensions: ...)` registration and any explicit
`ThemeExtension<RatingBarThemeData>` annotations in your code.

## Migrate a Material app

Set `ratings_plus: ^2.0.0` in your app's `pubspec.yaml` and run
`flutter pub get`. On Flutter 3.50.1 (Dart 3.14.0), preview and apply the SDK
fix from the app directory.

```sh
dart fix --dry-run --code=migrate_design_widgets
dart fix --apply --code=migrate_design_widgets
```

The fix updates imports and can add `material_ui: any` to your app's
dependencies. If your app re-exports Material from a shared library, change its
`export` URI to `package:material_ui/material_ui.dart` too. An unfiltered
`dart fix --apply` also updates these exports on Dart 3.14.0.

If you need to support the full Flutter range of `ratings_plus`,
declare the following constraint. Review the diff and run your app's checks.

```sh
flutter pub add 'material_ui:>=0.0.1 <2.0.0'
flutter analyze
flutter test
```

If your SDK lacks the fix, add the same dependency and replace
`package:flutter/material.dart` with `package:material_ui/material_ui.dart` in
your Material imports and exports. Keep existing prefixes and `show` or `hide`
lists. Apps using localization delegates or dependencies that mix Material
libraries can follow [Flutter's migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).

## Keep using bundled Material

On Flutter 3.38.5 through releases before 3.44, Pub selects `material_ui`
0.0.1. This version re-exports `package:flutter/material.dart`, so both imports
refer to the same Material classes. You can update the import on your existing
SDK. [material_ui 0.0.1](https://pub.dev/packages/material_ui/versions/0.0.1)

If a newer Flutter app still needs bundled Material, you can temporarily pin
`material_ui: 0.0.1` in the app's dependencies and run `flutter pub get`,
provided the rest of its dependencies accept that version. On Flutter 3.50.1,
the SDK import then works with rating themes and emits a deprecation notice.
After migrating the app and packages that exchange Material types, loosen the
pin and run `flutter pub upgrade material_ui`.
