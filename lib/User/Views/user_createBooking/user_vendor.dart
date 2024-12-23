import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_bookingHistory.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_payment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart'as permissionHandler;
// import 'package:permission_handler/permission_handler.dart';
import 'package:stripe_platform_interface/src/models/payment_methods.dart'
    as stripe;
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ChooseVendor extends StatefulWidget {
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
  final String? accountType;
  const ChooseVendor(
      {super.key,
      required this.bookingId,
      required this.unit,
      required this.unitType,
      required this.load,
      required this.size,
      required this.token,
      required this.pickup,
      required this.dropPoints,
      required this.firstName,
      required this.lastName,
      required this.selectedType,
      required this.cityName,
      required this.address,
      required this.zipCode,
      required this.unitTypeName,
      required this.id, required this.email, this.accountType});

  @override
  State<ChooseVendor> createState() => _ChooseVendorState();
}

class _ChooseVendorState extends State<ChooseVendor> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  int selectedVendor = 0;
  bool isVendorSelected = false;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> _dropLatLngs = [];
  List<Map<String, dynamic>> vendors = [];
  String? selectedVendorId;
  int fullAmount = 0;
  int advanceAmount = 0;
  bool isLoading = true;
  bool isDeleting = false;
  bool isFetching = false;
  Timer? timer;
  Map<String, dynamic>? paymentIntent;
  bool isTimeout = false;
  double fullPayAmount = 0.0;
  double advancePayAmount = 0.0;
  Future<Map<String, dynamic>?>? booking;
  Timer? _refreshTimer;
  Timer? _fetchTimer;
  bool isStopped = false;
  bool isPayAdvance = false;
  String? selectedPartnerName;
  String? selectedPartnerId;
  String? selectedOldQuotePrice;
  String? selectedQuotePrice;
  String? paymentStatus;
  String? bookingStatus;
  Timer? _cycleTimer;
  Timer? _timeoutTimer;
  int fetchedVendorsCount = 0;
  String zeroQuotePrice = '0';
  bool isSwipeEnabled = false;
  String currentPlace = '';


  @override
  void initState() {
    startVendorFetching();
    _moveCameraToFitAllMarkers();
    fetchAddressCoordinates();
    fetchCoordinates();
    booking = _fetchBookingDetails();
    super.initState();
  }


  Future<void> fetchVendor() async {
    if (!mounted || isStopped || isFetching) return;

    setState(() {
      isFetching = true;
    });

    try {
      final fetchedVendorsNullable = await userService.userVehicleVendor(
        context,
        bookingId: widget.bookingId,
        unitType: widget.unitType,
        unitClassification: widget.unit,
        subClassification: widget.unitTypeName,
      );

      print('Fetched Vendor Response: $fetchedVendorsNullable');

      if (fetchedVendorsNullable == null) {
        print('Received null response from userService');
        setState(() {
          isFetching = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedVendors;
      try {
        fetchedVendors = List<Map<String, dynamic>>.from(fetchedVendorsNullable);
      } catch (e) {
        print('Error parsing response: $e');
        setState(() {
          isFetching = false;
        });
        return;
      }


      setState(() {
        vendors.clear();
        vendors.addAll(fetchedVendors);
        isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isFetching = false;
      });
      print('Error fetching vendor: $e');
    }
  }

  void startVendorFetching() {
    _timeoutTimer = Timer(Duration(minutes: 3), () {
      if (!mounted) return;

      setState(() {
        isStopped = true;
        isSwipeEnabled = true;
      });

      stopFetching();
    });

    _startFetchPauseCycle();
  }

  void _startFetchPauseCycle() {
    _cycleTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (isStopped) {
        timer.cancel();
        return;
      }

      if (!isFetching) {
        await fetchVendor();
        await Future.delayed(Duration(seconds: 5));
      }
    });
  }

  void stopFetching() {
    setState(() {
      isStopped = true;
    });

    _cycleTimer?.cancel();
    _timeoutTimer?.cancel();
    _cycleTimer = null;
    _timeoutTimer = null;
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchPaymentData(
      String partnerId,
      String oldQuotePrice,
      String quotePrice,
      String paymentStatus,
      int advanceOrPay,) async {
    try {

      final response = await userService.updatePayment(
          widget.token,
          advanceOrPay,
          paymentStatus,
          partnerId,
          widget.bookingId,
          quotePrice,
          oldQuotePrice);

      if (response == null || !response.containsKey('success') || response['success'] == false) {
        print('Error in response: ${response?['message'] ?? 'Unknown error'}');
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        print(response);
        bookingStatus = response['booking']['bookingStatus'] ?? '';
        paymentStatus = response['booking']['paymentStatus'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching payment data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }



  Future<void> initiateStripePayment(
      BuildContext context,
      double amount,
      bool isPayAdvance,
      String partnerName,
      String partnerId,
      String oldQuotePrice,
      String quotePrice,
      String paymentStatus,
      int advanceOrPay,
      ) async {
    try {

      var paymentIntent = await createPaymentIntent(
        amount.toStringAsFixed(2),
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

      Fluttertoast.showToast(msg: 'Payment successfully completed'.tr());

      if (isPayAdvance) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(FontAwesomeIcons.multiply),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/confirm.svg',
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.7,
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              'Thank you!'.tr(),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Your booking is confirmed'.tr(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${'with advance payment of'.tr()} \n SAR ${amount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        await fetchPaymentData( partnerId,oldQuotePrice,quotePrice, paymentStatus, advanceOrPay,);
        // Wait for 2 seconds before navigating
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PendingPayment(
              firstName: widget.firstName,
              lastName: widget.lastName,
              selectedType: widget.selectedType,
              token: widget.token,
              unit: widget.unit,
              load: widget.load,
              size: widget.size,
              bookingId: widget.bookingId,
              unitType: widget.unitType,
              dropPoints: widget.dropPoints,
              pickup: widget.pickup,
              cityName: widget.cityName,
              address: widget.address,
              zipCode: widget.zipCode,
              unitTypeName: widget.unitTypeName,
              id: widget.id,
              partnerName: partnerName,
              partnerId: partnerId,
              oldQuotePrice: oldQuotePrice,
              paymentStatus: paymentStatus,
              quotePrice: quotePrice,
              advanceOrPay: advanceOrPay,
              bookingStatus: bookingStatus??'',
              email: widget.email,
            ),
          ),
        );
      } else {
        await fetchPaymentData( partnerId,selectedOldQuotePrice!,selectedQuotePrice!, "Paid", fullAmount,);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PendingPayment(
              firstName: widget.firstName,
              lastName: widget.lastName,
              selectedType: widget.selectedType,
              token: widget.token,
              unit: widget.unit,
              load: widget.load,
              size: widget.size,
              bookingId: widget.bookingId,
              unitType: widget.unitType,
              dropPoints: widget.dropPoints,
              pickup: widget.pickup,
              cityName: widget.cityName,
              address: widget.address,
              zipCode: widget.zipCode,
              unitTypeName: widget.unitTypeName,
              id: widget.id,
              partnerName: partnerName,
              partnerId: partnerId,
              oldQuotePrice: oldQuotePrice,
              paymentStatus: paymentStatus,
              quotePrice: quotePrice,
              advanceOrPay: advanceOrPay,
              bookingStatus: bookingStatus??'',
              email: widget.email,
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
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
      String amount, String currency) async {
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
      throw Exception('Error creating payment intent: $err');
    }
  }

  String calculateAmount(String amount) {
    try {
      final doubleAmount = double.tryParse(amount) ?? 0.0;
      final intAmount =
      (doubleAmount * 100).toInt();
      return intAmount.toString();
    } catch (e) {
      throw Exception('Invalid amount format: $amount');
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
      String pickupUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(pickupPlace)}&key=$apiKey';
      final pickupResponse = await http.get(Uri.parse(pickupUrl));
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

        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
            zoom: 5,
          )),
        );

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

  // Future<Map<String, dynamic>?> _fetchBookingDetails() async {
  //   try {
  //     final history = await userService.fetchBookingDetails(widget.id, widget.token);
  //     return history;
  //   } catch (e) {
  //     print('Error fetching booking details: $e');
  //     return null;
  //   }
  // }


/*
  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    final String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId != null && token != null) {
      print('Fetching details with bookingId=$bookingId and token=$token');
      return await userService.fetchBookingDetails(bookingId, token);
    } else {
      print('No bookingId or token found in shared preferences.');
      return null;
    }
  }
*/


  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId == null || token == null) {
      print('No bookingId found, fetching pending booking details.');

      if (widget.id != null && token != null) {
        bookingId = await userService.getPaymentPendingBooking(widget.id, token);

        if (bookingId != null) {
          // await saveBookingIdToPreferences(bookingId, token);
        } else {
          print('No pending booking found, navigating to NewBooking.');
          return null;
        }
      } else {
        print('No userId or token available.');
        return null;
      }
    }

    if (bookingId != null && token != null) {
      return await userService.fetchBookingDetails(bookingId, token);
    } else {
      print('Failed to fetch booking details due to missing bookingId or token.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewBooking(
            token: token,
            firstName: widget.firstName,
            lastName: widget.lastName,
            id: widget.id,
            email: widget.email,
          ),
        ),
      );
      return null;
    }
  }


  Future<void> handleDeleteBooking() async {
    try {
      await userService.deleteBooking(context, widget.bookingId, widget.token);
      await clearUserData();
      isDeleting = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserType(
            firstName: widget.firstName,
            lastName: widget.lastName,
            token: widget.token,
            id: widget.id,
            email: widget.email,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $e')),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Directionality(
              textDirection: ui.TextDirection.ltr,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30, bottom: 10),
                      child: Text(
                        'Are you sure you want to cancel this booking?'.tr(),
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                    if (isDeleting)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('yes'.tr()),
                    onPressed: () {
                      if (!isDeleting) {
                        setState(() {
                          isDeleting = true;
                        });
                        stopFetching();
                        handleDeleteBooking();
                      }
                    },
                  ),
                  TextButton(
                    child: Text('no'.tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchRefreshVendor() async {
    try {
      final fetchedVendorsNullable = await userService.userVehicleVendor(
        context,
        bookingId: widget.bookingId,
        unitType: widget.unitType,
        unitClassification: widget.unit,
        subClassification: widget.unitTypeName,
      );

      print('Fetched Vendor Response: $fetchedVendorsNullable');

      if (fetchedVendorsNullable == null) {
        print('Received null response from userService');
        setState(() {
          isFetching = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedVendors;
      try {
        fetchedVendors = List<Map<String, dynamic>>.from(fetchedVendorsNullable);
      } catch (e) {
        print('Error parsing response: $e');
        setState(() {
          isFetching = false;
        });
        return;
      }

      setState(() {
        vendors.clear();
        vendors.addAll(fetchedVendors);
        isFetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isFetching = false;
      });
      print('Error fetching vendor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        stopFetching();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserType(
                firstName: widget.firstName,
                lastName: widget.lastName,
                token: widget.token,
                id: widget.id,
              email: widget.email,
            )));
        return false;
      },
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
            appBar: commonWidgets.commonAppBar(
                context,
                User: widget.firstName +' '+ widget.lastName,
                showLeading: false,
                showLanguage: true,
                userId: widget.id),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserEditProfile(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person,color: Colors.grey,size: 30),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.firstName +' '+ widget.lastName,
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Icon(Icons.edit,color: Colors.grey,size: 20),
                      ],
                    ),
                    subtitle: Text(widget.id,
                      style: TextStyle(color: Color(0xff8E8D96),
                      ),),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Divider(),
                ),
                ListTile(
                    leading: Icon(Icons.home,size: 30,color: Color(0xff707070)),
                    title: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Home'.tr(),style: TextStyle(fontSize: 25),),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserType(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                        ),
                      );
                    }
                ),
                ListTile(
                    leading: SvgPicture.asset('assets/booking_logo.svg'),
                    title: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'booking'.tr(),
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    onTap: () async {
                      try {
                        final bookingData = await booking;
                        if (bookingData != null) {
                          bookingData['paymentStatus']== 'Pending' || bookingData['paymentStatus']== 'NotPaid'
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChooseVendor(
                                      id: widget.id,
                                      bookingId: bookingData['_id'] ?? '',
                                      size: bookingData['type']?.isNotEmpty ?? false
                                          ? bookingData['type'][0]['scale'] ?? ''
                                          : '',
                                      unitType: bookingData['unitType'] ?? '',
                                      unitTypeName: bookingData['type']
                                                  ?.isNotEmpty ??
                                              false
                                          ? bookingData['type'][0]['typeName'] ?? ''
                                          : '',
                                      load: bookingData['type']?.isNotEmpty ?? false
                                          ? bookingData['type'][0]['typeOfLoad'] ??
                                              ''
                                          : '',
                                      unit: bookingData['name'] ?? '',
                                      pickup: bookingData['pickup'] ?? '',
                                      dropPoints: bookingData['dropPoints'] ?? [],
                                      token: widget.token,
                                      firstName: widget.firstName,
                                      lastName: widget.lastName,
                                      selectedType: widget.selectedType,
                                      cityName: bookingData['cityName'] ?? '',
                                      address: bookingData['address'] ?? '',
                                      zipCode: bookingData['zipCode'] ?? '',
                                      email: widget.email,
                                    ),
                                  ),
                                )
                              : bookingData['paymentStatus'] == 'HalfPaid'
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PendingPayment(
                                                firstName: widget.firstName,
                                                lastName: widget.lastName,
                                                selectedType: widget.selectedType,
                                                token: widget.token,
                                                unit: bookingData['name'] ?? '',
                                                load: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['typeOfLoad'] ??
                                                        ''
                                                    : '',
                                                size: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['scale'] ??
                                                        ''
                                                    : '',
                                                bookingId: bookingData['_id'] ?? '',
                                                unitType:
                                                    bookingData['unitType'] ?? '',
                                                pickup: bookingData['pickup'] ?? '',
                                                dropPoints:
                                                    bookingData['dropPoints'] ?? [],
                                                cityName:
                                                    bookingData['cityName'] ?? '',
                                                address:
                                                    bookingData['address'] ?? '',
                                                zipCode:
                                                    bookingData['zipCode'] ?? '',
                                                unitTypeName: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['typeName'] ??
                                                        ''
                                                    : '',
                                                id: widget.id,
                                            partnerName: '',
                                            partnerId: bookingData['partner'] ?? '',
                                            oldQuotePrice: '',
                                            paymentStatus: bookingData['paymentStatus'] ?? '',
                                            quotePrice: '',
                                              advanceOrPay: bookingData['remainingBalance'] ?? 0,
                                            bookingStatus: bookingData['bookingStatus'] ?? '',
                                            email: widget.email,
                                              )),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentCompleted(
                                                firstName: widget.firstName,
                                                lastName: widget.lastName,
                                                selectedType: widget.selectedType,
                                                token: widget.token,
                                                unit: bookingData['name'] ?? '',
                                                load: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['typeOfLoad'] ??
                                                        ''
                                                    : '',
                                                size: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['scale'] ??
                                                        ''
                                                    : '',
                                                bookingId: bookingData['_id'] ?? '',
                                                unitType:
                                                    bookingData['unitType'] ?? '',
                                                pickup: bookingData['pickup'] ?? '',
                                                dropPoints:
                                                    bookingData['dropPoints'] ?? [],
                                                cityName:
                                                    bookingData['cityName'] ?? '',
                                                address:
                                                    bookingData['address'] ?? '',
                                                zipCode:
                                                    bookingData['zipCode'] ?? '',
                                                unitTypeName: bookingData['type']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? bookingData['type'][0]
                                                            ['typeName'] ??
                                                        ''
                                                    : '',
                                                id: widget.id,
                                                partnerId:
                                                    bookingData['partner'] ?? '',
                                                bookingStatus: bookingData['bookingStatus'] ?? '',
                                                email: widget.email,
                                              )),
                                    );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewBooking(
                                    token: widget.token,
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    id: widget.id,email: widget.email,)),
                          );
                        }
                      } catch (e) {
                        // Handle errors here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error fetching booking details: $e')),
                        );
                      }
                    }),
                ListTile(
                    leading: SvgPicture.asset('assets/booking_history.svg',
                        height: MediaQuery.of(context).size.height * 0.035),
                    title: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'booking_history'.tr(),
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingHistory(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email,
                          ),
                        ),
                      );
                    }),
                ListTile(
                    leading: SvgPicture.asset('assets/payment_logo.svg'),
                    title: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'payment'.tr(),
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Payment(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email,
                          ),
                        ),
                      );
                    }),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10, top: 15),
                  child: Text('more_info_and_support'.tr(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                    leading: Icon(Icons.account_balance_outlined,size: 35,),
                    title: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Invoice'.tr(),style: TextStyle(fontSize: 25),),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInvoice(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                        ),
                      );
                    }
                ),
                ListTile(
                  leading: SvgPicture.asset('assets/report_logo.svg'),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'report'.tr(),
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSubmitTicket(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset('assets/help_logo.svg'),
                  title: Padding(
                    padding: EdgeInsets.only(left: 7),
                    child: Text(
                      'help'.tr(),
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> UserHelp(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        )));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.phone,
                    size: 30,
                    color: Color(0xff707070),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'contact_us'.tr(),
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 30,
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'logout'.tr(),
                      style: TextStyle(fontSize: 25, color: Colors.red),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 10),
                                child: Text(
                                  'are_you_sure_you_want_to_logout'.tr(),
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('yes'.tr()),
                              onPressed: () async {
                                await clearUserData();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserLogin()),
                                );
                              },
                            ),
                            TextButton(
                              child: Text('no'.tr()),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: isSwipeEnabled
                ? () async {
                    await fetchRefreshVendor();
                }
                : () async {
              if (widget.cityName != null) {
                fetchAddressCoordinates();
              } else {
                fetchCoordinates();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Swipe to refresh will be enabled after 3 minutes'.tr())),
              );
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: FutureBuilder(
                future: booking,
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('An error occurred: ${snapshot.error}'));
                  }  else if (snapshot.hasData && snapshot.data != null){
                    return Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: MediaQuery.sizeOf(context).height * 0.45,
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
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Builder(
                                        builder: (context) => Center(
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              onPressed: () {
                                                Scaffold.of(context).openDrawer();
                                              },
                                              icon: const Icon(Icons.more_vert_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: SvgPicture.asset('assets/moving_truck.svg'),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      alignment: Alignment.center,
                                                      // height: 50,
                                                      width:
                                                      MediaQuery.sizeOf(context).width *
                                                          0.5,
                                                      child: Column(
                                                        children: [
                                                          Text('Booking id'.tr()),
                                                          Text(widget.bookingId),
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
                                            onPressed: showConfirmationDialog,
                                            icon: const Icon(FontAwesomeIcons.multiply)),
                                      ),
                                    ],
                                  ),
                                )),
                            Positioned(
                                bottom: 15,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0), // Rounded corners
                                        side: const BorderSide(
                                          color: Color(0xffE0E0E0), // Border color
                                          width: 1, // Border width
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    'Unit'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: widget.unit == 'null'
                                                      ? Text('no_data'.tr())
                                                      : Text(
                                                    widget.unit.tr(),
                                                    style: TextStyle(fontSize: 14),
                                                  )),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  height: 35,
                                                  child: const VerticalDivider(
                                                    color: Colors.grey,
                                                    thickness: 1,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    'Load'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: widget.load == 'null'
                                                      ? Text('No data')
                                                      : Text(
                                                    widget.load.tr(),
                                                    style: TextStyle(fontSize: 14),
                                                  )),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    'UnitType'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: widget.unitType == 'null'
                                                      ? Text('no_data'.tr())
                                                      : Text(
                                                    widget.unitType.tr(),
                                                    style: TextStyle(fontSize: 14),
                                                  )),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  height: 40,
                                                  child: const VerticalDivider(
                                                    color: Colors.grey,
                                                    thickness: 1,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 5,
                                                  child: Text(
                                                    'Size'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: widget.size == 'null'
                                                      ? Text('no_data'.tr())
                                                      : Text(
                                                    widget.size.tr(),
                                                    style: TextStyle(fontSize: 14),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 30, top: 20, bottom: 15),
                            child: Text(
                              'Choose your Vendor'.tr(),
                              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            if (isFetching) LinearProgressIndicator(),
                            vendors.isEmpty
                                ? isStopped
                                ? Center(child: Text('No vendors available'.tr()))
                                : Center(child: Text('Fetching vendors...'.tr()))
                                : Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: vendors.length,
                                itemBuilder: (context, index) {
                                  final vendor = vendors[index];
                                  final partnerId = vendor['partnerId']?.toString() ?? 'No partnerId';
                                  final oldQuotePrice = vendor['oldQuotePrice']?.toString() ?? 'No oldQuotePrice';
                                  final partnerName = vendor['partnerName']?.toString() ?? 'No Name';
                                  final quotePriceStr = vendor['quotePrice']?.toString() ?? '0';
                                  final quotePrice = double.tryParse(quotePriceStr) ?? 0;
                                  paymentStatus = vendor?['paymentStatus'];
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: RadioListTile<String>(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            flex:2,
                                            child: Text(
                                              '$partnerName',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: selectedVendorId == index.toString() ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:4,
                                            child: Text(
                                              '$quotePrice SAR',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: selectedVendorId == index.toString() ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      value: index.toString(),
                                      groupValue: selectedVendorId,
                                      onChanged: (String? value) {
                                        if (!mounted) return;
                                        setState(() {
                                          selectedPartnerName = partnerName;
                                          selectedPartnerId = partnerId;
                                          selectedQuotePrice = quotePrice.toStringAsFixed(2);
                                          selectedOldQuotePrice = oldQuotePrice;
                                          selectedVendorId = value;
                                          fullAmount = quotePrice.round();
                                          advanceAmount = (quotePrice / 2).round();
                                          try {
                                            fullPayAmount = fullAmount.toDouble();
                                            advancePayAmount = advanceAmount.toDouble();
                                          } catch (e) {
                                            print('Error parsing amount: $e');
                                            fullPayAmount = 0.0;
                                            advancePayAmount = 0.0;
                                          }
                                          stopFetching();
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  }
                  else {
                    return Center(child: Text('Please try again....'));
                  }
                }
              ),
            ),
          ),
            floatingActionButton: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 15, top: 15),
                      child: Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.055,
                          width: MediaQuery.of(context).size.width * 0.53,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6269FE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            // Pay Advance button with "Completed" status string
                            onPressed: selectedVendorId == null || selectedPartnerName == null || selectedPartnerId == null
                                ? null
                                : () {
                              initiateStripePayment(
                                context,
                                advancePayAmount,
                                true,
                                selectedPartnerName!,
                                selectedPartnerId!,
                                selectedOldQuotePrice!,
                                selectedQuotePrice!,
                                  "HalfPaid",
                                advanceAmount
                              );
                            },
                            child: Text(
                              '${'Pay Advance :'.tr()} \n $advanceAmount SAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 0, bottom: 15),
                      child: Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.055,
                          width: MediaQuery.of(context).size.width * 0.53,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2229BF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            // Full payment button with "Paid" status string
                            onPressed: selectedVendorId == null || selectedPartnerName == null || selectedPartnerId == null
                                ? null
                                : () async {
                              initiateStripePayment(
                                context,
                                fullPayAmount,
                                false,
                                selectedPartnerName!,
                                selectedPartnerId!,
                                selectedOldQuotePrice!,
                                selectedQuotePrice!,
                                "Paid",
                                fullAmount
                              );
                            },
                            child: Text(
                              '${'Pay :'.tr()} $fullAmount SAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}


