import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class SuperUserServices {

  static const String baseUrl = 'https://prod.naqlee.com:443/api/';

  Future<Map<String, dynamic>> getBookingsCount(String userId, String token) async {
    final url = Uri.parse('${baseUrl}bookings/$userId');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        final message = responseBody['message'] as String?;
        if (message != null) {
          CommonWidgets().showToast(message);
        }

        if (responseBody.containsKey('data')) {
          final bookings = responseBody['data'] as List<dynamic>;
          final partnerIds = bookings.map((booking) => booking['partnerId'] as String? ?? '').toSet().toList();
          int totalBookings = bookings.length;
          int runningBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Running').length;
          int yetToStartBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Yet to start').length;
          int completedBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Completed').length;
          int tripCompletedBookingsCount = bookings.where((booking) => booking['tripStatus'] == 'Completed' && booking['remainingBalance'] != 0 && booking['bookingStatus'] == 'Running').length;
          int pendingPaymentCount = bookings.where((booking) => booking['paymentStatus'] == 'NotPaid').length;
          int halfPaidPaymentCount = bookings.where((booking) => booking['tripStatus'] != 'Completed' && booking['bookingStatus'] == 'Running' && booking['paymentStatus'] == 'HalfPaid' && booking['remainingBalance'] != 0).length;
          int completedPaymentCount = bookings.where((booking) => booking['paymentStatus'] == 'Completed').length;
          int paidPaymentCount = bookings.where((booking) => booking['paymentStatus'] == 'Paid').length;

          List<String> bookingDates = bookings
              .where((booking) => (booking['paymentStatus'] == 'Paid' || booking['paymentStatus'] == 'Completed') && booking['bookingStatus'] == 'Completed')
              .map((booking) => booking['createdAt'] as String)
              .toList();

          List<String> pendingBookingDates = bookings
              .where((booking) => booking['paymentStatus'] == 'NotPaid' || booking['bookingStatus'] == 'Yet to start')
              .map((booking) => booking['createdAt'] as String)
              .toList();

          List<dynamic> notPaidBookings = bookings
              .where((booking) => booking['paymentStatus'] == 'NotPaid').toList();

          List<String> paymentStatus = bookings
              .map((booking) => booking['paymentStatus'] as String)
              .toList();

          return {
            'bookings': bookings.map((booking) => Map<String, dynamic>.from(booking)).toList(),
            'totalBookings': totalBookings,
            'runningBookingsCount': runningBookingsCount,
            'yetToStartBookingsCount': yetToStartBookingsCount,
            'completedBookings': completedBookingsCount,
            'pendingPaymentCount': pendingPaymentCount,
            'halfPaidPaymentCount': halfPaidPaymentCount,
            'completedPaymentCount': completedPaymentCount,
            'tripCompletedBookingsCount': tripCompletedBookingsCount,
            'paidPaymentCount': paidPaymentCount,
            'bookingDates': bookingDates,
            'pendingBookingDates': pendingBookingDates,
            'notPaidBookings': notPaidBookings,
            'paymentStatus': paymentStatus,
            'partnerIds': partnerIds,
          };
        } else {
          return {
            'totalBookings': 0,
            'runningBookingsCount': 0,
            'yetToStartBookingsCount': 0,
            'completedBookings': 0,
            'pendingPaymentCount': 0,
            'halfPaidPaymentCount': 0,
            'bookingDates': [],
          };
        }
      } else {
        return {
          'totalBookings': 0,
          'runningBookingsCount': 0,
          'yetToStartBookingsCount': 0,
          'completedBookings': 0,
          'pendingPaymentCount': 0,
          'halfPaidPaymentCount': 0,
          'bookingDates': [],
        };
      }
    } on SocketException {
      CommonWidgets().showToast('Please Check your Internet Connection..');
      return {
        'totalBookings': 0,
        'runningBookingsCount': 0,
        'yetToStartBookingsCount': 0,
        'completedBookings': 0,
        'pendingPaymentCount': 0,
        'halfPaidPaymentCount': 0,
        'bookingDates': [],
      };
    } catch (e) {
      return {
        'totalBookings': 0,
        'runningBookingsCount': 0,
        'yetToStartBookingsCount': 0,
        'completedBookings': 0,
        'pendingPaymentCount': 0,
        'halfPaidPaymentCount': 0,
        'bookingDates': [],
      };
    }
  }

  Future<Map<String, Map<String, String>>> getPartnerDetails(List<String> partnerIds, String token) async {
    Map<String, Map<String, String>> partnerIdToDataMap = {};

    for (String partnerId in partnerIds) {
      try {
        final response = await http.get(
          Uri.parse('${baseUrl}partner/$partnerId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final partnerName = responseBody['data']?['partnerName'] ?? 'N/A';
          final mobileNo = responseBody['data']?['mobileNo'] ?? 'N/A';

          partnerIdToDataMap[partnerId] = {
            'partnerName': partnerName,
            'mobileNo': mobileNo,
          };
        } else {
          partnerIdToDataMap[partnerId] = {
            'partnerName': 'N/A',
            'mobileNo': 'N/A',
          };
        }
      } catch (e) {
        partnerIdToDataMap[partnerId] = {
          'partnerName': 'N/A',
          'mobileNo': 'N/A',
        };
      }
    }

    return partnerIdToDataMap;
  }


  Future<Map<String, String>> getPartnerNames(List<String> partnerIds, String token) async {
    Map<String, String> partnerIdToNameMap = {};

    for (String partnerId in partnerIds) {
      try {
        final response = await http.get(
          Uri.parse('${baseUrl}partner/$partnerId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final partnerName = responseBody['data']?['partnerName'] ?? 'N/A';
          final mobileNo= responseBody['data']?['mobileNo'] ?? 'N/A';
          partnerIdToNameMap[partnerId] = partnerName;
        } else {
          partnerIdToNameMap[partnerId] = 'N/A';
        }
      } catch (e) {
        partnerIdToNameMap[partnerId] = 'N/A';
      }
    }

    return partnerIdToNameMap;
  }


  Future<void> updateBooking(String token,String bookingId,String date,String pickup,List dropPoints,int additionalLabour) async {

    final String url = '${baseUrl}edit-booking/$bookingId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'date': date,
          'pickup': pickup,
          'dropPoints': dropPoints,
          'additionalLabour': additionalLabour,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] as String?;
        if (message != null) {
          CommonWidgets().showToast(message);
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] as String?;
        if (message != null) {
          CommonWidgets().showToast(message);
        }
      }
    } catch (e) {
      CommonWidgets().showToast('An error occurred,Please try again.');
    }
  }

  Future<Map<String, String>?> choosePayment(
      BuildContext context, {
        required String userId,
        required String paymentBrand,
        required num amount,
      }) async {
    try {
      final url = Uri.parse('${baseUrl}create-payment');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'paymentBrand': paymentBrand,
          'amount': amount,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final checkOutId = responseBody['id'];
        final integrityId = responseBody['integrity'];

        if (checkOutId != null && integrityId != null) {
          return {
            'id': checkOutId,
            'integrity': integrityId,
          };
        }
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('Please Check your Internet Connection..');
      return null;
    } catch (e) {
      CommonWidgets().showToast('An error occurred,Please try again.');
      return null;
    }
  }

  Future<Map<String, String>?> getPaymentDetails(BuildContext context, String checkOutId, bool paymentType) async {
    try {
      String paymentBrand = paymentType ? 'MADA' : 'OTHER';
      final response = await http.get(
        Uri.parse('$baseUrl/payment-status/$checkOutId').replace(
          queryParameters: {
            'paymentBrand': paymentBrand,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String resultCode = responseBody['result']['code'] ?? 'Unknown';
        String description = responseBody['result']['description'] ?? 'Unknown';

        return {
          'code': resultCode,
          'description': description,
        };
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        commonWidgets.showToast(message);
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('Please Check your Internet Connection..');
      return null;
    } catch (e) {
      CommonWidgets().showToast('An error occurred,Please try again.');
      return null;
    }
  }


  Future<void> editProfile(
      String token,
      String userId,
      String firstName,
      String lastName,
      String emailAddress,
      String password,
      String confirmPassword,
      String contactNumber,
      String alternateNumber,
      String address1,
      String address2,
      String city,
      String govtId,
      String idNumber) async {

    final String url = '${baseUrl}edit-booking/$userId';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'emailAddress': emailAddress,
          'password': password,
          'confirmPassword': confirmPassword,
          'contactNumber': contactNumber,
          'alternateNumber': alternateNumber,
          'address1': address1,
          'address2': address2,
          'city': city,
          'govtId': govtId,
          'idNumber': idNumber,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] as String?;
        if (message != null) {
          CommonWidgets().showToast(message);
        }
      } else {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] as String?;
        if (message != null) {
          CommonWidgets().showToast(message);
        }
      }
    } catch (e) {
      CommonWidgets().showToast('An error occurred,Please try again.');
    }
  }


}