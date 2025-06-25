import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
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
  final String quotePrice;
  const DriverNotification({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.distanceToPickup, required this.distanceToDropPoints, required this.timeToPickup, required this.timeToDrop, required this.partnerId, required this.mode, required this.bookingId, required this.quotePrice});

  @override
  State<DriverNotification> createState() => _DriverNotificationState();
}

class _DriverNotificationState extends State<DriverNotification> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
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
    _getDistanceData();
  }

  Future<void> _getDistanceData() async {
    if (booking == null) {
      return;
    }

    final pickupAddress = booking?['pickup'];
    List<String> dropPointsAddresses = [];

    if (booking!['dropPoints'] is List) {
      dropPoints = (booking!['dropPoints'] as List).map((dropPoint) => dropPoint.toString()).toList();
    }

    if (pickupAddress.isEmpty || dropPoints.isEmpty) {
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
        return;
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
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      String currentLocation = '${position.latitude},${position.longitude}';

      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentLocation}&destinations=${pickupAddress}|${dropPointsAddresses.join('|')}&key=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return _processDistanceMatrixResponse(data, pickupAddress);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      return null;
    }
    return null;
  }

  Future<void> _fetchBookingDetails() async {
    final bookingData = await driverService.fetchBookingDetails(widget.bookingId, widget.token);
    setState(() {
      booking = bookingData;
    });

    await _getDistanceData();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
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
                title: Text('Radar'.tr(), style: TextStyle(fontSize: viewUtil.isTablet?30:26)),
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
                          bookingId: widget.bookingId,
                          pickUp: booking?['pickup'],
                          dropPoints: dropPoints,
                          quotePrice: widget.quotePrice.toString(),
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
                                    SvgPicture.asset('assets/naqleeBorder.svg',
                                      height: viewUtil.isTablet
                                          ?MediaQuery.of(context).size.height * 0.05
                                          :MediaQuery.of(context).size.height * 0.04),
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
                                        style: TextStyle(fontSize: viewUtil.isTablet?26:24),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        widget.quotePrice .toString(),
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
                                                style: TextStyle(fontSize: viewUtil.isTablet?26:20),
                                              ),
                                              Text(
                                                booking?['pickup'] ?? '',
                                                style: TextStyle(fontSize: viewUtil.isTablet?26:20),
                                              ),

                                              if (dropPointsData.isNotEmpty) ...[
                                                ...dropPointsData.map((dropPoint) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Text(
                                                      '${dropPoint['duration']} (${dropPoint['distance']}) ${'left'.tr()}',
                                                      style: TextStyle(fontSize: viewUtil.isTablet?26:20),
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
                                                style: TextStyle(fontSize: viewUtil.isTablet?26:20),
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
                      style: TextStyle(fontSize: viewUtil.isTablet?26:18,color: Colors.black),
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
                        icon: Icon(Icons.cancel,size: viewUtil.isTablet?30:25)
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
