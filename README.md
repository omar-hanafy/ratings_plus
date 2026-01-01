# Ratings Plus

A modern, high-performance, and accessible rating bar for Flutter.

`ratings_plus` is designed to be versatile, supporting both interactive input and read-only displays with precision (fractional ratings), custom shapes, and extensive styling options.

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
    *   **Semantics**: Fully accessible for screen readers.
*   **Customization**:
    *   **Builders**: Use any widget (Icons, Images, SVGs) for rated and unrated states.
    *   **Styling**: Custom colors, spacing, sizing, and glow effects.
    *   **Layout**: Vertical or Horizontal, with RTL support.
    *   **Theming**: Define global styles via `RatingBarThemeData`.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ratings_plus: ^1.0.0
```

## Usage

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

Seamlessly integrates with Flutter's `Form` widget for validation.

```dart
Form(
  child: Column(
    children: [
      RatingBar.form(
        initialValue: 0.0,
        minRating: 1.0,
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
          // Validate and save
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

## Interaction Lifecycle

`RatingBar` provides granular callbacks to help you manage complex interactions:

*   `onChangeStart`: Called when the user first touches the bar. Ideal for disabling parent scrolling (e.g., in a `ListView`).
*   `onChanged`: Called continuously as the user drags or taps. Use this for immediate UI updates.
*   `onChangeEnd`: Called when the user releases their finger. The best place to trigger API calls or database updates.

```dart
RatingBar(
  onChanged: (val) => setState(() => _current = val),
  onChangeStart: (val) => _disableScroll(),
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
| `unratedColor` | `Theme.disabledColor` | Color filter for unrated items (if no `unratedBuilder`). |
| `glow` | `true` | Show glow effect during interaction. |
| `glowColor` | `Theme.primaryColor` | Color of the touch glow. |
| `glowRadius` | `2.0` | Spread radius of the glow. |
| `animationDuration` | `150ms` | Duration for value change animations. |
| `animationCurve` | `Curves.easeOutCubic` | Curve for value change animations. |
| `enableHover` | `false` | Show rating preview on mouse hover (desktop/web). |
| `enableFeedback` | `true` | Provide haptic feedback on value changes. |

## Global Theming

Define the style once in your `ThemeData` to apply it consistently across your app.

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

`ratings_plus` treats accessibility as a first-class citizen.

*   **Keyboard Navigation**:
    *   `Tab`: Focuses the rating bar.
    *   `Arrow Keys`: Increase/decrease rating by `step`.
    *   `Home` / `End`: Set rating to min / max.
    *   `Page Up` / `Page Down`: Adjust rating by larger steps.
*   **Semantics**: Screen readers announce the current value (e.g., "3.5 of 5.0") and hint that it is adjustable. Custom labels can be provided via `semanticLabel`.

## License

MIT