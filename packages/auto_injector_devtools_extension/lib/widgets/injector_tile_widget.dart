import 'package:auto_injector_devtools_extension/models/injector.dart';
import 'package:auto_injector_devtools_extension/widgets/bind_tile_widget.dart';
import 'package:flutter/material.dart';

class InjectorTileWidget extends StatefulWidget {
  const InjectorTileWidget({
    super.key,
    required this.injector,
  });

  final Injector injector;

  @override
  State<InjectorTileWidget> createState() => _InjectorTileWidgetState();
}

class _InjectorTileWidgetState extends State<InjectorTileWidget> {
  Injector get injector => widget.injector;

  String get getSubtile {
    return 'Binds: ${injector.binds.length} | Injectors: ${injector.injectorsList.length}';
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        injector.isCommitted ? Icons.check : Icons.close,
        color: injector.isCommitted ? Colors.green : Colors.red,
      ),
      title: Text(injector.tag),
      subtitle: Text(getSubtile),
      children: [
        ListView.builder(
          itemCount: injector.binds.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return BindTileWidget(
              bind: injector.binds[index],
            );
          },
        ),
      ],
    );
  }
}
