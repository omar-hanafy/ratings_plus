import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ratings_plus/src/rating_bar_theme.dart';

/// Builds a widget for a specific rating item index.
///
/// The [RatingBar] calls this builder for each index from `0` to `itemCount - 1`.
/// The returned widget is wrapped in a container constrained to [RatingBar.itemSize].
///
/// This builder is responsible only for the visual representation of the item
/// (e.g., a Star icon); it does not need to handle gestures or spacing, which
/// are managed by the parent [RatingBar].
typedef RatingItemBuilder = Widget Function(BuildContext context, int index);

/// Defines the interaction behavior for a [RatingBar].
///
/// This enum controls how the widget interprets pointer events to update the rating.
enum RatingGestureMode {
  /// The rating is updated only when the user releases a tap on an item.
  ///
  /// Dragging gestures are ignored. This is useful when you want to prevent
  /// accidental value changes during scrolling interactions (e.g., inside a
  /// [ListView] or [SingleChildScrollView]).
  tap,

  /// The rating is updated continuously as the user drags across the items.
  ///
  /// Taps are treated as instantaneous drag events. This mode allows for fluid
  /// adjustment but requires careful handling if placed within scrollable views.
  drag,

  /// The rating responds to both tap and drag interactions.
  ///
  /// This is the standard behavior for most rating controls. Tapping sets the
  /// value immediately, while dragging updates the value continuously.
  tapAndDrag,

  /// User interaction is disabled.
  ///
  /// The widget behaves as a read-only display, ignoring all pointer events.
  /// This effectively turns [RatingBar] into a [RatingBarIndicator].
  none,
}

/// A highly customizable, interactive rating bar widget.
///
/// [RatingBar] allows users to select a rating value using touch, mouse, or
/// keyboard interactions. It is designed to be flexible, supporting custom visual
/// builders, various gesture modes, and form integration.
///
/// ### Interaction Models
///
/// The widget operates in one of two modes depending on which properties are set:
///
/// **1. Controlled (Stateless) Mode:**
/// You provide the [value] and handle the [onChanged] callback. The widget
/// simply renders the provided [value]. You are responsible for managing the
/// state and rebuilding the widget with the new value.
///
/// ```dart
/// RatingBar(
///   value: _currentRating, // State managed by parent
///   onChanged: (rating) {
///     setState(() => _currentRating = rating);
///   },
///   itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
/// )
/// ```
///
/// **2. Uncontrolled (Stateful) Mode:**
/// You provide an [initialValue], and the widget manages its own internal state.
/// The [onChanged] callback is still fired to notify you of updates, but the
/// widget rebuilds itself automatically.
///
/// ```dart
/// RatingBar(
///   initialValue: 3.0,
///   onChanged: (rating) => print('User selected: $rating'),
///   itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
/// )
/// ```
///
/// ### Form Integration
///
/// To use this widget within a [Form], use the [RatingBar.form] constructor.
/// This wraps the rating bar in a [FormField], enabling validation logic
/// (e.g., "Please select at least 1 star") and save callbacks.
///
/// ### Accessibility
///
/// This widget provides full accessibility support:
/// * **Semantics:** It announces the current value (e.g., "3.5 of 5.0") and
///   provides "increase" and "decrease" actions.
/// * **Keyboard:** When focused, users can change the rating using Arrow keys
///   (step adjustment), Home (min), and End (max).
///
/// See also:
///  * [RatingBarIndicator], for a lightweight, read-only version of this widget.
///  * [RatingBarThemeData], to configure default styles globally.
class RatingBar extends StatefulWidget {
  /// Creates an interactive rating bar.
  ///
  /// The [itemBuilder] is the only mandatory argument, determining the visual
  /// appearance of each rating unit (e.g., a Star).
  ///
  /// **Constraints:**
  /// * [itemCount] must be greater than 0.
  /// * [step], [minRating], and [initialValue] must be non-negative.
  /// * [minRating] cannot exceed [maxRating] (or [itemCount] if max is default).
  const RatingBar({
    super.key,
    required this.itemBuilder,
    this.unratedBuilder,
    this.value,
    this.initialValue = 0.0,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.itemCount = 5,
    this.direction = Axis.horizontal,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.itemSize,
    this.spacing,
    this.minRating = 0.0,
    this.maxRating,
    this.step = 1.0,
    this.allowClear = true,
    this.gestureMode = RatingGestureMode.tapAndDrag,
    this.enableHover = false,
    this.enableKeyboard = true,
    this.enableFeedback,
    this.unratedColor,
    this.glow,
    this.glowColor,
    this.glowRadius,
    this.glowBlurRadius,
    this.animationDuration,
    this.animationCurve,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticValueFormatter,
  }) : assert(itemCount > 0, 'itemCount must be > 0'),
       assert(step >= 0.0, 'step must be >= 0 (0 = continuous)'),
       assert(minRating >= 0.0, 'minRating must be >= 0'),
       assert(maxRating == null || maxRating > 0.0, 'maxRating must be > 0'),
       assert(
         minRating <= (maxRating ?? itemCount + 0.0),
         'minRating must be <= maxRating (or itemCount if maxRating is null)',
       ),
       assert(initialValue >= 0.0, 'initialValue must be >= 0');

