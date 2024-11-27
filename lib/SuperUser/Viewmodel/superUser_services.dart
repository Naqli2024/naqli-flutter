import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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
        print('Response body: $responseBody');

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
          print('No data key found in the response');
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
        print('Failed to load bookings: ${response.body}');
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
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet connection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
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
        print('Error fetching data for $partnerId: $e');
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
        print('Error fetching partner name for $partnerId: $e');
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
        print('Failed to update booking. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<Map<String, String>?> choosePayment(
      BuildContext context, {
        required String paymentBrand,
        required int amount,
      }) async {
    try {
      final url = Uri.parse('${baseUrl}create-payment');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'paymentBrand': paymentBrand,
          'amount': amount,
        }),
      );

      final responseBody = jsonDecode(response.body);
      print('Full Response Body: $responseBody');

      if (response.statusCode == 200) {
        final checkOutId = responseBody['id'];
        final integrityId = responseBody['integrity'];
        final message = responseBody['message'] ?? 'Payment processed successfully.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        if (checkOutId != null && integrityId != null) {
          return {
            'id': checkOutId,
            'integrity': integrityId,
          };
        }
      } else {
        final message = responseBody['message'] ?? 'Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } on SocketException {
      CommonWidgets().showToast('No Internet connection');
      throw Exception('Please check your internet \nconnection and try again.');
    } catch (e) {
      print('An error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, String>?> getPaymentDetails(BuildContext context, String checkOutId) async {
      try {
        final response = await http.get(
          Uri.parse('${baseUrl}payment-status/$checkOutId'),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        final responseBody = jsonDecode(response.body);
        print('Payment Response Body: $responseBody');
        if (response.statusCode == 200) {
          final message = responseBody['message'] ?? 'Payment processed successfully.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }  else {
          final message = responseBody['message'] ?? 'Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          print('Failed to create booking: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return null;
      }on SocketException {
        CommonWidgets().showToast('No Internet connection');
        throw Exception('Please check your internet \nconnection and try again.');
      } catch (e) {
        print('An error occurred: $e');
        throw Exception('An unexpected error occurred: $e');
      }
  }

}