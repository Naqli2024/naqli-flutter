import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Viewmodel/driver_services.dart';
import 'package:flutter_naqli/Driver/Views/driver_addresNavigation/driver_addressCompleteOrder.dart';
import 'package:flutter_naqli/Driver/Views/driver_pickupDropNavigation/driver_notified.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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
class DriverAddressInteraction extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String bookingId;
  final String pickUp;
  final String quotePrice;
  final String userId;
  final String partnerId;
  const DriverAddressInteraction({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.bookingId, required this.pickUp, required this.quotePrice, required this.userId, required this.partnerId});

  @override
  State<DriverAddressInteraction> createState() => _DriverAddressInteractionState();
}

class _DriverAddressInteractionState extends State<DriverAddressInteraction> {
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
      checkPickupLocation(); // Call your method whenever a new location is received
    });
  }

  Future<void> fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      setState(() {
        isLoading = true;
      });
      String pickupPlace = widget.pickUp; // Pickup location (city name)

      // Step 1: Get the current location (device's location)
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng =
      LatLng(currentPosition.latitude, currentPosition.longitude);

      setState(() {
        markers.clear();
        polylines.clear();
      });

      // Step 2: Fetch pickup coordinates
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
              const ImageConfiguration(size: Size(100, 48)), // Customize size here
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
                    icon: customIcon),
              );

              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: '$pickupAddress - Distance: ${distanceToPickup.toStringAsFixed(2)} km',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              );
            });

            // Step 3: Fetch route from current location to pickup point
            String directionsUrlFromCurrentToPickup =
                'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng.latitude},${pickupLatLng.longitude}&key=$apiKey';
            final directionsResponseFromCurrentToPickup =
            await http.get(Uri.parse(directionsUrlFromCurrentToPickup));

            // Draw the polyline for current location to pickup point
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

                // Center the map to the route
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

      // Extract points from the route
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
    // Debug log to see the value of distanceInKm
    print('Distance in KM: $distanceInKm');

    // Return "0 ft" if distance is null or 0
    if (distanceInKm == null || distanceInKm <= 0) {
      print('Distance is null or zero, returning 0 ft');
      return '0 ft'; // Ensure "0 ft" is returned when launching or if distance is 0
    }

    // Convert distance from kilometers to feet
    double distanceInFeet = distanceInKm * 3280.84;
    print('Distance in Feet: $distanceInFeet');

    // Convert feet to miles
    double distanceInMiles = distanceInFeet / 5280;

    // Return the distance in feet if less than 1 mile
    if (distanceInMiles < 1) {
      print('Distance is less than 1 mile, returning in feet');
      return '${distanceInFeet.toStringAsFixed(0)} ft';
    } else {
      // Return the distance in miles and remaining feet if greater than or equal to 1 mile
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

      // Update camera position
      await mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 20, // Adjust zoom level as needed
          tilt: 20,
          bearing: heading,
        ),
      ));

      // Check if pickupLatLng is not null
      if (pickupLatLng != null) {
        final LatLng pickUpLocation = LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude);
        List<LatLng> routePoints = await fetchDirections(currentLatLng, pickUpLocation);

        // Draw polyline on the map
        setState(() {
          polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ));
        });

        // Optional: Zoom to fit the route
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
          // mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)); // 50 is the padding
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
    return R * c; // Distance in kilometers
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
    // Example logic to calculate distance in feet
    double distanceInMeters = position.accuracy; // Replace with your distance logic
    return (distanceInMeters * 3.28084).toStringAsFixed(0); // Convert to feet and format
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

    // Request permission from the location package
    location_package.PermissionStatus permission = await location.requestPermission();

    if (permission == location_package.PermissionStatus.granted) {
      location.onLocationChanged.listen((location_package.LocationData newLocation) {
        checkPickupLocation();
        currentLatLng = LatLng(newLocation.latitude!, newLocation.longitude!);
        _updateRealTimeData(currentLatLng);
        // if (pickupLatLng != null && _isNearPickup(currentLatLng!, pickupLatLng!)) {
        //   _calculateAndDisplayRouteFromPickupToDropPoints();
        // }
      });
    } else {
      print('Location permission denied');
    }
  }

  void _initializePickupLocation() async {
    // Log the pickup string
    print('Pickup string: "${widget.pickUp}"');

    // Clean the pickup string by removing whitespace
    String cleanedPickup = widget.pickUp.trim();

    if (cleanedPickup.isNotEmpty) {
      // Call geocoding function to get LatLng
      LatLng? latLng = await getLatLngFromAddress(cleanedPickup);

      if (latLng != null) {
        pickupLatLng = latLng;
        print('Pickup location set to: $pickupLatLng'); // Debugging output
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
    return null; // Return null if something goes wrong
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
        print('pickupLatLng is null');
        return; // Exit early if pickupLatLng is null
      }

      double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng!);
      String updatedFeet = formatDistance(distanceToPickup);

      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, pickupLatLng!);
      await fetchNearbyPlaces(currentLatLng);
      // checkPickupLocation();
      // Fetch travel time and other details from the Google Directions API
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      String directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';
      final directionsResponse = await http.get(Uri.parse(directionsUrl));

      if (directionsResponse.statusCode == 200) {
        final directionsData = json.decode(directionsResponse.body);
        if (directionsData['status'] == 'OK') {
          final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];
          final placeName = directionsData['routes'][0]['legs'][0]['end_address'];

          // Check if the widget is still mounted before calling setState
          if (!mounted) return;

          setState(() {

            print('Current Location: $currentLatLng');
            print('Distance to Pickup: $distanceToPickup');
            print('Feet: $updatedFeet');
            print('Travel Time: $durationToPickup');
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
          rotation: heading,  // Rotate the arrow based on the heading
          anchor: Offset(0.5, 0.5),  // Center the arrow marker
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
    // Check if pickup location exists
    if (pickupLatLng != null) {
      // Calculate the distance to the pickup point
      double distanceToPickup = _haversineDistance(currentLatLng, pickupLatLng!);
      String feet = formatDistance(distanceToPickup);

      // Fetch updated directions from current location to pickup point
      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, pickupLatLng!);

      // Fetch updated travel time from API
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
      String directionsUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(directionsUrl));
      if (response.statusCode == 200) {
        final directionsData = json.decode(response.body);
        if (directionsData['status'] == 'OK') {
          // Extract the duration to pickup location
          final durationToPickup = directionsData['routes'][0]['legs'][0]['duration']['text'];

          // Update the polyline, distance, and time in the UI
          setState(() {
            // Remove the old polyline and add the new one
            polylines.removeWhere((p) => p.polylineId == const PolylineId('currentToPickup'));
            polylines.add(Polyline(
              polylineId: const PolylineId('currentToPickup'),
              color: Colors.blue,
              width: 5,
              points: updatedRoutePoints,
            ));

            // Update distance and time for the user interface
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
          currentIndex = 0; // Reset to the first place when new data is fetched
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

  void checkPickupLocation() async {
    print('Current LatLng: $currentLatLng');
    print('Pickup LatLng: $pickupLatLng');

    // Check if pickup location is available
    if (pickupLatLng == null) {
      print('Pickup location is null, cannot check distance.');
      return;
    }

    // Calculate the distance to pickup in kilometers
    double distanceToPickupInKm = _haversineDistance(currentLatLng, pickupLatLng!);

    // Convert kilometers to feet (1 km = 3280.84 feet)
    double distanceToPickupInFeet = distanceToPickupInKm * 3280.84;

    // Debugging log
    print('Distance to Pickup in Feet: $distanceToPickupInFeet');

    // Check if the distance is less than or equal to 50 feet and hasn't navigated yet
    if (distanceToPickupInFeet <= 111190 && !hasNavigated) {
      hasNavigated = true; // Prevent multiple navigations

      if (mounted) {
        // Stop position stream and navigate to CustomerNotified page
        await positionStream?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddressCompleteOrder(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              partnerId: widget.partnerId,
              bookingId: widget.bookingId,
              pickUp: widget.pickUp,
              quotePrice: widget.quotePrice,
              userName: firstName != null
                  ? '$firstName'
                  : '' + '${lastName != null ? '$lastName' : ''}',
            ),
          ),
        );

        print('Navigating to AddressCompleteOrder');
      }
    } else {
      print('Current location is more than 50 feet from pickup location or already navigated.');
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
      print('Error fetching user name: $e');
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
                      zoom: 2,
                    ),
                    markers: Set<Marker>.of(markers),
                    polylines: Set<Polyline>.of(polylines),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: true,
                    // buildingsEnabled: true,
                    // rotateGesturesEnabled: true,
                    // zoomControlsEnabled: true,
                    // zoomGesturesEnabled: true,
                    // scrollGesturesEnabled: true,
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
                  top: MediaQuery.sizeOf(context).height * 0.1,
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
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
                                          feet == null?'0 ft':'$feet', // Ensure this is updated dynamically
                                          style: TextStyle(fontSize: 20, color: Color(0xff676565)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded( // Wrap in Expanded to avoid overflow
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(nearbyPlaces[currentIndex]['name'] ?? ''),
                                        Text('Towards', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(nearbyPlaces[currentIndex]['address'] ?? '', textAlign: TextAlign.center),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.location_on,
                                  color: Color(0xff6069FF),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(nearbyPlaces[currentIndex]['address'] ?? 'Xxxxxxxxx', textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : Center(child: CircularProgressIndicator()),
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
                                      Padding(
                                        padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.18),
                                        child: SvgPicture.asset('assets/person.svg'),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          firstName != null
                                              ? '$firstName'
                                              : '' + '${lastName != null ? '$lastName' : ''}',
                                          style: TextStyle(fontSize: 24, color: Color(0xff676565)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Show updated distance and time
                                Text(
                                  timeToPickup ==null ?'Calculating...':'$timeToPickup (${pickUpDistance?.toStringAsFixed(2)} km)',
                                  style: TextStyle(fontSize: 17, color: Color(0xff676565)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(Icons.call, color: Color(0xff6069FF)),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text('Call', style: TextStyle(fontSize: 17, color: Color(0xff676565))),
                                      ),
                                      Icon(Icons.message, color: Color(0xff6069FF)),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text('Message', style: TextStyle(fontSize: 17, color: Color(0xff676565))),
                                      ),
                                      Icon(FontAwesomeIcons.multiply, color: Color(0xff6069FF)),
                                      Text('Cancel', style: TextStyle(fontSize: 17, color: Color(0xff676565))),
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
    );
  }
}
