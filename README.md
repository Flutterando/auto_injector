<a name="readme-top"></a>


<h1 align="center">Auto Injector - Automatic Dependency injection system without build_runner.</h1>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- You should link the logo to the pub dev page of you project or a homepage otherwise -->
  <a href="https://github.com/Flutterando/README-Template/">
    <img src="https://github.com/Flutterando/auto_injector/blob/documentation/readme_assets/logo-auto-injection.png" alt="Logo" width="180">
  </a>

  <p align="center">
    A simple way to inject dependencies in your project.
    <br />
    <!-- Put the link for the documentation here -->
    <a href="https://pub.dev/packages/auto_injector"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- Disable unused links with with comments -->
    <!--<a href="https://pub.dev/publishers/flutterando.com.br/packages">View Demo</a> -->
    ·
    <!-- The Report Bug and Request Feature should point to the issues page of the project, in this example we use the pull requests page because this is a github template -->
    <a href="https://github.com/flutterando/auto_injector/issues">Report Bug</a>
    ·
    <a href="https://github.com/flutterando/auto_injector/issues">Request Feature</a>
  </p>

<br>

<!--  SHIELDS  ---->


<!-- The shields here are an example of what could be used and are the most recommended, there are more below in the "some recomendations about shields" section. 
See the links in the example below, changing the parts after img.shields.io you can change the content of the shields. Alternatively, go to the website and generate new shields.  

[![Version](https://img.shields.io/github/v/release/flutterando/auto_injector?style=plastic)](https://pub.dev/packages/auto_injector)
[![Pub Points](https://img.shields.io/pub/points/auto_injector?label=pub%20points&style=plastic)](https://pub.dev/packages/auto_injector/score)
[![Flutterando Analysis](https://img.shields.io/badge/style-flutterando__analysis-blueviolet?style=plastic)](https://pub.dev/packages/flutterando_analysis/)

[![Pub Publisher](https://img.shields.io/pub/publisher/auto_injector?style=plastic)](https://pub.dev/publishers/flutterando.com.br/packages)



The ones used here are:
- Release version
- Pub Points
- style: Flutterando analysis
- publisher: Flutterando --->

[![Version](https://img.shields.io/github/v/release/flutterando/auto_injector?style=plastic)](https://pub.dev/packages/auto_injector)
[![Pub Points](https://img.shields.io/pub/points/auto_injector?label=pub%20points&style=plastic)](https://pub.dev/packages/auto_injector/score)
[![Flutterando Analysis](https://img.shields.io/badge/style-flutterando__analysis-blueviolet?style=plastic)](https://pub.dev/packages/flutterando_analysis/)

[![Pub Publisher](https://img.shields.io/pub/publisher/auto_injector?style=plastic)](https://pub.dev/publishers/flutterando.com.br/packages)
</div>

<!----
About Shields, some recommendations:
+-+
Build - GithubWorkflow ou Github Commit checks state
CodeCoverage - Codecov
Chat - Discord 
License - Github
Rating - Pub Likes, Pub Points and Pub Popularity (if still in early stages, we recommend only Pub Points since it's controllable)
Social - GitHub Forks, Github Org's Stars (if using Flutterando as the main org), YouTube Channel Subscribers (Again, using Flutterando, as set in the example)
--->

<br>

---
<!-- TABLE OF CONTENTS -->
<!-- Linked to every ## title below -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#sponsors">Sponsors</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#how-to-use">How to Use</a></li>
     <ol>
      <li><a href="#dispose-singleton">Dispose Singleton</a></li>
      <li><a href="#modularization">Modularization</a></li>
      <li><a href="#param-transform">Param Transform</a></li>
     </ol>
    <li><a href="#features">Features</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

---

<br>

<!-- ABOUT THE PROJECT -->
## About The Project
Auto Injector is a Dart package that was created to make the developer's life easier, making the method of how to do dependency injection simpler and more practical.
Just create the class that will be injected and declare it within some of the available "add" methods and that's it, you already have your dependency injection ready to use.


<i>This project is distributed under the MIT License. See `LICENSE.txt` for more information.
</i>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SPONSORS -->
<!-- For now FTeam is the only sponsor for Flutterando packages. The community is open to more support for it's open source endeavors, so check it out and make contact with us through the links provided at the end -->
## Sponsors

<a href="https://fteam.dev">
    <img src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/sponsor-logo.png" alt="Logo" width="120">
  </a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
<br>


<!-- GETTING STARTED -->
## Getting Started

<!---- The description provided below was aimed to show how to install a pub.dev package, change it as you see fit for your project ---->
To get Auto Injector in your project follow either of the instructions below:

a) Add your_package as a dependency in your Pubspec.yaml:
 ```yaml
   dependencies:
     auto_injector: ^1.0.2
``` 

b) Use Dart Pub:
```sh
   dart pub add auto_injector
```

<br>


## How to Use

<!---- In this section, provide a simple and short explanation of the base use of your project and a link to your documentation for more advanced uses --->


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

<br>

_For more examples, please refer to the_ [Documentation](https://pub.dev/documentation/auto_injector/latest/) 

<!---- You can use the emoji 🚧 to indicate Work In Progress sections ---->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FEATURES -->

<!---- Use this section to highlight your features and show  what is under progress. Use emojis for better communication if needed like ✅ for tasks done and 🚧 for Work In Progress ---->
## Features

- ✅ Auto Dependency Injection
- ✅ Factory Injection
- ✅ Singleton Injection
- ✅ Lazy Singleton Injection
- ✅ Instance Injection

Right now this package has concluded all his intended features. If you have any suggestions or find something to report, see below how to contribute to it. 

<!---- 
We suggest, in case of the roadmap of features has been completed, to include the text below:

Right now this package has concluded all his intended features. If you have any suggestions or find something to report, see below how to contribute to it. 
---->


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing 

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

<!---- Those are the current Flutterando contacts as of 25 August 2022 --->
## Contact

Flutterando Community
- [Discord](https://discord.gg/qNBDHNARja)
- [Telegram](https://t.me/flutterando)
- [Website](https://www.flutterando.com.br)
- [Youtube Channel](https://www.youtube.com.br/flutterando)
- [Other useful links](https://linktr.ee/flutterando)


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements 


Thank you to all the people who contributed to this project, whithout you this project would not be here today.

<br>

<!---- Change the link below to the contributors page of your project and change the repo= in the img src to properly point to your repository -->

<a href="https://github.com/flutterando/auto_injector/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=flutterando/auto_injector" />
</a>

<!-- Here is an alternative to the contributors page: https://allcontributors.org/
And the link for the currently used option in this readme: https://contrib.rocks/ -->


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MANTAINED BY -->
## Maintaned by

<br>
<p align="center">
  <a href="https://www.flutterando.com.br">
    <img width="110px" src="https://raw.githubusercontent.com/Flutterando/README-Template/master/readme_assets/logo-flutterando.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://www.flutterando.com.br">Flutterando</a>.
  </p>
</p>




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- [Choose an Open Source License](https://choosealicense.com)
[GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
[Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
[Malven's Grid Cheatsheet](https://grid.malven.co/)
[Img Shields](https://shields.io)
[GitHub Pages](https://pages.github.com)
[Font Awesome](https://fontawesome.com)
[React Icons](https://react-icons.github.io/react-icons/search) 

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com  -->
