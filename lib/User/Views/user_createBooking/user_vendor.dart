import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_bookingHistory.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_payment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
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
      required this.id});

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

  @override
  void initState() {
    startVendorFetching();
    widget.selectedType == 'vehicle' || widget.selectedType == 'bus'
        ? fetchCoordinates()
        : fetchAddressCoordinates();
    fetchAddressCoordinates();
    fetchCoordinates();
    booking = _fetchBookingDetails();
    super.initState();
  }

  Future<void> fetchVendor() async {
    if (!mounted || isStopped) return; // Prevent fetching if stopped

    setState(() {
      isFetching = true;
    });

    try {
      // Fetch vendor data from the userService
      final fetchedVendorsNullable = await userService.userVehicleVendor(
        context,
        bookingId: widget.bookingId,
        unitType: widget.unitType,
        unitClassification: widget.unit,
        subClassification: widget.unitTypeName,
      );

      // Log the fetched response
      print('Fetched Vendor Response: $fetchedVendorsNullable');

      // Handle null response
      if (fetchedVendorsNullable == null) {
        print('Received null response from userService');
        setState(() {
          isFetching = false;
        });
        return;
      }

      // Parse the response
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

      List<Map<String, dynamic>> newVendors = [];
      for (var vendor in fetchedVendors) {
        bool isDuplicate = vendors.any((existingVendor) =>
        existingVendor['partnerName'] == vendor['partnerName']);

        if (!isDuplicate) {
          newVendors.add(vendor);
        } else {
          // Update existing vendor data if it's already in the list
          int index = vendors.indexWhere((existingVendor) =>
          existingVendor['partnerName'] == vendor['partnerName']);
          if (index != -1) {
            setState(() {
              vendors[index] = vendor; // Update existing vendor
            });
          }
        }
      }

      if (!mounted || isStopped) return; // Prevent updating if stopped

      setState(() {
        vendors.addAll(newVendors);
        isFetching = false;
        if (vendors.length >= 3) {
          startRefreshing();  // Start refreshing only if we have 3 vendors
        }
      });
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        isFetching = false;
      });
      print('Error fetching vendor: $e');
    }
  }


  void startRefreshing() {
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (isTimeout || isStopped) {
        t.cancel();
      } else {
        fetchVendor();
      }
    });
  }

  // Start Vendor Fetching
  void startVendorFetching() {
    setState(() {
      isFetching = true;
      isTimeout = false;
      isStopped = false; // Reset stop flag
    });

    fetchVendor();

    _fetchTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      if (vendors.length < 3 && !isTimeout && !isStopped) {
        fetchVendor();
      } else {
        t.cancel();
      }
    });

    Timer(Duration(minutes: 3), () {
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        isTimeout = true;
        isFetching = false;
      });
      if (vendors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No vendor available'),
          duration: Duration(seconds: 3),
        ));
      }
    });

    _refreshTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (isTimeout || isStopped) {
        t.cancel(); // Stop refreshing if timeout or stopped
      } else {
        fetchVendor();
      }
    });
  }

  // Stop fetching when vendor is selected
  void stopFetching() {
    setState(() {
      isStopped = true;
      isFetching = false;
    });
    _fetchTimer?.cancel();  // Cancel fetch timer
    _refreshTimer?.cancel();  // Cancel refresh timer
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
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
      ); // Amount and currency

      // Initialize the payment sheet
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
              postalCode: 'YOUR POSTAL CODE',
              state: 'YOUR STATE',
            ),
          ),
          style: ThemeMode.dark,
          merchantDisplayName: 'Your Merchant Name',
        ),
      );

      // Display the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Show success message
      Fluttertoast.showToast(msg: 'Payment successfully completed');

      if (isPayAdvance) {
        // Show confirmation dialog for advance payment
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
                        const Positioned.fill(
                          child: Center(
                            child: Text(
                              'Thank you!',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Your booking is confirmed',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'with advance payment of SAR ${amount.toStringAsFixed(2)}', // Display the amount here
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Wait for 2 seconds before navigating
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to PendingPayment screen with partnerName and partnerId
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
              advanceOrPay: advanceOrPay
            ),
          ),
        );
      } else {
        // Directly navigate to PendingPayment for full payment without dialog
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
              partnerName: partnerName, // Pass partnerName
              partnerId: partnerId,
              oldQuotePrice: oldQuotePrice,
              paymentStatus: paymentStatus,
              quotePrice: quotePrice,
              advanceOrPay: advanceOrPay
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
      // Validate and calculate amount in the smallest currency unit (e.g., cents)
      final calculatedAmount = calculateAmount(amount);

      // Prepare request body
      Map<String, dynamic> body = {
        'amount': calculatedAmount,
        'currency': currency,
      };

      // Make POST request to Stripe API
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      // Check for errors in response
      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      // Parse and return the response body
      return json.decode(response.body);
    } catch (err) {
      throw Exception('Error creating payment intent: $err');
    }
  }

  String calculateAmount(String amount) {
    try {
      final doubleAmount = double.tryParse(amount) ?? 0.0;
      final intAmount =
      (doubleAmount * 100).toInt(); // Convert to smallest currency unit
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

      // Validate city name and address
      if (cityName.isEmpty || address.isEmpty) {
        // Show an alert or a Snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please enter both city name and address to locate the place.'),
          ),
        );
        return; // Exit the function if either is missing
      }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(context,
          User: widget.firstName +' '+ widget.lastName, showLeading: false),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/naqlee-logo.svg',
                      height: MediaQuery.of(context).size.height * 0.05),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CircleAvatar(
                          child: Icon(FontAwesomeIcons.multiply)))
                ],
              ),
            ),
            const Divider(),
            ListTile(
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'Booking',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                onTap: () async {
                  try {
                    final bookingData = await booking;

                    if (bookingData != null) {
                      bookingData['paymentStatus'] == 'Pending'
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
                                        partnerId: '',
                                        oldQuotePrice: '',
                                        paymentStatus: '',
                                        quotePrice: '',
                                          advanceOrPay: 0
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
                                id: widget.id)),
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
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'Booking History',
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
                      ),
                    ),
                  );
                }),
            ListTile(
                leading: Image.asset('assets/payment_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    'Payment',
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
                      ),
                    ),
                  );
                }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 15),
              child: Text('More info and support',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Image.asset('assets/report_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Report',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Image.asset('assets/help_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Help',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.phone,
                  size: 30,
                  color: Color(0xff707070),
                ),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 17),
                child: Text(
                  'Contact us',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  'Logout',
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
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30, bottom: 10),
                            child: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Yes'),
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
                          child: const Text('No'),
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
      body: SingleChildScrollView(
        child: Column(
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
                                    Scaffold.of(context)
                                        .openDrawer(); // Opens the drawer
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
                                      child: Image.asset(
                                          'assets/moving_truck.png'),
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
                                              Text('Booking Id'),
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
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 30, bottom: 10),
                                              child: Text(
                                                'Are you sure you want to cancel ?',
                                                style: TextStyle(fontSize: 19),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () async {
                                              await userService.deleteBooking(context,widget.bookingId, widget.token);
                                              stopFetching();
                                              await clearUserData();
                                               Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserType(
                                                                firstName: widget
                                                                    .firstName,
                                                                lastName: widget
                                                                    .lastName,
                                                                token: widget
                                                                    .token,
                                                                id: widget.id,
                                                              )));
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(FontAwesomeIcons.multiply)),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 15,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      // height: MediaQuery.sizeOf(context).height * 0.1,
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
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        'Unit',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: widget.unit == 'null'
                                          ? Text('No data')
                                          : Text(
                                              widget.unit ?? '',
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
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        'Load',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: widget.load == 'null'
                                          ? Text('No data')
                                          : Text(
                                              widget.load,
                                              style: TextStyle(fontSize: 14),
                                            )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        'Unit type',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: widget.unitType == 'null'
                                          ? Text('No data')
                                          : Text(
                                              widget.unitType,
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
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        'Size',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: widget.size == 'null'
                                          ? Text('No data')
                                          : Text(
                                              widget.size,
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
              child: const Padding(
                padding: EdgeInsets.only(left: 30, top: 20, bottom: 20),
                child: Text(
                  'Choose your Vendor',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Column(
              children: [
                if (isFetching) LinearProgressIndicator(),
                vendors.isEmpty
                    ? isTimeout
                    ? Center(child: Text('No vendor available'))
                    : Center(child: Text('Fetching vendors...'))
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
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
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
                            if (!mounted) return; // Check if the widget is still mounted
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
                              stopFetching(); // Stop fetching when radio button is selected
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
        ),
      ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.19,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
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
                        'Pay Advance : $advanceAmount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, bottom: 15),
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
                          false, // Full Payment
                          selectedPartnerName!,
                          selectedPartnerId!,
                          selectedOldQuotePrice!,
                          selectedQuotePrice!,
                            "Paid",
                          fullAmount
                        );
                      },
                      child: Text(
                        'Pay : $fullAmount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}


