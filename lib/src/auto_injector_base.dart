// ignore_for_file: public_member_api_docs, sort_constructors_first, lines_longer_than_80_chars
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'bind.dart';
import 'exceptions/exceptions.dart';
import 'param.dart';

part 'layers_graph.dart';

typedef VoidCallback = void Function();

/// Register and get binds
abstract class Injector {
  /// Request an instance by [Type]
  /// <br>
  /// [transform] : Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  T get<T>({ParamTransform? transform, String? key});

  /// Request an instance by [Type]
  /// <br>
  /// [transform]: Transform a param. This can be used for example
  /// to replace an instance with a mock in tests.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  T call<T>({ParamTransform? transform, String? key}) {
    return get<T>(transform: transform, key: key);
  }

  /// Register a factory instance.
  /// A new instance will be generated whenever requested.
  /// ```dart
  /// injector.add(MyController.new);
  /// ```
  /// <br>
  /// When [key] is provided this instance only can be found by key
  void add<T>(Function constructor, {BindConfig<T>? config, String? key});

  /// Register a instance.
  /// A concrete object (Not a function).
  /// ```dart
  /// injector.addInstance(MyController());
  /// ```
  /// <br>
  /// When [key] is provided this instance only can be found by key
  void addInstance<T>(T instance, {BindConfig<T>? config, String? key});

  /// Register a Singleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started as soon as it is registered.
  /// ```dart
  /// injector.addSingleton(MyController.new);
  /// ```
  /// <br>
  /// When [key] is provided this instance only can be found by key
  void addSingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  });

  /// Register a LazySingleton instance.
  /// It will generate a single instance for the duration of
  /// the application, or until manually removed.<br>
  /// The object will be started only when requested the first time.
  /// ```dart
  /// injector.addLazySingleton(MyController.new);
  /// ```
  /// <br>
  /// When [key] is provided this instance only can be found by key
  void addLazySingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  });

  /// Request an notifier property by [Type]
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  dynamic getNotifier<T>({String? key});
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
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  T? tryGet<T>({ParamTransform? transform, String? key});

  /// Inherit all instances and transforms from other AutoInjector object.
  /// ```dart
  /// final injector = AutoInjector();
  /// final otherInjector = AutoInjector();
  ///
  /// injector.addInjector(otherInjector);
  /// ```
  void addInjector(AutoInjector injector);

  /// Checks if the instance record exists.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  bool isAdded<T>({String? key});

  /// checks if the instance registration is as singleton.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  bool isInstantiateSingleton<T>({String? key});

  /// Removes the singleton instance.<br>
  /// This does not remove it from the registry tree.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  T? disposeSingleton<T>({String? key});

  /// Replaces an instance record with a concrete instance.<br>
  /// This function should only be used for unit testing.<br>
  /// Any other use is discouraged.
  /// <br>
  /// When [key] is provided it will search the instance that have the same key
  void replaceInstance<T>(T instance, {String? key});

  /// Informs the container that the additions
  /// are finished and the injector is ready to be used.<br>
  /// This command starts the singletons.
  void commit();

  /// remove commit
  void uncommit();

  /// Remove all the binds and turns the injector uncommitted
  void dispose([void Function(dynamic instance)? instanceCallback]);

  /// Execute "dispose()" in all the injectors from this layers tree
  void disposeRecursive();

  /// Find the injector by [injectorTag] in the layers tree and execute "dispose()" on it
  void disposeInjectorByTag(String injectorTag, [void Function(dynamic instance)? instanceCallback]);

  /// Run the [callback] when method [dispose] is called. <br/>
  /// All the dispose callbacks are called before the injector is disposed.
  void addDisposeListener(VoidCallback callback);

  /// Remove the [callback] previous included using [addDisposeListener]. <br/>
  /// If the callback was NOT included previously using [addDisposeListener]
  /// it will not do anything.
  void removeDisposeListener(VoidCallback callback);
}

class AutoInjectorImpl extends AutoInjector {
  @visibleForTesting
  final binds = <Bind>[];

  @visibleForTesting
  final injectorsList = <AutoInjectorImpl>[];

  @visibleForTesting
  bool committed = false;

  final layersGraph = LayersGraph();

