// ignore_for_file: public_member_api_docs

import 'package:auto_injector/auto_injector.dart';
import 'package:fake_reflection/fake_reflection.dart'
    show FakeReflectionExtension;

enum BindType {
  instance,
  factory,
  singleton,
  lazySingleton;

  bool get isSingleton {
    return this == BindType.singleton || this == BindType.lazySingleton;
  }
}

class BindConfig<T> {
  final DisposeCallback<T>? onDispose;
  final NotifierCallback<T>? notifier;
  BindConfig({
    this.onDispose,
    this.notifier,
  });
}

typedef DisposeCallback<T> = void Function(T value);
typedef NotifierCallback<T> = dynamic Function(T value);

class Bind<T> {
  final Function constructor;
  final BindType type;
  final List<Param> params;
  final String className;
  final T? instance;
  final BindConfig<T>? config;

  bool get hasInstance => instance != null;

  factory Bind({
    required Function constructor,
    required BindType type,
    BindConfig<T>? config,
    T? instance,
  }) {
    final constructorString = constructor.runtimeType.toString();
    final constructorListString = constructorString.split(' ');
    final paramsString = constructorListString[0];
    final classNameString = constructorListString.last;
    if (paramsString == '()') {
      return Bind<T>._(
        constructor: constructor,
        className: classNameString,
        params: [],
        type: type,
        config: config,
        instance: instance,
      );
    }

    final classData = constructor.reflection();
    final className = classData.className;

    final params = [
      ...classData.namedParams.map(
        (param) => NamedParam(
          className: param.type,
          isNullable: param.nullable,
          isRequired: param.required,
          named: Symbol(param.name),
        ),
      ),
      ...classData.notRequiredPositionalParams.map(
        (param) => PositionalParam(
          className: param.type,
          isNullable: param.nullable,
          isRequired: false,
        ),
      ),
      ...classData.positionalParams.map(
        (param) => PositionalParam(
          className: param.type,
          isNullable: param.nullable,
          isRequired: true,
        ),
      ),
    ];

    return Bind<T>._(
      constructor: constructor,
      className: className,
      params: params,
      type: type,
      config: config,
      instance: instance,
    );
  }

  factory Bind.empty(String className) {
    return Bind<T>._(
      constructor: () => null,
      className: className,
      params: [],
      type: BindType.factory,
    );
  }

  void callDispose() {
    final instance = this.instance;
    if (instance != null) {
      config?.onDispose?.call(instance);
    }
  }

  dynamic getNotifier() {
    if (instance != null && config?.notifier != null) {
      return Function.apply(config!.notifier!, [instance]);
    }
  }

  Bind._({
    required this.constructor,
    required this.type,
    required this.params,
    required this.className,
    this.config,
    this.instance,
  });

  Bind<T> withoutInstance() {
    return Bind<T>._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      config: config,
    );
  }

  Bind<T> withInstance(T instance) {
    return Bind<T>._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      instance: instance,
      config: config,
    );
  }
}
