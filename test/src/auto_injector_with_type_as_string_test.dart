import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  late AutoInjector injector;

  setUp(() {
    injector = AutoInjector();
  });

  tearDown(() => injector.disposeRecursive());

  test('AutoInjector: add', () async {
    expect(injector.isAdded(className: 'TestDatasource'), false);
    injector.addSingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded(className: 'TestDatasource'), true);
  });

  test('AutoInjector: addInstance', () async {
    expect(injector.isAdded(className: 'String'), false);

    injector.addInstance('Test');
    injector.commit();

    expect(injector.isAdded(className: 'String'), true);
    expect(injector.get(className: 'String'), 'Test');
  });

  test('AutoInjector: addSingleton', () async {
    expect(injector.isAdded(className: 'TestDatasource'), false);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      false,
    );

    injector.addSingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded(className: 'TestDatasource'), true);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      true,
    );

    final value1 = injector<TestDatasource>();
    final value2 = injector(className: 'TestDatasource');

    expect(value1, value2);
  });

  test('AutoInjector: addLazySingleton', () async {
    expect(injector.isAdded(className: 'TestDatasource'), false);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      false,
    );

    injector.addLazySingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded(className: 'TestDatasource'), true);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      false,
    );
    final value1 = injector<TestDatasource>();

    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      true,
    );

    final value2 = injector(className: 'TestDatasource');

    expect(value1, value2);
  });

  test('AutoInjector: disposeSingleton', () async {
    expect(injector.isAdded(className: 'TestDatasource'), false);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      false,
    );

    injector.addSingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded(className: 'TestDatasource'), true);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      true,
    );

    final instance = injector.disposeSingleton(className: 'TestDatasource');
    expect(instance, isA<TestDatasource>());
    expect(injector.isAdded(className: 'TestDatasource'), true);
    expect(
      injector.isInstantiateSingleton(className: 'TestDatasource'),
      false,
    );
  });
}

class TestDatasource {}
