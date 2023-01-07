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

class NotRegistredInstance extends AutoInjectorException {
  final List<String> classNames;
  NotRegistredInstance(this.classNames, [super.message = '', super.stackTrace]);
}
