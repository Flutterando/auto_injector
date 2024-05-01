import 'package:auto_injector_devtools_extension/widgets/bind_tile_widget.dart';
import 'package:auto_injector_devtools_extension/widgets/injector_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mocks.dart';

void main() {
  testWidgets(
    'injector tile widget displays correct information',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InjectorTileWidget(
              injector: mockInjectorCommitted,
            ),
          ),
        ),
      );

      expect(find.text('Test Injector'), findsOneWidget);
      expect(find.text('Binds: 3 | Injectors: 1'), findsOneWidget);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.byType(BindTileWidget), findsNWidgets(3));
    },
  );

  group('icon color', () {
    testWidgets('injector tile widget displays green icon when committed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InjectorTileWidget(
              injector: mockInjectorCommitted,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(
        (find.byIcon(Icons.check, skipOffstage: false).evaluate().first.widget
                as Icon)
            .color,
        equals(Colors.green),
      );
    });

    testWidgets('injector tile widget displays red icon when not committed',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InjectorTileWidget(
              injector: mockInjectorUncommitted,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        (find.byIcon(Icons.close, skipOffstage: false).evaluate().first.widget
                as Icon)
            .color,
        equals(Colors.red),
      );
    });
  });
}
