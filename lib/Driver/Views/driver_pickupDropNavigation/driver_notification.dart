import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'driver_accept.dart';
import 'dart:ui' as ui;

class DriverNotification extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final double distanceToPickup;
  final List<double> distanceToDropPoints;
  final String timeToPickup;
  final String timeToDrop;
  final String partnerId;
  final String bookingId;
  final String mode;
  const DriverNotification({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.distanceToPickup, required this.distanceToDropPoints, required this.timeToPickup, required this.timeToDrop, required this.partnerId, required this.mode, required this.bookingId});

  @override
  State<DriverNotification> createState() => _DriverNotificationState();
}

class _DriverNotificationState extends State<DriverNotification> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  Map<String, dynamic>? bookingRequestData;
  Map<String, dynamic>? booking;
  bool isLoading = false;
  bool isCalculating = false;
  Map<String, dynamic>? distanceData;
  String? pickupAddress;
  List<String> dropPoints = [];
  String currentToPickupDistance = 'N/A';
  String currentToPickupDuration = 'N/A';
  List<Map<String, String>> dropPointsData = [];

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
    _fetchBookingRequest();
    _getDistanceData();
  }

  Future<void> _getDistanceData() async {
    if (booking == null) {
      print("Booking data is null, cannot fetch distance data.");
      return;
    }

    final pickupAddress = booking?['pickup'];
    List<String> dropPointsAddresses = [];

    if (booking!['dropPoints'] is List) {
      dropPoints = (booking!['dropPoints'] as List).map((dropPoint) => dropPoint.toString()).toList();
    }

    if (pickupAddress.isEmpty || dropPoints.isEmpty) {
      print("Pickup address or drop points are empty.");
      return;
    }

    final data = await calculateDistanceAndTime(
      pickupAddress: pickupAddress,
      dropPointsAddresses: dropPoints,
    );

    if (data != null) {
      setState(() {
        currentToPickupDistance = data['currentToPickup']['distance'];
        currentToPickupDuration = data['currentToPickup']['duration'];
        dropPointsData = List<Map<String, String>>.from(data['dropPoints']);
      });
    } else {
      print("Failed to fetch distance data.");
    }
  }

  Future<Map<String, dynamic>?> calculateDistanceAndTime({
    required String pickupAddress,
    required List<String> dropPointsAddresses,
  }) async {
    try {
      setState(() {
        isCalculating = true;
      });
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String currentLocation = '${position.latitude},${position.longitude}';

      // String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$currentLocation|$pickupAddress&destinations=$pickupAddress|${dropPointsAddresses.join('|')}&key=$apiKey';
      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentLocation}&destinations=${pickupAddress}|${dropPointsAddresses.join('|')}&key=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');  // Log full response
        if (data['status'] == 'OK') {
          return _processDistanceMatrixResponse(data, pickupAddress);
        } else {
          print('API Status Error: ${data['status']}');
        }
      } else {
        print('Error fetching distance matrix: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }finally{
      setState(() {
        isCalculating = false;
      });
    }
    return null;
  }

  Map<String, dynamic>? _processDistanceMatrixResponse(Map<String, dynamic> data, String pickupAddress) {
    if (data['status'] == 'OK') {
      var rows = data['rows'] as List;
      if (rows.isNotEmpty) {
        var currentToPickupElement = rows[0]['elements'][0];
        String currentToPickupDistance = currentToPickupElement['distance']['text'];
        String currentToPickupDuration = currentToPickupElement['duration']['text'];

        List<Map<String, String>> dropPoints = [];

        for (int i = 0; i < rows.length; i++) {
          var elements = rows[i]['elements'];

          if (elements.isNotEmpty) {
            for (int j = 1; j < elements.length; j++) {
              var dropPointElement = elements[j];
              if (dropPointElement['status'] == 'OK') {
                dropPoints.add({
                  'distance': dropPointElement['distance']['text'],
                  'duration': dropPointElement['duration']['text'],
                });
              }
            }
          }
        }

        return {
          'currentToPickup': {
            'distance': currentToPickupDistance,
            'duration': currentToPickupDuration,
          },
          'dropPoints': dropPoints,
        };
      }
    } else {
      print('API response status not OK: ${data['status']}');
    }
    return null;
  }

  Future<void> _fetchBookingDetails() async {
    final bookingData = await driverService.fetchBookingDetails(widget.bookingId, widget.token);

    print("Fetched Booking Data: $bookingData");

    setState(() {
      booking = bookingData;
    });

    await _getDistanceData();
  }

  Future<void> _fetchBookingRequest() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await driverService.driverRequest(context, operatorId: widget.id);

      if (data != null && data['bookingRequest'] != null) {
        if (data['bookingRequest']['assignedOperator'] != null) {
          final assignedOperatorBookingId = data['bookingRequest']['assignedOperator']['bookingId'];
          print('Booking ID from assignedOperator: $assignedOperatorBookingId');
        } else {

          final bookingRequestBookingId = data['bookingRequest']['bookingId'];
          print('Booking ID from bookingRequest: $bookingRequestBookingId');
        }

        setState(() {
          bookingRequestData = data;
          isLoading = false;
        });
      } else {
        print("No booking request data available.");
      }
    } catch (e) {
      print("Error during API call: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: false,
                backgroundColor: Color(0xffE6E5E3).withOpacity(0.1),
                toolbarHeight: MediaQuery.of(context).size.height * 0.15,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      token: widget.token,
                      id: widget.id,partnerId: widget.partnerId,mode: widget.mode,)));
                  },
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    size: 30,
                  ),
                ),
                title: Text('Radar'.tr(), style: TextStyle(fontSize: 26)),
              ),
              body: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: GestureDetector(
                      onTap: (){
                        dropPoints == []
                        ? commonWidgets.showToast('Please wait....'.tr())
                        : Navigator.push(context, MaterialPageRoute(builder: (context)=> OrderAccept(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          partnerId: widget.partnerId,
                          bookingId: (bookingRequestData?['bookingRequest']['bookingId'] ?? '').toString(),
                          pickUp: booking?['pickup'],
                          dropPoints: dropPoints,
                          quotePrice: (bookingRequestData?['bookingRequest']['quotePrice'] ?? 0).toString(),
                          userId: booking?['user'],
                        )));
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SvgPicture.asset('assets/naqleeBorder.svg'),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        'SAR',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        (bookingRequestData?['bookingRequest']['quotePrice'] ?? 0).toString(),
                                        style: TextStyle(fontSize: 34),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 8, bottom: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/direction.svg',
                                          height: MediaQuery.of(context).size.height * 0.13,
                                        ),
                                      ],
                                    ),

                                    isCalculating
                                        ? Center(child: CircularProgressIndicator())
                                        : Expanded(
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$currentToPickupDuration ($currentToPickupDistance) ${'away'.tr()}',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Text(
                                                booking?['pickup'] ?? '',
                                                style: TextStyle(fontSize: 20),
                                              ),

                                              if (dropPointsData.isNotEmpty) ...[
                                                ...dropPointsData.map((dropPoint) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Text(
                                                      '${dropPoint['duration']} (${dropPoint['distance']}) ${'left'.tr()}',
                                                      style: TextStyle(fontSize: 20),
                                                    ),
                                                  );
                                                }).toList(),
                                              ] else ...[
                                                Text('', style: TextStyle(fontSize: 20)),
                                              ],

                                              Text(
                                                booking?['dropPoints'] != null && booking!['dropPoints'] is List
                                                    ? (booking!['dropPoints'] as List).join(', ')
                                                    : '',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: Text(
                      '${"We’ll let you know when there".tr()}\n${'Is a request'.tr()}',
                      style: TextStyle(fontSize: 18,color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: IconButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,partnerId: widget.partnerId,mode: widget.mode,)));
                        },
                        icon: Icon(Icons.cancel)
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
