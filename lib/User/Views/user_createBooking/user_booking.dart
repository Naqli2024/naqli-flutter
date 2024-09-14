import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_bookingHistory.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_payment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_places_flutter_api/google_places_flutter_api.dart';
class CreateBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String selectedType;
  final String token;
  final String id;
  const CreateBooking(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.selectedType, required this.token, required this.id});

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
  List<String> _suggestions = [];
  Map<int, List<String>> _dropPointSuggestions = {};
  late List<String> _pickUpSuggestions = [];
  late List<String> _cityNameSuggestions = [];
  late List<String> _addressSuggestions = [];
  late List<String> _zipCodeSuggestions = [];
  Future<Map<String, dynamic>?>? booking;

  @override
  void initState() {
    super.initState();
    _futureVehicles = userService.fetchUserVehicle();
    _futureBuses = userService.fetchUserBuses();
    _futureEquipment = userService.fetchUserEquipment();
    _futureSpecial = userService.fetchUserSpecialUnits();
    fetchLoadsForSelectedType(selectedTypeName ?? '');
    booking = _fetchBookingDetails();
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


  Future<void> _requestPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
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

      // Retrieve city name, address, and zip code
      String cityName = cityNameController.text.trim();
      String address = addressController.text.trim();
      String zipCode = zipCodeController.text.trim();

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

  Future<void> _fetchSuggestions(String query, int index, bool isPickUp) async {
    if (query.isEmpty) {
      setState(() {
        // Clear suggestions if the text field is empty
        if (isPickUp) {
          _pickUpSuggestions = [];
        } else {
          _dropPointSuggestions[index] = [];
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
          await userService.fetchUserVehicle(); // Fetch vehicles

      var selectedType = vehicles
          .expand((vehicle) => vehicle.types) // Flatten the list of types
          .firstWhere(
            (type) => type.typeName == selectedTypeName,
            orElse: () => VehicleType(
                typeName: '',
                typeOfLoad: [],
                typeImage: '',
                scale: ''), // Default value
          );

      print('Selected Type: ${selectedType.typeOfLoad}'); // Debugging line

      return selectedType.typeOfLoad; // Return the list of LoadType
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
            alwaysUse24HourFormat: true,
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
            alwaysUse24HourFormat: true,
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
      alwaysUse24HourFormat: true,
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
        commonWidgets.showToast('Choose Pickup and DropPoints');
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
        commonWidgets.showToast(
            'Choose Pickup and DropPoints');
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
        commonWidgets.showToast(
            'Choose City name and Address');
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
        commonWidgets.showToast(
            'Choose City name and Address');
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
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName + widget.lastName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: Container(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  const Text(
                    'Create Booking',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Step $_currentStep of 3 - booking',
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> UserType(
                        firstName: widget.firstName,
                        lastName: widget.lastName, token: widget.token,id: '',)));
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
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset('assets/naqlee-logo.svg',
                      height: MediaQuery.of(context).size.height * 0.05),
                  GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: const CircleAvatar(child: Icon(FontAwesomeIcons.multiply)))
                ],
              ),
            ),
            const Divider(),
            ListTile(
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking',style: TextStyle(fontSize: 25),),
                ),
                onTap: ()async {
                  try {
                    final bookingData = await booking;

                    if (bookingData != null) {
                      bookingData['paymentStatus']== 'Pending'
                          ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseVendor(
                            id: widget.id,
                            bookingId: bookingData['_id'] ?? '',
                            size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : '',
                            unitType: bookingData['unitType'] ?? '',
                            unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                            load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : '',
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
                          : bookingData['paymentStatus']== 'HalfPaid'
                          ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PendingPayment(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: widget.selectedType,
                              token: widget.token,
                              unit: bookingData['name'] ?? '',
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : '',
                              bookingId: bookingData['_id'] ?? '',
                              unitType: bookingData['unitType'] ?? '',
                              pickup: bookingData['pickup'] ?? '',
                              dropPoints: bookingData['dropPoints'] ?? [],
                              cityName: bookingData['cityName'] ?? '',
                              address: bookingData['address'] ?? '',
                              zipCode: bookingData['zipCode'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                              id: widget.id,
                              partnerName: '',
                              partnerId: '',
                              oldQuotePrice: '',
                              paymentStatus: '',
                              quotePrice: '',
                              advanceOrPay: ''
                            )
                        ),
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
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : '',
                              bookingId: bookingData['_id'] ?? '',
                              unitType: bookingData['unitType'] ?? '',
                              pickup: bookingData['pickup'] ?? '',
                              dropPoints: bookingData['dropPoints'] ?? [],
                              cityName: bookingData['cityName'] ?? '',
                              address: bookingData['address'] ?? '',
                              zipCode: bookingData['zipCode'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                              id: widget.id,
                              partnerId: bookingData['partner'] ?? '',
                            )
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewBooking(token: widget.token, firstName: widget.firstName, lastName: widget.lastName, id: widget.id)
                        ),
                      );
                    }
                  } catch (e) {
                    // Handle errors here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching booking details: $e')),
                    );
                  }
                }
            ),
            ListTile(
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking History',style: TextStyle(fontSize: 25),),
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingHistory(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,),
                    ),
                  );
                }
            ),
            ListTile(
                leading: Image.asset('assets/payment_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('Payment',style: TextStyle(fontSize: 25),),
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Payment(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,),
                    ),
                  );
                }
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 20,bottom: 10,top: 15),
              child: Text('More info and support',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Image.asset('assets/report_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Report',style: TextStyle(fontSize: 25),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: Image.asset('assets/help_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Help',style: TextStyle(fontSize: 25),),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseVendor(
                      bookingId: '',
                      size: '',
                      unitType:'',
                      unitTypeName: '',
                      load: '',
                      unit: '',
                      pickup: '',
                      dropPoints: [],
                      token: widget.token,
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      selectedType: '',
                      cityName: '',
                      address: '',
                      zipCode: '',
                      id: widget.id,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.phone,size: 30,color: Color(0xff707070),),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 17),
                child: Text('Contact us',style: TextStyle(fontSize: 25),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.logout,color: Colors.red,size: 30,),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Logout',style: TextStyle(fontSize: 25,color: Colors.red),),
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
                            padding: EdgeInsets.only(top: 30,bottom: 10),
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
                              MaterialPageRoute(builder: (context) => UserLogin()),
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_currentStep == 1) Container(),
                  if (_currentStep > 1)
                    Container(
                      padding: const EdgeInsets.only(left: 40, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_currentStep > 1) {
                              _currentStep--;
                            }
                          });
                        },
                        child: const Text(
                          'Back',
                          style: TextStyle(
                              color: Color(0xff6269FE),
                              fontSize: 21,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  if (_currentStep < 3)
                    Container(
                      padding: const EdgeInsets.only(right: 10, bottom: 15),
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
                          onPressed: () {
                            setState(() {
                              if (widget.selectedType == 'vehicle') {
                                if (_currentStep == 1) {
                                  if (selectedTypeName == null) {
                                    commonWidgets.showToast('Please select an option');
                                  } else {
                                    _currentStep++;
                                  }
                                } else if (_currentStep == 2) {
                                  if (_selectedFromTime == null ||
                                      _selectedDate == null ||
                                      productController.text.isEmpty ||
                                      selectedLoad == null) {
                                    commonWidgets.showToast('Please fill all fields');
                                  } else {
                                    _currentStep++;
                                  }
                                }
                              }
                              if (widget.selectedType == 'bus') {
                                if (_currentStep == 1) {
                                  if (selectedBus == null) {
                                    commonWidgets.showToast('Please select Bus');
                                  } else {
                                    _currentStep++;
                                  }
                                } else if (_currentStep == 2) {
                                  if (_selectedFromTime == null ||
                                      _selectedDate == null ||
                                      productController.text.isEmpty) {
                                    commonWidgets.showToast('Please fill all fields');
                                  } else {
                                    _currentStep++;
                                  }
                                }
                              }
                              if (widget.selectedType == 'equipment') {
                                if (_currentStep == 1) {
                                  if (selectedTypeName ==null) {
                                    commonWidgets.showToast('Please select an option');
                                  } else {
                                    _currentStep++;
                                  }
                                } else if (_currentStep == 2) {
                                  if (_selectedFromTime == null ||
                                      _selectedDate == null) {
                                    commonWidgets.showToast('Please fill all fields');
                                  } else {
                                    _currentStep++;
                                  }
                                }
                              }
                              if (widget.selectedType == 'special' || widget.selectedType == 'others') {
                                if (_currentStep == 1) {
                                  if (selectedSpecial ==null) {
                                    commonWidgets.showToast('Please select Special/Other Units');
                                  } else {
                                    _currentStep++;
                                  }
                                } else if (_currentStep == 2) {
                                  if (_selectedFromTime == null ||
                                      _selectedDate == null) {
                                    commonWidgets.showToast('Please fill all fields');
                                  } else {
                                    _currentStep++;
                                  }
                                }
                              }
                            });
                          },
                          child: const Text(
                            'Next',
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
                      padding: const EdgeInsets.only(right: 10, bottom: 15),
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
                          onPressed: () async {
                            setState(() {
                              createBooking();
                            });
                          },
                          child: const Text(
                            'Create Booking',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                child: const Text(
                  'Available Vehicle Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                              child: Image.asset('assets/delivery-truck.png'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Text(
                                vehicle.name,
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
                                    return vehicle.types?.map((type) {
                                          return PopupMenuItem<String>(
                                            value: type.typeName,
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: FutureBuilder(
                                                      future: _loadSvg(
                                                          type.typeImage),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: Icon(Icons
                                                                .rotate_right),
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return const Icon(
                                                              Icons.error);
                                                        } else {
                                                          return SvgPicture
                                                              .asset(
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(type.typeName,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16.0)),
                                                        Text(type.scale,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14.0)),
                                                      ],
                                                    ),
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
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedType.isEmpty
                                                ? 'Select'
                                                : selectedType.isNotEmpty
                                                    ? selectedType
                                                    : vehicle.types
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? vehicle.types!.first
                                                            .typeName
                                                        : 'No Data ',
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
                child: const Text(
                  'Available Bus Units',
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
                                    FutureBuilder(
                                      future: _loadSvg(bus.image),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 45, bottom: 10),
                                            child: SvgPicture.asset(
                                              bus.image,
                                              width: 30,
                                              height: 40,
                                            ),
                                          );
                                        }
                                      },
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
                child: const Text(
                  'Available Equipments Units',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                              child: Image.asset('assets/delivery-truck.png'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                equipments.name,
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
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: FutureBuilder(
                                                      future: _loadSvg(
                                                          type.typeImage),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(),
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return const Icon(
                                                              Icons.error);
                                                        } else {
                                                          return SvgPicture
                                                              .asset(
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
                                                    child: Text(type.typeName,
                                                        style: const TextStyle(
                                                            fontSize: 16.0)),
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
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedType.isEmpty
                                                ? 'Select'
                                                : selectedType.isNotEmpty
                                                    ? selectedType
                                                    : equipments.types
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? equipments.types!
                                                            .first.typeName
                                                        : 'No Data for Sub Classification',
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
                child: const Text(
                  'Available Special / Others Units',
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
                                    FutureBuilder(
                                      future: _loadSvg(specials.image),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return const Icon(Icons.error);
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 45, bottom: 10),
                                            child: SvgPicture.asset(
                                              specials.image,
                                              width: 30,
                                              height: 40,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    // SvgPicture.asset(bus.image??''),
                                    Divider(
                                      indent: 7,
                                      endIndent: 7,
                                      color: Color(0xffACACAD),
                                      thickness: 1,
                                    ),
                                    Text(
                                      specials.name,
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

  Widget othersContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Others Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // Add more widgets as needed
        ],
      ),
    );
  }

  Widget defaultContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Please select a type to see content',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
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
                  icon: const Icon(FontAwesomeIcons.calendar),
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
                    child: Text('$formattedDate'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Value of product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextFormField(
              controller: productController,
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Load type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: LoadTypeDropdown(
              selectedName: selectedTypeName,
              selectedLoad: selectedLoad,
              onLoadChanged: (newValue) {
                setState(() {
                  selectedLoad = newValue;
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
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Need Additional Labour',
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

  Widget UserBusStepTwo() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
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
                  icon: const Icon(FontAwesomeIcons.calendar),
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
                    child: Text('$formattedDate'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Value of product',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: TextFormField(
              controller: productController,
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Color(0xffCCCCCC)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
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
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Need Additional Labour',
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
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'From Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'To Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedToTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
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
                  icon: const Icon(FontAwesomeIcons.calendar),
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
                    child: Text('$formattedDate'),
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
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Need Additional Labour',
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
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'From Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedFromTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'To Time',
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
                  icon: const Icon(FontAwesomeIcons.clock),
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
                    child: Text('${_formatTimeOfDay(_selectedToTime)}'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            alignment: Alignment.topLeft,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
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
                  icon: const Icon(FontAwesomeIcons.calendar),
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
                    child: Text('$formattedDate'),
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
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Need Additional Labour',
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
    return  SingleChildScrollView(
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
                                onChanged: (value) => _fetchSuggestions(value, -1, true),
                                controller: pickUpController,
                                decoration: InputDecoration(
                                  hintText: 'Pick up',
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
                            itemCount: _pickUpSuggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_pickUpSuggestions[index]),
                                onTap: () => _onSuggestionTap(_pickUpSuggestions[index], pickUpController, true),
                              );
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
                                    height: 40,
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      onChanged: (value) => _fetchSuggestions(value, i, false),
                                      controller: controller,
                                      decoration: InputDecoration(
                                        hintText: 'Drop Point ${i + 1}',
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                        suffixIcon: i == _dropPointControllers.length - 1
                                            ? Row(
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
                            _fetchCoordinates();
                          },
                          child: const Text(
                            'Get Location',
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
    );
  }

  Widget UserBusStepThree() {
    return SingleChildScrollView(
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
                                    onChanged: (value) => _fetchSuggestions(value, -1, true),
                                    controller: pickUpController,
                                    decoration: InputDecoration(
                                      hintText: 'Pick up',
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
                                itemCount: _pickUpSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_pickUpSuggestions[index]),
                                    onTap: () => _onSuggestionTap(_pickUpSuggestions[index], pickUpController, true),
                                  );
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
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          onChanged: (value) => _fetchSuggestions(value, i, false),
                                          controller: controller,
                                          decoration: InputDecoration(
                                            hintText: 'Drop Point ${i + 1}',
                                            hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                            border: InputBorder.none,
                                            suffixIcon: i == _dropPointControllers.length - 1
                                                ? Row(
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
                            _fetchCoordinates();
                          },
                          child: const Text(
                            'Get Location',
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
    );
  }

  Widget UserEquipmentStepThree() {
    return SingleChildScrollView(
      child: Center(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
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
              ),
            ),
            Positioned(
              top: 10,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                    child: SvgPicture.asset('assets/search.svg')),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      controller: cityNameController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'city'),
                                      decoration: InputDecoration(
                                        hintText: 'Enter city name',
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
                                itemCount: _cityNameSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_cityNameSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_cityNameSuggestions[index], cityNameController, 'city'),
                                  );
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                  child: SvgPicture.asset('assets/address.svg')),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  child: TextFormField(
                                    controller: addressController,
                                    onChanged: (value) => _fetchAddressSuggestions(value, 'address'),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your address',
                                      hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                      border: InputBorder.none,
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
                          const Divider(indent: 5, endIndent: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                    child: SvgPicture.asset('assets/zipCode.svg')),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      controller: zipCodeController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'zipCode'),
                                      decoration: InputDecoration(
                                        hintText: 'Zip code for construction site',
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_zipCodeSuggestions.isNotEmpty && zipCodeController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _zipCodeSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_zipCodeSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_zipCodeSuggestions[index], zipCodeController, 'zipCode'),
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
                            _fetchAddressCoordinates();
                          },
                          child: const Text(
                            'Get Location',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget UserSpecialStepThree() {
    return SingleChildScrollView(
      child: Center(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
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
              ),
            ),
            Positioned(
              top: 10,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                    child: SvgPicture.asset('assets/search.svg')),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      controller: cityNameController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'city'),
                                      decoration: InputDecoration(
                                        hintText: 'Enter city name',
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
                                itemCount: _cityNameSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_cityNameSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_cityNameSuggestions[index], cityNameController, 'city'),
                                  );
                                },
                              ),
                            ),
                          const Divider(indent: 5, endIndent: 5),
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                  child: SvgPicture.asset('assets/address.svg')),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  child: TextFormField(
                                    controller: addressController,
                                    onChanged: (value) => _fetchAddressSuggestions(value, 'address'),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your address',
                                      hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                      border: InputBorder.none,
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
                          const Divider(indent: 5, endIndent: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10,10,5,5),
                                    child: SvgPicture.asset('assets/zipCode.svg')),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    child: TextFormField(
                                      controller: zipCodeController,
                                      onChanged: (value) => _fetchAddressSuggestions(value, 'zipCode'),
                                      decoration: InputDecoration(
                                        hintText: 'Zip code for construction site',
                                        hintStyle: const TextStyle(color: Color(0xff707070), fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_zipCodeSuggestions.isNotEmpty && zipCodeController.text.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(8),
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                itemCount: _zipCodeSuggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_zipCodeSuggestions[index]),
                                    onTap: () => _onAddressSuggestionTap(_zipCodeSuggestions[index], zipCodeController, 'zipCode'),
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
                            _fetchAddressCoordinates();
                          },
                          child: const Text(
                            'Get Location',
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
            ),
          ],
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
    _loadTypesFuture =
        widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
  }

  @override
  void didUpdateWidget(covariant LoadTypeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedName != oldWidget.selectedName) {
      setState(() {
        _loadTypesFuture =
            widget.fetchLoadsForSelectedType(widget.selectedName ?? '');
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
                        : 'Load type',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return loadItems.map((LoadType load) {
                  return PopupMenuItem<String>(
                    value: load.load,
                    child: Text(load.load),
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
