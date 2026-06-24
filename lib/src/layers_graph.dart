// ignore_for_file: public_member_api_docs, omit_local_variable_types

part of 'auto_injector_base.dart';

class LayersGraph {
  final LinkedHashMap<AutoInjectorImpl, List<AutoInjectorImpl>> adjacencyList;

  /// Dispose listeners this graph registered on inner injectors, kept so that
  /// a re-[initialize] can de-register them first and stay idempotent.
  /// Without this, every [AutoInjectorImpl.commit] (which re-runs [initialize])
  /// would stack one more listener on each long-lived inner injector, leaking
  /// closures that retain the inner, its parent and this [adjacencyList].
  final _registeredDisposeListeners =
      <MapEntry<AutoInjectorImpl, VoidCallback>>[];

  LayersGraph()
      : adjacencyList = LinkedHashMap(
          equals: (injector1, injector2) => injector1._tag == injector2._tag,
          hashCode: (injector) => injector._tag.hashCode,
          isValidKey: (key) => key is AutoInjectorImpl && key._tag.isNotEmpty,
        );

  /// Fills the [adjacencyList] with this [injector] and its children tree.
  void initialize(AutoInjectorImpl injector) {
    _clearDisposeListeners();
    _initialize(injector);
  }

  void _initialize(AutoInjectorImpl injector) {
    _addInjector(injector);
    for (final innerInjector in injector.injectorsList) {
      _addEdge(injector, innerInjector);
      _initialize(innerInjector);
      _removeWhenDispose(
        innerInjector: innerInjector,
        parentInjector: injector,
      );
    }
  }

  /// De-register every dispose listener previously added by this graph so a
  /// re-[initialize] does not accumulate duplicates on surviving injectors.
  void _clearDisposeListeners() {
    for (final entry in _registeredDisposeListeners) {
      entry.key.removeDisposeListener(entry.value);
    }
    _registeredDisposeListeners.clear();
  }

  /// Listen the [innerInjector] to remove it from this [LayersGraph].
  void _removeWhenDispose({
    required AutoInjectorImpl parentInjector,
    required AutoInjectorImpl innerInjector,
  }) {
    void listener() {
      // Remove the adjacents of [innerInjector] on [adjacencyList]
      adjacencyList.remove(innerInjector);

      // Remove [innerInjector] from [parentInjector] on [adjacencyList]
      adjacencyList[parentInjector]?.remove(innerInjector);
    }

    _registeredDisposeListeners.add(MapEntry(innerInjector, listener));
    innerInjector.addDisposeListener(listener);
  }

  /// Starts the [adjacencyList] for this [injector].<br/><br/>
  /// **NOTE:** This function doesn't fill the [adjacencyList]. It only creates
  /// an empty adjacency list to this injector
  void _addInjector(AutoInjectorImpl injector) {
    adjacencyList[injector] = [];
  }

  void _addEdge(AutoInjectorImpl source, AutoInjectorImpl target) {
    adjacencyList[source]?.add(target);
  }

  /// Returns a MapEntry. The value is the found [Bind] and the key
  /// is the [AutoInjectorImpl] that have this bind.
  /// <br/><br/> **NOTE: Algorithm based on BFS (breadth-first search)**
  MapEntry<AutoInjectorImpl, Bind>? getBindByClassName(
    AutoInjectorImpl startInjector, {
    required String className,
  }) {
    final injector = getFirstInjectorWhere(startInjector, (currentInjector) {
      for (final Bind bind in currentInjector.binds) {
        if (bind.className == className) return true;
      }
      return false;
    });
    if (injector == null) return null;
    final bind =
        injector.binds.firstWhere((bind) => bind.className == className);
    return MapEntry(injector, bind);
  }

  /// Returns a MapEntry. The value is the found [Bind] and the key
  /// is the [AutoInjectorImpl] that have this bind.
  /// <br/><br/> **NOTE: Algorithm based on BFS (breadth-first search)**
  MapEntry<AutoInjectorImpl, Bind>? getBindByKey(
    AutoInjectorImpl startInjector, {
    required String bindKey,
  }) {
    final injector = getFirstInjectorWhere(startInjector, (currentInjector) {
      for (final Bind bind in currentInjector.binds) {
        if (bind.key == bindKey) return true;
      }
      return false;
    });
    if (injector == null) return null;
    final bind = injector.binds.firstWhere((bind) => bind.key == bindKey);
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
    _clearDisposeListeners();
    adjacencyList.clear();
  }
}
