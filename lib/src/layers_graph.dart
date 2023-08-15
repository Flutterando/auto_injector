// ignore_for_file: public_member_api_docs, library_private_types_in_public_api,
// ignore_for_file:  omit_local_variable_types, prefer_final_in_for_each, lines_longer_than_80_chars

part of 'auto_injector_base.dart';

class LayersGraph {
  final List<AutoInjectorImpl> modules;
  final Map<AutoInjectorImpl, List<AutoInjectorImpl>> adjacencyList;

  LayersGraph()
      : modules = [],
        adjacencyList = {};

  void addInjectorRecursive(AutoInjectorImpl injector) {
    addInjector(injector);
    for (final innerInjector in injector.injectorsList) {
      _addEdge(injector, innerInjector);
      addInjectorRecursive(innerInjector);
    }
  }

  void addInjector(AutoInjectorImpl module) {
    modules.add(module);
    adjacencyList[module] = [];
  }

  void _addEdge(AutoInjectorImpl source, AutoInjectorImpl target) {
    adjacencyList[source]?.add(target);
  }

  /// Returns a MapEntry. The value is the found [Bind] and the key is the [AutoInjectorImpl] that have this bind.
  /// <br/><br/> **NOTE: Algorithm based on BFS (breadth-first search)**
  MapEntry<AutoInjectorImpl, Bind>? getBindByClassName(
    AutoInjectorImpl startInjector, {
    required String className,
  }) {
    final injector = getFirstInjectorWhere(startInjector, (currentInjector) {
      for (Bind bind in currentInjector.binds) {
        if (bind.className == className) return true;
      }
      return false;
    });
    if (injector == null) return null;
    final bind =
        injector.binds.firstWhere((bind) => bind.className == className);
    return MapEntry(injector, bind);
  }

  /// Execute [callback] in all the injectors.
  /// <br/><br/> **NOTE: Algorithm based on BFS (breadth-first search)**
  void executeInAllInjectors<T>(
    AutoInjectorImpl startInjector,
    T Function(AutoInjectorImpl) callback,
  ) {
    final visited = <AutoInjectorImpl>{};
    final queue = Queue<AutoInjectorImpl>();
    queue.add(startInjector);

    while (queue.isNotEmpty) {
      final currentInjector = queue.removeFirst();
      callback(currentInjector);

      if (adjacencyList[currentInjector] == null) continue;

      for (final adjacentInjector in adjacencyList[currentInjector]!) {
        if (!visited.contains(adjacentInjector)) {
          visited.add(adjacentInjector);
          queue.add(adjacentInjector);
        }
      }
    }
  }

  /// Returns the first injector that pass in the [validation].
  /// <br/><br/> **NOTE: Algorithm based on BFS (breadth-first search)**
  AutoInjectorImpl? getFirstInjectorWhere(
    AutoInjectorImpl startInjector,
    bool Function(AutoInjectorImpl) validation,
  ) {
    final visited = <AutoInjectorImpl>{};
    final queue = Queue<AutoInjectorImpl>();
    queue.add(startInjector);

    while (queue.isNotEmpty) {
      final currentInjector = queue.removeFirst();
      if (validation(currentInjector)) {
        return currentInjector;
      }

      if (adjacencyList[currentInjector] == null) continue;

      for (final adjacentInjector in adjacencyList[currentInjector]!) {
        if (!visited.contains(adjacentInjector)) {
          visited.add(adjacentInjector);
          queue.add(adjacentInjector);
        }
      }
    }
    return null;
  }

  void reset() {
    modules.clear();
    adjacencyList.clear();
  }
}
