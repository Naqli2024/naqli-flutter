import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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

import 'package:slide_to_act/slide_to_act.dart';

class CustomerNotified extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String bookingId;
  final String pickUp;
  final List dropPoints;
  final String quotePrice;
  final String userName;
  final String partnerId;
  final String contactNo;
  const CustomerNotified({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.bookingId, required this.pickUp, required this.dropPoints, required this.quotePrice, required this.userName, required this.partnerId, required this.contactNo});

  @override
  State<CustomerNotified> createState() => _CustomerNotifiedState();
}

class _CustomerNotifiedState extends State<CustomerNotified> with SingleTickerProviderStateMixin{
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
  double? pickUpDistance;
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
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initLocationListener();
    startLocationUpdatesForDropPoints();
    loadCustomArrowIcon();
    _startLocationUpdates();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startLocationUpdates() {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void startLocationUpdatesForDropPoints() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
      timeLimit: Duration(milliseconds: 200),
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      double heading = position.heading;

      if (mounted) {
        updateLocationMarker(newLocation, heading);

        if (currentLatLng == null || _haversineDistance(currentLatLng!, newLocation) > 50) {
          updateCameraPosition(newLocation, heading);
        }

        if (currentLatLng != null && _haversineDistance(currentLatLng!, newLocation) < 5) {
          animateMarkerMovement(currentLatLng!, newLocation);
        }

        setState(() {
          currentLatLng = newLocation;
        });

        await updateRouteDetails(newLocation);
      }
    });
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

  Future<void> _updateRealTimeDataToDropPoints(LatLng currentLatLng) async {
    try {
      for (int i = 0; i < widget.dropPoints.length; i++) {
        final dropPoint = widget.dropPoints[i];
        LatLng? dropLatLng;

        if (dropPoint is Map && dropPoint.containsKey('latitude') && dropPoint.containsKey('longitude')) {
          dropLatLng = LatLng(dropPoint['latitude'], dropPoint['longitude']);
        } else if (dropPoint is String) {
          dropLatLng = await getLatLngFromAddress(dropPoint);
        }
        dropPointLatLng = dropLatLng;
        if (dropLatLng == null) continue;

        double distanceToDrop = _haversineDistance(currentLatLng, dropLatLng);
        String updatedFeet = formatDistance(distanceToDrop);
        List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, dropLatLng);
        await fetchNearbyPlaces(currentLatLng);

        String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

        String reverseGeocodeUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentLatLng.latitude},${currentLatLng.longitude}&key=$apiKey';
        final reverseGeocodeResponse = await http.get(Uri.parse(reverseGeocodeUrl));

        String currentLocationName = 'Unknown Location'; // Default value

        if (reverseGeocodeResponse.statusCode == 200) {
          final reverseGeocodeData = json.decode(reverseGeocodeResponse.body);

          if (reverseGeocodeData['status'] == 'OK') {
            final currentAddress = reverseGeocodeData['results']?[0]['formatted_address'];
            currentPlace = currentAddress;
            if (currentAddress != null) {
              currentLocationName = currentAddress;
            }
          }
        }
        String directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${dropLatLng.latitude},${dropLatLng.longitude}&key=$apiKey';
        final directionsResponse = await http.get(Uri.parse(directionsUrl));

        if (directionsResponse.statusCode == 200) {
          final directionsData = json.decode(directionsResponse.body);
          if (directionsData['status'] == 'OK') {
            final durationToDrop = directionsData['routes'][0]['legs'][0]['duration']['text'];
            final placeName = directionsData['routes'][0]['legs'][0]['end_address'];
            if (mounted) {
              setState(() {
                dropPointsDistance.add(distanceToDrop);
                dropPointsDistance = [distanceToDrop];
                timeToDrop = durationToDrop;
                feet = updatedFeet;

                polylines.clear();
                polylines.add(Polyline(
                  polylineId: PolylineId('currentToDrop$i'),
                  color: Colors.green,
                  width: 10,
                  points: updatedRoutePoints,
                ));

                markers.add(Marker(
                  markerId: MarkerId('dropPoint$i'),
                  position: dropLatLng!,
                  infoWindow: InfoWindow(
                    title: placeName,
                    snippet: '${'Distance:'} ${distanceToDrop.toStringAsFixed(2)} km\nFeet: $updatedFeet\nTime: $durationToDrop',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ));
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred. Please try again.')));
    }
  }

  void _initLocationListener() async {
    location_package.Location location = location_package.Location();
    location_package.PermissionStatus permission = await location.requestPermission();

    if (permission == location_package.PermissionStatus.granted) {
      location.onLocationChanged.listen((location_package.LocationData newLocation) {
        LatLng updatedLocation = LatLng(newLocation.latitude!, newLocation.longitude!);

        if (currentLatLng != null) {
          animateMarkerMovement(currentLatLng, updatedLocation);
        }

        setState(() {
          currentLatLng = updatedLocation;
        });

        _updateRealTimeDataToDropPoints(currentLatLng);
        checkDropLocation();
      });
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

  void updateLocationMarker(LatLng newPosition, double heading) {
    if (mapController != null && customArrowIcon != null) {
      setState(() {
        markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));

        markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPosition,
          icon: customArrowIcon!,
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
        ));
      });

      updateCameraPosition(newPosition, heading);
    }
  }

  void animateMarkerMovement(LatLng oldPos, LatLng newPos) {
    const int animationDuration = 100;
    const int framesPerSecond = 30;
    int frame = 0;

    Timer.periodic(Duration(milliseconds: animationDuration ~/ framesPerSecond), (timer) {
      frame++;
      double lat = oldPos.latitude + (newPos.latitude - oldPos.latitude) * (frame / framesPerSecond);
      double lng = oldPos.longitude + (newPos.longitude - oldPos.longitude) * (frame / framesPerSecond);

      setState(() {
        currentLatLng = LatLng(lat, lng);
      });

      if (frame >= framesPerSecond) {
        timer.cancel();
      }
    });
  }


  void updateCameraPosition(LatLng newLocation, double bearing) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: 18.0,
          tilt: 20.0,
          bearing: bearing,
        ),
      ),
    );
  }

  Future<void> updateRouteDetails(LatLng currentLatLng) async {
    if (dropPointLatLng != null) {
      List<LatLng> updatedRoutePoints = await fetchDirections(currentLatLng, dropPointLatLng!);

      if (mounted) {
        setState(() {
          polylines.clear();
          polylines.add(Polyline(
            polylineId: const PolylineId('currentToDrop'),
            color: Colors.green,
            width: 10,
            points: updatedRoutePoints,
          ));
        });
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

  String formatDistance(double distanceInKm) {
    double distanceInFeet = distanceInKm * 3280.84;
    double distanceInMiles = distanceInFeet / 5280;

    if (distanceInMiles < 1) {
      return '${distanceInFeet.toStringAsFixed(0)} ft';
    } else {
      int miles = distanceInMiles.floor(); // Whole miles
      double remainingFeet = distanceInFeet - (miles * 5280);
      return '${miles} mi ${remainingFeet.toStringAsFixed(0)} ft';
    }
  }

  Future<void> recenterMap() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng newLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
      double heading = currentPosition.heading;

      if (mounted) {
        if (currentLatLng != null) {
          animateMarkerMovement(currentLatLng, newLatLng);
        }

        setState(() {
          currentLatLng = newLatLng;
        });

        markers.removeWhere((m) => m.markerId == const MarkerId('currentLocation'));
        markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: newLatLng,
          icon: customArrowIcon ?? BitmapDescriptor.defaultMarker,
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
        ));
      }

      updateCameraPosition(newLatLng, heading);
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

  double formattedDistance(double distanceInMeters) {
    return distanceInMeters * 3.28084;
  }

  void checkDropLocation() async {
    double distanceToDropInKm = _haversineDistance(currentLatLng, dropPointLatLng!);
    // 1 kilometer = 0.621371 miles
    // 1 mile = 5280 feet
    // Therefore, 1 kilometer = 3280.84 feet
    // Convert kilometers to feet (1 km = 3280.84 feet)
    double distanceInFeet = distanceToDropInKm * 3280.84;
    print(distanceInFeet);
    if (distanceInFeet <= 100 && !hasNavigated) {
      hasNavigated = true;

      if (mounted) {
        setState(() {
          isAtDropLocation = true;
        });

      }
    } else {

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
        body: isCompleting
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                      buildingsEnabled: false,
                      markers: Set<Marker>.of(markers),
                      polylines: Set<Polyline>.of(polylines),
                      compassEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: true,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                        ),
                      },
                    ),),
                  Positioned(
                    top: MediaQuery.sizeOf(context).height * 0.02,
                    child: isAtDropLocation
                      ? Container(
                      margin: EdgeInsets.only(left: 20),
                      width: MediaQuery.sizeOf(context).width * 0.92,
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
                                        Icon(Icons.location_on,color: Color(0xff6069FF),size: viewUtil.isTablet?30:20),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(currentPlace,textAlign: TextAlign.start,style: TextStyle(fontSize: viewUtil.isTablet?26:16,color: Color(0xff676565))),
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
                      : Container(
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
                                            feet == null?'0 ft':'$feet',
                                            style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?26:18, color: Color(0xff676565)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded( // Wrap in Expanded to avoid overflow
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("DropPoint Location".tr(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?26:16)),
                                          Text(widget.dropPoints.join(', '),textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                                          /***Commented for removing Nearby location***/
                                         /* Text(nearbyPlaces[currentIndex]['name'] ?? '',
                                            style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                                          Text('Towards'.tr(), style: TextStyle(fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?26:16)),
                                          Text(nearbyPlaces[currentIndex]['address'] ?? 'Xxxxxxxxx', textAlign: TextAlign.center,
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
                                child: Text('Fetching DropPoint Location...'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ),
                  Visibility(
                    visible: isAtDropLocation,
                    child: Positioned(
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
                                          timeToDrop ?? '',
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
                                          dropPointsDistance.isNotEmpty
                                              ? '${dropPointsDistance[0].toStringAsFixed(2)} km'
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
                                              offset: Offset(_animation.value, 0),
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
                      ),
                    ),
                  ),
                  if (!isAtDropLocation)...[
                  Visibility(
          visible: !isMoveClicked,
          replacement: Positioned(
              bottom: MediaQuery.sizeOf(context).height * 0.3,
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
              )),
          child: Positioned(
            bottom: MediaQuery.sizeOf(context).height * 0.27,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMoveClicked = true;
                });
                recenterMap();
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
                    minRadius: viewUtil.isTablet ? 55 : 40,
                    backgroundColor: Color(0xff6069FF),
                    child: Text(
                      'Move'.tr(),
                      style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet ? 26 : 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
                  Visibility(
                    visible: isMoveClicked,
                    replacement: Positioned(
                      bottom: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 30),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.93,
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Notify Customer'.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 24, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.userName,
                                      style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 24, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        commonWidgets.makePhoneCall(widget.contactNo);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.call, color: Color(0xff6069FF), size: viewUtil.isTablet ? 30 : 20),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Call'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 17, color: Color(0xff676565))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    child: Positioned(
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
                                          timeToDrop == null ? 'Calculating...'.tr() : timeToDrop ?? '',
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 20, color: Color(0xff676565)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset('assets/person.svg'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          dropPointsDistance.isNotEmpty ? '${dropPointsDistance[0].toStringAsFixed(2)} km' : 'Calculating...'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 20, color: Color(0xff676565)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      'Dropping of Product'.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 20, color: Color(0xff676565)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        commonWidgets.makePhoneCall(widget.contactNo);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.call, color: Color(0xff6069FF), size: viewUtil.isTablet ? 30 : 20),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Call'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 26 : 17, color: Color(0xff676565))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
    ]
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
