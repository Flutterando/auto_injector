import 'package:auto_injector_devtools_extension/models/bind.dart';
import 'package:auto_injector_devtools_extension/models/injector.dart';

Bind get mockBindFactory => Bind(
      key: 'factoryKey',
      className: 'FactoryClass',
      typeName: 'factory',
      hasInstanceIfSingleton: false,
      totalInstances: 3,
      params: [],
    );

Bind get mockBindSingleton => Bind(
      key: 'singletonKey',
      className: 'SingletonClass',
      typeName: 'singleton',
      hasInstanceIfSingleton: true,
      params: [],
    );

Bind get mockBindLazySingleton => Bind(
      key: 'lazySingletonKey',
      className: 'LazySingletonClass',
      typeName: 'lazySingleton',
      hasInstanceIfSingleton: false,
      params: [],
    );

Injector get mockSubInjector => Injector(
      tag: 'Sub Injector',
      bindLength: 1,
      isCommitted: true,
      binds: [
        mockBindFactory,
      ],
      injectorsList: [],
    );

Injector get mockInjectorCommitted => Injector(
      tag: 'Test Injector',
      bindLength: 3,
      isCommitted: true,
      binds: [
        mockBindFactory,
        mockBindSingleton,
        mockBindLazySingleton,
      ],
      injectorsList: [
        'Sub Injector',
      ],
    );

Injector get mockInjectorUncommitted => Injector(
      tag: 'Test Injector',
      bindLength: 2,
      isCommitted: false,
      binds: [
        mockBindFactory,
        mockBindSingleton,
      ],
      injectorsList: [
        'Sub Injector',
      ],
    );

Map<String, dynamic> get mockInjectorMap => {
      'tag': 'Test Injector',
      'bindLength': 3,
      'binds': [
        {
          'key': 'factoryKey',
          'className': 'FactoryClass',
          'typeName': 'factory',
          'hasInstanceIfSingleton': false,
          'params': [],
        },
        {
          'key': 'singletonKey',
          'className': 'SingletonClass',
          'typeName': 'singleton',
          'hasInstanceIfSingleton': true,
          'params': [],
        },
        {
          'key': 'lazySingletonKey',
          'className': 'LazySingletonClass',
          'typeName': 'lazySingleton',
          'hasInstanceIfSingleton': false,
          'params': [],
        },
      ],
      'injectorsList': [
        'Sub Injector',
      ],
      'committed': true,
    };

Map<String, Map<String, int>> get mockInstanceFactories => {
      'Test Injector': {
        'factoryKey': 3,
      }
    };
