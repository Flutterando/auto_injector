import 'package:flutter/material.dart';

import 'package:auto_injector_devtools_extension/models/bind.dart';

class BindTileWidget extends StatelessWidget {
  const BindTileWidget({
    super.key,
    required this.bind,
  });

  final Bind bind;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: bind.hasInstance
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(bind.iconByType()),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bind.key.isNotEmpty) Text('Key: ${bind.key}'),
                if (bind.className.isNotEmpty) Text('Name: ${bind.className}'),
                Text('Type: ${bind.typeName}'),
              ],
            ),
            const Spacer(),
            Text(
              bind.hasInstance
                  ? bind.totalInstances != null
                      ? 'CREATED ${bind.totalInstances}x'
                      : 'INSTANTIATED'
                  : 'NOT INSTANTIATED',
            ),
          ],
        ),
      ),
    );
  }
}

extension on Bind {
  IconData iconByType() {
    switch (typeName) {
      case 'instance':
        return Icons.data_object;
      case 'factory':
        return Icons.factory;
      case 'singleton':
        return Icons.download;
      case 'lazySingleton':
        return Icons.upload;
      default:
        return Icons.help;
    }
  }
}
