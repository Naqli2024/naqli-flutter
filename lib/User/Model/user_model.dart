/*class Vehicle {
  final String name;
  final List<VehicleType> types;

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
}*/


class Vehicle {
  final String name;
  final String unitType;
  final List<VehicleType> types;

  Vehicle({required this.name, required this.unitType, required this.types});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      name: json['name'],
      unitType: json['unitType'],
      types: (json['type'] as List<dynamic>)
          .map((typeJson) => VehicleType.fromJson(typeJson))
          .toList(),
    );
  }
}

class VehicleType {
  final String typeName;
  final String scale;
  final String typeImage;
  final List<LoadType> typeOfLoad;

  VehicleType({
    required this.typeName,
    required this.scale,
    required this.typeImage,
    required this.typeOfLoad,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      typeName: json['typeName'],
      scale: json['scale'] ?? '',
      typeImage: json['typeImage'],
      typeOfLoad: (json['typeOfLoad'] as List<dynamic>?)
          ?.map((loadJson) => LoadType.fromJson(loadJson))
          .toList() ??
          [],
    );
  }
}

class LoadType {
  final String load;

  LoadType({required this.load});

  factory LoadType.fromJson(Map<String, dynamic> json) {
    return LoadType(load: json['load']);
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


class UserInvoiceModel {
  final bool success;
  final String message;
  final List<Invoice> invoices;

  UserInvoiceModel({
    required this.success,
    required this.message,
    required this.invoices,
  });

  factory UserInvoiceModel.fromJson(Map<String, dynamic> json) {
    return UserInvoiceModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      invoices: (json['bookings'] as List<dynamic>?)
          ?.map((invoice) => Invoice.fromJson(invoice))
          .toList() ??
          [],
    );
  }
}

class Invoice {
  final String id;
  final String name;
  final String invoiceId;
  final String user;
  final String paymentType;
  final String unitType;
  final String pickup;
  final List dropPoints;
  final String city;
  final String partnerId;
  final int paymentAmount;

  Invoice( {
    required this.id,
    required this.name,
    required this.invoiceId,
    required this.user,
    required this.paymentType,
    required this.unitType,
    required this.pickup,
    required this.dropPoints,
    required this.city,
    required this.partnerId,
    required this.paymentAmount,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      invoiceId: json['invoiceId'] ?? '',
      user: json['user'] ?? '',
      paymentType: json['paymentType'] ?? 'N/A',
      unitType: json['unitType'] ?? '',
      pickup: json['pickup'] ?? '',
      dropPoints: json['dropPoints'] ?? [],
      city: json['city'] ?? '',
      partnerId: json['partner'] ?? '',
      paymentAmount: json['paymentAmount'] ?? 0,
    );
  }
}