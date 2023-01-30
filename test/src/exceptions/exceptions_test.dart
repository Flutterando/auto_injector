import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  test('errors message', () async {
    const error = AutoInjectorException('Test', StackTrace.empty);
    expect(error.toString(), 'AutoInjectorException: Test\n');
  });
}
