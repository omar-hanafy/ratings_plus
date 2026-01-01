/// A customizable rating bar and indicator for Flutter, designed for both interactive input and read-only displays.
///
/// This library provides the core [RatingBar] widget for user interaction and
/// [RatingBarIndicator] for visual representation of ratings. It supports
/// extensive customization through builders, themes, and interaction modes.
///
/// ### Getting Started
///
/// To collect a rating from a user, use [RatingBar]:
///
/// ```dart
/// RatingBar(
///   initialValue: 3,
///   onChanged: (rating) {
///     print('Rating: $rating');
///   },
///   itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
/// )
/// ```
///
/// To display a static rating (e.g., in a list), use [RatingBarIndicator]:
///
/// ```dart
/// RatingBarIndicator(
///   value: 4.5,
///   itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
/// )
/// ```
///
/// ### Key Features
///
/// * **[RatingBar]**: Interactive input. Supports tap/drag gestures, keyboard navigation, and form validation.
/// * **[RatingBarIndicator]**: Optimized read-only display.
/// * **[RatingBarThemeData]**: Global styling via [ThemeData.extensions].
///
/// See the individual classes for detailed behavioral documentation.
library;

export 'src/rating_bar.dart';
export 'src/rating_bar_indicator.dart';
export 'src/rating_bar_theme.dart';
