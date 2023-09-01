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
  final String? className;
  final T? instance;
  final BindConfig<T>? config;
  final String? key;

  bool get hasInstance => instance != null;

  factory Bind({
    required Function constructor,
    required BindType type,
    BindConfig<T>? config,
    T? instance,
    String? key,
  }) {
    final constructorString = constructor.runtimeType.toString();
    final className = _resolveClassName<T>(constructorString);
    final params = _extractParams(constructorString);

    return Bind<T>._(
      constructor: constructor,
      className: (key != null) ? null : className,
      params: params,
      type: type,
      config: config,
      instance: instance,
      key: key,
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
    this.className,
    this.config,
    this.instance,
    this.key,
  });

  Bind<T> withoutInstance() {
    return Bind<T>._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      config: config,
      key: key,
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
      key: key,
    );
  }

  static List<String> _customSplit(String input) {
    final parts = <String>[];
    var currentPart = '';
    var angleBracketCount = 0;

    for (final char in input.runes) {
      final charStr = String.fromCharCode(char);

      if (charStr == ',' && angleBracketCount == 0) {
        parts.add(currentPart.trim());
        currentPart = '';
      } else {
        currentPart += charStr;

        if (charStr == '<') {
          angleBracketCount++;
        } else if (charStr == '>') {
          angleBracketCount--;
        }
      }
    }

    if (currentPart.isNotEmpty && currentPart != ' ') {
      parts.add(currentPart.trim());
    }

    return parts;
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

      final paramsText = _customSplit(named);

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
      final paramList = _customSplit(allArgs);
      final allParam = paramList.map((e) => e.trim()).where((e) => e.isNotEmpty).map((e) {
        return PositionalParam(
          className: e.replaceFirst('?', ''),
          isNullable: e.endsWith('?'),
          isRequired: true,
        );
      }).toList();

      params.addAll(allParam);
    }

    return params;
  }

  static String _resolveClassName<T>(String constructorString) {
    final typeName = T.toString();
    final isDynamicOrObjectType = ['dynamic', 'Object'].contains(typeName);
    if (!isDynamicOrObjectType) return typeName;

    final className = constructorString.split(' => ').last;
    return className;
  }
}
