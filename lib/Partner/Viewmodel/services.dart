import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/Partner/Views/auth/otp.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://naqli.onrender.com/api/partner/';
  String globalPartnerId = '';

  Future<void> registerUser(context,{
    required String partnerName,
    required String mobileNo,
    required String email,
    required String password,
    required String role,
    required String partnerId,
    required String token,
  }) async {
    final url = Uri.parse('${baseUrl}register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
      final partnerId = responseBody['data']['partner']['_id'];
      print('Success');
      print(partnerId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(mobileNo: mobileNo,partnerName: partnerName,password: password, email: email,partnerId: partnerId,),
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
    required String partnerId,
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
          builder: (context) => StepOne(partnerName: partnerName, name: '', unitType: '', partnerId: partnerId, token: '', bookingId: '')
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
    required String partnerId,
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
            builder: (context) => StepOne(partnerName: partnerName, name: '', unitType: '', partnerId: partnerId, token: '', bookingId: '')
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

  Future<void> forgotPassword(
      BuildContext context,
      WidgetBuilder builder, {
        required String email,
      }) async {
    final url = Uri.parse('${baseUrl}forgot-password');

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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: builder,
        ),
      );
    } else {
      final message = responseBody['message'] ?? 'An unexpected error occurred. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to send OTP: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> forgotPasswordReset(
      BuildContext context, {
        required String otp,
        required String newPassword,
        required String confirmNewPassword,
      }) async {
    final url = Uri.parse('${baseUrl}verify-otp-update-password');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'otp': otp,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      }),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print('Success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context)=> LoginPage(partnerName: '', mobileNo: '', password: '', token: '', partnerId: ''),
        ),
      );
    } else {
      final message = responseBody['message'] ?? 'An unexpected error occurred. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to Reset Pwd: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> forgotPasswordResendOTP(context,{
    required String email,
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
      Fluttertoast.showToast(
        msg: 'OTP Send Successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
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
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'emailOrMobile': emailOrMobile,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);
    final userData = responseBody['data'];
    if (response.statusCode == 200) {
      print('Login successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      final token = responseBody['data']['token'];
      final partnerName = responseBody['data']['partner']['partnerName'];
      final partnerId = responseBody['data']['partner']['_id'];

      await getBookingData(partnerId,token);
      print(userData);
      print(token);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingDetails(partnerName: partnerName, partnerId: partnerId, token: token, quotePrice: '', paymentStatus: '',)
        ),
      );
      await savePartnerData(partnerId, token, partnerName);
      print('ID$partnerId');
      print('NAME$partnerName');
      print('TOKEN$token');
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
        required String token,
        required TextEditingController controller,

      }) async {

    // Extract values from the StepThree instance
    var partnerName = stepThreeInstance.partnerName;
    var partnerId= stepThreeInstance.partnerId;
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
      token: token
    );
    final url = Uri.parse('${baseUrl}add-operator');

    var request = http.MultipartRequest('POST', url);
    request.fields['partnerName'] = controller.text;
    request.fields['partnerId'] = partnerId;
    request.fields['token'] = token;
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



      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      var parsedResponse = jsonDecode(responseBody);
      // final partnerIdd = parsedResponse['data']['partner']['_id'];
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');
      print('partnerId');
      // print(partnerIdd);
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
            builder: (context) => LoginPage(partnerName: partnerName, mobileNo: mobileNo, password: '',token: token,partnerId: partnerId,),
          ),
        );
      } else {
        var parsedResponse = jsonDecode(responseBody);
        var message = parsedResponse['message'] ?? 'Operation failed. Please try again.';
        print('Failed to login user: ${response.statusCode}');
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
    required PlatformFile? aramcoLicense,
    required String partnerId,
    required String token,
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
    print('token: $token');
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


  Future<List<Map<String, dynamic>>> getBookingData(String partnerId, String token) async {
    final response = await http.get(
      Uri.parse('https://naqli.onrender.com/api/partner/$partnerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final partnerData = responseBody['data'];


      if (partnerData['operators'] != null) {
        final operators = partnerData['operators'] as List<dynamic>;
        final bookingIds = <Map<String, dynamic>>[];

        for (var operator in operators) {
          if (operator['bookingRequest'] != null) {
            final bookingRequests = operator['bookingRequest'] as List<dynamic>;

            for (var booking in bookingRequests) {
              final bookingId = booking['bookingId']?.toString() ?? 'Unknown ID';
              final quotePrice = booking['quotePrice']?.toString() ?? '0';
              final paymentStatus = booking['paymentStatus']?.toString() ?? '';
              print(bookingId);
              print(paymentStatus);
              print(quotePrice);
              print(token);
              await getBookingId(bookingId, token, paymentStatus,quotePrice);
              bookingIds.add({
                'bookingId': bookingId,
                'paymentStatus': paymentStatus,
                'quotePrice': quotePrice,
              });
            }
          }
        }

        print('ID$partnerId');
        print('NAMEs$partnerData');
        print('TOKEN$token');
        return bookingIds;
      } else {
        print("No operators found for this partner.");
        return [];
      }
    } else if (response.statusCode == 401) {
      print("Authorization failed: ${response.body}");
      return [];
    } else {
      print('Failed to load booking data: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load booking data');
    }
  }

  Future<Map<String, dynamic>> getBookingId(String bookingId, String token, String paymentStatus, String quotePrice) async {
    final response = await http.get(
      Uri.parse('https://naqli.onrender.com/api/getBookingsByBookingId/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Ensure 'data' is a map
      final Map<String, dynamic> data = responseBody['data'] as Map<String, dynamic>;

      if (data.isEmpty) {
        throw Exception('No data found for booking ID $bookingId');
      }

      final partnerId = data['_id'] ?? '';


      print(responseBody);

      // Access the 'type' list
      final List<dynamic> typeList = data['type'] as List<dynamic>;
      // Access the 'dropPoints' list
      final List<dynamic> dropPoints = data['dropPoints'] as List<dynamic>? ?? [];

      // Safely extract typeOfLoad from the first item
      String typeOfLoad = 'No load available';
      String typeName = '';
      // Safely access the first item in 'dropPoints'
      String firstDropPoint = 'No drop point available';

      if (dropPoints.isNotEmpty) {
        firstDropPoint = dropPoints[0] as String? ?? 'No drop point available';
      }
      if (typeList.isNotEmpty) {
        final typeItem = typeList[0] as Map<String, dynamic>;
        typeOfLoad = typeItem['typeOfLoad'] ?? 'No load available';
        typeName = typeItem['typeName'] ?? 'No name available';
      }

      final userId = data['user'] ?? '';
      await getUserName(userId, token);

      print('userId: $userId');
      print('paymentStatus: $paymentStatus');
      print('quotePrice: $quotePrice');
      print('token: $token');

      return {
        '_id': data['_id'],
        'date': data['date'],
        'time': data['time'],
        'productValue': data['productValue'],
        'additionalLabour': data['additionalLabour'],
        'pickup': data['pickup'],
        'name': data['name'],
        'typeName': typeName,
        'dropPoints': firstDropPoint,
        'typeOfLoad': typeOfLoad,
        'quotePrice': quotePrice,
        'paymentStatus': paymentStatus,
        'userId': userId,
        'bookingStatus': data['bookingStatus'],
        'remainingBalance': data['remainingBalance'],
        'paymentAmount': data['paymentAmount'],
      };

    } else if (response.statusCode == 401) {
      print("Authorization failed for booking ID $bookingId: ${response.body}");
      throw Exception('Authorization failed');
    } else {
      throw Exception('Failed to load booking data for booking ID $bookingId');
    }
  }

  Future<String?> getUserName(String userId, String token) async {
    final response = await http.get(
      Uri.parse('https://naqli.onrender.com/api/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Check if 'data' exists and contains 'firstName' and 'lastName'
      if (responseBody != null) {
        final firstName = responseBody['firstName'] ?? '';
        final lastName = responseBody['lastName'] ?? '';

        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          print('token: $token');
          print('User name: $firstName $lastName');
          return '$firstName $lastName';
        } else {
          print("First name or last name is not available.");
          return null;
        }
      } else {
        print("Response body does not contain user data.");
        return null;
      }
    } else if (response.statusCode == 401) {
      print("Authorization failed for user ID $userId: ${response.body}");
      throw Exception('Authorization failed');
    } else {
      print('Failed to load user data: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load user data for user ID $userId');
    }
  }

  Future<void> sendQuotePrice(
      BuildContext context, {
        required String quotePrice,
        required String partnerId,
        required String bookingId,
        required String token,
      }) async {
    final url = Uri.parse('${baseUrl}update-quote');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'quotePrice': quotePrice,
        'partnerId': partnerId,
        'bookingId': bookingId,
      }),
    );

    final responseBody = jsonDecode(response.body);
    // final userData = responseBody['data'];
    if (response.statusCode == 200) {
      await requestPayment(context, additionalCharges: 0, reason: '', bookingId: bookingId, token: token);
      print('Send Quote Price successful');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Send successful')),
      );

      print('token: $token');
    } else {
      final message = responseBody['message'] ?? 'Send failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Failed to Send price: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<String?> requestPayment(
      BuildContext context, {
        required int additionalCharges,
        required String reason,
        required String bookingId,
        required String token,
      }) async {
    final url = Uri.parse('https://naqli.onrender.com/api/bookings/$bookingId/additional-charges');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'additionalCharges': additionalCharges,
          'reason': reason,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data'); // Print response data for debugging

        // Check if the response contains the booking object and remainingBalance
        if (data['booking'] != null && data['booking']['remainingBalance'] != null) {
          return data['booking']['remainingBalance'].toString();
        } else {
          print('Remaining balance not found in response');
          return null;
        }
      } else {
        print('Failed to update payment, status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error making payment request: $e');
      return null;
    }
  }


  Future<void> deleteBookingRequest(BuildContext context,String partnerId, String bookingRequestId, String token) async {
    final url = Uri.parse('${baseUrl}$partnerId/booking-request/$bookingRequestId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // final userData = responseBody['data'];
      // await storeUserData(token, userData);
      print("Booking request deleted successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingDetails(partnerName: '', partnerId: partnerId, token: token, quotePrice: '', paymentStatus: '',)
        ),
      );
    } else if (response.statusCode == 401) {
      print("Authorization failed: ${response.body}");
      throw Exception('Authorization failed');
    } else {
      print("Failed to delete booking request: ${response.body}");
      throw Exception('Failed to delete booking request');
    }
  }


}

