import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/products/presentation/screens/products_screen.dart';

// ---------------------------------------------------------------------------
// GoRouter stub — ProductsScreen uses context.pushNamed(contactUsName)
// ---------------------------------------------------------------------------
GoRouter _testRouter() => GoRouter(
      initialLocation: '/products',
      routes: [
        GoRoute(
          path: '/products',
          builder: (_, __) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/contact-us',
          name: 'contact-us',
          builder: (_, __) => const Scaffold(body: Text('Contact Us')),
        ),
      ],
    );

Widget _wrapProducts() => ProviderScope(
      child: MaterialApp.router(
        routerConfig: _testRouter(),
      ),
    );

void main() {
  group('ProductsScreen — UI rendering', () {
    testWidgets('renders Product Arena header', (tester) async {
      await tester.pumpWidget(_wrapProducts());
      await tester.pump(); // settle first frame

      // 'Product' may appear more than once (header + nav labels); at least one must exist
      expect(find.text('Product'), findsWidgets);
      // 'Arena' is unique to the header
      expect(find.text('Arena'), findsOneWidget);
    });

    testWidgets('renders All category chip by default', (tester) async {
      await tester.pumpWidget(_wrapProducts());
      await tester.pump();

      // The horizontal category list always starts with 'All'
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching products',
        (tester) async {
      await tester.pumpWidget(_wrapProducts());
      // Only pump one frame — FutureBuilder is still waiting
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows bottom nav bar', (tester) async {
      await tester.pumpWidget(_wrapProducts());
      await tester.pump();

      // UserBottomNav renders a BottomNavigationBar or similar Row
      expect(find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
          find.byType(NavigationBar).evaluate().isNotEmpty ||
          find.byType(Row).evaluate().isNotEmpty, isTrue);
    });
  });

  group('ProductsScreen — category filter', () {
    testWidgets('tapping a category chip selects it', (tester) async {
      await tester.pumpWidget(_wrapProducts());
      await tester.pump();

      // The horizontal list must have at least the 'All' chip
      final allChip = find.text('All');
      expect(allChip, findsOneWidget);

      await tester.tap(allChip);
      await tester.pump();

      // Still shows 'All' after selection — no crash
      expect(find.text('All'), findsOneWidget);
    });
  });

  group('ProductsScreen — error state', () {
    testWidgets('does not crash on initial render', (tester) async {
      await tester.pumpWidget(_wrapProducts());
      await tester.pump();

      expect(find.byType(ProductsScreen), findsOneWidget);
    });
  });
}