  /// Creates a rating bar wrapped in a [FormField].
  ///
  /// This constructor enables the rating bar to participate in a [Form].
  /// It maintains the current value within the [FormFieldState], allowing validation,
  /// resetting, and saving.
  ///
  /// Use [validator] to enforce rules (e.g., minimum rating required) and
  /// [onSaved] to persist the value when [FormState.save] is called.
  ///
  /// Example:
  /// ```dart
  /// RatingBar.form(
  ///   initialValue: 0.0,
  ///   minRating: 1.0,
  ///   validator: (value) {
  ///     if (value < 1.0) return 'Please rate us.';
  ///     return null;
  ///   },
  ///   onSaved: (value) => _submitRating(value),
  ///   itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
  /// )
  /// ```
  static Widget form({
    Key? key,
    required RatingItemBuilder itemBuilder,
    RatingItemBuilder? unratedBuilder,
    double initialValue = 0.0,
    ValueChanged<double>? onChanged,
    int itemCount = 5,
    Axis direction = Axis.horizontal,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextDirection? textDirection,
    double? itemSize,
    double? spacing,
    double minRating = 0.0,
    double? maxRating,
    double step = 1.0,
    bool allowClear = true,
    RatingGestureMode gestureMode = RatingGestureMode.tapAndDrag,
    bool enableHover = false,
    bool enableKeyboard = true,
    bool? enableFeedback,
    Color? unratedColor,
    bool? glow,
    Color? glowColor,
    double? glowRadius,
    double? glowBlurRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    String Function(double)? semanticValueFormatter,
    // Form-specific
    FormFieldValidator<double>? validator,
    AutovalidateMode? autovalidateMode,
    FormFieldSetter<double>? onSaved,
  }) {
    return _RatingBarFormField(
      key: key,
      itemBuilder: itemBuilder,
      unratedBuilder: unratedBuilder,
      initialValue: initialValue,
      onChanged: onChanged,
      itemCount: itemCount,
      direction: direction,
      verticalDirection: verticalDirection,
      textDirection: textDirection,
      itemSize: itemSize,
      spacing: spacing,
      minRating: minRating,
      maxRating: maxRating,
      step: step,
      allowClear: allowClear,
      gestureMode: gestureMode,
      enableHover: enableHover,
      enableKeyboard: enableKeyboard,
      enableFeedback: enableFeedback,
      unratedColor: unratedColor,
      glow: glow,
      glowColor: glowColor,
      glowRadius: glowRadius,
      glowBlurRadius: glowBlurRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      semanticValueFormatter: semanticValueFormatter,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onSaved: onSaved,
    );
  }

  /// Builds the widget for each rating item at a specific index.
  ///
  /// This function is called for every index from `0` to `itemCount - 1`.
  /// The returned widget is used for the "filled" (rated) state of the item.
  /// It acts as a mask if partial filling is needed.
  ///
  /// The visual size of the returned widget is constrained by [itemSize].
  final RatingItemBuilder itemBuilder;

  /// Builds the widget for the unrated (empty) portion of the item.
  ///
  /// If provided, this is rendered behind the [itemBuilder] widget to represent
  /// the empty state.
  ///
  /// If null, the widget from [itemBuilder] is reused, but a [ColorFilter]
  /// is applied to it using [unratedColor] (or the theme's disabled color).
  final RatingItemBuilder? unratedBuilder;

  /// The current rating value (Controlled Mode).
  ///
  /// If this is non-null, the widget operates in **controlled mode**. It will
  /// always display this value, regardless of user interaction. To update the
  /// visual state, you must rebuild the widget with a new [value] in response
  /// to [onChanged].
  final double? value;

  /// The initial rating value (Uncontrolled Mode).
  ///
  /// This value is used to initialize the internal state when [value] is null.
  /// Changes to this property after the widget is mounted are ignored unless
  /// the widget is rebuilt with a new key.
  ///
  /// Defaults to `0.0`.
  final double initialValue;

  /// Callback triggered when the rating value changes.
  ///
  /// This is called whenever the user updates the rating via tap, drag, or
  /// keyboard interaction.
  ///
  /// * **Drag:** Called continuously as the pointer moves. If your state logic
  ///   is expensive, consider throttling this callback or using [onChangeEnd]
  ///   to commit the final value.
  /// * **Tap:** Called once when the tap is confirmed.
  /// * **Keyboard:** Called when an arrow key changes the value.
  final ValueChanged<double>? onChanged;

  /// Callback triggered when a user interaction begins.
  ///
  /// This is called when the user touches the rating bar or starts a drag.
  /// It is useful for disabling parent scrolling (e.g., in a [ListView] or
  /// [PageView]) to prevent gesture conflict.
  final ValueChanged<double>? onChangeStart;

