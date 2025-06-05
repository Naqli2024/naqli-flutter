import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class BookingHistory extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  final String email;
  const BookingHistory({super.key, required this.token, required this.firstName, required this.lastName, required this.id, required this.email});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late Future<List<dynamic>> bookingHistory;
  bool isLoading = true;

  @override
  void initState() {
    bookingHistory = fetchHistory();
    super.initState();
  }

  // Future<void> fetchHistory() async {
  //   List<dynamic> history = await userService.fetchPaymentBookingHistory(widget.id, widget.token);
  //   setState(() {
  //     bookingHistory = history;
  //     isLoading = false;
  //   });
  // }

  Future<List<dynamic>> fetchHistory() async {
    try {
      final data = await getSavedUserData();
      final String? id = data['id'];
      final String? token = data['token'];

      if (id != null && token != null) {
        return await userService.fetchPaymentBookingHistory(id, token);
      } else {
        setState(() {
          isLoading = false;
        });
        return [];
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xffFEFEFE),
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
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
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        'booking_history'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?26:24),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                  size: viewUtil.isTablet?27: 24,
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: bookingHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.17),
                      child: SvgPicture.asset('assets/history.svg',
                          height: viewUtil.isTablet
                          ? MediaQuery.sizeOf(context).height * 0.15
                          : MediaQuery.sizeOf(context).height * 0.12),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40, bottom: 20),
                      child: Text(
                        "No history available !!!".tr(),
                        style: TextStyle(fontSize: viewUtil.isTablet ? 27 :25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Let's book some vehicle and make your".tr(),
                      style: TextStyle(fontSize: viewUtil.isTablet ? 22 :20, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      "Booking history heavy".tr(),
                      style: TextStyle(fontSize: viewUtil.isTablet ? 22 :20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              );
            } else {
              final bookingHistory = snapshot.data!;
              return ListView.builder(
                itemCount: bookingHistory.length,
                itemBuilder: (context, index) {
                  final booking = bookingHistory[index];
                  String unitType = booking['unitType'] ?? 'N/A'.tr();
                  String unit = booking['name'] ?? 'N/A'.tr();
                  String paymentStatus = booking['paymentStatus'] ?? 'N/A'.tr();
                  return Padding(
                    padding: viewUtil.isTablet
                        ? EdgeInsets.fromLTRB(20,20,20,20)
                        : EdgeInsets.fromLTRB(8,20,8,20),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            elevation: 5,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 40, 17, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Unit'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          unitType.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 8, 17, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'UnitType'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          unit.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 8, 17, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Date'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          booking['date'] ?? 'N/A'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 8, 17, 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Booking id'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          booking['_id'] ?? 'N/A'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 8, 17, 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'PaymentStatus'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          paymentStatus.tr(),
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
                        Positioned(
                          top: 2,
                          left: MediaQuery.sizeOf(context).width * 0.38,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 2,
                                  blurRadius: 1,
                                  offset: const Offset(
                                      0, -3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/history_truck.svg',
                              height: viewUtil.isTablet ? 80 : 60,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 35,
                          left: 40,
                          child: CircleAvatar(
                              backgroundColor: Color(0xff8B4C97),
                              minRadius: 6,
                              maxRadius: double.maxFinite,
                             ),
                        ),
                        Positioned(
                          top: 60,
                          left: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(8, (index) {
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
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
