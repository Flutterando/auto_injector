part of '../auto_injector_base.dart';

extension _AutoInjectorConversion on AutoInjectorImpl {
  Map<String, dynamic> _toMap() {
    return {
      'tag': _tag,
      'bindLength': bindLength,
      'binds': binds.map((e) => e._toMap()).toList(),
      'injectorsList': injectorsList.map((injector) => injector._tag).toList(),
      'committed': committed,
    };
  }
}

extension _BindConversion on Bind {
  Map<String, dynamic> _toMap() {
    return {
      'className': className,
      'typeName': type.name,
      'hasInstance': hasInstance,
      'key': key,
      'params': params.map((e) => e._toMap()).toList(),
    };
  }
}

extension _ParamConversion on Param {
  Map<String, dynamic> _toMap() {
    return {
      'type': runtimeType.toString(),
      'className': className,
      'isNullable': isNullable,
      'isRequired': isRequired,
    };
  }
}
