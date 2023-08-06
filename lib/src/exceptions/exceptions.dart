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
  String toString() {
    var message = '$_typeName: ${this.message}\n${classNames.join(' => ')}';
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
class InjectorAlreadyCommited extends AutoInjectorException {
  /// all parent class names;
  final String injectorTag;

  /// AutoInjecton Exception for Unregistered instance.
  /// <br>
  /// Store all parent classNames
  /// [message]: message of exception<br>
  /// [stackTrace]: traces of exception
  /// [classNames]: all parent class names
  InjectorAlreadyCommited(
    this.injectorTag, [
    super.message = '',
    super.stackTrace,
  ]);

  @override
  String toString() {
    var message =
        '$_typeName: ${this.message}\nAutoInjector(tag: $injectorTag)';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}
