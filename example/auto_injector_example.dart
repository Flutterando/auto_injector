import 'package:auto_injector/auto_injector.dart';

final homeModule = AutoInjector(
  paramTransforms: [
    (param) {
      return param;
    }
  ],
  on: (i) {
    i.addInjector(productModule);
    i.addInjector(userModule);
  },
);

final productModule = AutoInjector(
  on: (i) {
    i.addInstance(1);
  },
);

final userModule = AutoInjector(
  on: (i) {
    i.addInstance(true);
  },
);

void main() {
  print(homeModule.get<int>());
  print(homeModule.get<bool>());
}
