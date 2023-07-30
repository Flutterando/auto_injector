import 'package:meta/meta.dart';

import 'bind.dart';
import 'exceptions/exceptions.dart';
import 'param.dart';

/// Register and get binds
abstract class Injector {
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

  /// Register a factory instance.
  /// A new instance will be generated whenever requested.
  /// ```dart
  /// injector.add(MyController.new);
  /// ```
  void add<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  });

  /// Register a instance.
  /// A concrete object (Not a function).
  /// ```dart
  /// injector.addInstance(MyController());
  /// ```
  void addInstance<T>(
    T instance, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  });

  /// Register a Singleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started as soon as it is registered.
  /// ```dart
  /// injector.addSingleton(MyController.new);
  /// ```
  void addSingleton<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  });

  /// Register a LazySingleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started only when requested the first time.
  /// ```dart
  /// injector.addLazySingleton(MyController.new);
  /// ```
  void addLazySingleton<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  });
}

/// Automatic Dependency Injection System, but without build_runner :)
/// <br>
/// `[tag]`: AutoInject instance identity.<br>
/// `[on]`: Helps with instance registration.<br>
/// `[paramObservers]`: List of functions that listen and transform
/// parameters while they are being parsed when requested by the `get()` method.
/// <br><br>
/// ```dart
/// final injector = AutoInjector();
///
/// injector.add(MyDatasource.new);
///
/// injector.get<MyDatasource>();
/// ```
abstract class AutoInjector extends Injector {
  final List<ParamTransform> _paramTransforms = [];

  /// Helps with instance registration
  final void Function(AutoInjector injector)? on;
  final String _tag;

  /// Only test
  @visibleForTesting
  int get bindLength;

  /// Automatic Dependency Injection System, but without build_runner :)
  /// <br>
  /// `[tag]`: AutoInject instance identity.<br>
  /// `[on]`: Helps with instance registration.<br>
  /// `[paramObservers]`: List of functions that listen and transform
  /// parameters while they are being parsed when
  /// requested by the `get()` method.
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

  AutoInjector._(this._tag, List<ParamTransform> paramObservers, this.on) {
    _paramTransforms.addAll(paramObservers);
  }

  /// Request an instance by [Type] that when throwing an
  /// exception returns null.
  /// <br>
  /// [transform]: Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  T? tryGet<T>({ParamTransform? transform});

  /// Request an notifier propertie by [Type]
  dynamic getNotifier<T>();

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
  void disposeSingletonsByTag(
    String tag, {
    void Function(dynamic instance)? onRemoved,
  });

  /// Removes registers by tag.<br>
  void removeByTag(String tag);

  /// checks if there is any instance registered with a tag
  bool hasTag(String tag);

  /// Replaces an instance record with a concrete instance.<br>
  /// This function should only be used for unit testing.<br>
  /// Any other use is discouraged.
  void replaceInstance<T>(T instance);

  /// Informs the container that the additions
  /// are finished and the injector is ready to be used.<br>
  /// This command starts the singletons.
  void commit();

  /// remove commit
  void uncommit();

  /// Remove all regiters
  void removeAll();
}

class _AutoInjector extends AutoInjector {
  final _binds = <Bind>[];
  var _commited = false;

  @override
  int get bindLength => _binds.length;

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
  dynamic getNotifier<T>() {
    final className = T.toString();
    final bind = _getBindByClassName(className);

    if (bind?.instance != null && bind?.notifier != null) {
      return Function.apply(bind!.notifier!, [bind.instance]);
    }
  }

