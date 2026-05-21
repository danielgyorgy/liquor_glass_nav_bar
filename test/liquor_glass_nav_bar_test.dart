import 'package:liquor_glass_nav_bar/liquor_glass_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pillKey = ValueKey('dark_liquid_glass_pill');

Widget _harness({
  required int index,
  required ValueChanged<int> onTap,
  List<LiquorGlassNavItem>? items,
}) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: LiquorGlassNavBar(
        currentIndex: index,
        onTap: onTap,
        items: items ??
            const [
              LiquorGlassNavItem(icon: Icons.home, label: 'Home'),
              LiquorGlassNavItem(
                icon: Icons.search,
                label: 'Search',
                badge: '2',
              ),
              LiquorGlassNavItem(icon: Icons.person, label: 'Me'),
            ],
      ),
    ),
  );
}

void main() {
  testWidgets('renders all items with labels', (tester) async {
    await tester.pumpWidget(_harness(index: 0, onTap: (_) {}));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
  });

  testWidgets('tapping an item reports its index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_harness(index: 0, onTap: taps.add));

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(taps, [1]);
  });

  testWidgets('shows badge text when provided', (tester) async {
    await tester.pumpWidget(_harness(index: 0, onTap: (_) {}));

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('dragging the pill snaps to a new index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_harness(index: 0, onTap: taps.add));
    await tester.pumpAndSettle();

    final barWidth = tester.getSize(find.byType(LiquorGlassNavBar)).width;
    final itemWidth = (barWidth - 32 /* margin */ - 16 /* padding */) / 3;

    await tester.drag(find.byKey(_pillKey), Offset(itemWidth * 2, 0));
    await tester.pumpAndSettle();

    expect(taps, isNotEmpty);
    expect(taps.last, greaterThan(0));
  });

  testWidgets('animates when currentIndex changes externally', (tester) async {
    await tester.pumpWidget(_harness(index: 0, onTap: (_) {}));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_harness(index: 2, onTap: (_) {}));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpAndSettle();

    expect(find.byType(LiquorGlassNavBar), findsOneWidget);
  });

  test('asserts at least two items', () {
    expect(
      () => LiquorGlassNavBar(
        currentIndex: 0,
        onTap: (_) {},
        items: const [LiquorGlassNavItem(icon: Icons.home)],
      ),
      throwsAssertionError,
    );
  });

  testWidgets('asserts currentIndex is in range', (tester) async {
    await tester.pumpWidget(_harness(index: 5, onTap: (_) {}));
    expect(tester.takeException(), isAssertionError);
  });
}
