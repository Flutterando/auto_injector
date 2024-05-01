import 'package:flutter_test/flutter_test.dart';
import 'package:auto_injector_devtools_extension/models/bind.dart';

import '../mocks/mocks.dart';

void main() {
  group('hasInstance', () {
    test('should return true when has instance', () {
      final bind = Bind(
        className: 'MyClass',
        typeName: 'singleton',
        hasInstanceIfSingleton: true,
        key: 'myKey',
        params: [],
        totalInstances: null,
      );
      expect(bind.hasInstance, true);
    });

    test('should return false when is not have instance', () {
      final bind = Bind(
        className: 'MyClass',
        typeName: 'factory',
        hasInstanceIfSingleton: false,
        key: 'myKey',
        params: [],
        totalInstances: 0,
      );
      expect(bind.hasInstance, false);
    });

    test('should return false when has total instance', () {
      final bind = Bind(
        className: 'MyClass',
        typeName: 'factory',
        hasInstanceIfSingleton: true,
        key: 'myKey',
        params: [],
        totalInstances: 5,
      );
      expect(bind.hasInstance, true);
    });
  });

  group('compareTo', () {
    test('should compare correctly', () {
      final instanceBind = Bind(
        className: 'MyClass',
        typeName: 'instance',
        hasInstanceIfSingleton: true,
        key: 'myKey',
        params: [],
        totalInstances: null,
      );

      expect(instanceBind.compareTo(instanceBind), 0);
      expect(instanceBind.compareTo(mockBindFactory), -1);
      expect(instanceBind.compareTo(mockBindSingleton), -1);
      expect(instanceBind.compareTo(mockBindLazySingleton), -1);

      expect(mockBindFactory.compareTo(mockBindFactory), 0);
      expect(mockBindFactory.compareTo(instanceBind), 1);
      expect(mockBindFactory.compareTo(mockBindSingleton), 1);
      expect(mockBindFactory.compareTo(mockBindLazySingleton), -1);

      expect(mockBindSingleton.compareTo(mockBindSingleton), 0);
      expect(mockBindSingleton.compareTo(instanceBind), 1);
      expect(mockBindSingleton.compareTo(mockBindFactory), -1);
      expect(mockBindSingleton.compareTo(mockBindLazySingleton), -1);

      expect(mockBindLazySingleton.compareTo(mockBindLazySingleton), 0);
      expect(mockBindLazySingleton.compareTo(instanceBind), 1);
      expect(mockBindLazySingleton.compareTo(mockBindFactory), 1);
      expect(mockBindLazySingleton.compareTo(mockBindSingleton), 1);
    });
  });

  group('fromMap', () {
    test('should create an instance of Bind from a map', () {
      final result = Bind.fromMap(
        {
          'className': 'MyClass',
          'typeName': 'singleton',
          'hasInstance': true,
          'key': 'myKey',
          'params': [],
        },
        5,
      );

      expect(result.className, 'MyClass');
      expect(result.typeName, 'singleton');
      expect(result.hasInstanceIfSingleton, true);
      expect(result.key, 'myKey');
      expect(result.params.length, 0);
      expect(result.totalInstances, 5);
    });
  });
}