  final disposeListeners = <VoidCallback>[];

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
  T get<T>({ParamTransform? transform, String? key}) {
    _checkAutoInjectorIsCommitted();

    try {
      final className = T.toString();
      T? instance;

      if (key == null) {
        instance = _resolveInstanceByClassName(className, transform);
        if (instance == null) {
          throw UnregisteredInstance([className], '$className unregistered.');
        }
      } else {
        instance = _resolveInstanceByKey(key, transform);
        if (instance == null) {
          throw UnregisteredInstanceByKey([key], '$key unregistered.');
        }
      }
      return instance;
    } on UnregisteredInstance catch (exception) {
      final trace = exception.classNames.join('->');
      var message = exception.message;
      if (exception.classNames.length > 1) {
        message = '$message\nTrace: $trace';
      }
      throw UnregisteredInstance(exception.classNames, message);
    } on UnregisteredInstanceByKey catch (exception) {
      final trace = exception.keys.join('->');
      var message = exception.message;
      if (exception.keys.length > 1) {
        message = '$message\nTrace: $trace';
      }
      throw UnregisteredInstance(exception.keys, message);
    }
  }

  @override
  T? tryGet<T>({ParamTransform? transform, String? key}) {
    try {
      return get<T>(transform: transform, key: key);
    } catch (e) {
      return null;
    }
  }

  @override
  dynamic getNotifier<T>({String? key}) {
    final className = T.toString();
    final data = (key == null) ? layersGraph.getBindByClassName(this, className: className) : layersGraph.getBindByKey(this, bindKey: key);
    final bind = data?.value;
    return bind?.getNotifier();
  }

  @override
  void add<T>(Function constructor, {BindConfig<T>? config, String? key}) {
    _add<T>(constructor, config: config, key: key);
  }

  @override
  void addInstance<T>(T instance, {BindConfig<T>? config, String? key}) {
    _add<T>(
      () => instance,
      type: BindType.instance,
      instance: instance,
      config: config,
      key: key,
    );
  }

