import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_injector_devtools_extension/widgets/bind_tile_widget.dart';

import '../mocks/mocks.dart';

void main() {
  testWidgets(
    'should displays bind information correctly',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BindTileWidget(bind: mockBindFactory),
          ),
        ),
      );

      expect(find.text('Key: factoryKey'), findsOneWidget);
      expect(find.text('Name: FactoryClass'), findsOneWidget);
      expect(find.text('Type: factory'), findsOneWidget);
      expect(find.text('CREATED 3x'), findsOneWidget);
    },
  );

  testWidgets(
    'should displays bind information correctly when instantiated',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BindTileWidget(bind: mockBindSingleton),
          ),
        ),
      );

      expect(find.text('Key: singletonKey'), findsOneWidget);
      expect(find.text('Name: SingletonClass'), findsOneWidget);
      expect(find.text('Type: singleton'), findsOneWidget);
      expect(find.text('INSTANTIATED'), findsOneWidget);
    },
  );

  testWidgets(
    'should displays bind information correctly when not instantiated',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BindTileWidget(bind: mockBindLazySingleton),
          ),
        ),
      );

      expect(find.text('Key: lazySingletonKey'), findsOneWidget);
      expect(find.text('Name: LazySingletonClass'), findsOneWidget);
      expect(find.text('Type: lazySingleton'), findsOneWidget);
      expect(find.text('NOT INSTANTIATED'), findsOneWidget);
    },
  );
}