  /// Callback triggered when a user interaction ends.
  ///
  /// This is called when the user lifts their finger or finishes a gesture.
  /// It indicates the final value of the interaction sequence. This is the ideal
  /// place to commit values to a database or API.
  final ValueChanged<double>? onChangeEnd;

  /// The total number of rating items (e.g., stars) to display.
  ///
  /// Must be greater than 0. Defaults to `5`.
  final int itemCount;

  /// The main axis along which the rating items are arranged.
  ///
  /// * [Axis.horizontal]: Items are placed in a Row.
  /// * [Axis.vertical]: Items are placed in a Column.
  final Axis direction;

  /// The flow direction for vertical layouts.
  ///
  /// Only applies when [direction] is [Axis.vertical].
  /// * [VerticalDirection.down]: Index 0 is at the top.
  /// * [VerticalDirection.up]: Index 0 is at the bottom (like a volume bar).
  final VerticalDirection verticalDirection;

  /// The text direction for horizontal layouts.
  ///
  /// Determines if items flow Left-to-Right (LTR) or Right-to-Left (RTL).
  /// If null, it defaults to [Directionality.of(context)].
  final TextDirection? textDirection;

  /// The size (width and height) of each rating item.
  ///
  /// This enforces a square constraint on the widgets returned by [itemBuilder].
  /// If null, defaults to [RatingBarThemeData.itemSize] (usually 40.0).
  final double? itemSize;

  /// The logical pixel distance between adjacent rating items.
  ///
  /// If null, defaults to [RatingBarThemeData.spacing] (usually 0.0).
  final double? spacing;

  /// The minimum allowed rating value.
  ///
  /// Users cannot drag or tap to select a value lower than this.
  /// Useful for ensuring a user gives at least 1 star.
  /// Defaults to `0.0`.
  final double minRating;

  /// The maximum possible rating value representing the full bar.
  ///
  /// If null, it defaults to [itemCount].
  ///
  /// **Example:**
  /// If [itemCount] is 5 and [maxRating] is 100, then filling the bar
  /// yields a value of 100, and each star represents 20 units.
  final double? maxRating;

  /// The step interval for rating selection.
  ///
  /// Defines how the rating snaps during interaction:
  /// * `1.0`: Whole numbers (e.g., 1, 2, 3).
  /// * `0.5`: Half steps (e.g., 1.0, 1.5, 2.0).
  /// * `0.0`: Continuous/Floating point (no snapping).
  ///
  /// Defaults to `1.0`.
  final double step;

  /// Whether tapping the current value resets the rating to [minRating].
  ///
  /// If `true`, and the user taps the item corresponding exactly to the
  /// current value, the rating resets to [minRating]. This allows users to
  /// "unselect" a rating.
  ///
  /// Defaults to `true`.
  final bool allowClear;

  /// The accepted gestures for changing the rating.
  ///
  /// Defaults to [RatingGestureMode.tapAndDrag]. Set to [RatingGestureMode.none]
  /// to make the bar read-only.
  final RatingGestureMode gestureMode;

  /// Whether to show a hover preview effect (desktop/web).
  ///
  /// If `true`, moving the mouse over the bar temporarily shows what the
  /// rating would be if clicked, without committing the value.
  /// Defaults to `false`.
  final bool enableHover;

  /// Whether to support keyboard interaction.
  ///
  /// If `true` and the widget is focused, users can use Arrow keys to adjust
  /// the rating by [step].
  /// Defaults to `true`.
  final bool enableKeyboard;

  /// Whether to provide haptic feedback (vibration) on value change.
  ///
  /// If null, defaults to [RatingBarThemeData.enableFeedback] or `true`.
  final bool? enableFeedback;

  /// The color used to tint the [itemBuilder] widget for the unrated state.
  ///
  /// This is only used if [unratedBuilder] is null.
  /// If null, defaults to [RatingBarThemeData.unratedColor] or the theme's
  /// disabled color.
  final Color? unratedColor;

  /// Whether to show a visual glow effect when interacting.
  ///
  /// The glow appears behind the item currently being touched/dragged.
  /// If null, defaults to [RatingBarThemeData.glow] or `true`.
  final bool? glow;

  /// The color of the interaction glow.
  ///
  /// If null, defaults to [RatingBarThemeData.glowColor] or the theme's primary color.
  final Color? glowColor;

  /// The radius of the glow effect.
  ///
  /// If null, defaults to [RatingBarThemeData.glowRadius].
  final double? glowRadius;

  /// The blur strength of the glow effect.
  ///
  /// If null, defaults to [RatingBarThemeData.glowBlurRadius].
  final double? glowBlurRadius;

  /// The duration of the animation when the rating changes.
  ///
  /// This applies to programmatic changes and tap interactions. Drag interactions
  /// generally update immediately.
  /// If null, defaults to [RatingBarThemeData.animationDuration].
  final Duration? animationDuration;

  /// The curve of the value change animation.
  ///
  /// If null, defaults to [RatingBarThemeData.animationCurve].
  final Curve? animationCurve;

  /// The mouse cursor to display when hovering.
  ///
  /// If null, defaults to [RatingBarThemeData.mouseCursor] or [SystemMouseCursors.click].
  final WidgetStateProperty<MouseCursor?>? mouseCursor;

