import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_interaction.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OrderAccept extends StatefulWidget {
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

  const OrderAccept({super.key,required this.firstName, required this.lastName, required this.token, required this.id,required this.bookingId, required this.pickUp, required this.dropPoints, required this.quotePrice, required this.userId, required this.partnerId});

  @override
  State<OrderAccept> createState() => _OrderAcceptState();
}

class _OrderAcceptState extends State<OrderAccept> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> dropLatLngs = [];
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
    fetchCoordinates();
    _checkPermissionsAndFetchLocation();
  }

  Future<void> fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      setState(() {
        isLoading = true;
      });
      String pickupPlace = widget.pickUp; // Pickup location
      List dropPlaces = widget.dropPoints; // Drop locations

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
            BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(100, 48)), // Customize size here if necessary
              'assets/carDirection.png', // Path to your custom icon
            );
            setState(() {
              markers.add(
                Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: currentLatLng,
                    infoWindow: InfoWindow(
                      title: 'Current Location',
                      snippet: 'Distance to Pickup: ${distanceToPickup.toStringAsFixed(2)} km',
                    ),
                    icon:customIcon
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
                  mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 6));
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
                  setState(() {
                    isLoading = false;
                  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
          context,
          showLeading: false,
        User: widget.firstName +' '+ widget.lastName,
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
                      target: LatLng(0, 0), // Default position
                      zoom: 5,
                    ),
                    markers: Set<Marker>.of(markers),
                    polylines: Set<Polyline>.of(polylines),
                    myLocationEnabled: true,
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
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(FontAwesomeIcons.multiply)),
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 30),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.93,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Center(child: SvgPicture.asset('assets/naqleeBorder.svg',height: 35,)),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 35,left: 8),
                                      child: SvgPicture.asset('assets/person.svg',),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text('SAR ${widget.quotePrice}',style: TextStyle(fontSize: 35 ),)),
                                  ],
                                ),
                                isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8,top: 8,bottom: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              SvgPicture.asset('assets/direction.svg',height: MediaQuery.of(context).size.height * 0.13,),
                                            ],
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('$timeToPickup(${pickUpDistance?.toStringAsFixed(2)}km)away',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 20),
                                                    child: Text(widget.pickUp,style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                                  ),
                                                  if (dropPointsDistance != null && dropPointsDistance!.isNotEmpty) ...[
                                                    ...dropPointsDistance!.map((distance) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 20),
                                                        child: Text(
                                                          '${timeToDrop} (${distance.toStringAsFixed(2)}km) left',
                                                          style: TextStyle(fontSize: 20,color: Color(0xff676565)),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ] else ...[
                                                    Text('', style: TextStyle(fontSize: 20)),
                                                  ],
                                                  Text( widget.dropPoints.join(', '), style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.057,
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xff6069FF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => DriverInteraction(
                                                    firstName: widget.firstName,
                                                    lastName: widget.lastName,
                                                    token: widget.token,
                                                    id: widget.id,
                                                    partnerId: widget.partnerId,
                                                    bookingId: widget.bookingId,
                                                    pickUp: widget.pickUp,
                                                    dropPoints: widget.dropPoints,
                                                    quotePrice: (bookingRequestData?['bookingRequest']['quotePrice'] ?? 0).toString(),
                                                    userId: widget.userId,
                                                  )));
                                            },
                                            child: const Text(
                                              'Accept',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
