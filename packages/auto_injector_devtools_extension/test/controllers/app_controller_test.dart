import 'package:auto_injector_devtools_extension/controllers/app_controller.dart';
import 'package:devtools_app_shared/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vm_service/vm_service.dart';

import '../mocks/mocks.dart';

// ignore: subtype_of_sealed_class
class _MockServiceManager extends Mock implements ServiceManager {}

class _FakeResponse implements Response {
  @override
  String get type => 'type';

  @override
  Map<String, dynamic>? json = {
    'injectors': [mockInjectorMap],
    'instanceFactories': mockInstanceFactories,
  };

  @override
  Map<String, dynamic> toJson() {
    return json ?? {};
  }
}

void main() {
  late AppController appController;
  late ServiceManager mockServiceManager;

  setUp(() {
    mockServiceManager = _MockServiceManager();
    appController = AppController(serviceManager: mockServiceManager);
  });

  tearDown(() {
    verifyNoMoreInteractions(mockServiceManager);
  });

  group('loadInjectors', () {
    test(
      'should update injectors list when successful',
      () async {
        when(() => mockServiceManager.callServiceExtensionOnMainIsolate(any()))
            .thenAnswer((_) async => _FakeResponse());

        await appController.loadInjectors();

        expect(appController.isLoading, false);
        expect(appController.error, isNull);
        expect(appController.injectors.length, 1);

        verify(() => mockServiceManager.callServiceExtensionOnMainIsolate(
              'ext.auto_injector.getInjectors',
            )).called(1);
      },
    );

    test(
      'should update error when an exception occurs',
      () async {
        const errorMessage = 'An error occurred';
        when(() => mockServiceManager.callServiceExtensionOnMainIsolate(any()))
            .thenThrow(errorMessage);

        await appController.loadInjectors();

        expect(appController.isLoading, false);
        expect(appController.error, errorMessage);
        expect(appController.injectors.length, 0);
        verify(() => mockServiceManager.callServiceExtensionOnMainIsolate(
              'ext.auto_injector.getInjectors',
            ));
      },
    );
  });

  group('sortBinds', () {
    test('should sort the binds for each injector', () {
      appController.injectors = [
        mockInjectorCommitted,
        mockInjectorUncommitted
      ];

      appController.sortBinds();

      expect(
        appController.injectors[0].binds.map((e) => e.typeName).toList(),
        [
          'singleton',
          'factory',
          'lazySingleton',
        ],
      );

      expect(
        appController.injectors[1].binds.map((e) => e.typeName).toList(),
        [
          'singleton',
          'factory',
        ],
      );
    });
  });
}
