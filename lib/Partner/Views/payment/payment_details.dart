import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerEditProfile.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerHelp.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/submitTicket.dart';
import 'dart:ui' as ui;

class PaymentDetails extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String email;
  final String quotePrice;
  final String paymentStatus;
  const PaymentDetails(
      {super.key,
      required this.partnerName,
      required this.partnerId,
      required this.token,
      required this.quotePrice,
      required this.paymentStatus,
      required this.email});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> with SingleTickerProviderStateMixin{
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  String _currentFilter = 'All';
  bool isLoading = false;
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  String paymentType = '';
  String bookingType = '';
  String? partnerProfileImage;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _fetchAndSetBookingDetails();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndSetBookingDetails() async {
    final bookingDetails = await fetchBookingDetails();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookingDetails));
    });
    isLoading = false;
  }

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      final bookingIds =
          await _authService.getBookingData(widget.partnerId, widget.token);
      if (bookingIds.isEmpty) {
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final bookingId = booking['bookingId'] as String;
        final paymentStatus = booking['paymentStatus'] as String;
        final profileImage = booking['profileImage'];
        partnerProfileImage = profileImage;
        paymentType = paymentStatus;
        try {
          final details = await _authService.getBookingId(
              bookingId, widget.token, paymentStatus, widget.quotePrice);
          bookingType = details['bookingStatus'];

          if (details.isNotEmpty) {
            details['paymentType'] = paymentType;
            details['bookingType'] = bookingType;
            bookingDetails.add(details);
          } else {}
        } catch (e) {
          commonWidgets.showToast('An error occurred,Please try again.');
        }
      }

      return bookingDetails;
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> _filterBookings(
      List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }
    else if (_currentFilter == 'Completed') {
      return bookings
          .where((booking) =>
              booking['paymentStatus'] == 'Completed' ||
              booking['paymentStatus'] == 'Paid' ||
              booking['bookingStatus'] == 'Completed')
          .toList();
    } else if (_currentFilter == 'Pending') {
      return bookings
          .where((booking) =>
              booking['paymentStatus'] == 'NotPaid' ||
              booking['paymentStatus'] == 'Pending' ||
              booking['paymentStatus'] == 'HalfPaid')
          .toList();
    }
    return bookings;
  }

  void _updateFilter(String filter) {
    isLoading = true;
    setState(() {
      _currentFilter = filter;
      _fetchAndSetBookingDetails();
    });
  }

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    ViewUtil viewUtil = ViewUtil(context);
    String paymentStatus = booking?['paymentStatus'] ?? 'N/A';
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
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                      child: Card(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Color(0xffE0E0E0), // Border color
                            width: 1, // Border width
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
                                          fontSize:
                                              viewUtil.isTablet ? 23 : 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${booking?['_id'] ?? 'No Booking Id'}',
                                      style: TextStyle(
                                          fontSize: viewUtil.isTablet ? 23 : 16,
                                          color: Color(0xff79797C)),
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
                                      'Date'.tr(),
                                      style: TextStyle(
                                          fontSize:
                                              viewUtil.isTablet ? 23 : 16),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${booking?['date'] ?? 'No Date'}',
                                      style: TextStyle(
                                          fontSize: viewUtil.isTablet ? 23 : 16,
                                          color: Color(0xff79797C)),
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
                          border: Border.all(
                            color: booking?['paymentStatus'] == 'Completed'
                                ? Colors.greenAccent
                                : booking?['paymentStatus'] == 'Paid'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                            '${booking?['paymentStatus'] ?? 'N/A'}' ==
                                    'Completed'
                                ? 'Paid'.tr()
                                : '${booking?['paymentStatus'] ?? 'N/A'}'.tr(),
                            style: TextStyle(
                                fontSize: viewUtil.isTablet ? 23 : 19)),
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
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Text(
                    '${booking?['paymentStatus'] ?? ''}' == 'Completed'
                        ? 'Total Paid'.tr()
                        : '${'Total'.tr()} ${paymentStatus.tr()}',
                    style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 19),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${booking?['paymentAmount'] ?? ''} SAR',
                    style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 19),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          userId: widget.partnerId,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(150.0),
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xffA09CEC),
                  title: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 25),
                      child: Text(
                        'Payment'.tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                      size: viewUtil.isTablet ? 27 : 24,
                    ),
                  ),
                ),
                Container(
                  color: const Color(0xff6A66D1),
                  height: 60,
                  width: MediaQuery.sizeOf(context).width,
                  child: TabBar(
                    onTap: (index) {
                      if(index == 0) {
                        _updateFilter('All');
                      } else if(index == 1) {
                        _updateFilter('Completed');
                      } else if(index == 2) {
                        _updateFilter('Pending');
                      }
                    },
                    labelColor: Colors.white,
                    unselectedLabelColor: Color(0xffC2BFF2),
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'All'.tr()),
                      Tab(text: 'Completed'.tr()),
                      Tab(text: 'PendingPayment'.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: commonWidgets.createDrawer(
            context, widget.partnerId, widget.partnerName,
            profileImage: partnerProfileImage, onPaymentPressed: () {
          Navigator.pop(context);
        }, onEditProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PartnerEditProfile(
                      partnerName: widget.partnerName,
                      token: widget.token,
                      partnerId: widget.partnerId,
                      email: widget.email,
                    )),
          );
        }, onBookingPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetails(
                partnerName: widget.partnerName,
                partnerId: widget.partnerId,
                token: widget.token,
                quotePrice: widget.quotePrice,
                paymentStatus: widget.paymentStatus,
                email: widget.email,
              ),
            ),
          );
        }, onReportPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitTicket(
                firstName: widget.partnerName,
                token: widget.token,
                partnerId: widget.partnerId,
                email: widget.email,
              ),
            ),
          );
        }, onHelpPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartnerHelp(
                partnerName: widget.partnerName,
                token: widget.token,
                partnerId: widget.partnerId,
                email: widget.email,
              ),
            ),
          );
        },
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<List<Map<String, dynamic>?>>(
                future: _bookingDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final bookingDetails = snapshot.data!;
                    return ListView.builder(
                      itemCount: bookingDetails.length,
                      itemBuilder: (context, index) {
                        final booking = bookingDetails[index];
                        final id = booking?['_id'] ?? 'Unknown ID';
                        final date = booking?['date'] ?? 'No date available';
                        final time = booking?['time'] ?? 'N/A';
                        final fromTime = booking?['fromTime'] ?? 'N/A';
                        final toTime = booking?['toTime'] ?? 'N/A';
                        return Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Card(
                            color: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 3.0,
                            child: ListTile(
                              title: Text('${'Booking id'.tr()}: $id'),
                              subtitle: Row(
                                children: [
                                  Text('$date'),
                                  time == 'N/A'
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('$fromTime - $toTime'),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('$time'),
                                        )
                                ],
                              ),
                              trailing: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff6A66D1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      showBookingDialog(context, booking!);
                                    },
                                    child: Text(
                                      'View'.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: viewUtil.isTablet ? 18 : 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                        child: Text(
                      _currentFilter == 'All'
                          ? 'No Payment Found'.tr()
                          : _currentFilter == 'Completed'
                              ? '${'no'.tr()} ${'$_currentFilter'.tr()} ${'found'.tr()}'
                              : 'No Pending Payment found'.tr(),
                      style: TextStyle(
                        fontSize: viewUtil.isTablet ? 22 : 16,
                      ),
                    ));
                  }
                },
              ),
      ),
    );
  }
}
