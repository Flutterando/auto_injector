import 'package:devtools_app_shared/service.dart';
import 'package:flutter/material.dart';

import 'package:auto_injector_devtools_extension/models/injector.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.serviceManager,
  });

  final ServiceManager serviceManager;
  List<Injector> injectors = [];
  bool isLoading = false;
  String? error;

  Future<void> loadInjectors() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.auto_injector.getInjectors',
      );

      final json = result.json ?? {};

      final instanceFactories = Map<String, dynamic>.from(
        json['instanceFactories'] ?? {},
      );
      injectors = _convertInjectors(json, instanceFactories);
      injectors.sort();
      sortBinds();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void sortBinds() {
    for (final injector in injectors) {
      injector.binds.sort();
    }
  }

  List<Injector> _convertInjectors(
    Map<String, dynamic> result,
    Map<String, dynamic> instanceFactories,
  ) {
    final resultInjectors = result['injectors'] as List? ?? [];
    return resultInjectors.map(
      (injector) {
        final tag = injector['tag'] ?? '';
        final factories = Map<String, dynamic>.from(
          instanceFactories[tag] ?? {},
        );

        return Injector.fromMap(injector, factories);
      },
    ).toList();
  }
}
