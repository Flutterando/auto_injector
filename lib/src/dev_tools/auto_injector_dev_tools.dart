// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
part of '../auto_injector_base.dart';

class AutoInjectorDevTools {
  AutoInjectorDevTools._();
  static final _singleton = AutoInjectorDevTools._();

  static AutoInjectorDevTools? create() {
    if (_kDebugMode) return _singleton;

    return null;
  }

  static const bool _kDebugMode = !bool.fromEnvironment('dart.vm.product') && !bool.fromEnvironment('dart.vm.profile');

  final List<AutoInjectorImpl> injectors = [];
  final Map<String, Map<String, int>> instanceFactories = {};
  static bool initialized = false;

  void addInjector(AutoInjectorImpl injector) {
    injectors.add(injector);
    if (!initialized) initialize();
  }

  void updateInstanceFactory(
    AutoInjectorImpl injectorOwner,
    Bind bindWithInstance,
  ) {
    final injectorOwnerTag = injectorOwner._tag;
    final key = bindWithInstance.className ?? bindWithInstance.key ?? bindWithInstance.instance.runtimeType.toString();
    final tag = instanceFactories[injectorOwnerTag];
    if (tag == null) {
      instanceFactories[injectorOwnerTag] = {key: 1};
      return;
    }
    final count = tag[key] ?? 0;
    tag[key] = count + 1;
  }

  Future<void> initialize() async {
    registerExtension(
      'ext.auto_injector.getInjectors',
      _getInjectors,
    );
    initialized = true;
  }

  Future<ServiceExtensionResponse> _getInjectors(
    String method,
    Map<String, String> parameters,
  ) async {
    return ServiceExtensionResponse.result(
      jsonEncode({
        'injectors': injectors.map((e) => e._toMap()).toList(),
        'instanceFactories': instanceFactories,
      }),
    );
  }
}
