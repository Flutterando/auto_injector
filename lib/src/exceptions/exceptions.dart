/// AutoInjecton Exception with ToString auto configurated
/// <br>
/// [message]: message of exception<br>
/// [stackTrace]: traces of exception
class AutoInjectorException implements Exception {
  /// message of exception
  final String message;

  /// traces of exception
  final StackTrace? stackTrace;

  /// AutoInjecton Exception with ToString auto configurated
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

/// AutoInjecton Exception for Unregistered instance.
/// <br>
/// Store all parent classNames
/// [message]: message of exception<br>
/// [stackTrace]: traces of exception
/// [classNames]: all parent class names
class UnregisteredInstance extends AutoInjectorException {
  /// all parent class names;
  final List<String> classNames;

  /// AutoInjecton Exception for Unregistered instance.
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