  /// The focus node for managing keyboard focus.
  ///
  /// Provide this if you need to control focus programmatically (e.g.,
  /// `focusNode.requestFocus()`). If null, an internal node is created.
  final FocusNode? focusNode;

  /// Whether this widget should automatically request focus when mounted.
  ///
  /// Defaults to `false`.
  final bool autofocus;

  /// The semantic label used by screen readers.
  ///
  /// Defaults to 'Rating'.
  final String? semanticLabel;

  /// A function to format the value announced by screen readers.
  ///
  /// Defaults to `"$value / $maxRating"`.
  final String Function(double)? semanticValueFormatter;

  bool get _isInteractive =>
      onChanged != null && gestureMode != RatingGestureMode.none;

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _internalValue;

  /// Preview value used for hover.
  double? _hoverValue;

  bool _isPressed = false;
  bool _isHovered = false;
  bool _hasFocus = false;
  bool _isInteracting = false;
  bool _isDragging = false;
  bool _tapCanceled = false;
  bool _pendingClear = false;

  /// Used to avoid spamming feedback.
  double? _lastFeedbackValue;

  /// Last value produced by a user interaction (tap/drag/keyboard).
  double? _lastInteractionValue;

  FocusNode? _internalFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _internalValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(RatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If we were uncontrolled and the initialValue changed, reflect it.
    final isControlled = widget.value != null;
    final wasControlled = oldWidget.value != null;
    if (isControlled) {
      _internalValue = _clampValue(widget.value!);
    } else if (wasControlled) {
      _internalValue = _clampValue(oldWidget.value ?? _internalValue);
    } else if (oldWidget.initialValue != widget.initialValue) {
      _internalValue = widget.initialValue;
    }

    // Clamp internal value if bounds changed.
    if (!isControlled) {
      _internalValue = _clampValue(_internalValue);
    }

    // If focus node changed, dispose the old internal one.
    if (oldWidget.focusNode != widget.focusNode) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt =
        Theme.of(context).extension<RatingBarThemeData>() ??
        const RatingBarThemeData();

    final textDirection = widget.textDirection ?? Directionality.of(context);

    final maxRating = widget.maxRating ?? widget.itemCount.toDouble();

    final itemSize = widget.itemSize ?? themeExt.itemSize;
    final spacing = widget.spacing ?? themeExt.spacing;

    final enableFeedback = widget.enableFeedback ?? themeExt.enableFeedback;

    final glowEnabled = widget.glow ?? themeExt.glow;
    final glowColor =
        widget.glowColor ??
        themeExt.glowColor ??
        Theme.of(context).colorScheme.primary;
    final glowRadius = widget.glowRadius ?? themeExt.glowRadius;
    final glowBlurRadius = widget.glowBlurRadius ?? themeExt.glowBlurRadius;

    final animDuration = widget.animationDuration ?? themeExt.animationDuration;
    final animCurve = widget.animationCurve ?? themeExt.animationCurve;

    final value = _currentValue;
    final displayValue = _hoverValue ?? value;

    // Convert to visual units (0..itemCount).
    final visualValue = _valueToVisual(
      displayValue,
      maxRating: maxRating,
    ).clamp(0.0, widget.itemCount.toDouble()).toDouble();

    final states = <WidgetState>{
      if (!widget._isInteractive) WidgetState.disabled,
      if (_isHovered) WidgetState.hovered,
      if (_isPressed) WidgetState.pressed,
      if (_hasFocus) WidgetState.focused,
    };

    final resolvedCursor =
        (widget.mouseCursor ?? themeExt.mouseCursor)?.resolve(states) ??
        (widget._isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic);

    final bar = TweenAnimationBuilder<double>(
      // Only set an `end` so Flutter can animate from the previous value.
      tween: Tween<double>(end: visualValue),
      // We want implicit animation when the committed value changes. Hover
      // updates should feel immediate.
      duration: (_hoverValue == null) ? animDuration : Duration.zero,
      curve: animCurve,
      builder: (context, animatedVisual, _) {
        return _RatingBarItems(
          itemCount: widget.itemCount,
          itemSize: itemSize,
          spacing: spacing,
          direction: widget.direction,
          verticalDirection: widget.verticalDirection,
          textDirection: textDirection,
          visualValue: animatedVisual,
          itemBuilder: widget.itemBuilder,
          unratedBuilder: widget.unratedBuilder,
          unratedColor:
              widget.unratedColor ??
              themeExt.unratedColor ??
              Theme.of(context).disabledColor,
          showGlow: glowEnabled && _isPressed,
          glowColor: glowColor,
          glowRadius: glowRadius,
          glowBlurRadius: glowBlurRadius,
        );
      },
    );

    final semanticsValue =
        widget.semanticValueFormatter?.call(value) ??
        '${value.toStringAsFixed(1)} / ${maxRating.toStringAsFixed(1)}';

    // Calculate increased/decreased values for semantics
    final step = widget.step <= 0 ? 1.0 : widget.step;
    final effectiveMin = _effectiveMinRating(maxRating);
    final increasedValue = (value + step)
        .clamp(effectiveMin, maxRating)
        .toDouble();
    final decreasedValue = (value - step)
        .clamp(effectiveMin, maxRating)
        .toDouble();

    final semanticsIncreasedValue =
        widget.semanticValueFormatter?.call(increasedValue) ??
        '${increasedValue.toStringAsFixed(1)} / ${maxRating.toStringAsFixed(1)}';
    final semanticsDecreasedValue =
        widget.semanticValueFormatter?.call(decreasedValue) ??
        '${decreasedValue.toStringAsFixed(1)} / ${maxRating.toStringAsFixed(1)}';

    Widget result = Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Rating',
      value: semanticsValue,
      increasedValue: widget._isInteractive ? semanticsIncreasedValue : null,
      decreasedValue: widget._isInteractive ? semanticsDecreasedValue : null,
      enabled: true,
      readOnly: !widget._isInteractive,
      focusable: widget.enableKeyboard && widget._isInteractive,
      onIncrease: widget._isInteractive
          ? () => _adjustByStep(1, announce: true, feedback: enableFeedback)
          : null,
      onDecrease: widget._isInteractive
          ? () => _adjustByStep(-1, announce: true, feedback: enableFeedback)
          : null,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: widget.enableKeyboard && widget._isInteractive,
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        onKeyEvent: widget.enableKeyboard && widget._isInteractive
            ? _handleKeyEvent
            : null,
        child: MouseRegion(
          cursor: resolvedCursor,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) {
            setState(() {
              _isHovered = false;
              _hoverValue = null;
            });
          },
          onHover: widget.enableHover && widget._isInteractive
              ? (event) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;

                  final local = box.globalToLocal(event.position);
                  final preview = _positionToValue(
                    local,
                    size: box.size,
                    textDirection: textDirection,
                    maxRating: maxRating,
                    isTap: false,
                    itemSize: itemSize,
                    spacing: spacing,
                  );

                  setState(() => _hoverValue = preview);
                }
              : null,
          child: _buildGestureLayer(
            context,
            child: bar,
            textDirection: textDirection,
            maxRating: maxRating,
            enableFeedback: enableFeedback,
            itemSize: itemSize,
            spacing: spacing,
          ),
        ),
      ),
    );

    // Make sure the bar isn't affected by surrounding Material ink.
    result = Material(color: Colors.transparent, child: result);

    return result;
  }

  double get _currentValue {
    final controlledValue = widget.value;
    if (controlledValue != null) {
      return _clampValue(controlledValue);
    }
    return _clampValue(_internalValue);
  }

  double _clampValue(double v) {
    final maxRating = widget.maxRating ?? widget.itemCount.toDouble();
    return v.clamp(_effectiveMinRating(maxRating), maxRating).toDouble();
  }

  double _valueToVisual(double value, {required double maxRating}) {
    if (maxRating <= 0) return 0.0;
    return (value / maxRating) * widget.itemCount;
  }

  double _visualToValue(double visual, {required double maxRating}) {
    return (visual / widget.itemCount) * maxRating;
  }

  double _snap(double raw, {required bool isTap}) {
    final step = widget.step;
    if (step <= 0) return raw;

    final steps = raw / step;
    final snappedSteps = isTap ? steps.ceilToDouble() : steps.roundToDouble();
    return snappedSteps * step;
  }

  double _positionToValue(
    Offset localPosition, {
    required Size size,
    required TextDirection textDirection,
    required double maxRating,
    required bool isTap,
    required double itemSize,
    required double spacing,
  }) {
    final mainAxisExtent = widget.direction == Axis.horizontal
        ? size.width
        : size.height;

    double pos = widget.direction == Axis.horizontal
        ? localPosition.dx
        : localPosition.dy;

    // Direction-aware coordinates (fill from the leading edge).
    if (widget.direction == Axis.horizontal &&
        textDirection == TextDirection.rtl) {
      pos = mainAxisExtent - pos;
    }
    if (widget.direction == Axis.vertical &&
        widget.verticalDirection == VerticalDirection.up) {
      pos = mainAxisExtent - pos;
    }

    final totalExtent =
        (itemSize * widget.itemCount) + (spacing * (widget.itemCount - 1));

    final safeExtent = totalExtent > 0 ? totalExtent : mainAxisExtent;
    pos = pos.clamp(0.0, safeExtent);

    final stride = itemSize + spacing;
    double visual;
    if (stride <= 0 || itemSize <= 0) {
      visual = (safeExtent == 0.0)
          ? 0.0
          : (pos / safeExtent) * widget.itemCount;
    } else {
      var index = (pos / stride).floor();
      if (index < 0) index = 0;
      if (index > widget.itemCount - 1) index = widget.itemCount - 1;

      final remainder = pos - (index * stride);
      final fraction = (remainder / itemSize).clamp(0.0, 1.0).toDouble();
      visual = (index + fraction)
          .clamp(0.0, widget.itemCount.toDouble())
          .toDouble();
    }
    final rawValue = _visualToValue(visual, maxRating: maxRating);

    final snapped = _snap(rawValue, isTap: isTap);

    // Clamp after snapping.
    return snapped.clamp(_effectiveMinRating(maxRating), maxRating).toDouble();
  }

  void _setValue(
    double newValue, {
    required bool feedback,
    required bool announce,
  }) {
    final maxRating = widget.maxRating ?? widget.itemCount.toDouble();
    final clamped = newValue
        .clamp(_effectiveMinRating(maxRating), maxRating)
        .toDouble();

    if ((clamped - _currentValue).abs() < _effectiveEpsilon(maxRating)) {
      _lastInteractionValue = clamped;
      return;
    }

    _lastInteractionValue = clamped;

    // Feedback: only emit if the snapped value changed.
    if (feedback && widget.step > 0 && _lastFeedbackValue != clamped) {
      _lastFeedbackValue = clamped;
      HapticFeedback.selectionClick();
    }

    if (widget.value == null) {
      setState(() => _internalValue = clamped);
    }

    widget.onChanged?.call(clamped);
  }

  double _consumeInteractionValue() {
    final value = _lastInteractionValue ?? _currentValue;
    _lastInteractionValue = null;
    return value;
  }

  void _adjustByStep(
    int direction, {
    required bool feedback,
    required bool announce,
  }) {
    final step = widget.step <= 0 ? 1.0 : widget.step;
    final next = _currentValue + direction * step;
    _setValue(next, feedback: feedback, announce: announce);
  }

  double _effectiveMinRating(double maxRating) {
    return widget.minRating <= maxRating ? widget.minRating : maxRating;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // Direction-aware adjustments.
    final td = widget.textDirection ?? Directionality.of(context);

    final isHorizontal = widget.direction == Axis.horizontal;
    final isRtl = isHorizontal && td == TextDirection.rtl;

    if (key == LogicalKeyboardKey.home) {
      final maxRating = widget.maxRating ?? widget.itemCount.toDouble();
      _setValue(_effectiveMinRating(maxRating), feedback: true, announce: true);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.end) {
      final maxRating = widget.maxRating ?? widget.itemCount.toDouble();
      _setValue(maxRating, feedback: true, announce: true);
      return KeyEventResult.handled;
    }

    // Horizontal RTL swaps meaning.
    if (isHorizontal) {
      if (key == LogicalKeyboardKey.arrowRight) {
        _adjustByStep(isRtl ? -1 : 1, feedback: true, announce: true);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        _adjustByStep(isRtl ? 1 : -1, feedback: true, announce: true);
        return KeyEventResult.handled;
      }
    }

    // Vertical: respect verticalDirection.
    if (!isHorizontal) {
      final dirUp = widget.verticalDirection == VerticalDirection.up;

      if (key == LogicalKeyboardKey.arrowUp) {
        _adjustByStep(dirUp ? 1 : -1, feedback: true, announce: true);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        _adjustByStep(dirUp ? -1 : 1, feedback: true, announce: true);
        return KeyEventResult.handled;
      }
    }

    // Page up/down as coarse adjustments.
    if (key == LogicalKeyboardKey.pageUp) {
      _adjustByStep(1, feedback: true, announce: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      _adjustByStep(-1, feedback: true, announce: true);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildGestureLayer(
    BuildContext context, {
    required Widget child,
    required TextDirection textDirection,
    required double maxRating,
    required bool enableFeedback,
    required double itemSize,
    required double spacing,
  }) {
    if (!widget._isInteractive) {
      return child;
    }

    final allowTap =
        widget.gestureMode == RatingGestureMode.tap ||
        widget.gestureMode == RatingGestureMode.tapAndDrag;
    final allowDrag =
        widget.gestureMode == RatingGestureMode.drag ||
        widget.gestureMode == RatingGestureMode.tapAndDrag;

    void beginInteraction(double next, {required bool feedback}) {
      if (!_isInteracting) {
        _isInteracting = true;
        widget.onChangeStart?.call(next);
      }
      _isPressed = true;
      _setValue(next, feedback: feedback, announce: true);
      setState(() {});
    }

    void endInteraction() {
      if (!_isInteracting) return;
      final value = _consumeInteractionValue();
      widget.onChangeEnd?.call(value);
      _isInteracting = false;
      _isDragging = false;
      _tapCanceled = false;
      _pendingClear = false;
      setState(() => _isPressed = false);
    }

    void scheduleTapCancelEnd() {
      _tapCanceled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_tapCanceled && !_isDragging) {
          endInteraction();
        }
        _tapCanceled = false;
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: allowTap
          ? (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final valueFromTap = _positionToValue(
                box.globalToLocal(details.globalPosition),
                size: box.size,
                textDirection: textDirection,
                maxRating: maxRating,
                isTap: true,
                itemSize: itemSize,
                spacing: spacing,
              );

              final current = _currentValue;
              final effectiveMin = _effectiveMinRating(maxRating);
              _pendingClear =
                  widget.allowClear &&
                  (valueFromTap - current).abs() <
                      _effectiveEpsilon(maxRating) &&
                  current > effectiveMin;

              beginInteraction(valueFromTap, feedback: enableFeedback);
            }
          : null,
      onTapUp: allowTap
          ? (_) {
              if (_pendingClear) {
                _pendingClear = false;
                _setValue(
                  _effectiveMinRating(maxRating),
                  feedback: enableFeedback,
                  announce: true,
                );
              }
              endInteraction();
            }
          : null,
      onTapCancel: allowTap
          ? () {
              scheduleTapCancelEnd();
            }
          : null,
      onHorizontalDragStart: allowDrag && widget.direction == Axis.horizontal
          ? (details) {
              _isDragging = true;
              _tapCanceled = false;
              _pendingClear = false;
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final next = _positionToValue(
                box.globalToLocal(details.globalPosition),
                size: box.size,
                textDirection: textDirection,
                maxRating: maxRating,
                isTap: false,
                itemSize: itemSize,
                spacing: spacing,
              );
              beginInteraction(next, feedback: enableFeedback);
            }
          : null,
      onHorizontalDragUpdate: allowDrag && widget.direction == Axis.horizontal
          ? (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final next = _positionToValue(
                box.globalToLocal(details.globalPosition),
                size: box.size,
                textDirection: textDirection,
                maxRating: maxRating,
                isTap: false,
                itemSize: itemSize,
                spacing: spacing,
              );

              _setValue(next, feedback: enableFeedback, announce: false);
            }
          : null,
      onHorizontalDragEnd: allowDrag && widget.direction == Axis.horizontal
          ? (_) {
              endInteraction();
            }
          : null,
      onHorizontalDragCancel: allowDrag && widget.direction == Axis.horizontal
          ? () {
              endInteraction();
            }
          : null,
      onVerticalDragStart: allowDrag && widget.direction == Axis.vertical
          ? (details) {
              _isDragging = true;
              _tapCanceled = false;
              _pendingClear = false;
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final next = _positionToValue(
                box.globalToLocal(details.globalPosition),
                size: box.size,
                textDirection: textDirection,
                maxRating: maxRating,
                isTap: false,
                itemSize: itemSize,
                spacing: spacing,
              );
              beginInteraction(next, feedback: enableFeedback);
            }
          : null,
      onVerticalDragUpdate: allowDrag && widget.direction == Axis.vertical
          ? (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final next = _positionToValue(
                box.globalToLocal(details.globalPosition),
                size: box.size,
                textDirection: textDirection,
                maxRating: maxRating,
                isTap: false,
                itemSize: itemSize,
                spacing: spacing,
              );

              _setValue(next, feedback: enableFeedback, announce: false);
            }
          : null,
      onVerticalDragEnd: allowDrag && widget.direction == Axis.vertical
          ? (_) {
              endInteraction();
            }
          : null,
      onVerticalDragCancel: allowDrag && widget.direction == Axis.vertical
          ? () {
              endInteraction();
            }
          : null,
      child: child,
    );
  }

  double _effectiveEpsilon(double maxRating) {
    // Scale epsilon to maxRating to avoid floating comparison issues.
    return math.max(1e-9, maxRating * 1e-9);
  }
}

// ---------------------------------------------------------------------------
// Internal Widgets
// ---------------------------------------------------------------------------

class _RatingBarItems extends StatelessWidget {
  const _RatingBarItems({
    required this.itemCount,
    required this.itemSize,
    required this.spacing,
    required this.direction,
    required this.verticalDirection,
    required this.textDirection,
    required this.visualValue,
    required this.itemBuilder,
    required this.unratedBuilder,
    required this.unratedColor,
    required this.showGlow,
    required this.glowColor,
    required this.glowRadius,
    required this.glowBlurRadius,
  });

  final int itemCount;
  final double itemSize;
  final double spacing;
  final Axis direction;
  final VerticalDirection verticalDirection;
  final TextDirection textDirection;
  final double visualValue;

  final RatingItemBuilder itemBuilder;
  final RatingItemBuilder? unratedBuilder;
  final Color unratedColor;

  final bool showGlow;
  final Color glowColor;
  final double glowRadius;
  final double glowBlurRadius;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < itemCount; i++) {
      final fill = (visualValue - i).clamp(0.0, 1.0);
      final ratedChild = itemBuilder(context, i);
      final unratedChild = unratedBuilder?.call(context, i);

      children.add(
        RepaintBoundary(
          child: _RatingItem(
            size: itemSize,
            fill: fill,
            axis: direction,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            rated: ratedChild,
            unrated: unratedChild,
            unratedColor: unratedColor,
            showGlow: showGlow,
            glowColor: glowColor,
            glowRadius: glowRadius,
            glowBlurRadius: glowBlurRadius,
          ),
        ),
      );

      if (i != itemCount - 1) {
        children.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: children,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      verticalDirection: verticalDirection,
      children: children,
    );
  }
}

