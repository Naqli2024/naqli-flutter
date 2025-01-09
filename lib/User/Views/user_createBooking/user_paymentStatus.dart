import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:ui' as ui;

class NewBooking extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  final String email;
  const NewBooking(
      {super.key,
      required this.token,
      required this.firstName,
      required this.lastName,
      required this.id, required this.email});

  @override
  State<NewBooking> createState() => _NewBookingState();
}

final CommonWidgets commonWidgets = CommonWidgets();
final UserService userService = UserService();

class _NewBookingState extends State<NewBooking> {

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
          userId: widget.id,
        ),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const CircleAvatar(child: Icon(FontAwesomeIcons.multiply,size: 20,))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.sizeOf(context).height * 0.17),
                  child: SvgPicture.asset('assets/createBooking.svg',
                      height: MediaQuery.sizeOf(context).height * 0.2),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  child: Text(
                    "${"Looks like you don't have any booking".tr()}\n${'yet. Start by creating your New booking'.tr()}",
                    style: TextStyle(fontSize: viewUtil.isTablet ? 22 :16, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6A66D1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserType(
                                  token: widget.token,
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  id: widget.id,email: widget.email,)),
                        );
                      },
                      child: Text(
                        'createBooking'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet ? 24 :17,
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
      ),
    );
  }
}

class PaymentCompleted extends StatefulWidget {
  final String bookingId;
  final String unit;
  final String unitType;
  final String unitTypeName;
  final String load;
  final String size;
  final String pickup;
  final List dropPoints;
  final String cityName;
  final String address;
  final String zipCode;
  final String token;
  final String firstName;
  final String lastName;
  final String selectedType;
  final String id;
  final String email;
  final String partnerId;
  final String bookingStatus;
  const PaymentCompleted(
      {super.key,
      required this.bookingId,
      required this.unit,
      required this.unitType,
      required this.unitTypeName,
      required this.load,
      required this.size,
      required this.pickup,
      required this.dropPoints,
      required this.cityName,
      required this.address,
      required this.zipCode,
      required this.token,
      required this.firstName,
      required this.lastName,
      required this.selectedType,
      required this.id,
      required this.partnerId, required this.bookingStatus, required this.email});

  @override
  State<PaymentCompleted> createState() => _PaymentCompletedState();
}

class _PaymentCompletedState extends State<PaymentCompleted> {
  bool isVendorSelected = false;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> _dropLatLngs = [];
  String? selectedVendorId;
  bool isLoading = true;
  List<Map<String, dynamic>>? partnerData;
  String currentPlace = '';

  @override
  void initState() {
    fetchAddressCoordinates();
    fetchCoordinates();
    fetchPartnerData();
    super.initState();
  }

  Future<void> fetchPartnerData() async {
    try {
      final data = await userService.getPartnerData(widget.partnerId, widget.token,widget.bookingId);

      print('Fetched Partner Data: $data');

      if (data.isNotEmpty) {
        setState(() {
          partnerData = data;
        });
      } else {
        print('No partner data available');
      }
    } catch (e) {
      print('Error fetching partner data: $e');
    }
  }

  Future<void> fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String pickupPlace = widget.pickup;
      List dropPlaces = widget.dropPoints;

      setState(() {
        markers.clear();
        polylines.clear();
        _dropLatLngs.clear();
      });

      // Fetch the user's current location
      Position currentPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      LatLng currentLatLng =
      LatLng(currentPosition.latitude, currentPosition.longitude);

