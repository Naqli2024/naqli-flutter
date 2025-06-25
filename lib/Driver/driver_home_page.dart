import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_addresNavigation/driver_addressInteraction.dart';
import 'package:flutter_naqli/Driver/Views/driver_addresNavigation/driver_addressNotification.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_interaction.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_notification.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_profile.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show asin, atan2, cos, pi, sin, sqrt;

import 'package:shared_preferences/shared_preferences.dart';

class DriverHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String partnerId;
  final String mode;
  const DriverHomePage({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.partnerId, required this.mode});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage>
    with SingleTickerProviderStateMixin {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  bool isOnline = false;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> dropLatLngs = [];
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _showNotification = false;
  bool isModeChanging = false;
  String? distance;
  LatLng? currentLocation;
  double? pickUpDistance;
  List<double>? dropPointsDistance;
  String? timeToPickup;
  String? timeToDrop;
  String cityName = '';
  String bookingStatus = '';
  LatLng currentLatLng = LatLng(37.7749, -122.4194);
  StreamSubscription<Position>? positionStream;
  double currentHeading = 0.0;
  BitmapDescriptor? customIcon;
  Map<String, dynamic>? bookingRequestData;
  bool isLoading = false;
  Map<String, dynamic>? booking;
  String bookingId = '';
  String quotePrice = '0';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _checkPermissionsAndFetchLocation();
    fetchCoordinates();
    _loadDriverStatus();
    _fetchBookingRequest();
    _fetchBookingDetails();
    _checkInteractionData();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    _animationController.dispose();
    markers.clear();
    polylines.clear();
    super.dispose();
  }

  Future<void> _fetchBookingDetails() async {
    final bookingData = await driverService.fetchBookingDetails(bookingId??'', widget.token);
    setState(() {
      booking = bookingData;
      cityName =booking?['cityName']??"";
      bookingStatus =booking?['bookingStatus']??'';
    });
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));
    }
  }

  Future<void> fetchCoordinates() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        markers.clear();
        polylines.clear();
        dropLatLngs.clear();
      });

      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String reverseGeocodeUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng.latitude},${currentLatLng.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(reverseGeocodeUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final placeName = data['results'][0]['formatted_address'];
          BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(100, 100)),
            'assets/carDirection.png',
          );
          setState(() {
            markers.add(
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: currentLatLng,
                infoWindow: InfoWindow(
                  title: 'Current Location'.tr(),
                  snippet: placeName,
                ),
                icon: customIcon,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current Location'.tr(),
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${'Place:'.tr()} $placeName',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          });
        } else {
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

  double calculateDistance(LatLng a, LatLng b) {
    const double R = 6371;
    double lat1 = a.latitude * pi / 180;
    double lat2 = b.latitude * pi / 180;
    double dLat = (b.latitude - a.latitude) * pi / 180;
    double dLon = (b.longitude - a.longitude) * pi / 180;

    double aValue = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(aValue));

    return R * c;
  }

  void _toggleNotification() {
    setState(() {
      _showNotification = !_showNotification;
    });

    if (_showNotification) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _loadDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnline = prefs.getBool('isOnline') ?? false;
    });
  }

  Future<void> _saveDriverStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnline', status);
  }

  void driverOnlineModeChange() async{
    isModeChanging = true;
    await driverService.driverMode(context, partnerId: widget.partnerId, operatorId: widget.id, mode: "online");
  }

  void driverOfflineModeChange() async{
    await driverService.driverMode(context, partnerId: widget.partnerId, operatorId: widget.id, mode: "offline");
  }

  Future<void> _fetchBookingRequest() async {
    try {
      final data = await driverService.driverRequest(context, operatorId: widget.id);

      if (data != null) {
        String? fetchedBookingId;
        String? fetchedQuotePrice;
        Map<String, dynamic>? matchedBooking;

        if (data['bookingRequest'] != null && data['bookingRequest']['assignedOperator'] != null) {
          matchedBooking = data['bookingRequest'];
          fetchedBookingId = matchedBooking?['assignedOperator']['bookingId']?.toString();
          fetchedQuotePrice = matchedBooking?['quotePrice']?.toString();
        }

        if (fetchedBookingId == null && data['bookingRequests'] != null) {
          final requests = List<Map<String, dynamic>>.from(data['bookingRequests']);

          for (final request in requests) {
            final quotePrice = request['quotePrice'];
            final paymentStatus = request['paymentStatus'];

            if (quotePrice != null &&
                (paymentStatus == 'HalfPaid' || paymentStatus == 'Paid' || paymentStatus == 'Completed') &&
                    request['bookingStatus'] != 'Completed') {
              matchedBooking = request;
              fetchedBookingId = request['bookingId']?.toString();
              fetchedQuotePrice = quotePrice.toString();
              break;
            }
          }
        }

        if (fetchedBookingId != null && fetchedQuotePrice != null) {
          setState(() {
            bookingRequestData = matchedBooking;
            bookingId = fetchedBookingId!;
            quotePrice = fetchedQuotePrice!;
          });
        } else {
          print('No valid booking with quote/payment found.');
        }
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred. Please try again:');
    }
  }


  Future<void> _handleDriverRequest() async {
    try {
      final response = await driverService.driverRequest(context, operatorId: widget.id);

      if (response != null) {
        _toggleNotification();
      } else {
        commonWidgets.showToast('No data available');
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset('assets/naqlee-logo.svg',
                        height: MediaQuery.of(context).size.height * 0.05),
                    GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(child: Icon(FontAwesomeIcons.multiply)))
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.person,size: 30,),
                ),
                title: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Profile'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    DriverProfile(firstName: widget.firstName,lastName: widget.lastName,operatorId: widget.id, partnerId: widget.partnerId,)
                  ));
                },
              ),
              ListTile(
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.logout,color: Colors.red,size: 30,),
                ),
                title: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('logout'.tr(),style: TextStyle(fontSize: 25,color: Colors.red),),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          content: Container(
                            width: viewUtil.isTablet
                                ? MediaQuery.of(context).size.width * 0.6
                                : MediaQuery.of(context).size.width,
                            height: viewUtil.isTablet
                                ? MediaQuery.of(context).size.height * 0.08
                                : MediaQuery.of(context).size.height * 0.12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 30,bottom: 10),
                                  child: Text(
                                    'are_you_sure_you_want_to_logout'.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: viewUtil.isTablet?27:19),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('yes'.tr(),
                                style: TextStyle(fontSize: viewUtil.isTablet?22:16),),
                              onPressed: () async {
                                await clearDriverData();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DriverLogin()),
                                );
                              },
                            ),
                            TextButton(
                              child: Text('no'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body:  isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: ()async{
                  _fetchBookingRequest();
                },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
             child: Stack(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.78,
                          child: GoogleMap(
                            mapType: MapType.normal,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                            },
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(0, 0), // Default position
                              zoom: 40,
                            ),
                            markers: Set<Marker>.of(markers),
                            polylines: Set<Polyline>.of(polylines),
                            myLocationEnabled: false,
                            myLocationButtonEnabled: true,
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                              ),
                            },
                          ),
                        ),
                        Positioned(
                          top: 15,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Builder(
                                    builder: (context) => Center(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          onPressed: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          icon: const Icon(Icons.menu),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _checkPermissionsAndFetchLocation();
                                            fetchCoordinates();
                                            _fetchBookingRequest();
                                          });
                                        },
                                        icon: Icon(Icons.refresh)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isOnline)
                       Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 20),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: viewUtil.isTablet
                              ? MediaQuery.of(context).size.width * 0.37
                              : MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xff6069FF)),
                              ),
                            ),
                            onPressed: () async {
                              isModeChanging =true;
                              _checkPermissionsAndFetchLocation();
                              await _fetchBookingRequest();
                              await _fetchBookingDetails();
                              await _handleDriverRequest();
                              setState(() {
                                driverOnlineModeChange();
                                isOnline = true;
                                _saveDriverStatus(isOnline);
                                if (bookingStatus == 'Completed') {
                                  CommonWidgets().showToast('This booking is already completed.');
                                }
                              });
                            },
                            child: isModeChanging
                                ? Center(child: CircularProgressIndicator())
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SvgPicture.asset('assets/carOffline.svg', height: viewUtil.isTablet ?40:35),
                                Text(
                                  'Offline'.tr(),
                                  style:
                                  TextStyle(fontSize: viewUtil.isTablet ?26 :23, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (isOnline)
                      Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 20),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: viewUtil.isTablet
                              ? MediaQuery.of(context).size.width * 0.37
                              : MediaQuery.of(context).size.width * 0.45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff6069FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xff6069FF)),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                driverOfflineModeChange();
                                isOnline = false;
                                _saveDriverStatus(isOnline);
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Online'.tr(),
                                  style:
                                  TextStyle(fontSize: viewUtil.isTablet ?26 :23, color: Colors.black),
                                ),
                                SvgPicture.asset('assets/carOnline.svg', height: viewUtil.isTablet ?40:35),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                _buildNotification()
              ],
                      ),
                    ),
            ),
      ),
    );
  }

  Future<void> _checkInteractionData() async {
    final interactionAddressData = await getSavedDriverAddressInteractionData();
    final interactionData = await getSavedDriverInteractionData();
    if (interactionAddressData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverAddressInteraction(
            firstName: interactionAddressData['firstName'] ?? '',
            lastName: interactionAddressData['lastName'] ?? '',
            token: interactionAddressData['token'] ?? '',
            id: interactionAddressData['id'] ?? '',
            partnerId: interactionAddressData['partnerId'] ?? '',
            bookingId: interactionAddressData['bookingId'] ?? '',
            pickUp: interactionAddressData['pickUp'] ?? '',
            address: interactionAddressData['address'] ?? '',
            quotePrice: interactionAddressData['quotePrice'] ?? '',
            userId: interactionAddressData['userId'] ?? '',
          ),
        ),
      );
    } else if (interactionData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverInteraction(
            bookingId: interactionData['bookingId'],
            firstName: interactionData['firstName'],
            lastName: interactionData['lastName'],
            token: interactionData['token'],
            id: interactionData['id'],
            partnerId: interactionData['partnerId'],
            pickUp: interactionData['pickUp'],
            dropPoints: List<String>.from(interactionData['dropPoints']),
            quotePrice: interactionData['quotePrice'],
            userId: interactionData['userId'],
          )
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildNotification() {
    if (_showNotification && bookingStatus != 'Completed' && bookingId.isNotEmpty && quotePrice != '0') {
      final childWidget = cityName.isEmpty
          ? DriverNotification(
        firstName: widget.firstName,
        lastName: widget.lastName,
        token: widget.token,
        id: widget.id,
        distanceToPickup: pickUpDistance ?? 0.0,
        distanceToDropPoints: dropPointsDistance ?? [],
        timeToDrop: timeToDrop ?? '',
        timeToPickup: timeToPickup ?? '',
        partnerId: widget.partnerId,
        mode: widget.mode,
        bookingId: bookingId,
        quotePrice: quotePrice,
      )
          : DriverAddressNotification(
        firstName: widget.firstName,
        lastName: widget.lastName,
        token: widget.token,
        id: widget.id,
        distanceToPickup: pickUpDistance ?? 0.0,
        timeToPickup: timeToPickup ?? '',
        partnerId: widget.partnerId,
        mode: widget.mode,
        bookingId: bookingId,
        quotePrice: quotePrice,
      );

      return SlideTransition(position: _slideAnimation, child: childWidget);
    }
    return Container();
  }




}