  @override
  void add<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    _add<T>(
      constructor,
      tag ?? _tag,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  @override
  void addInstance<T>(
    T instance, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    _add<T>(
      () => instance,
      tag ?? _tag,
      type: BindType.instance,
      instance: instance,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  @override
  void addSingleton<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    _add<T>(
      constructor,
      tag ?? _tag,
      type: BindType.singleton,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  @override
  void addLazySingleton<T>(
    Function constructor, {
    String? tag,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) =>
      _add<T>(
        constructor,
        tag ?? _tag,
        type: BindType.lazySingleton,
        onDispose: onDispose,
        notifier: notifier,
      );

  @override
  void addInjector(covariant _AutoInjector injector) {
    for (final bind in injector._binds) {
      final index = _binds.indexWhere(
        (bindElement) => bindElement.className == bind.className,
      );
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
  void disposeSingletonsByTag(
    String tag, {
    void Function(dynamic instance)? onRemoved,
  }) {
    final taggedBinds = List<Bind>.from(
      _binds.where((bind) => bind.tag == tag),
    );
    for (var index = 0; index < taggedBinds.length; index++) {
      final bind = taggedBinds[index];
      final instance = _disposeSingletonByClasseName(bind.className);
      onRemoved?.call(instance);
    }
  }

  @override
  void removeByTag(String tag) {
    _binds.removeWhere((bind) {
      final condition = bind.tag == tag;
      if (condition && bind.instance != null) {
        bind.onDispose?.call(bind.instance);
      }

      return condition;
    });
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

    final bind = Bind<T>(
      constructor: () => instance,
      type: BindType.instance,
      tag: _binds[index].tag,
      instance: instance,
    );

    _binds[index] = bind;
  }

  @override
  void commit() {
    _commited = true;
    _binds //
        .where((bind) => bind.type == BindType.singleton)
        .map((bind) => bind.className)
        .forEach(_resolveInstanceByClassName);
  }

  @override
  void uncommit() => _commited = false;

  @override
  bool hasTag(String tag) {
    for (final bind in _binds) {
      if (bind.tag == tag) {
        return true;
      }
    }

    return false;
  }

  void _checkAutoInjectorIsCommited() {
    if (!_commited) {
      final message = '''
The injector(tag: $_tag) is not committed.
It is recommended to call the "commit()" method after adding instances.'''
          .trim();
      print('\x1B[33m$message\x1B[0m');
    }
  }

  @override
  void removeAll() {
    _binds.clear();
  }

  UnregisteredInstance _prepareExceptionTrace(UnregisteredInstance exception) {
    final trace = exception.classNames.join('->');
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

    final instance = Function.apply(
      bind.constructor,
      positionalParams,
      namedParams,
    );
    return bind.addInstance(instance);
  }

  List<Param> _resolveParam(
    List<Param> params,
    ParamTransform? transform,
  ) {
    final copyParams = params.where((param) => param.injectableParam).toList();
    for (var i = 0; i < copyParams.length; i++) {
      final param = _transforms(copyParams[i], transform);
      if (param.value != null) {
        copyParams[i] = param;
        continue;
      }

      final instance = _resolveInstanceByClassName(param.className, transform);
      if (!param.isNullable && instance == null) {
        throw UnregisteredInstance(
          [param.className],
          '${param.className} not registred.',
        );
      }

      copyParams[i] = param.setValue(instance);
    }

    return copyParams;
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
    final index = _binds.indexWhere(
      (bindElement) => bindElement.className == bind.className,
    );
    if (index != -1) {
      _binds[index] = bind;
    }
  }

  void _add<T>(
    Function constructor,
    String tag, {
    BindType type = BindType.factory,
    T? instance,
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    if (_commited) {
      throw AutoInjectorException(
        '''
Injector commited!\nCannot add new instances, however can still use replace methods.'''
            .trim(),
        StackTrace.current,
      );
    }

    final bind = Bind<T>(
      constructor: constructor,
      type: type,
      tag: tag,
      onDispose: onDispose,
      notifier: notifier,
      instance: instance,
    );

    if (_isAddedByClassName(bind.className)) {
      throw AutoInjectorException(
        '${bind.className} Class is already added.',
        StackTrace.current,
      );
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
      if (bind.instance == null) {
        return null;
      }
      bind.callDispose();
      _binds[index] = bind.removeInstance();

      return instance;
    }
    return null;
  }
}
