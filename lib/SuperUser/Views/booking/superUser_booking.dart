import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUserType.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart'as permissionHandler;
import 'dart:ui' as ui;

class SuperUserBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String selectedType;
  final String token;
  final String id;
  final String email;
  final String? accountType;
  final String? isFromUserType;
  const SuperUserBooking({super.key, required this.firstName, required this.lastName, required this.selectedType, required this.token, required this.id, required this.email, this.accountType, this.isFromUserType});

  @override
  State<SuperUserBooking> createState() => _SuperUserBookingState();
}

class _SuperUserBookingState extends State<SuperUserBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController pickUpController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final FocusNode productValueFocusNode = FocusNode();
  int _currentStep = 1;
  String? selectedLoad;
  TimeOfDay _selectedFromTime =  TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 0;
  late Future<List<Vehicle>> _futureVehicles;
  late Future<List<Buses>> _futureBuses;
  late Future<List<Equipment>> _futureEquipment;
  late Future<List<Special>> _futureSpecial;
  Map<String, String?> _selectedSubClassification = {};
  String? selectedTypeName;
  String? selectedName;
  String? scale;
  String? typeImage;
  String? typeOfLoad;
  List<String> loadItems = [];
  int? selectedBus;
  int? selectedSpecial;
  List<TextEditingController> _dropPointControllers = [
    TextEditingController(),
  ];
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  final List<LatLng> _dropLatLngs = [];
  final String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
  Map<int, List<String>> _dropPointSuggestions = {};
  late List<String> _pickUpSuggestions = [];
  late List<String> _cityNameSuggestions = [];
  late List<String> _addressSuggestions = [];
  late List<String> _zipCodeSuggestions = [];
  Future<Map<String, dynamic>?>? booking;
  String currentPlace = '';
  int typeCount = 0;
  bool isLocating = false;


  @override
  void initState() {
    super.initState();
    _futureVehicles = userService.fetchUserVehicle();
    _futureBuses = userService.fetchUserBuses();
    _futureEquipment = userService.fetchUserEquipment();
    _futureSpecial = userService.fetchUserSpecialUnits();
    fetchLoadsForSelectedType(selectedTypeName ?? '');
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          userId: widget.id,
          showLeading: true,
          showLanguage: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Text(
                      widget.isFromUserType != null
                          ?'createBooking'.tr()
                          :'Get an estimate'.tr(),
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      widget.isFromUserType != null
                          ?'${'step'.tr()} $_currentStep ${'of 3 - booking'.tr()}'
                          :'${'step'.tr()} $_currentStep ${'of 3'.tr()}',
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> SuperUsertype(
                        firstName: widget.firstName,
                        lastName: widget.lastName, token: widget.token,id: widget.id,email: widget.email,)));
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
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
                leading: Icon(Icons.home,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Home'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuperUserHomePage(firstName: widget.firstName, lastName: widget.lastName, token: widget.token, id: widget.id, email: widget.email)
                    ),
                  );
                },
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/booking_logo.svg',
                      height: MediaQuery.of(context).size.height * 0.035),
                  title: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text('Trigger Booking'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TriggerBooking(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        ),
                      ),
                    );
                  }
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/booking_manager.svg'),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Booking Manager'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingManager(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        ),
                      ),
                    );
                  }
              ),
              ListTile(
                leading: SvgPicture.asset('assets/payment.svg'),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Payments'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuperUserPayment(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          email: widget.email
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                  leading: Icon(Icons.account_balance_outlined,size: 35,),
                  title: Text('Invoice'.tr(),style: TextStyle(fontSize: 25),),
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
                  child: Text('report'.tr(),style: TextStyle(fontSize: 25),),
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
                  child: Text('help'.tr(),style: TextStyle(fontSize: 25),),
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
                leading: Icon(Icons.logout,color: Colors.red,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('logout'.tr(),style: TextStyle(fontSize: 25,color: Colors.red),),
                ),
                onTap: () {
                  showLogoutDialog();
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStep(1),
                    _buildLine(),
                    _buildStep(2),
                    _buildLine(),
                    _buildStep(3),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildStepContent(_currentStep),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: MediaQuery.sizeOf(context).height * 0.11,
          color: Colors.white,
          child:  Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_currentStep == 1) Container(),
                if (_currentStep > 1)
                  Container(
                    padding: const EdgeInsets.only(left: 12, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_currentStep > 1) {
                            if (_currentStep == 2) {
                              selectedLoad = null;
                            }
                            _currentStep--;
                          }
                        });
                      },
                      child: Text(
                        'back'.tr(),
                        style: TextStyle(
                            color: Color(0xff6269FE),
                            fontSize: 21,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                if (_currentStep < 3)
                  Container(
                    padding: const EdgeInsets.only(right: 10, bottom: 5,top:5),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.055,
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async{
                          setState(() {
                            if (widget.selectedType == 'vehicle') {
                              if (_currentStep == 1) {
                                if (selectedTypeName == null) {
                                  commonWidgets.showToast('Please select an option'.tr());
                                } else {
                                  _currentStep++;
                                }
                              }else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null ||
                                    productController.text.isEmpty) {
                                  commonWidgets.showToast('Please fill all fields'.tr());
                                } else {
                                  fetchLoadsForSelectedType(selectedTypeName ?? '').then((loadTypes) {
                                    print('Fetched loadTypes: $loadTypes');
                                    if (loadTypes.isEmpty || selectedLoad !=null) {

                                      setState(() {
                                        _currentStep++;
                                      });
                                    } else {
                                      if (loadTypes.isNotEmpty) {
                                        commonWidgets.showToast('Please select Load type'.tr());
                                      }
                                    }
                                  }).catchError((error) {
                                    print('Error fetching load types: $error');
                                    commonWidgets.showToast('Error fetching load types');
                                  });
                                }
                              }
                            }
                            if (widget.selectedType == 'bus') {
                              if (_currentStep == 1) {
                                if (selectedBus == null) {
                                  commonWidgets.showToast('Please select Bus'.tr());
                                } else {
                                  _currentStep++;
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null ||
                                    productController.text.isEmpty) {
                                  commonWidgets.showToast('Please fill all fields'.tr());
                                } else {
                                  _currentStep++;
                                }
                              }
                            }
                            if (widget.selectedType == 'equipment') {
                              if (_currentStep == 1) {
                                if (selectedTypeName ==null) {
                                  commonWidgets.showToast('Please select an option'.tr());
                                } else {
                                  _currentStep++;
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null) {
                                  commonWidgets.showToast('Please fill all fields'.tr());
                                } else {
                                  _currentStep++;
                                }
                              }
                            }
                            if (widget.selectedType == 'special' || widget.selectedType == 'others') {
                              if (_currentStep == 1) {
                                if (selectedSpecial ==null) {
                                  commonWidgets.showToast('Please select Special/Other Units'.tr());
                                } else {
                                  _currentStep++;
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null) {
                                  commonWidgets.showToast('Please fill all fields'.tr());
                                } else {
                                  _currentStep++;
                                }
                              }
                            }
                          });
                        },
                        child: Text(
                          'next'.tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep == 3)
                  Container(
                    padding: const EdgeInsets.only(right: 10, bottom: 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.055,
                      width: MediaQuery.of(context).size.width * 0.52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            createBooking();
                          });
                        },
                        child: Text(
                          'createBooking'.tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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

  void showLogoutDialog(){
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30,bottom: 10),
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
                    MaterialPageRoute(builder: (context) => UserLogin()),
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
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _dropPointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTextField() {
    setState(() {
      final newController = TextEditingController();
      _dropPointControllers.add(newController);
    });
  }

  void _removeTextField(int index) {
    setState(() {
      _dropPointSuggestions.remove(index); // Remove entry by index
      _dropPointControllers.removeAt(index);
    });
  }

  void _dismissSuggestions() {
    setState(() {
      _pickUpSuggestions = [];
      for (var i = 0; i < _dropPointSuggestions.length; i++) {
        _dropPointSuggestions[i] = [];
      }
    });
  }

  Future<void> _requestPermissions() async {
    var status = await permissionHandler.Permission.location.status;
    if (!status.isGranted) {
      await permissionHandler.Permission.location.request();
    }
  }

  Future<void> locateCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 10.0),
        );
      }

      setState(() {
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation,
            infoWindow: InfoWindow(
              title: 'your_location'.tr(),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  Future<void> currentPositionSuggestion() async {
    setState(() {
      isLocating = true;
    });
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String reverseGeocodeUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentPosition.latitude},${currentPosition.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(reverseGeocodeUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data['status'] == 'OK') {
        final formattedAddress = data['results'][0]['formatted_address'];

        setState(() {
          pickUpController.text = formattedAddress;
          isLocating = false;
          _pickUpSuggestions = [];
        });

        setState(() {
          markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(currentPosition.latitude, currentPosition.longitude),
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: formattedAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        });
      } else {
        print('Error with reverse geocoding API response: ${data['status']}');
      }
    } else {
      print('Failed to load reverse geocoding data, status code: ${response.statusCode}');
    }
  }

  Future<void> currentPositionSuggestionForCity() async {
    setState(() {
      isLocating = true;
    });
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    // Convert the coordinates into a human-readable address (Reverse Geocoding)
    String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
    String reverseGeocodeUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentPosition.latitude},${currentPosition.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(reverseGeocodeUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data['status'] == 'OK') {
        final formattedAddress = data['results'][0]['formatted_address'];

        // Update the pickup controller with the current location address
        setState(() {
          cityNameController.text = formattedAddress;
          isLocating = false;
          _cityNameSuggestions = [];
        });

        // Optionally, place a marker for the current location on the map
        setState(() {
          markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(currentPosition.latitude, currentPosition.longitude),
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: formattedAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        });
      } else {
        print('Error with reverse geocoding API response: ${data['status']}');
      }
    } else {
      print('Failed to load reverse geocoding data, status code: ${response.statusCode}');
    }
  }

  Future<void> _fetchCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String pickupPlace = pickUpController.text;
      List<String> dropPlaces =
      _dropPointControllers.map((controller) => controller.text).toList();

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

  Future<void> _fetchAddressCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String cityName = cityNameController.text.trim();
      String address = addressController.text.trim();
      String zipCode = zipCodeController.text.trim();

      if (cityName.isEmpty || address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please enter both city name and address to locate the place.'),
          ),
        );
        return;
      }

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

  Future<void> _fetchSuggestions(String query, int index, bool isPickUp) async {
    if (query.isEmpty) {
      setState(() {
        if (isPickUp) {
          _pickUpSuggestions = [];
        } else {
          _dropPointSuggestions[index] = [];
        }
      });
      return;
    }

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List<dynamic>;

        setState(() {
          if (isPickUp) {
            _pickUpSuggestions = predictions.map((p) => p['description'] as String).toList();
          } else {
            _dropPointSuggestions[index] = predictions.map((p) => p['description'] as String).toList();
          }
        });
      } else {
        print('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _onSuggestionTap(String suggestion, TextEditingController controller, bool isPickUp) {
    setState(() {
      controller.text = suggestion;
      if (isPickUp) {
        _pickUpSuggestions = [];
      } else {
        final index = _dropPointControllers.indexOf(controller);
        if (index != -1) {
          _dropPointSuggestions[index] = [];
        }
      }
    });
  }

  Future<void> _fetchAddressSuggestions(String query, String type) async {
    if (query.isEmpty) {
      setState(() {
        if (type == 'city') {
          _cityNameSuggestions = [];
        } else if (type == 'address') {
          _addressSuggestions = [];
        } else if (type == 'zipCode') {
          _zipCodeSuggestions = [];
        }
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List<dynamic>;

        setState(() {
          if (type == 'city') {
            _cityNameSuggestions = predictions.map((p) => p['description'] as String).toList();
          } else if (type == 'address') {
            _addressSuggestions = predictions.map((p) => p['description'] as String).toList();
          } else if (type == 'zipCode') {
            _zipCodeSuggestions = predictions.map((p) => p['description'] as String).toList();
          }
        });
      } else {
        print('Failed to load suggestions');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _onAddressSuggestionTap(String suggestion, TextEditingController controller, String type) {
    setState(() {
      controller.text = suggestion;
      if (type == 'city') {
        _cityNameSuggestions = [];
      } else if (type == 'address') {
        _addressSuggestions = [];
      } else if (type == 'zipCode') {
        _zipCodeSuggestions = [];
      }
    });
  }

  Future<List<LoadType>> fetchLoadsForSelectedType(String selectedTypeName) async {
    try {
      List<Vehicle> vehicles =
      await userService.fetchUserVehicle();

      var selectedType = vehicles
          .expand((vehicle) => vehicle.types)
          .firstWhere(
            (type) => type.typeName == selectedTypeName,
        orElse: () => VehicleType(
            typeName: '',
            typeOfLoad: [],
            typeImage: '',
            scale: ''),
      );

      print('Selected Type: ${selectedType.typeOfLoad}');

      return selectedType.typeOfLoad;
    } catch (e) {
      print('Error fetching loads: $e');
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedFromTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedFromTime) {
      setState(() {
        _selectedFromTime = picked;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedToTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedToTime) {
      setState(() {
        _selectedToTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  }

  Future<void> createBooking() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String formattedTime = _formatTimeOfDay(_selectedFromTime);
    String formattedToTime = _formatTimeOfDay(_selectedToTime);
    List<String> dropPlaces = _dropPointControllers.map((controller) => controller.text).toList();

    if (widget.selectedType == 'vehicle') {
      if (pickUpController.text.isEmpty || dropPlaces.contains('') || dropPlaces.isEmpty) {
        commonWidgets.showToast('Choose Pickup and DropPoints'.tr());
      } else {
        // Print debugging info
        print('name$selectedName');
        print('unitType${widget.selectedType}');
        print('typeName$selectedTypeName');
        print('scale$scale');
        print('typeImage$typeImage');
        print('typeOfLoad$selectedLoad');
        print('date$formattedDate');
        print('additionalLabour$selectedLabour');
        print('time$formattedTime');
        print('productValue${productController.text}');
        print('pickup${pickUpController.text}');
        print('dropPoints${_dropPointControllers.map((controller) => controller.text).toList()}');

        String? bookingId = await userService.userVehicleCreateBooking(
          context,
          name: selectedName.toString(),
          unitType: widget.selectedType,
          typeName: selectedTypeName.toString(),
          scale: scale.toString(),
          typeImage: typeImage.toString(),
          typeOfLoad: selectedLoad.toString(),
          date: formattedDate,
          additionalLabour: selectedLabour.toString(),
          time: formattedTime,
          productValue: productController.text,
          pickup: pickUpController.text,
          dropPoints: dropPlaces,
          token: widget.token,
        );

        setState(() {
          if (bookingId != null) {
            CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuperUserHomePage(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    token: widget.token,
                    id: widget.id,
                    email: widget.email,
                    accountType: widget.accountType,
                  ),
                ),
              );
            });
          }
        });
      }
    }
    if(widget.selectedType=='bus') {
      if (pickUpController.text.isEmpty ||
          dropPlaces.contains('') ||
          dropPlaces.isEmpty) {
        commonWidgets.showToast('Choose Pickup and DropPoints'.tr());
      }
      else {
        print('unitType${widget.selectedType}');
        print('name$selectedName');
        print('typeImage$typeImage');
        print('date$formattedDate');
        print('additionalLabour$selectedLabour');
        print('time$formattedTime');
        print('productValue${productController.text}');
        print('pickup${pickUpController.text}');
        print('dropPoints${_dropPointControllers.map((
            controller) => controller.text).toList()}');
        String? bookingId = await userService.userBusCreateBooking(
            context,
            name: selectedName.toString(),
            unitType: widget.selectedType,
            image: typeImage.toString(),
            date: formattedDate,
            additionalLabour: selectedLabour.toString(),
            time: formattedTime,
            productValue: productController.text,
            pickup: pickUpController.text,
            dropPoints: dropPlaces,
            token: widget.token);
        if (bookingId != null){
          CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  email: widget.email,
                  accountType: widget.accountType,
                ),
              ),
            );
          });
        }
      }
    }
    if(widget.selectedType=='equipment') {
      if (cityNameController.text.isEmpty ||
          addressController.text.isEmpty) {
        commonWidgets.showToast('Choose City name and Address'.tr());
      }
      else {
        print('unitType${widget.selectedType}');
        print('name$selectedName');
        print('typeImage$typeImage');
        print('FromTime$formattedTime');
        print('ToTime$formattedToTime');
        print('Date$formattedDate');
        print('additionalLabour$selectedLabour');
        print('city${cityNameController.text}');
        print('address${addressController.text}');
        print('zipcode${zipCodeController.text}');
        String? bookingId = await userService.userEquipmentCreateBooking(
            context,
            name: selectedName.toString(),
            unitType: widget.selectedType,
            typeName: selectedTypeName.toString(),
            typeImage: typeImage.toString(),
            date: formattedDate,
            additionalLabour: selectedLabour.toString(),
            fromTime: formattedTime,
            toTime: formattedToTime,
            cityName: cityNameController.text,
            address: addressController.text,
            zipCode: zipCodeController.text,
            token: widget.token);
        if (bookingId != null){
          CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  email: widget.email,
                  accountType: widget.accountType,
                ),
              ),
            );
          });
        }
      }
    }
    if(widget.selectedType=='special') {
      if (cityNameController.text.isEmpty ||
          addressController.text.isEmpty) {
        commonWidgets.showToast('Choose City name and Address'.tr());
      }
      else {
        print('unitType${widget.selectedType}');
        print('name$selectedName');
        print('typeImage$typeImage');
        print('FromTime$formattedTime');
        print('ToTime$formattedToTime');
        print('Date$formattedDate');
        print('additionalLabour$selectedLabour');
        print('city${cityNameController.text}');
        print('address${addressController.text}');
        print('zipcode${zipCodeController.text}');
        String? bookingId = await userService.userSpecialCreateBooking(
            context,
            name: selectedName.toString(),
            unitType: widget.selectedType,
            image: typeImage.toString(),
            date: formattedDate,
            additionalLabour: selectedLabour.toString(),
            fromTime: formattedTime,
            toTime: formattedToTime,
            cityName: cityNameController.text,
            address: addressController.text,
            zipCode: zipCodeController.text,
            token: widget.token);
        if (bookingId != null){
          CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  email: widget.email,
                  accountType: widget.accountType,
                ),
              ),
            );
          });
        }
      }
    }
  }

  void onCreateBookingPressed() {
    createBooking();
  }

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

  Widget _buildStep(int step) {
    bool isActive = step == _currentStep;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? const Color(0xff6A66D1) : const Color(0xffACACAD),
            width: 1),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isActive ? const Color(0xff6A66D1) : Colors.white,
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return buildStepOneContent(widget.selectedType);
      case 2:
        return buildStepTwoContent(widget.selectedType);
      case 3:
        return buildStepThreeContent(widget.selectedType);
      default:
        return Container();
    }
  }

  Widget buildStepOneContent(String selectedType) {
    switch (selectedType) {
      case 'vehicle':
        return vehicleContent();
      case 'bus':
        return busContent();
      case 'equipment':
        return equipmentContent();
      case 'special':
        return specialContent();
      case 'others':
        return specialContent();
      default:
        return defaultContent();
    }
  }

  Widget buildStepTwoContent(String selectedType) {
    switch (selectedType) {
      case 'vehicle':
        return UserVehicleStepTwo(
            selectedTypeName??'',
            selectedName??'',
            typeImage??'',
            scale??''
        );
      case 'bus':
        return UserBusStepTwo();
      case 'equipment':
        return UserEquipmentStepTwo();
      case 'special':
        return UserSpecialStepTwo();
      case 'others':
        return UserSpecialStepTwo();
      default:
        return defaultContent();
    }
  }

  Widget buildStepThreeContent(String selectedType) {
    switch (selectedType) {
      case 'vehicle':
        return UserVehicleStepThree(
            selectedTypeName??'',
            selectedName??'',
            typeImage??'',
            scale??'',
            _selectedDate .toString(),
            _selectedFromTime.toString(),
            productController.text,
            selectedLoad??'',
            selectedLabour.toString()
        );
      case 'bus':
        return UserBusStepThree();
      case 'equipment':
        return UserEquipmentStepThree();
      case 'special':
        return UserSpecialStepThree();
      case 'others':
        return UserSpecialStepThree();
      default:
        return defaultContent();
    }
  }

  Widget vehicleContent() {
    return FutureBuilder<List<Vehicle>>(
      future: _futureVehicles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No vehicles available'));
        } else {
          final vehicles = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: Text(
                  'available_vehicle_units'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final selectedType = _selectedSubClassification[vehicle.name] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset('assets/delivery-truck.svg'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Text(
                                vehicle.name.tr(),
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height:
                                MediaQuery.of(context).size.height * 0.05,
                                child: const VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Container(
                                  width: double.infinity,
                                  child: PopupMenuButton<String>(
                                    elevation: 5,
                                    constraints: BoxConstraints(
                                      minWidth:350,
                                      maxWidth:350,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    offset:  Offset(0, 55),
                                    padding: EdgeInsets.zero,
                                    color: Colors.white,
                                    onSelected: (newValue) {
                                      setState(() {
                                        _selectedSubClassification[vehicle.name] = newValue;
                                        selectedTypeName = newValue;
                                        selectedName = vehicle.name;
                                        scale = vehicle.types
                                            ?.firstWhere((type) => type.typeName == newValue)
                                            .scale;
                                        typeImage = vehicle.types
                                            ?.firstWhere((type) => type.typeName == newValue)
                                            .typeImage;
                                      });
                                    },
                                    itemBuilder: (context) {
                                      return vehicle.types?.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        var type = entry.value;
                                        typeCount = index + 1;
                                        print('Dropdown item ${index + 1}: ${typeCount}');
                                        return PopupMenuItem<String>(
                                          value: type.typeName,
                                          child: Directionality(
                                            textDirection: ui.TextDirection.ltr,
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: FutureBuilder(
                                                      future: _loadSvg(type.typeImage),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: Icon(Icons.rotate_right),
                                                          );
                                                        } else if (snapshot.hasError) {
                                                          return const Icon(Icons.error);
                                                        } else {
                                                          return SvgPicture.asset(
                                                            type.typeImage,
                                                            width: 40,
                                                            height: 30,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(type.typeName.tr(),
                                                            style: const TextStyle(fontSize: 16.0)),
                                                        Text(type.scale,
                                                            style: const TextStyle(fontSize: 14.0)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList() ??
                                          [];
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedType.isEmpty
                                                  ? 'select'.tr()
                                                  : selectedType.isNotEmpty
                                                  ? selectedType.tr()
                                                  : vehicle.types?.isNotEmpty == true
                                                  ? vehicle.types!.first.typeName
                                                  : 'no_data'.tr(),
                                              style: const TextStyle(fontSize: 16.0),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget busContent() {
    return FutureBuilder<List<Buses>>(
      future: _futureBuses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Buses available'));
        } else {
          final buses = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: Text(
                  'available_bus_units'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 0, // Space between columns
                    mainAxisSpacing: 0, // Space between rows
                    childAspectRatio:
                    1, // Aspect ratio for card width and height
                  ),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    final isBusSelected = selectedBus == index;
                    return Padding(
                      padding: const EdgeInsets.only(left: 27),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.39,
                            height: MediaQuery.sizeOf(context).height * 0.21,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedName = bus.name;
                                  typeImage = bus.image;
                                  if (isBusSelected) {
                                    selectedBus = null;
                                  } else {
                                    selectedBus = index;
                                  }
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: isBusSelected
                                          ? Color(
                                        0xff6A66D1,
                                      )
                                          : Color(0xffACACAD),
                                      width: isBusSelected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 45, bottom: 10),
                                      child: SvgPicture.asset(
                                        bus.image,
                                        width: 30,
                                        height: 40,
                                        placeholderBuilder: (context)=>
                                        Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      indent: 7,
                                      endIndent: 7,
                                      color: Color(0xffACACAD),
                                      thickness: 1,
                                    ),
                                    Text(
                                      bus.name,
                                      textAlign:
                                      TextAlign.center, // Center the text
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget equipmentContent() {
    return FutureBuilder<List<Equipment>>(
      future: _futureEquipment,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No vehicles available'));
        } else {
          final equipment = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: Text(
                  'available_equipments_units'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    final equipments = equipment[index];
                    final selectedType = _selectedSubClassification[equipments.name] ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset('assets/delivery-truck.svg'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                equipments.name.tr(),
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height:
                                MediaQuery.of(context).size.height * 0.05,
                                child: const VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                width: double.infinity,
                                child: PopupMenuButton<String>(
                                  elevation: 5,
                                  constraints:
                                  BoxConstraints.tightFor(width: 350),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  offset: const Offset(0, 55),
                                  padding: EdgeInsets.zero,
                                  color: Colors.white,
                                  onSelected: (newValue) {
                                    setState(() {
                                      _selectedSubClassification[
                                      equipments.name] = newValue;
                                      selectedTypeName = newValue;
                                      selectedName = equipments.name;
                                      typeImage = equipments.types
                                          ?.firstWhere((type) => type.typeName == newValue)
                                          .typeImage;
                                    });
                                  },
                                  itemBuilder: (context) {
                                    return equipments.types?.map((type) {
                                      return PopupMenuItem<String>(
                                        value: type.typeName,
                                        child: Directionality(
                                          textDirection: ui.TextDirection.ltr,
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: FutureBuilder(
                                                    future: _loadSvg(type.typeImage),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child:Icon(Icons.rotate_right),
                                                        );
                                                      } else if (snapshot.hasError) {
                                                        return const Icon(Icons.error);
                                                      } else {
                                                        return SvgPicture.asset(
                                                          type.typeImage,
                                                          width: 40,
                                                          height: 30,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(type.typeName.tr(),
                                                      style: const TextStyle(fontSize: 16.0)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList() ??
                                        [];
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedType.isEmpty
                                                ? 'select'.tr()
                                                : selectedType.isNotEmpty
                                                ? selectedType.tr()
                                                : equipments.types?.isNotEmpty == true
                                                ? equipments.types!.first.typeName
                                                : 'no_data'.tr(),
                                            style:
                                            const TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget specialContent() {
    return FutureBuilder<List<Special>>(
      future: _futureSpecial,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Equipment available'));
        } else {
          final special = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: Text(
                  'available_special_others_units'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 0, // Space between columns
                    mainAxisSpacing: 0, // Space between rows
                    childAspectRatio: 1,
                  ),
                  itemCount: special.length,
                  itemBuilder: (context, index) {
                    final specials = special[index];
                    final isSpecialSelected = selectedSpecial == index;
                    return Padding(
                      padding: const EdgeInsets.only(left: 27),
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.39,
                            height: MediaQuery.sizeOf(context).height * 0.21,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedName = specials.name;
                                  typeImage = specials.image;
                                  if (isSpecialSelected) {
                                    selectedSpecial = null;
                                  } else {
                                    selectedSpecial = index;
                                  }
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: isSpecialSelected
                                          ? Color(0xff6A66D1,)
                                          : Color(0xffACACAD),
                                      width: isSpecialSelected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 45, bottom: 10),
                                      child: SvgPicture.asset(
                                        specials.image,
                                        width: 30,
                                        height: 40,
                                      ),
                                    ),
                                    Divider(
                                      indent: 7,
                                      endIndent: 7,
                                      color: Color(0xffACACAD),
                                      thickness: 1,
                                    ),
                                    Text(
                                      specials.name.tr(),
                                      textAlign: TextAlign.center, // Center the text
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget othersContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Others Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget defaultContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text('please_select_a_type_to_see_content'.tr(),
          style: TextStyle(fontSize: 18)),
    );
  }

  Widget UserVehicleStepTwo(
      String selectedTypeName,
      String name,
      String typeImage,
      String scale,
      ) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return SingleChildScrollView(
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 22),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Time'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                _selectTime(context);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBCBCBC)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC),),
                    ),
                    Container(
                      height: 50,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _selectTime(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${_formatTimeOfDay(_selectedFromTime)}',style: TextStyle(fontSize: 16),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 22),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Date'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                _selectDate(context);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBCBCBC)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                    ),
                    Container(
                      height: 50,
                      child: const VerticalDivider(
                        color: Colors.grey,
                        thickness: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _selectDate(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$formattedDate',style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 22),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'valueOfProduct'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: TextFormField(
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                focusNode: productValueFocusNode,
                controller: productController,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Color(0xffCCCCCC),fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: const BorderSide(
                      color: Color(0xffBCBCBC),
                      width: 1.0, // Border width
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: const BorderSide(
                      color: Color(0xffBCBCBC),
                      width: 1.0, // Border width
                    ),
                  ),
                ),keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 22),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'loadType'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: LoadTypeDropdown(
                selectedName: selectedTypeName,
                selectedLoad: selectedLoad,
                onLoadChanged: (newValue) async {
                  setState(() {
                    selectedLoad = newValue;
                  });
                  await Future.delayed(Duration(milliseconds: -1));
                  if (productValueFocusNode.hasFocus) {
                    productValueFocusNode.unfocus();
                  }
                },
                fetchLoadsForSelectedType: fetchLoadsForSelectedType,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: _onCheckboxChanged,
                    checkColor: Colors.white,
                    activeColor: const Color(0xff6A66D1),
                    side: BorderSide(color: Colors.grey),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'needAdditionalLabour'.tr(),
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isChecked)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    RadioListTile(
                      title: const Text('1'),
                      value: 1,
                      groupValue: selectedLabour,
                      onChanged: (value) {
                        setState(() {
                          selectedLabour = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('2'),
                      value: 2,
                      groupValue: selectedLabour,
                      onChanged: (value) {
                        setState(() {
                          selectedLabour = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text('3'),
                      value: 3,
                      groupValue: selectedLabour,
                      onChanged: (value) {
                        setState(() {
                          selectedLabour = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget UserBusStepTwo() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Time'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              _selectTime(context);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffBCBCBC)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC)),
                  ),
                  Container(
                    height: 50,
                    child: const VerticalDivider(
                      color: Colors.grey,
                      thickness: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _selectTime(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${_formatTimeOfDay(_selectedFromTime)}',style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              _selectDate(context);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffBCBCBC)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                  ),
                  Container(
                    height: 50,
                    child: const VerticalDivider(
                      color: Colors.grey,
                      thickness: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _selectDate(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$formattedDate',style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'valueOfProduct'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextFormField(
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              controller: productController,
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: const BorderSide(
                    color: Color(0xffBCBCBC),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  borderSide: const BorderSide(
                    color: Color(0xffBCBCBC),
                    width: 1.0,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: _onCheckboxChanged,
                  checkColor: Colors.white,
                  activeColor: const Color(0xff6A66D1),
                  side: BorderSide(color: Colors.grey),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'needAdditionalLabour'.tr(),
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('1'),
                    value: 1,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('2'),
                    value: 2,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('3'),
                    value: 3,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget UserEquipmentStepTwo() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'fromTime'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectTime(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'toTime'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectToTime(context),
                  icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectToTime(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${_formatTimeOfDay(_selectedToTime)}',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'startingDate'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectDate(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$formattedDate',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: _onCheckboxChanged,
                  checkColor: Colors.white,
                  activeColor: const Color(0xff6A66D1),
                  side: BorderSide(color: Colors.grey),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'needAdditionalLabour'.tr(),
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('1'),
                    value: 1,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('2'),
                    value: 2,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('3'),
                    value: 3,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget UserSpecialStepTwo() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'fromTime'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectTime(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'toTime'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectToTime(context),
                  icon: const Icon(FontAwesomeIcons.clock,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectToTime(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${_formatTimeOfDay(_selectedToTime)}',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'startingDate'.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffBCBCBC)),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                ),
                Container(
                  height: 50,
                  child: const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    _selectDate(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$formattedDate',style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: _onCheckboxChanged,
                  checkColor: Colors.white,
                  activeColor: const Color(0xff6A66D1),
                  side: BorderSide(color: Colors.grey),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'needAdditionalLabour'.tr(),
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isChecked)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('1'),
                    value: 1,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('2'),
                    value: 2,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('3'),
                    value: 3,
                    groupValue: selectedLabour,
                    onChanged: (value) {
                      setState(() {
                        selectedLabour = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget UserVehicleStepThree(
      String selectedTypeName,
      String name,
      String typeImage,
      String scale,
      String selectedDate,
      String selectedTime,
      String valueOfProduct,
      String selectedLoad,
      String additionalLabour,
      ) {
    return  GestureDetector(
      onTap: () {
        setState(() {
          _dismissSuggestions();
        });
      },
      child: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10,17,10,10),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff009E10),
                                    minRadius: 6,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      onChanged: (value) => _fetchSuggestions(value, -1, true),
                                      controller: pickUpController,
                                      decoration: InputDecoration(
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 8,top: 5),
                                          child: Tooltip(
                                            message: 'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: ()async{
                                                  FocusScope.of(context).unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(Icons.my_location,size: 20,color: Color(0xff6A66D1),)),
                                          ),
                                        ),
                                        hintText: 'Pick Up'.tr(),
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pickUpSuggestions.isNotEmpty && pickUpController.text.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(8),
                                height: 200,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: ListView.builder(
                                  itemCount: _pickUpSuggestions.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {

                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Icon(Icons.my_location_outlined,color: Colors.blue,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left: 13,right: MediaQuery.sizeOf(context).width * 0.27),
                                              child: Text('Current Location'.tr()),
                                            ),
                                            isLocating ? Container(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ):Container()
                                          ],
                                        ),
                                        onTap: () async {
                                          await currentPositionSuggestion();
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title: Text(_pickUpSuggestions[index - 1]),
                                        onTap: () => _onSuggestionTap(_pickUpSuggestions[index - 1], pickUpController, true),
                                      );
                                    }
                                  },
                                ),
                              ),
                            const Divider(
                              indent: 5,
                              endIndent: 5,
                            ),
                            ..._dropPointControllers.asMap().entries.map((entry) {
                              int i = entry.key;
                              TextEditingController controller = entry.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10,10,5,10),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE20808),
                                          minRadius: 6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 43,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textCapitalization: TextCapitalization.sentences,
                                            onChanged: (value) => _fetchSuggestions(value, i, false),
                                            controller: controller,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: '${'Drop Point'.tr()} ${i + 1}',
                                              hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                              border: InputBorder.none,
                                              suffixIcon: i == _dropPointControllers.length - 1
                                                  ? Padding(
                                                padding: const EdgeInsets.only(right: 15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (_dropPointControllers.length > 1)
                                                      GestureDetector(
                                                        onTap: () => _removeTextField(i),
                                                        child: Icon(Icons.cancel_outlined, color: Colors.red),
                                                      ),
                                                    if (_dropPointControllers.length == 1)
                                                      GestureDetector(
                                                        onTap: _addTextField,
                                                        child: Icon(Icons.add_circle_outline_sharp),
                                                      ),
                                                  ],
                                                ),
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_dropPointSuggestions[i] != null && _dropPointSuggestions[i]!.isNotEmpty && controller.text.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: _dropPointSuggestions[i]!.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dropPointSuggestions[i]![index]),
                                            onTap: () => _onSuggestionTap(_dropPointSuggestions[i]![index], controller, false),
                                          );
                                        },
                                      ),
                                    ),
                                  if (i < _dropPointControllers.length - 1)
                                    Divider(
                                      indent: 5,
                                      endIndent: 5,
                                    ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6A66D1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _fetchCoordinates();
                            },
                            child: Text(
                              'getDirection'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget UserBusStepThree() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _dismissSuggestions();
        });
      },
      child: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
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
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10,17,10,10),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff009E10),
                                    minRadius: 6,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      onChanged: (value) => _fetchSuggestions(value, -1, true),
                                      controller: pickUpController,
                                      decoration: InputDecoration(
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 8,top: 5),
                                          child: Tooltip(
                                            message: 'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: ()async{
                                                  FocusScope.of(context).unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(Icons.my_location,size: 20,color: Color(0xff6A66D1),)),
                                          ),
                                        ),
                                        hintText: 'Pick Up'.tr(),
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pickUpSuggestions.isNotEmpty && pickUpController.text.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(8),
                                height: 200,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: ListView.builder(
                                  itemCount: _pickUpSuggestions.length + 1,  // +1 to include the "Current Location"
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      // Show "Current Location" as the first suggestion
                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Icon(Icons.my_location_outlined,color: Colors.blue,size: 20,),
                                            Padding(
                                              padding: EdgeInsets.only(left: 13,right: MediaQuery.sizeOf(context).width * 0.27),
                                              child: Text('Current Location'.tr()),
                                            ),
                                            isLocating ? Container(
                                              height: 15,
                                              width: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ):Container()
                                          ],
                                        ),
                                        onTap: () async {
                                          await currentPositionSuggestion();
                                        },
                                      );
                                    } else {
                                      // Show other suggestions from the list
                                      return ListTile(
                                        title: Text(_pickUpSuggestions[index - 1]),  // Adjust index for suggestions
                                        onTap: () => _onSuggestionTap(_pickUpSuggestions[index - 1], pickUpController, true),
                                      );
                                    }
                                  },
                                ),
                              ),
                            const Divider(
                              indent: 5,
                              endIndent: 5,
                            ),
                            ..._dropPointControllers.asMap().entries.map((entry) {
                              int i = entry.key;
                              TextEditingController controller = entry.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10,10,5,10),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE20808),
                                          minRadius: 6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 43,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textCapitalization: TextCapitalization.sentences,
                                            onChanged: (value) => _fetchSuggestions(value, i, false),
                                            controller: controller,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: '${'Drop Point'.tr()} ${i + 1}',
                                              hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                              border: InputBorder.none,
                                              suffixIcon: i == _dropPointControllers.length - 1
                                                  ? Padding(
                                                padding: const EdgeInsets.only(right: 15),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (_dropPointControllers.length > 1)
                                                      GestureDetector(
                                                        onTap: () => _removeTextField(i),
                                                        child: Icon(Icons.cancel_outlined, color: Colors.red),
                                                      ),
                                                    if (_dropPointControllers.length == 1)
                                                      GestureDetector(
                                                        onTap: _addTextField,
                                                        child: Icon(Icons.add_circle_outline_sharp),
                                                      ),
                                                  ],
                                                ),
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_dropPointSuggestions[i] != null && _dropPointSuggestions[i]!.isNotEmpty && controller.text.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: _dropPointSuggestions[i]!.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dropPointSuggestions[i]![index]),
                                            onTap: () => _onSuggestionTap(_dropPointSuggestions[i]![index], controller, false),
                                          );
                                        },
                                      ),
                                    ),
                                  if (i < _dropPointControllers.length - 1)
                                    Divider(
                                      indent: 5,
                                      endIndent: 5,
                                    ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6A66D1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _fetchCoordinates();
                            },
                            child: Text(
                              'getDirection'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dismissAddressSuggestions() {
    setState(() {
      _cityNameSuggestions.clear();
      _addressSuggestions.clear();
      _zipCodeSuggestions.clear();
    });
  }

  Widget UserEquipmentStepThree() {
    return GestureDetector(
      onTap: (){
        _dismissAddressSuggestions();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 15, right: 15,top: 5),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0),
                          width: 1,
                        ),
                      ),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,8,15,5),
                                    child: SvgPicture.asset('assets/search.svg')),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: cityNameController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'city'),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Tooltip(
                                            message: 'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: ()async{
                                                  FocusScope.of(context).unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(Icons.my_location,size: 20,color: Color(0xff6A66D1),)),
                                          ),
                                        ),
                                        hintText: 'enterCityName'.tr(),
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_cityNameSuggestions.isNotEmpty && cityNameController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _cityNameSuggestions.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Icon(Icons.my_location_outlined,color: Colors.blue,size: 20,),
                                          Padding(
                                            padding: EdgeInsets.only(left: 13,right: MediaQuery.sizeOf(context).width * 0.27),
                                            child: Text('Current Location'.tr()),
                                          ),
                                          isLocating ? Container(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ):Container()
                                        ],
                                      ),
                                      onTap: () async {
                                        await currentPositionSuggestionForCity();
                                      },
                                    );
                                  } else {
                                    return ListTile(
                                      title: Text(_cityNameSuggestions[index - 1]),
                                      onTap: () => _onAddressSuggestionTap(_cityNameSuggestions[index -1], cityNameController, 'city'),
                                    );
                                  }
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10,8,15,10),
                                  child: SvgPicture.asset('assets/address.svg')),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: 33,
                                  child: TextFormField(
                                    textCapitalization: TextCapitalization.sentences,
                                    controller: addressController,
                                    onChanged: (value) => _fetchAddressSuggestions(value, 'address'),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'enterYourAddress'.tr(),
                                      hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                      border: InputBorder.none,
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_addressSuggestions.isNotEmpty && addressController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _addressSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_addressSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_addressSuggestions[index], addressController, 'address'),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6A66D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _fetchAddressCoordinates();
                          },
                          child: Text(
                            'getDirection'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _requestPermissions();
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
            ],
          ),
        ),
      ),
    );
  }

  Widget UserSpecialStepThree() {
    return GestureDetector(
      onTap: (){
        _dismissAddressSuggestions();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 15, right: 15,top: 5),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0), // Border color
                          width: 1, // Border width
                        ),
                      ),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,8,15,8),
                                    child: SvgPicture.asset('assets/search.svg')),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: cityNameController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'city'),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Tooltip(
                                            message: 'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: ()async{
                                                  FocusScope.of(context).unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(Icons.my_location,size: 20,color: Color(0xff6A66D1),)),
                                          ),
                                        ),
                                        hintText: 'enterCityName'.tr(),
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_cityNameSuggestions.isNotEmpty && cityNameController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _cityNameSuggestions.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Icon(Icons.my_location_outlined,color: Colors.blue,size: 20,),
                                          Padding(
                                            padding: EdgeInsets.only(left: 13,right: MediaQuery.sizeOf(context).width * 0.27),
                                            child: Text('Current Location'.tr()),
                                          ),
                                          isLocating ? Container(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ):Container()
                                        ],
                                      ),
                                      onTap: () async {
                                        await currentPositionSuggestionForCity();
                                      },
                                    );
                                  } else {
                                    return ListTile(
                                      title: Text(_cityNameSuggestions[index - 1]),
                                      onTap: () => _onAddressSuggestionTap(_cityNameSuggestions[index -1], cityNameController, 'city'),
                                    );
                                  }
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10,8,15,10),
                                  child: SvgPicture.asset('assets/address.svg')),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: 33,
                                  child: TextFormField(
                                    textCapitalization: TextCapitalization.sentences,
                                    controller: addressController,
                                    onChanged: (value) => _fetchAddressSuggestions(value, 'address'),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'enterYourAddress'.tr(),
                                      hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                      border: InputBorder.none,
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_addressSuggestions.isNotEmpty && addressController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _addressSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_addressSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_addressSuggestions[index], addressController, 'address'),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6A66D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _fetchAddressCoordinates();
                          },
                          child: Text(
                            'getDirection'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _requestPermissions();
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey,
    );
  }
}

