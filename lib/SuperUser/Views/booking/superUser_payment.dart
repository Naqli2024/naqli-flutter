import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SuperUserPayment extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const SuperUserPayment({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<SuperUserPayment> createState() => _SuperUserPaymentState();
}

class _SuperUserPaymentState extends State<SuperUserPayment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  List<Map<String, dynamic>> bookings = [];
  String _currentFilter = 'All';
  bool isLoading = false;
  String partnerId = '';
  String partnerName = '';
  String bookingId = '';
  String unit = '';
  String unitType = '';
  String bookingStatus = '';
  String bookingDate = '';
  String bookingTime = '';
  String fromTime = '';
  String toTime = '';
  int _selectedIndex = 2;
  bool isOtherCardTapped = false;
  bool isMADATapped = false;
  String? checkOutId;
  String? integrityId;
  String? resultCode;
  String? paymentStatus;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    _fetchAndSetBookingDetails();
  }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });

    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);

    setState(() {
      bookings = (bookingData['bookings'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
      isLoading = false;
    });
  }

  Future<void> _fetchAndSetBookingDetails() async {
    await fetchBookingsData();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookings));
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }  else if (_currentFilter == 'Completed') {
      return bookings.where((booking) => booking['paymentStatus'] == 'Paid' || booking['paymentStatus'] == 'Completed').toList();
    } else if (_currentFilter == 'HalfPaid') {
      return bookings.where((booking) => booking['tripStatus'] != 'Completed' && booking['bookingStatus'] == 'Running' && booking['paymentStatus'] == 'HalfPaid' && booking['remainingBalance'] != 0).toList();
    } else if(_currentFilter == 'Pending') {
      return bookings.where((booking) => booking['tripStatus'] == 'Completed' && booking['remainingBalance'] != 0 && booking['bookingStatus'] == 'Running').toList();
    }
    return bookings;
  }

  void _updateFilter(String filter) {
    setState(() {
      isLoading = true;
      _currentFilter = filter;
      _fetchAndSetBookingDetails();
    });
  }

  Future<String> fetchPartnerNameForBooking(String partnerId, String token) async {
    try {
      final partnerNameData = await superUserServices.getPartnerNames([partnerId], token);
      if (partnerNameData is Map && partnerNameData.containsKey(partnerId)) {
        return partnerNameData[partnerId] ?? 'N/A';
      } else {
        return 'N/A';
      }
    } catch (e) {
      return 'N/A';
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
          User: widget.firstName +' '+ widget.lastName,
          userId: widget.id,
          showLeading: false,
          showLanguage: true,
          bottom: PreferredSize(
            preferredSize: viewUtil.isTablet ?Size.fromHeight(180.0): Size.fromHeight(170.0),
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  toolbarHeight: 80,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xff807BE5),
                  title: Text(
                    'Payment'.tr(),
                    style: TextStyle(color: Colors.white),
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
                  actions: [
                    PopupMenuButton<String>(
                      color: Colors.white,
                      offset: const Offset(0, 55),
                      icon: CircleAvatar(
                        backgroundColor: Color(0xffB7B3F1),
                        child: const Icon(
                          Icons.more_vert_outlined,
                          color: Colors.white,
                        ),
                      ),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          height: 30,
                          child: Text('NewBooking'.tr()),
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserType(
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
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      color: Colors.white,
                      border: Border.all(color: Color(0xff707070),width: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    height: MediaQuery.of(context).size.height * 0.063,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateFilter('All');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentFilter == 'All' ? Color(0xff6269FE) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'All'.tr(),
                                  style: TextStyle(
                                    color: _currentFilter == 'All' ? Colors.white : Colors.black,
                                    fontSize: viewUtil.isTablet ?22:16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateFilter('Completed');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentFilter == 'Completed' ? Color(0xff6269FE) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Completed'.tr(),
                                  style: TextStyle(
                                    color: _currentFilter == 'Completed' ? Colors.white : Colors.black,
                                    fontSize: viewUtil.isTablet ?22:16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateFilter('HalfPaid');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentFilter == 'HalfPaid' ? Color(0xff6269FE) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'HalfPaid'.tr(),
                                  style: TextStyle(
                                    color: _currentFilter == 'HalfPaid' ? Colors.white : Colors.black,
                                    fontSize: viewUtil.isTablet ?22:16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _updateFilter('Pending');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentFilter == 'Pending' ? Color(0xff6269FE) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Pending'.tr(),
                                  style: TextStyle(
                                    color: _currentFilter == 'Pending' ? Colors.white : Colors.black,
                                    fontSize: viewUtil.isTablet ?22:16,
                                  ),
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
        body: RefreshIndicator(
          onRefresh: () async{
            await _fetchAndSetBookingDetails();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isLoading
                    ? Expanded(child: Center(child: CircularProgressIndicator(),))
                    : bookings.isNotEmpty
                      ? Flexible(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _bookingDetailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading bookings.'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No Bookings found',style: TextStyle(fontSize:  viewUtil.isTablet ?22:16)));
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final booking = snapshot.data![index];
                              final bookingPartnerName = bookings[index];
                              partnerId = booking['partner']??'N/A';
                              bookingId = booking['_id']??'N/A';
                              unit = booking['unitType']??'N/A';
                              unitType = booking['_id']??'N/A';
                              bookingStatus = booking['bookingStatus']??'N/A';
                              bookingDate = booking['date']??'N/A';
                              bookingTime = booking['time']??'N/A';
                              fromTime = booking['fromTime']??'N/A';
                              toTime = booking['toTime']??'N/A';
                              return FutureBuilder<String>(
                                future: fetchPartnerNameForBooking(booking['partner']??'null', widget.token),
                                builder: (context, snapshot) {
                                  // if (snapshot.connectionState == ConnectionState.waiting) {
                                  //   return Center(child: CircularProgressIndicator());
                                  // }
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error Loading'));
                                  }
                                  if (snapshot.hasData) {
                                    final partnerNames = snapshot.data ?? 'N/A';
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      child: Card(
                                        color: Colors.white,
                                        shadowColor: Colors.black,
                                        elevation: 3.0,
                                        child: ListTile(
                                          title: Text('${'Booking id'.tr()}: ${booking['_id']??'N/A'}'),
                                          subtitle: Row(
                                            children: [
                                              Text('${booking['date']??'N/A'}'),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('${booking['time']??'N/A'}' == 'N/A' ? '${booking['fromTime']??'N/A'}'+'-'+'${booking['toTime']??'N/A'}' :'${booking['time']??'N/A'}'),
                                              )
                                            ],
                                          ),
                                          trailing: Container(
                                            margin: const EdgeInsets.only(bottom: 20),
                                            child: SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              width: MediaQuery.of(context).size.width * 0.2,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xff6A66D1),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showBookingDialog(context,booking,bookingPartnerName: partnerNames);
                                                },
                                                child: Text(
                                                  'View'.tr(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: viewUtil.isTablet ?18:12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              );

                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
                      : Expanded(child: Center(child: Text('No Bookings Found'.tr(),style: TextStyle(fontSize:  viewUtil.isTablet ?22:16))))
            ],
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

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking,{String? bookingPartnerName}) {
    ViewUtil viewUtil = ViewUtil(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String unitType = booking['unitType']??'N/A';
        String paymentStatus = booking['paymentStatus']??'N/A';
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
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
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
                                      'Booking id'.tr(),
                                      style: TextStyle(
                                          fontSize: viewUtil.isTablet ?22:16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${booking['_id']}',
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16,color: Color(0xff79797C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Vendor'.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${bookingPartnerName??'N/A'}',
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16,color: Color(0xff79797C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Vehicle'.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      unitType.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16,color: Color(0xff79797C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Date'.tr(),
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${booking['date'] ??'N/A'}',
                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16,color: Color(0xff79797C)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      child: Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:Border.all(color: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                              ? Colors.greenAccent
                              : booking['paymentStatus'] == 'HalfPaid'
                              ? Color(0xffA89610)
                              : Colors.red,),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(paymentStatus.tr(),style: TextStyle(fontSize: viewUtil.isTablet ?22:19)),
                      ),
                    ),
                    Positioned(
                      top: -40,
                      right: -30,
                      child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                              backgroundColor: Colors.red,
                              minRadius: 20,
                              maxRadius: double.maxFinite,
                              child: Icon(Icons.cancel_outlined, color: Colors.white,size: 30,))),
                    ),
                  ],
                ),
                booking['paymentStatus'] == 'HalfPaid'
                    ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Pending Amount'.tr(),
                            style: TextStyle(
                              fontSize: viewUtil.isTablet ?24:17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8,bottom: 20),
                          child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.054,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff6269FE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            showSelectPaymentDialog(booking['remainingBalance'],booking['partner']??'',booking['_id']??'');
                          },
                          child: Text(
                            '${'Pay :'.tr()} ${booking['remainingBalance']} SAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ?22:17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                    )
                    : Column(
                  children: [
                    Text('Total Paid'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ?24:19)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${booking['paymentAmount']} SAR',style: TextStyle(fontSize: viewUtil.isTablet ?24:19)),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        commonWidgets.showToast("You're already on Payment");
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
        paymentStatus = result['description'] ?? '';
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
    <style>
      body {
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
      .paymentWidgets {
        width: 50%;
        max-width: 100px;
        box-sizing: border-box;
      }
      .paymentWidgets button {
        background-color: #4CAF50;
        color: white;
        border: none;
        padding: 10px 20px;
        font-size: 16px;
        border-radius: 5px;
        cursor: pointer;
      }
      .paymentWidgets button:hover {
        background-color: #45a049;
      }
      #submitButton {
        display: none;
        margin-top: 20px;
        padding: 10px 20px;
        font-size: 16px;
        background-color: #4CAF50;
        color: white;
        border: none;
        cursor: pointer;
        border-radius: 5px;
      }
      #submitButton:active {
        background-color: #45a049;
      }
    </style>

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
        script.onload = () => {
          console.log('Payment widget script loaded'); 
        };
        document.body.appendChild(script);
      }

      document.addEventListener("DOMContentLoaded", function () {
        loadPaymentScript("${checkOutId}", "${integrity}");
      });

      function sendPaymentStatus(status) {
        NavigateToFlutter.postMessage(status);
      }
    </script>
  </head>

  <body>
    <form action="https://naqlee.com/payment/results" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
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
                MaterialPageRoute(builder: (context) => PaymentSuccessScreen(
                  onContinuePressed:() async {
                    await userService.updatePayment(
                      widget.token,
                      amount,
                      'Completed',
                      partnerID,
                      bookingId,
                      amount*2,
                      0,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SuperUserPayment(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        token: widget.token,
                        id: widget.id,
                        email: widget.email,
                      ),),
                    );
                  },)));
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PaymentFailureScreen(
                  paymentStatus: paymentStatus??'',
                  onRetryPressed:() {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SuperUserPayment(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        token: widget.token,
                        id: widget.id,
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
