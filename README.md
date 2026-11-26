# Ratings Plus

Collect and display fractional ratings in Flutter with custom item widgets, keyboard and pointer input, and form validation.

[![Pub Version](https://img.shields.io/pub/v/ratings_plus)](https://pub.dev/packages/ratings_plus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

*   **Versatile Modes**:
    *   **Interactive**: `RatingBar` for user input.
    *   **Read-only**: `RatingBarIndicator` for displaying static values.
    *   **Form Integration**: `RatingBar.form` for validation and easy form submission.
*   **Interaction Models**:
    *   **Controlled**: Parent manages state (like a standard Checkbox or Slider).
    *   **Uncontrolled**: Widget manages its own state, perfect for simple use cases.
*   **Precision Control**: Support for any fractional step (e.g., 0.5 for half-stars, 0.1 for precise values, or 0.0 for continuous).
*   **Gestures**:
    *   **Tap**: Precise selection.
    *   **Drag**: Smooth sliding selection.
    *   **Tap & Drag**: The best of both worlds.
*   **Input & Accessibility**:
    *   **Mouse Support**: Hover effects and custom cursors.
    *   **Keyboard Support**: Arrow keys, Home, End, and Page Up/Down navigation.
    *   **Semantics**: Interactive bars expose a value and adjustment actions. Indicators expose a read-only value.
*   **Customization**:
    *   **Builders**: Use any widget (Icons, Images, SVGs) for rated and unrated states.
    *   **Styling**: Custom colors, spacing, sizing, and glow effects.
    *   **Layout**: Vertical or Horizontal, with RTL support.
    *   **Theming**: Define global styles via `RatingBarThemeData`.

## Installation

The examples use `material_ui` for Material widgets and `ratings_plus` for the rating controls. Add both dependencies to your app.

```yaml
dependencies:
  material_ui: '>=0.0.1 <2.0.0'
  ratings_plus: ^2.0.0
```

The package supports Flutter 3.38.5 and later. Apps upgrading from 1.x should match their Material imports to the resolved `material_ui` version. [Migration guide](https://github.com/omar-hanafy/ratings_plus/blob/main/MIGRATION.md)

## Usage

```dart
import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';
```

### 1. Interactive Rating Bar

#### Uncontrolled (Stateful)
The simplest way to get started. The widget manages its own state.

```dart
RatingBar(
  initialValue: 3.5,
  onChanged: (value) {
    print('Rating updated: $value');
  },
  itemBuilder: (context, index) => const Icon(
    Icons.star,
    color: Colors.amber,
  ),
)
```

#### Controlled (Stateless)
For when you need full control over the state (e.g., Redux, BLoC, or parent state).

```dart
RatingBar(
  value: _myRating, // Sourced from parent state
  onChanged: (value) {
    setState(() => _myRating = value);
  },
  itemBuilder: (context, index) => const Icon(
    Icons.star,
    color: Colors.amber,
  ),
)
```

### 2. Read-only Indicator

Optimized for displaying averages or static reviews. It ignores input and is lightweight.

```dart
RatingBarIndicator(
  value: 3.7,
  itemCount: 5,
  itemSize: 24.0,
  itemBuilder: (context, index) => const Icon(
    Icons.star,
    color: Colors.amber,
  ),
)
```

### 3. Form Integration

Keep a `GlobalKey<FormState>` named `formKey` in the parent state. This form accepts ratings of one star or more. Clearing the selection returns it to zero.

```dart
Form(
  key: formKey,
  child: Column(
    children: [
      RatingBar.form(
        initialValue: 0.0,
        validator: (value) {
          if (value == null || value < 1.0) {
            return 'Please select a rating';
          }
          return null;
        },
        onSaved: (value) {
          // Save valid value
        },
        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
      ),
      ElevatedButton(
        onPressed: () {
          final form = formKey.currentState!;
          if (form.validate()) form.save();
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

## Interaction Lifecycle

Use the pointer callbacks to track a tap or drag from selection to completion.

* `onChangeStart` marks the start of a rating gesture.
* `onChanged` reports the selected value after a tap or as a drag crosses rating steps. Keyboard and accessibility adjustments also use this callback.
* `onChangeEnd` receives the final gesture value. If a parent scrollable cancels a pending tap, it receives the current rating.

```dart
RatingBar(
  onChanged: (val) => setState(() => _current = val),
  onChangeStart: (val) => _showPreview(val),
  onChangeEnd: (val) => _saveToDatabase(val),
  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
)
```

## Configuration

### Layout & Behavior

| Property | Default | Description |
|---|---|---|
| `direction` | `Axis.horizontal` | Layout direction (`Axis.horizontal` or `Axis.vertical`). |
| `verticalDirection` | `VerticalDirection.down` | Flow direction for vertical layouts (`down` or `up`). |
| `textDirection` | `Directionality` | LTR or RTL support. |
| `gestureMode` | `RatingGestureMode.tapAndDrag` | Interaction model: `tap`, `drag`, `tapAndDrag`, or `none`. |
| `step` | `1.0` | Value snap interval (set to `0.0` for continuous). |
| `minRating` | `0.0` | Minimum selectable value. |
| `maxRating` | `itemCount` | Maximum value (allows scaling, e.g., 5 items = 100 points). |
| `allowClear` | `true` | Whether tapping the current value resets it to `minRating`. |
| `enableKeyboard` | `true` | Enables arrow keys, Home/End for navigation. |
| `autofocus` | `false` | Whether to request focus on mount. |

### Visuals & Animations

| Property | Default | Description |
|---|---|---|
| `itemSize` | `40.0` | Size of each rating item (width and height). |
| `spacing` | `0.0` | Logical pixel spacing between items. |
| `unratedColor` | `ThemeData.disabledColor` | Color filter for unrated items (if no `unratedBuilder`). |
| `glow` | `true` | Show glow effect during interaction. |
| `glowColor` | `ColorScheme.primary` | Color of the touch glow. |
| `glowRadius` | `2.0` | Spread radius of the glow. |
| `animationDuration` | `150ms` | Duration for value change animations. |
| `animationCurve` | `Curves.easeOutCubic` | Curve for value change animations. |
| `enableHover` | `false` | Show rating preview on mouse hover (desktop/web). |
| `enableFeedback` | `true` | Request haptic feedback on discrete rating changes. |

## Global Theming

Add `RatingBarThemeData` to the `ThemeData.extensions` of your `material_ui` app. Individual widget properties take precedence.

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      RatingBarThemeData(
        itemSize: 32.0,
        spacing: 4.0,
        glowColor: Colors.amberAccent,
        unratedColor: Colors.grey,
        animationCurve: Curves.easeInOut,
      ),
    ],
  ),
  // ...
)
```

## Accessibility

Tab focuses an interactive rating bar when `enableKeyboard` is enabled. Arrow keys along the bar's axis adjust by one step, respecting RTL and vertical direction. Page Up and Page Down increase and decrease by one step. Home selects the minimum and End selects the maximum. Continuous ratings use one rating unit for keyboard and accessibility adjustments.

The control exposes its label, current value and adjustment actions to assistive technology. The default value text uses one decimal place, such as `3.5 / 5.0`. Set `semanticLabel` to identify the item being rated and `semanticValueFormatter` for localized wording or finer precision.

## License

MIT
