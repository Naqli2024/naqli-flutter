class Vehicle {
  final String name;
  final List<VehicleType> types;  // Correcting to use List<VehicleType> only

  Vehicle({required this.name, required this.types});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'] ?? '',
      types: (json['type'] as List<dynamic>?)
          ?.map((item) => VehicleType.fromJson(item))
          .toList() ?? [],
    );
  }
}

class VehicleType {
  final String typeName;
  final String typeImage;
  final String scale;
  final List<LoadType> typeOfLoad;

  VehicleType({
    required this.typeName,
    required this.typeImage,
    required this.scale,
    required this.typeOfLoad,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      typeName: json['typeName'] ?? '',
      typeImage: json['typeImage'] ?? '',
      scale: json['scale'] ?? '',
      typeOfLoad: (json['typeOfLoad'] as List<dynamic>?)
          ?.map((load) => LoadType.fromJson(load))
          .toList() ?? [],
    );
  }
}

class LoadType {
  final String load; // Ensure this property matches what you're trying to display

  LoadType({required this.load});

  factory LoadType.fromJson(Map<String, dynamic> json) {
    return LoadType(
      load: json['load'], // Ensure this field exists in your JSON
    );
  }
}

class Buses {
  final String name;
  final String image;

  Buses({required this.name,required this.image});

  factory Buses.fromJson(Map<String, dynamic> json) {
    return Buses(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Special {
  final String name;
  final String image;

  Special({required this.name,required this.image});

  factory Special.fromJson(Map<String, dynamic> json) {
    return Special(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Equipment {
  final String name;
  final List<EquipmentType>? types;

  Equipment({required this.name, this.types});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'] ?? '',
      types: (json['type'] as List<dynamic>?)
          ?.map((item) => EquipmentType.fromJson(item))
          .toList(),
    );
  }
}

class EquipmentType {
  final String typeName;
  final String typeImage;
  final String scale;

  EquipmentType({required this.typeName, required this.typeImage, required this.scale});

  factory EquipmentType.fromJson(Map<String, dynamic> json) {
    return EquipmentType(
      typeName: json['typeName'] ?? '',
      typeImage: json['typeImage'] ?? '',
      scale: json['scale'] ?? '',
    );
  }
}