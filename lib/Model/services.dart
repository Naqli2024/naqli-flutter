import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/sharedPreferences.dart';
import 'package:flutter_naqli/Views/auth/login.dart';
import 'package:flutter_naqli/Views/auth/otp.dart';
import 'package:flutter_naqli/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Views/auth/stepThree.dart';
import 'package:flutter_naqli/Views/auth/stepTwo.dart';
import 'package:flutter_naqli/Views/booking/booking_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl = 'https://naqli.onrender.com/api/partner/';
  String globalPartnerId = '';
  Future<void> registerUser(context,{
    required String partnerName,
    required String mobileNo,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${baseUrl}register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': role,
        'partnerName': partnerName,
        'mobileNo': mobileNo,
        'email': email,
        'password': password,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(mobileNo: mobileNo,partnerName: partnerName,password: password, email: email,),
        ),
      );
    } else {
      final message = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to register user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> validateOTP(context,{
    required String otp,
    required String partnerName,
    required String email,
    required String mobileNo,
    required String password,
  }) async {
    if (otp.length == 6) {
    final url = Uri.parse('${baseUrl}verify-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'otp': otp,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(mobileNo: mobileNo,partnerName: partnerName,password: password)
        ),
      );
    } else {
      final message = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to register user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    }
  }

  Future<void> resendOTP(context,{
    required String email,
    required String partnerName,
    required String password,
    required String mobileNo,
  }) async {
    final url = Uri.parse('${baseUrl}resend-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Sent')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(mobileNo: mobileNo,partnerName: partnerName,password: password)
        ),
      );
    } else {
      final message = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to register user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> loginUser(
      BuildContext context, {
        required String emailOrMobile,
        required String mobileNo,
        required String partnerName,
        required String password,
      }) async {
    final url = Uri.parse('${baseUrl}login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'emailOrMobile': emailOrMobile,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);
    final userData = responseBody['data']['partner'];
    if (response.statusCode == 200) {
      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      final token = responseBody['data']['token'];
      final partnerName = responseBody['data']['partner']['partnerName'];
      final partnerId = responseBody['data']['partner']['_id'];

      await storeUserData(token, userData);
      print(userData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StepOne(unitType:'',partnerName: partnerName, name: '', partnerId: partnerId,),
        ),
      );
    } else {
      final message = responseBody['message'] ?? 'Login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to login user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> addOperator(
      BuildContext context, {
        required StepThree stepThreeInstance,
        required PlatformFile? istimaraCard,
        required PlatformFile? pictureOfVehicle,
        required PlatformFile? drivingLicense,
        required PlatformFile? nationalID,
        required PlatformFile? aramcoLicense,
        required String partnerName,
        required String unitType,
        required String unitClassification,
        required String subClassification,
        required String plateInformation,
        required String istimaraNo,
        required String firstName,
        required String lastName,
        required String email,
        required String mobileNo,
        required String dateOfBirth,
        required String iqamaNo,
        required String panelInformation,
        required String partnerId,
        required TextEditingController controller,

      }) async {

    // Extract values from the StepThree instance
    var partnerName = stepThreeInstance.partnerName;
    var unitType = stepThreeInstance.unitType;
    var unitClassification = stepThreeInstance.unitClassification;
    var subClassification = stepThreeInstance.subClassification;
    var plateInformation = stepThreeInstance.plateInformation;
    var istimaraNo = stepThreeInstance.istimaraNo;
    var firstName = stepThreeInstance.firstName;
    var lastName = stepThreeInstance.lastName;
    var email = stepThreeInstance.email;
    var mobileNo = stepThreeInstance.mobileNo;
    var dateOfBirth = stepThreeInstance.dateOfBirth;
    var iqamaNo = stepThreeInstance.iqamaNo;
    var panelInformation = stepThreeInstance.panelInformation;

    logRequestData(
      partnerName: partnerName,
      unitType: unitType,
      unitClassification: unitClassification,
      subClassification: subClassification,
      plateInformation: plateInformation,
      istimaraNo: istimaraNo,
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobileNo: mobileNo,
      dateOfBirth: dateOfBirth,
      iqamaNo: iqamaNo,
      panelInformation: panelInformation,
      istimaraCard: istimaraCard,
      aramcoLicense: aramcoLicense,
      drivingLicense: drivingLicense,
      nationalID: nationalID,
      pictureOfVehicle: pictureOfVehicle,
      partnerId:partnerId,
    );
    final url = Uri.parse('${baseUrl}add-operator');

    var request = http.MultipartRequest('POST', url);
    request.fields['partnerName'] = partnerNameController.text;
    request.fields['partnerId'] = partnerId;
    request.fields['unitType'] = unitType;
    request.fields['unitClassification'] = unitClassification;
    request.fields['subClassification'] = subClassification;
    request.fields['plateInformation'] = plateInformation;
    request.fields['istimaraNo'] = istimaraNo;
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['email'] = email;
    request.fields['mobileNo'] = mobileNo;
    request.fields['dateOfBirth'] = dateOfBirth;
    request.fields['iqamaNo'] = iqamaNo;
    request.fields['panelInformation'] = panelInformation;

    // Adding files
    if (istimaraCard != null) {
      request.files.add(await http.MultipartFile.fromPath('istimaraCard', istimaraCard.path.toString()));
    }
    if (pictureOfVehicle != null) {
      request.files.add(await http.MultipartFile.fromPath('pictureOfVehicle', pictureOfVehicle.path.toString()));
    }
    if (drivingLicense != null) {
      request.files.add(await http.MultipartFile.fromPath('drivingLicense', drivingLicense.path.toString()));
    }
    if (nationalID != null) {
      request.files.add(await http.MultipartFile.fromPath('nationalID', nationalID.path.toString()));
    }
    if (aramcoLicense != null) {
      request.files.add(await http.MultipartFile.fromPath('aramcoLicense', aramcoLicense.path.toString()));
    }

    try {

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      var parsedResponse = jsonDecode(responseBody);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 201) {
        globalPartnerId = partnerId;
        print('Upload successful');
        Fluttertoast.showToast(
          msg: 'Operator added Successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetails(partnerId: partnerId,partnerName: partnerName,),
          ),
        );
      } else {
        var parsedResponse = jsonDecode(responseBody);
        var message = parsedResponse['message'] ?? 'Operation failed. Please try again.';

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }



  void logRequestData({
    required String partnerName,
    required String unitType,
    required String unitClassification,
    required String subClassification,
    required String plateInformation,
    required String istimaraNo,
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNo,
    required String dateOfBirth,
    required String iqamaNo,
    required String panelInformation,
    required PlatformFile? istimaraCard,
    required PlatformFile? pictureOfVehicle,
    required PlatformFile? drivingLicense,
    required PlatformFile? nationalID,
    required PlatformFile? aramcoLicense, required String partnerId,
  }) {
    print('Sending data:');
    print('partnerName: $partnerName');
    print('unitType: $unitType');
    print('unitClassification: $unitClassification');
    print('subClassification: $subClassification');
    print('plateInformation: $plateInformation');
    print('istimaraNo: $istimaraNo');
    print('firstName: $firstName');
    print('lastName: $lastName');
    print('email: $email');
    print('mobileNo: $mobileNo');
    print('dateOfBirth: $dateOfBirth');
    print('iqamaNo: $iqamaNo');
    print('istimaraCard: $istimaraCard');
    print('pictureOfVehicle: $pictureOfVehicle');
    print('drivingLicense: $drivingLicense');
    print('nationalID: $nationalID');
    print('aramcoLicense: $aramcoLicense');
    print('partnerId: $partnerId');
  }

  Future<List<int>> streamToBytes(Stream<List<int>> stream) async {
    final completer = Completer<List<int>>();
    final bytes = <int>[];

    stream.listen(
          (data) => bytes.addAll(data),
      onDone: () => completer.complete(bytes),
      onError: completer.completeError,
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<List<Map<String, dynamic>>> fetchVehicleData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/vehicles'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load vehicle data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBusData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/buses'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load bus data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEquipmentData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/equipments'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load equipment data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSpecialData() async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/special-units'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load special data');
    }
  }



  Future<void> getBookingData(String partnerId) async {
    final response = await http.get(Uri.parse('https://naqli.onrender.com/api/partner/$partnerId'));

    if (response.statusCode == 200) {
      print(response.body);
      final responseBody = response.body;

      // Parse the JSON response
      var parsedResponse = jsonDecode(responseBody);

      // Access partnerId
      final partnerId = parsedResponse['_id'];
      print("Partner ID: $partnerId");

      // Access operators list
      final operators = parsedResponse['operators'] as List;

      // Iterate over operators to get booking requests
      for (var operator in operators) {
        final bookingRequests = operator['bookingRequest'] as List;

        for (var booking in bookingRequests) {
          // Access the bookingId
          final bookingId = booking['bookingId'];
          print("Booking ID: $bookingId");
        }
      }
    } else {
      throw Exception('Failed to load booking data');
    }
  }


}

