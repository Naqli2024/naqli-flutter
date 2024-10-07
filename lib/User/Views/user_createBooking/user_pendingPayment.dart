import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PendingPayment extends StatefulWidget {
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
  final String partnerName;
  final String partnerId;
  final String oldQuotePrice;
  final String paymentStatus;
  final String quotePrice;
  final int advanceOrPay;
  final String bookingStatus;

  const PendingPayment({super.key, required this.bookingId, required this.unit, required this.unitType, required this.load, required this.size, required this.pickup, required this.dropPoints, required this.cityName, required this.address, required this.zipCode, required this.token, required this.firstName, required this.lastName, required this.selectedType, required this.unitTypeName, required this.id, required this.partnerName, required this.partnerId, required this.oldQuotePrice, required this.paymentStatus, required this.quotePrice, required this.advanceOrPay, required this.bookingStatus});

  @override
  State<PendingPayment> createState() => _PendingPaymentState();
}

class _PendingPaymentState extends State<PendingPayment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  String vendorName = 'Vendor name';
  String unit = 'unit';
  String operatorName = 'Operator Name';
  String mode = 'Mode';
  int remainingBalance = 0;
  String bookingStatus = 'Booking status';
  String paymentStatus = 'payment Status';
  String pendingAmount = 'XXXXX SAR';
  bool isLoading = true;
  List<Map<String, dynamic>>? partnerData;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> _dropLatLngs = [];
  String zeroQuotePrice = '0';

  @override
  void initState() {
    print(widget.token);
    print(widget.advanceOrPay);
    print(widget.paymentStatus);
    print(widget.partnerId);
    print(widget.bookingId);
    print(widget.quotePrice);
    print(widget.oldQuotePrice);
    // widget.paymentStatus == 'HalfPaid'
    // ? null
    // :fetchPaymentData();
    fetchAddressCoordinates();
    fetchCoordinates();
    fetchPartnerData();
    // userService.updatePayment(widget.token, widget.advanceOrPay, widget.paymentStatus, widget.partnerId,widget.bookingId, widget.quotePrice, widget.oldQuotePrice);
    _savePaymentDetailsToSharedPreferences(widget.paymentStatus, widget.advanceOrPay);
    super.initState();
  }

  Future<void> _savePaymentDetailsToSharedPreferences(String paymentStatus, int advanceOrPay) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (advanceOrPay > 0) {
      await prefs.setString('paymentStatus', paymentStatus);
      await prefs.setInt('advanceOrPay', advanceOrPay);
      print('Payment status and advance/pay saved to SharedPreferences.');
    } else {
      print('Advance or Pay is 0, not saving to SharedPreferences.');
    }
  }

  Future<void> initiateStripePayment(
      BuildContext context,
      String status,
      String bookingId,
      int amount,
      String partnerId,
      ) async {
    try {
      var paymentIntent = await createPaymentIntent(
        amount,
        'INR',
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          billingDetails: BillingDetails(
            name: 'YOUR NAME',
            email: 'YOUREMAIL@gmail.com',
            phone: 'YOUR PHONE',
            address: Address(
              city: 'YOUR CITY',
              country: 'YOUR COUNTRY',
              line1: 'YOUR ADDRESS LINE 1',
              line2: 'YOUR ADDRESS LINE 2',
              postalCode: '',
              state: 'YOUR STATE',
            ),
          ),
          style: ThemeMode.dark,
          merchantDisplayName: 'Your Merchant Name',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(msg: 'Payment successfully completed');
      await userService.updatePayment(
        widget.token,
        amount,
        'Completed',
        partnerId,
        bookingId,
        zeroQuotePrice.toString(),
        zeroQuotePrice.toString(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            id: widget.id,
            firstName: widget.firstName,
            lastName: widget.lastName,
            token: widget.token,
            Image: 'assets/payment_success.svg',
            title: 'Thank you!',
            subTitle: 'Your Payment was successful',
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCompleted(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              selectedType: widget.selectedType,
              unit: widget.unit,
              load: widget.load,
              bookingId: widget.bookingId,
              unitType: widget.unitType,
              dropPoints: widget.dropPoints,
              pickup: widget.pickup,
              cityName: widget.cityName,
              address: widget.address,
              zipCode: widget.zipCode,
              unitTypeName: widget.unitTypeName,
              partnerId: widget.partnerId,
              size: widget.size,
              bookingStatus: widget.bookingStatus,
            ),
          ),
        );
      });

    } catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
          msg: 'Error from Stripe: ${e.error.localizedMessage}',
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Unforeseen error: $e',
        );
      }
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      int amount,
      String currency,
      ) async {
    try {
      final calculatedAmount = calculateAmount(amount);

      Map<String, dynamic> body = {
        'amount': calculatedAmount,
        'currency': currency,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      return json.decode(response.body);
    } catch (err) {
      print(err);
      throw Exception('Error creating payment intent: $err');
    }
  }

  String calculateAmount(int amount) {
    try {
      final intAmount = amount * 100;
      return intAmount.toString();
    } catch (e) {
      throw Exception('Invalid amount format: $amount');
    }
  }


  Future<void> fetchPaymentData() async {
    try {

      final response = await userService.updatePayment(
        widget.token,
        widget.advanceOrPay,
        widget.paymentStatus,
        widget.partnerId,
        widget.bookingId,
        widget.quotePrice,
        widget.oldQuotePrice,
      );

      // Check if the response is null or doesn't contain the expected keys
      if (response == null || !response.containsKey('success') || response['success'] == false) {
        // Handle the error from the response
        print('Error in response: ${response?['message'] ?? 'Unknown error'}');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Parse the response and update the UI
      setState(() {
        print(response);
        // remainingBalance = response['booking']['remainingBalance']?.toString() ?? '0';
        unit = response['booking']['name'] ?? ' ';
        bookingStatus = response['booking']['bookingStatus'] ?? '';
        paymentStatus = response['booking']['paymentStatus'] ?? '';
        // remainingBalance = response['booking']['remainingBalance']?? 0;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching payment data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPartnerData() async {
    try {
      final data = await userService.getPartnerData(widget.partnerId, widget.token,widget.bookingId);

      // Log the fetched data to check what's being returned
      print('Fetched Partner Data: $data');

      if (data.isNotEmpty) {
        setState(() {
          partnerData = data;
        });
      } else {
        // If the data is empty, log it
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
      // Fetch pickup coordinates
      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));

      // Fetch drop coordinates
      List<Future<http.Response>> dropResponses = dropPlaces.map((dropPlace) {
        String dropUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(dropPlace)}&key=$apiKey';
        return http.get(Uri.parse(dropUrl));
      }).toList();

      final List<http.Response> dropResponsesList =
      await Future.wait(dropResponses);

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

              // Clear existing polylines and drop points list
              polylines.clear();
              _dropLatLngs.clear();
            });
          } else {
            print('Pickup location is null');
          }
        } else {
          print('Error with pickup API response: ${pickupData?['status']}');
        }

        // Handle each drop point response
        List<LatLng> waypoints = [];
        for (int i = 0; i < dropResponsesList.length; i++) {
          final dropResponse = dropResponsesList[i];
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
                      markerId: MarkerId('dropPoint$i'),
                      position: dropLatLng,
                      infoWindow: InfoWindow(
                        title: 'Drop Point ${i + 1}',
                        snippet: dropAddress,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  );

                  // Add the drop point to the list
                  _dropLatLngs.add(dropLatLng);
                  waypoints.add(dropLatLng);
                });
              } else {
                print('Drop location is null for point $i');
              }
            } else {
              print(
                  'Error with drop API response for point $i: ${dropData?['status']}');
            }
          } else {
            print(
                'Failed to load drop coordinates for point $i, status code: ${dropResponse.statusCode}');
          }
        }

        // Fetch route with Directions API
        if (_dropLatLngs.isNotEmpty) {
          String waypointsString = waypoints
              .map((latLng) => '${latLng.latitude},${latLng.longitude}')
              .join('|');
          String directionsUrl =
              'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLatLng!.latitude},${pickupLatLng!.longitude}&destination=${_dropLatLngs.last.latitude},${_dropLatLngs.last.longitude}&waypoints=optimize:true|$waypointsString&key=$apiKey';
          final directionsResponse = await http.get(Uri.parse(directionsUrl));

          if (directionsResponse.statusCode == 200) {
            final directionsData = json.decode(directionsResponse.body);
            if (directionsData != null && directionsData['status'] == 'OK') {
              final routes = directionsData['routes']?[0];
              final legs = routes?['legs'] as List<dynamic>;
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
            } else {
              print(
                  'Error with directions API response: ${directionsData?['status']}');
            }
          } else {
            print(
                'Failed to load directions, status code: ${directionsResponse.statusCode}');
          }
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mapController != null && pickupLatLng != null) {
            _moveCameraToFitAllMarkers();
          }
        });
      } else {
        print(
            'Failed to load pickup coordinates, status code: ${pickupResponse.statusCode}');
      }
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder:  (context) => UserType(
          firstName: widget.firstName,
          lastName: widget.lastName,
          token: widget.token,
          id: widget.id,
          quotePrice: widget.quotePrice,
          oldQuotePrice: widget.oldQuotePrice,
        )));
        return false;
      },
      child: Scaffold(
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,showLeading: false
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            await fetchPartnerData();
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
                  )
                ),
                Positioned(
                    top: 15,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 15),
                                      child: Image.asset('assets/moving_truck.png'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          alignment: Alignment.center,
                                          // height: 50,
                                          width: MediaQuery.sizeOf(context).width * 0.55,
                                          child: Column(
                                            children: [
                                              Text('Booking Id'),
                                              Text(widget.bookingId),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                                onPressed: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder:  (context) => UserType(
                                          firstName: widget.firstName,
                                          lastName: widget.lastName,
                                          token: widget.token,
                                          id: widget.id,
                                        quotePrice: widget.quotePrice,
                                      )));
                                },
                                icon: Icon(FontAwesomeIcons.multiply)),
                          ),
                        ],
                      ),
                    )),
                /*widget.selectedType ==
                    'vehicle' ||
                    widget.selectedType ==
                        'bus' ||
                    widget.selectedType ==
                        'equipment' ||
                    widget.selectedType ==
                        'special' ||
                    widget.selectedType ==
                        'others'
                ?*/Center(
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
                        child: Container(
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xffE0E0E0), // Border color
                                width: 1, // Border width
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Vendor name',
                                          style: TextStyle(
                                              color: Color(0xff79797C),
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          partnerData?[0]['partnerName'] ?? 'N/A',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Operator name',
                                          style: TextStyle(
                                              color: Color(0xff79797C),
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          partnerData != null && partnerData!.isNotEmpty
                                              ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                              ? (partnerData?[0]['operatorName'] ?? 'N/A')
                                              : (partnerData?[0]['assignOperatorName'] ?? 'N/A'))
                                              : 'No Data',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Operator mobile No',
                                          style: TextStyle(
                                              color: Color(0xff79797C),
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          partnerData != null && partnerData!.isNotEmpty
                                              ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                              ? (partnerData?[0]['mobileNo'] ?? 'N/A')
                                              : (partnerData?[0]['assignOperatorMobileNo'] ?? 'N/A'))
                                              : 'No Data',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Unit',
                                          style: TextStyle(
                                              color: Color(0xff79797C),
                                              fontSize: 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          widget.unit,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
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
                                          style: TextStyle(fontSize: 16),
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
                      widget.paymentStatus == 'HalfPaid'
                      ?Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 50,right: 50,top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Pending Amount',
                                  style: TextStyle(fontSize: 21),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 50,right: 50,bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '${widget.advanceOrPay} SAR',
                                  style: TextStyle(fontSize: 21,color: Color(0xff914F9D)),
                                ),
                              ],
                            ),
                          ),
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
                                  onPressed: (){
                                    initiateStripePayment(
                                        context,
                                        'Completed',
                                        widget.bookingId,
                                        widget.advanceOrPay,
                                        widget.partnerId
                                    );
                                  },
                                  child: Text(
                                    'Pay : ${widget.advanceOrPay} SAR',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.normal),
                                  )),
                            ),
                          ),
                        ],
                      )
                       : Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_sharp,color: Colors.green,size: 30,),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text('Payment Successful' ,style: TextStyle(color: Color(0xff79797C),fontSize: 20,fontWeight: FontWeight.w500),),
                            ),
                          ],
                        ),
                      )
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
}
