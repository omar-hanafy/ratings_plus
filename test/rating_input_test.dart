import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';

const _rated = Color(0xffff0000);
const _unrated = Color(0xff0000ff);
const _painting = ValueKey('rating paint');

Widget _item(BuildContext context, int index) =>
    const SizedBox.square(dimension: 40, child: ColoredBox(color: _rated));

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

Future<List<Color>?> _sample(WidgetTester tester, List<Offset> points) {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_painting),
  );
  return tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return points.map((point) {
        final offset = (point.dy.toInt() * image.width + point.dx.toInt()) * 4;
        return Color.fromARGB(
          bytes.getUint8(offset + 3),
          bytes.getUint8(offset),
          bytes.getUint8(offset + 1),
          bytes.getUint8(offset + 2),
        );
      }).toList();
    } finally {
      image.dispose();
    }
  });
}

void main() {
  for (final mode in [RatingGestureMode.tap, RatingGestureMode.tapAndDrag]) {
    testWidgets('$mode keeps the committed value when a scroll wins', (
      tester,
    ) async {
      final changes = <double>[];
      final starts = <double>[];
      final ends = <double>[];
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        _app(
          ListView(
            controller: scroll,
            children: [
              const SizedBox(height: 200),
              Center(
                child: RatingBar(
                  gestureMode: mode,
                  initialValue: 3,
                  onChanged: changes.add,
                  onChangeStart: starts.add,
                  onChangeEnd: ends.add,
                  itemBuilder: _item,
                ),
              ),
              const SizedBox(height: 900),
            ],
          ),
        ),
      );

      final firstStar =
          tester.getTopLeft(find.byType(RatingBar)) + const Offset(10, 20);
      final gesture = await tester.startGesture(firstStar);
      await tester.pump(kPressTimeout);
      expect(starts, [1.0]);
      expect(changes, isEmpty);

      await gesture.moveBy(const Offset(0, -40));
      await gesture.moveBy(const Offset(0, -50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(scroll.offset, greaterThan(0));
      expect(changes, isEmpty);
      expect(ends, [3.0]);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Rating')).value,
        '3.0 / 5.0',
      );
    });
  }

  testWidgets('hover previews tap snapping and releases the preview on click', (
    tester,
  ) async {
    final changes = <double>[];
    await tester.pumpWidget(
      _app(
        RepaintBoundary(
          key: _painting,
          child: RatingBar(
            initialValue: 1,
            enableHover: true,
            unratedColor: _unrated,
            animationDuration: Duration.zero,
            onChanged: changes.add,
            itemBuilder: _item,
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byKey(_painting));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: origin - const Offset(1, 1));
    addTearDown(mouse.removePointer);
    final target = origin + const Offset(85, 20);
    await mouse.moveTo(target);
    await tester.pump();

    const samples = [Offset(100, 20), Offset(140, 20)];
    expect(await _sample(tester, samples), [_rated, _unrated]);
    expect(changes, isEmpty);
    await mouse.down(target);
    await mouse.up();
    await tester.pump();
    expect(changes, [3.0]);
    await mouse.down(target);
    await mouse.up();
    await tester.pump();
    expect(changes, [3.0, 0.0]);
    expect(await _sample(tester, samples), [_unrated, _unrated]);
  });

  testWidgets('drag paints the new RTL half step on its next frame', (
    tester,
  ) async {
    final changes = <double>[];
    await tester.pumpWidget(
      _app(
        RepaintBoundary(
          key: _painting,
          child: RatingBar(
            step: 0.5,
            glow: false,
            textDirection: TextDirection.rtl,
            animationDuration: const Duration(seconds: 1),
            unratedColor: _unrated,
            onChanged: changes.add,
            itemBuilder: _item,
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byKey(_painting));
    final drag = await tester.startGesture(origin + const Offset(190, 20));
    await drag.moveTo(origin + const Offset(63, 20));
    await tester.pump();
    expect(changes.last, 3.5);
    expect(await _sample(tester, const [Offset(50, 20), Offset(70, 20)]), [
      _unrated,
      _rated,
    ]);
    await drag.up();
  });

  testWidgets(
    'drag release before a frame paints the last proposal, then animates later changes',
    (tester) async {
      Widget control(
        double value,
        ValueChanged<double> onChanged, {
        double? maximum,
      }) => _app(
        RepaintBoundary(
          key: _painting,
          child: RatingBar(
            value: value,
            maxRating: maximum,
            glow: false,
            itemBuilder: _item,
            onChanged: onChanged,
            unratedColor: _unrated,
            animationDuration: const Duration(seconds: 1),
            animationCurve: Curves.linear,
          ),
        ),
      );
      final changes = <double>[];
      await tester.pumpWidget(control(1, changes.add));
      final origin = tester.getTopLeft(find.byKey(_painting));
      final drag = await tester.startGesture(origin + const Offset(25, 20));
      await drag.moveTo(origin + const Offset(80, 20));
      await tester.pumpWidget(control(changes.last, changes.add));
      await drag.moveTo(origin + const Offset(160, 20));
      await drag.up();
      await tester.pumpWidget(control(changes.last, changes.add));
      const sample = [Offset(142, 20)];
      expect(changes.last, 4);
      expect(await _sample(tester, sample), [_rated]);
      await tester.pumpWidget(control(4, changes.add, maximum: 10));
      expect(await _sample(tester, sample), [_rated]);
      await tester.pumpAndSettle();
      expect(await _sample(tester, sample), [_unrated]);
      await tester.pumpWidget(control(4, changes.add));
      await tester.pumpAndSettle();
      await tester.pumpWidget(control(1, changes.add));
      expect(await _sample(tester, sample), [_rated]);
      await tester.pumpAndSettle();
      expect(await _sample(tester, sample), [_unrated]);
      await tester.tapAt(origin + const Offset(150, 20));
      await tester.pumpWidget(control(changes.last, changes.add));
      expect(await _sample(tester, sample), [_unrated]);
      await tester.pumpAndSettle();
      expect(await _sample(tester, sample), [_rated]);
    },
  );

  testWidgets(
    'a drag that reaches an animating target settles the fill there',
    (tester) async {
      Widget control(double value) => _app(
        RepaintBoundary(
          key: _painting,
          child: RatingBar(
            value: value,
            glow: false,
            itemBuilder: _item,
            onChanged: (_) {},
            unratedColor: _unrated,
            animationDuration: const Duration(seconds: 1),
            animationCurve: Curves.linear,
          ),
        ),
      );
      await tester.pumpWidget(control(1));
      await tester.pumpWidget(control(4));
      await tester.pump(const Duration(milliseconds: 100));
      const sample = [Offset(142, 20)];
      expect(await _sample(tester, sample), [_unrated]);
      final origin = tester.getTopLeft(find.byKey(_painting));
      final drag = await tester.startGesture(origin + const Offset(20, 20));
      await drag.moveTo(origin + const Offset(160, 20));
      await drag.up();
      await tester.pump();
      expect(await _sample(tester, sample), [_rated]);
      await tester.pumpWidget(control(1));
      expect(await _sample(tester, sample), [_rated]);
      await tester.pumpAndSettle();
      expect(await _sample(tester, sample), [_unrated]);
    },
  );

  for (final change in ['disable', 'mode', 'axis']) {
    testWidgets(
      'retiring a drag on $change balances its callback and releases its press',
      (tester) async {
        final starts = <double>[];
        final oldEnds = <double>[];
        final newEnds = <double>[];
        final pressed = <bool>[];
        late StateSetter rebuild;
        var interrupted = false;
        var useOldCallback = true;
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return RatingBar(
                  gestureMode: interrupted && change == 'mode'
                      ? RatingGestureMode.tap
                      : RatingGestureMode.tapAndDrag,
                  direction: interrupted && change == 'axis'
                      ? Axis.vertical
                      : Axis.horizontal,
                  itemBuilder: _item,
                  onChanged: interrupted && change == 'disable' ? null : (_) {},
                  onChangeStart: starts.add,
                  onChangeEnd: useOldCallback
                      ? (value) => setState(() => oldEnds.add(value))
                      : newEnds.add,
                  mouseCursor: WidgetStateProperty.resolveWith((states) {
                    pressed.add(states.contains(WidgetState.pressed));
                    return null;
                  }),
                );
              },
            ),
          ),
        );
        final origin = tester.getTopLeft(find.byType(RatingBar));
        final drag = await tester.startGesture(origin + const Offset(20, 20));
        await drag.moveTo(origin + const Offset(120, 20));
        await tester.pump();
        expect(starts, hasLength(1));
        expect(pressed.last, isTrue);
        rebuild(() {
          interrupted = true;
          useOldCallback = false;
        });
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(oldEnds, [3.0]);
        expect(pressed.last, isFalse);
        await drag.up();
        rebuild(() => interrupted = false);
        await tester.pump();
        await tester.tapAt(origin + const Offset(175, 20));
        await tester.pump();
        expect(starts, hasLength(2));
        expect(newEnds, [5.0]);
        expect(oldEnds, [3.0]);
      },
    );
  }

  testWidgets(
    'controlled drag reports distinct proposals before the parent rebuilds',
    (tester) async {
      final changes = <double>[];
      final ends = <double>[];
      await tester.pumpWidget(
        _app(
          RatingBar(
            value: 2,
            itemBuilder: _item,
            onChanged: changes.add,
            onChangeEnd: ends.add,
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(RatingBar));
      final drag = await tester.startGesture(origin + const Offset(80, 20));
      await drag.moveTo(origin + const Offset(153, 20));
      await drag.moveTo(origin + const Offset(157, 20));
      await drag.moveTo(origin + const Offset(80, 20));
      await drag.up();
      await tester.pump();
      expect(changes, [4.0, 2.0]);
      expect(ends, [2.0]);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Rating')).value,
        '2.0 / 5.0',
      );
    },
  );

  testWidgets('a held tap commits against the current controlled value', (
    tester,
  ) async {
    final parent = ValueNotifier<double>(2);
    addTearDown(parent.dispose);
    final changes = <double>[];
    final ends = <double>[];
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<double>(
          valueListenable: parent,
          builder: (context, value, child) => RatingBar(
            value: value,
            itemBuilder: _item,
            onChanged: (rating) {
              changes.add(rating);
              parent.value = rating;
            },
            onChangeEnd: ends.add,
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byType(RatingBar));
    final gesture = await tester.startGesture(origin + const Offset(70, 20));
    await tester.pump(kPressTimeout);
    parent.value = 4;
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(changes, [2.0]);
    expect(ends, [2.0]);
    expect(parent.value, 2);
  });

  testWidgets('a rounded decimal drag target paints on the release frame', (
    tester,
  ) async {
    final parent = ValueNotifier<double>(0);
    addTearDown(parent.dispose);
    await tester.pumpWidget(
      _app(
        RepaintBoundary(
          key: _painting,
          child: ValueListenableBuilder<double>(
            valueListenable: parent,
            builder: (context, value, child) => RatingBar(
              value: value,
              maxRating: 1,
              step: 0.1,
              glow: false,
              animationDuration: const Duration(seconds: 1),
              unratedColor: _unrated,
              itemBuilder: _item,
              onChanged: (rating) => parent.value = (rating * 10).round() / 10,
            ),
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byKey(_painting));
    final drag = await tester.startGesture(origin + const Offset(5, 20));
    await drag.moveTo(origin + const Offset(60, 20));
    await drag.up();
    await tester.pump();
    expect(parent.value, 0.3);
    expect(await _sample(tester, const [Offset(42, 20), Offset(70, 20)]), [
      _rated,
      _unrated,
    ]);
  });

  testWidgets('a continuous tap clears a numerically equivalent rating', (
    tester,
  ) async {
    final changes = <double>[];
    await tester.pumpWidget(
      _app(
        RatingBar(
          value: 0.28,
          maxRating: 1,
          step: 0,
          itemBuilder: _item,
          onChanged: changes.add,
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byType(RatingBar));
    await tester.tapAt(origin + const Offset(56, 20));
    expect(changes, [0.0]);
  });

  testWidgets('a held tap uses the current position of a translated bar', (
    tester,
  ) async {
    final changes = <double>[];
    Widget shifted(double distance) => _app(
      Transform.translate(
        offset: Offset(distance, 0),
        child: RatingBar(itemBuilder: _item, onChanged: changes.add),
      ),
    );
    await tester.pumpWidget(shifted(0));
    final origin = tester.getTopLeft(find.byType(RatingBar));
    final gesture = await tester.startGesture(origin + const Offset(105, 20));
    await tester.pump(kPressTimeout);
    await tester.pumpWidget(shifted(40));
    await gesture.up();
    expect(changes, [2.0]);
  });

  testWidgets(
    'controlled resets allow feedback for a later selection of the same step',
    (tester) async {
      final haptics = <Object?>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      Widget control(double value) =>
          _app(RatingBar(value: value, itemBuilder: _item, onChanged: (_) {}));
      await tester.pumpWidget(control(2));
      final target =
          tester.getTopLeft(find.byType(RatingBar)) + const Offset(100, 20);
      await tester.tapAt(target);
      await tester.pumpWidget(control(3));
      await tester.pumpWidget(control(2));
      await tester.tapAt(target);
      await tester.pump();
      expect(haptics, List.filled(2, 'HapticFeedbackType.selectionClick'));
    },
  );

  for (final input in ['keyboard', 'semantics']) {
    testWidgets('a stationary hover yields to a rating set by $input', (
      tester,
    ) async {
      final changes = <double>[];
      await tester.pumpWidget(
        _app(
          RepaintBoundary(
            key: _painting,
            child: RatingBar(
              autofocus: true,
              initialValue: 1,
              enableHover: true,
              animationDuration: Duration.zero,
              unratedColor: _unrated,
              itemBuilder: _item,
              onChanged: changes.add,
            ),
          ),
        ),
      );
      await tester.pump();
      final origin = tester.getTopLeft(find.byKey(_painting));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: origin - const Offset(1, 1));
      addTearDown(mouse.removePointer);
      await mouse.moveTo(origin + const Offset(148, 20));
      await tester.pump();
      const points = [Offset(70, 20), Offset(140, 20)];
      expect(await _sample(tester, points), [_rated, _rated]);
      if (input == 'keyboard') {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      } else {
        tester.semantics.performAction(
          find.semantics.byLabel('Rating'),
          ui.SemanticsAction.increase,
        );
      }
      await tester.pump();
      expect(changes, [2.0]);
      expect(await _sample(tester, points), [_rated, _unrated]);
    });
  }

  for (final (maximum, step) in [(1e-10, 1e-11), (1e12, 1.0)]) {
    testWidgets('one step remains selectable on a scale of $maximum', (
      tester,
    ) async {
      final changes = <double>[];
      await tester.pumpWidget(
        _app(
          RatingBar(
            autofocus: true,
            initialValue: maximum / 2,
            maxRating: maximum,
            step: step,
            itemBuilder: _item,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(changes, [maximum / 2 + step]);
    });
  }

  testWidgets(
    'equivalent decimal tap boundaries keep their step and clear normally',
    (tester) async {
      final changes = <double>[];
      await tester.pumpWidget(
        _app(
          RatingBar(
            itemCount: 1,
            itemSize: 100,
            maxRating: 1,
            initialValue: 0.28,
            step: 0.02,
            itemBuilder: _item,
            onChanged: changes.add,
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(RatingBar));
      await tester.tapAt(origin + const Offset(28, 15));
      await tester.pump();
      expect(changes, [0.0]);
    },
  );

  testWidgets(
    'indicator clamps out-of-range values and paints upward half fills',
    (tester) async {
      Widget indicator(double value) => _app(
        RepaintBoundary(
          key: _painting,
          child: RatingBarIndicator(
            itemCount: 2,
            value: value,
            maxRating: 4,
            direction: Axis.vertical,
            verticalDirection: VerticalDirection.up,
            unratedColor: _unrated,
            animationDuration: const Duration(milliseconds: 100),
            animationCurve: Curves.linear,
            itemBuilder: _item,
          ),
        ),
      );
      const points = [Offset(20, 10), Offset(20, 30), Offset(20, 70)];
      await tester.pumpWidget(indicator(-1));
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Rating')).value,
        '0.0 / 4.0',
      );
      expect(await _sample(tester, points), [_unrated, _unrated, _unrated]);

      await tester.pumpWidget(indicator(8));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Rating')).value,
        '4.0 / 4.0',
      );
      expect(await _sample(tester, points), [_unrated, _unrated, _unrated]);
      await tester.pump(const Duration(milliseconds: 75));
      expect(await _sample(tester, points), [_unrated, _rated, _rated]);
      await tester.pumpAndSettle();
      expect(await _sample(tester, points), [_rated, _rated, _rated]);
    },
  );

  testWidgets('keyboard uses widget and theme feedback settings', (
    tester,
  ) async {
    final haptics = <Object?>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final changes = <double>[];
    Widget control({bool? enableFeedback}) => _app(
      RatingBar(
        autofocus: true,
        itemBuilder: _item,
        enableFeedback: enableFeedback,
        onChanged: changes.add,
      ),
      theme: ThemeData(
        extensions: const [RatingBarThemeData(enableFeedback: false)],
      ),
    );
    await tester.pumpWidget(control());
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(changes, [1.0]);
    expect(haptics, isEmpty);

    await tester.pumpWidget(control(enableFeedback: true));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(changes, [1.0, 5.0]);
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });

  testWidgets('assistive actions adjust a single labeled slider', (
    tester,
  ) async {
    final changes = <double>[];
    await tester.pumpWidget(
      _app(
        RatingBar(
          initialValue: 2,
          step: 0.5,
          semanticLabel: 'Review score',
          semanticValueFormatter: (value) => '$value stars',
          itemBuilder: (context, index) =>
              Icon(Icons.star, semanticLabel: 'Decoration $index'),
          onChanged: changes.add,
        ),
      ),
    );
    final control = find.semantics.byLabel('Review score');
    expect(control, findsOne);
    expect(find.semantics.byLabel(RegExp('Decoration')), findsNothing);
    final data = control.evaluate().single.getSemanticsData();
    expect(data.flagsCollection.isSlider, isTrue);
    expect(data.value, '2.0 stars');
    expect(data.increasedValue, '2.5 stars');
    expect(data.decreasedValue, '1.5 stars');
    expect(data.hasAction(ui.SemanticsAction.tap), isFalse);

    tester.semantics.performAction(control, ui.SemanticsAction.increase);
    await tester.pump();
    expect(control.evaluate().single.value, '2.5 stars');
    tester.semantics.performAction(control, ui.SemanticsAction.decrease);
    await tester.pump();
    expect(control.evaluate().single.value, '2.0 stars');
    expect(changes, [2.5, 2.0]);
  });

  testWidgets(
    'selecting the minimum validates and saves an initially unrated form',
    (tester) async {
      final form = GlobalKey<FormState>();
      double? saved;
      final changes = <double>[];
      await tester.pumpWidget(
        _app(
          Form(
            key: form,
            child: RatingBar.form(
              itemBuilder: _item,
              minRating: 1,
              validator: (value) =>
                  value == null || value < 1 ? 'Choose a rating' : null,
              onSaved: (value) => saved = value,
              onChanged: changes.add,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Choose a rating'), findsOneWidget);
      final origin = tester.getTopLeft(find.byType(RatingBar));
      await tester.tapAt(origin + const Offset(10, 20));
      await tester.pump();
      expect(changes, [1.0]);
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 1.0);
      form.currentState!.reset();
      expect(form.currentState!.validate(), isFalse);
    },
  );
}
