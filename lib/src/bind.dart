// ignore_for_file: public_member_api_docs

import 'package:auto_injector/auto_injector.dart';

enum BindType {
  instance,
  factory,
  singleton,
  lazySingleton;

  bool get isSingleton {
    return this == BindType.singleton || this == BindType.lazySingleton;
  }
}

typedef DisposeCallback<T> = void Function(T value);
typedef NotifierCallback<T> = dynamic Function(T value);

class Bind<T> {
  final Function constructor;
  final BindType type;
  final List<Param> params;
  final String className;
  final String tag;
  final T? instance;
  final DisposeCallback<T>? onDispose;
  final Function? notifier;

  bool get hasInstance => instance != null;

  factory Bind({
    required Function constructor,
    required BindType type,
    required String tag,
    DisposeCallback<T>? onDispose,
    Function? notifier,
    T? instance,
  }) {
    final constructorString = constructor.runtimeType.toString();
    final className = _resolveClassName<T>(constructorString);
    final params = _extractParams(constructorString);
    return Bind<T>._(
      constructor: constructor,
      className: className,
      params: params,
      tag: tag,
      type: type,
      onDispose: onDispose,
      notifier: notifier,
      instance: instance,
    );
  }

  Bind._({
    required this.constructor,
    required this.type,
    required this.params,
    required this.className,
    required this.tag,
    this.onDispose,
    this.notifier,
    this.instance,
  });

  Bind<T> removeInstance() {
    return Bind<T>._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      tag: tag,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  Bind<T> addInstance(T instance) {
    return Bind<T>._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      tag: tag,
      instance: instance,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static List<Param> _extractParams(String constructorString) {
    final params = <Param>[];

    if (constructorString.startsWith('() => ')) {
      return params;
    }

    final allArgsRegex = RegExp(r'\((.+)\) => .+');

    final allArgsMatch = allArgsRegex.firstMatch(constructorString);

    var allArgs = allArgsMatch!.group(1)!;

    final hasNamedParams = RegExp(r'\{(.+)\}');
    final namedParams = hasNamedParams.firstMatch(allArgs);

    if (namedParams != null) {
      final named = namedParams.group(1)!;
      allArgs = allArgs.replaceAll('{$named}', '');

      final paramsText = named.split(',').map((e) => e.trim()).toList();

      for (final paramText in paramsText) {
        final anatomicParamText = paramText.split(' ');

        final type = anatomicParamText[anatomicParamText.length - 2];
        final named = Symbol(anatomicParamText.last);

        final param = NamedParam(
          isRequired: anatomicParamText.contains('required'),
          named: named,
          isNullable: type.endsWith('?'),
          className: type.replaceFirst('?', ''),
        );

        params.add(param);
      }
    }

    if (allArgs.isNotEmpty) {
      final allParam = allArgs //
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) {
        return PositionalParam(
          className: e.replaceFirst('?', ''),
          isNullable: e.endsWith('?'),
        );
      }).toList();

      params.addAll(allParam);
    }

    return params;
  }

  static String _resolveClassName<T>(String constructorString) {
    final typeName = T.toString();
    final isDynamicType = typeName == 'dynamic';
    if (!isDynamicType) return typeName;

    final className = constructorString.split(' => ').last;
    return className;
  }
}
