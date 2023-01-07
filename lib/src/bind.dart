import 'param.dart';

enum BindType {
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
  late final List<Param> params;
  late final String className;

  Bind({
    required this.constructor,
    required this.type,
  }) {
    final constructorString = constructor.runtimeType.toString();
    className = _resolveClassName(constructorString);
    params = _extractParams(constructorString);
  }

  List<Param> _extractParams(String constructorString) {
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

  String _resolveClassName<T>(String constructorString) {
    final className = constructorString.split(' => ').last;
    return className;
  }
}
