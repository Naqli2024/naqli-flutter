import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
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
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart'as permissionHandler;
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

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
  final SuperUserServices superUserServices = SuperUserServices();
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
  num fullAmount = 0;
  num advanceAmount = 0;
  bool isLoading = true;
  bool isDeleting = false;
  bool isFetching = false;
  Timer? timer;
  Map<String, dynamic>? paymentIntent;
  bool isTimeout = false;
  num fullPayAmount = 0;
  num advancePayAmount = 0;
  Future<Map<String, dynamic>?>? booking;
  Timer? _refreshTimer;
  Timer? _fetchTimer;
  bool isStopped = false;
  bool isPayAdvance = false;
  String? selectedPartnerName;
  String? selectedPartnerId;
  num? selectedOldQuotePrice;
  num? selectedQuotePrice;
  String? updatedPaymentStatus;
  String? bookingStatus;
  Timer? _cycleTimer;
  Timer? _timeoutTimer;
  int fetchedVendorsCount = 0;
  String zeroQuotePrice = '0';
  bool isSwipeEnabled = false;
  String currentPlace = '';
  String? checkOutId;
  String? integrityId;
  String? resultCode;
  String? paymentResult;
  bool isOtherCardTapped = false;
  bool isMADATapped = false;
  late Future<UserDataModel> userData;
  late WebViewController webViewController;

  @override
  void initState() {
    startVendorFetching();
    _moveCameraToFitAllMarkers();
    fetchAddressCoordinates();
    fetchCoordinates();
    booking = _fetchBookingDetails();
    userData = userService.getUserData(widget.id,widget.token);
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

      if (fetchedVendorsNullable == null) {
        setState(() {
          isFetching = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedVendors;
      try {
        fetchedVendors = List<Map<String, dynamic>>.from(fetchedVendorsNullable);
      } catch (e) {
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
      num amount,
      String paymentStatus,
      String partnerId,
      String bookingId,
      num oldQuotePrice) async {
    try {

      final response = await userService.updatePayment(
          widget.token,
          amount,
          paymentStatus,
          partnerId,
          bookingId,
          amount*2,
          oldQuotePrice,
        );

      if (response == null || !response.containsKey('success') || response['success'] == false) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        bookingStatus = response['booking']['bookingStatus'] ?? '';
        updatedPaymentStatus = response['booking']['paymentStatus'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
            return;
          }
        } else {
          return;
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
                return;
              }
            } else {
              return;
            }
          } else {
            return;
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
              return;
            }
          } else {
            return;
          }
        }

        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
            zoom: 5,
          )),
        );

      } else {
        return;
      }
    } catch (e) {
      print(e);
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
            return;
          }
        } else {
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      print(e);
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
        return;
      }

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(pickupLatLng!.latitude, pickupLatLng!.longitude),
          zoom: 5,
        )), // Padding in pixels
      );
    } else {
      return;
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
    String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId == null && widget.id != null && widget.token != null) {
      bookingId = await userService.getPaymentPendingBooking(widget.id, widget.token);

      if (bookingId == null || bookingId.isEmpty) {
        bookingId = await userService.getBookingByUserId(widget.id, widget.token);
      }

      if (bookingId == null || bookingId.isEmpty) {
        return null;
      }
    }

    if (bookingId != null && widget.token != null) {
      final bookingDetails = await userService.fetchBookingDetails(bookingId, widget.token);

      if (bookingDetails != null) {
        return bookingDetails;
      } else {
        print("Booking details returned null from API.");
      }
    } else {
      print("Either bookingId or token is null, cannot fetch details.");
    }
    return null;
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
      commonWidgets.showToast('Error deleting booking: $e');
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  void showConfirmationDialog() {
    ViewUtil viewUtil = ViewUtil(context);
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: viewUtil.isTablet ? 22 :17),
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
      if (fetchedVendorsNullable == null) {
        setState(() {
          isFetching = false;
        });
        return;
      }

      List<Map<String, dynamic>> fetchedVendors;
      try {
        fetchedVendors = List<Map<String, dynamic>>.from(fetchedVendorsNullable);
      } catch (e) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
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
                    leading: FutureBuilder<UserDataModel>(
                      future: userData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data?.userProfile == null) {
                          return CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 24,
                            child: Icon(Icons.person, color: Colors.grey, size: 30),
                          );
                        } else {
                          final user = snapshot.data!;
                          return CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: 24,
                            backgroundImage: NetworkImage(
                              "https://prod.naqlee.com/api/image/${user.userProfile!.fileName}",
                            ),
                          );
                        }
                      },
                    ),
                    title: Text(
                      widget.firstName +' '+ widget.lastName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      widget.id,
                      style: TextStyle(color: Color(0xff8E8D96)),
                    ),
                    trailing: Icon(Icons.edit, color: Colors.grey, size: 20),
                  )
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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
                                child: CircularProgressIndicator())),
                      );
                      try {
                        final bookingData = await booking;
                        if (bookingData != null) {
                          Navigator.pop(context);
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
                                            oldQuotePrice: 0,
                                            paymentStatus: bookingData['paymentStatus'] ?? '',
                                            quotePrice: 0,
                                              advanceOrPay: bookingData['remainingBalance']??0,
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
                          Navigator.pop(context);
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
                        Navigator.pop(context);
                        commonWidgets.showToast('Error fetching booking details: $e');
                      }
                    }),
                ListTile(
                    leading: SvgPicture.asset('assets/booking_history.svg',
                        height: viewUtil.isTablet
                            ? MediaQuery.of(context).size.height * 0.028
                            : MediaQuery.of(context).size.height * 0.035),
                    title: Padding(
                      padding: EdgeInsets.only(left: viewUtil.isTablet ?5:10),
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
                        return Directionality(
                          textDirection: ui.TextDirection.ltr,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.white,
                            contentPadding: const EdgeInsets.all(20),
                            content: Container(
                              width: viewUtil.isTablet
                                  ? MediaQuery.of(context).size.width * 0.6
                                  : MediaQuery.of(context).size.width,
                              height: viewUtil.isTablet
                                  ? MediaQuery.of(context).size.height * 0.08
                                  : MediaQuery.of(context).size.height * 0.12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 30,bottom: 10),
                                    child: Text(
                                      'are_you_sure_you_want_to_logout'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: viewUtil.isTablet?27:19),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('yes'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet?22:16),),
                                onPressed: () async {
                                  await clearUserData();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserLogin()),
                                  );
                                },
                              ),
                              TextButton(
                                child: Text('no'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
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
              commonWidgets.showToast('Swipe to refresh will be enabled after 3 minutes'.tr());
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
                                                  child: SvgPicture.asset('assets/moving_truck.svg',height: viewUtil.isTablet?50: 35),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                      alignment: Alignment.center,
                                                      width: MediaQuery.sizeOf(context).width * 0.5,
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
                                  padding: viewUtil.isTablet
                                      ? EdgeInsets.only(left: 30, right: 30)
                                      : EdgeInsets.only(left: 10, right: 10),
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                          color: Color(0xffE0E0E0),
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
                                                        fontSize: viewUtil.isTablet ? 22 : 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: widget.unit == 'null'
                                                      ? Text('no_data'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),)
                                                      : Text(
                                                    widget.unit.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),
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
                                                        fontSize: viewUtil.isTablet ? 22 : 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: widget.load == 'null'
                                                      ? Text('No data',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),)
                                                      : Text(
                                                    widget.load.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),
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
                                                        fontSize: viewUtil.isTablet ? 22 : 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 3,
                                                  child: widget.unitType == 'null'
                                                      ? Text('no_data'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),)
                                                      : Text(
                                                    widget.unitType.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 14),
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
                                                        fontSize: viewUtil.isTablet ? 22 : 16,
                                                        fontWeight: FontWeight.bold),
                                                  )),
                                              Expanded(
                                                  flex: 4,
                                                  child: widget.size == 'null'
                                                      ? Text('no_data'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14),)
                                                      : Text(
                                                    widget.size.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 14),
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
                              style: TextStyle(fontSize: viewUtil.isTablet ? 25 : 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            if (isFetching) LinearProgressIndicator(),
                            vendors.isEmpty
                                ? isStopped
                                ? Center(child: Text('No vendors available'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 14),))
                                : Center(child: Text('Fetching vendors...'.tr()))
                                : Container(
                              height: 200,
                              child: ListView.builder(
                                itemCount: vendors.length,
                                itemBuilder: (context, index) {
                                  final vendor = vendors[index];
                                  final partnerId = vendor['partnerId']?.toString() ?? '';
                                  final oldQuotePrice = vendor['oldQuotePrice'] ?? 0;
                                  final partnerName = vendor['partnerName']?.toString() ?? '';
                                  final quotePrice = vendor['quotePrice'] ?? 0;
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
                                                fontSize:  viewUtil.isTablet ? 22 : 17,
                                                fontWeight: selectedVendorId == index.toString() ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex:4,
                                            child: Text(
                                              '$quotePrice SAR',
                                              style: TextStyle(
                                                fontSize:  viewUtil.isTablet ? 22 : 17,
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
                                          selectedQuotePrice = quotePrice;
                                          selectedOldQuotePrice = oldQuotePrice;
                                          selectedVendorId = value;
                                          fullAmount = quotePrice;
                                          advanceAmount = quotePrice / 2;
                                          try {
                                            fullPayAmount = fullAmount;
                                            advancePayAmount = advanceAmount;
                                          } catch (e) {
                                            fullPayAmount = 0;
                                            advancePayAmount = 0;
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
                              isPayAdvance =true;
                              showSelectPaymentDialog(
                                  selectedQuotePrice??0,
                                  selectedPartnerId??'',
                                  selectedOldQuotePrice??0,
                                  widget.bookingId,
                                  selectedPartnerName??'',
                                  advanceAmount
                              );
                            },
                            child: Text(
                              viewUtil.isTablet
                              ?'${'Pay Advance :'.tr()} $advanceAmount SAR'
                              :'${'Pay Advance :'.tr()} \n $advanceAmount SAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:  viewUtil.isTablet ? 22 : 16,
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
                            onPressed: selectedVendorId == null || selectedPartnerName == null || selectedPartnerId == null
                                ? null
                                : () async {
                              isPayAdvance =false;
                              showSelectPaymentDialog(
                                  selectedQuotePrice??0,
                                  selectedPartnerId??'',
                                  selectedOldQuotePrice??0,
                                  widget.bookingId,
                                  selectedPartnerName??'',
                                  advanceAmount
                              );
                            },
                            child: Text(
                              '${'Pay :'.tr()} $fullAmount SAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:  viewUtil.isTablet ? 22 : 16,
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

  void showSelectPaymentDialog(num amount,String partnerId,num oldQuotePrice,String bookingId,String partnerName,num advanceAmount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 25),
            backgroundColor: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(0),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              isOtherCardTapped = false;
                              isMADATapped = false;
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            )),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isMADATapped = true;
                            isOtherCardTapped = false;
                            Navigator.pop(context);
                          });
                          await initiatePayment('MADA', amount,advanceAmount);
                          showPaymentDialog(checkOutId??'', integrityId??'', true, amount, partnerId, oldQuotePrice, bookingId, partnerName, advanceAmount);
                          },
                        child: Container(
                          color: isMADATapped
                              ? Color(0xffD4D4D4)
                              : Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pay using MADA".tr(),
                                style: TextStyle(fontSize: 18),
                              ),
                              SvgPicture.asset(
                                'assets/Mada_Logo.svg',
                                height: 25,
                                width: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isMADATapped = false;
                            isOtherCardTapped = true;
                            Navigator.pop(context);
                          });
                          await initiatePayment('OTHER', amount,advanceAmount);
                          showPaymentDialog(checkOutId??'', integrityId??'',false,amount,partnerId,oldQuotePrice,bookingId,partnerName,advanceAmount);
                        },
                        child: Container(
                          color: isOtherCardTapped
                              ? Color(0xffD4D4D4)
                              : Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("Pay using Other Card Types".tr(),
                                    style: TextStyle(fontSize: 18)),
                              ),
                              SvgPicture.asset('assets/visa-mastercard.svg',
                                  height: 40, width: 20)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future initiatePayment(String paymentBrand,num amount,num advanceAmount) async {
    setState(() {
      commonWidgets.loadingDialog(context, true);
    });
    final result = await superUserServices.choosePayment(
      context,
      userId: widget.id,
      paymentBrand: paymentBrand,
      amount: isPayAdvance==true?advanceAmount:amount,
    );
    if (result != null) {
      setState(() {
        checkOutId = result['id'];
        integrityId = result['integrity'];
      });
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  Future<void> getPaymentStatus(String checkOutId, bool isMadaTapped) async {
    final result = await superUserServices.getPaymentDetails(context, checkOutId, isMadaTapped);
    if (result != null && result['code'] != null) {
      setState(() {
        resultCode = result['code'] ?? '';
        paymentResult = result['description'] ?? '';
      });
    } else {
      commonWidgets.showToast('Failed to retrieve payment status.');
    }
  }

  void showPaymentDialog(String checkOutId, String integrity, bool isMADATapped, num amount, String partnerID, num oldQuotePrice, String bookingId, String partnerName, num advanceAmount) {
    if (checkOutId.isEmpty || integrity.isEmpty) {
      return;
    }

    final String visaHtml = '''
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>HyperPay Payment Integration</title>
            <script>
              window['wpwlOptions'] = {
                billingAddress: {},
                mandatoryBillingFields: {
                  country: true,
                  state: true,
                  city: true,
                  postcode: true,
                  street1: true,
                  street2: false,
                },
              };
              
              function loadPaymentScript(checkoutId, integrity) {
                const script = document.createElement('script');
                script.src = "https://eu-prod.oppwa.com/v1/paymentWidgets.js?checkoutId=" + checkoutId;
                script.crossOrigin = 'anonymous';
                script.integrity = integrity;
                document.body.appendChild(script);
              }
              
              document.addEventListener("DOMContentLoaded", function () {
                loadPaymentScript("${checkOutId}", "${integrity}");
              });
            </script>
          </head>
          <body>
            <form action="https://naqlee.com/payment/results" method="POST" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
          </body>
        </html>
        ''';

  final String madaHtml = visaHtml.replaceAll("VISA MASTER AMEX", "MADA");
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
              child: CircularProgressIndicator())),
    );
    webViewController = WebViewController()
    ..setBackgroundColor(Colors.transparent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..addJavaScriptChannel(
      'NavigateToFlutter',
      onMessageReceived: (JavaScriptMessage message) async {
        await getPaymentStatus(checkOutId, isMADATapped);
        if (resultCode == "000.000.000") {
          if(isPayAdvance == true)
          {
            advancePaymentSuccessDialog(advanceAmount);
            Future.delayed(Duration(seconds: 3), () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessScreen(
                    onContinuePressed: () async {
                      await fetchPaymentData(advanceAmount,'HalfPaid',partnerID,bookingId,oldQuotePrice);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => PendingPayment(
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
                          partnerId: partnerID,
                          oldQuotePrice: oldQuotePrice,
                          paymentStatus: updatedPaymentStatus.toString(),
                          quotePrice: amount,
                          advanceOrPay: advanceAmount,
                          bookingStatus: bookingStatus??'',
                          email: widget.email,
                        ),),
                      );
                    },
                  ),
                ),
              );
              Future.delayed(Duration(seconds: 3), () async {
                await fetchPaymentData(advanceAmount,'HalfPaid',partnerID,bookingId,oldQuotePrice);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => PendingPayment(
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
                    partnerId: partnerID,
                    oldQuotePrice: oldQuotePrice,
                    paymentStatus: updatedPaymentStatus.toString(),
                    quotePrice: amount,
                    advanceOrPay: advanceAmount,
                    bookingStatus: bookingStatus??'',
                    email: widget.email,
                  ),),
                );
              });
            });
          }
          else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PaymentSuccessScreen(
                      onContinuePressed: () async {
                        await fetchPaymentData(amount, 'Paid', partnerID, bookingId, oldQuotePrice);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => PendingPayment(
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
                            partnerId: partnerID,
                            oldQuotePrice: oldQuotePrice,
                            paymentStatus: updatedPaymentStatus
                                .toString(),
                            quotePrice: amount,
                            advanceOrPay: advanceAmount,
                            bookingStatus: bookingStatus ??
                                '',
                            email: widget.email,
                          ),),
                        );
                        Future.delayed(Duration(seconds: 3), () async {
                          await fetchPaymentData(amount, 'Paid', partnerID, bookingId, oldQuotePrice);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => PendingPayment(
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
                              partnerId: partnerID,
                              oldQuotePrice: oldQuotePrice,
                              paymentStatus: updatedPaymentStatus.toString(),
                              quotePrice: amount,
                              advanceOrPay: advanceAmount,
                              bookingStatus: bookingStatus??'',
                              email: widget.email,
                            ),),
                          );
                        });
                      },
                    ),
              ),
            );
          }
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PaymentFailureScreen(
                paymentStatus: paymentResult??'',
                onRetryPressed:() {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ChooseVendor(
                      id: widget.id,
                      bookingId: bookingId,
                      size: widget.size,
                      unitType: widget.unitType,
                      unitTypeName: widget.unitTypeName,
                      load: widget.load,
                      unit: widget.unit,
                      pickup: widget.pickup,
                      dropPoints: widget.dropPoints,
                      token: widget.token,
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      selectedType: widget.selectedType,
                      cityName: widget.cityName,
                      address: widget.address,
                      zipCode: widget.zipCode,
                      email: widget.email,
                      accountType: widget.accountType,
                    )),
                  );
                },)));
        }
      },
    )
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                insetPadding: EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.42,
                    child: WebViewWidget(controller: webViewController),
                  ),
                ),
              );
            },
          );
        },
      ),
    )
    ..loadRequest(Uri.dataFromString(
      isMADATapped ? madaHtml : visaHtml,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ));
}


  void advancePaymentSuccessDialog(num amount) {
    ViewUtil viewUtil = ViewUtil(context);
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
                icon: Icon(FontAwesomeIcons.multiply,size: viewUtil.isTablet? 30 :20),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: viewUtil.isTablet
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.25,
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
                          style: TextStyle(fontSize:viewUtil.isTablet? 40 :30),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Your booking is confirmed'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet? 30 :20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${'with advance payment of'.tr()} \n SAR ${amount}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: viewUtil.isTablet? 22 :16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


