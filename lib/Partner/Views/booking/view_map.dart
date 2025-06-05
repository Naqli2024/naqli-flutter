import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerEditProfile.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerHelp.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/submitTicket.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

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
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  String paymentStatus ='';
  String bookingStatus = '';
  String ?balance;
  String errorMessage = '';
  Map<String, dynamic>? bookingDetails;
  bool isTerminating = false;
  String? operatorId;
  DriverLocation? driverLocation;
  BitmapDescriptor? customArrowIcon;
  Timer? _locationTimer;
  List<Map<String, dynamic>>? partnerData;
  String? partnerProfileImage;

  @override
  void initState() {
    super.initState();
    paymentStatus = widget.paymentStatus;
    _moveCameraToFitAllMarkers();
    fetchAddressCoordinates();
    _fetchCoordinates();
    _requestPermissions();
    fetchBookingDetails();
    _startDriverLocationUpdates();
    _loadCustomMarker();
    fetchPartnerProfile();
    remainingBalance = widget.remainingBalance;
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

  Future<void> _requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
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
        dropLatLng!=[];
      });

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

              polylines.clear();
              dropLatLng!=[];
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

        }
      } else {

      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
      setState(() {
        remainingBalance =
            updatedRemainingBalance;
      });
    } else {
     return;
    }
  }

  Future<void> fetchBookingDetails() async {
    try {
      final details = await _authService.getBookingId(
        widget.bookingId,
        widget.token,
        '',
        widget.quotePrice,
      );
      setState(() {
        if (details != null && details.isNotEmpty) {
          bookingDetails = details;
          paymentStatus = bookingDetails?['paymentStatus'];
          bookingStatus = bookingDetails?['bookingStatus'];
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

  Future<List<Map<String, dynamic>>> fetchPartnerProfile() async {
    try {
      final bookingIds = await _authService.getBookingData(
          widget.partnerId, widget.token);

      if (bookingIds.isEmpty) {
        return [];
      }
      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final profileImage = booking['profileImage'];
        partnerProfileImage = profileImage;
        return bookingDetails;
      }
      return bookingDetails;
    }catch (e) {
      return [];
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
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.partnerName,
            userId: widget.partnerId
        ),
        drawer: commonWidgets.createDrawer(context,
            widget.partnerId,
            widget.partnerName,
            profileImage: partnerProfileImage,
            onEditProfilePressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PartnerEditProfile(partnerName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,)
                ),
              );
            },
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
            },
            onHelpPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerHelp(partnerName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,),
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
                Column(
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.43,
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
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            remainingBalance == '0' || paymentStatus == 'Completed'
                                ? Container()
                                : Padding(
                              padding: EdgeInsets.only(left: 50, right: 50,top: 10,bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Pending Amount'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22:17),
                                  ),
                                  Text(
                                    remainingBalance != null
                                        ? '$remainingBalance SAR'
                                        : 'N/A',
                                    style:
                                    TextStyle(color: Color(0xffAD1C86), fontSize: viewUtil.isTablet?22:17),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Additional Charges'.tr(),
                              style: TextStyle(fontSize: viewUtil.isTablet?22:17),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 70, right: 70),
                              child: TextFormField(
                                controller: chargesController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            _buildTextField('Reason'.tr(), reasonController),
                            Visibility(
                              visible: paymentStatus == 'Completed' || paymentStatus == 'Paid' ,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15,bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_sharp,color: Colors.green,size: 30,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text('Payment Successful!!'.tr() ,style: TextStyle(color: Colors.green,fontSize: viewUtil.isTablet?26:20,fontWeight: FontWeight.w500),),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 0, left: 20,bottom: 20),
                              height: MediaQuery.of(context).size.height * 0.06,
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
                                        ? commonWidgets.showToast('Please add Additional charges and Reason'.tr())
                                        : requestPayment();
                                  },
                                  child: Text(
                                    'Request Payment'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: viewUtil.isTablet?22:15,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                        color: Color(0xffE0E0E0),
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
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'User name'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    widget.userName,
                                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16),
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
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'User id'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    widget.userId,
                                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Mode'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    widget.mode.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16),
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
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Booking Status'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    bookingStatus.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16),
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
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'PaymentStatus'.tr(),
                                                    style: TextStyle(
                                                        color: Color(0xff79797C),
                                                        fontSize: viewUtil.isTablet?22:16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    paymentStatus.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet?22:16),
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
                                    child: widget.pickupPoint.isNotEmpty
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
                                          child: Text(widget.pickupPoint,style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_pin,color: Colors.red),
                                            Text("DropPoint Location".tr(),style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17,fontWeight: FontWeight.w500))
                                          ],
                                        ),
                                        Text(widget.dropPoint,style: TextStyle(fontSize: viewUtil.isTablet? 23 : 17)),
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

  Widget _buildTextField(String hintText, controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
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
                return '${'Please enter'.tr()} $hintText';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

}




