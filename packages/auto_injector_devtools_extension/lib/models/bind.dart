import 'package:auto_injector_devtools_extension/models/param.dart';

class Bind implements Comparable<Bind> {
  final String className;
  final String typeName;
  final bool hasInstanceIfSingleton;
  final String key;
  final List<Param> params;
  final int? totalInstances;

  Bind({
    required this.className,
    required this.typeName,
    required this.hasInstanceIfSingleton,
    required this.key,
    required this.params,
    this.totalInstances,
  });

  bool get hasInstance =>
      hasInstanceIfSingleton || (totalInstances != null && totalInstances! > 0);

  factory Bind.fromMap(Map<String, dynamic> map, [int? totalInstances]) {
    return Bind(
      className: map['className'] ?? '',
      typeName: map['typeName'] ?? '',
      hasInstanceIfSingleton: map['hasInstance'] ?? false,
      key: map['key'] ?? '',
      params: List<Param>.from(map['params']?.map((x) => Param.fromMap(x))),
      totalInstances: totalInstances,
    );
  }

  @override
  int compareTo(Bind other) {
    if (hasInstance && !other.hasInstance) {
      return -1;
    } else if (!hasInstance && other.hasInstance) {
      return 1;
    }

    final order = {
      'instance': 0,
      'singleton': 1,
      'lazySingleton': 2,
      'factory': 3,
    };

    return (order[typeName] ?? 4).compareTo(order[other.typeName] ?? 4);
  }
}
