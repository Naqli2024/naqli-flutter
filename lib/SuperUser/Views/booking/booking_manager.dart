import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/edit_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:webview_flutter/webview_flutter.dart';

class BookingManager extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const BookingManager({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<BookingManager> createState() => _BookingManagerState();
}

class _BookingManagerState extends State<BookingManager> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  final TextEditingController pickUpPointController = TextEditingController();
  final TextEditingController dropPointController = TextEditingController();
  int _selectedIndex = 1;
  String selectedMode= 'Tralia';
  String _currentFilter = 'Hold';
  String partnerId = '';
  String partnerName = '';
  String unit = '';
  String unitType = '';
  String bookingStatus = '';
  String bookingDate = '';
  bool isLoading = false;
  int selectedUnit = 1;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isChecked = false;
  bool isDeleting = false;
  int selectedLabour = 0;
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  List<Map<String, dynamic>> bookings = [];
  String partnerData = '';
  Map<String, String> partnerNames = {};
  bool allSelected = false;
  List<Map<String, dynamic>> _filteredBookings = [];
  List<Map<String, dynamic>> allBookings = [];
  bool _noBookingsFound = false;
  ScrollController _scrollController = ScrollController();
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
    fetchBookingsAndPartnerNames(widget.id,widget.token);
    _filteredBookings = List.from(bookings);
  }

  Future<void> fetchBookingsAndPartnerNames(String userId, String token) async {
    try {
      final bookingsData = await superUserServices.getBookingsCount(userId, token);
      final bookings = bookingsData['bookings'] as List<Map<String, dynamic>>? ?? [];
      final partnerIds = bookings.map((booking) => booking['partner']).whereType<String>().toSet().toList();

      Map<String, String> partnerIdToNameMap = {};
      if (partnerIds.isNotEmpty) {
        partnerIdToNameMap = await superUserServices.getPartnerNames(partnerIds, token);
      }
      List<Map<String, dynamic>> updatedBookings = bookings.map((booking) {
        String partnerId = booking['partner'] ?? '';
        String partnerName = partnerIdToNameMap[partnerId] ?? 'N/A';
        booking['partnerName'] = partnerName;

        return booking;
      }).toList();
      setState(() {
        this.bookings = updatedBookings;
        this.isLoading = false;
      });
    } catch (e) {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });

    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);

    setState(() {
      bookings = (bookingData['bookings'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
        _filteredBookings = bookings;
        isLoading = false;
    });
  }

  Future<void> _fetchAndSetBookingDetails() async {
    await fetchBookingsData();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookings));
      _filteredBookings  = _filterBookings(bookings);
    });
    isLoading = false;
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }  else if (_currentFilter == 'Hold') {
      return bookings.where((booking) => booking['paymentStatus'] == 'NotPaid' || booking['bookingStatus'] == 'Yet to start').toList();
    } else if (_currentFilter == 'Running') {
      return bookings.where((booking) => booking['bookingStatus'] == 'Running').toList();
    } else if(_currentFilter == 'Pending for Payment') {
      return bookings.where((booking) => booking['tripStatus'] == 'Completed' && booking['remainingBalance'] != 0).toList();
    } else if(_currentFilter == 'Completed') {
      return bookings.where((booking) => (booking['paymentStatus'] == 'Paid' || booking['paymentStatus'] == 'Completed') && booking['bookingStatus'] == 'Completed').toList();
    }
    return bookings;
  }

  void _updateFilter(String filter) {
    setState(() {
      isLoading = true;
      _currentFilter = filter;
    _fetchAndSetBookingDetails();
    _filteredBookings = _filterBookings(bookings);
    _applyDateFilter('All');
      fetchBookingsAndPartnerNames(widget.id,widget.token);
    });
  }

  void _applyDateFilter(String dateFilter) {
    final DateTime now = DateTime.now();

    List<Map<String, dynamic>> filteredBookings = _filterBookings(bookings);

    DateTime startDate;
    DateTime endDate;

    switch (dateFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
        break;

      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday));
        endDate = startDate.add(Duration(days: 6)).add(Duration(hours: 23, minutes: 59, seconds: 59));
        break;

      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1).subtract(Duration(seconds: 1));
        break;

      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1).subtract(Duration(seconds: 1));
        break;

      case 'All':
      default:
        setState(() {
          _filteredBookings = List.from(filteredBookings);
          _noBookingsFound = _filteredBookings.isEmpty;
          isLoading = false;
        });
        return;
    }

    filteredBookings = filteredBookings.where((booking) {
      try {
        DateTime bookingDate = DateTime.parse(booking['createdAt']).toLocal();
        DateTime onlyDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

        return (onlyDate.isAfter(startDate) || onlyDate.isAtSameMomentAs(startDate)) &&
            (onlyDate.isBefore(endDate) || onlyDate.isAtSameMomentAs(endDate));
      } catch (e) {
        return false;
      }
    }).toList();

    setState(() {
      _filteredBookings = filteredBookings;
      _noBookingsFound = _filteredBookings.isEmpty;
      isLoading = false;
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
              preferredSize: const Size.fromHeight(160.0),
              child: Column(
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    toolbarHeight: 80,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xff807BE5),
                    title: Text(
                          'Booking Manager'.tr(),
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
                  Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Padding(
                padding: EdgeInsets.fromLTRB(8, 20, 8, 10),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                  width: MediaQuery.of(context).size.width * 0.17,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allSelected ? Color(0xff6269FE) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Color(0xffBCBCBC)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (allSelected) {
                          _updateFilter('Hold');
                          _currentFilter = 'Hold';
                        } else {
                          _updateFilter('All');
                          _currentFilter = 'All';
                        }

                        allSelected = !allSelected;
                        fetchBookingsAndPartnerNames(widget.id, widget.token);
                      });
                    },
                    child: Text(
                      'All'.tr(),
                      style: TextStyle(
                        color: allSelected ? Colors.white : Colors.black,
                        fontSize: viewUtil.isTablet ?20:14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
                   Padding(
                padding: EdgeInsets.fromLTRB(8, 20, 10, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      offset: const Offset(0, 45),
                      constraints: const BoxConstraints(
                        minWidth: 150,
                        maxWidth: 150,
                      ),
                      icon: Icon(Icons.filter_alt_rounded),
                      onSelected: (value) {
                        setState(() {
                          _applyDateFilter(value);
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'All',
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Text('All'.tr()),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'Today',
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Text('Today'.tr()),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'This Week',
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Text('This Week'.tr()),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'This Month',
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Text('This Month'.tr()),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuDivider(height: 1),
                          PopupMenuItem(
                            value: 'This Year',
                            child: Directionality(
                              textDirection: ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Text('This Year'.tr()),
                                ],
                              ),
                            ),
                          ),
                        ];
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
              onRefresh: ()async{
                await _fetchAndSetBookingDetails();
              },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: !allSelected,
                  replacement: Container(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
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
                                _updateFilter('Hold');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _currentFilter == 'Hold' ? Color(0xff6269FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    'Hold'.tr(),
                                    style: TextStyle(
                                      color: _currentFilter == 'Hold' ? Colors.white : Colors.black,
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
                                _updateFilter('Running');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _currentFilter == 'Running' ? Color(0xff6269FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    'Running'.tr(),
                                    style: TextStyle(
                                      color: _currentFilter == 'Running' ? Colors.white : Colors.black,
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
                                _updateFilter('Pending for Payment');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _currentFilter == 'Pending for Payment' ? Color(0xff6269FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    'PendingForPayment'.tr(),textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _currentFilter == 'Pending for Payment' ? Colors.white : Colors.black,
                                      fontSize: viewUtil.isTablet ?22:14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async{
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
                        ],
                      ),
                    ),
                  ),
                ),
                isLoading
                    ? Expanded(child: Center(child: CircularProgressIndicator(),))
                    : bookings.isNotEmpty
                      ? Flexible(
                        child: Column(
                        children: [
                          if (_noBookingsFound)
                          Expanded(child: Center(child: Text('No Bookings Found'.tr(),style: TextStyle(fontSize:  viewUtil.isTablet ?22:16)))),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredBookings.length,
                              itemBuilder: (context, index) {
                                final booking = _filteredBookings[index];
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
                                      final partnerName = snapshot.data ?? 'N/A';
                                      String paymentStatus = booking['paymentStatus']??'N/A';
                                      String unitType = booking['unitType']??'N/A';
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 5),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          color: Colors.white,
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff6269FE),
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(16),
                                                          topRight: Radius.circular(16)
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          '${'Booking id'.tr()}: ${booking['_id']}',
                                                          style: TextStyle(fontSize: viewUtil.isTablet ?22:17,color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        top: -1,
                                                        bottom: 5,
                                                        child: Container(
                                                          color: Color(0xff6269FE),
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(30),
                                                            topRight: Radius.circular(30),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 15, top: 15),
                                                          child: Row(
                                                            children: [
                                                              booking['paymentStatus'] == 'HalfPaid'
                                                                  ? SvgPicture.asset('assets/running.svg', height: 45)
                                                                  : booking['paymentStatus'] == 'NotPaid'
                                                                  ? SvgPicture.asset('assets/pending.svg', height: 45)
                                                                  : SvgPicture.asset('assets/completed.svg', height: 45),
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  booking['paymentStatus'] == 'Paid'
                                                                      ? 'Completed'.tr()
                                                                      : paymentStatus.tr(),
                                                                  style: TextStyle(fontSize: viewUtil.isTablet ?22:17),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20,top: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      'Unit'.tr(),
                                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      unitType.tr(),
                                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20,top: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      'Vendor'.tr(),
                                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      isLoading ? 'Loading...'.tr() :partnerName ?? 'Loading...',
                                                                      style: TextStyle(fontSize: viewUtil.isTablet ?22:16),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20,top: 15),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                                          ? 'PaymentStatus'.tr() : booking['remainingBalance'] == 0 ?'':'PendingPayment'.tr(),
                                                                      style: TextStyle(fontSize:  viewUtil.isTablet ?22:16),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      flex: 2,
                                                                      child: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                                          ? Text('Completed'.tr(), style: TextStyle(fontSize:  viewUtil.isTablet ?22:16,color: Colors.green))
                                                                          : booking['remainingBalance'] == 0
                                                                          ? SizedBox(height: 0,)
                                                                          : Text('${booking['remainingBalance']??'N/A'} SAR',
                                                                           style: TextStyle(fontSize:  viewUtil.isTablet ?22:16,color: Colors.red))
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                          ? Container()
                                                          : Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: GestureDetector(
                                                                      onTap: (){
                                                                        showConfirmationDialog(booking);
                                                                      },
                                                                      child: SvgPicture.asset('assets/delete.svg'))
                                                              ),
                                                              Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: GestureDetector(
                                                                      onTap: (){
                                                                        Navigator.of(context).push(
                                                                          MaterialPageRoute(
                                                                            builder: (context) => EditBooking(
                                                                              firstName: widget.firstName,
                                                                              lastName: widget.lastName,
                                                                              token: widget.token,
                                                                              id: widget.id,
                                                                              email: widget.email,
                                                                              unitType: booking['unitType']??'',
                                                                              pickUpPoint: booking['pickup']??'',
                                                                              dropPoint: booking['dropPoints']??[],
                                                                              mode: booking['name']??'',
                                                                              modeClassification: booking['type']?.isNotEmpty ?? '' ? booking['type'][0]['typeName'] ?? 'N/A' : 'N/A'.tr(),
                                                                              date: booking['date']??'',
                                                                              additionalLabour: booking['additionalLabour']??0,
                                                                              bookingId: booking['_id']??'',
                                                                              cityName: booking['cityName']??'',
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: SvgPicture.asset('assets/edit.svg'))
                                                              ),
                                                            ],
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20,bottom: 15),
                                                    child: SizedBox(
                                                      height: MediaQuery.of(context).size.height * 0.045,
                                                      width: MediaQuery.of(context).size.width * 0.65,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(15),
                                                              side: BorderSide(color: Color(0xff6269FE),width: 0.5)
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          showBookingDialog(context,booking,bookingPartnerName: partnerName);
                                                        },
                                                        child: Text(
                                                          'View Booking'.tr(),
                                                          style: TextStyle(
                                                            color: Color(0xff6269FE),
                                                            fontSize: viewUtil.isTablet ?22:17,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
        commonWidgets.showToast("You're already on Booking Manager");
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

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking,{String? bookingPartnerName}) {
    ViewUtil viewUtil = ViewUtil(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String unit = booking['unitType']??'N/A';
        String unitType = booking['name']??'N/A';
        String bookingStatus = booking['bookingStatus']??'N/A';
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                ? Colors.green
                                : booking['paymentStatus'] == 'HalfPaid'
                                  ? Color(0xffFDAF2C)
                                  : Colors.red,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                        ),
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.08,
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            '${'Booking id'.tr()}: ${booking['_id']}',
                            style: TextStyle(fontSize: viewUtil.isTablet ?23:18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Unit'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                  Text(unit.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                ],
                              ),
                            ),
                            Divider(indent: 5, endIndent: 5),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('UnitType'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                  Text(unitType.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                ],
                              ),
                            ),
                            Divider(indent: 5, endIndent: 5),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Vendor'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                  Text('${bookingPartnerName??'N/A'}', style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                ],
                              ),
                            ),
                            Divider(indent: 5, endIndent: 5),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Booking Status'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                  Text(bookingStatus.tr(), style: TextStyle(fontSize: viewUtil.isTablet ?22:16)),
                                ],
                              ),
                            ),
                            booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Completed'.tr(),style: TextStyle(color: Colors.green,fontSize: viewUtil.isTablet ?24:18),),
                            )
                            : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Pending Amount'.tr(),
                                    style: TextStyle(
                                      fontSize: viewUtil.isTablet ?24:17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10,bottom: 20),
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showSelectPaymentDialog(booking['remainingBalance']??'',booking['partner']??'',booking['_id']??'');
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -15,
                  right: -20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      // radius: 15,
                      child: Icon(FontAwesomeIcons.multiply, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: viewUtil.isTablet ? 24 :17),
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
                    child: Text('no'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 :15),),
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
          builder: (context) => BookingManager(
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
          String paymentStatus = message.message;
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
                      MaterialPageRoute(builder: (context) => BookingManager(
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
                      MaterialPageRoute(builder: (context) => BookingManager(
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
