# Auto Injector

Automatic Dependency injection system without build_runner :)

## Usage

Register instances:

```dart
final autoInjector = AutoInjector();

void main(){


    // factory
    autoInjector.add(Controller.new);
    // Singleton
    autoInjector.addSingleton(Datasource.new);
    // lazySingleton
    autoInjector.addLazySingleton(Repository.new);
    // instance
    autoInjector.instance('Instance');

    // Inform that you have finished adding instances
    autoInjector.commit();

}


class Controller {
    final Repository repository;

    Controller(this.repository);
}

class Repository {
    final Datasource datasource;

    Repository({required this.datasource});
}

class Datasource {}

```

Get instance:

```dart
  // fetch
  final controller = autoInjector.get<Controller>();
  print(controller); // Instance of 'Controller'.

  // or use calleble function (withless .get())
  final datasource = autoInjector<Datasource>();
  print(datasource); // Instance of 'Datasource'.
```

Try get instance:

```dart
  // use tryGet that returns null if exception.
  final datasource = autoInjector.tryGet<Datasource>() ?? Datasource();
  print(datasource); // Instance of 'Datasource'.
```

Get instance and transform params.
This can be used for example to replace an instance with a mock in tests.

```dart
  final datasource = autoInjector.get<Datasource>(transform: changeParam(DataSourceMock()));
  print(datasource); // Instance of 'Datasource'.
```

## Dispose Singleton

Singletons can be terminated on request using the `disposeSingleton` method returning
the instance for executing the dispose routine.

```dart

final deadInstance = autoInjector.disposeSingleton<MyController>();
deadInstance.close();

```

## Modularization

For projects with multiple scopes, try uniting the instances by naming them Module or Container.
With this, you can register specific instances for each module.

```dart

// app_module.dart
final appModule = AutoInjector(
  tag: 'AppModule',
  on: (i) {
    i.addInjector(productModule);
    i.addInjector(userModule);
    i.commit();
  },
);

...

// product_module.dart
final productModule = AutoInjector(
  tag: 'ProductModule',
  on: (i) {
    i.addInstance(1);
  },
);

...

// user_module.dart
final userModule = AutoInjector(
  tag: 'UserModule',
  on: (i) {
    i.addInstance(true);
  },
);

...

void main() {
  print(appModule.get<int>());
  print(appModule.get<bool>());
}

```

It is also possible to remove all singletons from a specific tag using the method
`disposeSingletonsByTag` which reports each instance removed via an anonymous function:

```dart
autoInjector.disposeSingletonsByTag('ProductModule', (instance){
  // individual dispose routine
});
```

## Param Transform

There is the possibility to listen and transform all the parameters that are being analyzed
when there is an instance request (`AutoInject.get()`). Add transformers on the main instance:

```dart
final homeModule = AutoInjector(
  paramTransforms: [
    (param) {
    if(param is NamedParam){
        return param;
    } else if(param is PositionalParam) {
        return param;
    }
  ],
);

```
