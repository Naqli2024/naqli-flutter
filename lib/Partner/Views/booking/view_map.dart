import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/partner_report/submitTicket.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ViewMap extends StatefulWidget {
  final String partnerName;
  final String userName;
  final String userId;
  final String email;
  final String mode;
  final String bookingStatus;
  final String pickupPoint;
  final String dropPoint;
  final String remainingBalance;
  final String bookingId;
  final String token;
  final String partnerId;
  final String quotePrice;
  final String paymentStatus;
  final String cityName;
  final String address;
  final String zipCode;

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
    required this.partnerId,
    required this.quotePrice,
    required this.paymentStatus,
    required this.cityName,
    required this.address,
    required this.zipCode, required this.email,
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
  String ?paymentStatus;
  String ?bookingStatus;
  String ?balance;
  String errorMessage = '';
  Map<String, dynamic>? bookingDetails;
  bool isTerminating = false;

  @override
  void initState() {
    super.initState();
    paymentStatus = widget.paymentStatus;
    _moveCameraToFitAllMarkers();
    fetchAddressCoordinates();
    _fetchCoordinates();
    _requestPermissions();
    fetchBookingDetails();
    remainingBalance = widget.remainingBalance;
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
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
        dropLatLng!=[];
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
              dropLatLng!=[];
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

  Future<void> _fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String pickupPlace = widget.pickupPoint;
      String dropPlace = widget.dropPoint;

      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      String dropUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlace)}&key=$apiKey';

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

          pickupLatLng = LatLng(pickupLocation['lat'], pickupLocation['lng']);
          dropLatLng = LatLng(dropLocation['lat'], dropLocation['lng']);

          setState(() {
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
          });

          // Fetch the route from Directions API
          await _fetchRoute(pickupLatLng!, dropLatLng!, apiKey);

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

  Future<void> _fetchRoute(LatLng pickup, LatLng drop, String apiKey) async {
    try {
      String routeUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${drop.latitude},${drop.longitude}&key=$apiKey';

      final routeResponse = await http.get(Uri.parse(routeUrl));

      if (routeResponse.statusCode == 200) {
        final routeData = json.decode(routeResponse.body);
        if (routeData['status'] == 'OK') {
          List<LatLng> routePoints = [];
          for (var step in routeData['routes'][0]['legs'][0]['steps']) {
            var startLocation = step['start_location'];
            var endLocation = step['end_location'];
            routePoints.add(LatLng(startLocation['lat'], startLocation['lng']));
            routePoints.add(LatLng(endLocation['lat'], endLocation['lng']));
          }

          setState(() {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: routePoints,
              ),
            );
          });
        } else {
          print('Error fetching route: ${routeData['status']}');
        }
      } else {
        print('Failed to load route, status code: ${routeResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }


  void _moveCameraToFitAllMarkers() {
    if (mapController != null) {
      LatLngBounds bounds;
      if (dropLatLng!=null) {
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
    double southWestLat = [pickupLatLng!.latitude, dropLatLng!.latitude]
        .reduce((a, b) => a < b ? a : b);
    double southWestLng = [pickupLatLng!.longitude, dropLatLng!.longitude]
        .reduce((a, b) => a < b ? a : b);
    double northEastLat = [pickupLatLng!.latitude, dropLatLng!.latitude]
        .reduce((a, b) => a > b ? a : b);
    double northEastLng = [pickupLatLng!.longitude, dropLatLng!.longitude]
        .reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  Future<void> requestPayment() async {
    int additionalCharges = int.tryParse(chargesController.text) ?? 0;
    chargesController.text = '';
    String? updatedRemainingBalance = await _authService.requestPayment(
      context,
      additionalCharges: additionalCharges,
      reason: reasonController.text,
      bookingId: widget.bookingId,
      token: widget.token,
    );
    commonWidgets.showToast('Additional charges were added');
    if (updatedRemainingBalance != null) {
      print(
          'Updated Remaining Balance: $updatedRemainingBalance'); // Print for debugging
      setState(() {
        remainingBalance =
            updatedRemainingBalance; // Update the state with the new balance
      });
    } else {
      print('Failed to update remaining balance');
    }
  }

  Future<void> fetchBookingDetails() async {
    try {
      print("Fetching booking details...");
      print("Booking ID: ${widget.bookingId}");
      print("Token: ${widget.token}");

      final details = await _authService.getBookingId(
        widget.bookingId,
        widget.token,
        '',
        widget.quotePrice,
      );

      print("API Response: $details"); // Log the entire response

      setState(() {
        if (details != null && details.isNotEmpty) {
          bookingDetails = details;
          paymentStatus = bookingDetails?['paymentStatus'];
          bookingStatus = bookingDetails?['bookingStatus'];
          // remainingBalance = bookingDetails?['remainingBalance'];
          print("Updated Payment Status: $paymentStatus"); // Track status updates
        } else {
          errorMessage = 'No booking details found for the selected ID.';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching booking details: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.partnerName,
      ),
      drawer: commonWidgets.createDrawer(context,
          onPaymentPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentDetails(
                    token: widget.token,
                    partnerId: widget.partnerId,
                    partnerName: widget.partnerName,
                    quotePrice: widget.quotePrice,
                    paymentStatus: widget.paymentStatus,
                    email: widget.email,
                  )),
        );
      }, onBookingPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookingDetails(
                    token: widget.token,
                    partnerId: widget.partnerId,
                    partnerName: widget.partnerName,
                    quotePrice: widget.quotePrice,
                    paymentStatus: widget.paymentStatus,
                    email: widget.email,
                  )),
        );
      },
          onReportPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitTicket(firstName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,),
              ),
            );
          }
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          await fetchBookingDetails();
          setState(() {
            if (widget.cityName != null) {
              fetchAddressCoordinates();
            } else {
              _fetchCoordinates();
            }
          });
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 0.4,
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
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      // height: MediaQuery.sizeOf(context).height * 0.37,
                      margin: EdgeInsets.only(
                          top: MediaQuery.sizeOf(context).height * 0.25,
                          left: 15,
                          right: 15,
                          bottom: 10),
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
                                        bookingStatus??'',
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
                                        'Payment status',
                                        style: TextStyle(
                                            color: Color(0xff79797C),
                                            fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        paymentStatus??'',
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
                    remainingBalance == '0' || paymentStatus == 'Completed'
                        ? Container()
                        : Padding(
                      padding: EdgeInsets.only(left: 50, right: 50,top: 10,bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Pending Amount',
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            remainingBalance != null
                                ? '$remainingBalance SAR'
                                : 'N/A',
                            style:
                            TextStyle(color: Color(0xffAD1C86), fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Additional Charges',
                      style: TextStyle(fontSize: 17),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 70, right: 70),
                      child: TextFormField(
                        controller: chargesController,
                        keyboardType: TextInputType.numberWithOptions(),
                      ),
                    ),
                    _buildTextField('Reason', reasonController),
                    Visibility(
                      visible: paymentStatus == 'Completed',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15,bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_sharp,color: Colors.green,size: 30,),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text('Payment Successful!!' ,style: TextStyle(color: Colors.green,fontSize: 20,fontWeight: FontWeight.w500),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10, left: 10,bottom: 20),
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
                                onPressed: () {
                                  chargesController.text.isEmpty || reasonController.text.isEmpty
                                  ? commonWidgets.showToast('Please add Additional charges and Reason')
                                  : requestPayment();
                                },
                                child: Text(
                                  'Request Payment',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10, right: 10,bottom: 20),
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
                                onPressed: () async{
                                  setState(() {
                                    isTerminating = true;
                                  });
                                  await _authService.terminateBooking(context,widget.partnerId,widget.bookingId,widget.token,widget.email);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BookingDetails(partnerName: widget.partnerName,
                                              partnerId: widget.partnerId,
                                              token: widget.token,
                                              quotePrice: '',
                                              paymentStatus: '',email: widget.email,)
                                    ),
                                  );
                                  setState(() {
                                    isTerminating = false;
                                  });
                                  },
                                child: isTerminating
                                    ? Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          ),
                                      )
                                    : Text(
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
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(String hintText, controller) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
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
