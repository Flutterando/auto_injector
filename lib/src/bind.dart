// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'param.dart';

enum BindType {
  instance,
  factory,
  singleton,
  lazySingleton;

  bool get isSingleton {
    return this == BindType.singleton || this == BindType.lazySingleton;
  }
}

class Bind {
  final Function constructor;
  final BindType type;
  final List<Param> params;
  final String className;
  final String tag;
  final Object? instance;

  bool get hasInstance => instance != null;

  Bind._({
    required this.constructor,
    required this.type,
    required this.params,
    required this.className,
    required this.tag,
    this.instance,
  });

  static Bind withInstance<T>(
    T instance,
    String tag,
  ) {
    return Bind._(
      constructor: () => instance,
      className: T.toString(),
      params: [],
      tag: tag,
      type: BindType.instance,
    );
  }

  static Bind withConstructor<T>({
    required Function constructor,
    required BindType type,
    required String tag,
  }) {
    final constructorString = constructor.runtimeType.toString();
    final className = _resolveClassName<T>(constructorString);
    final params = _extractParams(constructorString);
    return Bind._(
      constructor: constructor,
      className: className,
      params: params,
      tag: tag,
      type: type,
    );
  }

  Bind removeInstance() {
    return Bind._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      tag: tag,
      instance: null,
    );
  }

  Bind addInstance(dynamic instance) {
    return Bind._(
      constructor: constructor,
      type: type,
      params: params,
      className: className,
      tag: tag,
      instance: instance,
    );
  }

  static List<Param> _extractParams(String constructorString) {
    final params = <Param>[];

    if (constructorString.startsWith('() => ')) {
      return params;
    }

    final allArgsRegex = RegExp(r'\((.+)\) => .+');

    final allArgsMatch = allArgsRegex.firstMatch(constructorString.toString());

    var allArgs = allArgsMatch!.group(1)!;

    final hasNamedParams = RegExp(r'\{(.+)\}');
    final namedParams = hasNamedParams.firstMatch(allArgs);

    if (namedParams != null) {
      final named = namedParams.group(1)!;
      allArgs = allArgs.replaceAll('{$named}', '');

      final paramsText = named.split(',').map((e) => e.trim()).toList();

      for (var paramText in paramsText) {
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
    if(!isDynamicType) return typeName;

    final className = constructorString.split(' => ').last;
    return className;
  }
}
