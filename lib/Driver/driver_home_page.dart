import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_accept.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notification.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show asin, cos, pi, sin, sqrt;

class DriverHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  const DriverHomePage({super.key, required this.firstName, required this.lastName, required this.token, required this.id});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage>
    with SingleTickerProviderStateMixin {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
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
    fetchCoordinates();
    _checkPermissionsAndFetchLocation();
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
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String pickupPlace = 'San Francisco'; // Pickup location
      List dropPlaces = ['Santa Rosa']; // Drop locations

      // Step 1: Get the current location (device's location)
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        markers.clear();
        polylines.clear();
        dropLatLngs.clear();
      });

      // Step 2: Fetch pickup coordinates
      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));

      // Step 3: Fetch drop coordinates
      List<Future<http.Response>> dropResponses = dropPlaces.map((dropPlace) {
        String dropUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlace)}&key=$apiKey';
        return http.get(Uri.parse(dropUrl));
      }).toList();

      final List<http.Response> dropResponsesList = await Future.wait(dropResponses);

      if (pickupResponse.statusCode == 200) {
        final pickupData = json.decode(pickupResponse.body);

        if (pickupData != null && pickupData['status'] == 'OK') {
          final pickupLocation = pickupData['results']?[0]['geometry']?['location'];
          final pickupAddress = pickupData['results']?[0]['formatted_address'];

          if (pickupLocation != null) {
            LatLng pickupLatLng = LatLng(pickupLocation['lat'], pickupLocation['lng']);
            double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng);
            List<double> distancesToDropPoints = [];
            pickUpDistance = distanceToPickup;

            setState(() {
              markers.add(
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: currentLatLng,
                  infoWindow: InfoWindow(
                    title: 'Current Location',
                    snippet: 'Distance to Pickup: ${distanceToPickup.toStringAsFixed(2)} km',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              );

              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: '$pickupAddress Distance: ${distanceToPickup.toStringAsFixed(2)} km',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              );
            });

            // Step 5: Handle drop point markers
            List<LatLng> waypoints = [];
            for (int i = 0; i < dropResponsesList.length; i++) {
              final dropResponse = dropResponsesList[i];
              if (dropResponse.statusCode == 200) {
                final dropData = json.decode(dropResponse.body);

                if (dropData != null && dropData['status'] == 'OK') {
                  final dropLocation = dropData['results']?[0]['geometry']?['location'];
                  final dropAddress = dropData['results']?[0]['formatted_address'];

                  if (dropLocation != null) {
                    LatLng dropLatLng = LatLng(dropLocation['lat'], dropLocation['lng']);
                    double distance = _haversineDistance(pickupLatLng, dropLatLng);
                    distancesToDropPoints.add(distance);
                    dropPointsDistance = [distance];

                    setState(() {
                      markers.add(
                        Marker(
                          markerId: MarkerId('dropPoint$i'),
                          position: dropLatLng,
                          infoWindow: InfoWindow(
                            title: 'Drop Point ${i + 1}',
                            snippet: '$dropAddress - Distance: ${distance.toStringAsFixed(2)} km',
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      );

                      dropLatLngs.add(dropLatLng);
                      waypoints.add(dropLatLng);
                    });
                  } else {
                    print('Drop location is null for point $i');
                  }
                } else {
                  print('Error with drop API response for point $i: ${dropData?['status']}');
                }
              } else {
                print('Failed to load drop coordinates for point $i, status code: ${dropResponse.statusCode}');
              }
            }

            // Step 6: Fetch route from current location to pickup point
            String directionsUrlFromCurrentToPickup =
                'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng.latitude},${pickupLatLng.longitude}&key=$apiKey';
            final directionsResponseFromCurrentToPickup = await http.get(Uri.parse(directionsUrlFromCurrentToPickup));

            // Draw the polyline for current location to pickup point
            if (directionsResponseFromCurrentToPickup.statusCode == 200) {
              final directionsData = json.decode(directionsResponseFromCurrentToPickup.body);
              if (directionsData['status'] == 'OK') {
                final polylinePoints = directionsData['routes'][0]['overview_polyline']['points'];
                List<LatLng> routePoints = _decodePolyline(polylinePoints);

                setState(() {
                  polylines.add(Polyline(
                    polylineId: const PolylineId('currentToPickup'),
                    color: Colors.blue,
                    width: 5,
                    points: routePoints,
                  ));
                });

                // Extract travel time
                final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];
                timeToPickup = durationToPickup;
                print('Travel time to Pickup: $durationToPickup');
              }
            }

            // Step 7: Fetch route from pickup point to drop points
            if (dropLatLngs.isNotEmpty) {
              String waypointsString = waypoints.map((latLng) => '${latLng.latitude},${latLng.longitude}').join('|');
              String directionsUrl =
                  'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLatLng.latitude},${pickupLatLng.longitude}&destination=${dropLatLngs.last.latitude},${dropLatLngs.last.longitude}&waypoints=$waypointsString&key=$apiKey';
              final directionsResponse = await http.get(Uri.parse(directionsUrl));

              if (directionsResponse.statusCode == 200) {
                final directionsData = json.decode(directionsResponse.body);
                if (directionsData['status'] == 'OK') {
                  final polylinePoints = directionsData['routes'][0]['overview_polyline']['points'];
                  List<LatLng> routePoints = _decodePolyline(polylinePoints);

                  setState(() {
                    polylines.add(Polyline(
                      polylineId: const PolylineId('pickupToDrop'),
                      color: Colors.green,
                      width: 5,
                      points: routePoints,
                    ));
                  });

                  // Extract travel time from pickup to drop points
                  final durationFromPickupToDrop = directionsData['routes'][0]['legs'][0]['duration']['text'];
                  timeToDrop = durationFromPickupToDrop;
                  print('Travel time from Pickup to Drop Points: $durationFromPickupToDrop');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }



  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
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

  double _haversineDistance(LatLng a, LatLng b) {
    const double R = 6371; // Radius of Earth in kilometers
    double lat1 = a.latitude * (3.141592653589793 / 180);
    double lat2 = b.latitude * (3.141592653589793 / 180);
    double dLat = (b.latitude - a.latitude) * (3.141592653589793 / 180);
    double dLon = (b.longitude - a.longitude) * (3.141592653589793 / 180);

    double aValue = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(aValue));

    return R * c; // Distance in kilometers
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


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.78,
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0), // Default position
                          zoom: 1,
                        ),
                        markers: markers,
                        polylines: polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
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
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => OrderAccept()));
                                    },
                                    icon: Icon(Icons.search)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: GestureDetector(
                        onTap: _toggleNotification, // Toggle the notification screen
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
                    ),
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
                            isOnline = !isOnline;
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
                            isOnline = !isOnline;
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
                )
              ),
          ],
        ),
      ),
    );
  }
}
