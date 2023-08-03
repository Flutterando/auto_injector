import 'package:auto_injector/auto_injector.dart';
import 'package:test/test.dart';

void main() {
  /*
    Each module should take care of its binds AND instances.

    Let's suppose you create nested injectors: parentInjector and innerInjector.
    In this example innerInjector have a Bind of Class1.

    If you ask for Class1 for innerInjector or parentInjector, they should
    return the same instance.

    That's what this edge case is testing
  */
  group('Nested Injectors - should return the same instance', () {
    test('Singleton', () {
      final innerInjector = AutoInjector(
        on: (i) {
          i.addSingleton(Class1.new);
          i.commit();
        },
      );

      final parentInjector = AutoInjector(
        on: (i) {
          i.addSingleton(Class2.new);
          i.addSingleton(Class3.new);
          i.addInjector(innerInjector);
          i.commit();
        },
      );

      final class1ParentInjector = parentInjector.get<Class1>();
      final class1InnerInjector = innerInjector.get<Class1>();
      expect(class1ParentInjector.hashCode, class1InnerInjector.hashCode);
    });

    test('Lazy Singleton', () {
      final innerInjector = AutoInjector(
        on: (i) {
          i.addLazySingleton(Class1.new);
          i.commit();
        },
      );

      final parentInjector = AutoInjector(
        on: (i) {
          i.addLazySingleton(Class2.new);
          i.addLazySingleton(Class3.new);
          i.addInjector(innerInjector);
          i.commit();
        },
      );

      final class1ParentInjector = parentInjector.get<Class1>();
      final class1InnerInjector = innerInjector.get<Class1>();
      expect(class1ParentInjector.hashCode, class1InnerInjector.hashCode);
    });

    test('Factory (should be different)', () {
      final innerInjector = AutoInjector(
        on: (i) {
          i.add(Class1.new);
          i.commit();
        },
      );

      final parentInjector = AutoInjector(
        on: (i) {
          i.add(Class2.new);
          i.add(Class3.new);
          i.addInjector(innerInjector);
          i.commit();
        },
      );

      final class1ParentInjector = parentInjector.get<Class1>();
      final class1InnerInjector = innerInjector.get<Class1>();
      expect(
          class1ParentInjector.hashCode, isNot(class1InnerInjector.hashCode));
    });
  });
}

class Class1 {}

class Class2 {
  final Class1 aa;
  Class2(this.aa);
}

class Class3 {}
