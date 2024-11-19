import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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

class _AddressCompleteOrderState extends State<AddressCompleteOrder> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final DriverService driverService = DriverService();
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropPointLatLng;
  final List<LatLng> dropLatLngs = [];
  String? distance;
  LatLng? currentLocation;
  double pickUpDistance = 0;
  List<double> dropPointsDistance = [];
  bool isLoading = true;
  bool isCompleting = false;
  String? timeToPickup;
  String? timeToDrop;
  String ? feet;
  LatLng currentLatLng = LatLng(37.7749, -122.4194);
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

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
    _initializePickupLocation();
    startLocationUpdates();
    loadCustomArrowIcon();
    _initLocationListener();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude); // Update current location
      });
    });
  }

  Future<void> fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      setState(() {
        isLoading = true;
      });
      String pickupPlace = widget.pickUp;
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
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
                    title: 'Drop Point'.tr(),
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
                // Extract travel time
                final durationToPickup =
                directionsData['routes'][0]['legs'][0]['duration']['text'];
                timeToPickup = durationToPickup;
                print('Travel time to Pickup: $durationToPickup');

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
      print('Error fetching coordinates: $e');
    }
  }

  Future<List<LatLng>> fetchDirections(LatLng start, LatLng destination) async {
    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    final String url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${start.latitude},${start.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> points = [];

      if (data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        points = _decodePolyline(polylinePoints);
      }
      return points;
    } else {
      throw Exception('Failed to fetch directions');
    }
  }

  String formatDistance(double? distanceInKm) {
    print('Distance in KM: $distanceInKm');
    if (distanceInKm == null || distanceInKm <= 0) {
      print('Distance is null or zero, returning 0 ft');
      return '0 ft';
    }
    double distanceInFeet = distanceInKm * 3280.84;
    print('Distance in Feet: $distanceInFeet');

    double distanceInMiles = distanceInFeet / 5280;

    if (distanceInMiles < 1) {
      print('Distance is less than 1 mile, returning in feet');
      return '${distanceInFeet.toStringAsFixed(0)} ft';
    } else {
      int miles = distanceInMiles.floor();
      double remainingFeet = distanceInFeet - (miles * 5280);
      print('Distance is more than 1 mile, returning in miles and feet');
      return '${miles} mi ${remainingFeet.toStringAsFixed(0)} ft';
    }
  }

  Future<void> recenterMap() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
      double heading = currentPosition.heading;

      await mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 20,
          tilt: 20,
          bearing: heading,
        ),
      ));

      if (pickupLatLng != null) {
        final LatLng pickUpLocation = LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude);
        List<LatLng> routePoints = await fetchDirections(currentLatLng, pickUpLocation);

        setState(() {
          polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ));
        });

        if (routePoints.isNotEmpty) {
          LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(
              routePoints.map((point) => point.latitude).reduce((a, b) => a < b ? a : b),
              routePoints.map((point) => point.longitude).reduce((a, b) => a < b ? a : b),
            ),
            northeast: LatLng(
              routePoints.map((point) => point.latitude).reduce((a, b) => a > b ? a : b),
              routePoints.map((point) => point.longitude).reduce((a, b) => a > b ? a : b),
            ),
          );
        }
      } else {
        print("Pickup location is not available.");
      }
    } catch (e) {
      print('Error recentering map: $e');
    }
  }

  double _haversineDistance(LatLng start, LatLng end) {
    const double R = 6371; // Radius of the Earth in kilometers
    double dLat = _degToRad(end.latitude - start.latitude);
    double dLon = _degToRad(end.longitude - start.longitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_degToRad(start.latitude)) * cos(_degToRad(end.latitude)) *
                sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
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

  String calculateFeet(Position position) {
    double distanceInMeters = position.accuracy;
    return (distanceInMeters * 3.28084).toStringAsFixed(0);
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    positionStream.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> loadCustomArrowIcon() async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/arrow.png', 140);
    customArrowIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void _initLocationListener() async {
    location_package.Location location = location_package.Location();
    location_package.PermissionStatus permission = await location.requestPermission();

    if (permission == location_package.PermissionStatus.granted) {
      location.onLocationChanged.listen((location_package.LocationData newLocation) {
        currentLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);
        _updateRealTimeData(currentLatLng);
      });
    } else {
      print('Location permission denied');
    }
  }

  void _initializePickupLocation() async {
    print('Pickup string: "${widget.pickUp}"');

    String cleanedPickup = widget.pickUp.trim();

    if (cleanedPickup.isNotEmpty) {
      LatLng? latLng = await getLatLngFromAddress(cleanedPickup);

      if (latLng != null) {
        pickupLatLng = latLng;
        print('Pickup location set to: $pickupLatLng');
      } else {
        print('Could not get coordinates for the pickup location');
      }
    } else {
      print('Pickup location string is empty');
    }
  }

  Future<LatLng?> getLatLngFromAddress(String address) async {
    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        double lat = data['results'][0]['geometry']['location']['lat'];
        double lng = data['results'][0]['geometry']['location']['lng'];
        return LatLng(lat, lng);
      } else {
        print('Error fetching geocode: ${data['status']}');
      }
    } else {
      print('Error fetching geocode: ${response.statusCode}');
    }
    return null;
  }

  Future<void> startLocationUpdates() async {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) async {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      print('newLocation: $newLocation');

      if (newLocation != currentLatLng) {
        await fetchNearbyPlaces(newLocation);
        await _updateRealTimeData(newLocation);
        print('newLocationnn: $newLocation');
        setState(() {
          currentLatLng = newLocation;
          markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));
          markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: newLocation,
            infoWindow: InfoWindow(
              title: 'Current Location'.tr(),
            ),
            icon: customArrowIcon!,
          ));
        });
        updateCameraPosition(newLocation);
        updateLocationMarker(newLocation, position.heading);
        await updateRouteDetails(newLocation);
      }
    });
  }

  Future<void> _updateRealTimeData(LatLng currentLatLng) async {
    try {
      if (pickupLatLng == null) {
        print('pickupLatLng is null');
        return;
      }

      double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng!);
      String updatedFeet = formatDistance(distanceToPickup);
      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, pickupLatLng!);
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      String reverseGeocodeUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng.latitude},${currentLatLng.longitude}&key=$apiKey';
      final reverseGeocodeResponse = await http.get(Uri.parse(reverseGeocodeUrl));

      String currentLocationName = 'Unknown Location';

      if (reverseGeocodeResponse.statusCode == 200) {
        final reverseGeocodeData = json.decode(reverseGeocodeResponse.body);

        if (reverseGeocodeData['status'] == 'OK') {
          final currentAddress = reverseGeocodeData['results']?[0]['formatted_address'];
          currentPlace = currentAddress;
          if (currentAddress != null) {
            currentLocationName = currentAddress;
            print('Current Location Name: $currentLocationName');
          }
        }
      }
      String directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';
      final directionsResponse = await http.get(Uri.parse(directionsUrl));

      if (directionsResponse.statusCode == 200) {
        final directionsData = json.decode(directionsResponse.body);
        if (directionsData['status'] == 'OK') {
          final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];
          final placeName = directionsData['routes'][0]['legs'][0]['end_address'];

          if (!mounted) return;

          setState(() {
            pickUpDistance = distanceToPickup;
            timeToPickup = durationToPickup;
            feet = updatedFeet;
            polylines.clear();
            polylines.add(Polyline(
              polylineId: const PolylineId('currentToPickup'),
              color: Colors.blue,
              width: 5,
              points: updatedRoutePoints,
            ));
            markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));
            markers.add(Marker(
              markerId: const MarkerId('currentLocation'),
              position: currentLatLng,
              infoWindow: InfoWindow(
                title: placeName,
                snippet: '${'Distance to Pickup:'.tr()} ${distanceToPickup.toStringAsFixed(2)} km\nFeet: $feet\nTime: $timeToPickup',
              ),
              icon: customArrowIcon!,
            ));

            mapController?.animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  currentLatLng.latitude < pickupLatLng!.latitude ? currentLatLng.latitude : pickupLatLng!.latitude,
                  currentLatLng.longitude < pickupLatLng!.longitude ? currentLatLng.longitude : pickupLatLng!.longitude,
                ),
                northeast: LatLng(
                  currentLatLng.latitude > pickupLatLng!.latitude ? currentLatLng.latitude : pickupLatLng!.latitude,
                  currentLatLng.longitude > pickupLatLng!.longitude ? currentLatLng.longitude : pickupLatLng!.longitude,
                ),
              ),
              100.0,
            ));
          });
        }
      }
    } catch (e) {
      print('Error updating real-time data: $e');
    }
  }


  void updateLocationMarker(LatLng position, double heading) {
    if (mapController != null && customArrowIcon != null) {
      setState(() {
        currentLocationMarker = Marker(
          markerId: MarkerId('current_location'),
          position: position,
          icon: customArrowIcon!,
          rotation: heading,
          anchor: Offset(0.5, 0.5),
        );
      });
    }
  }

  void updateCameraPosition(LatLng currentLatLng) {
    mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLatLng),
    );
  }

  Future<void> updateRouteDetails(LatLng currentLatLng) async {
    if (pickupLatLng != null) {
      double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng!);
      String feet = formatDistance(distanceToPickup);
      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, pickupLatLng!);
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      String directionsUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(directionsUrl));
      if (response.statusCode == 200) {
        final directionsData = json.decode(response.body);
        if (directionsData['status'] == 'OK') {
          final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];
          setState(() {
            polylines.removeWhere((p) => p.polylineId == const PolylineId('currentToPickup'));
            polylines.add(Polyline(
              polylineId: const PolylineId('currentToPickup'),
              color: Colors.blue,
              width: 5,
              points: updatedRoutePoints,
            ));
            pickUpDistance = distanceToPickup;
            timeToPickup = durationToPickup;
            feet = formatDistance(distanceToPickup);
          });

        }
      }
    }
  }

  Future<void> fetchNearbyPlaces(LatLng currentLatLng) async {
    setState(() {
      isLoading = true;
    });

    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String nearbyPlacesUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentLatLng.latitude},${currentLatLng.longitude}&radius=1500&type=restaurant&key=$apiKey';

    final response = await http.get(Uri.parse(nearbyPlacesUrl));

    if (response.statusCode == 200) {
      final nearbyPlacesData = json.decode(response.body);

      setState(() {
        nearbyPlaces = []; // Clear previous places
      });

      if (nearbyPlacesData['status'] == 'OK') {
        print('near$nearbyPlacesData');
        for (var place in nearbyPlacesData['results']) {
          nearbyPlaces.add({
            'name': place['name'],
            'address': place['vicinity'],
          });
        }
        setState(() {
          currentIndex = 0;
        });
      } else {
        print('Error fetching places: ${nearbyPlacesData['status']}');
      }
    } else {
      print('Failed to load nearby places, status code: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
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


  @override
  Widget build(BuildContext context) {
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
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                    onPressed: (){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverHomePage(
                                          firstName: widget.firstName,
                                          lastName: widget.lastName,
                                          token: widget.token,
                                          id: widget.id,
                                          partnerId: widget.partnerId,
                                          mode: 'online')));
                                    },
                                    icon: Icon(FontAwesomeIcons.multiply)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                      top: MediaQuery.sizeOf(context).height * 0.1,
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
                                                style: TextStyle(fontSize: 16,color: Color(0xff676565))),
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
                      bottom: 20,
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
                                          style: TextStyle(fontSize: 20, color: Color(0xff676565)),
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
                                          style: TextStyle(fontSize: 20, color: Color(0xff676565)),
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
                                      style: TextStyle(fontSize: 20, color: Color(0xff676565)),
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
                                        ),
                                        innerColor: Color(0xff6069FF),
                                        outerColor: Color(0xff6069FF),
                                        sliderButtonIcon: Icon(
                                          Icons.arrow_forward_outlined,
                                          color: Colors.white,
                                        ),
                                        text: "Complete Order".tr(),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onSubmit: () async{
                                          setState(() {
                                            isCompleting =true;
                                          });
                                          await driverService.driverCompleteOrder(context, bookingId: widget.bookingId, status: completeOrder, token: widget.token);
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverHomePage(
                                              firstName: widget.firstName,
                                              lastName: widget.lastName,
                                              token: widget.token,
                                              id: widget.id,
                                              partnerId: widget.partnerId,
                                              mode: 'online')));
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
