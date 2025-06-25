import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_profile.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart' as location_package;
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:slide_to_act/slide_to_act.dart';
class AddressCompleteOrder extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String bookingId;
  final String pickUp;
  final String quotePrice;
  final String userName;
  final String partnerId;
  const AddressCompleteOrder({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.bookingId, required this.pickUp, required this.quotePrice, required this.userName, required this.partnerId});

  @override
  State<AddressCompleteOrder> createState() => _AddressCompleteOrderState();
}

class _AddressCompleteOrderState extends State<AddressCompleteOrder> with SingleTickerProviderStateMixin{
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  final Set<Polyline> polylines = {};
  LatLng? dropPointLatLng;
  final List<LatLng> dropLatLngs = [];
  String? distance;
  LatLng? currentLocation;
  double pickUpDistance = 0;
  List<double> dropPointsDistance = [];
  bool isLoading = false;
  bool isCompleting = false;
  String? timeToPickup;
  String? timeToDrop;
  String ? feet;
  String? firstName;
  String? lastName;
  List<Map<String, dynamic>> nearbyPlaces = [];
  late StreamSubscription<Position> positionStream;
  int currentIndex = 0;
  late Timer timer;
  bool isAtDropLocation = false;
  Timer? _locationTimer;
  StreamSubscription<Position>? positionStreamSubscription;
  BitmapDescriptor? customArrowIcon;
  Marker? currentLocationMarker;
  List<LatLng> waypoints = [];
  String totalDistance = '';
  String totalDuration = '';
  String totalFeet = '';
  String currentPlace = '';
  StreamSubscription<location_package.LocationData>? locationSubscription;
  double proximityThreshold = 0.001;
  bool isMoveClicked = false;
  bool hasNavigated = false;
  Timer? _locationCheckTimer;
  bool completeOrder = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  GoogleMapController? mapController;
  LatLng? currentLatLng;
  LatLng? pickupLatLng;
  Polyline? routePolyline;
  Set<Marker> markers = {};
  bool isFetching = false;
  Timer? _recenterTimer;
  LatLng? previousLatLng;
  Timer? _pickupCheckTimer;
  LatLng? _cachedPickupLatLng;
  List<LatLng>? _cachedPolylinePoints;
  DateTime? _lastPolylineRequestTime;
  Timer? _debounceTimer;
  int _seconds = 120;
  Timer? _timer;
  final List<TextEditingController> otpController = List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _updatePolyline();
    _getCurrentLocation();
    // _loadCustomMarker();
    _loadData();
    _startRecenterTimer();
    _startPickupCheckTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pickupCheckTimer?.cancel();
    _recenterTimer?.cancel();
    _debounceTimer?.cancel();
    positionStream?.cancel();
    super.dispose();
  }


  Future<void> _loadData() async {
    await _getPickupCoordinates();
    _trackUserLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    LatLng current = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLatLng = current;
      _updateMarkers();
      _updateDistanceAndTime();
    });
    await _getAddressFromCoordinates(current.latitude, current.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        String address = data['results'][0]['formatted_address'];

        setState(() {
          currentPlace = address;
        });
      } else {
        print('No address found for coordinates.');
      }
    } else {
      print('Failed to fetch address.');
    }
  }

  Future<void> _getPickupCoordinates() async {
    if (_cachedPickupLatLng != null) {
      setState(() {
        pickupLatLng = _cachedPickupLatLng;
        _updateMarkers();
      });
      return;
    }

    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(widget.pickUp)}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        LatLng newPickupLatLng = LatLng(
          data['results'][0]['geometry']['location']['lat'],
          data['results'][0]['geometry']['location']['lng'],
        );
        setState(() {
          pickupLatLng = newPickupLatLng;
          _cachedPickupLatLng = newPickupLatLng;
          _updateMarkers();
        });
        await driverService.driverCurrentCoordinates(context,partnerId: widget.partnerId,operatorId: widget.id,latitude: pickupLatLng!.latitude,longitude: pickupLatLng!.longitude);
      }
    }
  }

  Future<void> _updatePolyline() async {
    if (currentLatLng == null || pickupLatLng == null) return;

    // Throttle API calls: Only request if 5 sec has passed since the last request
    if (_lastPolylineRequestTime != null &&
        DateTime.now().difference(_lastPolylineRequestTime!).inSeconds < 5) {
      return;
    }

    _lastPolylineRequestTime = DateTime.now();

    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng!.latitude},${currentLatLng!.longitude}&destination=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> polylineCoordinates = _decodePolyline(data['routes'][0]['overview_polyline']['points']);

        setState(() {
          routePolyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          );
        });
      }
    }
  }

  void _startRecenterTimer() {
    _recenterTimer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (currentLatLng != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng!),
        );
      }
    });
  }

  void _handleNewLocation(Position position) async {
    LatLng newLatLng = LatLng(position.latitude, position.longitude);

    // Skip update if movement is small (within 10 meters)
    if (currentLatLng != null &&
        Geolocator.distanceBetween(
            currentLatLng!.latitude, currentLatLng!.longitude,
            newLatLng.latitude, newLatLng.longitude) < 10) {
      return;
    }

    setState(() {
      currentLatLng = newLatLng;
      _updateMarkers();
      _updateDistanceAndTime();
    });

    await _updatePolyline();
    // Debounce polyline update (avoid unnecessary API calls)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () async {
      await driverService.driverCurrentCoordinates(
        context,
        partnerId: widget.partnerId,
        operatorId: widget.id,
        latitude: currentLatLng!.latitude,
        longitude: currentLatLng!.longitude,
      );

    });

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
    }

  }

  void _trackUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update only if moved more than 10 meters
      ),
    ).listen((Position position) {
      _handleNewLocation(position);
    });
  }

  void _updateDistanceAndTime() {
    if (currentLatLng == null || pickupLatLng == null) return;

    double distanceMeters = Geolocator.distanceBetween(
      currentLatLng!.latitude, currentLatLng!.longitude,
      pickupLatLng!.latitude, pickupLatLng!.longitude,
    );

    double distanceKm = distanceMeters / 1000;
    double distanceFeet = distanceMeters * 3.281;

    String feetDisplayValue = distanceFeet >= 5280
        ? "${(distanceFeet / 5280).toStringAsFixed(1)} mi ${(distanceFeet % 5280).round()} ft"
        : "${distanceFeet.toStringAsFixed(0)} ft";

    int timeInMinutes = ((distanceKm / 40.0) * 60).ceil();
    String timeDisplay = timeInMinutes < 1
        ? "${((distanceKm / 40.0) * 3600).toStringAsFixed(0)} sec"
        : "$timeInMinutes min";

    setState(() {
      pickUpDistance = distanceKm;
      feet = feetDisplayValue;
      timeToPickup = timeDisplay;
    });
  }

  static double _haversineDistance(LatLng start, LatLng end) {
    const double R = 6371; // Earth radius in KM
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c; // Distance in KM
    return distance; // Distance in KM
  }

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double deltaLon = (end.longitude - start.longitude) * pi / 180;

    double y = sin(deltaLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
    double bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360; // Convert to degrees
  }

  void _updateMarkers() {
    if (currentLatLng == null || pickupLatLng == null) return;

    markers.clear();

    double bearing = _calculateBearing(previousLatLng ?? currentLatLng!, currentLatLng!);
    previousLatLng = currentLatLng;  // Store the last known position

    // markers.add(Marker(
    //   markerId: const MarkerId('currentLocation'),
    //   position: currentLatLng!,
    //   icon: customArrowIcon ?? BitmapDescriptor.defaultMarker,
    //   infoWindow: const InfoWindow(title: 'Your Location'),
    //   rotation: bearing, // Rotate arrow towards movement direction
    // ));

    markers.add(Marker(
      markerId: const MarkerId('pickupLocation'),
      position: pickupLatLng!,
      infoWindow: InfoWindow(title: 'Pickup Location: ${widget.pickUp}'),
    ));
  }

  void recenterMap() {
    if (currentLatLng == null || pickupLatLng == null || mapController == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(currentLatLng!.latitude, pickupLatLng!.latitude),
        min(currentLatLng!.longitude, pickupLatLng!.longitude),
      ),
      northeast: LatLng(
        max(currentLatLng!.latitude, pickupLatLng!.latitude),
        max(currentLatLng!.longitude, pickupLatLng!.longitude),
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80)); // Padding for better view
  }

