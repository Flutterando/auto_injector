import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  late AutoInjector injector;

  setUp(() {
    injector = AutoInjector();
    injector.removeAll();
  });

  test('AutoInjector: add', () async {
    expect(injector.isAdded<TestDatasource>(), false);
    injector.add(TestDatasource.new);
    injector.commit();

    expect(injector.isAdded<TestDatasource>(), true);
  });

  test('hasTag', () {
    const tag = 'tag';
    injector.uncommit();
    expect(injector.hasTag(tag), false);
    injector.add<TestDatasource>(TestDatasource.new, tag: tag);
    expect(injector.hasTag(tag), true);
  });

  test(
      'AutoInjector: add with dynamic '
      'must return AutoInjector instance', () async {
    expect(injector.isAdded<TestDatasource>(), false);

    injector.add(TestDatasource.new);

    expect(injector.isAdded<TestDatasource>(), true);
  });

  test('AutoInjector: add after commit throw exception', () async {
    injector.add(TestDatasource.new);
    injector.commit();

    expect(
      () => injector.add(TestDatasource.new),
      throwsA(isA<AutoInjectorException>()),
    );
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

    expect(
      () => injector.add(TestDatasource.new),
      throwsA(isA<AutoInjectorException>()),
    );
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

    test('Get instance with named params and positional params', () {
      injector.add(OtherRepository.new);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get<OtherRepository>(), isA<OtherRepository>());
    });

    test('Error when get not registered instance', () {
      try {
        injector.get<TestDatasource>();
        throw Exception('error');
      } on UnregisteredInstance catch (e) {
        e.toString();
        expect(e.message, 'TestDatasource unregistered.');
      }
    });

    test('Error when get not registered instance, 2 traces', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.commit();

      try {
        injector.get<TestRepository>();
        throw Exception();
      } on UnregisteredInstance catch (e) {
        expect(
          e.message,
          '''
TestDatasource not registered.\nTrace: TestRepository->TestDatasource'''
              .trim(),
        );
      }
    });

    test('Error when get not registered instance, 3 traces', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.commit();
      try {
        injector.get<TestController>();
        throw Exception();
      } on UnregisteredInstance catch (e) {
        expect(
          e.message,
          '''
TestDatasource not registered.\nTrace: TestController->TestRepository->TestDatasource'''
              .trim(),
        );
      }
    });
    test('Get instance by tag', () {
      injector
          .add<TestWithInterface>(TestWithInterfaceDefaultImplementation.new);
      injector.add<TestWithInterface>(
        TestWithInterfaceImplementation.new,
        tag: 'test1',
      );
      injector.add<TestWithInterface>(
        TestWithInterfaceImplementation2.new,
        tag: 'test2',
      );
      injector.commit();
      final defaultValue = injector.get<TestWithInterface>();
      final test1 = injector.get<TestWithInterface>(tag: 'test1');
      final test2 = injector.get<TestWithInterface>(tag: 'test2');

      expect(defaultValue, isA<TestWithInterfaceDefaultImplementation>());
      expect(test1, isA<TestWithInterfaceImplementation>());
      expect(test2, isA<TestWithInterfaceImplementation2>());
      expect(defaultValue.talk(), 'TestWithInterfaceDefaultImplementation');
      expect(test1.talk(), 'TestWithInterfaceImplementation');
      expect(test2.talk(), 'TestWithInterfaceImplementation2');
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
      expect(
        () => injector.replaceInstance<String>('Changed'),
        throwsA(isA<AutoInjectorException>()),
      );
    });
  });

  group('ParamsTransform', () {
    test('change', () {
      final injector = AutoInjector(
        paramTransforms: [
          (param) {
            if (param.className == 'String') {
              return param.setValue('Text');
            } else if (param.className == 'TestDatasource') {
              return param.setValue(TestDatasource());
            }
            return param;
          },
        ],
      );

      injector.add(TestRepository.new);
      injector.commit();

      expect(injector.get<TestRepository>(), isA<TestRepository>());
    });
  });
  group('addInjector', () {
    test('add 1 injector without replace old instances', () {
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

      expect(injector.isInstantiateSingleton<String>(tag: 'tag1'), true);
      expect(injector.isInstantiateSingleton<bool>(tag: 'tag1'), true);
      expect(injector.isInstantiateSingleton<int>(), true);

      expect(injector.isAdded<String>('tag1'), true);
      expect(injector.isAdded<bool>('tag1'), true);
      expect(injector.isAdded<int>(), true);

      final disposed = [];

      injector.disposeSingletonsByTag('tag1', onRemoved: disposed.add);

      expect(disposed, ['test', true]);

      expect(injector.isInstantiateSingleton<String>(tag: 'tag1'), false);
      expect(injector.isInstantiateSingleton<bool>(tag: 'tag1'), false);
      expect(injector.isInstantiateSingleton<int>(), true);

      expect(injector.isAdded<String>('tag1'), true);
      expect(injector.isAdded<bool>('tag1'), true);
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

  group('get with transform', () {
    test('change a injection', () {
      final ds = TestDatasource();
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.addInstance(ds);
      injector.commit();

      final dsChange = TestDatasource();

      final datasourceChangedHash = injector //
          .get<TestController>(transform: changeParam(dsChange))
          .repository
          .datasource
          .hashCode;

      expect(datasourceChangedHash != ds.hashCode, true);
      expect(datasourceChangedHash, dsChange.hashCode);
    });
  });

  group('try get', () {
    test('return a value', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.commit();

      expect(injector.tryGet<TestController>(), isA<TestController>());
    });
    test('return null if exception', () {
      injector.add(TestController.new);
      injector.add(TestRepository.new);
      injector.commit();

      expect(injector.tryGet<TestController>(), null);
    });
  });

  test('inversion of control', () {
    final injector = AutoInjector();
    injector.addLazySingleton<InversionOfControlInterface>(
      InversionOfControlImplementation.new,
    );
    injector.commit();
    final instance = injector.get<InversionOfControlInterface>();
    expect(instance, isA<InversionOfControlImplementation>());
  });

  test('Dispose', () {
    final injector = AutoInjector();
    injector.addSingleton<String>(
      () => '',
      config: BindConfig(
        notifier: (value) {
          return 1;
        },
        onDispose: expectAsync1(
          (p0) {
            expect(p0, '');
          },
        ),
      ),
    );
    injector.commit();
    injector.disposeSingleton<String>();
  });
  test('Notifier', () {
    final injector = AutoInjector();
    injector.addInstance<String>(
      '',
      config: BindConfig(
        notifier: (value) {
          return 1;
        },
      ),
    );
    injector.commit();
    expect(injector.getNotifier<String>(), 1);
  });
  test('Notifier Assert if Generic Object', () {
    final injector = AutoInjector();

    expect(
      () => injector.addInstance(
        '',
        config: BindConfig(
          notifier: (value) {
            return 1;
          },
        ),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('removeByTag', () {
    injector.addInstance('String', tag: 'tag');
    injector.addInstance(0);
    injector.commit();

    expect(injector.bindLength, 2);
    injector.removeByTag('tag');
    expect(injector.bindLength, 1);
  });

  test('WithNullableParams', () {
    injector.addInstance('String');
    injector.addSingleton(WithNullableParams.new);
    injector.commit();

    expect(injector.bindLength, 2);
    expect(injector.get<WithNullableParams>(), isA<WithNullableParams>());
  });

  test('Added same class name binds with different tags', () {
    injector.addInstance('String', tag: '1');
    injector.addInstance('String', tag: '2');

    expect(injector.bindLength, 2);
  });
}

class WithNullableParams {
  final String text;
  final double? number;
  final bool isBoolean;

  WithNullableParams(this.text, {this.number = 0, this.isBoolean = true});
}

abstract class InversionOfControlInterface {}

class InversionOfControlImplementation implements InversionOfControlInterface {}

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

class OtherRepository {
  final String name;

  final TestDatasource datasource;

  OtherRepository(this.name, {required this.datasource});
}

abstract class TestWithInterface {
  String talk();
}

class TestWithInterfaceDefaultImplementation implements TestWithInterface {
  @override
  String talk() {
    return 'TestWithInterfaceDefaultImplementation';
  }
}

class TestWithInterfaceImplementation implements TestWithInterface {
  @override
  String talk() {
    return 'TestWithInterfaceImplementation';
  }
}

class TestWithInterfaceImplementation2 implements TestWithInterface {
  @override
  String talk() {
    return 'TestWithInterfaceImplementation2';
  }
}
