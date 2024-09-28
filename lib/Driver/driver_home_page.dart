import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_accept.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notification.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
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
  String? distance;
  LatLng? currentLocation;
  double? pickUpDistance;
  List<double>? dropPointsDistance;
  String? timeToPickup;
  String? timeToDrop;
  LatLng currentLatLng = LatLng(37.7749, -122.4194);
  StreamSubscription<Position>? positionStream;
  double currentHeading = 0.0;
  BitmapDescriptor? customIcon;
  Map<String, dynamic>? bookingRequestData;
  Future<Map<String, dynamic>?>? booking;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the screen
      end: Offset.zero, // End at its normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _checkPermissionsAndFetchLocation();
    fetchCoordinates();
    _loadDriverStatus();
    _fetchBookingRequest();
    print(widget.partnerId);
    print(widget.id);
    print(widget.mode);
  }


  @override
  void dispose() {
    positionStream?.cancel();
    _animationController.dispose();
    markers.clear();
    polylines.clear();
    super.dispose();
  }

  double _haversineDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLon = _degreesToRadians(end.longitude - start.longitude);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degreesToRadians(start.latitude)) *
                cos(_degreesToRadians(end.latitude)) *
                sin(dLon / 2) *
                sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Move camera to current location on the map
    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));
    }
  }

  Future<void> fetchCoordinates() async {
    try {
      // Step 1: Get the current location (device's location)
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      // Clear existing markers and polylines
      setState(() {
        markers.clear();
        polylines.clear();
        dropLatLngs.clear();
      });

      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      // Step 2: Reverse geocode to get the place name
      String reverseGeocodeUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng.latitude},${currentLatLng.longitude}&key=$apiKey';
      final response = await http.get(Uri.parse(reverseGeocodeUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final placeName = data['results'][0]['formatted_address'];
          // Step 3: Add current location marker with place name
          BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(100, 100)), // Customize size here if necessary
            'assets/carDirection.png', // Path to your custom icon
          );
          setState(() {
            markers.add(
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: currentLatLng,
                infoWindow: InfoWindow(
                  title: 'Current Location',
                  snippet: placeName, // Show the place name here
                ),
                icon: customIcon,
                onTap: () {
                  // Show info window when the marker is clicked
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Place: $placeName',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );

            // Move the camera to the current location
            // mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
          });
        } else {
          print('Failed to reverse geocode location. Status: ${data['status']}');
        }
      } else {
        print('Failed to fetch reverse geocoding. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }




  void _showDistanceSnackbar(LatLng point, List<LatLng> otherPoints) {
    double totalDistance = 0;

    for (LatLng otherPoint in otherPoints) {
      totalDistance += _haversineDistance(point, otherPoint);
    }
    distance = '${totalDistance.toStringAsFixed(2)}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Total Distance: ${totalDistance.toStringAsFixed(2)} km'),
    ));
  }

  void _moveCameraToFitAllMarkers() {
    if (mapController != null) {
      LatLngBounds bounds;
      if (dropLatLngs.isNotEmpty) {
        bounds = _calculateBounds();
      } else {
        bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          northeast: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
        );
      }
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _calculateBounds() {
    if (pickupLatLng == null) {
      throw Exception('pickupLatLng is null');
    }

    double southWestLat = [
      pickupLatLng!.latitude,
      ...dropLatLngs.map((latLng) => latLng.latitude)
    ].reduce((a, b) => a < b ? a : b);

    double southWestLng = [
      pickupLatLng!.longitude,
      ...dropLatLngs.map((latLng) => latLng.longitude)
    ].reduce((a, b) => a < b ? a : b);

    double northEastLat = [
      pickupLatLng!.latitude,
      ...dropLatLngs.map((latLng) => latLng.latitude)
    ].reduce((a, b) => a > b ? a : b);

    double northEastLng = [
      pickupLatLng!.longitude,
      ...dropLatLngs.map((latLng) => latLng.longitude)
    ].reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }


  double calculateDistance(LatLng a, LatLng b) {
    const double R = 6371; // Radius of Earth in kilometers
    double lat1 = a.latitude * pi / 180;
    double lat2 = b.latitude * pi / 180;
    double dLat = (b.latitude - a.latitude) * pi / 180;
    double dLon = (b.longitude - a.longitude) * pi / 180;

    double aValue = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(aValue));

    return R * c; // Distance in kilometers
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
    await driverService.driverMode(context, partnerId: widget.partnerId, operatorId: widget.id, mode: "online");
  }

  void driverOfflineModeChange() async{
    await driverService.driverMode(context, partnerId: widget.partnerId, operatorId: widget.id, mode: "offline");
  }

  Future<void> _fetchBookingRequest() async {
    try {
      // Fetch the booking request data using driverService
      final data = await driverService.driverRequest(context, operatorId: widget.id);

      if (data != null && data['bookingRequest'] != null) {
        // Check if assignedOperator exists in the bookingRequest
        if (data['bookingRequest']['assignedOperator'] != null) {
          // Fetch bookingId from assignedOperator if present
          final assignedOperatorBookingId = data['bookingRequest']['assignedOperator']['bookingId'];
          print('Booking ID from assignedOperator: $assignedOperatorBookingId');
        } else {
          // Otherwise, fetch bookingId directly from bookingRequest
          final bookingRequestBookingId = data['bookingRequest']['bookingId'];
          print('Booking ID from bookingRequest: $bookingRequestBookingId');
        }

        // Set the fetched data to state
        setState(() {
          bookingRequestData = data;
        });
      } else {
        print("No booking request data available.");
      }
    } catch (e) {
      print("Error during API call: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  Future<void> _handleDriverRequest() async {
    try {
      // Fetch the driver request using driverService
      final response = await driverService.driverRequest(context, operatorId: widget.id);

      if (response != null) {
        // Toggle notification if response exists
        _toggleNotification();
      } else {
        // Handle if no data is present in the response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data available from the API.')),
        );
      }
    } catch (e) {
      print("Error during API call: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Icon(Icons.logout,color: Colors.red,size: 30,),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Logout',style: TextStyle(fontSize: 25,color: Colors.red),),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30,bottom: 10),
                            child: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            await clearDriverData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DriverLogin()),
                            );
                          },
                        ),
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
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
          : SingleChildScrollView(
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
                        gestureRecognizers: Set()
                          ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer(),
                          ))
                          ..add(Factory<TapGestureRecognizer>(
                                () => TapGestureRecognizer(),
                          )),
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
                                    offset: const Offset(
                                        0, 5), // changes position of shadow
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
                                    offset: const Offset(
                                        0, 5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                    onPressed: () {
                                      // Navigator.push(context,
                                      //     MaterialPageRoute(builder: (context) => OrderAccept()));
                                    },
                                    icon: Icon(Icons.search)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                   /* Positioned(
                      bottom: 20,
                      child: GestureDetector(
                        onTap: ()async{

                          },
                          // _toggleNotification,
                          child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                          0, 5), // changes position of shadow
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
                                minRadius: 45,
                                maxRadius: double.maxFinite,
                                backgroundColor: Color(0xff6069FF),
                                child: Text(
                                  'Move',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                                )),
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),
                if (!isOnline) // Show Offline button when the user is offline
                  Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xff6069FF)),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            driverOnlineModeChange();
                            isOnline = true;
                            _saveDriverStatus(isOnline);
                            _handleDriverRequest();
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset('assets/carOffline.svg', height: 35),
                            Text(
                              'Offline',
                              style:
                              TextStyle(fontSize: 23, color: Colors.black),
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
                      width: MediaQuery.of(context).size.width * 0.45,
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
                              'Online',
                              style:
                              TextStyle(fontSize: 23, color: Colors.black),
                            ),
                            SvgPicture.asset('assets/carOnline.svg', height: 35),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // SlideTransition widget for notification screen
            if (_showNotification)
              SlideTransition(
                position: _slideAnimation,
                child: DriverNotification(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    token: widget.token,
                    id: widget.id,
                  distanceToPickup: pickUpDistance ?? 0.0,
                  distanceToDropPoints: dropPointsDistance ?? [],
                  timeToDrop: timeToDrop??'',
                  timeToPickup: timeToPickup??'',
                  partnerId: widget.partnerId,
                  mode: widget.mode,
                  bookingId: (bookingRequestData?['bookingRequest']['bookingId'] ?? '').toString(),
                )
              ),
          ],
        ),
      ),
    );
  }
}
