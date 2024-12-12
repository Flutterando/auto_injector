import 'package:auto_injector/auto_injector.dart';
import 'package:auto_injector/src/bind.dart';
import 'package:test/test.dart';

void main() {
  test('Class1', () {
    ValidationUtils.validateClass1(Class1.macos);
    ValidationUtils.validateClass1(Class1.js);
    ValidationUtils.validateClass1(Class1.wasm);
  });
  test('Class2', () {
    ValidationUtils.validateClass2(Class2.macos);
    ValidationUtils.validateClass2(Class2.js);
    ValidationUtils.validateClass2(Class2.wasm);
  });
  test('Class3', () {
    ValidationUtils.validateClass3(Class3.macos);
    ValidationUtils.validateClass3(Class3.js);
    ValidationUtils.validateClass3(Class3.wasm);
  });
}

class ValidationUtils {
  static void validateClass1(String constructorString) {
    final classData = Bind.fromConstructorString(
      constructorString: constructorString,
      constructor: Class1.new,
      type: BindType.singleton,
    );
    expect(classData.className, 'Class1');
    expect(classData.params.length, 3);
    expect(classData.params[0].className, 'int');
    expect(classData.params[0].runtimeType, PositionalParam);
    expect(classData.params[0].isNullable, false);
    expect(classData.params[0].isRequired, true);

    expect(classData.params[1], isA<NamedParam>());
    final param1 = classData.params[1] as NamedParam;
    expect(param1.named, const Symbol('var2'));
    expect(param1.className, 'int');
    expect(param1.isNullable, false);
    expect(param1.isRequired, false);

    expect(classData.params[2].runtimeType, NamedParam);
    final param2 = classData.params[2] as NamedParam;
    expect(param2.named, const Symbol('var3'));
    expect(param2.className, 'bool');
    expect(param2.isNullable, true);
    expect(param2.isRequired, false);
  }

  static void validateClass2(String constructorString) {
    final classData = Bind.fromConstructorString(
      constructorString: constructorString,
      constructor: Class1.new,
      type: BindType.singleton,
    );
    expect(classData.className, 'Class2');
    expect(classData.params.length, 3);
    expect(classData.params[0].className, 'int');
    expect(classData.params[0].runtimeType, PositionalParam);
    expect(classData.params[0].isNullable, false);
    expect(classData.params[0].isRequired, true);

    expect(classData.params[1], isA<NamedParam>());
    final param1 = classData.params[1] as NamedParam;
    expect(param1.named, const Symbol('var2'));
    expect(param1.className, 'int');
    expect(param1.isNullable, false);
    expect(param1.isRequired, false);

    expect(classData.params[2].runtimeType, NamedParam);
    final param2 = classData.params[2] as NamedParam;
    expect(param2.named, const Symbol('var3'));
    expect(param2.className, 'bool');
    expect(param2.isNullable, true);
    expect(param2.isRequired, false);
  }

  static void validateClass3(String constructorString) {
    final classData = Bind.fromConstructorString(
      constructorString: constructorString,
      constructor: Class1.new,
      type: BindType.singleton,
    );
    expect(classData.className, 'Class3');
    expect(classData.params.length, 3);
    expect(classData.params[0].runtimeType, PositionalParam);
    final param0 = classData.params[0] as PositionalParam;
    expect(param0.className, 'int');
    expect(param0.isNullable, false);
    expect(param0.isRequired, true);

    expect(classData.params[1], isA<NamedParam>());
    final param1 = classData.params[1] as NamedParam;
    expect(param1.named, const Symbol('var2'));
    expect(param1.className, 'int');
    expect(param1.isNullable, false);
    expect(param1.isRequired, false);

    expect(classData.params[2].runtimeType, NamedParam);
    final param2 = classData.params[2] as NamedParam;
    expect(param2.named, const Symbol('var3'));
    expect(param2.className, 'bool');
    expect(param2.isNullable, true);
    expect(param2.isRequired, false);
  }
}

class Class1 {
  final int var1;
  final int var2;
  final bool? var3;

  const Class1(this.var1, {this.var2 = 0, this.var3});
  static String js =
      "Closure: (int, {int var2, bool? var3}) => Class1 from: ['_#new#tearOff'](var1, opts) {";
  static String wasm = 'Closure: (int, {int var2, bool? var3}) => Class1';
  static String macos =
      "Closure: (int, {int var2, bool? var3}) => Class1 from Function 'Class1.': static.";
}

class Class2 {
  final int var1;
  final int var2;
  final bool? var3;

  Class2(this.var1, {this.var2 = 0, this.var3});
  static String js =
      "Closure: (int, {int var2, bool? var3}) => Class2 from: ['_#new#tearOff'](var1, opts) {";
  static String wasm = 'Closure: (int, {int var2, bool? var3}) => Class2';
  static String macos =
      "Closure: (int, {int var2, bool? var3}) => Class2 from Function 'Class2.': static.";
}

class Class3<T extends Object, Y extends Map<String, dynamic>> {
  final int var1;
  final int var2;
  final bool? var3;

  Class3(this.var1, {this.var2 = 0, this.var3});
  static String js =
      "Closure: <T1 extends Object>(int, {int var2, bool? var3}) => Class3<T1> from: ['_#new#tearOff'](T, var1, opts) {";
  static String wasm =
      'Closure: <X0 extends Object>(int, {int var2, bool? var3}) => Class3<X0>';
  static String macos =
      "Closure: <Y0 extends Object>(int, {int var2, bool? var3}) => Class3<Y0> from Function 'Class3.': static.";
}
