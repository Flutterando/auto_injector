// ignore_for_file: public_member_api_docs, sort_constructors_first, lines_longer_than_80_chars
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'bind.dart';
import 'exceptions/exceptions.dart';
import 'param.dart';

part 'layers_graph.dart';

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
  T call<T>({ParamTransform? transform}) => get<T>(transform: transform);

  /// Register a factory instance.
  /// A new instance will be generated whenever requested.
  /// ```dart
  /// injector.add(MyController.new);
  /// ```
  void add<T>(Function constructor, {BindConfig<T>? config});

  /// Register a instance.
  /// A concrete object (Not a function).
  /// ```dart
  /// injector.addInstance(MyController());
  /// ```
  void addInstance<T>(T instance, {BindConfig<T>? config});

  /// Register a Singleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started as soon as it is registered.
  /// ```dart
  /// injector.addSingleton(MyController.new);
  /// ```
  void addSingleton<T>(Function constructor, {BindConfig<T>? config});

  /// Register a LazySingleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started only when requested the first time.
  /// ```dart
  /// injector.addLazySingleton(MyController.new);
  /// ```
  void addLazySingleton<T>(Function constructor, {BindConfig<T>? config});

  /// Request an notifier propertie by [Type]
  dynamic getNotifier<T>();
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
    tag ??= const Uuid().v4();
    return AutoInjectorImpl(tag, paramTransforms, on);
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

class AutoInjectorImpl extends AutoInjector {
  @visibleForTesting
  final binds = <Bind>[];

  @visibleForTesting
  final injectorsList = <AutoInjectorImpl>[];

  @visibleForTesting
  bool commited = false;

  final layersGraph = LayersGraph();

  @override
  int get bindLength => binds.length;

  AutoInjectorImpl(
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
    return bind?.getNotifier();
  }

  @override
  void add<T>(Function constructor, {BindConfig<T>? config}) {
    _add<T>(constructor, config: config);
  }

  @override
  void addInstance<T>(T instance, {BindConfig<T>? config}) {
    _add<T>(
      () => instance,
      type: BindType.instance,
      instance: instance,
      config: config,
    );
  }

  @override
  void addSingleton<T>(Function constructor, {BindConfig<T>? config}) {
    _add<T>(
      constructor,
      type: BindType.singleton,
      config: config,
    );
  }

  @override
  void addLazySingleton<T>(Function constructor, {BindConfig<T>? config}) =>
      _add<T>(
        constructor,
        type: BindType.lazySingleton,
        config: config,
      );

  @override
  void addInjector(covariant AutoInjectorImpl injector) {
    injectorsList.add(injector);
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
  void replaceInstance<T>(T instance) {
    final className = T.toString();

    final data = layersGraph.getBindByClassName(this, className: className);
    if (data == null) {
      throw AutoInjectorException(
        '$className cannot be replaced as it was not added before.',
        StackTrace.current,
      );
    }
    final injector = data.key;

    final index = injector.binds //
        .indexWhere((bind) => bind.className == className);

    final newBind = Bind<T>(
      constructor: () => instance,
      type: BindType.instance,
      instance: instance,
    );

    injector.binds[index] = newBind;
  }

  @override
  void commit() {
    if (commited) throw InjectorAlreadyCommited(_tag);

    commited = true;

    layersGraph.addInjectorRecursive(this);
    layersGraph.executeInAllInjectors(this, (injector) {
      final isCurrentInjector = injector._tag == _tag;
      if (!isCurrentInjector && !injector.commited) {
        injector.commit();
      }
    });
    startSingletons();
  }

  void startSingletons() {
    binds //
        .where((bind) => bind.type == BindType.singleton)
        .map((bind) => bind.className)
        .forEach(_resolveInstanceByClassName);
  }

  @override
  void uncommit() => commited = false;

  void _checkAutoInjectorIsCommited() {
    if (!commited) {
      final message = '''
The injector(tag: $_tag) is not committed.
It is recommended to call the "commit()" method after adding instances.'''
          .trim();
      print('\x1B[33m$message\x1B[0m');
    }
  }

  @override
  void removeAll() {
    binds.clear();
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
    final data = layersGraph.getBindByClassName(this, className: className);
    if (data == null) return null;

    final injectorOwner = data.key;
    final bind = data.value;

    if (bind.hasInstance) {
      return bind.instance;
    }

    final bindWithInstance = injectorOwner._resolveBind(bind, transform);

    if (bindWithInstance.type.isSingleton) {
      injectorOwner._updateBinds(bindWithInstance);
    }

    return bindWithInstance.instance;
  }

  Bind? _getBindByClassName(String className) {
    final bind = binds
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
    return bind.withInstance(instance);
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
          '${param.className} not registered.',
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
    final index = binds.indexWhere(
      (bindElement) => bindElement.className == bind.className,
    );
    if (index != -1) {
      binds[index] = bind;
    }
  }

  void _add<T>(
    Function constructor, {
    BindType type = BindType.factory,
    T? instance,
    BindConfig<T>? config,
  }) {
    assert(
      config == null ||
          !['dynamic', 'Object', 'Object?'] //
              .contains(T.toString()),
      'Added generic value in register. ex\n'
      'injector.add<MyClasse>(MyClasse)',
    );
    if (commited) {
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
      config: config,
      instance: instance,
    );

    if (_isAddedByClassName(bind.className)) {
      throw AutoInjectorException(
        '${bind.className} Class is already added.',
        StackTrace.current,
      );
    }

    binds.add(bind);
  }

  bool _isAddedByClassName(String className) {
    final index = binds.indexWhere((bind) => bind.className == className);
    return index != -1;
  }

  dynamic _disposeSingletonByClasseName(String className) {
    final data = layersGraph.getBindByClassName(this, className: className);
    if (data == null) return null;

    final bind = data.value;
    if (!bind.hasInstance) return null;

    bind.callDispose();
    final injectorOwnsBind = data.key;
    final indexBind = injectorOwnsBind.binds
        .indexWhere((bind) => bind.className == className);
    injectorOwnsBind.binds[indexBind] = bind.withoutInstance();
    return bind.instance;
  }
}
