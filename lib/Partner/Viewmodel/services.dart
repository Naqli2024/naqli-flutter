import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/auth/forgotPassword.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/Partner/Views/auth/otp.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AuthService {
  static const String baseUrl = 'https://prod.naqlee.com:443/api/partner/';
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
    try{
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
        Navigator.pushReplacement(
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
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
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
    try{
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
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> resendOTP(context,{
    required String email,
    required String partnerName,
    required String password,
    required String mobileNo,
    required String partnerId,
  }) async {
    try{
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
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to register user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> forgotPassword(
      BuildContext context,
      WidgetBuilder builder, {
        required String email,
      }) async {
    try{
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
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> forgotPasswordReset(
      BuildContext context, {
        required String otp,
        required String newPassword,
        required String confirmNewPassword,
      }) async {
    try{
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
            builder: (context)=> ForgotPasswordSuccess(),
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
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

  Future<void> forgotPasswordResendOTP(context,{
    required String email,
  }) async {
    try{
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
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Success');
      } else {
        final message = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to register user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
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
    try{
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
        final token = responseBody['data']['token'];
        final partnerName = responseBody['data']['partner']['partnerName'];
        final partnerId = responseBody['data']['partner']['_id'];
        final type = responseBody['data']['partner']['type'];
        final email = responseBody['data']['partner']['email'];

        if(type == 'singleUnit + operator')
          {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => BookingDetails(partnerName: partnerName, partnerId: partnerId, token: token, quotePrice: '', paymentStatus: '',email: email,)
              ),
            );
            print('Login successful');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful')),
            );
            await getBookingData(partnerId,token);
            print(userData);
            print(token);
            await savePartnerData(partnerId, token, partnerName,email);
          }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Only "singleUnit + operator" Operator can allowed...')),
          );
        }
      } else {
        final message = responseBody['message'] ?? 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to login user: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
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
        required String password,
        required String confirmPassword,
        required String mobileNo,
        required DateTime dateOfBirth,
        required String iqamaNo,
        required String panelInformation,
        required String partnerId,
        required String token,
        required TextEditingController controller,
      }) async {
    try {
      var partnerName = stepThreeInstance.partnerName;
      var partnerId = stepThreeInstance.partnerId;
      var unitType = stepThreeInstance.unitType;
      var unitClassification = stepThreeInstance.unitClassification;
      var subClassification = stepThreeInstance.subClassification;
      var plateInformation = stepThreeInstance.plateInformation;
      var istimaraNo = stepThreeInstance.istimaraNo;
      var firstName = stepThreeInstance.firstName;
      var lastName = stepThreeInstance.lastName;
      var email = stepThreeInstance.email;
      var password = stepThreeInstance.password;
      var confirmPassword = stepThreeInstance.confirmPassword;
      var mobileNo = stepThreeInstance.mobileNo;
      var dateOfBirth = stepThreeInstance.dateOfBirth;
      var iqamaNo = stepThreeInstance.iqamaNo;
      var panelInformation = stepThreeInstance.panelInformation;

      logRequestData(
        partnerName: controller.text,
        unitType: unitType,
        unitClassification: unitClassification,
        subClassification: subClassification,
        plateInformation: plateInformation,
        istimaraNo: istimaraNo,
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobileNo: mobileNo,
        dateOfBirth: dateOfBirth.toIso8601String(),
        iqamaNo: iqamaNo,
        panelInformation: panelInformation,
        istimaraCard: istimaraCard,
        aramcoLicense: aramcoLicense,
        drivingLicense: drivingLicense,
        nationalID: nationalID,
        pictureOfVehicle: pictureOfVehicle,
        partnerId: partnerId,
        password: password,
        confirmPassword: confirmPassword
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
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;
      request.fields['mobileNo'] = mobileNo;
      request.fields['dateOfBirth'] = dateOfBirth.toIso8601String();
      request.fields['iqamaNo'] = iqamaNo;
      request.fields['panelInformation'] = panelInformation;

      // Adding files
      if (istimaraCard != null && istimaraCard.path != null) {
        request.files.add(await http.MultipartFile.fromPath('istimaraCard', istimaraCard.path.toString()));
      }
      if (pictureOfVehicle != null && pictureOfVehicle.path != null) {
        request.files.add(await http.MultipartFile.fromPath('pictureOfVehicle', pictureOfVehicle.path.toString()));
      }
      if (drivingLicense != null && drivingLicense.path != null) {
        request.files.add(await http.MultipartFile.fromPath('drivingLicense', drivingLicense.path.toString()));
      }
      if (nationalID != null && nationalID.path != null) {
        request.files.add(await http.MultipartFile.fromPath('nationalID', nationalID.path.toString()));
      }
      if (aramcoLicense != null && aramcoLicense.path != null) {
        request.files.add(await http.MultipartFile.fromPath('aramcoLicense', aramcoLicense.path.toString()));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      var parsedResponse = jsonDecode(responseBody);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');
      print('partnerId');
      if (response.statusCode == 201) {
        globalPartnerId = partnerId;
        print('Upload successful');
        Fluttertoast.showToast(
          msg: 'Operator added Successfully'.tr(),
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
            builder: (context) => LoginPage(partnerName: partnerName, mobileNo: mobileNo, password: '', token: token, partnerId: partnerId),
          ),
        );
      } else {
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
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
      print('Network error: No Internet connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
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
    required String password,
    required String confirmPassword,
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
    print('password:: $password');
    print('confirmPassword: $confirmPassword');
    print('mobileNo: $mobileNo');
    print('dateOfBirth: $dateOfBirth');
    print('iqamaNo: $iqamaNo');
    print('panelInformation: $panelInformation');
    print('istimaraCard: ${istimaraCard?.path ?? 'No file'}');
    print('pictureOfVehicle: ${pictureOfVehicle?.path ?? 'No file'}');
    print('drivingLicense: ${drivingLicense?.path ?? 'No file'}');
    print('nationalID: ${nationalID?.path ?? 'No file'}');
    print('aramcoLicense: ${aramcoLicense?.path ?? 'No file'}');
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
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/vehicles'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load vehicle data');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBusData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/buses'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load bus data');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEquipmentData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/equipments'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load equipment data');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSpecialData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/special-units'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load special data');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }


  Future<List<Map<String, dynamic>>> getBookingData(String partnerId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/partner/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final partnerData = responseBody['data'];
       print('dataaa$partnerData');
        if (partnerData['bookingRequest'] != null) {
          final bookingRequests = partnerData['bookingRequest'] as List<dynamic>;
          final bookingIds = <Map<String, dynamic>>[];

          for (var booking in bookingRequests) {
            final bookingId = booking['bookingId']?.toString() ?? 'Unknown ID';

            final quotePrice = booking['quotePrice'] is int
                ? booking['quotePrice'].toString()
                : booking['quotePrice'].toString();

            final paymentStatus = booking['paymentStatus']?.toString() ?? '';

            print('Booking ID: $bookingId');
            print('Payment Status: $paymentStatus');
            print('Quote Price: $quotePrice');

            bookingIds.add({
              'bookingId': bookingId,
              'paymentStatus': paymentStatus,
              'quotePrice': quotePrice,
            });
          }
          return bookingIds;
        } else {
          print("No booking requests found for this partner.");
          return [];
        }
      } else if (response.statusCode == 401) {
        print("Authorization failed: ${response.body}");
        return [];
      } else {
        print('Failed to load booking data: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load booking data');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> getBookingId(String bookingId, String token, String paymentStatus, String quotePrice) async {
    try{
      print('object$paymentStatus');
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/getBookingsByBookingId/$bookingId'),
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

        final List<dynamic> typeList = data['type'] as List<dynamic>;
        final List<dynamic> dropPoints = data['dropPoints'] as List<dynamic>? ?? [];
        String typeOfLoad = 'N/A';
        String typeName = '';
        String firstDropPoint = 'No drop point available';

        if (dropPoints.isNotEmpty) {
          firstDropPoint = dropPoints[0] as String? ?? 'No drop point available';
        }
        if (typeList.isNotEmpty) {
          final typeItem = typeList[0] as Map<String, dynamic>;
          typeOfLoad = typeItem['typeOfLoad'] ?? 'N/A';
          typeName = typeItem['typeName'] ?? 'N/A';
        }
        final bookingStatus = data['bookingStatus'] ?? 'Unknown';
        final userId = data['user'] ?? '';
        await getUserName(userId, token);

        print('userId: $userId');
        print('paymentStatus: $paymentStatus');
        print('quotePrice: $quotePrice');
        print('token: $token');
        print('bookingStatus: $bookingStatus');

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
          'paymentStatus': data['paymentStatus'],
          'userId': userId,
          'bookingStatus': bookingStatus,
          'remainingBalance': data['remainingBalance'],
          'paymentAmount': data['paymentAmount'],
           'cityName' : data['cityName'],
           'address' : data['address'],
           'zipCode' : data['zipCode'],
           'fromTime' : data['fromTime'],
           'toTime' : data['toTime'],
        };

      } else if (response.statusCode == 401) {
        print("Authorization failed for booking ID $bookingId: ${response.body}");
        throw Exception('Authorization failed');
      } else {
        throw Exception('Failed to load booking data for booking ID $bookingId');
      }
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> getUserName(String userId, String token) async {
    try{
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
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
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> sendQuotePrice(
      BuildContext context, {
        required String quotePrice,
        required String partnerId,
        required String bookingId,
        required String token,
      }) async {
    try{
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
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Send failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
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
    }on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<String?> requestPayment(
      BuildContext context, {
        required int additionalCharges,
        required String reason,
        required String bookingId,
        required String token,
      }) async {
    try {
    final url = Uri.parse('https://prod.naqlee.com:443/api/bookings/$bookingId/additional-charges');

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
        print('Response Data: $data');

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
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }


  Future<void> deleteBookingRequest(BuildContext context,String partnerId, String bookingRequestId, String token) async {
    try {
      final url = Uri.parse(
          '${baseUrl}$partnerId/booking-request/$bookingRequestId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if (response.statusCode == 401) {
        print("Authorization failed: ${response.body}");
        throw Exception('Authorization failed');
      } else {
        print("Failed to delete booking request: ${response.body}");
        throw Exception('Failed to delete booking request');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> terminateBooking(BuildContext context,String partnerId, String bookingId, String token,String email) async {
    try {
      final url = Uri.parse('${baseUrl}$partnerId/booking-request/$bookingId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("Booking request deleted successfully.");
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if (response.statusCode == 401) {
        print("Authorization failed: ${response.body}");
        throw Exception('Authorization failed');
      } else {
        print("Failed to delete booking request: ${response.body}");
        throw Exception('Failed to delete booking request');
      }
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> submitTicket(BuildContext context, {
    required String reportMessage,
    required String email,
    required File? pictureOfTheReport,
  }) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com:443/api/report/add-report');

      var request = http.MultipartRequest('POST', url);
      request.fields['email'] = email;
      request.fields['reportMessage'] = reportMessage;

      if (pictureOfTheReport != null) {
        var fileName = basename(pictureOfTheReport.path);
        var fileBytes = await pictureOfTheReport.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'pictureOfTheReport',
            fileBytes,
            filename: fileName,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      if (response.statusCode == 201) {
        try {
          final message = jsonDecode(responseBody)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          print('Success: $message');
        } catch (e) {
          print('Error parsing JSON: $e');
          print('Received body: $responseBody');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - $responseBody')),
        );
        print('Failed to submit ticket: ${response.statusCode}');
        print('Response body: $responseBody');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please check your connection and try again.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
      print('Error: $e');
    }
  }

}

