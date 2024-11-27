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
  final String load;

  LoadType({required this.load});

  factory LoadType.fromJson(Map<String, dynamic> json) {
    return LoadType(
      load: json['load'],
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


class UserDataModel{
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String password;
  final String confirmPassword;
  final int contactNumber;
  final String alternateNumber;
  final String address1;
  final String address2;
  final String city;
  final String accountType;
  final String govtId;
  final int idNumber;

  UserDataModel({required this.firstName, required this.lastName, required this.emailAddress, required this.password, required this.confirmPassword, required this.contactNumber, required this.alternateNumber, required this.address1, required this.address2, required this.city, required this.accountType, required this.govtId, required this.idNumber});

  factory UserDataModel.fromJson(Map<String,dynamic> json){
    return UserDataModel(firstName: json['firstName']??'', lastName: json['lastName']??'', emailAddress: json['emailAddress']??'', password: json['password']??'', confirmPassword: json['confirmPassword']??'', contactNumber: json['contactNumber']??0, alternateNumber: json['alternateNumber']??'', address1: json['address1']??'', address2: json['address2']??'', city: json['city']??'', accountType: json['accountType']??'', govtId: json['govtId']??'', idNumber: json['idNumber']??0);
  }
}