      // Add marker for the current location
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLatLng,
            infoWindow: InfoWindow(
              snippet: currentPlace,
              title: 'Current Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      // Fetch pickup coordinates
      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));

      if (pickupResponse.statusCode == 200) {
        final pickupData = json.decode(pickupResponse.body);

        if (pickupData != null && pickupData['status'] == 'OK') {
          final pickupLocation =
          pickupData['results']?[0]['geometry']?['location'];
          final pickupAddress = pickupData['results']?[0]['formatted_address'];

          if (pickupLocation != null) {
            pickupLatLng = LatLng(pickupLocation['lat'], pickupLocation['lng']);

            setState(() {
              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng!,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: pickupAddress,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
              );
            });
          }
        }

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
              print('Current Location Name: $currentLocationName');
            }
          }
        }

        // Fetch drop coordinates
        if (dropPlaces.isNotEmpty) {
          String dropUrl =
              'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlaces[0])}&key=$apiKey';
          final dropResponse = await http.get(Uri.parse(dropUrl));

          if (dropResponse.statusCode == 200) {
            final dropData = json.decode(dropResponse.body);

            if (dropData != null && dropData['status'] == 'OK') {
              final dropLocation =
              dropData['results']?[0]['geometry']?['location'];
              final dropAddress = dropData['results']?[0]['formatted_address'];

              if (dropLocation != null) {
                LatLng dropLatLng =
                LatLng(dropLocation['lat'], dropLocation['lng']);

                setState(() {
                  markers.add(
                    Marker(
                      markerId: const MarkerId('dropPoint'),
                      position: dropLatLng,
                      infoWindow: InfoWindow(
                        title: 'Drop Point',
                        snippet: dropAddress,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  );

                  _dropLatLngs.add(dropLatLng);
                });

                // Fetch route with Directions API from current location -> pickup -> drop
                String directionsUrl =
                    'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng.latitude},${currentLatLng.longitude}&destination=${dropLatLng.latitude},${dropLatLng.longitude}&waypoints=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&key=$apiKey';

                final directionsResponse = await http.get(Uri.parse(directionsUrl));

                if (directionsResponse.statusCode == 200) {
                  final directionsData = json.decode(directionsResponse.body);

                  if (directionsData != null && directionsData['status'] == 'OK') {
                    final routes = directionsData['routes']?[0];
                    final polyline = routes?['overview_polyline']?['points'];

                    if (polyline != null) {
                      final decodedPoints = _decodePolyline(polyline);

                      setState(() {
                        polylines.add(
                          Polyline(
                            polylineId: const PolylineId('route'),
                            color: Colors.blue,
                            width: 5,
                            points: decodedPoints,
                          ),
                        );
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mapController != null) {
          _moveCameraToFitAllMarkers();
        }
      });
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }

  Future<void> fetchAddressCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      // Retrieve city name, address, and zip code
      String cityName = widget.cityName.trim();
      String address = widget.address.trim();
      String zipCode = widget.zipCode.trim();


      // Combine city name, address, and zip code
      String fullAddress = '$address, $cityName';
      if (zipCode.isNotEmpty) {
        fullAddress += ', $zipCode';
      }

      setState(() {
        markers.clear();
        polylines.clear();
        _dropLatLngs.clear();
      });

      // Fetch pickup coordinates
      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(fullAddress)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));

      if (pickupResponse.statusCode == 200) {
        final pickupData = json.decode(pickupResponse.body);

        if (pickupData != null && pickupData['status'] == 'OK') {
          final pickupLocation =
              pickupData['results']?[0]['geometry']?['location'];
          final pickupAddress = pickupData['results']?[0]['formatted_address'];

          if (pickupLocation != null) {
            setState(() {
              pickupLatLng =
                  LatLng(pickupLocation['lat'], pickupLocation['lng']);

              // Display the city name, address, and zip code in the snippet
              String snippetText = '$address, $cityName';
              if (zipCode.isNotEmpty) {
                snippetText += ', $zipCode';
              }

              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng!,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: snippetText,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
              );

              // Clear existing polylines and drop points list
              polylines.clear();
              _dropLatLngs.clear();
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mapController != null && pickupLatLng != null) {
                _moveCameraToFitAllMarkers();
              }
            });
          } else {
            print('Pickup location is null');
          }
        } else {
          print('Error with pickup API response: ${pickupData?['status']}');
        }
      } else {
        print(
            'Failed to load pickup coordinates, status code: ${pickupResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      polylinePoints.add(
        LatLng(
          (lat / 1E5),
          (lng / 1E5),
        ),
      );
    }

    return polylinePoints;
  }

  void _moveCameraToFitAllMarkers() {
    if (mapController != null) {
      LatLngBounds bounds;
      if (_dropLatLngs.isNotEmpty) {
        bounds = _calculateBounds();
      } else if (pickupLatLng != null) {
        bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          northeast: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
        );
      } else {
        print('No coordinates to fit.');
        return;
      }

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          zoom: 5,
        )), // Padding in pixels
      );
    } else {
      print('mapController is not initialized');
    }
  }

  LatLngBounds _calculateBounds() {
    double southWestLat = [
      pickupLatLng!.latitude,
      ..._dropLatLngs.map((latLng) => latLng.latitude)
    ].reduce((a, b) => a < b ? a : b);
    double southWestLng = [
      pickupLatLng!.longitude,
      ..._dropLatLngs.map((latLng) => latLng.longitude)
    ].reduce((a, b) => a < b ? a : b);
    double northEastLat = [
      pickupLatLng!.latitude,
      ..._dropLatLngs.map((latLng) => latLng.latitude)
    ].reduce((a, b) => a > b ? a : b);
    double northEastLng = [
      pickupLatLng!.longitude,
      ..._dropLatLngs.map((latLng) => latLng.longitude)
    ].reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
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
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            await fetchPartnerData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 1,
                        ),
                        markers: markers,
                        polylines: polylines,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserType(firstName: widget.firstName, lastName: widget.lastName, token: widget.token, id: widget.id,email: widget.email,)
                                        ),
                                      );
                                    },
                                    child: const CircleAvatar(backgroundColor: Colors.white,child: Icon(FontAwesomeIcons.arrowLeft,size: 20,))),
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80),
                                ),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: SvgPicture.asset('assets/moving_truck.svg'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.sizeOf(context).width * 0.55,
                                              child: Column(
                                                children: [
                                                  Text('Booking id'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                                  Text(widget.bookingId,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserType(
                                                    firstName: widget.firstName,
                                                    lastName: widget.lastName,
                                                    token: widget.token,
                                                    id: widget.id,
                                                    email: widget.email,
                                                  )));
                                    },
                                    icon: const Icon(FontAwesomeIcons.multiply)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      left: viewUtil.isTablet?25 :15,
                      right: viewUtil.isTablet?25 :15,
                      bottom: 10),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(
                        color: Color(0xffE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: partnerData == null
                          ? Center(
                              child: CircularProgressIndicator())
                          : Column(
                              children: [
                                _buildDetailRow('Vendor Name'.tr(),
                                    partnerData?[0]['partnerName'] ?? 'no_data'.tr()),
                                Divider(),
                                _buildDetailRow('Operator Name'.tr(),
                                  partnerData != null && partnerData!.isNotEmpty
                                      ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                      ? (partnerData?[0]['operatorName'] ?? 'N/A')
                                      : (partnerData?[0]['assignOperatorName'] ?? 'N/A'))
                                      : 'no_data'.tr()),
                                Divider(),
                                _buildDetailRow('Operator Mobile'.tr(),
                                  partnerData != null && partnerData!.isNotEmpty
                                      ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                      ? (partnerData?[0]['mobileNo'] ?? 'N/A')
                                      : (partnerData?[0]['assignOperatorMobileNo'] ?? 'N/A'))
                                      : 'no_data'.tr()),
                                Divider(),
                                _buildDetailRow(
                                    'Mode'.tr(), partnerData?[0]['mode'] ?? 'no_data'.tr()),
                                Divider(),
                                _buildDetailRow('Booking Status'.tr(),
                                    widget.bookingStatus.tr()),
                              ],
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15,bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_sharp,color: Colors.green,size: 30,),
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text('Payment Successful!!'.tr() ,style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet ? 25 : 20,fontWeight: FontWeight.w500),),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: Color(0xff79797C), fontSize: viewUtil.isTablet ? 20 : 16),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
            ),
          ),
        ],
      ),
    );
  }
}

