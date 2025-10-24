import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:shared_preferences/shared_preferences.dart';

String buildBookingData({
  required String selectedType,
  required String selectedName,
  required String selectedTypeName,
  required String selectedLoad,
  required String selectedLabour,
  required String formattedDate,
  required String formattedTime,
  required String formattedToTime,
  required List<String> dropPlaces,
  required String pickup,
  required String productValue,
  required String cityName,
  required String address,
  required String zipCode,
  required String scale,
  required String typeImage,
}) {
  final Map<String, dynamic> bookingData = {
    'selectedType': selectedType,
    'selectedName': selectedName,
    'selectedTypeName': selectedTypeName,
    'selectedLoad': selectedLoad,
    'selectedLabour': selectedLabour,
    'date': formattedDate,
    'fromTime': formattedTime,
    'toTime': formattedToTime,
    'pickup': pickup,
    'dropPoints': dropPlaces,
    'productValue': productValue,
    'cityName': cityName,
    'address': address,
    'zipCode': zipCode,
    'scale': scale,
    'typeImage': typeImage,
  };
  return jsonEncode(bookingData);
}

Future<void> restoreBookingDataAfterLogin({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String token,
  required String id,
  required String email,
  required String accountType,
}) async {
  try {
    // Step 1: Check if any saved booking data exists
    final data = await getSavedLocalBookingDataWithoutLogin();
    final savedData = data['bookingData'];

    // Step 2: If no data → go to UserType page directly
    if (savedData == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UserType(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: id,
            email: email,
            accountType: accountType,
          ),
        ),
      );
      return;
    }

    // Step 3: If data exists → decode and create booking
    final booking = jsonDecode(savedData);
    final selectedType = booking['selectedType'] ?? '';
    final UserService userService = UserService();

    String? bookingId;

    switch (selectedType) {
      case 'vehicle':
        bookingId = await userService.userVehicleCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          typeName: booking['selectedTypeName'] ?? '',
          scale: booking['scale'] ?? '',
          typeImage: booking['typeImage'] ?? '',
          typeOfLoad: booking['selectedLoad'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;

      case 'bus':
        bookingId = await userService.userBusCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          image: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;

      case 'equipment':
        bookingId = await userService.userEquipmentCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          typeName: booking['selectedTypeName'] ?? '',
          typeImage: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          fromTime: booking['fromTime'] ?? '',
          toTime: booking['toTime'] ?? '',
          cityName: booking['cityName'] ?? '',
          address: booking['address'] ?? '',
          zipCode: booking['zipCode'] ?? '',
          token: token,
        );
        break;

      case 'special':
        bookingId = await userService.userSpecialCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          image: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          fromTime: booking['fromTime'] ?? '',
          toTime: booking['toTime'] ?? '',
          cityName: booking['cityName'] ?? '',
          address: booking['address'] ?? '',
          zipCode: booking['zipCode'] ?? '',
          token: token,
        );
        break;

      case 'shared-cargo':
        bookingId = await userService.userSharedCargoCreateBooking(
          context,
          name: '',
          unitType: selectedType,
          shipmentType: booking['selectedShipmentType'] ?? '',
          shippingCondition: booking['selectedShipmentCondition'] ?? '',
          cargoLength: booking['cargoLength'] ?? '',
          cargoBreadth: booking['cargoBreadth'] ?? '',
          cargoHeight: booking['cargoHeight'] ?? '',
          cargoUnit: booking['cargoUnit'] ?? '',
          date: booking['date'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          shipmentWeight: booking['shipmentWeight'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;
    }

    // Step 4: If booking successfully created
    if (bookingId != null && bookingId.isNotEmpty) {
      await clearSavedLocalBookingDataWithoutLogin();

// Step 1: Navigate first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseVendor(
            bookingId: bookingId ?? '',
            size: booking['scale'] ?? '',
            unitType: selectedType,
            unitTypeName: booking['selectedTypeName'] ?? '',
            load: booking['selectedLoad'] ?? '',
            unit: booking['selectedName'] ?? '',
            pickup: booking['pickup'] ?? '',
            dropPoints: List<String>.from(booking['dropPoints'] ?? []),
            token: token,
            firstName: firstName,
            lastName: lastName,
            selectedType: selectedType,
            cityName: booking['cityName'] ?? '',
            address: booking['address'] ?? '',
            zipCode: booking['zipCode'] ?? '',
            id: id,
            email: email,
            accountType: accountType,
          ),
        ),
      );