Future<void> _loadSvg(String asset) async {
  await Future.delayed(const Duration(milliseconds: 500));
}

class LoadTypeDropdown extends StatefulWidget {
  final String? selectedName;
  final String? selectedLoad;
  final Function(String?) onLoadChanged;
  final Future<List<LoadType>> Function(String) fetchLoadsForSelectedType;

  LoadTypeDropdown({
    required this.selectedName,
    required this.selectedLoad,
    required this.onLoadChanged,
    required this.fetchLoadsForSelectedType,
  });

  @override
  _LoadTypeDropdownState createState() => _LoadTypeDropdownState();
}

class _LoadTypeDropdownState extends State<LoadTypeDropdown> {
  late Future<List<LoadType>> _loadTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadTypesFuture = widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
  }

  @override
  void didUpdateWidget(covariant LoadTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedName != oldWidget.selectedName) {
      setState(() {
        _loadTypesFuture = widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LoadType>>(
      future: _loadTypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<LoadType> loadItems = snapshot.data ?? [];

          // Ensure loadItems is not empty and contains valid LoadType objects
          print('Load Items: $loadItems'); // Debugging line

          return Container(
            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: PopupMenuButton<String>(
              onSelected: (String newValue) {
                widget.onLoadChanged(newValue);
              },
              elevation: 5,
              color: Colors.white,
              constraints: BoxConstraints.tightFor(width: 350),
              offset: const Offset(0, -280),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (widget.selectedLoad?.isNotEmpty ?? false)
                        ? widget.selectedLoad!
                        : 'loadType'.tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down,size: 26),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return loadItems.map((LoadType load) {
                  return PopupMenuItem<String>(
                    value: load.load.tr(),
                    child: Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Row(
                        children: [
                          Text(load.load.tr(),
                              style: const TextStyle(fontSize: 16.0)),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          );
        } else {
          return Center(child: Text('No loads available'));
        }
      },
    );
  }
}