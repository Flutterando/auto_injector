import 'bind.dart';
import 'errors/errors.dart';
import 'param.dart';

/// Automatic Dependency Injection System, but without build_runner :)
/// <br>
/// `[on]`: Helps with instance registration.<br>
/// `[paramObservers]`: List of functions that listen and transform parameters while they
/// are being parsed when requested by the `get()` method.
/// <Br><br>
/// ```dart
/// final injector = AutoInjector();
///
/// injector.add(MyDatasource.new);
///
/// injector.get<MyDatasource>();
/// ```
abstract class AutoInjector {
  final List<ParamTransform> _paramTransforms = [];
  final void Function(AutoInjector injector)? on;

  AutoInjector._(List<ParamTransform> paramObservers, this.on) {
    _paramTransforms.addAll(paramObservers);
  }

  /// Automatic Dependency Injection System, but without build_runner :)
  /// <br>
  /// `[on]`: Helps with instance registration.<br>
  /// `[paramObservers]`: List of functions that listen and transform parameters while they
  /// are being parsed when requested by the `get()` method.
  /// <Br><br>
  /// ```dart
  /// final injector = AutoInjector();
  ///
  /// injector.add(MyDatasource.new);
  ///
  /// injector.get<MyDatasource>();
  /// ```
  factory AutoInjector({
    List<ParamTransform> paramTransforms = const [],
    void Function(AutoInjector injector)? on,
  }) {
    return _AutoInjector(paramTransforms, on);
  }

  /// Request an instance by [Type]
  T get<T>();

  /// Request an instance by [Type]
  T call<T>() => get<T>();

  /// Register a factory instance.
  /// A new instance will be generated whenever requested.
  void add<T>(Function constructor);

  /// Register a instance.
  /// A concrete object (Not a function).
  void addInstance<T>(T instance);

  /// Register a Singleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started as soon as it is registered.
  void addSingleton<T>(Function constructor);

  /// Register a LazySingleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started only when requested the first time.
  void addLazySingleton<T>(Function constructor);

  /// Inherit all instance and transform records.
  void addInjector(AutoInjector injector);

  /// Checks if the instance record exists.
  bool isAdded<T>();

  /// checks if the instance registration is as singleton.
  bool isInstantiateSingleton<T>();

  /// Unregisters an instance by type.
  void remove<T>();

  /// Removes the singleton instance.<br>
  /// This does not remove it from the registry tree.
  void disposeSingleton<T>();

  /// Replaces an instance record with a concrete instance.<br>
  /// This function should only be used for unit testing.<br>
  /// Any other use is discouraged.
  void replaceInstance<T>(T instance);
}

class _AutoInjector extends AutoInjector {
  final _mapOfBinds = <String, Bind>{};
  final _singletonInstances = <String, dynamic>{};

  _AutoInjector(List<ParamTransform> paramTransforms, void Function(AutoInjector injector)? on) : super._(paramTransforms, on) {
    on?.call(this);
  }

  @override
  T get<T>() {
    try {
      final className = T.toString();
      final instance = _getByClassName(className);

      if (instance == null) {
        throw NotRegistredInstance([className], '$className not registred.');
      }

      return instance;
    } on NotRegistredInstance catch (e) {
      var trace = e.classNames.join('->');
      var message = e.message;
      if (e.classNames.length > 1) {
        message = '$message\nTrace: $trace';
      }
      throw NotRegistredInstance(e.classNames, message);
    }
  }

  @override
  void add<T>(Function constructor) => _add<T>(constructor);

  @override
  void addInstance<T>(T instance) => _add<T>(() => instance);

  @override
  void addSingleton<T>(Function constructor) {
    final className = _add<T>(
      constructor,
      BindType.singleton,
    );
    try {
      _getByClassName(className);
    } on NotRegistredInstance {
      throw AutoInjectorException(
        '''Singleton instances need to be added last.
Add `$className` at the end or use `addLazySingleton`''',
        StackTrace.current,
      );
    }
  }

  @override
  void addLazySingleton<T>(Function constructor) => _add<T>(
        constructor,
        BindType.lazySingleton,
      );

  @override
  void addInjector(covariant _AutoInjector injector) {
    for (var key in injector._mapOfBinds.keys) {
      if (!_mapOfBinds.containsKey(key)) {
        final bind = injector._mapOfBinds[key]!;
        if (bind.type == BindType.singleton) {
          addSingleton(bind.constructor);
        } else {
          _mapOfBinds[key] = bind;
        }
      }
    }

    _paramTransforms.addAll(injector._paramTransforms);
  }

  @override
  bool isAdded<T>() => _isAddedByClassName(T.toString());

  @override
  bool isInstantiateSingleton<T>() => _singletonInstances.containsKey(T.toString());

  @override
  void disposeSingleton<T>() => _disposeSingletonByClasseName(T.toString());

  @override
  void remove<T>() {
    var type = T.toString();
    _mapOfBinds.remove(type);
    _singletonInstances.remove(type);
  }

  @override
  void replaceInstance<T>(T instance) {
    final className = T.toString();
    if (!_isAddedByClassName(className)) {
      throw AutoInjectorException('$className cannot be replaced as it was not added before.', StackTrace.current);
    }
    remove<T>();
    addInstance<T>(instance);
  }

  String _add<T>(Function constructor, [BindType type = BindType.factory]) {
    final bind = Bind(
      constructor: constructor,
      type: type,
    );

    if (_isAddedByClassName(bind.className)) {
      throw AutoInjectorException('${bind.className} Class is already added.', StackTrace.current);
    }

    _mapOfBinds[bind.className] = bind;

    return bind.className;
  }

  dynamic _getByClassName(String className) {
    final singleton = _singletonInstances[className];

    if (singleton != null) {
      return singleton;
    }

    final bind = _mapOfBinds[className];

    if (bind == null) {
      return null;
    }

    late List<Param> params;

    try {
      params = _resolveParam(bind.params);
    } on NotRegistredInstance catch (e) {
      throw NotRegistredInstance(
        [className, ...e.classNames],
        e.message,
      );
    }

    final positionalParams = params //
        .whereType<PositionalParam>()
        .map((param) => param.value)
        .toList();

    final namedParams = params //
        .whereType<NamedParam>()
        .map((param) => {param.named: param.value})
        .fold(<Symbol, dynamic>{}, (value, element) => value..addAll(element));

    final instance = Function.apply(bind.constructor, positionalParams, namedParams);

    if (bind.type.isSingleton) {
      _singletonInstances[className] = instance;
    }

    return instance;
  }

  bool _isAddedByClassName(String className) => _mapOfBinds.containsKey(className);

  void _disposeSingletonByClasseName(String className) => _singletonInstances.remove(className);

  List<Param> _resolveParam(List<Param> params) {
    params = List<Param>.from(params);
    for (var i = 0; i < params.length; i++) {
      var param = _transforms(params[i]);
      if (param.value != null) {
        params[i] = param;
        continue;
      }
      final instance = _getByClassName(param.className);
      if (!param.isNullable && instance == null) {
        throw NotRegistredInstance([param.className], '${param.className} not registred.');
      }

      params[i] = param.addValue(instance);
    }

    return params;
  }

  Param _transforms(Param param) {
    return _paramTransforms.fold(param, (internalParam, transform) {
      return transform(internalParam);
    });
  }
}
