/// AutoInjection Exception with ToString auto configured
/// <br>
/// [message]: message of exception<br>
/// [stackTrace]: traces of exception
class AutoInjectorException implements Exception {
  /// message of exception
  final String message;

  /// traces of exception
  final StackTrace? stackTrace;

  /// AutoInjection Exception with ToString auto configured
  const AutoInjectorException(this.message, [this.stackTrace]);

  String get _typeName => 'AutoInjectorException';

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
/// [message]: message of exception<br>
/// [stackTrace]: traces of exception
/// [classNames]: all parent class names
class UnregisteredInstance extends AutoInjectorException {
  /// all parent class names;
  final List<String> classNames;

  /// AutoInjection Exception for Unregistered instance.
  /// <br>
  /// Store all parent classNames
  /// [message]: message of exception<br>
  /// [stackTrace]: traces of exception
  /// [classNames]: all parent class names
  UnregisteredInstance(this.classNames, [super.message = '', super.stackTrace]);

  @override
  String get _typeName => 'UnregisteredInstance';

  @override
  String toString() {
    var message = '$_typeName: ${this.message}\n${classNames.join(' => ')}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}
