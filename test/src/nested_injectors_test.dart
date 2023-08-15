import 'package:auto_injector/auto_injector.dart';
import 'package:auto_injector/src/auto_injector_base.dart';
import 'package:test/test.dart';

void main() {
  group('Nested Injectors -', () {
    group('replaceInstance()', () {
      test('one parent level', () {
        final innerInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class1.new);
            i.commit();
          },
        );
        final parentInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class2.new);
            i.addInjector(innerInjector);
            i.commit();
          },
        );
        final itemToReplace = Class1();
        parentInjector.replaceInstance(itemToReplace);

        expect(itemToReplace.hashCode, parentInjector.get<Class1>().hashCode);
        expect(itemToReplace.hashCode, innerInjector.get<Class1>().hashCode);
      });

      test('two parent level', () {
        final grandChildInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class1.new);
            i.commit();
          },
        );

        final childInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class1.new);
            i.addInjector(grandChildInjector);
            i.commit();
          },
        );

        final parentInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class2.new);
            i.addInjector(childInjector);
            i.commit();
          },
        );

        final itemToReplace = Class1();
        parentInjector.replaceInstance(itemToReplace);

        expect(itemToReplace.hashCode, parentInjector.get<Class1>().hashCode);
        expect(itemToReplace.hashCode, childInjector.get<Class1>().hashCode);
      });
    });

    // group('hasInjectorByTag()', () {
    //   test('one parent level', () {
    //     final innerInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class1.new);
    //         i.commit();
    //       },
    //     );
    //     final parentInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class2.new);
    //         i.addInjector(innerInjector);
    //         i.commit();
    //       },
    //     );

    //     expect(parentInjector.hasInjectorByTag(innerInjector.tag), true);
    //     expect(parentInjector.hasInjectorByTag('inexistent tag'), false);
    //   });
    //   test('two parent level', () {
    //     const tagGrandChildInjector = 'grand-child-injector';
    //     const tagChildInjector = 'child-injector';
    //     final grandChildInjector = AutoInjector(tag: tagGrandChildInjector);
    //     grandChildInjector.addSingleton(Class1.new);
    //     grandChildInjector.commit();

    //     final childInjector = AutoInjector(
    //       tag: tagChildInjector,
    //       on: (i) {
    //         i.addSingleton(Class1.new);
    //         i.addInjector(grandChildInjector);
    //         i.commit();
    //       },
    //     );

    //     final parentInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class2.new);
    //         i.addInjector(childInjector);
    //         i.commit();
    //       },
    //     );

    //     expect(parentInjector.hasInjectorByTag(tagGrandChildInjector), true);
    //     expect(parentInjector.hasInjectorByTag('inexistent tag'), false);
    //   });

    //   test('three parent level', () {
    //     const tagInner3Injector = 'inner3-injector';
    //     final inner3Injector = AutoInjector(
    //       tag: tagInner3Injector,
    //       on: (i) {
    //         i.addSingleton(Class1.new);
    //         i.commit();
    //       },
    //     );
    //     final inner2Injector = AutoInjector(
    //       on: (i) {
    //         i.addInjector(inner3Injector);
    //         i.commit();
    //       },
    //     );

    //     final inner1Injector = AutoInjector(
    //       on: (i) {
    //         i.addInjector(inner2Injector);
    //         i.commit();
    //       },
    //     );

    //     final parentInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class2.new);
    //         i.addInjector(inner1Injector);
    //         i.commit();
    //       },
    //     );

    //     expect(parentInjector.hasInjectorByTag(tagInner3Injector), true);
    //     expect(parentInjector.hasInjectorByTag('inexistent tag'), false);
    //   });
    // });

    // group('removeAutoInjectorByTag()', () {
    //   test('one parent level', () {
    //     const tagInnerInjector = 'inner-injector';
    //     final innerInjector = AutoInjector(
    //       tag: tagInnerInjector,
    //       on: (i) {
    //         i.addSingleton(Class1.new);
    //         i.commit();
    //       },
    //     );

    //     final parentInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class2.new);
    //         i.addInjector(innerInjector);
    //         i.commit();
    //       },
    //     );

    //     final removedInjector = parentInjector
    // .removeInjectorByTag(tagInnerInjector);
    //     expect(removedInjector, innerInjector);
    //     expect(parentInjector.hasInjectorByTag(tagInnerInjector), false);
    //   });

    //   test('two parent levels', () {
    //     const tagGrandChildInjector = 'grand-child-injector';
    //     const tagChildInjector = 'child-injector';
    //     final grandChildInjector = AutoInjector(tag: tagGrandChildInjector);
    //     grandChildInjector.addSingleton(Class1.new);
    //     grandChildInjector.commit();

    //     final childInjector = AutoInjector(
    //       tag: tagChildInjector,
    //       on: (i) {
    //         i.addSingleton(Class1.new);
    //         i.addInjector(grandChildInjector);
    //         i.commit();
    //       },
    //     );

    //     final parentInjector = AutoInjector(
    //       on: (i) {
    //         i.addSingleton(Class2.new);
    //         i.addInjector(childInjector);
    //         i.commit();
    //       },
    //     );

    //     final removedInjector = parentInjector
    // .removeInjectorByTag(tagGrandChildInjector);
    //     expect(removedInjector, grandChildInjector);
    //     expect(
    //parentInjector.hasInjectorByTag(tagGrandChildInjector),
    //false,
    // );
    //   });
    // });

    group('disposeInjectorByTag', () {
      test('should remove the inner injector named with this tag', () {
        const innerInjectorTag = 'inner-injector-tag';
        final innerInjector = AutoInjector(
          tag: innerInjectorTag,
          on: (i) {
            i.addLazySingleton(Class1.new);
          },
        ) as AutoInjectorImpl;

        final parentInjector = AutoInjector(
          on: (i) {
            i.addInjector(innerInjector);
            i.commit();
          },
        );

        parentInjector.disposeInjectorByTag(innerInjectorTag);
        expect(innerInjector.commited, false);
        expect(innerInjector.binds.isEmpty, true);
        expect(innerInjector.layersGraph.adjacencyList.isEmpty, true);
        expect(innerInjector.layersGraph.modules.isEmpty, true);
      });
    });

    group('Recursive Commit: ', () {
      test('should be recursive', () {
        final innerInjector = AutoInjector() as AutoInjectorImpl;
        final parentInjector = AutoInjector();
        parentInjector.addInjector(innerInjector);
        parentInjector.commit();

        expect(innerInjector.commited, true);
      });

      test(
          'throw "InjectorAlreadyCommited" when called .commit() and '
          'the injector is already commited', () {
        final injector = AutoInjector() as AutoInjectorImpl;
        injector.commit();

        expect(injector.commit, throwsA(isA<InjectorAlreadyCommited>()));
      });

      test('should commit only injectors not commited', () {
        final innerInjector = AutoInjector(
          on: (i) {
            i.addSingleton(Class3.new);
            i.commit();
          },
        ) as AutoInjectorImpl;

        final parentInjector = AutoInjector();
        parentInjector.addSingleton(Class1.new);
        parentInjector.addSingleton(Class2.new);
        parentInjector.addInjector(innerInjector);
        parentInjector.commit();

        expect(innerInjector.commited, true);
      });
    });

    /*
    Each module should take care of its binds AND instances.

    Let's suppose you create nested injectors: parentInjector and innerInjector.
    In this example innerInjector have a Bind of Class1.

    If you ask for Class1 for innerInjector or parentInjector, they should
    return the same instance.

    That's what this edge case is testing
  */
    group('should return the same instance', () {
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
          class1ParentInjector.hashCode,
          isNot(class1InnerInjector.hashCode),
        );
      });
    });
  });
}

class Class1 {}

class Class2 {
  final Class1 aa;
  Class2(this.aa);
}

class Class3 {}
