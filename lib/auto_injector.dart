/// This code is managed by the `auto_injector` package.
/// It is responsible for automatically injecting dependencies into the application.
/// The generated code ensures that all required dependencies are properly initialized
/// and available for use throughout the application lifecycle.
library;

export 'src/auto_injector_base.dart' hide AutoInjectorImpl, VoidCallback;
export 'src/bind.dart';
export 'src/exceptions/exceptions.dart';
export 'src/param.dart';
