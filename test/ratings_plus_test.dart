import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratings_plus/ratings_plus.dart';

void main() {
  group('RatingBar', () {
    testWidgets('tap updates rating (uncontrolled)', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      expect(barFinder, findsOneWidget);

      final topLeft = tester.getTopLeft(barFinder);

      // Tap near the end -> should resolve to max (5.0)
      await tester.tapAt(topLeft + const Offset(180, 20));
      await tester.pump();

      expect(lastValue, 5.0);
    });

    testWidgets('controlled mode uses external value', (tester) async {
      double rating = 2.0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Center(
                  child: RatingBar(
                    value: rating,
                    itemCount: 5,
                    itemSize: 40,
                    step: 1,
                    onChanged: (v) => setState(() => rating = v),
                    itemBuilder: (context, _) => const Icon(Icons.star),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(rating, 2.0);

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      // Tap to set rating to 4
      await tester.tapAt(topLeft + const Offset(150, 20));
      await tester.pump();

      expect(rating, 4.0);
    });

    testWidgets('half step rating works', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                spacing: 0,
                step: 0.5,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      // Tap at 2.5 stars position
      await tester.tapAt(topLeft + const Offset(95, 20));
      await tester.pump();

      expect(lastValue, 2.5);
    });

    testWidgets('read-only mode does not respond to taps', (tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                value: 3.0,
                itemCount: 5,
                itemSize: 40,
                onChanged: null, // Read-only
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(180, 20));
      await tester.pump();

      expect(callbackCalled, false);
    });

    testWidgets('minRating constraint is respected', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                initialValue: 3.0,
                itemCount: 5,
                itemSize: 40,
                minRating: 1.0,
                step: 1,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      // Tap at the very beginning (should clamp to minRating)
      await tester.tapAt(topLeft + const Offset(5, 20));
      await tester.pump();

      expect(lastValue, 1.0);
    });

    testWidgets('gestureMode.tap ignores drag updates', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                gestureMode: RatingGestureMode.tap,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      final gesture = await tester.startGesture(topLeft + const Offset(5, 20));
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(160, 20));
      await gesture.up();
      await tester.pump();

      expect(lastValue, 1.0);
    });

    testWidgets('gestureMode.drag responds to drag', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                gestureMode: RatingGestureMode.drag,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      final tapGesture = await tester.startGesture(
        topLeft + const Offset(150, 20),
      );
      await tester.pump();
      await tapGesture.moveTo(topLeft + const Offset(170, 20));
      await tester.pump();
      await tapGesture.up();
      await tester.pump();
      expect(lastValue, 4.0);

      final gesture = await tester.startGesture(topLeft + const Offset(5, 20));
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(140, 20));
      await gesture.up();
      await tester.pump();

      expect(lastValue, 4.0);
    });

    testWidgets('gestureMode.none ignores input', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                gestureMode: RatingGestureMode.none,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(150, 20));
      await tester.pump();

      expect(lastValue, isNull);
    });

    testWidgets('allowClear resets to minRating on tap-up', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                initialValue: 3.0,
                itemCount: 5,
                itemSize: 40,
                step: 1,
                allowClear: true,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(100, 20));
      await tester.pump();

      expect(lastValue, 0.0);
    });

    testWidgets('drag triggers start/end once with final value', (
      tester,
    ) async {
      final starts = <double>[];
      final ends = <double>[];
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                gestureMode: RatingGestureMode.tapAndDrag,
                onChanged: (v) => lastValue = v,
                onChangeStart: starts.add,
                onChangeEnd: ends.add,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      final gesture = await tester.startGesture(topLeft + const Offset(5, 20));
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(140, 20));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(starts.length, 1);
      expect(ends.length, 1);
      expect(ends.single, lastValue);
    });

    testWidgets('spacing hit-test treats gap as previous item', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                spacing: 20,
                step: 1,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      // Tap in the gap after the first star (40..60)
      await tester.tapAt(topLeft + const Offset(45, 20));
      await tester.pump();

      expect(lastValue, 1.0);
    });

    testWidgets('controlled to uncontrolled retains last value', (
      tester,
    ) async {
      final rating = ValueNotifier<double>(2.0);
      final controlled = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        ValueListenableBuilder<bool>(
          valueListenable: controlled,
          builder: (context, isControlled, _) {
            return MaterialApp(
              home: ValueListenableBuilder<double>(
                valueListenable: rating,
                builder: (context, value, _) {
                  return Scaffold(
                    body: Center(
                      child: RatingBar(
                        value: isControlled ? value : null,
                        initialValue: 1.0,
                        itemCount: 5,
                        itemSize: 40,
                        step: 1,
                        onChanged: (v) => rating.value = v,
                        itemBuilder: (context, _) => const Icon(Icons.star),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(140, 20));
      await tester.pump();

      expect(rating.value, 4.0);

      controlled.value = false;
      await tester.pump();

      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.bySemanticsLabel('Rating'));
      expect(node.value, '4.0 / 5.0');
      handle.dispose();
    });

    testWidgets('hover preview does not commit value without click', (
      tester,
    ) async {
      int changes = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                initialValue: 1.0,
                itemCount: 5,
                itemSize: 40,
                enableHover: true,
                onChanged: (_) => changes++,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: topLeft + const Offset(5, 20));
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(180, 20));
      await tester.pump();

      expect(changes, 0);
    });

    testWidgets('maxRating scaling maps visual to real value', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                itemCount: 5,
                itemSize: 40,
                step: 1,
                maxRating: 10,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      // Tap near the end of the 3rd star to select 3 stars => 6.0
      await tester.tapAt(topLeft + const Offset(118, 20));
      await tester.pump();

      expect(lastValue, 6.0);
    });

    testWidgets('RTL tap maps to higher values on the left', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: RatingBar(
                  itemCount: 5,
                  itemSize: 40,
                  step: 1,
                  onChanged: (v) => lastValue = v,
                  itemBuilder: (context, _) => const Icon(Icons.star),
                ),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(5, 20));
      await tester.pump();

      expect(lastValue, 5.0);
    });

    testWidgets('verticalDirection.up maps top to higher values', (
      tester,
    ) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                direction: Axis.vertical,
                verticalDirection: VerticalDirection.up,
                itemCount: 5,
                itemSize: 40,
                step: 1,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);

      await tester.tapAt(topLeft + const Offset(20, 5));
      await tester.pump();

      expect(lastValue, 5.0);
    });

    testWidgets('keyboard navigation works (arrows/home/end/page)', (
      tester,
    ) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBar(
                initialValue: 2.0,
                itemCount: 5,
                itemSize: 40,
                step: 1,
                autofocus: true,
                onChanged: (v) => lastValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(lastValue, 3.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(lastValue, 2.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(lastValue, 5.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(lastValue, 0.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(lastValue, 1.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      expect(lastValue, 0.0);
    });

    testWidgets('RTL keyboard arrows are reversed', (tester) async {
      double? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: RatingBar(
                  initialValue: 3.0,
                  itemCount: 5,
                  itemSize: 40,
                  step: 1,
                  autofocus: true,
                  onChanged: (v) => lastValue = v,
                  itemBuilder: (context, _) => const Icon(Icons.star),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(lastValue, 2.0);
    });

    testWidgets('semantics reflect label/value and actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingBar(
              initialValue: 3.0,
              itemCount: 5,
              itemSize: 40,
              step: 1,
              onChanged: (_) {},
              semanticLabel: 'Star Rating',
              itemBuilder: (context, _) => const Icon(Icons.star),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Star Rating')),
        matchesSemantics(
          label: 'Star Rating',
          value: '3.0 / 5.0',
          isFocusable: true,
          isEnabled: true,
          hasEnabledState: true,
          isReadOnly: false,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('RatingBarIndicator', () {
    testWidgets('displays rating correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBarIndicator(
                value: 3.5,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RatingBarIndicator), findsOneWidget);
    });

    testWidgets('is read-only (does not respond to taps)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBarIndicator(
                value: 3.0,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      // The widget should render without issues
      expect(find.byType(RatingBarIndicator), findsOneWidget);
    });

    testWidgets('semantics are read-only with no actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RatingBarIndicator(
                value: 3.0,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Rating')),
        matchesSemantics(
          label: 'Rating',
          value: '3.0 / 5.0',
          isEnabled: true,
          hasEnabledState: true,
          isReadOnly: true,
          hasIncreaseAction: false,
          hasDecreaseAction: false,
        ),
      );
      handle.dispose();
    });
  });

  group('RatingBarThemeData', () {
    testWidgets('theme values are applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [RatingBarThemeData(itemSize: 50, spacing: 8)],
          ),
          home: Scaffold(
            body: Center(
              child: RatingBar(
                value: 3.0,
                itemCount: 5,
                onChanged: null,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RatingBar), findsOneWidget);
    });

    test('copyWith creates modified copy', () {
      const original = RatingBarThemeData(itemSize: 40, spacing: 0);

      final modified = original.copyWith(itemSize: 50);

      expect(modified.itemSize, 50);
      expect(modified.spacing, 0);
    });

    test('lerp interpolates values', () {
      const a = RatingBarThemeData(itemSize: 40, spacing: 0);
      const b = RatingBarThemeData(itemSize: 60, spacing: 10);

      final result = a.lerp(b, 0.5);

      expect(result.itemSize, 50);
      expect(result.spacing, 5);
    });
  });

  group('RatingBar.form', () {
    testWidgets('integrates with Form validation', (tester) async {
      final formKey = GlobalKey<FormState>();
      double? savedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: RatingBar.form(
                initialValue: 0,
                validator: (v) => v == null || v < 1 ? 'Required' : null,
                onSaved: (v) => savedValue = v,
                itemBuilder: (context, _) => const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      // Validate without input - should fail
      expect(formKey.currentState!.validate(), false);

      // Tap to set rating
      final barFinder = find.byType(RatingBar);
      final topLeft = tester.getTopLeft(barFinder);
      await tester.tapAt(topLeft + const Offset(100, 20));
      await tester.pump();

      // Now validation should pass
      expect(formKey.currentState!.validate(), true);

      // Save the form
      formKey.currentState!.save();
      expect(savedValue, isNotNull);
      expect(savedValue! >= 1, true);
    });
  });
}
