import 'package:auto_injector_devtools_extension/widgets/injector_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_injector_devtools_extension/widgets/app_widget.dart';
import 'package:auto_injector_devtools_extension/controllers/app_controller.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mocks.dart';

class _MockAppController extends Mock implements AppController {}

void main() {
  late AppController mockController;

  setUp(() {
    mockController = _MockAppController();

    when(() => mockController.loadInjectors()).thenAnswer((_) async {});
    when(() => mockController.isLoading).thenReturn(true);
    when(() => mockController.injectors).thenReturn([]);
  });

  tearDown(() {
    verify(() => mockController.isLoading).called(1);
    verify(() => mockController.error).called(1);
    verify(() => mockController.addListener(any())).called(1);
    verify(() => mockController.removeListener(any())).called(1);
    verifyNoMoreInteractions(mockController);
  });

  testWidgets('should display app title correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppWidget(controller: mockController),
      ),
    );

    expect(find.text('AutoInjector Monitor'), findsOneWidget);
    verify(() => mockController.loadInjectors()).called(1);
    verify(() => mockController.injectors).called(1);
  });

  testWidgets(
    'should display refresh button correctly and call loadInjectors',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppWidget(controller: mockController),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      verify(() => mockController.loadInjectors()).called(2);
      verify(() => mockController.injectors).called(1);
    },
  );

  testWidgets(
    'should display linear progress indicator when loading',
    (tester) async {
      when(() => mockController.isLoading).thenReturn(true);
      when(() => mockController.error).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: AppWidget(controller: mockController),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      verify(() => mockController.loadInjectors()).called(1);
      verify(() => mockController.injectors).called(1);
    },
  );

  testWidgets('should display error message when error is present',
      (tester) async {
    when(() => mockController.isLoading).thenReturn(false);
    when(() => mockController.error).thenReturn('Error message');

    await tester.pumpWidget(
      MaterialApp(
        home: AppWidget(controller: mockController),
      ),
    );

    expect(find.text('Error message'), findsOneWidget);
    verify(() => mockController.loadInjectors()).called(1);
  });

  testWidgets(
    'should display injector tiles when no error and not loading',
    (tester) async {
      when(() => mockController.injectors).thenReturn(
        [
          mockInjectorCommitted,
          mockInjectorUncommitted,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AppWidget(controller: mockController),
        ),
      );

      expect(find.byType(InjectorTileWidget), findsNWidgets(2));
      verify(() => mockController.loadInjectors()).called(1);
      verify(() => mockController.injectors).called(3);
    },
  );
}
