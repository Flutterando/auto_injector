// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:meta/meta.dart';

typedef ParamTransform = Param? Function(Param param);

ParamTransform changeParam<T>(T newValue) {
  return (param) {
    if (T.toString() == param.className) {
      return param.setValue(newValue);
    }
    return null;
  };
}

@sealed
abstract class Param {
  final String className;
  final bool isNullable;
  final bool isRequired;

  bool get injectableParam => !isNullable && isRequired;

  /// instance of param
  final dynamic value;

  Param({
    required this.className,
    this.isNullable = false,
    this.value,
    this.isRequired = true,
  });

  /// return a new instance of Param with value
  Param setValue(dynamic value);
}

@sealed
class NamedParam extends Param {
  final Symbol named;

  NamedParam({
    required super.className,
    super.value,
    required this.named,
    super.isNullable = false,
    bool isRequired = false,
  }) : super(isRequired: isRequired);

  @override
  NamedParam setValue(dynamic value) {
    return NamedParam(
      named: named,
      className: className,
      isNullable: isNullable,
      isRequired: isNullable,
      value: value,
    );
  }
}

@sealed
class PositionalParam extends Param {
  PositionalParam({
    required super.className,
    super.value,
    super.isNullable = false,
  });

  @override
  PositionalParam setValue(dynamic value) {
    return PositionalParam(
      className: className,
      isNullable: isNullable,
      value: value,
    );
  }
}
