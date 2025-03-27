import 'package:intl/intl.dart';

class Operator {
  final String unitType;
  final String unitClassification;
  final String subClassification;
  final String plateInformation;
  final String istimaraNo;
  final String istimaraCard;
  final String pictureOfVehicle;
  final List<OperatorDetail> operatorsDetail;

  Operator({
    required this.unitType,
    required this.unitClassification,
    required this.subClassification,
    required this.plateInformation,
    required this.istimaraNo,
    required this.istimaraCard,
    required this.pictureOfVehicle,
    required this.operatorsDetail,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    var operatorsDetailList = json['operatorsDetail'] as List? ?? [];
    List<OperatorDetail> parsedOperatorsDetail =
    operatorsDetailList.map((e) => OperatorDetail.fromJson(e)).toList();

    return Operator(
      unitType: json['unitType'] ?? '',
      unitClassification: json['unitClassification'] ?? '',
      subClassification: json['subClassification'] ?? '',
      plateInformation: json['plateInformation'] ?? '',
      istimaraNo: json['istimaraNo'] ?? '',
      istimaraCard: json['istimaraCard'] != null && json['istimaraCard']['fileName'] != null
          ? json['istimaraCard']['fileName']
          : 'Upload a file',

      pictureOfVehicle: json['pictureOfVehicle'] != null && json['pictureOfVehicle']['fileName'] != null
          ? json['pictureOfVehicle']['fileName']
          : 'Upload a file',
      operatorsDetail: parsedOperatorsDetail,
    );
  }
}

class OperatorDetail {
  final String operatorId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNo;
  final String iqamaNo;
  final String dateOfBirth;
  final String panelInformation;
  final String drivingLicense;
  final String aramcoLicense;
  final String nationalID;

  OperatorDetail({
    required this.operatorId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.iqamaNo,
    required this.dateOfBirth,
    required this.panelInformation,
    required this.drivingLicense,
    required this.aramcoLicense,
    required this.nationalID,
  });

  factory OperatorDetail.fromJson(Map<String, dynamic> json) {
    return OperatorDetail(
      operatorId: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      iqamaNo: json['iqamaNo'] ?? '',
      panelInformation: json['panelInformation'] ?? '',
      drivingLicense: json['drivingLicense'] != null && json['drivingLicense']['fileName'] != null
          ? json['drivingLicense']['fileName']
          : 'Upload a file',

      aramcoLicense: json['aramcoLicense'] != null && json['aramcoLicense']['fileName'] != null
          ? json['aramcoLicense']['fileName']
          : 'Upload a file',

      nationalID: json['nationalID'] != null && json['nationalID']['fileName'] != null
          ? json['nationalID']['fileName']
          : 'Upload a file',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['dateOfBirth']))
          : '',
    );
  }
}

