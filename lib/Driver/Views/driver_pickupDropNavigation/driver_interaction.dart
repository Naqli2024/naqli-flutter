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
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_notified.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart' as location_package;
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';
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
  bool isLoading = true;
  bool isCalculating = false;
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

  @override
  void initState() {
    super.initState();
      fetchCoordinates();
    fetchUserName();
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
      checkPickupLocation();
    });
  }

  Future<void> fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      setState(() {
        isCalculating = true;
      });
      String pickupPlace = widget.pickUp;
      List dropPlaces = widget.dropPoints;
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        markers.clear();
        polylines.clear();
        dropLatLngs.clear();
      });

      String pickupUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));
      List<Future<http.Response>> dropResponses = dropPlaces.map((dropPlace) {
        String dropUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlace)}&key=$apiKey';
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
            setState(() {
                markers.add(Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: currentLatLng,
                    infoWindow: InfoWindow(
                      title: 'Current Location'.tr(),
                      snippet: '${'Distance to Pickup:'.tr()} ${distanceToPickup.toStringAsFixed(2)} km',
                    ),
                    icon:customArrowIcon!
                ));

              markers.add(Marker(
                markerId: const MarkerId('pickup'),
                position: pickupLatLng,
                infoWindow: InfoWindow(
                  title: 'Pickup Point'.tr(),
                  snippet: '$pickupAddress - Distance: ${distanceToPickup.toStringAsFixed(2)} km',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ));
            });
            String directionsUrlFromCurrentToPickup =
                'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng.latitude},${pickupLatLng.longitude}&key=$apiKey';
            final directionsResponseFromCurrentToPickup = await http.get(Uri.parse(directionsUrlFromCurrentToPickup));
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
                mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 12));
                final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];

                setState(() {
                  // pickUpDistance = distanceToPickup;
                  // feet = formatDistance(distanceToPickup);
                  // timeToPickup = durationToPickup;
                });
              }
            }
            if (dropLatLngs.isNotEmpty) {
              String waypointsString = dropLatLngs.map((latLng) => '${latLng.latitude},${latLng.longitude}').join('|');
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
                  LatLngBounds bounds = LatLngBounds(
                    southwest: LatLng(
                      currentLatLng.latitude < pickupLatLng.latitude ? currentLatLng.latitude : pickupLatLng.latitude,
                      currentLatLng.longitude < pickupLatLng.longitude ? currentLatLng.longitude : pickupLatLng.longitude,
                    ),
                    northeast: LatLng(
                      currentLatLng.latitude > pickupLatLng.latitude ? currentLatLng.latitude : pickupLatLng.latitude,
                      currentLatLng.longitude > pickupLatLng.longitude ? currentLatLng.longitude : pickupLatLng.longitude,
                    ),
                  );
                  mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                  final durationFromPickupToDrop = directionsData['routes'][0]['legs'][0]['duration']['text'];
                  timeToDrop = durationFromPickupToDrop;
                  setState(() {
                    isCalculating = false;
                  });
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            }
          }
        } else {
         return;
        }
      } else {
       return;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
    if (distanceInKm == null || distanceInKm <= 0) {
      return '0 ft';
    }
    double distanceInFeet = distanceInKm * 3280.84;
    double distanceInMiles = distanceInFeet / 5280;
    if (distanceInMiles < 1) {
      return '${distanceInFeet.toStringAsFixed(0)} ft';
    } else {
      int miles = distanceInMiles.floor();
      double remainingFeet = distanceInFeet - (miles * 5280);
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
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  double _haversineDistance(LatLng start, LatLng end) {
    const double R = 6371;
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
        checkPickupLocation();
        currentLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);
        _updateRealTimeData(currentLatLng);
      });
    } else {
      return;
    }
  }

  void _initializePickupLocation() async {
    String cleanedPickup = widget.pickUp.trim();

    if (cleanedPickup.isNotEmpty) {
      LatLng? latLng = await getLatLngFromAddress(cleanedPickup);

      if (latLng != null) {
        pickupLatLng = latLng;
      } else {
        return;
      }
    } else {
      return;
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

      }
    } else {

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
      if (newLocation != currentLatLng) {
        await fetchNearbyPlaces(newLocation);
        await _updateRealTimeData(newLocation);
        setState(() {
          currentLatLng = newLocation;
          markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));
          markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: newLocation,
            infoWindow: const InfoWindow(
              title: 'Current Location',
            ),
            icon: customArrowIcon!,
          ));
        });
        checkPickupLocation();
        updateCameraPosition(newLocation);
        updateLocationMarker(newLocation, position.heading);
        await updateRouteDetails(newLocation);
      }
    });
  }

  Future<void> _updateRealTimeData(LatLng currentLatLng) async {
    try {
      if (pickupLatLng == null) {
        return;
      }

      double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng!);
      String updatedFeet = formatDistance(distanceToPickup);

      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, pickupLatLng!);
      await fetchNearbyPlaces(currentLatLng);
      // checkPickupLocation();
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
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

            markers.removeWhere((m) => m.markerId == MarkerId('currentLocation'));
            markers.add(Marker(
              markerId: const MarkerId('currentLocation'),
              position: currentLatLng,
              infoWindow: InfoWindow(
                title: placeName,
                snippet: 'Distance to Pickup: ${distanceToPickup.toStringAsFixed(2)} km\nFeet: $feet\nTime: $timeToPickup',
              ),
              icon: customArrowIcon!,
            ));

          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
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
        nearbyPlaces = [];
      });

      if (nearbyPlacesData['status'] == 'OK') {
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

      }
    } else {

    }

    setState(() {
      isLoading = false;
    });
  }

  void checkPickupLocation() async {
    if (pickupLatLng == null) {
      return;
    }

    double distanceToPickupInKm = _haversineDistance(currentLatLng, pickupLatLng!);

    // Convert kilometers to feet (1 km = 3280.84 feet)
    double distanceToPickupInFeet = distanceToPickupInKm * 3280.84;
    // Check if the distance is less than or equal to 50 feet and hasn't navigated yet
    if (distanceToPickupInFeet <= 50 && !hasNavigated) {
      hasNavigated = true; // Prevent multiple navigations

      if (mounted) {
        setState(() {
          isAtPickupLocation = true;
        });

        await positionStream?.cancel();
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
              userName: firstName != null
                  ? '$firstName'
                  : '' + '${lastName != null ? '$lastName' : ''}',
            ),
          ),
        );
      }
    } else {

    }
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


  Future<void> fetchUserName() async {
    try {
      final fetchedFirstName = await driverService.getUserName(widget.userId, widget.token);
      setState(() {
        firstName = fetchedFirstName;
        lastName = fetchedFirstName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
                        zoom: 2,
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
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(FontAwesomeIcons.multiply,
                                        size: viewUtil.isTablet?30:20)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                    top: MediaQuery.sizeOf(context).height * 0.1,
                    left: viewUtil.isTablet
                        ? MediaQuery.sizeOf(context).height * 0.027
                        : MediaQuery.sizeOf(context).height * 0.017,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.92,
                      child: Card(
                        color: Colors.white,
                        child: nearbyPlaces.isNotEmpty
                            ? Column(
                          children: [
                            if (nearbyPlaces.isNotEmpty && currentIndex < nearbyPlaces.length)
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
                                            style: TextStyle(fontSize: viewUtil.isTablet?26:16, color: Color(0xff676565)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(nearbyPlaces[currentIndex]['name'] ?? '',
                                            style: TextStyle(fontSize: viewUtil.isTablet?26:16),),
                                          Text('Towards'.tr(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?26:16)),
                                          Text(nearbyPlaces[currentIndex]['address'] ?? '', textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Divider(
                              indent: 15,
                              endIndent: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Color(0xff6069FF),
                                      size: viewUtil.isTablet?30:20
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Text(nearbyPlaces[currentIndex]['address'] ?? 'Xxxxxxxxx', textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
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
                                child: Text('Fetching nearby Location...',
                                    style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.sizeOf(context).height * 0.27,
                    child: GestureDetector(
                      onTap: recenterMap,
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
                                  SvgPicture.asset('assets/person.svg'),
                                  Spacer(),
                                  Expanded(
                                    child: Text(
                                      firstName != null
                                          ? '$firstName'
                                          : '' + '${lastName != null ? '$lastName' : ''}',
                                      style: TextStyle(fontSize: viewUtil.isTablet?26:24, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            // Show updated distance and time
                            Text(
                                timeToPickup ==null ?'Calculating...'.tr():'$timeToPickup (${pickUpDistance?.toStringAsFixed(2)} km)',
                              style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Color(0xff676565)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.call, color: Color(0xff6069FF),size: viewUtil.isTablet?30:20),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text('Call'.tr(), style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Color(0xff676565))),
                                  ),
                                  Icon(Icons.message, color: Color(0xff6069FF),size: viewUtil.isTablet?30:20),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text('Message'.tr(), style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Color(0xff676565))),
                                  ),
                                  Icon(FontAwesomeIcons.multiply, color: Color(0xff6069FF),size: viewUtil.isTablet?30:20),
                                  Text('Cancel'.tr(), style: TextStyle(fontSize: viewUtil.isTablet?26:17, color: Color(0xff676565))),
                                ],
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
