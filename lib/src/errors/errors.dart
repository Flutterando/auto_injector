class AutoInjectorException extends Error {
  final String message;
  @override
  final StackTrace? stackTrace;

  AutoInjectorException(this.message, [this.stackTrace]);

  @override
  String toString() {
    var message = '$runtimeType: ${this.message}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

class UnregisteredInstance extends AutoInjectorException {
  final List<String> classNames;
  UnregisteredInstance(this.classNames, [super.message = '', super.stackTrace]);
}
