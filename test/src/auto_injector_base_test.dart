import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  late AutoInjector injector;

  setUp(() {
    injector = AutoInjector();
  });

  test('AutoInjector: add', () async {
    expect(injector.isAdded<TestDatasource>(), false);

    injector.add(TestDatasource.new);

    expect(injector.isAdded<TestDatasource>(), true);
  });

  test('AutoInjector: add after commit throw exception', () async {
    injector.add(TestDatasource.new);
    injector.commit();

    expect(() => injector.add(TestDatasource.new),
        throwsA(isA<AutoInjectorException>()));
  });

  test('AutoInjector: addInstance', () async {
    expect(injector.isAdded<String>(), false);

    injector.addInstance('Test');
    injector.commit();

    expect(injector.isAdded<String>(), true);

    expect(injector<String>(), 'Test');
  });

  test('AutoInjector: addSingleton', () async {
    expect(injector.isAdded<TestDatasource>(), false);
    expect(injector.isInstantiateSingleton<TestDatasource>(), false);

    injector.addSingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded<TestDatasource>(), true);
    expect(injector.isInstantiateSingleton<TestDatasource>(), true);

    final value1 = injector<TestDatasource>();
    final value2 = injector<TestDatasource>();

    expect(value1, value2);
  });

  test('AutoInjector: addLazySingleton', () async {
    expect(injector.isAdded<TestDatasource>(), false);
    expect(injector.isInstantiateSingleton<TestDatasource>(), false);

    injector.addLazySingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded<TestDatasource>(), true);
    expect(injector.isInstantiateSingleton<TestDatasource>(), false);

    final value1 = injector<TestDatasource>();
    expect(injector.isInstantiateSingleton<TestDatasource>(), true);

    final value2 = injector<TestDatasource>();

    expect(value1, value2);
  });

  test('AutoInjector: disposeSingleton', () async {
    expect(injector.isAdded<TestDatasource>(), false);
    expect(injector.isInstantiateSingleton<TestDatasource>(), false);

    injector.addSingleton(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded<TestDatasource>(), true);
    expect(injector.isInstantiateSingleton<TestDatasource>(), true);

    final instance = injector.disposeSingleton<TestDatasource>();
    expect(instance, isA<TestDatasource>());
    expect(injector.isAdded<TestDatasource>(), true);
    expect(injector.isInstantiateSingleton<TestDatasource>(), false);
  });

  test('Invalid added again', () {
    injector.add<TestDatasource>(TestDatasource.new);

    expect(() => injector.add(TestDatasource.new),
        throwsA(isA<AutoInjectorException>()));
  });

  group('AutoInjector: get', () {
    test('zero input', () {
      injector.add<TestDatasource>(TestDatasource.new);
      injector.commit();

      expect(injector.get<TestDatasource>(), isA<TestDatasource>());
    });

    test('Get instance with named params nullable', () {
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.commit();

      expect(injector.get<TestRepository>(), isA<TestRepository>());
    });

    test('Get instance with named params', () {
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get<TestRepository>(), isA<TestRepository>());
    });

    test('Get instance with positional params', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get<TestController>(), isA<TestController>());
    });

    test('Error when get not registred instance', () {
      try {
        injector.get<TestDatasource>();
        throw Exception('error');
      } on NotRegistredInstance catch (e) {
        expect(e.message, 'TestDatasource not registred.');
      }
    });

    test('Error when get not registred instance, 2 traces', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.commit();

      try {
        injector.get<TestRepository>();
        throw 'error';
      } on NotRegistredInstance catch (e) {
        expect(e.message,
            'TestDatasource not registred.\nTrace: TestRepository->TestDatasource');
      }
    });

    test('Error when get not registred instance, 3 traces', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.commit();
      try {
        injector.get<TestController>();
        throw 'error';
      } on NotRegistredInstance catch (e) {
        expect(e.message,
            'TestDatasource not registred.\nTrace: TestController->TestRepository->TestDatasource');
      }
    });
  });

  group('replaceInstance', () {
    test('change', () {
      injector.addInstance('Text');
      injector.commit();
      expect(injector.get<String>(), 'Text');

      injector.replaceInstance<String>('Changed');

      expect(injector.get<String>(), 'Changed');
    });

    test('Throw AutoInjectorException when have no added before', () {
      expect(() => injector.replaceInstance<String>('Changed'),
          throwsA(isA<AutoInjectorException>()));
    });
  });

  group('ParamsTransform', () {
    test('change', () {
      final injector = AutoInjector(paramTransforms: [
        (param) {
          if (param.className == 'String') {
            return param.addValue('Text');
          } else if (param.className == 'TestDatasource') {
            return param.addValue(TestDatasource());
          }
          return param;
        },
      ]);

      injector.add(TestRepository.new);
      injector.commit();

      expect(injector.get<TestRepository>(), isA<TestRepository>());
    });
  });
  group('addInjector', () {
    test('add 1 injector withless replace old instances', () {
      final injector = AutoInjector();
      final injectorOther = AutoInjector();

      injector.addInstance('Text');
      injectorOther.addInstance('Change');
      injectorOther.addInstance(1);
      injectorOther.addSingleton(TestDatasource.new);

      injector.addInjector(injectorOther);

      injector.commit();

      expect(injector.get<String>(), 'Text');
      expect(injector.get<int>(), 1);
      expect(injector.get<TestDatasource>(), isA<TestDatasource>());
    });
  });

  group('disposeSingletonsByTag', () {
    test('2 tagged instances', () {
      injector.addSingleton(() => 'test', tag: 'tag1');
      injector.addSingleton(() => true, tag: 'tag1');
      injector.addSingleton(() => 1);
      injector.commit();

      expect(injector.isInstantiateSingleton<String>(), true);
      expect(injector.isInstantiateSingleton<bool>(), true);
      expect(injector.isInstantiateSingleton<int>(), true);

      expect(injector.isAdded<String>(), true);
      expect(injector.isAdded<bool>(), true);
      expect(injector.isAdded<int>(), true);

      final disposed = [];

      injector.disposeSingletonsByTag('tag1', onRemoved: disposed.add);

      expect(disposed, ['test', true]);

      expect(injector.isInstantiateSingleton<String>(), false);
      expect(injector.isInstantiateSingleton<bool>(), false);
      expect(injector.isInstantiateSingleton<int>(), true);

      expect(injector.isAdded<String>(), true);
      expect(injector.isAdded<bool>(), true);
      expect(injector.isAdded<int>(), true);
    });
  });

  group('start with on', () {
    test('2 instances', () {
      final injector = AutoInjector(
        on: (i) {
          i.addInstance('Text');
          i.addInstance(1);
          i.commit();
        },
      );

      expect(injector.get<String>(), 'Text');
      expect(injector.get<int>(), 1);
    });
  });
}

class TestController {
  final TestRepository repository;

  TestController(this.repository);
}

class TestRepository {
  final String? text;
  final TestDatasource datasource;

  TestRepository({required this.datasource, this.text});
}

class TestDatasource {}
