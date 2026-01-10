import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Helper/helper.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_bookingHistory.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_payment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_naqli/User/vectorImage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart'
    as permissionHandler;
import 'dart:ui' as ui;

class CreateBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String selectedType;
  final String token;
  final String id;
  final String email;
  final String? accountType;
  final String? isFromUserType;
  const CreateBooking(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.selectedType,
      required this.token,
      required this.id,
      required this.email,
      this.isFromUserType,
      this.accountType});

  @override
  State<CreateBooking> createState() => _CreateBookingState();
}

class _CreateBookingState extends State<CreateBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController pickUpController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final FocusNode productValueFocusNode = FocusNode();
  int _currentStep = 1;
  String? selectedLoad;
  TimeOfDay _selectedFromTime = TimeOfDay.now();
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
  List<String> _suggestions = [];
  Map<int, List<String>> _dropPointSuggestions = {};
  late List<String> _pickUpSuggestions = [];
  late List<String> _cityNameSuggestions = [];
  late List<String> _addressSuggestions = [];
  late List<String> _zipCodeSuggestions = [];
  Future<Map<String, dynamic>?>? booking;
  FocusNode _pickUpFocusNode = FocusNode();
  List<FocusNode> _dropPointFocusNodes = [];
  String currentPlace = '';
  int typeCount = 0;
  bool isLocating = false;
  late Future<UserDataModel> userData;
  Timer? _debounce;
  String? selectedShipmentType;
  String? selectedShipmentCondition;
  final List<String> shipmentTypeItems = [
    "Food",
    "Building Materials",
    "Auto parts",
    "Tools and Equipment's",
    "Perfumes and Cosmetics",
    "Fodder",
    "Container 20",
    "Medicinal products",
    "Scrap",
    "Steel",
    "Other",
  ];
  final List<String> shipmentConditionItems = ['Refrigerator', 'Dry Storage'];
  String selectedUnit = 'mm';
  bool _isTimePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _futureVehicles = userService.fetchUserVehicle();
    _futureBuses = userService.fetchUserBuses();
    _futureEquipment = userService.fetchUserEquipment();
    _futureSpecial = userService.fetchUserSpecialUnits();
    booking = _fetchBookingDetails();
    userData = userService.getUserData(widget.id, widget.token);
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      preloadImages(context);
      if (selectedTypeName != null && selectedTypeName!.isNotEmpty) {
        fetchLoadsForSelectedType(selectedTypeName!);
      }
    });
  }

  Future<void> preloadImages(BuildContext context) async {
    _futureBuses.then((buses) {
      for (var bus in buses) {
        MyVectorImage.preload(context, bus.image);
      }
    });
    _futureSpecial.then((specials) {
      for (var special in specials) {
        MyVectorImage.preload(context, special.image);
      }
    });
  }

  void goToNextStep() {
    if (!mounted) return;
    setState(() {
      _currentStep++;
    });
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
          User: widget.firstName + ' ' + widget.lastName,
          userId: widget.id,
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
                          ? 'createBooking'.tr()
                          : 'Get an estimate'.tr(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet ? 27 : 22),
                    ),
                    Text(
                      widget.isFromUserType != null
                          ? '${'step'.tr()} $_currentStep ${'of 3 - booking'.tr()}'
                          : '${'step'.tr()} $_currentStep ${'of 3'.tr()}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet ? 22 : 17),
                    ),
                  ],
                ),
              ),
              leading: FutureBuilder<bool>(
                future: hasToken(),
                builder: (context, snapshot) {
                  final bool hasUserToken = snapshot.data ?? false;

                  return IconButton(
                    onPressed: () {
                      if (hasUserToken) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserType(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    token: widget.token,
                                    id: widget.id,
                                    email: widget.email,
                                  )),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserHomePage()),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                      size: viewUtil.isTablet ? 27 : 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        drawer: FutureBuilder<bool>(
          future: hasToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Drawer(
                backgroundColor: Colors.white,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final bool hasUserToken = snapshot.data ?? false;

            return hasUserToken
                ? _buildUserDrawer(context)
                : _buildPublicDrawer(context);
          },
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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_currentStep == 1) const SizedBox.shrink(),
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
                            fontSize: viewUtil.isTablet ? 26 : 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                if (_currentStep < 3)
                  Container(
                    padding:
                        const EdgeInsets.only(right: 10, bottom: 5, top: 5),
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
                        onPressed: () async {
                          if (!mounted) return;
                          if (widget.selectedType == 'vehicle') {
                            if (_currentStep == 1) {
                              if (selectedTypeName == null) {
                                commonWidgets.showToast('Please select an option'.tr());
                                return;
                              }
                              setState(() => _currentStep++);
                              return;
                            } else if (_currentStep == 2) {
                              if (_selectedFromTime == null ||
                                  _selectedDate == null ||
                                  productController.text.isEmpty) {
                                commonWidgets.showToast('Please fill all fields'.tr());
                                return;
                              }
                              try {
                                final loadTypes =
                                await fetchLoadsForSelectedType(selectedTypeName ?? '');

                                if (!mounted) return;

                                if (loadTypes.isEmpty || selectedLoad != null) {
                                  setState(() => _currentStep++);
                                } else {
                                  commonWidgets.showToast('Please select Load type'.tr());
                                }
                              } catch (_) {
                                commonWidgets.showToast('Error fetching load types'.tr());
                              }
                            }
                          }
                            if (widget.selectedType == 'bus') {
                              if (_currentStep == 1) {
                                if (selectedBus == null) {
                                  commonWidgets
                                      .showToast('Please select Bus'.tr());
                                } else {
                                  goToNextStep();
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null ||
                                    productController.text.isEmpty) {
                                  commonWidgets
                                      .showToast('Please fill all fields'.tr());
                                } else {
                                  goToNextStep();
                                }
                              }
                            }
                            if (widget.selectedType == 'equipment') {
                              if (_currentStep == 1) {
                                if (selectedTypeName == null) {
                                  commonWidgets.showToast(
                                      'Please select an option'.tr());
                                } else {
                                  goToNextStep();
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null) {
                                  commonWidgets
                                      .showToast('Please fill all fields'.tr());
                                } else {
                                  goToNextStep();
                                }
                              }
                            }
                            if (widget.selectedType == 'shared-cargo') {
                              if (_currentStep == 1) {
                                if (selectedShipmentType == null ||
                                    selectedShipmentCondition == null ||
                                    lengthController.text.isEmpty ||
                                    breadthController.text.isEmpty ||
                                    heightController.text.isEmpty) {
                                  commonWidgets
                                      .showToast('Please fill all fields'.tr());
                                } else {
                                  goToNextStep();
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null ||
                                    productController.text.isEmpty ||
                                    weightController.text.isEmpty) {
                                  commonWidgets
                                      .showToast('Please fill all fields'.tr());
                                } else {
                                  goToNextStep();
                                }
                              }
                            }
                            if (widget.selectedType == 'special' ||
                                widget.selectedType == 'others') {
                              if (_currentStep == 1) {
                                if (selectedSpecial == null) {
                                  commonWidgets.showToast(
                                      'Please select Special/Other Units'.tr());
                                } else {
                                  goToNextStep();
                                }
                              } else if (_currentStep == 2) {
                                if (_selectedFromTime == null ||
                                    _selectedDate == null) {
                                  commonWidgets.showToast('Please fill all fields'.tr());
                                } else {
                                  goToNextStep();
                                }
                              }
                            }
                        },
                        child: Text(
                          'next'.tr(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ? 26 : 18,
                              fontWeight: FontWeight.w500),
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
                          String formattedDate =
                              DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate);
                          String formattedTime =
                              _formatTimeOfDay(context,_selectedFromTime);
                          String formattedToTime =
                              _formatTimeOfDay(context,_selectedToTime);
                          List<String> dropPlaces =
                              _dropPointControllers.map((c) => c.text).toList();

                          String bookingData = buildBookingData(
                            selectedType: widget.selectedType,
                            selectedName: selectedName.toString(),
                            selectedTypeName: selectedTypeName.toString(),
                            selectedLoad: selectedLoad.toString(),
                            selectedLabour: selectedLabour.toString(),
                            formattedDate: formattedDate,
                            formattedTime: formattedTime,
                            formattedToTime: formattedToTime,
                            dropPlaces: dropPlaces,
                            pickup: pickUpController.text,
                            productValue: productController.text,
                            cityName: cityNameController.text,
                            address: addressController.text,
                            zipCode: zipCodeController.text,
                            scale: scale.toString(),
                            typeImage: typeImage.toString(),
                            selectedShipmentType: selectedShipmentType.toString(),
                            selectedShipmentCondition: selectedShipmentCondition.toString(),
                            cargoLength: lengthController.text,
                            cargoBreadth: breadthController.text,
                            cargoHeight: heightController.text,
                            cargoUnit: selectedUnit,
                            shipmentWeight: weightController.text,
                          );

                          bool hasUserToken = widget.token != null && widget.token.isNotEmpty;
                          final UserService userService = UserService();

                          if (hasUserToken) {
                            // Create booking for all types
                            String? bookingId;

                            switch (widget.selectedType) {
                              case 'vehicle':
                                bookingId = await userService.userVehicleCreateBooking(
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
                                break;

                              case 'bus':
                                bookingId = await userService.userBusCreateBooking(
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
                                  token: widget.token,
                                );
                                break;

                              case 'equipment':
                                bookingId = await userService.userEquipmentCreateBooking(
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
                                  token: widget.token,
                                );
                                break;

                              case 'special':
                                bookingId = await userService.userSpecialCreateBooking(
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
                                  token: widget.token,
                                );
                                break;

                              case 'shared-cargo':
                                bookingId = await userService.userSharedCargoCreateBooking(
                                  context,
                                  name: '',
                                  unitType: widget.selectedType,
                                  shipmentType: selectedShipmentType.toString(),
                                  shippingCondition: selectedShipmentCondition.toString(),
                                  cargoLength: lengthController.text,
                                  cargoBreadth: breadthController.text,
                                  cargoHeight: heightController.text,
                                  cargoUnit: selectedUnit,
                                  date: formattedDate,
                                  time: formattedTime,
                                  productValue: productController.text,
                                  shipmentWeight: weightController.text,
                                  pickup: pickUpController.text,
                                  dropPoints: dropPlaces,
                                  token: widget.token,
                                );
                                break;
                            }

                            if (bookingId != null && bookingId.isNotEmpty) {
                              await clearSavedLocalBookingDataWithoutLogin();

                              // Step 1: Show booking dialog first
                              CommonWidgets().showBookingDialog(context: context, bookingId: bookingId);

                              // Step 2: Navigate to ChooseVendor after a short delay
                              Future.delayed(const Duration(seconds: 2), () {
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChooseVendor(
                                      bookingId: bookingId ?? '',
                                      size: scale.toString(),
                                      unitType: widget.selectedType,
                                      unitTypeName: selectedTypeName.toString(),
                                      load: selectedLoad.toString(),
                                      unit: selectedName.toString(),
                                      pickup: pickUpController.text,
                                      dropPoints: dropPlaces,
                                      token: widget.token,
                                      firstName: widget.firstName,
                                      lastName: widget.lastName,
                                      selectedType: widget.selectedType,
                                      cityName: cityNameController.text,
                                      address: addressController.text,
                                      zipCode: zipCodeController.text,
                                      id: widget.id,
                                      email: widget.email,
                                      accountType: widget.accountType,
                                    ),
                                  ),
                                );
                              });
                            }
                          }
                          else {
                            // Not logged in → save locally & go to login
                            bool isSaved = await saveLocalBookingDataWithoutLogin(bookingData);
                            print(bookingData);
                            if (isSaved) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLogin()),
                              );
                            }
                          }
                        },
                        child: Text(
                          'createBooking'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: viewUtil.isTablet ? 26 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDrawer(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEditProfile(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      token: widget.token,
                      id: widget.id,
                      email: widget.email,
                    ),
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
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data?.userProfile == null) {
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
                  widget.firstName + ' ' + widget.lastName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.id,
                  style: TextStyle(color: Color(0xff8E8D96)),
                ),
                trailing: Icon(Icons.edit, color: Colors.grey, size: 20),
              )),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Divider(),
          ),
          ListTile(
              leading: Icon(Icons.home, size: 30, color: Color(0xff707070)),
              title: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Home'.tr(),
                  style: TextStyle(fontSize: 25),
                ),
              ),
              onTap: () {
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
              }),
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
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 30),
                          child: CircularProgressIndicator())),
                );
                try {
                  final bookingData = await booking;

                  if (bookingData != null) {
                    Navigator.pop(context);
                    bookingData['paymentStatus'] == 'Pending' ||
                            bookingData['paymentStatus'] == 'NotPaid'
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
                                unitTypeName: bookingData['type']?.isNotEmpty ??
                                        false
                                    ? bookingData['type'][0]['typeName'] ?? ''
                                    : '',
                                load: bookingData['type']?.isNotEmpty ?? false
                                    ? bookingData['type'][0]['typeOfLoad'] ?? ''
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
                                accountType: widget.accountType,
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
                                          load:
                                              bookingData['type']?.isNotEmpty ??
                                                      false
                                                  ? bookingData['type'][0]
                                                          ['typeOfLoad'] ??
                                                      ''
                                                  : '',
                                          size:
                                              bookingData['type']?.isNotEmpty ??
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
                                          address: bookingData['address'] ?? '',
                                          zipCode: bookingData['zipCode'] ?? '',
                                          unitTypeName:
                                              bookingData['type']?.isNotEmpty ??
                                                      false
                                                  ? bookingData['type'][0]
                                                          ['typeName'] ??
                                                      ''
                                                  : '',
                                          id: widget.id,
                                          partnerName: '',
                                          partnerId:
                                              bookingData['partner'] ?? '',
                                          oldQuotePrice: 0,
                                          paymentStatus:
                                              bookingData['paymentStatus'] ??
                                                  '',
                                          quotePrice: 0,
                                          advanceOrPay:
                                              bookingData['remainingBalance'] ??
                                                  0,
                                          bookingStatus:
                                              bookingData['bookingStatus'] ??
                                                  '',
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
                                          load:
                                              bookingData['type']?.isNotEmpty ??
                                                      false
                                                  ? bookingData['type'][0]
                                                          ['typeOfLoad'] ??
                                                      ''
                                                  : '',
                                          size:
                                              bookingData['type']?.isNotEmpty ??
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
                                          address: bookingData['address'] ?? '',
                                          zipCode: bookingData['zipCode'] ?? '',
                                          unitTypeName:
                                              bookingData['type']?.isNotEmpty ??
                                                      false
                                                  ? bookingData['type'][0]
                                                          ['typeName'] ??
                                                      ''
                                                  : '',
                                          id: widget.id,
                                          partnerId:
                                              bookingData['partner'] ?? '',
                                          bookingStatus:
                                              bookingData['bookingStatus'] ??
                                                  '',
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
                                id: widget.id,
                                email: widget.email,
                              )),
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
                padding: EdgeInsets.only(left: viewUtil.isTablet ? 5 : 10),
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
          ListTile(
              leading: Icon(
                Icons.account_balance_outlined,
                size: 35,
              ),
              title: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Invoice'.tr(),
                  style: TextStyle(fontSize: 25),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInvoice(
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
                  builder: (context) => UserSubmitTicket(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    token: widget.token,
                    id: widget.id,
                    email: widget.email,
                  ),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserHelp(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          email: widget.email)));
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
                              padding: EdgeInsets.only(top: 30, bottom: 10),
                              child: Text(
                                'are_you_sure_you_want_to_logout'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet ? 27 : 19),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'yes'.tr(),
                            style: TextStyle(
                                fontSize: viewUtil.isTablet ? 22 : 16),
                          ),
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
                          child: Text('no'.tr(),
                              style: TextStyle(
                                  fontSize: viewUtil.isTablet ? 22 : 16)),
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
    );
  }

  Widget _buildPublicDrawer(BuildContext context) {
    return Drawer(
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
          Container(
            color: Color(0xffE5EBF8),
            child: ListTile(
                leading: Icon(Icons.person, size: 30),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text(
                    'User'.tr(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                }),
          ),
          ListTile(
            leading: Icon(Icons.people, size: 30),
            title: Padding(
              padding: EdgeInsets.only(left: 7),
              child: Text(
                'Partner'.tr(),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => PartnerHomePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.drive_eta_rounded, size: 30),
            title: Padding(
              padding: EdgeInsets.only(left: 7),
              child: Text(
                'Driver'.tr(),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DriverLogin()));
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, size: 30),
            title: Padding(
              padding: EdgeInsets.only(left: 7),
              child: Text(
                'Help'.tr(),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => UserHelp()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    bool isActive = step == _currentStep;
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? const Color(0xff6A66D1) : const Color(0xffACACAD),
            width: 1),
      ),
      child: CircleAvatar(
        radius: viewUtil.isTablet ? 30 : 20,
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

  Widget _buildLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey,
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
      case 'shared-cargo':
        return sharedCargoContent();
      case 'others':
        return specialContent();
      default:
        return defaultContent();
    }
  }

  Widget buildStepTwoContent(String selectedType) {
    try {
      switch (selectedType) {
        case 'vehicle':
          return UserVehicleStepTwo();
        case 'bus':
          return UserBusStepTwo();
        case 'equipment':
          return UserEquipmentStepTwo();
        case 'special':
          return UserSpecialStepTwo();
        case 'shared-cargo':
          return UserSharedCargoStepTwo();
        case 'others':
          return UserSpecialStepTwo();
        default:
          return defaultContent();
      }
    } catch (e) {
      return Center(child: Text("Error loading step. Please check logs._currentStep: $e"));
    }
  }

  Widget buildStepThreeContent(String selectedType) {
    switch (selectedType) {
      case 'vehicle':
        return UserVehicleStepThree();
      case 'bus':
        return UserBusStepThree();
      case 'equipment':
        return UserEquipmentStepThree();
      case 'special':
        return UserSpecialStepThree();
      case 'shared-cargo':
        return UserSharedCargoStepThree();
      case 'others':
        return UserSpecialStepThree();
      default:
        return defaultContent();
    }
  }

  Widget vehicleContent() {
    ViewUtil viewUtil = ViewUtil(context);
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
                  style: TextStyle(
                      fontSize: viewUtil.isTablet ? 24 : 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    final selectedType =
                        _selectedSubClassification[vehicle.name] ?? '';

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
                              child: SvgPicture.asset(
                                  'assets/delivery-truck.svg',
                                  height: viewUtil.isTablet ? 50 : 35),
                            ),
                            Expanded(
                              flex: 6,
                              child: Text(
                                vehicle.name.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet ? 20 : 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
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
                                  height: 50,
                                  width: double.infinity,
                                  child: PopupMenuButton<String>(
                                    elevation: 5,
                                    constraints: BoxConstraints(
                                      minWidth: viewUtil.isTablet
                                          ? MediaQuery.sizeOf(context).width *
                                              0.92
                                          : 350,
                                      maxWidth: viewUtil.isTablet
                                          ? MediaQuery.sizeOf(context).width *
                                              0.92
                                          : 350,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    offset: Offset(0, 55),
                                    padding: EdgeInsets.zero,
                                    color: Colors.white,
                                    onSelected: (newValue) {
                                      setState(() {
                                        _selectedSubClassification[
                                            vehicle.name] = newValue;
                                        selectedTypeName = newValue;
                                        selectedName = vehicle.name;
                                        var selectedTypeObj = vehicle.types
                                            ?.firstWhere((type) =>
                                                type.typeName == newValue);
                                        scale = selectedTypeObj?.scale;
                                        typeImage = selectedTypeObj?.typeImage;
                                      });
                                    },
                                    itemBuilder: (context) {
                                      return vehicle.types?.map((type) {
                                            return PopupMenuItem<String>(
                                              value: type.typeName,
                                              child: Directionality(
                                                textDirection:
                                                ui.TextDirection.ltr,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.asset(
                                                        type.typeImage,
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                        height:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .height *
                                                                0.06,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(type.typeName.tr(),
                                                            style: TextStyle(
                                                                fontSize: viewUtil
                                                                        .isTablet
                                                                    ? 22
                                                                    : 16)),
                                                        Text(type.scale,
                                                            style: TextStyle(
                                                                fontSize: viewUtil
                                                                        .isTablet
                                                                    ? 20
                                                                    : 14)),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList() ??
                                          [];
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedType.isEmpty
                                                  ? 'select'.tr()
                                                  : selectedType.tr(),
                                              style: TextStyle(
                                                  fontSize: viewUtil.isTablet
                                                      ? 20
                                                      : 16),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(Icons.arrow_drop_down,
                                              size:
                                                  viewUtil.isTablet ? 25 : 20),
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
    ViewUtil viewUtil = ViewUtil(context);
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
                  style: TextStyle(
                      fontSize: viewUtil.isTablet ? 24 : 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    childAspectRatio: 1,
                  ),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    final isBusSelected = selectedBus == index;
                    print(bus.image);
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
                                      padding: viewUtil.isTablet
                                          ? EdgeInsets.only(
                                              top: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.08,
                                              bottom: 10)
                                          : EdgeInsets.only(
                                              top: 45, bottom: 10),
                                      child: MyVectorImage(
                                        name: bus.image,
                                        height: viewUtil.isTablet ? 70 : 40,
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Divider(
                                      indent: viewUtil.isTablet ? 15 : 7,
                                      endIndent: viewUtil.isTablet ? 15 : 7,
                                      color: Color(0xffACACAD),
                                      thickness: 1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text(
                                        bus.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize:
                                                viewUtil.isTablet ? 20 : 15),
                                      ),
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
    ViewUtil viewUtil = ViewUtil(context);
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
                  style: TextStyle(
                      fontSize: viewUtil.isTablet ? 24 : 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    final equipments = equipment[index];
                    final selectedType =
                        _selectedSubClassification[equipments.name] ?? '';
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
                              child: SvgPicture.asset(
                                  'assets/delivery-truck.svg',
                                  height: viewUtil.isTablet ? 50 : 35),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                equipments.name.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet ? 20 : 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                child: const VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                child: PopupMenuButton<String>(
                                  elevation: 5,
                                  constraints: BoxConstraints(
                                    minWidth: viewUtil.isTablet
                                        ? MediaQuery.sizeOf(context).width *
                                            0.92
                                        : 350,
                                    maxWidth: viewUtil.isTablet
                                        ? MediaQuery.sizeOf(context).width *
                                            0.92
                                        : 350,
                                  ),
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
                                          ?.firstWhere((type) =>
                                              type.typeName == newValue)
                                          .typeImage;
                                    });
                                  },
                                  itemBuilder: (context) {
                                    return equipments.types?.map((type) {
                                          return PopupMenuItem<String>(
                                            value: type.typeName,
                                            child: Directionality(
                                              textDirection:
                                                  ui.TextDirection.ltr,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.asset(
                                                        type.typeImage,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.04,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Text(type.typeName.tr(),
                                                        style: TextStyle(
                                                            fontSize: viewUtil
                                                                    .isTablet
                                                                ? 22
                                                                : 16)),
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
                                                    : equipments.types
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? equipments.types!
                                                            .first.typeName
                                                        : 'no_data'.tr(),
                                            style: TextStyle(
                                                fontSize: viewUtil.isTablet
                                                    ? 20
                                                    : 16),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(Icons.arrow_drop_down,
                                            size: viewUtil.isTablet ? 25 : 20),
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
    ViewUtil viewUtil = ViewUtil(context);
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
                  style: TextStyle(
                      fontSize: viewUtil.isTablet ? 24 : 16,
                      fontWeight: FontWeight.w500),
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
                                          ? Color(
                                              0xff6A66D1,
                                            )
                                          : Color(0xffACACAD),
                                      width: isSpecialSelected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: viewUtil.isTablet
                                          ? EdgeInsets.only(
                                              top: MediaQuery.sizeOf(context)
                                                      .width *
                                                  0.08,
                                              bottom: 10)
                                          : EdgeInsets.only(
                                              top: 45, bottom: 10),
                                      child: MyVectorImage(
                                        name: specials.image,
                                        height: viewUtil.isTablet ? 70 : 40,
                                      ),
                                    ),
                                    SizedBox(height: 7),
                                    Divider(
                                      indent: viewUtil.isTablet ? 15 : 7,
                                      endIndent: viewUtil.isTablet ? 15 : 7,
                                      color: Color(0xffACACAD),
                                      thickness: 1,
                                    ),
                                    Text(
                                      specials.name.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize:
                                              viewUtil.isTablet ? 20 : 15),
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

  Widget sharedCargoContent() {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 20, bottom: 30),
                child: Text(
                  'Cost for Shared Shipping'.tr(),
                  style: TextStyle(
                      fontSize: viewUtil.isTablet ? 24 : 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              commonWidgets.buildDropdown(
                label: 'Shipment Type'.tr(),
                selectedValue: selectedShipmentType,
                items: shipmentTypeItems,
                isTablet: viewUtil.isTablet,
                onChanged: (newValue) {
                  setState(() {
                    selectedShipmentType = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              commonWidgets.buildDropdown(
                label: 'Shipping Condition'.tr(),
                selectedValue: selectedShipmentCondition,
                items: shipmentConditionItems,
                isTablet: viewUtil.isTablet,
                onChanged: (newValue) {
                  setState(() {
                    selectedShipmentCondition = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              commonWidgets.buildCargoLabeledTextField(
                label: 'Length',
                controller: lengthController,
                context: context,
                isTablet: viewUtil.isTablet,
                hintText: 'Length',
                selectedUnit: selectedUnit,
                onUnitChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              commonWidgets.buildCargoLabeledTextField(
                label: 'Breadth',
                controller: breadthController,
                context: context,
                isTablet: viewUtil.isTablet,
                hintText: 'Breadth',
                selectedUnit: selectedUnit,
                onUnitChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              commonWidgets.buildCargoLabeledTextField(
                label: 'Height',
                controller: heightController,
                context: context,
                isTablet: viewUtil.isTablet,
                hintText: 'Height',
                selectedUnit: selectedUnit,
                onUnitChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
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

  Widget UserVehicleStepTwo() {
    ViewUtil viewUtil = ViewUtil(context);
    String formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate)
        : '';
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                        FontAwesomeIcons.clock,
                        color: const Color(0xffBCBCBC),
                        size: viewUtil.isTablet ? 27 : 20,
                      ),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _selectedFromTime != null
                            ? _formatTimeOfDay(context,_selectedFromTime)
                            : 'Select time',
                        style:
                            TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.calendar,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate.isEmpty ? 'Select date' : formattedDate,
                          style: TextStyle(
                              fontSize: viewUtil.isTablet ? 20 : 16)),
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
                "${'valueOfProduct'.tr()} (SAR)",
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
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
                hintStyle:
                    const TextStyle(color: Color(0xffCCCCCC), fontSize: 16),
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
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'loadType'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && productValueFocusNode.hasFocus) {
                    productValueFocusNode.unfocus();
                  }
                });
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
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 20 : 16,
                          fontWeight: FontWeight.w500),
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

  Widget UserBusStepTwo() {
    ViewUtil viewUtil = ViewUtil(context);
    String formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate)
        : '';
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.clock,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedFromTime != null
                          ? _formatTimeOfDay(context,_selectedFromTime)
                          : 'Select time',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 90 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.calendar,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate.isEmpty ? 'Select date' : formattedDate,
                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                "${'valueOfProduct'.tr()} (SAR)",
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
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
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 20 : 16,
                          fontWeight: FontWeight.w500),
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
    ViewUtil viewUtil = ViewUtil(context);
    String formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate)
        : '';
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.clock,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedFromTime != null
                          ? _formatTimeOfDay(context,_selectedFromTime)
                          : 'Select from time',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                'toTime'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _selectToTime(context);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.clock,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedToTime != null
                          ? _formatTimeOfDay(context,_selectedToTime)
                          : 'Select to time',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                'startingDate'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.calendar,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate.isNotEmpty
                          ? formattedDate
                          : 'Select date',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
                    ),
                ],
              ),
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
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 20 : 16,
                          fontWeight: FontWeight.w500),
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
    ViewUtil viewUtil = ViewUtil(context);
    String formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate)
        : '';
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
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                        FontAwesomeIcons.clock,
                        color: Color(0xffBCBCBC),
                        size: viewUtil.isTablet ? 27 : 20,
                      ),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedFromTime != null
                          ? _formatTimeOfDay(context,_selectedFromTime)
                          : 'Select from time',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                'toTime'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _selectToTime(context);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                        FontAwesomeIcons.clock,
                        color: Color(0xffBCBCBC),
                        size: viewUtil.isTablet ? 27 : 20,
                      ),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedToTime != null
                          ? _formatTimeOfDay(context,_selectedToTime)
                          : 'Select to time',
                          style:TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
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
                'startingDate'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                        FontAwesomeIcons.calendar,
                        color: Color(0xffBCBCBC),
                        size: viewUtil.isTablet ? 27 : 20,
                      ),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate.isEmpty ? 'Select date' : formattedDate,
                          style:
                              TextStyle(fontSize: viewUtil.isTablet ? 20 : 16)),
                    ),
                ],
              ),
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
                      style: TextStyle(
                          fontSize: viewUtil.isTablet ? 20 : 16,
                          fontWeight: FontWeight.w500),
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

  Widget UserSharedCargoStepTwo() {
    ViewUtil viewUtil = ViewUtil(context);
    String formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate)
        : '';
    return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
      overscroll: false,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Shipping Time'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                        FontAwesomeIcons.clock,
                        color: const Color(0xffBCBCBC),
                        size: viewUtil.isTablet ? 27 : 20,
                      ),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedFromTime != null
                          ? _formatTimeOfDay(context,_selectedFromTime)
                          : 'Select time',
                        style:
                            TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
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
                'Shipping Date'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(FontAwesomeIcons.calendar,
                          color: Color(0xffBCBCBC),
                          size: viewUtil.isTablet ? 27 : 20),
                  ),
                  Container(
                    width: 1,
                    height: viewUtil.isTablet ? 60 : 50,
                    color: const Color(0xffBCBCBC),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate.isEmpty ? 'Select date' : formattedDate,
                          style: TextStyle(
                              fontSize: viewUtil.isTablet ? 20 : 16)),
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
                "${'Shipment Value'.tr()} (SAR)",
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
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
                hintStyle:
                    const TextStyle(color: Color(0xffCCCCCC), fontSize: 16),
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
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 22),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "${'Shipment Weight'.tr()} (Kg)",
                style: TextStyle(
                    fontSize: viewUtil.isTablet ? 20 : 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextFormField(
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              controller: weightController,
              decoration: InputDecoration(
                hintStyle:
                    const TextStyle(color: Color(0xffCCCCCC), fontSize: 16),
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
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget UserVehicleStepThree() {
    ViewUtil viewUtil = ViewUtil(context);
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
                height: viewUtil.isTablet
                    ? MediaQuery.of(context).size.height * 0.9
                    : MediaQuery.of(context).size.height * 0.6,
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
                  padding: viewUtil.isTablet
                      ? EdgeInsets.only(left: 45, right: 45)
                      : EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 17, 10, 10),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff009E10),
                                    minRadius: 6,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: viewUtil.isTablet ? 60 : 40,
                                    padding: viewUtil.isTablet
                                        ? EdgeInsets.only(right: 8, top: 10)
                                        : EdgeInsets.only(right: 3, top: 0),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) =>
                                          _fetchSuggestions(value, -1, true),
                                      controller: pickUpController,
                                      decoration: InputDecoration(
                                        suffixIcon: Tooltip(
                                          message:
                                              'Locate Current Location'.tr(),
                                          child: IconButton(
                                              onPressed: () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await locateCurrentPosition();
                                              },
                                              icon: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 7),
                                                child: Icon(
                                                  Icons.my_location,
                                                  size: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  color: Color(0xff6A66D1),
                                                ),
                                              )),
                                        ),
                                        hintText: 'Pick Up'.tr(),
                                        hintStyle: TextStyle(
                                            color: Color(0xff707070),
                                            fontSize:
                                                viewUtil.isTablet ? 20 : 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pickUpSuggestions.isNotEmpty &&
                                pickUpController.text.isNotEmpty)
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
                                            Icon(
                                              Icons.my_location_outlined,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 13,
                                                  right:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.25),
                                              child:
                                                  Text('Current Location'.tr()),
                                            ),
                                            isLocating
                                                ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                        onTap: () async {
                                          await currentPositionSuggestion();
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title:
                                            Text(_pickUpSuggestions[index - 1]),
                                        onTap: () => _onSuggestionTap(
                                            _pickUpSuggestions[index - 1],
                                            pickUpController,
                                            true),
                                      );
                                    }
                                  },
                                ),
                              ),
                            const Divider(
                              indent: 5,
                              endIndent: 5,
                            ),
                            ..._dropPointControllers
                                .asMap()
                                .entries
                                .map((entry) {
                              int i = entry.key;
                              TextEditingController controller = entry.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 5, 10),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE20808),
                                          minRadius: 6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: viewUtil.isTablet ? 60 : 43,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            onChanged: (value) =>
                                                _fetchSuggestions(
                                                    value, i, false),
                                            controller: controller,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText:
                                                  '${'Drop Point'.tr()} ${i + 1}',
                                              hintStyle: TextStyle(
                                                  color: Color(0xff707070),
                                                  fontSize: viewUtil.isTablet
                                                      ? 20
                                                      : 15),
                                              border: InputBorder.none,
                                              suffixIcon: i ==
                                                      _dropPointControllers
                                                              .length -
                                                          1
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              viewUtil.isTablet
                                                                  ? 10
                                                                  : 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (_dropPointControllers
                                                                  .length >
                                                              1)
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _removeTextField(
                                                                      i),
                                                              child: Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color: Colors
                                                                      .red,
                                                                  size: viewUtil
                                                                          .isTablet
                                                                      ? 25
                                                                      : 20),
                                                            ),
                                                          if (_dropPointControllers
                                                                  .length ==
                                                              1)
                                                            GestureDetector(
                                                              onTap:
                                                                  _addTextField,
                                                              child: Icon(
                                                                Icons
                                                                    .add_circle_outline_sharp,
                                                                size: viewUtil
                                                                        .isTablet
                                                                    ? 25
                                                                    : 20,
                                                              ),
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
                                  if (_dropPointSuggestions[i] != null &&
                                      _dropPointSuggestions[i]!.isNotEmpty &&
                                      controller.text.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount:
                                            _dropPointSuggestions[i]!.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dropPointSuggestions[
                                                i]![index]),
                                            onTap: () => _onSuggestionTap(
                                                _dropPointSuggestions[i]![
                                                    index],
                                                controller,
                                                false),
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
                                fontSize: viewUtil.isTablet ? 23 : 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget UserBusStepThree() {
    ViewUtil viewUtil = ViewUtil(context);
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
                height: viewUtil.isTablet
                    ? MediaQuery.of(context).size.height * 0.9
                    : MediaQuery.of(context).size.height * 0.6,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 17, 10, 10),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff009E10),
                                    minRadius: 6,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: viewUtil.isTablet ? 60 : 40,
                                    padding: viewUtil.isTablet
                                        ? EdgeInsets.only(right: 8, top: 10)
                                        : EdgeInsets.only(right: 3, top: 0),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) =>
                                          _fetchSuggestions(value, -1, true),
                                      controller: pickUpController,
                                      decoration: InputDecoration(
                                        suffixIcon: Tooltip(
                                          message:
                                              'Locate Current Location'.tr(),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: IconButton(
                                                onPressed: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(
                                                  Icons.my_location,
                                                  size: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  color: Color(0xff6A66D1),
                                                )),
                                          ),
                                        ),
                                        hintText: 'Pick Up'.tr(),
                                        hintStyle: TextStyle(
                                            color: Color(0xff707070),
                                            fontSize:
                                                viewUtil.isTablet ? 20 : 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pickUpSuggestions.isNotEmpty &&
                                pickUpController.text.isNotEmpty)
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
                                            Icon(
                                              Icons.my_location_outlined,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 13,
                                                  right:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.25),
                                              child:
                                                  Text('Current Location'.tr()),
                                            ),
                                            isLocating
                                                ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                        onTap: () async {
                                          await currentPositionSuggestion();
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title:
                                            Text(_pickUpSuggestions[index - 1]),
                                        onTap: () => _onSuggestionTap(
                                            _pickUpSuggestions[index - 1],
                                            pickUpController,
                                            true),
                                      );
                                    }
                                  },
                                ),
                              ),
                            const Divider(
                              indent: 5,
                              endIndent: 5,
                            ),
                            ..._dropPointControllers
                                .asMap()
                                .entries
                                .map((entry) {
                              int i = entry.key;
                              TextEditingController controller = entry.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 5, 10),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE20808),
                                          minRadius: 6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: viewUtil.isTablet ? 60 : 43,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            onChanged: (value) =>
                                                _fetchSuggestions(
                                                    value, i, false),
                                            controller: controller,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText:
                                                  '${'Drop Point'.tr()} ${i + 1}',
                                              hintStyle: TextStyle(
                                                  color: Color(0xff707070),
                                                  fontSize: viewUtil.isTablet
                                                      ? 20
                                                      : 15),
                                              border: InputBorder.none,
                                              suffixIcon: i ==
                                                      _dropPointControllers
                                                              .length -
                                                          1
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              viewUtil.isTablet
                                                                  ? 10
                                                                  : 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (_dropPointControllers
                                                                  .length >
                                                              1)
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _removeTextField(
                                                                      i),
                                                              child: Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color: Colors
                                                                      .red,
                                                                  size: viewUtil
                                                                          .isTablet
                                                                      ? 25
                                                                      : 20),
                                                            ),
                                                          if (_dropPointControllers
                                                                  .length ==
                                                              1)
                                                            GestureDetector(
                                                              onTap:
                                                                  _addTextField,
                                                              child: Icon(
                                                                Icons
                                                                    .add_circle_outline_sharp,
                                                                size: viewUtil
                                                                        .isTablet
                                                                    ? 25
                                                                    : 20,
                                                              ),
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
                                  if (_dropPointSuggestions[i] != null &&
                                      _dropPointSuggestions[i]!.isNotEmpty &&
                                      controller.text.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount:
                                            _dropPointSuggestions[i]!.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dropPointSuggestions[
                                                i]![index]),
                                            onTap: () => _onSuggestionTap(
                                                _dropPointSuggestions[i]![
                                                    index],
                                                controller,
                                                false),
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
                                fontSize: viewUtil.isTablet ? 23 : 16,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget UserEquipmentStepThree() {
    ViewUtil viewUtil = ViewUtil(context);
    return GestureDetector(
      onTap: () {
        _dismissAddressSuggestions();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: viewUtil.isTablet
                    ? EdgeInsets.only(left: 45, right: 45)
                    : EdgeInsets.only(left: 30, right: 30),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 15, 5),
                                    child: SvgPicture.asset('assets/search.svg',
                                        height: viewUtil.isTablet ? 20 : 14)),
                                Expanded(
                                  child: Container(
                                    height: viewUtil.isTablet ? 40 : 30,
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: cityNameController,
                                      onChanged: (value) =>
                                          _fetchAddressSuggestions(
                                              value, 'city'),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Tooltip(
                                            message:
                                                'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(
                                                  Icons.my_location,
                                                  size: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  color: Color(0xff6A66D1),
                                                )),
                                          ),
                                        ),
                                        hintText: 'enterCityName'.tr(),
                                        hintStyle: TextStyle(
                                            color: Color(0xff707070),
                                            fontSize:
                                                viewUtil.isTablet ? 23 : 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_cityNameSuggestions.isNotEmpty &&
                              cityNameController.text.isNotEmpty)
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
                                          Icon(
                                            Icons.my_location_outlined,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 13,
                                                right:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.25),
                                            child:
                                                Text('Current Location'.tr()),
                                          ),
                                          isLocating
                                              ? Container(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      onTap: () async {
                                        await currentPositionSuggestionForCity();
                                      },
                                    );
                                  } else {
                                    return ListTile(
                                      title:
                                          Text(_cityNameSuggestions[index - 1]),
                                      onTap: () => _onAddressSuggestionTap(
                                          _cityNameSuggestions[index - 1],
                                          cityNameController,
                                          'city'),
                                    );
                                  }
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 15, 10),
                                  child: SvgPicture.asset('assets/address.svg',
                                      height: viewUtil.isTablet ? 23 : 15)),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: viewUtil.isTablet ? 40 : 33,
                                  child: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: addressController,
                                    onChanged: (value) =>
                                        _fetchAddressSuggestions(
                                            value, 'address'),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'enterYourAddress'.tr(),
                                      hintStyle: TextStyle(
                                          color: Color(0xff707070),
                                          fontSize:
                                              viewUtil.isTablet ? 22 : 15),
                                      border: InputBorder.none,
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_addressSuggestions.isNotEmpty &&
                              addressController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _addressSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_addressSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(
                                        _addressSuggestions[index],
                                        addressController,
                                        'address'),
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
                              fontSize: viewUtil.isTablet ? 23 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: viewUtil.isTablet
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height * 0.45,
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
    ViewUtil viewUtil = ViewUtil(context);
    return GestureDetector(
      onTap: () {
        _dismissAddressSuggestions();
      },
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: viewUtil.isTablet
                    ? EdgeInsets.only(left: 45, right: 45)
                    : EdgeInsets.only(left: 30, right: 30),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 8, 15, 5),
                                    child: SvgPicture.asset('assets/search.svg',
                                        height: viewUtil.isTablet ? 20 : 14)),
                                Expanded(
                                  child: Container(
                                    height: viewUtil.isTablet ? 40 : 30,
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: cityNameController,
                                      onChanged: (value) =>
                                          _fetchAddressSuggestions(
                                              value, 'city'),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Tooltip(
                                            message:
                                                'Locate Current Location'.tr(),
                                            child: IconButton(
                                                onPressed: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await locateCurrentPosition();
                                                },
                                                icon: Icon(
                                                  Icons.my_location,
                                                  size: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  color: Color(0xff6A66D1),
                                                )),
                                          ),
                                        ),
                                        hintText: 'enterCityName'.tr(),
                                        hintStyle: TextStyle(
                                            color: Color(0xff707070),
                                            fontSize:
                                                viewUtil.isTablet ? 23 : 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_cityNameSuggestions.isNotEmpty &&
                              cityNameController.text.isNotEmpty)
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
                                          Icon(
                                            Icons.my_location_outlined,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 13,
                                                right:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.25),
                                            child:
                                                Text('Current Location'.tr()),
                                          ),
                                          isLocating
                                              ? Container(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                      onTap: () async {
                                        await currentPositionSuggestionForCity();
                                      },
                                    );
                                  } else {
                                    return ListTile(
                                      title:
                                          Text(_cityNameSuggestions[index - 1]),
                                      onTap: () => _onAddressSuggestionTap(
                                          _cityNameSuggestions[index - 1],
                                          cityNameController,
                                          'city'),
                                    );
                                  }
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 8, 15, 10),
                                  child: SvgPicture.asset('assets/address.svg',
                                      height: viewUtil.isTablet ? 23 : 15)),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: viewUtil.isTablet ? 40 : 33,
                                  child: TextFormField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: addressController,
                                    onChanged: (value) =>
                                        _fetchAddressSuggestions(
                                            value, 'address'),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'enterYourAddress'.tr(),
                                      hintStyle: TextStyle(
                                          color: Color(0xff707070),
                                          fontSize:
                                              viewUtil.isTablet ? 22 : 15),
                                      border: InputBorder.none,
                                      // contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_addressSuggestions.isNotEmpty &&
                              addressController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _addressSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_addressSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(
                                        _addressSuggestions[index],
                                        addressController,
                                        'address'),
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
                              fontSize: viewUtil.isTablet ? 23 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: viewUtil.isTablet
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height * 0.45,
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

  Widget UserSharedCargoStepThree() {
    ViewUtil viewUtil = ViewUtil(context);
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
                height: viewUtil.isTablet
                    ? MediaQuery.of(context).size.height * 0.9
                    : MediaQuery.of(context).size.height * 0.6,
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
                  padding: viewUtil.isTablet
                      ? EdgeInsets.only(left: 45, right: 45)
                      : EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 17, 10, 10),
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff009E10),
                                    minRadius: 6,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: viewUtil.isTablet ? 60 : 40,
                                    padding: viewUtil.isTablet
                                        ? EdgeInsets.only(right: 8, top: 10)
                                        : EdgeInsets.only(right: 3, top: 0),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) =>
                                          _fetchSuggestions(value, -1, true),
                                      controller: pickUpController,
                                      decoration: InputDecoration(
                                        suffixIcon: Tooltip(
                                          message:
                                              'Locate Current Location'.tr(),
                                          child: IconButton(
                                              onPressed: () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                await locateCurrentPosition();
                                              },
                                              icon: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 7),
                                                child: Icon(
                                                  Icons.my_location,
                                                  size: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  color: Color(0xff6A66D1),
                                                ),
                                              )),
                                        ),
                                        hintText: 'Pick Up'.tr(),
                                        hintStyle: TextStyle(
                                            color: Color(0xff707070),
                                            fontSize:
                                                viewUtil.isTablet ? 20 : 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_pickUpSuggestions.isNotEmpty &&
                                pickUpController.text.isNotEmpty)
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
                                            Icon(
                                              Icons.my_location_outlined,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 13,
                                                  right:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.25),
                                              child:
                                                  Text('Current Location'.tr()),
                                            ),
                                            isLocating
                                                ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                        onTap: () async {
                                          await currentPositionSuggestion();
                                        },
                                      );
                                    } else {
                                      return ListTile(
                                        title:
                                            Text(_pickUpSuggestions[index - 1]),
                                        onTap: () => _onSuggestionTap(
                                            _pickUpSuggestions[index - 1],
                                            pickUpController,
                                            true),
                                      );
                                    }
                                  },
                                ),
                              ),
                            const Divider(
                              indent: 5,
                              endIndent: 5,
                            ),
                            ..._dropPointControllers
                                .asMap()
                                .entries
                                .map((entry) {
                              int i = entry.key;
                              TextEditingController controller = entry.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 5, 10),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE20808),
                                          minRadius: 6,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: viewUtil.isTablet ? 60 : 43,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            onChanged: (value) =>
                                                _fetchSuggestions(
                                                    value, i, false),
                                            controller: controller,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText:
                                                  '${'Drop Point'.tr()} ${i + 1}',
                                              hintStyle: TextStyle(
                                                  color: Color(0xff707070),
                                                  fontSize: viewUtil.isTablet
                                                      ? 20
                                                      : 15),
                                              border: InputBorder.none,
                                              suffixIcon: i ==
                                                      _dropPointControllers
                                                              .length -
                                                          1
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              viewUtil.isTablet
                                                                  ? 10
                                                                  : 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (_dropPointControllers
                                                                  .length >
                                                              1)
                                                            GestureDetector(
                                                              onTap: () =>
                                                                  _removeTextField(
                                                                      i),
                                                              child: Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color: Colors
                                                                      .red,
                                                                  size: viewUtil
                                                                          .isTablet
                                                                      ? 25
                                                                      : 20),
                                                            ),
                                                          if (_dropPointControllers
                                                                  .length ==
                                                              1)
                                                            GestureDetector(
                                                              onTap:
                                                                  _addTextField,
                                                              child: Icon(
                                                                Icons
                                                                    .add_circle_outline_sharp,
                                                                size: viewUtil
                                                                        .isTablet
                                                                    ? 25
                                                                    : 20,
                                                              ),
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
                                  if (_dropPointSuggestions[i] != null &&
                                      _dropPointSuggestions[i]!.isNotEmpty &&
                                      controller.text.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount:
                                            _dropPointSuggestions[i]!.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dropPointSuggestions[
                                                i]![index]),
                                            onTap: () => _onSuggestionTap(
                                                _dropPointSuggestions[i]![
                                                    index],
                                                controller,
                                                false),
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
                                fontSize: viewUtil.isTablet ? 23 : 16,
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

  @override
  void dispose() {
    for (var controller in _dropPointControllers) {
      controller.dispose();
    }
    timeController.dispose();
    productController.dispose();
    pickUpController.dispose();
    cityNameController.dispose();
    zipCodeController.dispose();
    addressController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    weightController.dispose();

    productValueFocusNode.dispose();
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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          commonWidgets.showToast('Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        commonWidgets.showToast(
            'Location permanently denied. Please enable it in settings.');
        await Geolocator.openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String place = 'Unknown location';
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        place =
            "${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      }

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 10.0),
        );
      }

      setState(() {
        pickUpController.text = place;
        cityNameController.text = place;
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation,
            infoWindow: InfoWindow(
              title: 'your_location'.tr(),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });
    } catch (e) {
      print("Error locating position: $e");
      commonWidgets.showToast('An error occurred. Please try again.');
    }
  }

  Future<void> currentPositionSuggestion() async {
    setState(() {
      isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => isLocating = false);
        await Geolocator.openAppSettings();
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
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
            markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                infoWindow: InfoWindow(
                  title: 'Current Location',
                  snippet: formattedAddress,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );
          });
        } else {
          setState(() => isLocating = false);
        }
      } else {
        setState(() => isLocating = false);
      }
    } catch (e) {
      setState(() => isLocating = false);
    }
  }

  Future<void> currentPositionSuggestionForCity() async {
    setState(() {
      isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => isLocating = false);
        await Geolocator.openAppSettings();
        return;
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best,
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
            cityNameController.text = formattedAddress;
            isLocating = false;
            _cityNameSuggestions = [];
            markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position:
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                infoWindow: InfoWindow(
                  title: 'Current Location',
                  snippet: formattedAddress,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );
          });
        } else {
          setState(() => isLocating = false);
        }
      } else {
        setState(() => isLocating = false);
      }
    } catch (e) {
      setState(() => isLocating = false);
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
          } else {}
        } else {}

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
              } else {}
            } else {}
          } else {}
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
            } else {}
          } else {}
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mapController != null && pickupLatLng != null) {
            _moveCameraToFitAllMarkers();
          }
        });
      } else {}
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<void> _fetchAddressCoordinates() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';

      String cityName = cityNameController.text.trim();
      String address = addressController.text.trim();
      String zipCode = zipCodeController.text.trim();

      if (cityName.isEmpty || address.isEmpty) {
        commonWidgets.showToast(
            'Please enter both city name and address to locate the place.');
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
          } else {}
        } else {}
      } else {}
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

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final predictions = data['predictions'] as List<dynamic>;

          setState(() {
            if (isPickUp) {
              _pickUpSuggestions =
                  predictions.map((p) => p['description'] as String).toList();
            } else {
              _dropPointSuggestions[index] =
                  predictions.map((p) => p['description'] as String).toList();
            }
          });
        } else {
          return;
        }
      } catch (e) {
        commonWidgets.showToast('An error occurred, Please try again.');
      }
    });
  }

  void _onSuggestionTap(
      String suggestion, TextEditingController controller, bool isPickUp) {
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

    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final predictions = data['predictions'] as List<dynamic>;

          setState(() {
            if (type == 'city') {
              _cityNameSuggestions =
                  predictions.map((p) => p['description'] as String).toList();
            } else if (type == 'address') {
              _addressSuggestions =
                  predictions.map((p) => p['description'] as String).toList();
            } else if (type == 'zipCode') {
              _zipCodeSuggestions =
                  predictions.map((p) => p['description'] as String).toList();
            }
          });
        } else {}
      } catch (e) {
        commonWidgets.showToast('An error occurred, Please try again.');
      }
    });
  }

  void _onAddressSuggestionTap(
      String suggestion, TextEditingController controller, String type) {
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

  Future<List<LoadType>> fetchLoadsForSelectedType(
      String selectedTypeName) async {
    try {
      List<Vehicle> vehicles = await userService.fetchUserVehicle();

      var selectedType = vehicles.expand((vehicle) => vehicle.types).firstWhere(
            (type) => type.typeName == selectedTypeName,
            orElse: () => VehicleType(
                typeName: '', typeOfLoad: [], typeImage: '', scale: ''),
          );
      return selectedType.typeOfLoad;
    } catch (e) {
      return [];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!mounted) return;

    final now = DateTime.now();

    final DateTime safeInitialDate = (_selectedDate != null &&
        _selectedDate.isAfter(DateTime(2000)) &&
        _selectedDate.isBefore(DateTime(2100)))
        ? _selectedDate
        : now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: commonWidgets.normalizeLocaleFromLocale(context.locale),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!mounted || _isTimePickerOpen) return;

    _isTimePickerOpen = true;

    final initialTime = _selectedFromTime ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: commonWidgets.normalizeLocaleFromLocale(context.locale),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );

    _isTimePickerOpen = false;
    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedFromTime = picked;
      });
    }
  }

  Future<void> _selectToTime(BuildContext context) async {
    if (!mounted || _isTimePickerOpen) return;

    _isTimePickerOpen = true;

    final initialTime = _selectedToTime ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: commonWidgets.normalizeLocaleFromLocale(context.locale),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );

    _isTimePickerOpen = false;
    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _selectedToTime = picked;
      });
    }
  }

  String _formatTimeOfDay(BuildContext context, TimeOfDay time) {
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
    String formattedDate = DateFormat('yyyy-MM-dd',commonWidgets.normalizeLocaleFromLocale(context.locale).languageCode).format(_selectedDate);
    String formattedTime = _formatTimeOfDay(context,_selectedFromTime);
    String formattedToTime = _formatTimeOfDay(context,_selectedToTime);
    List<String> dropPlaces =
        _dropPointControllers.map((controller) => controller.text).toList();

    if (widget.selectedType == 'vehicle') {
      if (pickUpController.text.isEmpty ||
          dropPlaces.contains('') ||
          dropPlaces.isEmpty) {
        commonWidgets.showToast('Choose Pickup and DropPoints'.tr());
      } else {
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
            CommonWidgets()
                .showBookingDialog(context: context, bookingId: bookingId);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseVendor(
                    bookingId: bookingId,
                    size: scale.toString(),
                    unitType: widget.selectedType,
                    unitTypeName: selectedTypeName.toString(),
                    load: selectedLoad.toString(),
                    unit: selectedName.toString(),
                    pickup: pickUpController.text,
                    dropPoints: dropPlaces,
                    token: widget.token,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    selectedType: widget.selectedType,
                    cityName: cityNameController.text,
                    address: addressController.text,
                    zipCode: zipCodeController.text,
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
    if (widget.selectedType == 'bus') {
      if (pickUpController.text.isEmpty ||
          dropPlaces.contains('') ||
          dropPlaces.isEmpty) {
        commonWidgets.showToast('Choose Pickup and DropPoints'.tr());
      } else {
        String? bookingId = await userService.userBusCreateBooking(context,
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
        if (bookingId != null) {
          CommonWidgets()
              .showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseVendor(
                  bookingId: bookingId,
                  size: scale.toString(),
                  unitType: widget.selectedType,
                  load: selectedLoad.toString(),
                  unit: selectedName.toString(),
                  unitTypeName: '',
                  pickup: pickUpController.text,
                  dropPoints: dropPlaces,
                  token: widget.token,
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  selectedType: widget.selectedType,
                  cityName: '',
                  address: '',
                  zipCode: '',
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
    if (widget.selectedType == 'equipment') {
      if (cityNameController.text.isEmpty || addressController.text.isEmpty) {
        commonWidgets.showToast('Choose City name and Address'.tr());
      } else {
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
        if (bookingId != null) {
          CommonWidgets()
              .showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseVendor(
                  bookingId: bookingId,
                  size: scale.toString(),
                  unitType: widget.selectedType,
                  load: selectedLoad.toString(),
                  unit: selectedName.toString(),
                  unitTypeName: selectedTypeName.toString(),
                  pickup: pickUpController.text,
                  dropPoints: dropPlaces,
                  token: widget.token,
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  selectedType: widget.selectedType,
                  cityName: cityNameController.text,
                  address: addressController.text,
                  zipCode: zipCodeController.text,
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
    if (widget.selectedType == 'special') {
      if (cityNameController.text.isEmpty || addressController.text.isEmpty) {
        commonWidgets.showToast('Choose City name and Address'.tr());
      } else {
        String? bookingId = await userService.userSpecialCreateBooking(context,
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
        if (bookingId != null) {
          CommonWidgets()
              .showBookingDialog(context: context, bookingId: bookingId);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseVendor(
                  bookingId: bookingId,
                  size: scale.toString(),
                  unitType: widget.selectedType,
                  unitTypeName: '',
                  load: selectedLoad.toString(),
                  unit: selectedName.toString(),
                  pickup: '',
                  dropPoints: [],
                  token: widget.token,
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  selectedType: widget.selectedType,
                  cityName: cityNameController.text,
                  address: addressController.text,
                  zipCode: zipCodeController.text,
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
    if (widget.selectedType == 'shared-cargo') {
      if (pickUpController.text.isEmpty ||
          dropPlaces.contains('') ||
          dropPlaces.isEmpty) {
        commonWidgets.showToast('Choose Pickup and DropPoints'.tr());
      } else {
        String? bookingId = await userService.userSharedCargoCreateBooking(
          context,
          name: '',
          unitType: widget.selectedType,
          shipmentType: selectedShipmentType.toString(),
          shippingCondition: selectedShipmentCondition.toString(),
          cargoLength: lengthController.text,
          cargoBreadth: breadthController.text,
          cargoHeight: heightController.text,
          cargoUnit: selectedUnit,
          date: formattedDate,
          time: formattedTime,
          productValue: productController.text,
          shipmentWeight: weightController.text,
          pickup: pickUpController.text,
          dropPoints: dropPlaces,
          token: widget.token,
        );

        setState(() {
          if (bookingId != null) {
            CommonWidgets()
                .showBookingDialog(context: context, bookingId: bookingId);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseVendor(
                    bookingId: bookingId,
                    size: '',
                    unitType: widget.selectedType,
                    unitTypeName: '',
                    load: '',
                    unit: '',
                    pickup: pickUpController.text,
                    dropPoints: dropPlaces,
                    token: widget.token,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    selectedType: widget.selectedType,
                    cityName: cityNameController.text,
                    address: addressController.text,
                    zipCode: zipCodeController.text,
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
  }

  void onCreateBookingPressed() {
    createBooking();
  }

  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId == null && widget.id != null && widget.token != null) {
      bookingId =
          await userService.getPaymentPendingBooking(widget.id, widget.token);

      if (bookingId == null || bookingId.isEmpty) {
        bookingId =
            await userService.getBookingByUserId(widget.id, widget.token);
      }

      if (bookingId == null || bookingId.isEmpty) {
        return null;
      }
    }

    if (bookingId != null && widget.token != null) {
      final bookingDetails =
          await userService.fetchBookingDetails(bookingId, widget.token);

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
    _loadTypesFuture =
        widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
  }

  @override
  void didUpdateWidget(covariant LoadTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedName != oldWidget.selectedName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _loadTypesFuture =
              widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return FutureBuilder<List<LoadType>>(
      future: _loadTypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<LoadType> loadItems = snapshot.data ?? [];
          return Container(
            padding: EdgeInsets.symmetric(
                vertical: viewUtil.isTablet ? 17 : 14, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              height: 30,
              child: PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                onSelected: (String newValue) {
                  widget.onLoadChanged(newValue);
                },
                elevation: 5,
                color: Colors.white,
                constraints: BoxConstraints.tightFor(
                    width: viewUtil.isTablet
                        ? MediaQuery.sizeOf(context).width * 0.92
                        : 350),
                // offset: const Offset(0, -280),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (widget.selectedLoad?.isNotEmpty ?? false)
                          ? widget.selectedLoad!
                          : 'loadType'.tr(),
                      style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                    ),
                    Icon(Icons.arrow_drop_down,
                        size: viewUtil.isTablet ? 30 : 26),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  if (loadItems.isEmpty) {
                    return [
                      PopupMenuItem<String>(
                        value: null,
                        enabled: false,
                        child: Text(
                          'No Load Type Available',
                          style: TextStyle(
                              fontSize: viewUtil.isTablet ? 20 : 16,
                              color: Colors.black),
                        ),
                      ),
                    ];
                  }
                  return loadItems.map((LoadType load) {
                    return PopupMenuItem<String>(
                      value: load.load.tr(),
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Row(
                          children: [
                            Text(load.load.tr(),
                                style: TextStyle(
                                    fontSize: viewUtil.isTablet ? 20 : 16)),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          );
        } else {
          return Center(child: Text('No loads available'));
        }
      },
    );
  }
}
