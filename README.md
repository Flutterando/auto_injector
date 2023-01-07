# Auto Injector

Dependency injection system. But without build_runner :)

## IMPORTANT!

This package is still under development.
Not recommended for use in production!

## Example


```dart

void main(){

    final autoInjector = AutoInjector();

    // factory
    autoInjector.add(Controller.new);

    // lazySingleton
    autoInjector.addLazySingleton(Repository.new);

    // Singleton
    autoInjector.addSingleton(Datasource.new);

    // instance
    autoInjector.instance('Instance');

    // fetch
    final controller = autoInjector.get<Controller>();
    print(controller); // Instance of 'Controller'.

    // or use calleble function (withless .get())
    final datasource = autoInjector<Datasource>();
    print(datasource); // Instance of 'Datasource'.

}


class Controller {
    final Repository repository;

    Controller(this.repository)
}

class Repository {
    final Datasource datasource;

    Repository({required this.datasource})
}

class Datasource {}

```

## Modularization

For projects with multiple scopes, try uniting the instances by naming them Module or Container.
With this, you can register specific instances for each module.

```dart

// app_module.dart
final appModule = AutoInjector(
  on: (i) {
    i.addInjector(productModule);
    i.addInjector(userModule);
  },
);

...

// product_module.dart
final productModule = AutoInjector(
  on: (i) {
    i.addInstance(1);
  },
);

...

// user_module.dart
final userModule = AutoInjector(
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

## Param Transform

Existe a possíbilidade de escutar e transformar todos os paramentros que estão sendo analisados
quando há o pedido da instancia (`AutoInject.get()`). Adicione transformadores na instância principal.

```dart
final homeModule = AutoInjector(
  paramTransforms: [
    (param) {
    if(param is NamedParam){
        return param;
    } else if(param is PositionalParam) {
        return param;
    } else {
        return param;
    }
  ],
);

```