class _RatingItem extends StatelessWidget {
  const _RatingItem({
    required this.size,
    required this.fill,
    required this.axis,
    required this.textDirection,
    required this.verticalDirection,
    required this.rated,
    required this.unrated,
    required this.unratedColor,
    required this.showGlow,
    required this.glowColor,
    required this.glowRadius,
    required this.glowBlurRadius,
  });

  final double size;
  final double fill;
  final Axis axis;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;
  final Widget rated;
  final Widget? unrated;
  final Color unratedColor;

  final bool showGlow;
  final Color glowColor;
  final double glowRadius;
  final double glowBlurRadius;

  @override
  Widget build(BuildContext context) {
    final ratedBox = SizedBox.square(
      dimension: size,
      child: FittedBox(child: rated),
    );

    final unratedBox = SizedBox.square(
      dimension: size,
      child: FittedBox(
        child:
            unrated ??
            ColorFiltered(
              colorFilter: ColorFilter.mode(unratedColor, BlendMode.srcIn),
              child: rated,
            ),
      ),
    );

    Widget result = SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          unratedBox,
          if (fill > 0)
            ClipRect(
              clipper: _FillClipper(
                fraction: fill,
                axis: axis,
                textDirection: textDirection,
                verticalDirection: verticalDirection,
              ),
              child: ratedBox,
            ),
        ],
      ),
    );

    if (showGlow) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor.withAlpha(30),
              blurRadius: glowBlurRadius,
              spreadRadius: glowRadius,
            ),
            BoxShadow(
              color: glowColor.withAlpha(20),
              blurRadius: glowBlurRadius,
              spreadRadius: glowRadius,
            ),
          ],
        ),
        child: result,
      );
    }

    return result;
  }
}

