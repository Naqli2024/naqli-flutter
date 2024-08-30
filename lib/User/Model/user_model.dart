class Vehicle {
  final String name;
  final List<Type>? types;

  Vehicle({required this.name, this.types});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      types: (json['type'] as List<dynamic>?)
          ?.map((item) => Type.fromJson(item))
          .toList(),
    );
  }
}

class Type {
  final String typeName;
  final String typeImage;

  Type({required this.typeName, required this.typeImage});

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      typeName: json['typeName'] ?? '',
      typeImage: json['typeImage'] ?? '',
    );
  }
}