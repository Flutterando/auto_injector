import 'bind.dart';
import 'errors/errors.dart';
import 'param.dart';

/// Automatic Dependency Injection System, but without build_runner :)
/// <br>
/// `[tag]`: AutoInject instance identity.<br>
/// `[on]`: Helps with instance registration.<br>
/// `[paramObservers]`: List of functions that listen and transform parameters while they
/// are being parsed when requested by the `get()` method.
/// <br><br>
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
  final String _tag;

  AutoInjector._(this._tag, List<ParamTransform> paramObservers, this.on) {
    _paramTransforms.addAll(paramObservers);
  }

  /// Automatic Dependency Injection System, but without build_runner :)
  /// <br>
  /// `[tag]`: AutoInject instance identity.<br>
  /// `[on]`: Helps with instance registration.<br>
  /// `[paramObservers]`: List of functions that listen and transform parameters while they
  /// are being parsed when requested by the `get()` method.
  /// <br><br>
  /// ```dart
  /// final injector = AutoInjector();
  ///
  /// injector.add(MyDatasource.new);
  ///
  /// injector.get<MyDatasource>();
  /// ```
  factory AutoInjector({
    String? tag,
    List<ParamTransform> paramTransforms = const [],
    void Function(AutoInjector injector)? on,
  }) {
    tag ??= 'container:${DateTime.now().millisecondsSinceEpoch}-injector';
    return _AutoInjector(tag, paramTransforms, on);
  }

  /// Request an instance by [Type]
  /// <br>
  /// [transform]: Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  T get<T>({ParamTransform? transform});

  /// Request an instance by [Type]
  /// <br>
  /// [transform]: Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  T call<T>({
    ParamTransform? transform,
  }) =>
      get<T>(transform: transform);

  /// Request an instance by [Type] that when throwing an exception returns null.
  /// <br>
  /// [transform]: Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  T? tryGet<T>({ParamTransform? transform});

  /// Register a factory instance.
  /// A new instance will be generated whenever requested.
  /// ```dart
  /// injector.add(MyController.new);
  /// ```
  void add<T>(Function constructor, {String? tag});

  /// Register a instance.
  /// A concrete object (Not a function).
  /// ```dart
  /// injector.addInstance(MyController());
  /// ```
  void addInstance<T>(T instance, {String? tag});

  /// Register a Singleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started as soon as it is registered.
  /// ```dart
  /// injector.addSingleton(MyController.new);
  /// ```
  void addSingleton<T>(Function constructor, {String? tag});

  /// Register a LazySingleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started only when requested the first time.
  /// ```dart
  /// injector.addLazySingleton(MyController.new);
  /// ```
  void addLazySingleton<T>(Function constructor, {String? tag});

  /// Inherit all instances and transforms from other AutoInjector object.
  /// ```dart
  /// final injector = AutoInjector();
  /// final otherInjector = AutoInjector();
  ///
  /// injector.addInjector(otherInjector);
  /// ```
  void addInjector(AutoInjector injector);

  /// Checks if the instance record exists.
  bool isAdded<T>();

  /// checks if the instance registration is as singleton.
  bool isInstantiateSingleton<T>();

  /// Removes the singleton instance.<br>
  /// This does not remove it from the registry tree.
  T? disposeSingleton<T>();

  /// Removes singleton instances by tag.<br>
  /// This does not remove it from the registry tree.
  void disposeSingletonsByTag(String tag, {void Function(dynamic instance)? onRemoved});

  /// Replaces an instance record with a concrete instance.<br>
  /// This function should only be used for unit testing.<br>
  /// Any other use is discouraged.
  void replaceInstance<T>(T instance);

  /// Informs the container that the additions
  /// are finished and the injector is ready to be used.<br>
  /// This command starts the singletons.
  void commit();
}

class _AutoInjector extends AutoInjector {
  final _binds = <Bind>[];
  var _commited = false;

  _AutoInjector(
    String tag,
    List<ParamTransform> paramTransforms,
    void Function(AutoInjector injector)? on,
  ) : super._(tag, paramTransforms, on) {
    on?.call(this);
  }

  @override
  T get<T>({ParamTransform? transform}) {
    _checkAutoInjectorIsCommited();

    try {
      final className = T.toString();
      final instance = _resolveInstanceByClassName(className, transform);

      if (instance == null) {
        throw UnregisteredInstance([className], '$className unregistered.');
      }

      return instance;
    } on UnregisteredInstance catch (exception) {
      throw _prepareExceptionTrace(exception);
    }
  }

  @override
  T? tryGet<T>({ParamTransform? transform}) {
    try {
      return get<T>(transform: transform);
    } catch (e) {
      return null;
    }
  }

  @override
  void add<T>(Function constructor, {String? tag}) {
    _add<T>(constructor, tag ?? _tag);
  }

  @override
  void addInstance<T>(T instance, {String? tag}) {
    _add<T>(() => instance, tag ?? _tag, BindType.instance, instance);
  }

  @override
  void addSingleton<T>(Function constructor, {String? tag}) {
    _add<T>(constructor, tag ?? _tag, BindType.singleton);
  }

  @override
  void addLazySingleton<T>(Function constructor, {String? tag}) => _add<T>(
        constructor,
        tag ?? _tag,
        BindType.lazySingleton,
      );

