import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Defines the visual properties for [RatingBar] and [RatingBarIndicator].
///
/// This class enables global styling of rating bars when added to the app's [ThemeData].
/// It leverages Flutter's [ThemeExtension] system to seamlessly integrate with
/// the existing theme infrastructure.
///
/// Properties defined here serve as **defaults**. They are used only when the
/// corresponding property on the [RatingBar] or [RatingBarIndicator] widget is
/// null. Widget-specific parameters always take precedence over the theme.
///
/// ### Example
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [
///       RatingBarThemeData(
///         itemSize: 28,
///         spacing: 6,
///         unratedColor: Colors.grey,
///         glowColor: Colors.amberAccent,
///       ),
///     ],
///   ),
/// )
/// ```
@immutable
class RatingBarThemeData extends ThemeExtension<RatingBarThemeData> {
  /// Creates a theme data object for rating bars.
  const RatingBarThemeData({
    this.itemSize = 40.0,
    this.spacing = 0.0,
    this.unratedColor,
    this.glow = true,
    this.glowColor,
    this.glowRadius = 2.0,
    this.glowBlurRadius = 10.0,
    this.enableFeedback = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOutCubic,
    this.mouseCursor,
  });

  /// The default size (width and height) of each rating item.
  ///
  /// Used if [RatingBar.itemSize] is null.
  /// Defaults to `40.0`.
  final double itemSize;

  /// The default gap between adjacent rating items.
  ///
  /// Used if [RatingBar.spacing] is null.
  /// Defaults to `0.0`.
  final double spacing;

  /// The default color for the unrated portion of items.
  ///
  /// Used if [RatingBar.unratedColor] is null and no [RatingBar.unratedBuilder]
  /// is provided. If null, defaults to [ThemeData.disabledColor].
  final Color? unratedColor;

  /// Whether to show a glow effect during interaction by default.
  ///
  /// Used if [RatingBar.glow] is null.
  /// Defaults to `true`.
  final bool glow;

  /// The default color of the interaction glow.
  ///
  /// Used if [RatingBar.glowColor] is null.
  /// If null, defaults to [ColorScheme.primary].
  final Color? glowColor;

  /// The default spread radius of the interaction glow.
  ///
  /// Used if [RatingBar.glowRadius] is null.
  /// Defaults to `2.0`.
  final double glowRadius;

  /// The default blur radius of the interaction glow.
  ///
  /// Used if [RatingBar.glowBlurRadius] is null.
  /// Defaults to `10.0`.
  final double glowBlurRadius;

  /// Whether to provide haptic feedback when the value changes by default.
  ///
  /// Used if [RatingBar.enableFeedback] is null.
  /// Defaults to `true`.
  final bool enableFeedback;

  /// The default duration of the implicit animation when the value changes.
  ///
  /// Used if [RatingBar.animationDuration] is null.
  /// Defaults to `150ms`.
  final Duration animationDuration;

  /// The default curve of the implicit animation when the value changes.
  ///
  /// Used if [RatingBar.animationCurve] is null.
  /// Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// The default mouse cursor to display when hovering over the rating bar.
  ///
  /// Used if [RatingBar.mouseCursor] is null.
  /// If null, defaults to [SystemMouseCursors.click] when interactive, and
  /// [SystemMouseCursors.basic] when not.
  final WidgetStateProperty<MouseCursor?>? mouseCursor;

  /// Creates a copy of this theme but with the given fields replaced.
  @override
  RatingBarThemeData copyWith({
    double? itemSize,
    double? spacing,
    Color? unratedColor,
    bool? glow,
    Color? glowColor,
    double? glowRadius,
    double? glowBlurRadius,
    bool? enableFeedback,
    Duration? animationDuration,
    Curve? animationCurve,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
  }) {
    return RatingBarThemeData(
      itemSize: itemSize ?? this.itemSize,
      spacing: spacing ?? this.spacing,
      unratedColor: unratedColor ?? this.unratedColor,
      glow: glow ?? this.glow,
      glowColor: glowColor ?? this.glowColor,
      glowRadius: glowRadius ?? this.glowRadius,
      glowBlurRadius: glowBlurRadius ?? this.glowBlurRadius,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  /// Linearly interpolates between two [RatingBarThemeData] objects.
  @override
  RatingBarThemeData lerp(ThemeExtension<RatingBarThemeData>? other, double t) {
    if (other is! RatingBarThemeData) return this;

    return RatingBarThemeData(
      itemSize: lerpDouble(itemSize, other.itemSize, t) ?? itemSize,
      spacing: lerpDouble(spacing, other.spacing, t) ?? spacing,
      unratedColor: Color.lerp(unratedColor, other.unratedColor, t),
      glow: t < 0.5 ? glow : other.glow,
      glowColor: Color.lerp(glowColor, other.glowColor, t),
      glowRadius: lerpDouble(glowRadius, other.glowRadius, t) ?? glowRadius,
      glowBlurRadius:
          lerpDouble(glowBlurRadius, other.glowBlurRadius, t) ?? glowBlurRadius,
      enableFeedback: t < 0.5 ? enableFeedback : other.enableFeedback,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
      mouseCursor: t < 0.5 ? mouseCursor : other.mouseCursor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RatingBarThemeData &&
        other.itemSize == itemSize &&
        other.spacing == spacing &&
        other.unratedColor == unratedColor &&
        other.glow == glow &&
        other.glowColor == glowColor &&
        other.glowRadius == glowRadius &&
        other.glowBlurRadius == glowBlurRadius &&
        other.enableFeedback == enableFeedback &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.mouseCursor == mouseCursor;
  }

  @override
  int get hashCode => Object.hash(
    itemSize,
    spacing,
    unratedColor,
    glow,
    glowColor,
    glowRadius,
    glowBlurRadius,
    enableFeedback,
    animationDuration,
    animationCurve,
    mouseCursor,
  );

  @override
  String toString() =>
      'RatingBarThemeData('
      'itemSize: $itemSize, '
      'spacing: $spacing, '
      'unratedColor: $unratedColor, '
      'glow: $glow, '
      'glowColor: $glowColor, '
      'glowRadius: $glowRadius, '
      'glowBlurRadius: $glowBlurRadius, '
      'enableFeedback: $enableFeedback, '
      'animationDuration: $animationDuration, '
      'animationCurve: $animationCurve, '
      'mouseCursor: $mouseCursor'
      ')';
}
