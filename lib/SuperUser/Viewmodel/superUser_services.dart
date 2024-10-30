import 'dart:convert';
import 'dart:io';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:http/http.dart' as http;

class SuperUserServices {

  static const String baseUrl = 'https://naqli.onrender.com/api/';

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

          int totalBookings = bookings.length;
          int runningBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Running').length;
          int yetToStartBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Yet to start').length;
          int completedBookingsCount = bookings.where((booking) => booking['bookingStatus'] == 'Completed').length;
          int pendingPaymentCount = bookings.where((booking) => booking['paymentStatus'] == 'NotPaid').length;
          int halfPaidPaymentCount = bookings.where((booking) => booking['paymentStatus'] == 'HalfPaid').length;

          List<String> bookingDates = bookings
              .where((booking) => booking['bookingStatus'] == 'Completed')
              .map((booking) => booking['date'] as String)
              .toList();

          List<String> pendingBookingDates = bookings
              .where((booking) => booking['paymentStatus'] == 'NotPaid')
              .map((booking) => booking['date'] as String)
              .toList();

          List<dynamic> notPaidBookings = bookings
              .where((booking) => booking['paymentStatus'] == 'NotPaid').toList();

          return {
            'totalBookings': totalBookings,
            'runningBookingsCount': runningBookingsCount,
            'yetToStartBookingsCount': yetToStartBookingsCount,
            'completedBookings': completedBookingsCount,
            'pendingPaymentCount': pendingPaymentCount,
            'halfPaidPaymentCount': halfPaidPaymentCount,
            'bookingDates': bookingDates,
            'pendingBookingDates': pendingBookingDates,
            'notPaidBookings': notPaidBookings,
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


}