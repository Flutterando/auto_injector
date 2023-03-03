<!--
*** This template was base on othneildrew's Best-README-Template. If you have a suggestion that would make this better, please fork the repo and create a pull request if it's for the template as whole. 

If it's for the Flutterando version of the template just send a message to us (our contacts are below)

*** Don't forget to give his project a star, he deserves it!
*** Thanks for your support! 
-->


  <h1 align="center">Auto Injector</h1>


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <!-- LOGO DO PROJETO -->    
    <img src="" alt="Logo" width="80" style=" padding-right: 30px;">
  </a>
  <a href="https://github.com/Flutterando/README-Template/">
    <img src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png" alt="Logo" width="95">
  </a>

  <br />
  <p align="center">
    Welcome to Auto Injector!
    Automatic Dependency injection system without build_runner. 
    <br>
    <br>
    <!-- nao tem link para o site do docsauro -->   
    <a href="">View Example</a>
    ·
    <a href="https://github.com/Flutterando/auto_injector/issues">Report Bug</a>
    ·
    <a href="https://github.com/Flutterando/auto_injector/issues">Request Feature</a>
  </p>
</div>

<br>

---


<!-- TABLE OF CONTENTS -->

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#usage">Usage</a></li>     
    <ol>
      <li><a href="#dispose-singleton">Dispose Singleton</a></li>
      <li><a href="#modularization">Modularization</a></li>
      <li><a href="#param-transform">Param Transform</a></li>
    </ol>
  </li>     
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#contributors">Contributors</a></li>
  </ol>
</details>

---

<br>

<!-- ABOUT THE PROJECT -->
## <div id="about-the-project">:memo: About The Project</div>

### What is Auto Injector?

## <div id="usage">✨ Usage</div>

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

### <div id="dispose-singleton">Dispose Singleton</div>

Singletons can be terminated on request using the `disposeSingleton` method returning
the instance for executing the dispose routine.

```dart

final deadInstance = autoInjector.disposeSingleton<MyController>();
deadInstance.close();

```

### <div id="modularization">Modularization</div>

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

### <div id="param-transform">Param Transform</div>

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

<!-- CONTRIBUTING -->
## <div id="contributing">🧑‍💻 Contributing</div>

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the appropriate tag.
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Remember to include a tag, and to follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and [Semantic Versioning](https://semver.org/) when uploading your commit and/or creating the issue.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## <div id="contact">💬 Contact</div>

Flutterando Community
- [Discord](https://discord.gg/MKPZmtrRb4)
- [Telegram](https://t.me/flutterando)
- [Website](https://www.flutterando.com.br)
- [Youtube Channel](https://www.youtube.com.br/flutterando)
- [Other useful links](https://linktr.ee/flutterando)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<br>

<!-- CONTRIBUTORS -->
## <div id="contributors">👥 Contributors</div>

<a href="https://github.com/Flutterando/auto_injector/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=flutterando/auto_injector" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MANTAINED BY -->
## 🛠️ Maintaned by

<br>

<p align="center">
  <a href="https://www.flutterando.com.br">
    <img width="110px" src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png">
  </a>
  <p align="center">
    This fork version is maintained by <a href="https://www.flutterando.com.br">Flutterando</a>.
  </p>
</p>

