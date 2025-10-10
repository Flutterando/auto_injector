import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  late AutoInjector injector;

  setUp(() {
    injector = AutoInjector();
  });

  tearDown(() => injector.disposeRecursive());

  const mockKey = 'mock-key';

  test('AutoInjector: add', () async {
    expect(injector.isAdded(key: mockKey), false);
    injector.add<TestDatasource>(TestDatasource.new, key: mockKey);
    injector.commit();

    expect(injector.isAdded<TestDatasource>(key: mockKey), true);
  });

  test(
      'AutoInjector: add with dynamic '
      'must return AutoInjector instance', () async {
    expect(injector.isAdded(key: mockKey), false);

    injector.add(TestDatasource.new, key: mockKey);

    expect(injector.isAdded(key: mockKey), true);
  });

  test('AutoInjector: add after commit throw exception', () async {
    injector.commit();

    expect(
      () => injector.add(TestDatasource.new, key: mockKey),
      throwsA(isA<AutoInjectorException>()),
    );
  });

  test('AutoInjector: addInstance', () async {
    expect(injector.isAdded(key: mockKey), false);

    injector.addInstance('Test', key: mockKey);
    injector.commit();

    expect(injector.isAdded(key: mockKey), true);
    expect(injector(key: mockKey), 'Test');
  });

  test('AutoInjector: get instance without tag should throw an exception',
      () async {
    injector.addInstance('Test', key: mockKey);
    injector.commit();

    expect(() => injector<String>(), throwsA(isA<UnregisteredInstance>()));
  });

  test('AutoInjector: addSingleton', () async {
    expect(injector.isAdded(key: mockKey), false);
    expect(injector.isInstantiateSingleton(key: mockKey), false);

    injector.addSingleton(TestDatasource.new, key: mockKey);
    injector.commit();

    expect(injector.isAdded(key: mockKey), true);
    expect(injector.isInstantiateSingleton(key: mockKey), true);

    final value1 = injector(key: mockKey);
    final value2 = injector(key: mockKey);

    expect(value1, value2);
  });

  test('AutoInjector: addLazySingleton', () async {
    expect(injector.isAdded(key: mockKey), false);
    expect(injector.isInstantiateSingleton(key: mockKey), false);

    injector.addLazySingleton(TestDatasource.new, key: mockKey);
    injector.commit();

    expect(injector.isAdded(key: mockKey), true);
    expect(injector.isInstantiateSingleton(key: mockKey), false);

    final value1 = injector.get(key: mockKey);
    expect(injector.isInstantiateSingleton(key: mockKey), true);

    final value2 = injector.get(key: mockKey);

    expect(value1, value2);
  });

  test('AutoInjector: disposeSingleton', () async {
    expect(injector.isAdded(key: mockKey), false);
    expect(injector.isInstantiateSingleton(key: mockKey), false);

    injector.addSingleton(TestDatasource.new, key: mockKey);
    injector.commit();

    expect(injector.isAdded(key: mockKey), true);
    expect(injector.isInstantiateSingleton(key: mockKey), true);

    final instance = injector.disposeSingleton(key: mockKey);
    expect(instance, isA<TestDatasource>());
    expect(injector.isAdded(key: mockKey), true);
    expect(injector.isInstantiateSingleton(key: mockKey), false);
  });

  test('Invalid added again', () {
    injector.add(TestDatasource.new, key: mockKey);

    expect(
      () => injector.add(TestDatasource.new, key: mockKey),
      throwsA(isA<AutoInjectorException>()),
    );
  });

  group('AutoInjector: get', () {
    test('zero input', () {
      injector.add(TestDatasource.new, key: mockKey);
      injector.commit();

      expect(injector.get(key: mockKey), isA<TestDatasource>());
    });

    test('Get instance with named params nullable', () {
      injector.add(TestRepository.new, key: 'mock-key-1');
      injector.add(TestDatasource.new);
      injector.commit();

      expect(injector.get(key: 'mock-key-1'), isA<TestRepository>());
    });

    test(
        'Get the right instance when key is provided and there are two '
        'different instances', () {
      injector.add(TestRepository.new, key: 'mock-key-1');
      injector.add(TestRepository.new, key: 'mock-key-2');
      injector.add(TestDatasource.new);
      injector.commit();

      final repository1 = injector.get(key: 'mock-key-1');
      final repository2 = injector.get(key: 'mock-key-2');
      expect(repository1.hashCode, isNot(repository2.hashCode));
    });

    test(
        'Get the first instance when key is NOT provided and there are two '
        'different instances', () {
      injector.add(TestRepository.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.commit();

      final repository1 = injector.get(key: mockKey);
      final repository2 = injector.get<TestRepository>();
      expect(repository1.hashCode, isNot(repository2.hashCode));
    });

    test('Get instance with named params with Map generics', () {
      injector.add(TestComplexNamed.new, key: mockKey);
      injector.commit();

      expect(injector.get(key: mockKey), isA<TestComplexNamed>());
    });

    test('Get instance with named params', () {
      injector.add(TestRepository.new, key: mockKey);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get(key: mockKey), isA<TestRepository>());
    });

    test('Get instance with positional params', () {
      injector.add(TestController.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get(key: mockKey), isA<TestController>());
    });

    test('Get instance with named params and positional params', () {
      injector.add(OtherRepository.new, key: mockKey);
      injector.add(TestDatasource.new);
      injector.addInstance('Test');
      injector.commit();

      expect(injector.get(key: mockKey), isA<OtherRepository>());
    });

    test('Error when get not registered instance', () {
      injector.commit();
      expect(
        () => injector.get(key: mockKey),
        throwsA(
          const TypeMatcher<UnregisteredInstance>().having(
            (e) => e.message,
            'message',
            equals('$mockKey unregistered.'),
          ),
        ),
      );
    });

    test('Error when get not registered instance, 2 traces', () {
      injector.add(TestRepository.new, key: mockKey);
      injector.commit();
      expect(
        () => injector.get(key: mockKey),
        throwsA(
          const TypeMatcher<UnregisteredInstance>().having(
            (e) => e.message,
            'message',
            equals('TestDatasource not registered.\n'
                'Trace: $mockKey->TestDatasource'),
          ),
        ),
      );
    });

    test('Error when get not registered instance, 3 traces', () {
      injector.add(TestController.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.commit();
      expect(
        () => injector.get(key: mockKey),
        throwsA(
          const TypeMatcher<UnregisteredInstance>().having(
            (e) => e.message,
            'message',
            equals('TestDatasource not registered.\n'
                'Trace: $mockKey->TestRepository->TestDatasource'),
          ),
        ),
      );
    });
  });

  group('replaceInstance', () {
    test('change', () {
      injector.addInstance('Text', key: mockKey);
      injector.commit();
      expect(injector.get(key: mockKey), 'Text');

      injector.replaceInstance('Changed', key: mockKey);

      expect(
        () => injector.get<String>(),
        throwsA(isA<UnregisteredInstance>()),
      );
      expect(injector.get(key: mockKey), 'Changed');
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

      injector.add(TestRepository.new, key: mockKey);
      injector.commit();

      expect(injector.get(key: mockKey), isA<TestRepository>());
    });
  });
  group('addInjector', () {
    test('add 1 injector without replace old instances', () {
      final injector = AutoInjector();
      final injectorOther = AutoInjector();

      injector.addInstance('Text', key: 'text-key');
      injectorOther.addInstance('Change', key: 'change-key');
      injectorOther.addInstance(1, key: '1-key');
      injectorOther.addSingleton(TestDatasource.new, key: 'datasource-key');

      injector.addInjector(injectorOther);

      injector.commit();

      expect(injector.get(key: 'text-key'), 'Text');
      expect(injector.get(key: '1-key'), 1);
      expect(injector.get(key: 'datasource-key'), isA<TestDatasource>());
    });
  });

  group('start with on', () {
    test('2 instances', () {
      final injector = AutoInjector(
        on: (i) {
          i.addInstance('Text', key: 'text-key');
          i.addInstance(1, key: '1-key');
          i.commit();
        },
      );

      expect(injector.get(key: 'text-key'), 'Text');
      expect(injector.get(key: '1-key'), 1);
    });
  });

  group('get with transform', () {
    test('change a injection', () {
      final ds = TestDatasource();
      injector.add(TestController.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.addInstance(ds);
      injector.commit();

      final dsChange = TestDatasource();

      final datasourceChangedHash = injector
          .get<TestController>(key: mockKey, transform: changeParam(dsChange))
          .repository
          .datasource
          .hashCode;

      expect(datasourceChangedHash != ds.hashCode, true);
      expect(datasourceChangedHash, dsChange.hashCode);
    });
  });

  group('try get', () {
    test('return a value', () {
      injector.add(TestController.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.add(TestDatasource.new);
      injector.commit();

      expect(injector.tryGet(key: mockKey), isA<TestController>());
    });
    test('return null if exception', () {
      injector.add(TestController.new, key: mockKey);
      injector.add(TestRepository.new);
      injector.commit();

      expect(injector.tryGet(key: mockKey), null);
    });
  });

  test('inversion of control', () {
    final injector = AutoInjector();
    injector.addLazySingleton(
      InversionOfControlImplementation.new,
      key: mockKey,
    );
    injector.commit();
    final instance = injector.get<InversionOfControlInterface>(key: mockKey);
    expect(instance, isA<InversionOfControlImplementation>());
  });

  test('Dispose', () {
    final injector = AutoInjector();
    injector.addSingleton(
      () => '',
      key: mockKey,
      config: BindConfig(
        notifier: (value) => 1,
        onDispose: expectAsync1((p0) => expect(p0, '')),
      ),
    );
    injector.commit();
    injector.disposeSingleton(key: mockKey);
  });
  test('Notifier', () {
    final injector = AutoInjector();
    injector.addInstance(
      '',
      key: mockKey,
      config: BindConfig(notifier: (value) => 1),
    );
    injector.commit();
    expect(injector.getNotifier(key: mockKey), 1);
  });

  test('WithNullableParams', () {
    injector.addInstance('String');
    injector.addSingleton(WithNullableParams.new, key: mockKey);
    injector.commit();

    expect(injector.bindLength, 2);
    expect(injector.get(key: mockKey), isA<WithNullableParams>());
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

class TestComplexNamed {
  final Map<String, dynamic>? value;
  final Map<String, List<Map<String, dynamic>>>? map;

  TestComplexNamed({this.value, this.map});
}

class TestDatasource {}

class OtherRepository {
  final String name;

  final TestDatasource datasource;

  OtherRepository(this.name, {required this.datasource});
}
