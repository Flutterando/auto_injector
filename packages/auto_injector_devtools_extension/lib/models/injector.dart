import 'package:auto_injector_devtools_extension/models/bind.dart';

class Injector implements Comparable<Injector> {
  final String tag;
  final int bindLength;
  final List<Bind> binds;
  final List<String> injectorsList;
  final bool isCommitted;

  Injector({
    required this.tag,
    required this.bindLength,
    required this.binds,
    required this.injectorsList,
    required this.isCommitted,
  });

  factory Injector.fromMap(
    Map<String, dynamic> map,
    Map<String, dynamic>? bindFactories,
  ) {
    return Injector(
      tag: map['tag'] ?? '',
      bindLength: map['bindLength']?.toInt() ?? 0,
      binds: List<Bind>.from(
        map['binds']?.map(
          (element) {
            final key = element['className'] ?? element['key'] ?? '';
            final y = bindFactories?[key];

            return Bind.fromMap(element, y);
          },
        ),
      ),
      injectorsList: List<String>.from(map['injectorsList']),
      isCommitted: map['committed'] ?? false,
    );
  }

  @override
  int compareTo(Injector other) {
    return other.binds.length.compareTo(binds.length);
  }
}
