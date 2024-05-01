import 'package:flutter_test/flutter_test.dart';
import 'package:auto_injector_devtools_extension/models/param.dart';

void main() {
  group('fromMap', () {
    test('should create a Param object from a map', () {
      final map = {
        'type': 'int',
        'className': 'MyClass',
        'isNullable': true,
        'isRequired': false,
      };

      final param = Param.fromMap(map);

      expect(param.type, 'int');
      expect(param.className, 'MyClass');
      expect(param.isNullable, true);
      expect(param.isRequired, false);
    });
  });
}