// Step 2: After small delay, show booking dialog on next frame
      Future.delayed(const Duration(seconds: 2), () {
        CommonWidgets()
            .showBookingDialog(context: context, bookingId: bookingId ?? "");
      });
    } else {
      // Fallback → Go to normal user flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UserType(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: id,
            email: email,
            accountType: accountType,
          ),
        ),
      );
    }
  } catch (e, stack) {
    CommonWidgets().showToast('Failed to restore booking data.');
    // If something failed, go to normal user flow
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UserType(
          firstName: firstName,
          lastName: lastName,
          token: token,
          id: id,
          email: email,
          accountType: accountType,
        ),
      ),
    );
  }
}

Future<void> restoreSuperUserBookingDataAfterLogin({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String token,
  required String id,
  required String email,
  required String accountType,
}) async {
  try {
    // Step 1: Check if any saved booking data exists
    final data = await getSavedLocalBookingDataWithoutLogin();
    final savedData = data['bookingData'];

    // Step 2: If no data → go to UserType page directly
    if (savedData == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuperUserHomePage(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: id,
            email: email,
            accountType: accountType,
          ),
        ),
      );
      return;
    }

    // Step 3: If data exists → decode and create booking
    final booking = jsonDecode(savedData);
    final selectedType = booking['selectedType'] ?? '';
    final UserService userService = UserService();

    String? bookingId;

    switch (selectedType) {
      case 'vehicle':
        bookingId = await userService.userVehicleCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          typeName: booking['selectedTypeName'] ?? '',
          scale: booking['scale'] ?? '',
          typeImage: booking['typeImage'] ?? '',
          typeOfLoad: booking['selectedLoad'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;

      case 'bus':
        bookingId = await userService.userBusCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          image: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;

      case 'equipment':
        bookingId = await userService.userEquipmentCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          typeName: booking['selectedTypeName'] ?? '',
          typeImage: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          fromTime: booking['fromTime'] ?? '',
          toTime: booking['toTime'] ?? '',
          cityName: booking['cityName'] ?? '',
          address: booking['address'] ?? '',
          zipCode: booking['zipCode'] ?? '',
          token: token,
        );
        break;

      case 'special':
        bookingId = await userService.userSpecialCreateBooking(
          context,
          name: booking['selectedName'] ?? '',
          unitType: selectedType,
          image: booking['typeImage'] ?? '',
          date: booking['date'] ?? '',
          additionalLabour: booking['selectedLabour'] ?? '',
          fromTime: booking['fromTime'] ?? '',
          toTime: booking['toTime'] ?? '',
          cityName: booking['cityName'] ?? '',
          address: booking['address'] ?? '',
          zipCode: booking['zipCode'] ?? '',
          token: token,
        );
        break;

      case 'shared-cargo':
        bookingId = await userService.userSharedCargoCreateBooking(
          context,
          name: '',
          unitType: selectedType,
          shipmentType: booking['selectedShipmentType'] ?? '',
          shippingCondition: booking['selectedShipmentCondition'] ?? '',
          cargoLength: booking['cargoLength'] ?? '',
          cargoBreadth: booking['cargoBreadth'] ?? '',
          cargoHeight: booking['cargoHeight'] ?? '',
          cargoUnit: booking['cargoUnit'] ?? '',
          date: booking['date'] ?? '',
          time: booking['fromTime'] ?? '',
          productValue: booking['productValue'] ?? '',
          shipmentWeight: booking['shipmentWeight'] ?? '',
          pickup: booking['pickup'] ?? '',
          dropPoints: List<String>.from(booking['dropPoints'] ?? []),
          token: token,
        );
        break;
    }

    // Step 4: If booking successfully created
    if (bookingId != null && bookingId.isNotEmpty) {
      await clearSavedLocalBookingDataWithoutLogin();

// Step 1: Navigate first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TriggerBooking(
            token: token,
            firstName: firstName,
            lastName: lastName,
            id: id,
            email: email,
          ),
        ),
      );

    } else {
      // Fallback → Go to normal user flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuperUserHomePage(
            firstName: firstName,
            lastName: lastName,
            token: token,
            id: id,
            email: email,
            accountType: accountType,
          ),
        ),
      );
    }
  } catch (e, stack) {
    CommonWidgets().showToast('Failed to restore booking data.');
    // If something failed, go to normal user flow
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SuperUserHomePage(
          firstName: firstName,
          lastName: lastName,
          token: token,
          id: id,
          email: email,
          accountType: accountType,
        ),
      ),
    );
  }
}

Future<bool> hasToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token != null && token.isNotEmpty;
}
