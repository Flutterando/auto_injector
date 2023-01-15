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
  final dynamic value;

  Param({
    required this.className,
    this.isNullable = false,
    this.value,
  });

  Param setValue(dynamic value);
}

@sealed
class NamedParam extends Param {
  final bool isRequired;
  final Symbol named;

  NamedParam({
    required super.className,
    super.value,
    required this.named,
    super.isNullable = false,
    this.isRequired = false,
  });

  @override
  NamedParam setValue(value) {
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
  PositionalParam setValue(value) {
    return PositionalParam(
      className: className,
      isNullable: isNullable,
      value: value,
    );
  }
}
