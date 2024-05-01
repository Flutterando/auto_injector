import 'package:auto_injector_devtools_extension/widgets/app_widget.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const DevToolsExtension(
      child: AppWidget(),
    ),
  );
}