  @override
  void addInjector(covariant _AutoInjector injector) {
    for (var bind in injector._binds) {
      final index = _binds.indexWhere((bindElement) => bindElement.className == bind.className);
      if (index == -1) {
        _binds.add(bind);
      }
    }

    _paramTransforms.addAll(injector._paramTransforms);
  }

  @override
  bool isAdded<T>() => _isAddedByClassName(T.toString());

  @override
  bool isInstantiateSingleton<T>() {
    final className = T.toString();
    final bind = _getBindByClassName(className);
    return bind?.hasInstance ?? false;
  }

  @override
  T? disposeSingleton<T>() {
    return _disposeSingletonByClasseName(T.toString()) as T?;
  }

  @override
  void disposeSingletonsByTag(String tag, {void Function(dynamic instance)? onRemoved}) {
    for (var index = 0; index < _binds.where((bind) => bind.tag == tag).length; index++) {
      final bind = _binds[index];
      final instance = _disposeSingletonByClasseName(bind.className);
      onRemoved?.call(instance);
    }
  }

  @override
  void replaceInstance<T>(T instance) {
    final className = T.toString();
    if (!_isAddedByClassName(className)) {
      throw AutoInjectorException(
        '$className cannot be replaced as it was not added before.',
        StackTrace.current,
      );
    }
    final index = _binds.indexWhere((bind) => bind.className == className);

    var bind = Bind.withInstance<T>(instance, _binds[index].tag);

    _binds[index] = bind;
  }

  @override
  void commit() {
    _binds //
        .where((bind) => bind.type == BindType.singleton)
        .map((bind) => bind.className)
        .forEach(_resolveInstanceByClassName);

    _commited = true;
  }

  void _checkAutoInjectorIsCommited() {
    if (!_commited) {
      const message = r'''This injector is not committed.
It is recommended to call the "commit()" method after adding instances.''';
      print('\x1B[33m$message\x1B[0m');
    }
  }

  UnregisteredInstance _prepareExceptionTrace(UnregisteredInstance exception) {
    var trace = exception.classNames.join('->');
    var message = exception.message;
    if (exception.classNames.length > 1) {
      message = '$message\nTrace: $trace';
    }
    return UnregisteredInstance(exception.classNames, message);
  }

  dynamic _resolveInstanceByClassName(
    String className, [
    ParamTransform? transform,
  ]) {
    var bind = _getBindByClassName(className);

    if (bind == null) {
      return null;
    }

    if (bind.hasInstance) {
      return bind.instance;
    }

    bind = _resolveBind(bind, transform);

    if (bind.type.isSingleton) {
      _updateBinds(bind);
    }

    return bind.instance;
  }

  Bind? _getBindByClassName(String className) {
    final bind = _binds
        .cast<Bind?>() //
        .firstWhere(
          (bind) => bind?.className == className,
          orElse: () => null,
        );

    return bind;
  }

  Bind _resolveBind(
    Bind bind,
    ParamTransform? transform,
  ) {
    late List<Param> params;

    try {
      params = _resolveParam(bind.params, transform);
    } on UnregisteredInstance catch (e) {
      final classNames = [bind.className, ...e.classNames];
      throw UnregisteredInstance(classNames, e.message);
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
    bind = bind.addInstance(instance);

    return bind;
  }

  List<Param> _resolveParam(
    List<Param> params,
    ParamTransform? transform,
  ) {
    params = List<Param>.from(params);
    for (var i = 0; i < params.length; i++) {
      var param = _transforms(params[i], transform);
      if (param.value != null) {
        params[i] = param;
        continue;
      }
      final instance = _resolveInstanceByClassName(param.className, transform);
      if (!param.isNullable && instance == null) {
        throw UnregisteredInstance([param.className], '${param.className} not registred.');
      }

      params[i] = param.setValue(instance);
    }

    return params;
  }

  Param _transforms(Param param, ParamTransform? transform) {
    final allTransforms = [
      if (transform != null) transform,
      ..._paramTransforms,
    ];

    return allTransforms.fold(param, (internalParam, localTransform) {
      return localTransform(internalParam) ?? internalParam;
    });
  }

  void _updateBinds(Bind bind) {
    final index = _binds.indexWhere((bindElement) => bindElement.className == bind.className);
    if (index != -1) {
      _binds[index] = bind;
    }
  }

  void _add<T>(
    Function constructor,
    String tag, [
    BindType type = BindType.factory,
    T? instance,
  ]) {
    if (_commited) {
      throw AutoInjectorException(
        'Injector commited!\nCannot add new instances, however can still use replace methods.',
        StackTrace.current,
      );
    }

    late Bind bind;

    if (type == BindType.instance) {
      bind = Bind.withInstance<T>(instance as T, tag);
    } else {
      bind = Bind.withConstructor<T>(
        constructor: constructor,
        type: type,
        tag: tag,
      );
    }

    if (_isAddedByClassName(bind.className)) {
      throw AutoInjectorException('${bind.className} Class is already added.', StackTrace.current);
    }

    _binds.add(bind);
  }

  bool _isAddedByClassName(String className) {
    final index = _binds.indexWhere((bind) => bind.className == className);
    return index != -1;
  }

  dynamic _disposeSingletonByClasseName(String className) {
    final index = _binds.indexWhere((bind) => bind.className == className);
    if (index != -1) {
      final bind = _binds[index];
      final instance = bind.instance;
      _binds[index] = bind.removeInstance();
      return instance;
    }
    return null;
  }
}
