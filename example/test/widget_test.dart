import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratings_plus_example/main.dart';

void main() {
  testWidgets(
    'the fractional value follows the rating and clears on a repeat tap',
    (tester) async {
      await tester.pumpWidget(const MyApp());

      final rating = find.bySemanticsLabel('Fractional rating');
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
}
