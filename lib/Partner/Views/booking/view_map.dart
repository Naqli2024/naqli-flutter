import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
class ViewMap extends StatefulWidget {
  final String partnerName;
  final String userName;
  final String userId;
  final String mode;
  final String bookingStatus;
  final String pickupPoint;
  final String dropPoint;
  final String remainingBalance;
  final String bookingId;
  final String token;

  const ViewMap({
    super.key,
    required this.partnerName,
    required this.userId,
    required this.mode,
    required this.bookingStatus,
    required this.userName,
    required this.pickupPoint,
    required this.dropPoint,
    required this.remainingBalance,
    required this.bookingId,
    required this.token,
  });

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final TextEditingController chargesController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  late String remainingBalance;
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
    _requestPermissions();
    remainingBalance = widget.remainingBalance;
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String pickupPlace = widget.pickupPoint;
      String dropPlace = widget.dropPoint;

      String pickupUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      String dropUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlace)}&key=$apiKey';

      final pickupResponse = await http.get(Uri.parse(pickupUrl));
      final dropResponse = await http.get(Uri.parse(dropUrl));

      if (pickupResponse.statusCode == 200 && dropResponse.statusCode == 200) {
        final pickupData = json.decode(pickupResponse.body);
        final dropData = json.decode(dropResponse.body);

        if (pickupData['status'] == 'OK' && dropData['status'] == 'OK') {
          final pickupLocation = pickupData['results'][0]['geometry']['location'];
          final dropLocation = dropData['results'][0]['geometry']['location'];
          final pickupAddress = pickupData['results'][0]['formatted_address'];
          final dropAddress = dropData['results'][0]['formatted_address'];

          setState(() {
            pickupLatLng = LatLng(pickupLocation['lat'], pickupLocation['lng']);
            dropLatLng = LatLng(dropLocation['lat'], dropLocation['lng']);

            if (pickupLatLng != null && dropLatLng != null) {
              markers.add(
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickupLatLng!,
                  infoWindow: InfoWindow(
                    title: 'Pickup Point',
                    snippet: pickupAddress,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              );

              markers.add(
                Marker(
                  markerId: const MarkerId('dropPoint'),
                  position: dropLatLng!,
                  infoWindow: InfoWindow(
                    title: 'Drop Point',
                    snippet: dropAddress,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              );

              polylines.add(
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: [pickupLatLng!, dropLatLng!],
                ),
              );
            }
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mapController != null && pickupLatLng != null && dropLatLng != null) {
              _moveCameraToFitAllMarkers();
            }
          });
        } else {
          print('Error with API response: ${pickupData['status']} and ${dropData['status']}');
        }
      } else {
        print('Failed to load coordinates, status code: ${pickupResponse.statusCode} and ${dropResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching coordinates: $e');
    }
  }

  void _moveCameraToFitAllMarkers() {
    if (mapController != null && pickupLatLng != null && dropLatLng != null) {
      LatLngBounds bounds = _calculateBounds();
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 130), // Padding in pixels
      );
    } else {
      print('mapController or coordinates are not initialized');
    }
  }

  LatLngBounds _calculateBounds() {
    double southWestLat = [pickupLatLng!.latitude, dropLatLng!.latitude].reduce((a, b) => a < b ? a : b);
    double southWestLng = [pickupLatLng!.longitude, dropLatLng!.longitude].reduce((a, b) => a < b ? a : b);
    double northEastLat = [pickupLatLng!.latitude, dropLatLng!.latitude].reduce((a, b) => a > b ? a : b);
    double northEastLng = [pickupLatLng!.longitude, dropLatLng!.longitude].reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  Future<void> requestPayment() async {
    int additionalCharges = int.tryParse(chargesController.text) ?? 0;
    String? updatedRemainingBalance = await _authService.requestPayment(
      context,
      additionalCharges: additionalCharges,
      reason: reasonController.text,
      bookingId: widget.bookingId,
      token: widget.token,
    );

    if (updatedRemainingBalance != null) {
      print('Updated Remaining Balance: $updatedRemainingBalance'); // Print for debugging
      setState(() {
        remainingBalance = updatedRemainingBalance; // Update the state with the new balance
      });
    } else {
      print('Failed to update remaining balance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.partnerName,
      ),
      drawer: commonWidgets.createDrawer(context),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _requestPermissions();
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),  // Default position
                zoom: 1,
              ),
              markers: markers,
              polylines: polylines,
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    // height: MediaQuery.sizeOf(context).height * 0.37,
                    margin: EdgeInsets.only(
                      top: MediaQuery.sizeOf(context).height * 0.25,
                      left: 15,
                      right: 15,
                      bottom: 10
                    ),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0), // Border color
                          width: 1, // Border width
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'User name',
                                      style: TextStyle(
                                          color: Color(0xff79797C),
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.userName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'User id',
                                      style: TextStyle(
                                          color: Color(0xff79797C),
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.userId,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Mode',
                                      style: TextStyle(
                                          color: Color(0xff79797C),
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.mode,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Booking status',
                                      style: TextStyle(
                                          color: Color(0xff79797C),
                                          fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      widget.bookingStatus,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text('Additional Charges',style: TextStyle(fontSize: 17),),
                  Padding(
                    padding: const EdgeInsets.only(left: 70,right: 70),
                    child: TextFormField(
                      controller: chargesController,
                      keyboardType: TextInputType.numberWithOptions(),
                    ),
                  ),
                  _buildTextField('Reason',reasonController),
                  Padding(
                    padding: EdgeInsets.only(left: 50,right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Pending Amount',
                          style: TextStyle(fontSize: 17),
                        ),
                        Text(
                            remainingBalance != null ? '$remainingBalance' : 'N/A',
                          style: TextStyle(
                              color: Color(0xffAD1C86), fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20,left: 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.054,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6269FE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: requestPayment,
                              child: const Text(
                                'Request Payment',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              )),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20,right: 10),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.054,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6F181C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Text(
                                'Terminate',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextField(String hintText,controller) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 30),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xffCBC8C8)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $hintText';
            }
            return null;
          },
        ),
      ),
    ],
  );
}

