import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:webview_flutter/webview_flutter.dart';

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
  final String email;
  final String partnerName;
  final String partnerId;
  final num oldQuotePrice;
  final String paymentStatus;
  final num quotePrice;
  final num advanceOrPay;
  final String bookingStatus;

  const PendingPayment({super.key, required this.bookingId, required this.unit, required this.unitType, required this.load, required this.size, required this.pickup, required this.dropPoints, required this.cityName, required this.address, required this.zipCode, required this.token, required this.firstName, required this.lastName, required this.selectedType, required this.unitTypeName, required this.id, required this.partnerName, required this.partnerId, required this.oldQuotePrice, required this.paymentStatus, required this.quotePrice, required this.advanceOrPay, required this.bookingStatus, required this.email});

  @override
  State<PendingPayment> createState() => _PendingPaymentState();
}

class _PendingPaymentState extends State<PendingPayment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final SuperUserServices superUserServices = SuperUserServices();
  String vendorName = 'Vendor name';
  String unit = 'unit';
  String operatorName = 'Operator Name';
  String mode = 'Mode';
  num advanceOrPay = 0;
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
  int zeroQuotePrice = 0;
  Future<Map<String, dynamic>?>? booking;
  bool isOtherCardTapped = false;
  bool isMADATapped = false;
  String? checkOutId;
  String? integrityId;
  String? resultCode;
  String? paymentResult;
  String? operatorId;
  DriverLocation? driverLocation;
  BitmapDescriptor? customArrowIcon;
  Timer? _locationTimer;
  late WebViewController webViewController;

  @override
  void initState() {
    fetchAddressCoordinates();
    fetchCoordinates();
    fetchPartnerData();
    fetchAndSetBookingDetails();
    _startDriverLocationUpdates();
    _loadCustomMarker();
    super.initState();
  }

  void _startDriverLocationUpdates() async {
    await fetchPartnerData();
    await fetchDriverCoOrdinatesAndUpdateMarker();
    _locationTimer = Timer.periodic(Duration(seconds: 10), (_) {
      fetchDriverCoOrdinatesAndUpdateMarker();
    });
  }

  Future<void> fetchDriverCoOrdinatesAndUpdateMarker() async {
    try {
      if (operatorId == null || operatorId!.isEmpty) return;

      driverLocation = await userService.fetchDriverLocation(widget.partnerId, operatorId!);
      if (driverLocation != null && customArrowIcon != null) {
        LatLng target = LatLng(driverLocation!.latitude, driverLocation!.longitude);

        setState(() {
          markers.removeWhere((marker) => marker.markerId == MarkerId('driver'));

          markers.add(
            Marker(
              markerId: MarkerId('driver'),
              position: target,
              infoWindow: InfoWindow(title: 'Driver Location'),
              icon: customArrowIcon ?? BitmapDescriptor.defaultMarker,
            ),
          );
        });

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred, Please try again.');
    }
  }

  void _loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/arrow.png');
    final Uint8List markerImage = byteData.buffer.asUint8List();

    img.Image? originalImage = img.decodeImage(markerImage);

    if (originalImage != null) {
      img.Image resizedImage = img.copyResize(originalImage, width: 200, height: 200);

      final Uint8List resizedMarkerImage = Uint8List.fromList(img.encodePng(resizedImage));

      customArrowIcon = BitmapDescriptor.fromBytes(resizedMarkerImage);

      setState(() {});
    }
  }

  Future<void> fetchPartnerData() async {
    try {
      final data = await userService.getPartnerData(widget.partnerId, widget.token,widget.bookingId);
      if (data.isNotEmpty) {
        setState(() {
          partnerData = data;
          operatorId = partnerData?[0]['operatorId'] ?? 'N/A';
        });
      } else {
        return;
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
              polylines.clear();
              _dropLatLngs.clear();
            });
          } else {
            return;
          }
        } else {
          return;
        }

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mapController != null && pickupLatLng != null) {
            _moveCameraToFitAllMarkers();
          }
        });
      } else {
        return;
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> fetchAddressCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';


      String cityName = widget.cityName.trim();
      String address = widget.address.trim();
      String zipCode = widget.zipCode.trim();


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
      commonWidgets.showToast('An error occurred,Please try again.');
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

  Future<void> fetchAndSetBookingDetails() async {
    final bookingDetails = await _fetchBookingDetails();
    if (bookingDetails != null) {
      setState(() {
        advanceOrPay = bookingDetails['remainingBalance'] ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder:  (context) => UserType(
          firstName: widget.firstName,
          lastName: widget.lastName,
          token: widget.token,
          id: widget.id,
          quotePrice: widget.quotePrice,
          oldQuotePrice: widget.oldQuotePrice,
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
            User: widget.firstName +' '+ widget.lastName,showLeading: false,
              userId: widget.id
          ),
          body: RefreshIndicator(
            onRefresh: () async{
              await fetchPartnerData();
              fetchAndSetBookingDetails();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                          },
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(0, 0), // Default position
                            zoom: 5,
                          ),
                          markers: markers,
                          polylines: polylines,
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                            ),
                          },
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            widget.paymentStatus == 'Pending' || widget.paymentStatus == 'HalfPaid'
                                ?Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 50,right: 50,top: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Pending Amount'.tr(),
                                        style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 21,fontWeight: FontWeight.w500),
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
                                        style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 21,color: Color(0xff914F9D)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20,left: 10),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.06,
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff6269FE),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        onPressed: (){
                                          showSelectPaymentDialog(widget.advanceOrPay,widget.partnerId,widget.bookingId);
                                        },
                                        child: Text(
                                          '${'Pay :'.tr()} ${widget.advanceOrPay} SAR',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: viewUtil.isTablet ? 24 : 17,
                                              fontWeight: FontWeight.w500),
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
                                    child: Text('Payment Successful!!'.tr() ,style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet ? 25 : 20,fontWeight: FontWeight.w500),),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Positioned(
                      top: 15,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                        padding: const EdgeInsets.only(left: 15,right: 15),
                                        child: SvgPicture.asset('assets/moving_truck.svg',height: viewUtil.isTablet?50: 35),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            alignment: Alignment.center,
                                            // height: 50,
                                            width: MediaQuery.sizeOf(context).width * 0.55,
                                            child: Column(
                                              children: [
                                                Text('Booking id'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                                Text(widget.bookingId,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
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
                                          email: widget.email,
                                        )));
                                  },
                                  icon: Icon(FontAwesomeIcons.multiply)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.06,
              child: FloatingActionButton(
                backgroundColor: const Color(0xff6069FF),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onPressed: (){
                  _showModalBottomSheet(context);
                },child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text('View Details'.tr(),
                        textDirection: ui.TextDirection.ltr,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: viewUtil.isTablet ? 25 : 17),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(Icons.arrow_forward,color: Colors.white,),
                    )
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,StateSetter setState){
            return Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.7,
                  minChildSize: 0,
                  maxChildSize: 0.8,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.sizeOf(context).width,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Text("Booking Details".tr(),style: TextStyle(fontSize: viewUtil.isTablet? 25 : 20,fontWeight: FontWeight.w500)),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      viewUtil.isTablet?25 :15,
                                      viewUtil.isTablet?25 :20,
                                      viewUtil.isTablet?25 :15,
                                      10
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
                                                    'Vendor Name'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize:viewUtil.isTablet ? 20 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    partnerData?[0]['partnerName'] ?? 'N/A',
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                                                    'Operator Name'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet ? 20 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    partnerData != null && partnerData!.isNotEmpty
                                                        ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                                        ? (partnerData?[0]['operatorName'] ?? 'N/A'.tr())
                                                        : (partnerData?[0]['assignOperatorName'] ?? 'N/A'.tr()))
                                                        : 'no_data'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                                                    'Operator Mobile'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet ? 20 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    partnerData != null && partnerData!.isNotEmpty
                                                        ? (partnerData?[0]['type'] == 'singleUnit + operator'
                                                        ? (partnerData?[0]['mobileNo'] ?? 'N/A'.tr())
                                                        : (partnerData?[0]['assignOperatorMobileNo'] ?? 'N/A'.tr()))
                                                        : 'no_data'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                                                    'Unit'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet ? 20 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    widget.unit.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                                                    'Booking Status'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet ? 20 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    widget.bookingStatus.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                                  child: widget.pickup.isNotEmpty
                                    ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_pin,color: Colors.green),
                                          Text("Pickup Location".tr(),style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17,fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: Text(widget.pickup,style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_pin,color: Colors.red),
                                          Text("DropPoint Location".tr(),style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17,fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                      Text(widget.dropPoints.join(', '),style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
                                    ],
                                  )
                                      : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_pin,color: Colors.blue),
                                          Text("Address".tr(),style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17,fontWeight: FontWeight.w500))
                                        ],
                                      ),
                                      Text(widget.cityName,style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
                                      Text(widget.address,style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.cancel,color: Colors.grey,size: 25,),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showSelectPaymentDialog(num amount,String partnerId,String bookingId) {
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
                          await initiatePayment('MADA', amount);
                          showPaymentDialog(checkOutId??'', integrityId??'', true,amount,partnerId,bookingId);
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
                          await initiatePayment('OTHER', amount);
                          showPaymentDialog(checkOutId??'', integrityId??'', false,amount,partnerId,bookingId);
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

  Future initiatePayment(String paymentBrand,num amount) async {
    setState(() {
      commonWidgets.loadingDialog(context, true);
    });
    final result = await superUserServices.choosePayment(
      context,
      userId: widget.id,
      paymentBrand: paymentBrand,
      amount: amount,
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

  void showPaymentDialog(String checkOutId, String integrity, bool isMADATapped, num amount, String partnerID, String bookingId) {
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                onContinuePressed: () async {
                  await userService.updatePayment(
                    widget.token,
                    amount,
                    'Completed',
                    partnerID,
                    bookingId,
                    amount * 2,
                    0,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PaymentCompleted(
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
                      email: widget.email,
                    ),),
                  );
                },
              ),
            ),
          );
          Future.delayed(Duration(seconds: 3), () async {
            await userService.updatePayment(
              widget.token,
              amount,
              'Completed',
              partnerID,
              bookingId,
              amount * 2,
              0,
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PaymentCompleted(
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
                email: widget.email,
              ),),
            );
          });
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PaymentFailureScreen(
                paymentStatus: paymentResult??'',
                onRetryPressed:() {
                  Navigator.of(context).push(
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
                      partnerName: widget.partnerName,
                      partnerId: partnerID,
                      oldQuotePrice: widget.oldQuotePrice,
                      paymentStatus: widget.paymentStatus,
                      quotePrice: amount,
                      advanceOrPay: widget.advanceOrPay,
                      bookingStatus: bookingStatus??'',
                      email: widget.email,
                    ),),
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

}
