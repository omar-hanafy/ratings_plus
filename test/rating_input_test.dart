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