/*  void _loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/arrow.png');
    final Uint8List markerImage = byteData.buffer.asUint8List();

    img.Image? originalImage = img.decodeImage(markerImage);

    if (originalImage != null) {
      img.Image resizedImage = img.copyResize(originalImage, width: 200, height: 200);

      final Uint8List resizedMarkerImage = Uint8List.fromList(img.encodePng(resizedImage));

      customArrowIcon = BitmapDescriptor.fromBytes(resizedMarkerImage);

      setState(() {});
    }
  }*/

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  void _startPickupCheckTimer() {
    _pickupCheckTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _updateDistanceAndTime();
    });
  }

  List<LatLng> convertToLatLng(List<dynamic> coordinates) {
    List<LatLng> latLngList = [];

    for (int i = 0; i < coordinates.length; i += 2) {
      if (i + 1 < coordinates.length) {
        double lat = coordinates[i].toDouble();
        double lng = coordinates[i + 1].toDouble();
        latLngList.add(LatLng(lat, lng));
      }
    }

    return latLngList;
  }

  void resendOtp() async {
    for (var controller in otpController) {
      controller.clear();
    }
    await driverService.driverStartTripOTP(
      context,
      bookingId: widget.bookingId,
    );
  }

  void verifyOtp() async {
    String otp = otpController.map((controller) => controller.text).join();

    if (otp.isEmpty || otp.length < otpController.length) {
      CommonWidgets().showToast('please_enter_otp'.tr());
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool isVerified = await driverService.driverVerifyOTP(
      context,
      bookingId: widget.bookingId,
      otp: otp,
    );

    setState(() {
      isLoading = false;
    });
    if (isVerified != true) {
      CommonWidgets().showToast('Please enter correct OTP'.tr());
      return;
    }
    Navigator.pop(context);
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        Future.delayed(Duration(seconds: 3), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });
        ViewUtil viewUtil = ViewUtil(context);
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AlertDialog(
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.fromLTRB(20, 30, 20, 20),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: viewUtil.isTablet
                  ? MediaQuery.of(context).size.height * 0.4
                  :MediaQuery.of(context).size.height * 0.35,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          'assets/payment_success.svg',
                          width: MediaQuery.of(context).size.width,
                          height: viewUtil.isTablet
                              ? MediaQuery.of(context).size.height * 0.25
                              : MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      Positioned(
                        top: -15,
                        right: -15,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(FontAwesomeIcons.multiply, size: viewUtil.isTablet ? 30 : 20),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(
                      'OTP Verified'.tr(),
                      style: TextStyle(fontSize: viewUtil.isTablet ? 30:25, fontWeight: FontWeight.bold,color: Colors.green),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Your trip is Starting'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: viewUtil.isTablet ? 25:20,fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driverAddressInteractionActive', false);
    await driverService.driverCompleteOrder(context, bookingId: widget.bookingId, status: completeOrder, token: widget.token);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverHomePage(
        firstName: widget.firstName,
        lastName: widget.lastName,
        token: widget.token,
        id: widget.id,
        partnerId: widget.partnerId,
        mode: 'online')));
  }

  void showOTPDialog() {
    ViewUtil viewUtil = ViewUtil(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              void _startTimer() {
                _timer?.cancel(); // Cancel any existing timer
                _seconds = 120; // Reset timer
                _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  setState(() {
                    if (_seconds > 0) {
                      _seconds--;
                    } else {
                      _timer?.cancel();
                    }
                  });
                });
              }

              String _formattedTime() {
                final minutes = _seconds ~/ 60;
                final seconds = _seconds % 60;
                return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
              }

              if (_timer == null) {
                _startTimer();
              }

              return Center(
                child: SingleChildScrollView(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('otp_verification'.tr(),
                              style: TextStyle(fontSize: viewUtil.isTablet ?24 :20, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Please enter the OTP sent to the customer".tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: viewUtil.isTablet ?23 :16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: viewUtil.isTablet ? 60 : 50,
                                  child: TextField(
                                    controller: otpController[index],
                                    maxLength: 1,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: const BorderSide(
                                          color: Color(0xffBCBCBC),
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.length == 1 && index < 5) {
                                        FocusScope.of(context).nextFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        FocusScope.of(context).previousFocus();
                                      }
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: RichText(
                              text: TextSpan(
                                text: "Remaining time:".tr(),
                                style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet ? 20 : 15),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: _formattedTime(),
                                    style: TextStyle(color: Colors.blue, fontSize: viewUtil.isTablet ? 20 : 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                resendOtp();
                                _startTimer();
                              });
                            },
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: RichText(
                                text: TextSpan(
                                  text: "didn't_receive_otp".tr(),
                                  style: TextStyle(color: Colors.black, fontSize: viewUtil.isTablet ? 20 : 15),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'resend'.tr(),
                                      style: TextStyle(color: Colors.blue, fontSize: viewUtil.isTablet ? 20 : 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6A66D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                verifyOtp();
                              },
                              child: isLoading
                                  ? Container(
                                height: 10,
                                width: 10,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Verify'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet ?23 :18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Color(0xff6A66D1) )
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel'.tr(),
                                style: TextStyle(
                                  color: Color(0xff6A66D1),
                                  fontSize: viewUtil.isTablet ?23 :18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      _timer?.cancel();
      _timer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          showLeading: true,
          User: widget.firstName +' '+ widget.lastName,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.93,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        Future.delayed(Duration(milliseconds: 500), () {
                          if (currentLatLng != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLatLng!, 16),
                            );
                          }
                        });
                      },
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(0, 0),
                        zoom: 10,
                      ),
                      markers: markers,
                      polylines: routePolyline != null ? {routePolyline!} : {},
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.sizeOf(context).height * 0.02,
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        width: MediaQuery.sizeOf(context).width * 0.92,
                        // height: MediaQuery.sizeOf(context).height * 0.13,
                        child: Card(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50,right: 30,top: 0),
                                      child: Column(
                                        children: [
                                          Icon(Icons.location_on,color: Color(0xff6069FF),size: 30,),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(currentPlace.isNotEmpty
                                                ? currentPlace
                                                : 'Fetching Current Location.....'.tr(),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(fontSize: viewUtil.isTablet?24:16,color: Color(0xff676565))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ),
                  Positioned(
                      bottom: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 30),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.93,
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          timeToPickup ?? '',
                                          style: TextStyle(fontSize: viewUtil.isTablet?26:20, color: Color(0xff676565)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset('assets/person.svg'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          pickUpDistance!=0
                                              ? '${pickUpDistance.toStringAsFixed(2)} km'
                                              : 'Calculating...'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet?26:20, color: Color(0xff676565)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    indent: 15,
                                    endIndent: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.userName,
                                      style: TextStyle(fontSize: viewUtil.isTablet?26:20, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 15, top: 20),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.07,
                                      width: MediaQuery.of(context).size.width * 0.62,
                                      child: SlideAction(
                                        borderRadius: 12,
                                        elevation: 0,
                                        submittedIcon: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: viewUtil.isTablet?30:26,
                                        ),
                                        innerColor: Color(0xff6069FF),
                                        outerColor: Color(0xff6069FF),
                                        sliderButtonIcon: AnimatedBuilder(
                                          animation: _animation,
                                          builder: (context, child) {
                                            return Transform.translate(
                                              offset: Offset(_animation.value, 0), // Horizontal movement
                                              child: Icon(
                                                Icons.arrow_forward_outlined,
                                                color: Colors.white,
                                                size: viewUtil.isTablet?30:26,
                                              ),
                                            );
                                          },
                                        ),
                                        text: "Complete Order".tr(),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: viewUtil.isTablet?26:18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onSubmit: () async {
                                          setState(() {
                                            isCompleting =true;
                                          });
                                          resendOtp();
                                          showOTPDialog();
                                          setState(() {
                                            isCompleting =false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}