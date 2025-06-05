import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_notified.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_profile.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart' as location_package;
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class DriverInteraction extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String bookingId;
  final String pickUp;
  final List dropPoints;
  final String quotePrice;
  final String userId;
  final String partnerId;
  const DriverInteraction({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.bookingId, required this.pickUp, required this.dropPoints, required this.quotePrice, required this.userId, required this.partnerId});

  @override
  State<DriverInteraction> createState() => _DriverInteractionState();
}

class _DriverInteractionState extends State<DriverInteraction> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  LatLng? dropLatLng;
  final List<LatLng> dropLatLngs = [];
  String? distance;
  LatLng? currentLocation;
  double? pickUpDistance;
  List<double>? dropPointsDistance;
  bool isLoading = true;
  bool isCalculating = false;
  String? timeToPickup;
  String? timeToDrop;
  String ? feet;
  String? firstName;
  String? lastName;
  String? contactNo;
  List<Map<String, dynamic>> nearbyPlaces = [];
  late StreamSubscription<Position> positionStream;
  int currentIndex = 0;
  late Timer timer;
  bool isAtPickupLocation = false;
  Timer? _locationTimer;
  StreamSubscription<Position>? positionStreamSubscription;
  BitmapDescriptor? customArrowIcon;
  Marker? currentLocationMarker;
  List<LatLng> waypoints = [];
  String totalDistance = '';
  String totalDuration = '';
  String totalFeet = '';
  StreamSubscription<location_package.LocationData>? locationSubscription;
  double proximityThreshold = 0.001;
  bool hasNavigated = false;
  bool isMoveClicked = false;

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

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _loadCustomMarker();
    _loadData();
    _startRecenterTimer();
    _startPickupCheckTimer();
  }

  @override
  void dispose() {
    _recenterTimer?.cancel();
    _pickupCheckTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }


  Future<void> _loadData() async {
    await _getPickupCoordinates();
    _trackUserLocation();
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

    checkPickupLocation();
  }

  void _trackUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Geolocator.getPositionStream(
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

    markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      position: currentLatLng!,
      icon: customArrowIcon ?? BitmapDescriptor.defaultMarker, // Use arrow icon if available
      infoWindow: const InfoWindow(title: 'Your Location'),
      rotation: bearing, // Rotate arrow towards movement direction
    ));

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

  void _loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/arrow.png');
    final Uint8List markerImage = byteData.buffer.asUint8List();

    img.Image? originalImage = img.decodeImage(markerImage);

    if (originalImage != null) {
      img.Image resizedImage = img.copyResize(originalImage, width: 200, height: 200);

      final Uint8List resizedMarkerImage = Uint8List.fromList(img.encodePng(resizedImage));

      customArrowIcon = BitmapDescriptor.fromBytes(resizedMarkerImage);

      setState(() {});
    }
  }

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
      checkPickupLocation();
      _updateDistanceAndTime();
    });
  }

  void checkPickupLocation() async {
    if (pickupLatLng == null || currentLatLng == null) {
      print("pickupLatLng or currentLatLng is null");
      return;
    }

    double distanceToPickupInKm = _haversineDistance(currentLatLng!, pickupLatLng!);
    double distanceToPickupInFeet = distanceToPickupInKm * 3280.84;

    if (distanceToPickupInFeet <= 100 && !hasNavigated) {
      hasNavigated = true;

      if (mounted) {
        setState(() {
          isAtPickupLocation = true;
        });
        commonWidgets.showToast('Reached Pickup Location..'.tr());

        // await positionStream?.cancel(); // Temporarily comment out

        try {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerNotified(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  partnerId: widget.partnerId,
                  bookingId: widget.bookingId,
                  pickUp: widget.pickUp,
                  dropPoints: widget.dropPoints,
                  quotePrice: widget.quotePrice,
                  userName: firstName != null || lastName!= null
                      ? '$firstName'+' '+ '$lastName'
                      : '',
                  contactNo:contactNo.toString()
              ),
            ),
          );
        } catch (e) {
          print('Navigation error: $e');
        }
      }
    }
  }

  Future<void> fetchUserName() async {
    try {
      final userDetails = await driverService.getUserDetails(widget.userId, widget.token);

      if (userDetails != null) {
        setState(() {
          firstName = userDetails['firstName'] ?? 'N/A';
          lastName = userDetails['lastName'] ?? 'N/A';
          contactNo = userDetails['contactNo'] ?? 'N/A';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  LatLng _findClosestPointOnPolyline(LatLng currentLocation, List<LatLng> polylinePoints) {
    LatLng closestPoint = polylinePoints.first;
    double closestDistance = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      closestPoint.latitude,
      closestPoint.longitude,
    );

    for (LatLng point in polylinePoints) {
      double distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPoint = point;
      }
    }
    return closestPoint;
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
                      },
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(0, 0),
                        zoom: 2,
                      ),
                      markers: markers,
                      polylines: routePolyline != null ? {routePolyline!} : {},
                      buildingsEnabled: false,
                      compassEnabled: false,
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
                    top: MediaQuery.sizeOf(context).height * 0.02,
                    left: viewUtil.isTablet
                        ? MediaQuery.sizeOf(context).height * 0.027
                        : MediaQuery.sizeOf(context).height * 0.017,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.92,
                      child: Card(
                        color: Colors.white,
                        child: feet != null
                          ? Column(
                          children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15, right: 10),
                                      child: Column(
                                        children: [
                                          SvgPicture.asset('assets/upArrow.svg'),
                                          Text(
                                            feet == null?'0 ft':'$feet',
                                            style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?26:18, color: Color(0xff676565)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Pickup Location".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?26:16)),
                                          Text(widget.pickUp,textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                                         /***Commented for removing Nearby location***/
                                         /* Text(nearbyPlaces[currentIndex]['name'] ?? '',
                                            style: TextStyle(fontSize: viewUtil.isTablet?26:16),),
                                          Text('Towards'.tr(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?26:16)),
                                          Text(nearbyPlaces[currentIndex]['address'] ?? '', textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: viewUtil.isTablet?26:16)),*/
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                          : Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Fetching Pickup Location...'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  isMoveClicked
                  ? Positioned(
                      bottom: MediaQuery.sizeOf(context).height * 0.25,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Tooltip(
                          message: 'Re-centre',
                          child: CircleAvatar(
                            radius: viewUtil.isTablet ? 30 : 20,
                            backgroundColor: Colors.white,
                            child: IconButton(
                                onPressed: recenterMap,
                                icon: Icon(Icons.my_location)),
                          ),
                        ),
                      ))
                  : Visibility(
                    visible: feet!=null,
                    child: Positioned(
                      bottom: MediaQuery.sizeOf(context).height * 0.27,
                      child: GestureDetector(
                        onTap: (){
                           setState(() {
                             isMoveClicked = true;
                             recenterMap();
                             // _loadData();
                           });
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
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
                            border: Border.all(
                              color: Color(0xff6069FF),
                              width: 6,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                                minRadius: viewUtil.isTablet?55:40,
                                maxRadius: double.maxFinite,
                                backgroundColor: Color(0xff6069FF),
                                child: Text(
                                  'Move'.tr(),
                                  style:
                                  TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?26:20),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 30),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.93,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(child: SvgPicture.asset('assets/person.svg')),
                                  Center(
                                    child: Text(
                                      firstName != null || lastName!= null
                                          ? '$firstName'+' '+ '$lastName'
                                          : '',
                                      style: TextStyle(fontSize: viewUtil.isTablet?26:24, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            Text(
                                timeToPickup ==null ?'Calculating...'.tr():'$timeToPickup (${pickUpDistance?.toStringAsFixed(2)} km)',
                              style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Color(0xff676565)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await commonWidgets.makePhoneCall(contactNo??'');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Color(0xff6069FF),
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.call, color: Colors.white,size: viewUtil.isTablet?30:20),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Call'.tr(), style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Colors.white)),
                                      ),
                                    ],),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                    ),
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
