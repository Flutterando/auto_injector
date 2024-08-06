import 'package:auto_injector_devtools_extension/models/injector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mocks.dart';

void main() {
  group('compareTo', () {
    test('should compares the bind lengths correctly', () {
      expect(mockInjectorCommitted.compareTo(mockInjectorUncommitted), -1);
      expect(mockInjectorUncommitted.compareTo(mockInjectorCommitted), 1);
      expect(mockInjectorCommitted.compareTo(mockInjectorCommitted), 0);
    });
  });

  group('fromMap', () {
    test('should create an instance of Injector from a map', () {
      final result = Injector.fromMap(
        mockInjectorMap,
        mockInstanceFactories,
      );

      expect(result.tag, 'Test Injector');
      expect(result.bindLength, 3);
      expect(result.binds.length, 3);
      expect(result.injectorsList, ['Sub Injector']);
      expect(result.isCommitted, true);
    });
  });
}
