import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart'as permissionHandler;
import 'dart:ui' as ui;

class EditBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  final String bookingId;
  final String unitType;
  final String cityName;
  final String pickUpPoint;
  final List dropPoint;
  final String mode;
  final String modeClassification;
  final String date;
  final int additionalLabour;
  const EditBooking({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email, required this.unitType, required this.pickUpPoint, required this.dropPoint, required this.mode, required this.modeClassification, required this.date, required this.additionalLabour, required this.bookingId, required this.cityName});

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  late TextEditingController pickUpPointController = TextEditingController();
  late List<TextEditingController> _dropPointControllers;
  late TextEditingController modeController = TextEditingController();
  late TextEditingController modeClassificationController = TextEditingController();
  late TextEditingController cityNameController = TextEditingController();
  final String apiKey = dotenv.env['API_KEY'] ?? 'No API Key Found';
  late List<List<String>> _dropPointSuggestions;
  late List<String> _pickUpSuggestions = [];
  late List<String> _cityNameSuggestions = [];
  late List<String> _addressSuggestions = [];
  String selectedMode= 'Tralia';
  bool isLoading = false;
  int selectedUnit = 1;
  late DateTime _selectedStartDate;
  DateTime _selectedEndDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 0;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  LatLng? pickupLatLng;
  LatLng? dropLatLng;
  String currentPlace = '';
  int typeCount = 0;
  bool isLocating = false;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    selectedUnitType();
    pickUpPointController = TextEditingController(text: widget.pickUpPoint);
    cityNameController = TextEditingController(text: widget.cityName);
    modeController = TextEditingController(text: widget.mode.tr());
    modeClassificationController = TextEditingController(text: widget.modeClassification.tr());
    _selectedStartDate = widget.date != null
        ? DateFormat("yyyy-MM-dd").parse(widget.date)
        : DateTime.now();
    if (widget.additionalLabour != null && widget.additionalLabour! > 0) {
      isChecked = true;
      selectedLabour = widget.additionalLabour;
    }
    _dropPointControllers = List.generate(widget.dropPoint.length, (index) {
      return TextEditingController(text: widget.dropPoint[index]);
    });
    _dropPointSuggestions = List.generate(widget.dropPoint.length, (index) => []);
  }

  Widget selectedUnitType(){
    switch (widget.unitType.toLowerCase()) {
      case 'vehicle':
        selectedUnit = 1;
        break;
      case 'bus':
        selectedUnit = 2;
        break;
      case 'equipment':
        selectedUnit = 3;
        break;
      case 'special':
        selectedUnit = 4;
        break;
      case 'others':
        selectedUnit = 5;
        break;
      default:
        selectedUnit = 1;
    }
    return Container();
  }

  Future<void> _fetchSuggestions(String query, int index, bool isPickUp) async {
    if (query.isEmpty) {
      setState(() {
        if (isPickUp) {
          _pickUpSuggestions = [];
        } else {
          if (index < _dropPointSuggestions.length) {
            _dropPointSuggestions[index] = [];
          }
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
          if (isPickUp) {
            _pickUpSuggestions = predictions.map((p) => p['description'] as String).toList();
          } else {
            while (_dropPointSuggestions.length <= index) {
              _dropPointSuggestions.add([]);
            }
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
          pickUpPointController.text = formattedAddress;
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

  void _onSuggestionTap(String suggestion, TextEditingController controller, bool isPickUp) {
    setState(() {
      controller.text = suggestion;

      if (isPickUp) {
        _pickUpSuggestions.clear();
      } else {
        final index = _dropPointControllers.indexOf(controller);
        if (index != -1) {
          _dropPointSuggestions[index].clear();
        }
      }
    });
  }

  void _onAddressSuggestionTap(String suggestion, TextEditingController controller, String type) {
    setState(() {
      controller.text = suggestion;
      if (type == 'city') {
        _cityNameSuggestions = [];
      } else if (type == 'address') {
        _addressSuggestions = [];
      }
    });
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
          showLeading: false,
          showLanguage: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              toolbarHeight: MediaQuery.of(context).size.height * 0.09,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff807BE5),
              title: Text(
                'Edit Booking'.tr(),
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () {
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
                },
                icon: CircleAvatar(
                  backgroundColor: Color(0xffB7B3F1),
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: (){
            setState(() {
              _dismissSuggestions();
            });
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildUnitRadioList(setState),
                widget.pickUpPoint.isEmpty && widget.dropPoint.isEmpty
                ? Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20,20,0,5,),
                        child: Text('City'.tr()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right:20,bottom: 5),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: cityNameController,
                        onChanged: (value) => _fetchSuggestions(value, -1, true),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xff009E10)),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xffBCBCBC)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                  ],
                )
                : Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20,20,0,5,),
                        child: Text('Pickup Point'.tr()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right:20,bottom: 5),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: pickUpPointController,
                        onChanged: (value) => _fetchSuggestions(value, -1, true),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xff009E10)),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xffBCBCBC)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (_pickUpSuggestions.isNotEmpty && pickUpPointController.text.isNotEmpty)
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
                                onTap: () => _onSuggestionTap(_pickUpSuggestions[index - 1], pickUpPointController, true),
                              );
                            }
                          },
                        ),
                      ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                        child: Text('Drop Point'.tr()),
                      ),
                    ),
                    ..._dropPointControllers.asMap().entries.map((entry) {
                      int i = entry.key;
                      TextEditingController controller = entry.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (value) => _fetchSuggestions(value, i, false),
                              controller: controller,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xffBCBCBC)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: '${'Drop Point'.tr()} ${i + 1}',
                                hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                prefixIcon: Icon(Icons.circle, size: 15, color: Color(0xffE20808)),
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
                          _buildSuggestionList(i, controller),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                    child: Text('Mode'.tr()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20,right:20,bottom: 5),
                  child: TextFormField(
                    readOnly: true,
                    controller: modeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffBCBCBC)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                    child: Text('Mode Classification'.tr()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20,right:20,bottom: 5),
                  child: TextFormField(
                    readOnly: true,
                    controller: modeClassificationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffBCBCBC)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 5,top: 20),
                    child: Text('Date'.tr()),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    selectStartDate(context, setState);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffBCBCBC)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => selectStartDate(context, setState),
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
                            selectStartDate(context, setState);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                DateFormat('yyyy-MM-dd').format(_selectedStartDate),
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor: const Color(0xff6A66D1),
                        side: BorderSide(color: Colors.grey),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'needAdditionalLabour'.tr(),
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isChecked)
                  Column(
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
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.055,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6269FE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        String updatedDate = DateFormat('yyyy-MM-dd').format(_selectedStartDate);
                        String updatedPickup = pickUpPointController.text;
                        List<String> updatedDropPoints = _dropPointControllers.map((controller) => controller.text).toList();
                        await superUserServices.updateBooking(
                          widget.token,
                          widget.bookingId,
                          updatedDate,
                          updatedPickup,
                          updatedDropPoints,
                          selectedLabour,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingManager(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              token: widget.token,
                              id: widget.id,
                              email: widget.email,
                            ),
                          ),
                        );
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text(
                        'Save'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: commonWidgets.buildBottomNavigationBar(
          context: context,
          selectedIndex: _selectedIndex,
          onTabTapped: _onTabTapped,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  email: widget.email,
                )));
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingManager(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuperUserPayment(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
          ),
        );
        break;
    }
  }

  Widget _buildSuggestionList(int i, TextEditingController controller) {
    if (i < _dropPointSuggestions.length &&
        _dropPointSuggestions[i].isNotEmpty &&
        controller.text.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(8),
        height: 200,
        child: ListView.builder(
          itemCount: _dropPointSuggestions[i].length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_dropPointSuggestions[i][index]),
              onTap: () => _onSuggestionTap(_dropPointSuggestions[i][index], controller, false),
            );
          },
        ),
      );
    }
    return Container();
  }

  Widget buildUnitRadioList(StateSetter setState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: Text('Vehicle'.tr(), style: TextStyle(fontSize: 14,color: Colors.black)),
                  value: 1,
                  groupValue: selectedUnit,
                  onChanged: null,
                ),
              ),
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: Text('Bus'.tr(), style: TextStyle(fontSize: 14,color: Colors.black)),
                  value: 2,
                  groupValue: selectedUnit,
                  onChanged: null,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: Text('Equipment'.tr(),style: TextStyle(fontSize: 14,color: Colors.black)),
                value: 3,
                groupValue: selectedUnit,
                onChanged: null,
              ),
            ),
            Expanded(
              child: RadioListTile(
                dense: true,
                title: Text('Special'.tr(),style: TextStyle(fontSize: 14,color: Colors.black)),
                value: 4,
                groupValue: selectedUnit,
                onChanged: null,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: Text('Others'.tr(),style: TextStyle(fontSize: 14,color: Colors.black)),
                value: 5,
                groupValue: selectedUnit,
                onChanged: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> selectStartDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }
}
