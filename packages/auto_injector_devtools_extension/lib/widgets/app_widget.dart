import 'package:devtools_extensions/devtools_extensions.dart'
    if (dart.library.io) 'package:auto_injector_devtools_extension/controllers/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:auto_injector_devtools_extension/controllers/app_controller.dart';
import 'package:auto_injector_devtools_extension/widgets/injector_tile_widget.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({
    super.key,
    this.controller,
  });

  final AppController? controller;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late AppController controller = widget.controller ??
      AppController(
        serviceManager: serviceManager,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInjectors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoInjector Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadInjectors,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final error = controller.error;

          return Column(
            children: [
              if (controller.isLoading) const LinearProgressIndicator(),
              if (error != null)
                Center(child: Text(error))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.injectors.length,
                    itemBuilder: (context, index) {
                      final injector = controller.injectors[index];
                      return InjectorTileWidget(
                        injector: injector,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