class _FillClipper extends CustomClipper<Rect> {
  const _FillClipper({
    required this.fraction,
    required this.axis,
    required this.textDirection,
    required this.verticalDirection,
  });

  final double fraction;
  final Axis axis;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;

  @override
  Rect getClip(Size size) {
    final f = fraction.clamp(0.0, 1.0);

    if (axis == Axis.horizontal) {
      if (textDirection == TextDirection.rtl) {
        final width = size.width * f;
        return Rect.fromLTRB(size.width - width, 0, size.width, size.height);
      }
      return Rect.fromLTRB(0, 0, size.width * f, size.height);
    }

    // Vertical.
    if (verticalDirection == VerticalDirection.up) {
      final height = size.height * f;
      return Rect.fromLTRB(0, size.height - height, size.width, size.height);
    }

    return Rect.fromLTRB(0, 0, size.width, size.height * f);
  }

  @override
  bool shouldReclip(_FillClipper oldClipper) {
    return fraction != oldClipper.fraction ||
        axis != oldClipper.axis ||
        textDirection != oldClipper.textDirection ||
        verticalDirection != oldClipper.verticalDirection;
  }
}

// ---------------------------------------------------------------------------
// Form Field
// ---------------------------------------------------------------------------

class _RatingBarFormField extends FormField<double> {
  _RatingBarFormField({
    super.key,
    required RatingItemBuilder itemBuilder,
    RatingItemBuilder? unratedBuilder,
    double initialValue = 0.0,
    ValueChanged<double>? onChanged,
    int itemCount = 5,
    Axis direction = Axis.horizontal,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextDirection? textDirection,
    double? itemSize,
    double? spacing,
    double minRating = 0.0,
    double? maxRating,
    double step = 1.0,
    bool allowClear = true,
    RatingGestureMode gestureMode = RatingGestureMode.tapAndDrag,
    bool enableHover = false,
    bool enableKeyboard = true,
    bool? enableFeedback,
    Color? unratedColor,
    bool? glow,
    Color? glowColor,
    double? glowRadius,
    double? glowBlurRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    String Function(double)? semanticValueFormatter,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  }) : super(
         initialValue: initialValue,
         builder: (FormFieldState<double> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               RatingBar(
                 itemBuilder: itemBuilder,
                 unratedBuilder: unratedBuilder,
                 value: state.value,
                 onChanged: (value) {
                   state.didChange(value);
                   onChanged?.call(value);
                 },
                 itemCount: itemCount,
                 direction: direction,
                 verticalDirection: verticalDirection,
                 textDirection: textDirection,
                 itemSize: itemSize,
                 spacing: spacing,
                 minRating: minRating,
                 maxRating: maxRating,
                 step: step,
                 allowClear: allowClear,
                 gestureMode: gestureMode,
                 enableHover: enableHover,
                 enableKeyboard: enableKeyboard,
                 enableFeedback: enableFeedback,
                 unratedColor: unratedColor,
                 glow: glow,
                 glowColor: glowColor,
                 glowRadius: glowRadius,
                 glowBlurRadius: glowBlurRadius,
                 animationDuration: animationDuration,
                 animationCurve: animationCurve,
                 mouseCursor: mouseCursor,
                 focusNode: focusNode,
                 autofocus: autofocus,
                 semanticLabel: semanticLabel,
                 semanticValueFormatter: semanticValueFormatter,
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 5.0, left: 2.0),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: Theme.of(state.context).colorScheme.error,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
