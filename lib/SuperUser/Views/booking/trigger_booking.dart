import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TriggerBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const TriggerBooking(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.token,
      required this.id,
      required this.email});

  @override
  State<TriggerBooking> createState() => _TriggerBookingState();
}

class _TriggerBookingState extends State<TriggerBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  String? selectedVendor;
  bool showCheckbox = false;
  bool isChecked = false;
  bool isLoading = false;
  bool isDeleting = false;
  List<bool> isCheckedList = List.generate(3, (index) => false);
  bool allSelected = false;
  List<dynamic> notPaidBookings = [];
  String bookingId = '';
  String unitType = '';
  String unitClassification = '';
  String subClassification = '';
  String vendorName = '';
  String? partnerId = '';
  bool isOtherCardTapped = false;
  bool isMADATapped = false;
  bool isPayAdvance = false;
  String? selectedPartnerName;
  String? selectedOldQuotePrice;
  int? selectedQuotePrice;
  Map<String, String?> selectedVendors = {};
  Map<String, int?> selectedQuotePrices = {};
  int _selectedIndex = 4;
  String? checkOutId;
  String? integrityId;
  int? resultCode;

  @override
  void initState() {
    super.initState();
    fetchBookingsData();
    fetchVendors();
  }


  Future initiatePayment(String paymentBrand,int amount) async {
    setState(() {
      loadingDialog(true);
    });
    final result = await superUserServices.choosePayment(
      context,
      userId: widget.id,
      paymentBrand: paymentBrand,
      amount: amount,
    );
      print('paymentBrand$paymentBrand');
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

// resultCode=000.100.110
  Future<void> getPaymentStatus(String checkOutId,bool isMadaTapped) async {
    final result = await superUserServices.getPaymentDetails(context, checkOutId, isMadaTapped);
    print('Processed');
    if (result != null) {
      setState(() {
        resultCode = int.tryParse(result['code'] ?? '');
        print(resultCode);
        showPaymentSuccessDialog();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve payment status.')),
      );
    }
  }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });
    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);
    setState(() {
      notPaidBookings = bookingData['notPaidBookings']??[];
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<List<Map<String, dynamic>>?> fetchVendors() {
    return userService.userVehicleVendor(
      context,
      bookingId: bookingId,
      unitType: unitType,
      unitClassification: unitClassification,
      subClassification: subClassification,
    );
  }

  void showConfirmationDialog(Map<String, dynamic> booking) {
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
                        style: TextStyle(fontSize: viewUtil.isTablet ? 24 :19),
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
                    child: Text('yes'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 :15)),
                    onPressed: () {
                      if (!isDeleting) {
                        setState(() {
                          isDeleting = true;
                        });
                        handleDeleteBooking(booking['_id']);
                      }
                    },
                  ),
                  TextButton(
                    child: Text('no'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 :15)),
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

  Future<void> handleDeleteBooking(String bookingIds) async {
    try {
      await userService.deleteBooking(context, bookingIds, widget.token);
      isDeleting = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TriggerBooking(
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

  Future<Map<String, String>> fetchPartnerDetailsForBooking(
      String partnerId, String token) async {
    try {
      final partnerData =
          await superUserServices.getPartnerDetails([partnerId], token);
      print('Received partnerData for $partnerId: $partnerData');

      if (partnerData is Map && partnerData.containsKey(partnerId)) {
        final details = partnerData[partnerId];

        return {
          'partnerName': details?['partnerName'] ?? 'N/A',
          'mobileNo': details?['mobileNo'] ?? 'N/A',
        };
      } else {
        print('Unexpected data format for partner details: $partnerData');
        return {
          'partnerName': 'N/A',
          'mobileNo': 'N/A',
        };
      }
    } catch (e) {
      print('Error fetching partner details for $partnerId: $e');
      return {
        'partnerName': 'N/A',
        'mobileNo': 'N/A',
      };
    }
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
          showLeading: false,
          showLanguage: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              toolbarHeight: 80,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Text(
                'Trigger Booking'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuperUserHomePage(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          email: widget.email),
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await fetchVendors();
                  setState(() {});
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: showCheckbox,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.035,
                              width: MediaQuery.of(context).size.width * 0.29,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff6269FE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    allSelected = !allSelected;
                                    for (int i = 0;
                                        i < notPaidBookings.length;
                                        i++) {
                                      notPaidBookings[i]['isSelected'] =
                                          allSelected;
                                    }
                                  });
                                },
                                child: Text(
                                  allSelected ? 'Deselect All'.tr() : 'Select All'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: viewUtil.isTablet ? 20 :14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      notPaidBookings.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.35),
                              child: Center(
                                child: Text(
                                  'No Bookings Found'.tr(),
                                  style: TextStyle(
                                      fontSize:  viewUtil.isTablet ? 20 :18),
                                ),
                              ),
                            )
                          : Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: notPaidBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = notPaidBookings[index];
                                  bookingId = booking['_id'];
                                  unitType = booking['unitType'];
                                  unitClassification = booking['name'];
                                  subClassification = booking['type']?.isNotEmpty ?? ''
                                          ? booking['type'][0]['typeName'] ?? 'N/A'.tr()
                                          : 'N/A';
                                  print(bookingId);
                                  print(unitType);
                                  print(unitClassification);
                                  print(subClassification);
                                  return GestureDetector(
                                    onLongPress: () {
                                      setState(() {
                                        showCheckbox = true;
                                      });
                                    },
                                    onTap: () {
                                      if (showCheckbox) {
                                        setState(() {
                                          showCheckbox = false;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                      child: Stack(
                                        children: [
                                          Padding(padding: const EdgeInsets.fromLTRB(25, 15, 25, 5),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              color: Colors.white,
                                              elevation: 5,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      '${booking['unitType']}'.tr(),
                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                                    ),
                                                  ),
                                                  Padding(padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      '${'Booking id'.tr()}: $bookingId',
                                                      style: TextStyle(color: Color(0xff914F9D), fontSize: viewUtil.isTablet ?22:14),
                                                    ),
                                                  ),
                                                  FutureBuilder<List<Map<String, dynamic>>?>(
                                                    future: fetchVendors(),
                                                    builder: (context, snapshot) {
                                                      /*if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return Center(
                                                          child: Padding(padding: const EdgeInsets.all(12),
                                                            child: Container(
                                                              height: 20,
                                                              width: 20,
                                                              child: CircularProgressIndicator(strokeWidth: 3),
                                                            ),
                                                          ),
                                                        );
                                                      }*/if (snapshot.hasError) {
                                                        return Center(child: Text('Error: ${snapshot.error}'));
                                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                                        return Center(
                                                          child: Padding(padding: const EdgeInsets.only(top: 22, bottom: 22),
                                                            child: Text ('No vendors available'.tr(),
                                                              style: TextStyle(fontSize: viewUtil.isTablet ?22:14),),
                                                          ),
                                                        );
                                                      }

                                                      final vendors = snapshot.data!;
                                                      return ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: vendors.length,
                                                        itemBuilder: (context, index) {
                                                          final vendor = vendors[index];
                                                          final partnerId = vendor['partnerId']?.toString() ?? 'No partnerId';
                                                          final quotePrice = vendor['quotePrice']?.toString() ?? '0';

                                                          return Padding(
                                                            padding: const EdgeInsets.only(left: 20),
                                                            child: RadioListTile(
                                                              dense: true,
                                                              fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState>states) {
                                                                  return states.contains(MaterialState.selected)
                                                                      ? Color(0xff6269FE)
                                                                      : Color(0xff707070);
                                                                },
                                                              ),
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      vendor['partnerName'] ?? 'N/A',
                                                                      style: TextStyle(
                                                                        fontSize: viewUtil.isTablet ?22:17,
                                                                        fontWeight: FontWeight.normal,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      '${vendor['quotePrice'] ?? 'N/A'} SAR',
                                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:17,
                                                                        fontWeight: FontWeight.normal,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              value: partnerId,
                                                              groupValue: selectedVendors[booking['_id'] ?? ''],
                                                              onChanged: (String? value) {
                                                                if (value != null) {
                                                                  _onRadioButtonSelected(booking['_id'] ?? "", value);
                                                                }
                                                                setState(() {
                                                                  selectedQuotePrices[booking['_id']] = int.tryParse(quotePrice);
                                                                });
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: SizedBox(
                                                      height: MediaQuery.of(context).size.height * 0.054,
                                                      width: MediaQuery.of(context).size.width * 0.4,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color(0xff6269FE),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),
                                                          ),
                                                        ),
                                                        onPressed: selectedVendors[booking['_id'] ?? ""] != null
                                                            ? () {
                                                                openPayOrAdvanceDialog(selectedVendors[booking['_id'] ?? ""] ?? "",
                                                                  widget.token,
                                                                  booking,
                                                                );
                                                              }
                                                            : null,
                                                        child: Text(
                                                          'PayNow'.tr(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: viewUtil.isTablet ?22:17,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20,bottom: 20),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showConfirmationDialog(booking);
                                                      },
                                                      child: Text(
                                                        'Cancel'.tr(),
                                                        style: TextStyle(color: Colors.red, fontSize: viewUtil.isTablet ?22:17),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 30,
                                            left: 40,
                                            child: showCheckbox
                                                ? Checkbox(value: notPaidBookings[index]['isSelected'] as bool? ?? false, // Access the boolean field
                                                    onChanged: (value) {
                                                      setState(() {
                                                        notPaidBookings[index]['isSelected'] = value;
                                                      });
                                                    },
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor: Color(0xff572727),
                                                    minRadius: 6,
                                                    maxRadius: double.maxFinite,
                                                  ),
                                          ),
                                          Positioned(
                                            top: 60,
                                            left: 20,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: List.generate(7, (index) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                  child: CircleAvatar(
                                                    backgroundColor: Color(0xffD4D4D4),
                                                    radius: 9,
                                                  ),
                                                );
                                              }),
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
                  ),
                ),
              ),
        bottomNavigationBar: Visibility(
          visible: showCheckbox,
          replacement: commonWidgets.buildBottomNavigationBar(
            context: context,
            selectedIndex: _selectedIndex,
            onTabTapped: _onTabTapped,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff6269FE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {},
            child: Container(
              color: Color(0xff6269FE),
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Confirm Booking'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  void _onRadioButtonSelected(String bookingId, String partnerId) {
    setState(() {
      selectedVendors[bookingId] = partnerId;
    });
  }

  Future<void> openPayOrAdvanceDialog(String partnerId, String token, Map<String, dynamic> booking) async {Map<String, String> partnerDetails =
        await fetchPartnerDetailsForBooking(partnerId, token);
    String partnerName = partnerDetails['partnerName'] ?? 'N/A';
    String mobileNo = partnerDetails['mobileNo'] ?? 'N/A';
    showPayOrPayAdvanceDialog(booking, partnerName: partnerName, mobileNo: mobileNo);
  }

  void showPayOrPayAdvanceDialog(Map<String, dynamic> booking, {String? partnerName, String? mobileNo}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ViewUtil viewUtil = ViewUtil(context);
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(0),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${booking['unitType']}'.tr(),
                                style: TextStyle(fontSize: viewUtil.isTablet ?24 : 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${'Booking id'.tr()}: ${booking['_id']}',
                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 14),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                              child: Card(
                                elevation: 5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(
                                    color: Color(0xffE0E0E0),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                                'Name'.tr(),
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                partnerName ?? '',
                                                style: TextStyle(
                                                    fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(thickness: 0.4),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Mobile No'.tr(),
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                mobileNo ?? '',
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(thickness: 0.4),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'UnitType'.tr(),
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${booking['unitType'] ?? 'N/A'}'.tr(),
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(thickness: 0.4),
                                      booking['pickup'] == null && booking['dropPoints'] == null
                                      ? Column(
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
                                                    'City'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${booking['cityName'] ?? 'N/A'}',
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                      : Column(
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
                                                    'From'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    '${booking['pickup'] ?? 'N/A'}',
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(thickness: 0.4),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'To'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    (booking['dropPoints'] as List).join(', '),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(thickness: 0.4),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Additional Labour'.tr(),
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${booking['additionalLabour'] ?? 'N/A'}',
                                                style: TextStyle(fontSize: viewUtil.isTablet ?22 : 16),
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
                            SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.056,
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff6269FE),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  showSelectPaymentDialog(selectedQuotePrices[booking['_id']]! ~/ 2);
                                },
                                child: Text(
                                  '${'Pay Advance :'.tr()} ${selectedQuotePrices[booking['_id']]! ~/ 2} SAR',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: viewUtil.isTablet ?22 : 17,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.056,
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff6269FE),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  showSelectPaymentDialog(selectedQuotePrices[booking['_id']]??0);
                                },
                                child: Text(
                                  '${'Pay :'.tr()} ${selectedQuotePrices[booking['_id']] ?? 0} SAR',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: viewUtil.isTablet ?22 : 17,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30)
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.cancel, color: Colors.grey,size: 30,)
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void loadingDialog(bool isProcessing){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Visibility(
          visible: isProcessing,
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 90),
              backgroundColor: Colors.white,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 50),
                      LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.blue,
                        size: 80,
                      ),
                      SizedBox(height: 50)
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

  void showSelectPaymentDialog(int amount) {
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
                          showPaymentDialog(checkOutId??'', integrityId??'', true);
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
                          showPaymentDialog(checkOutId??'', integrityId??'', false);
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

  void showPaymentDialog(String checkOutId, String integrity, bool isMADATapped) {
    if (checkOutId.isEmpty || integrity.isEmpty) {
      print('Error: checkOutId or integrity is empty');
      return;
    }

    final String visaHtml = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
          }
          .paymentWidgets {
            width: 50%;
            max-width: 100px;
            box-sizing: border-box;
          }
        </style>
        <script>
          function loadPaymentScript(checkoutId, integrity) {
            const script = document.createElement('script');
            script.src = "https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId=" + checkoutId;
            script.crossOrigin = 'anonymous';
            script.integrity = integrity;

            script.onload = () => {
              console.log('Payment widget script loaded');
              const paymentForm = document.querySelector('.paymentWidgets');
              if (paymentForm) {
                paymentForm.addEventListener('submit', (event) => {
                  event.preventDefault();
                  console.log('Payment form submitted');
                  if (window.flutter_inappwebview) {
                    console.log('Calling Flutter handler...');
                    window.flutter_inappwebview.callHandler('payButtonClicked', checkoutId);
                  } else {
                    console.log('Flutter handler not available');
                  }
                });
              } else {
                console.log('Payment form not found');
              }
            };
            document.body.appendChild(script);
          }
          document.addEventListener("DOMContentLoaded", function() {
            loadPaymentScript("${checkOutId}", "${integrity}");
          });
        </script>
      </head>
      <body>
        <form action="https://prod.naqlee.com:443/api/payment-status/$checkOutId" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
      </body>
    </html>
  ''';

    final String madaHtml = visaHtml.replaceAll("VISA MASTER AMEX", "MADA");

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
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              child: WebView(
                backgroundColor: Colors.transparent,
                initialUrl: Uri.dataFromString(
                    isMADATapped ? madaHtml : visaHtml,
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8'))
                    .toString(),
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: {
                  JavascriptChannel(
                    name: 'payButtonClicked',
                    onMessageReceived: (JavascriptMessage message) async {
                      await getPaymentStatus(checkOutId,isMADATapped);
                    },
                  ),
                },
                onWebViewCreated: (WebViewController webViewController) {
                  webViewController.clearCache();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Payment Status',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5),
                    resultCode != "000.100.110"
                    ? Column(
                      children: [
                        Center(
                          child:  LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.blue,
                            size: 60,
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Please wait!!\nYour payment is in process..Do not close the page',textAlign: TextAlign.center,style: TextStyle(fontSize: 17)),
                        ),
                      ],
                    )
                   : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            color: Color(0xffE6FFE5),
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Text('Payment Successful!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.green)),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'You wil be redirected to dashboard by clicking this..',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15)),
                        ),
                        SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.057,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.green,
                                    size: 200,
                                  );
                                },
                                child: Text(
                                  'Go to Dashboard',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 23),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
