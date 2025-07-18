import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Model/partner_model.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Views/auth/forgotPassword.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/Partner/Views/auth/otp.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepThree.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_forgotPassword.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://prod.naqlee.com:443/api/partner/';
  String globalPartnerId = '';

  Future<void> registerPartner(context,{
    required String partnerName,
    required String mobileNo,
    required String email,
    required String password,
    required String role,
    required String region,
    required String city,
    required String bankName,
    required String companyName,
    required String ibanCode,
    required String CRNumber,
  }) async {
    try{
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
          'region': region,
          'city': city,
          'bank': bankName,
          'company': companyName,
          'ibanNumber': ibanCode,
          'CRNumber': CRNumber,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final partnerId = responseBody['data']['partner']['_id'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(mobileNo: mobileNo,partnerName: partnerName,password: password, email: email,partnerId: partnerId,),
          ),
        );
      } else {
        final message = responseBody['message'];
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StepOne(partnerName: partnerName, name: '', unitType: '', partnerId: partnerId, token: '', bookingId: '')
            ),
          );
        } else {
          final message = responseBody['message'];
          commonWidgets.showToast(message);
        }
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        final message = responseBody['message'];
        commonWidgets.showToast(message);
      } else {
        final message = responseBody['message'];
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: builder,
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context)=> ForgotPasswordSuccess(),
          ),
        );
      } else {
        final message = responseBody['message'] ?? 'An error occurred,Please try again.. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
        commonWidgets.showToast(message);
      } else {
        final message = responseBody['message'];
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> loginPartner(
      BuildContext context, {
        required String emailOrMobile,
        required String password,
      }) async {
    try{
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
            final message = responseBody['message'];
            commonWidgets.showToast(message);
            await getBookingData(partnerId,token);
            await savePartnerData(partnerId, token, partnerName,email);
          }
        else{
          commonWidgets.showToast('Only "singleUnit + operator" Operator can allowed...');
        }
      } else {
        final message = responseBody['message'] ?? 'Login failed. Please try again.';
        commonWidgets.showToast(message);
        if(message == 'Account not verified! Verify your account')
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(mobileNo: '',partnerName: '',password: password, email: emailOrMobile,partnerId: '',),
            ),
          );
        }
      }
    }on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      if (response.statusCode == 201) {
        globalPartnerId = partnerId;
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
            builder: (context) => LoginPage(),
          ),
        );
      } else {
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
    } on SocketException {
      commonWidgets.showToast('Network error. Please check your connection and try again.');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
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
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']??'Please try again';
        commonWidgets.showToast(message);
        return [];
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBusData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/buses'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']??'Please try again';
        commonWidgets.showToast(message);
        return [];
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchEquipmentData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/equipments'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']??'Please try again';
        commonWidgets.showToast(message);
        return [];
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSpecialData() async {
    try{
      final response = await http.get(Uri.parse('https://prod.naqlee.com:443/api/special-units'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']??'Please try again';
        commonWidgets.showToast(message);
        return [];
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      return [];
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

        final partnerName = partnerData['partnerName'] ?? '';
        final mobileNo = partnerData['mobileNo'] ?? '';
        final email = partnerData['email'] ?? '';
        final region = partnerData['region'] ?? '';
        final city = partnerData['city'] ?? '';
        final bank = partnerData['bank'] ?? '';
        final crNumber = partnerData['CRNumber'] ?? '';
        final company = partnerData['company'] ?? '';
        final ibanNumber = partnerData['ibanNumber'] ?? '';
        final profileFileName = partnerData['partnerProfile']?['fileName'];

        final bookingIds = <Map<String, dynamic>>[];
        final companyDetails = (partnerData['companyDetails'] as List<dynamic>?)?.map((company) {
          return {
            'companyName': company['companyName'] ?? '',
            'legalName': company['legalName'] ?? '',
            'phoneNumber': company['phoneNumber'] ?? '',
            'address': company['address'] ?? '',
            'cityName': company['cityName'] ?? '',
            'zipCode': company['zipCode'] ?? '',
            'companyType': company['companyType'] ?? '',
            'companyIdNo': company['companyIdNo'] ?? '',
          };
        }).toList() ?? [];

        if (partnerData['bookingRequest'] != null && (partnerData['bookingRequest'] as List).isNotEmpty) {
          final bookingRequests = partnerData['bookingRequest'] as List<dynamic>;

          for (var booking in bookingRequests) {
            final bookingId = booking['bookingId']?.toString() ?? 'Unknown ID';
            final quotePrice = booking['quotePrice']?.toString() ?? '';
            final paymentStatus = booking['paymentStatus']?.toString() ?? '';

            bookingIds.add({
              'bookingId': bookingId,
              'paymentStatus': paymentStatus,
              'quotePrice': quotePrice,
              'mobileNo': mobileNo,
              'name': partnerName,
              'email': email,
              'region': region,
              'city': city,
              'bank': bank,
              'crNumber': crNumber,
              'company': company,
              'ibanNumber': ibanNumber,
              'companyDetails': companyDetails,
              'profileImage': profileFileName,
            });
          }
        } else {
          // Add partner details even when bookingRequest is empty
          bookingIds.add({
            'mobileNo': mobileNo,
            'name': partnerName,
            'email': email,
            'region': region,
            'city': city,
            'bank': bank,
            'crNumber': crNumber,
            'company': company,
            'ibanNumber': ibanNumber,
            'companyDetails': companyDetails,
            'bookingRequests': [],
            'profileImage': profileFileName,
          });
        }

        return bookingIds;
      } else {
        return [];
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getBookingId(String bookingId, String token, String paymentStatus, String quotePrice) async {
    try{
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/getBookingsByBookingId/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final Map<String, dynamic> data = responseBody['data'] as Map<String, dynamic>;

        if (data.isEmpty) {
          final responseBody = jsonDecode(response.body);
          final message = responseBody['message']??'Please try again';
          commonWidgets.showToast(message);
        }
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
        return {
          '_id': data['_id'],
          'unitType': data['unitType'],
          'shipmentType': data['shipmentType'],
          'shippingCondition': data['shippingCondition'],
          'cargoLength': data['cargoLength'],
          'cargoBreadth': data['cargoBreadth'],
          'cargoHeight': data['cargoHeight'],
          'cargoUnit': data['cargoUnit'],
          'shipmentWeight': data['shipmentWeight'],
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

      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message']??'Please try again';
        commonWidgets.showToast(message);
        return {};
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, String?>?> getUserName(String userId, String token) async {
    try {
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
          final contactNumber = responseBody['contactNumber'].toString() ?? '';

          String? fullName;
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            fullName = '$firstName $lastName'.trim();
          }

          return {
            'fullName': fullName,
            'contactNumber': contactNumber,
          };
        } else {
          final message = responseBody['message'] ?? 'Please try again';
          commonWidgets.showToast(message);
          return null;
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Please try again';
        commonWidgets.showToast(message);
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return null;
    } catch (e) {
      return null;
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
        commonWidgets.showToast(message);
      } else {
        final message = responseBody['message'] ?? 'Send failed. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['booking'] != null && data['booking']['remainingBalance'] != null) {
          return data['booking']['remainingBalance'].toString();
        } else {
          return null;
        }
      } else {
        return null;
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return null;
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
      return null;
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
        commonWidgets.showToast(message);
      } else {
        commonWidgets.showToast('Something went wrong,Please try again');
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
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
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      }  else {
        commonWidgets.showToast('Something went wrong,Please try again');
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
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
      if (response.statusCode == 201) {
        try {
          final message = jsonDecode(responseBody)['message'];
          commonWidgets.showToast(message);
        } catch (e) {
          commonWidgets.showToast('Something went wrong,Please try again');
        }
      } else {
        commonWidgets.showToast('Error: ${response.statusCode} - $responseBody');
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> updatePartnerProfile(
      String partnerId,
      String token,
      File? profileImage,
      String name,
      String mobileNo,
      String emailAddress,
      String password,
      String confirmPassword,
      String city,
      String company,
      String ibanNumber,
      String region,
      String bank,
      String CRNumber,
      ) async {
    final String url = 'https://prod.naqlee.com:443/api/partner/edit-partner/$partnerId';
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['partnerName'] = name;
      request.fields['email'] = emailAddress;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;
      request.fields['mobileNo'] = mobileNo;
      request.fields['city'] = city;
      request.fields['company'] = company;
      request.fields['ibanNumber'] = ibanNumber;
      request.fields['region'] = region;
      request.fields['bank'] = bank;
      request.fields['CRNumber'] = CRNumber;

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'partnerProfile',
            profileImage.path,
          ),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final message = jsonResponse['message'] as String?;
        if (message != null) {
          commonWidgets.showToast(message);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        commonWidgets.showToast('Something went wrong. Please try again');
      }
    } catch (e) {
      commonWidgets.showToast('Something went wrong. Please try again');
    }
  }

  Future<void> addCompanyDetails(
       BuildContext context,
        String partnerId,
        String company,
        String legalName,
        String phoneNo,
        String altNo,
        String address,
        String city,
        String zipCode,
        String companyType,
        String companyId,
      ) async {
    try{
      final url = Uri.parse('${baseUrl}edit-company-details/$partnerId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "companyName": company,
          "legalName": legalName,
          "phoneNumber": phoneNo,
          "address": address,
          "cityName": city,
          "zipCode": zipCode,
          "companyType": companyType,
          "companyIdNo": companyId
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Send failed. Please try again.';
        commonWidgets.showToast(message);
      } else {
        final message = responseBody['message'] ?? 'Send failed. Please try again.';
        commonWidgets.showToast(message);
      }
    }on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
    }
  }

  Future<List<Operator>> getOperatorData(String partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('https://prod.naqlee.com:443/api/partner/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final partnerData = responseBody['data'];

        if (partnerData['operators'] != null && (partnerData['operators'] as List).isNotEmpty) {
          final operators = partnerData['operators'] as List<dynamic>;

          return operators.map((operator) => Operator.fromJson(operator)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
      return [];
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
      return [];
    }
  }


  Future<void> updateOperatorProfile(
      String partnerId,
      String operatorId,
      String firstName,
      String lastName,
      String emailId,
      String mobileNo,
      String password,
      String confirmPassword,
      String iqamaNo,
      String dateOfBirth,
      String panelInfo,
      String plateInfo,
      File? drivingLicense,
      File? aramcoLicense,
      File? nationalId,
      ) async {
    final String url = 'https://prod.naqlee.com:443/api/partner/edit-operator';
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = emailId;
      request.fields['mobileNo'] = mobileNo;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;
      request.fields['iqamaNo'] = iqamaNo;
      request.fields['dateOfBirth'] = dateOfBirth;
      request.fields['panelInformation'] = panelInfo;
      request.fields['plateInformation'] = plateInfo;
      request.fields['partnerId'] = partnerId;
      request.fields['operatorId'] = operatorId;
      Future<void> addFile(String fieldName, File? file, http.MultipartRequest request) async {
        if (file != null) {
          String? mimeType = lookupMimeType(file.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
              filename: file.path,
            ),
          );
        }
      }
      await addFile('drivingLicense', drivingLicense, request);
      await addFile('aramcoLicense', aramcoLicense, request);
      await addFile('nationalID', nationalId, request);
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final message = jsonResponse['message'] as String?;
        if (message != null) {
          commonWidgets.showToast(message);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final message = jsonResponse['message'] as String?;
        commonWidgets.showToast(message??'');
      }
    } catch (e) {
      commonWidgets.showToast('Something went wrong. Please try again');
    }
  }

  Future<void> deleteOperator(BuildContext context,String operatorId) async {
    try {
      final url = Uri.parse('https://prod.naqlee.com:443/api/partner/delete-operator/$operatorId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      } else {
        commonWidgets.showToast('Something went wrong,Please try again');
      }
    } on SocketException {
      commonWidgets.showToast('Please Check your Internet Connection..');
    } catch (e) {
      commonWidgets.showToast('Something went wrong,Please try again');
    }
  }



}

