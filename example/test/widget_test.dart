import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus_example/main.dart';

void main() {
  testWidgets(
    'the fractional value follows the rating and clears on a repeat tap',
    (tester) async {
      await tester.pumpWidget(const MyApp());

      final rating = find.bySemanticsLabel('Fractional rating');
      await tester.ensureVisible(rating);
      await tester.pumpAndSettle();

      expect(find.text('Value: 2.5'), findsOneWidget);
      expect(tester.getSemantics(rating).value, '2.5 / 5.0');

      final bar = tester.getRect(rating);
      expect(bar.size, const Size(240, 48));
      final fourthStarLeadingHalf =
          bar.centerLeft + Offset(bar.width * 0.65, 0);
      await tester.tapAt(fourthStarLeadingHalf);
      await tester.pumpAndSettle();
      expect(find.text('Value: 3.5'), findsOneWidget);
      expect(tester.getSemantics(rating).value, '3.5 / 5.0');

      await tester.tapAt(fourthStarLeadingHalf);
      await tester.pumpAndSettle();
      expect(find.text('Value: 0.0'), findsOneWidget);
      expect(tester.getSemantics(rating).value, '0.0 / 5.0');
    },
  );

  testWidgets('scrolling from the fractional rating preserves its value', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final rating = find.bySemanticsLabel('Fractional rating');
    await tester.ensureVisible(rating);
    await tester.pumpAndSettle();

    final bar = tester.getRect(rating);
    final gesture = await tester.startGesture(
      bar.centerLeft + Offset(bar.width * 0.85, 0),
    );
    await tester.pump(kPressTimeout);
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -40));
    await gesture.up();
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.getSemantics(rating).value, '2.5 / 5.0');
    expect(find.text('Value: 2.5'), findsOneWidget);
  });

  testWidgets('the required rating validates selection and clearing', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.byType(Form));
    await tester.pumpAndSettle();
    final rating = find.bySemanticsLabel('Form rating');
    final error = find.text('Please select a rating');
    expect(error, findsOneWidget);
    expect(tester.getSemantics(rating).value, '0.0 / 5.0');

    await tester.tap(rating);
    await tester.pumpAndSettle();
    expect(error, findsNothing);
    expect(tester.getSemantics(rating).value, '3.0 / 5.0');

    await tester.tap(rating);
    await tester.pumpAndSettle();
    expect(error, findsOneWidget);
    expect(tester.getSemantics(rating).value, '0.0 / 5.0');
  });

  testWidgets('switching to playground updates live preview and code snippet', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Playground'));
    await tester.pumpAndSettle();

    expect(find.text('Live Interactive Preview'), findsOneWidget);
    expect(find.text('Generated Dart Snippet'), findsOneWidget);

    final heartsChip = find.text('Hearts');
    await tester.ensureVisible(heartsChip);
    await tester.pumpAndSettle();
    await tester.tap(heartsChip);
    await tester.pumpAndSettle();

    final snippet = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(snippet.data, contains('Icons.favorite_rounded'));
  });

  testWidgets('theme and RTL toggles update app configuration', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.text('LTR'));
    await tester.pumpAndSettle();
    expect(find.text('RTL'), findsOneWidget);

    final context = tester.element(find.text('Ratings Plus'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('responsive layouts render cleanly on mobile and desktop sizes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in const [Size(390, 844), Size(1280, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MyApp(initialView: DemoView.playground));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
