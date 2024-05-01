class Param {
  final String type;
  final String className;
  final bool isNullable;
  final bool isRequired;

  Param({
    required this.type,
    required this.className,
    required this.isNullable,
    required this.isRequired,
  });

  factory Param.fromMap(Map<String, dynamic> map) {
    return Param(
      type: map['type'] ?? '',
      className: map['className'] ?? '',
      isNullable: map['isNullable'] ?? false,
      isRequired: map['isRequired'] ?? false,
    );
  }
}
