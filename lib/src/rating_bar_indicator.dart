import 'package:flutter/material.dart';

import 'package:ratings_plus/src/rating_bar.dart';

/// A widget that displays a read-only rating indicator.
///
/// This widget is a lightweight wrapper around [RatingBar] with interaction
/// explicitly disabled. It is optimized for presenting ratings in non-interactive
/// contexts, such as review lists, product cards, or summary views.
///
/// ### Behavior
/// * **Input:** Ignores all user input (taps, drags, keyboard).
/// * **Semantics:** Reports the value to screen readers but excludes "adjustable" traits.
/// * **Visuals:** Renders the fractional [value] based on the [itemBuilder].
///
/// ### Example
///
/// ```dart
/// RatingBarIndicator(
///   value: 4.5,
///   itemCount: 5,
///   itemSize: 20.0,
///   itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
/// )
/// ```
///
/// See also:
///  * [RatingBar], for the interactive equivalent.
class RatingBarIndicator extends StatelessWidget {
  /// Creates a read-only rating indicator.
  ///
  /// The [itemBuilder] and [value] arguments are required.
  const RatingBarIndicator({
    super.key,
    required this.itemBuilder,
    required this.value,
    this.unratedBuilder,
    this.itemCount = 5,
    this.direction = Axis.horizontal,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.itemSize,
    this.spacing,
    this.maxRating,
    this.unratedColor,
    this.animationDuration,
    this.animationCurve,
    this.semanticLabel,
    this.semanticValueFormatter,
  });

  /// Builds the widget for each rating item.
  ///
  /// This builder is called for each index from `0` to [itemCount] - 1.
  /// It should return the widget representing a "full" star (or other shape).
  final RatingItemBuilder itemBuilder;

  /// Builds the widget for the unrated (empty) portion of the item.
  ///
  /// If provided, this is rendered behind the [itemBuilder] widget.
  /// If null, the [itemBuilder] widget is reused with a color filter applied
  /// (using [unratedColor]).
  final RatingItemBuilder? unratedBuilder;

  /// The rating value to display.
  ///
  /// This value is clamped between 0 and [maxRating] (or [itemCount]).
  final double value;

  /// The total number of rating items to display.
  ///
  /// Defaults to `5`.
  final int itemCount;

  /// The axis along which the indicator is laid out.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// The direction in which vertical items flow.
  ///
  /// Only applies when [direction] is [Axis.vertical].
  /// Defaults to [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// The text direction for horizontal layout.
  ///
  /// If null, defaults to [Directionality.of(context)].
  final TextDirection? textDirection;

  /// The size (width and height) of each rating item.
  ///
  /// If null, defaults to [RatingBarThemeData.itemSize] or `40.0`.
  final double? itemSize;

  /// The gap between adjacent rating items.
  ///
  /// If null, defaults to [RatingBarThemeData.spacing] or `0.0`.
  final double? spacing;

  /// The maximum possible rating value.
  ///
  /// This defines the scale of the rating.
  /// If null, defaults to [itemCount].
  ///
  /// Example: If [itemCount] is 5 and [maxRating] is 10, then a [value] of 5
  /// will fill 2.5 stars (50% of the bar).
  final double? maxRating;

  /// The color for the unrated portion of items.
  ///
  /// Used when [unratedBuilder] is null. If null, defaults to
  /// [RatingBarThemeData.unratedColor] or the theme's disabled color.
  final Color? unratedColor;

  /// The duration of the implicit animation when the value changes.
  ///
  /// If null, defaults to [RatingBarThemeData.animationDuration].
  final Duration? animationDuration;

  /// The curve of the implicit animation when the value changes.
  ///
  /// If null, defaults to [RatingBarThemeData.animationCurve].
  final Curve? animationCurve;

  /// The semantic label for accessibility.
  ///
  /// Defaults to 'Rating'.
  final String? semanticLabel;

  /// Callback to format the semantic value for accessibility.
  ///
  /// Defaults to `"$value / $maxRating"`.
  final String Function(double value)? semanticValueFormatter;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      itemBuilder: itemBuilder,
      unratedBuilder: unratedBuilder,
      value: value,
      initialValue: value,
      itemCount: itemCount,
      direction: direction,
      verticalDirection: verticalDirection,
      textDirection: textDirection,
      itemSize: itemSize,
      spacing: spacing,
      minRating: 0,
      maxRating: maxRating,
      step: 0, // Continuous display
      onChanged: null, // Read-only
      enableHover: false,
      enableKeyboard: false,
      glow: false,
      unratedColor: unratedColor,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      semanticLabel: semanticLabel,
      semanticValueFormatter: semanticValueFormatter,
    );
  }
}
