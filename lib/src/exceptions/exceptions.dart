/// AutoInjection Exception with ToString auto configured
/// <br>
/// [message] : message of exception<br>
/// [stackTrace] : traces of exception
class AutoInjectorException implements Exception {
  /// message of exception
  final String message;

  /// traces of exception
  final StackTrace? stackTrace;

  /// AutoInjection Exception with ToString auto configured
  AutoInjectorException(this.message, [this.stackTrace]);

  // ignore: no_runtimetype_tostring
  late final String _typeName = '$runtimeType';

  @override
  String toString() {
    var message = '$_typeName: ${this.message}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

/// AutoInjection Exception for Unregistered instance.
/// <br>
/// Store all parent classNames
/// [message] : message of exception<br>
/// [stackTrace] : traces of exception<br>
/// [classNames] : all parent class names
class UnregisteredInstance extends AutoInjectorException {
  /// all parent class names;
  final List<String> classNames;

  /// AutoInjection Exception for Unregistered instance.
  /// <br>
  /// Store all parent classNames
  /// [message] : message of exception<br>
  /// [stackTrace] : traces of exception<br>
  /// [classNames] : all parent class names
  UnregisteredInstance(this.classNames, [super.message = '', super.stackTrace]);

  @override
  String toString() {
    var message = '$_typeName: ${this.message}\n${classNames.join(' => ')}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }

  /// instance with stackTrace prints
  UnregisteredInstance withExceptionTrace() {
    final trace = classNames.join('->');
    var message = this.message;
    if (classNames.length > 1) {
      message = '$message\nTrace: $trace';
    }
    return UnregisteredInstance(classNames, message);
  }
}

/// AutoInjection Exception for Unregistered instance.
/// <br>
/// Store all parent classNames
/// [message] : message of exception<br>
/// [stackTrace] : traces of exception<br>
class UnregisteredInstanceByKey extends AutoInjectorException {
  /// all parent class names;
  final List<String> keys;

  /// AutoInjection Exception for Unregistered instance.
  /// <br>
  /// Store all parent classNames
  /// [message] : message of exception<br>
  /// [stackTrace] : traces of exception<br>
  /// [keys] : all parent keys
  UnregisteredInstanceByKey(this.keys, [super.message = '', super.stackTrace]);

  @override
  String toString() {
    var message = '$_typeName: ${this.message}\n${keys.join(' => ')}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

/// AutoInjection Exception thrown when an `addInjector(..., resolveUpward: true)`
/// edge would create a cycle in the upward (ancestor) resolution chain.
/// <br>
/// Upward resolution must form a tree: a child resolves against its ancestor as
/// a fallback, never the other way around. A mutual upward link would make
/// resolution recurse forever, so it is rejected eagerly at composition time.
/// <br>
/// [injectorTag] : tag of the injector at which the cycle was detected
class UpwardResolutionCycle extends AutoInjectorException {
  /// tag of the injector at which the cycle was detected
  final String injectorTag;

  /// AutoInjection Exception for an upward resolution cycle.
  UpwardResolutionCycle(
    this.injectorTag, [
    super.message = '',
    super.stackTrace,
  ]);

  @override
  String toString() {
    var message = '$_typeName: ${this.message}'
        '\nupward resolution cycle detected at tag $injectorTag';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

/// AutoInjecton Exception for Injector Already Commited.
/// <br>
/// Store all parent classNames
/// [message] : message of exception<br>
/// [stackTrace] : traces of exception<br>
/// [injectorTag] : tag of the current injector
class InjectorAlreadyCommited extends AutoInjectorException {
  /// all parent class names;
  final String injectorTag;

  /// AutoInjecton Exception for Injector Already Commited.
  /// <br>
  /// Store all parent classNames
  /// [message] : message of exception<br>
  /// [stackTrace] : traces of exception<br>
  /// [injectorTag] : tag of the current injector
  InjectorAlreadyCommited(
    this.injectorTag, [
    super.message = '',
    super.stackTrace,
  ]);

  @override
  String toString() {
    var message = '$_typeName: ${this.message}'
        '\nAutoInjector(tag: $injectorTag)';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}