  @override
  void addSingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  }) {
    _add<T>(
      constructor,
      type: BindType.singleton,
      config: config,
      key: key,
    );
  }

  @override
  void addLazySingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  }) =>
      _add<T>(
        constructor,
        type: BindType.lazySingleton,
        config: config,
        key: key,
      );

  @override
  void addInjector(covariant AutoInjectorImpl injector) {
    injectorsList.add(injector);
  }

  @override
  bool isAdded<T>({String? key}) => (key == null) //
      ? _hasBindByClassName(T.toString())
      : _hasBindByKey(key);

  @override
  bool isInstantiateSingleton<T>({String? key}) {
    final className = T.toString();
    final data = (key == null) ? layersGraph.getBindByClassName(this, className: className) : layersGraph.getBindByKey(this, bindKey: key);
    final bind = data?.value;
    return bind?.hasInstance ?? false;
  }

  @override
  T? disposeSingleton<T>({String? key}) {
    final response = (key == null) ? _disposeSingletonByClasseName(T.toString()) : _disposeSingletonByKey(key);
    return response as T?;
  }

  @override
  void replaceInstance<T>(T instance, {String? key}) {
    final className = T.toString();

    final data = (key == null) ? layersGraph.getBindByClassName(this, className: className) : layersGraph.getBindByKey(this, bindKey: key);
    if (data == null) {
      throw AutoInjectorException(
        '$className cannot be replaced because it was not added before.',
        StackTrace.current,
      );
    }
    final injector = data.key;

    final index = (key == null) ? injector.binds.indexWhere((bind) => bind.className == className) : injector.binds.indexWhere((bind) => bind.key == key);

    final newBind = Bind<T>(
      constructor: () => instance,
      type: BindType.instance,
      instance: instance,
      key: key,
    );

    injector.binds[index] = newBind;
  }

  @override
  void commit() {
    if (committed) throw InjectorAlreadyCommited(_tag);

    committed = true;

    layersGraph.initialize(this);
    layersGraph.executeInAllInjectors(this, (injector) {
      final isCurrentInjector = injector._tag == _tag;
      if (!isCurrentInjector && !injector.committed) {
        injector.commit();
      }
    });
    startSingletons();
  }

  void startSingletons() {
    final singletonBinds = binds.where((bind) => bind.type == BindType.singleton);

    singletonBinds.where((bind) => bind.className != null).map((bind) => bind.className!).forEach(_resolveInstanceByClassName);

    singletonBinds.where((bind) => bind.key != null).map((bind) => bind.key!).forEach(_resolveInstanceByKey);
  }

  @override
  void uncommit() => committed = false;

  void _checkAutoInjectorIsCommitted() {
    if (!committed) {
      final message = '''
The injector(tag: $_tag) is not committed.
It is recommended to call the "commit()" method after adding instances.'''
          .trim();
      print('\x1B[33m$message\x1B[0m');
    }
  }

  @override
  void dispose([void Function(dynamic instance)? instanceCallback]) {
    for (final disposer in disposeListeners) {
      disposer.call();
    }
    disposeListeners.clear();
    for (final bind in binds.where((b) => b.instance != null)) {
      instanceCallback?.call(bind.instance);
      bind.callDispose();
    }
    binds.clear();
    layersGraph.reset();
    committed = false;
  }

  @override
  void disposeRecursive() {
    layersGraph.executeInAllInjectors(this, (i) {
      if (i._tag != _tag) i.dispose();
    });
    // The current is the last to be disposed because it cleans the layersGraph
    dispose();
  }

  @override
  void disposeInjectorByTag(String injectorTag, [void Function(dynamic instance)? instanceCallback]) {
    layersGraph.executeInAllInjectors(this, (injector) {
      if (injector._tag == injectorTag) injector.dispose(instanceCallback);
    });
  }

  @override
  void addDisposeListener(VoidCallback callback) {
    disposeListeners.add(callback);
  }

  @override
  void removeDisposeListener(VoidCallback callback) {
    disposeListeners.remove(callback);
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

  dynamic _resolveInstanceByKey(
    String key, [
    ParamTransform? transform,
  ]) {
    final data = layersGraph.getBindByKey(this, bindKey: key);
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

  Bind _resolveBind(
    Bind bind,
    ParamTransform? transform,
  ) {
    late List<Param> params;

    try {
      params = _resolveParam(bind.params, transform);
    } on UnregisteredInstance catch (e) {
      final classNames = [bind.className ?? bind.key!, ...e.classNames];
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
    String? key,
  }) {
    assert(
      config == null ||
          key != null ||
          !['dynamic', 'Object', 'Object?'] //
              .contains(T.toString()),
      'Added generic value in register. Try something like this:\n'
      'injector.add<MyClasse>(MyClasse)',
    );
    if (committed) {
      throw AutoInjectorException(
        '''
Injector committed!\nCannot add new instances, however can still use replace methods.'''
            .trim(),
        StackTrace.current,
      );
    }

    final bind = Bind<T>(
      constructor: constructor,
      type: type,
      config: config,
      instance: instance,
      key: key,
    );

    final bindData = (key == null) ? layersGraph.getBindByClassName(this, className: bind.className!) : layersGraph.getBindByKey(this, bindKey: key);
    final hasBind = bindData != null;
    if (hasBind) {
      final injectorOwnsBind = bindData.key;
      throw AutoInjectorException(
        '${bind.className} Class already exists on Injector(tag: "${injectorOwnsBind._tag}").',
        StackTrace.current,
      );
    }

    binds.add(bind);
  }

  bool _hasBindByClassName(String className) {
    final data = layersGraph.getBindByClassName(this, className: className);
    return data != null;
  }

  bool _hasBindByKey(String key) {
    final data = layersGraph.getBindByKey(this, bindKey: key);
    return data != null;
  }

  dynamic _disposeSingletonByClasseName(String className) {
    final data = layersGraph.getBindByClassName(this, className: className);
    if (data == null) return null;

    final bind = data.value;
    if (!bind.hasInstance) return null;

    bind.callDispose();
    final injectorOwnsBind = data.key;
    final indexBind = injectorOwnsBind.binds.indexWhere((bind) => bind.className == className);
    injectorOwnsBind.binds[indexBind] = bind.withoutInstance();
    return bind.instance;
  }

  dynamic _disposeSingletonByKey(String key) {
    final data = layersGraph.getBindByKey(this, bindKey: key);
    if (data == null) return null;

    final bind = data.value;
    if (!bind.hasInstance) return null;

    bind.callDispose();
    final injectorOwnsBind = data.key;
    final indexBind = injectorOwnsBind.binds.indexWhere((bind) => bind.key == key);
    injectorOwnsBind.binds[indexBind] = bind.withoutInstance();
    return bind.instance;
  }
}
