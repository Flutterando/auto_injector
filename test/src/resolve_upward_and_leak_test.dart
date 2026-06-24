// ignore_for_file: require_trailing_commas

import 'package:auto_injector/auto_injector.dart';
import 'package:auto_injector/src/auto_injector_base.dart';
import 'package:test/test.dart';

class Config {
  Config(this.v);
  final String v;
}

class Service {
  Service(this.config);
  final Config config;
}

class ShellService {
  ShellService();
}

void main() {
  group('resolveUpward (feature resolves against ancestor) -', () {
    test('downward-only is still the default: feature->root fails', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.add<Service>(Service.new);
      root.addInjector(feature);
      root.commit();

      expect(
        () => root.get<Service>(),
        throwsA(isA<UnregisteredInstance>()),
      );
    });

    test('addSingleton fails at commit without resolveUpward', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.addSingleton<Service>(Service.new);
      root.addInjector(feature);

      // The singleton is started during the cascaded commit -> throws there.
      expect(
        root.commit,
        throwsA(isA<UnregisteredInstance>()),
      );
    });

    test('add: resolves Config from the ancestor (upward fallback)', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.add<Service>(Service.new);
      root.addInjector(feature, resolveUpward: true);
      root.commit();

      expect(root.get<Service>().config.v, 'core');
      // get from the feature itself must also resolve upward.
      expect(feature.get<Service>().config.v, 'core');
    });

    test('addSingleton: cascaded commit starts the singleton upward', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.addSingleton<Service>(Service.new);
      root.addInjector(feature, resolveUpward: true);

      // Must not throw: feature.startSingletons() resolves Config via ancestor.
      root.commit();
      expect(root.get<Service>().config.v, 'core');
    });

    test('addLazySingleton: resolves upward on first request', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.addLazySingleton<Service>(Service.new);
      root.addInjector(feature, resolveUpward: true);
      root.commit();

      final a = root.get<Service>();
      final b = root.get<Service>();
      expect(a.config.v, 'core');
      expect(identical(a, b), isTrue);
    });

    test('local/downward binds shadow the ancestor', () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      final feature = AutoInjector(tag: 'feature');
      feature.addInstance<Config>(Config('feature'));
      feature.add<Service>(Service.new);
      root.addInjector(feature, resolveUpward: true);
      root.commit();

      // feature owns its own Config -> ancestor is NOT consulted.
      expect(root.get<Service>().config.v, 'feature');
    });

    test('mutual upward link throws UpwardResolutionCycle (not stack overflow)',
        () {
      final a = AutoInjector(tag: 'a');
      final b = AutoInjector(tag: 'b');
      a.addInjector(b, resolveUpward: true); // b._upwardParent = a
      expect(
        () => b.addInjector(a, resolveUpward: true), // would close the loop
        throwsA(isA<UpwardResolutionCycle>()),
      );
    });

    test('diamond upward chain (a->b->c->a) is rejected at the closing edge',
        () {
      final a = AutoInjector(tag: 'a');
      final b = AutoInjector(tag: 'b');
      final c = AutoInjector(tag: 'c');
      a.addInjector(b, resolveUpward: true); // b -> a
      b.addInjector(c, resolveUpward: true); // c -> b -> a
      expect(
        () => c.addInjector(a, resolveUpward: true), // a -> c closes the loop
        throwsA(isA<UpwardResolutionCycle>()),
      );
    });

    test('control: provide pattern (parent as child) keeps working downward',
        () {
      final root = AutoInjector();
      root.addInstance<Config>(Config('core'));
      root.commit();

      final page = AutoInjector()..addInjector(root);
      page.add<Service>(Service.new);
      page.commit();

      expect(page.get<Service>().config.v, 'core');
    });
  });

  group('LayersGraph dispose-listener leak -', () {
    test('re-commits keep the disposeListeners count of a long-lived inner '
        'stable', () {
      final shell = AutoInjector(tag: 'shell') as AutoInjectorImpl;
      shell.addSingleton(ShellService.new);

      final root = AutoInjector(tag: 'root') as AutoInjectorImpl;
      root.addInjector(shell);
      root.commit();

      final baseline = shell.disposeListeners.length;

      // Simulate many navigation cycles that re-commit the long-lived root.
      for (var i = 0; i < 50; i++) {
        root.uncommit();
        root.commit();
      }

      expect(shell.disposeListeners.length, baseline);
    });
  });
}
