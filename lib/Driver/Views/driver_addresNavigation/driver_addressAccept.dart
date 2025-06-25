import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_addresNavigation/driver_addressInteraction.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class AcceptAddressOrder extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String bookingId;
  final String pickUp;
  final String address;
  final String quotePrice;
  final String userId;
  final String partnerId;
  const AcceptAddressOrder({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.bookingId, required this.pickUp, required this.quotePrice, required this.userId, required this.partnerId, required this.address});

  @override
  State<AcceptAddressOrder> createState() => _AcceptAddressOrderState();
}

class _AcceptAddressOrderState extends State<AcceptAddressOrder> {
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
      String pickupPlace = widget.pickUp;

      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      LatLng currentLatLng =
      LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        markers.clear();
        polylines.clear();
      });

      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));

      if (pickupResponse.statusCode == 200) {
        final pickupData = json.decode(pickupResponse.body);

        if (pickupData != null && pickupData['status'] == 'OK') {
          final pickupLocation = pickupData['results']?[0]['geometry']?['location'];
          final pickupAddress = pickupData['results']?[0]['formatted_address'];

          if (pickupLocation != null) {
            LatLng pickupLatLng =
            LatLng(pickupLocation['lat'], pickupLocation['lng']);
            double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng);

            BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(100, 48)),
              'assets/carDirection.png',
            );

            setState(() {
              markers.add(
                Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: currentLatLng,
                    infoWindow: InfoWindow(
                      title: 'Current Location'.tr(),
                      snippet: '${'Distance to Pickup:'.tr()} ${distanceToPickup.toStringAsFixed(2)} km',
                    ),
                    icon: customIcon),
              );

              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point'.tr(),
                    snippet: '$pickupAddress - ${'Distance:'.tr()} ${distanceToPickup.toStringAsFixed(2)} km',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              );
            });
            String directionsUrlFromCurrentToPickup =
                'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng.latitude},${pickupLatLng.longitude}&key=$apiKey';
            final directionsResponseFromCurrentToPickup =
            await http.get(Uri.parse(directionsUrlFromCurrentToPickup));
            if (directionsResponseFromCurrentToPickup.statusCode == 200) {
              final directionsData =
              json.decode(directionsResponseFromCurrentToPickup.body);
              if (directionsData['status'] == 'OK') {
                final polylinePoints =
                directionsData['routes'][0]['overview_polyline']['points'];
                List<LatLng> routePoints = _decodePolyline(polylinePoints);

                setState(() {
                  polylines.add(Polyline(
                    polylineId: const PolylineId('currentToPickup'),
                    color: Colors.blue,
                    width: 5,
                    points: routePoints,
                  ));
                });
                double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng);
                pickUpDistance = distanceToPickup;
                final durationToPickup =
                directionsData['routes'][0]['legs'][0]['duration']['text'];
                timeToPickup = durationToPickup;
                mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(
                        (currentLatLng.latitude + pickupLatLng.latitude) / 2,
                        (currentLatLng.longitude + pickupLatLng.longitude) / 2),
                    10));
              }
            }

            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred. Please try again.');
    }
  }

  double _haversineDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371.0;
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

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
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
                        target: LatLng(0, 0),
                        zoom: 5,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 15),
                                          child: SvgPicture.asset(
                                            'assets/naqleeBorder.svg',
                                            height: viewUtil.isTablet
                                                ? MediaQuery.of(context).size.height * 0.05
                                                : MediaQuery.of(context).size.height * 0.04,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
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
                                      child: CircleAvatar(
                                        radius: viewUtil.isTablet ? 30 : 20,
                                        backgroundColor: Colors.white,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(FontAwesomeIcons.multiply,
                                              size: viewUtil.isTablet ? 30 : 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 35,left: 8),
                                      child: SvgPicture.asset('assets/person.svg',),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text('SAR ${widget.quotePrice}',style: TextStyle(fontSize: viewUtil.isTablet?35:30),)),
                                  ],
                                ),
                                isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: viewUtil.isTablet?20:8,top: 15,bottom: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              SvgPicture.asset('assets/direction.svg',height: MediaQuery.of(context).size.height * 0.100,),
                                            ],
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text('$timeToPickup(${pickUpDistance?.toStringAsFixed(2)}km)${'away'.tr()}',
                                                      style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?26:20)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 45),
                                                    child: Text(widget.pickUp,style: TextStyle(fontSize: viewUtil.isTablet?26:20,color: Color(0xff676565)),),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: Text(widget.address,style: TextStyle(fontSize: viewUtil.isTablet?26:20,color: Color(0xff676565)),),
                                                  ),
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
                                            onPressed: () async {
                                              await saveDriverAddressInteractionData(
                                                bookingId: widget.bookingId,
                                                firstName: widget.firstName,
                                                lastName: widget.lastName,
                                                token: widget.token,
                                                id: widget.id,
                                                partnerId: widget.partnerId,
                                                pickUp: widget.pickUp,
                                                address: widget.address,
                                                quotePrice: widget.quotePrice,
                                                userId: widget.userId,
                                              );
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) => DriverAddressInteraction(
                                                    firstName: widget.firstName,
                                                    lastName: widget.lastName,
                                                    token: widget.token,
                                                    id: widget.id,
                                                    partnerId: widget.partnerId,
                                                    bookingId: widget.bookingId,
                                                    pickUp: widget.pickUp,
                                                    address: widget.address,
                                                    quotePrice: (bookingRequestData?['bookingRequest']['quotePrice'] ?? 0).toString(),
                                                    userId: widget.userId,
                                                  )));
                                            },
                                            child: Text(
                                              'Accept'.tr(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: viewUtil.isTablet?26:18,
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
      ),
    );
  }
}
