import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SuperUserHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const SuperUserHomePage({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<SuperUserHomePage> createState() => _SuperUserHomePageState();
}

class _SuperUserHomePageState extends State<SuperUserHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  int totalBookingsCount = 0;
  int runningBookingsCount = 0;
  int completedBookingsCount = 0;
  int yetToStartBookingsCount = 0;
  int halfPaidPaymentCount = 0;
  int pendingPaymentCount = 0;
  int totalPending = 0;
  List<String> date = [];
  List<String> pendingBookingDate = [];
  String? tooltipMessage;
  bool isLoading = true;
  int? touchedSectionIndex;
  List<Color> gradientColors = [
    AppColors.contentColorRed,
    AppColors.contentColorGreen,
  ];
  bool showAvg = false;
  String selectedDuration = 'All time';
  bool showCompletedData = false;
  bool showPendingData = false;
  final List<String> sectionLabels = [
    'Half Paid',
    'Completed',
    'Paid',
    'Pending',
  ];
  final List<Color> sectionColors = [
    Color(0xffC968FF),
    Color(0xff70CF97),
    Color(0xff7F6AFF),
    Color(0xffED5A6B),
  ];
  List<Map<String, dynamic>> monthlyData = [
    {"month": 1, "value": 3},
    {"month": 2, "value": 2},
    {"month": 3, "value": 5},
    {"month": 4, "value": 3.1},
    {"month": 5, "value": 4},
    {"month": 6, "value": 3},
    {"month": 7, "value": 4},
    {"month": 8, "value": 2},
    {"month": 9, "value": 4},
    {"month": 10, "value": 1.5},
    {"month": 11, "value": 3.2},
    {"month": 12, "value": 2.8},
  ];
  final List<String> dropdownItems = ['All time', 'This Week', 'This Month', 'This Year'];
  LineChartData? completedChartData;
  LineChartData? pendingChartData;
  LineChartData? allChartData;

  @override
  void initState() {
    super.initState();
    fetchRunningBookingsCount().then((_) {
      updateAllChartData(selectedDuration);
    });
    completedChartData = completedData(date);
    pendingChartData = pendingData(pendingBookingDate);
    allChartData = mainData(date,pendingBookingDate);
  }


  @override
  Widget build(BuildContext context) {
    assert(dropdownItems.contains(selectedDuration), 'selectedDuration must be in dropdownItems');
    return Scaffold(
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
            toolbarHeight: MediaQuery.of(context).size.height * 0.09,
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            leading: Builder(
              builder: (BuildContext context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            )
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
                leading: SvgPicture.asset('assets/booking_logo.svg',
                    height: MediaQuery.of(context).size.height * 0.035),
                title: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('Trigger Booking',style: TextStyle(fontSize: 25),),
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
                title: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Booking Manager',style: TextStyle(fontSize: 25),),
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
              title: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Payments',style: TextStyle(fontSize: 25),),
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
              leading: SvgPicture.asset('assets/report_logo.svg'),
              title: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Report',style: TextStyle(fontSize: 25),),
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
              title: const Padding(
                padding: EdgeInsets.only(left: 7),
                child: Text('Help',style: TextStyle(fontSize: 25),),
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
              title: const Padding(
                padding: EdgeInsets.only(left: 10),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10, top: 25),
                    height: MediaQuery.sizeOf(context).height * 0.16,
                    child: Card(
                      color: Color(0xffF5B369),
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$totalBookingsCount',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text('Total Booking'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 25,left: 5,right: 5),
                    height: MediaQuery.sizeOf(context).height * 0.16,
                    child: Card(
                      color: Color(0xffC7ED6D),
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$completedBookingsCount',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text('Completed'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(right: 10, top: 25),
                    height: MediaQuery.sizeOf(context).height * 0.16,
                    child: Card(
                      color: Color(0xff52FFA9),
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$totalPending',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30)),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text('Pending'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CarouselSlider(
              options: CarouselOptions(
                enlargeCenterPage: true,
                autoPlay: false,
                aspectRatio: 10 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 1,
              ),
              items: [
                // Container(
                //   padding: const EdgeInsets.fromLTRB(8,12,8,10),
                //   child: Card(
                //     color: Colors.white,
                //     shadowColor: Colors.black,
                //     elevation: 3.0,
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         side: BorderSide(color: Color(0xff707070),width: 0.2)
                //     ),
                //     child: Stack(
                //           children: [
                //             GestureDetector(
                //               onTapDown: (details) {
                //                 Offset localPosition = details.localPosition;
                //
                //                 setState(() {
                //                   tooltipMessage = null;
                //                 });
                //               },
                //               child: PieChart(
                //                 PieChartData(
                //                   startDegreeOffset: 250,
                //                   sectionsSpace: 0,
                //                   centerSpaceRadius: 100,
                //                   pieTouchData: PieTouchData(
                //                     touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                //                       setState(() {
                //                         if (event is PointerUpEvent || event is PointerExitEvent) {
                //                           tooltipMessage = null;
                //                           touchedSectionIndex = null;
                //                         } else if (response != null && response.touchedSection != null) {
                //                           touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                //                           if (touchedSectionIndex != null &&
                //                               touchedSectionIndex! >= 0 &&
                //                               touchedSectionIndex! < sectionLabels.length) {
                //                             tooltipMessage = '  ${touchedSectionIndex} ${sectionLabels[touchedSectionIndex!]}';
                //                           } else {
                //                             touchedSectionIndex = null;
                //                             tooltipMessage = null;
                //                           }
                //                         }
                //                       });
                //                     },
                //                   ),
                //                   sections: [
                //                     PieChartSectionData(
                //                       value: halfPaidPaymentCount.toDouble(),
                //                       color: Color(0xffC968FF),
                //                       radius: 20,
                //                       showTitle: false,
                //                     ),
                //                     PieChartSectionData(
                //                       value: completedBookingsCount.toDouble(),
                //                       color: Color(0xff70CF97),
                //                       radius: 25,
                //                       showTitle: false,
                //                     ),
                //                     PieChartSectionData(
                //                       value: completedBookingsCount.toDouble(),
                //                       color: Color(0xff7F6AFF),
                //                       radius: 35,
                //                       showTitle: false,
                //                     ),
                //                     PieChartSectionData(
                //                       value: pendingPaymentCount.toDouble(),
                //                       color: Color(0xffED5A6B),
                //                       radius: 30,
                //                       showTitle: false,
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //             Positioned.fill(
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   GestureDetector(
                //                     onTap: () {
                //                       showDialog(
                //                         context: context,
                //                         builder: (BuildContext context) {
                //                           return Dialog(
                //                             shape: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.circular(8),
                //                             ),
                //                             insetPadding: EdgeInsets.symmetric(horizontal: 10),
                //                             backgroundColor: Colors.white,
                //                             child: Container(
                //                               width: MediaQuery.of(context).size.width,
                //                               padding: const EdgeInsets.all(0),
                //                               child: StatefulBuilder(
                //                                 builder: (BuildContext context, StateSetter setState) {
                //                                   return Column(
                //                                     mainAxisSize: MainAxisSize.min,
                //                                     children: [
                //                                       Container(
                //                                         width: MediaQuery.of(context).size.width * 0.8,
                //                                         height: MediaQuery.of(context).size.height * 0.53,
                //                                         child: Column(
                //                                           mainAxisAlignment: MainAxisAlignment.center,
                //                                           children: [
                //                                             Expanded(
                //                                               child: Stack(
                //                                                 children: [
                //                                                   PieChart(
                //                                                     PieChartData(
                //                                                       startDegreeOffset: 250,
                //                                                       sectionsSpace: 0,
                //                                                       centerSpaceRadius: 80,
                //                                                       pieTouchData: PieTouchData(
                //                                                         touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                //                                                           setState(() {
                //                                                             if (event is! PointerUpEvent && event is! PointerExitEvent) {
                //                                                               if (response != null && response.touchedSection != null) {
                //                                                                 touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                //                                                               }
                //                                                             } else {
                //                                                               touchedSectionIndex = null; // Reset if not touching
                //                                                             }
                //                                                           });
                //                                                         },
                //                                                       ),
                //                                                       sections: [
                //                                                         PieChartSectionData(
                //                                                           value: halfPaidPaymentCount.toDouble(),
                //                                                           color: Color(0xffC968FF),
                //                                                           radius: 20,
                //                                                           showTitle: false,
                //                                                         ),
                //                                                         PieChartSectionData(
                //                                                           value: completedBookingsCount.toDouble(),
                //                                                           color: Color(0xff70CF97),
                //                                                           radius: 25,
                //                                                           showTitle: false,
                //                                                         ),
                //                                                         PieChartSectionData(
                //                                                           value: completedBookingsCount.toDouble(),
                //                                                           color: Color(0xff7F6AFF),
                //                                                           radius: 35,
                //                                                           showTitle: false,
                //                                                         ),
                //                                                         PieChartSectionData(
                //                                                           value: pendingPaymentCount.toDouble(),
                //                                                           color: Color(0xffED5A6B),
                //                                                           radius: 30,
                //                                                           showTitle: false,
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   ),
                //                                                   Positioned.fill(
                //                                                     child: Column(
                //                                                       mainAxisAlignment: MainAxisAlignment.center,
                //                                                       children: [
                //                                                         Container(
                //                                                           height: 160,
                //                                                           width: 160,
                //                                                           child: Center(
                //                                                             child: Text(
                //                                                               touchedSectionIndex != null
                //                                                                   ? getSectionTitle(touchedSectionIndex!)
                //                                                                   : "${completedBookingsCount/totalBookingsCount*100}%\nCompleted Successfully",
                //                                                               textAlign: TextAlign.center,
                //                                                               style: TextStyle(fontSize: 20),
                //                                                             ),
                //                                                           ),
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   )
                //                                                 ],
                //                                               ),
                //                                             ),
                //                                             Padding(
                //                                               padding: const EdgeInsets.fromLTRB(35, 8, 8, 8),
                //                                               child: Column(
                //                                                 mainAxisAlignment: MainAxisAlignment.center,
                //                                                 children: [
                //                                                   Padding(
                //                                                     padding: const EdgeInsets.all(3),
                //                                                     child: Row(
                //                                                       children: [
                //                                                         CircleAvatar(
                //                                                           backgroundColor: Color(0xff009E10),
                //                                                           minRadius: 6,
                //                                                         ),
                //                                                         Padding(
                //                                                           padding: const EdgeInsets.only(left: 20),
                //                                                           child: Text(
                //                                                             'Completed',
                //                                                             style: TextStyle(
                //                                                               fontSize: 16,
                //                                                               color: Color(0xff7F6AFF),
                //                                                             ),
                //                                                           ),
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   ),
                //                                                   Padding(
                //                                                     padding: const EdgeInsets.all(3),
                //                                                     child: Row(
                //                                                       children: [
                //                                                         CircleAvatar(
                //                                                           backgroundColor: Color(0xff7F6AFF),
                //                                                           minRadius: 6,
                //                                                         ),
                //                                                         Padding(
                //                                                           padding: const EdgeInsets.only(left: 20),
                //                                                           child: Text(
                //                                                             'Paid',
                //                                                             style: TextStyle(
                //                                                               fontSize: 16,
                //                                                               color: Color(0xff7F6AFF),
                //                                                             ),
                //                                                           ),
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   ),
                //                                                   Padding(
                //                                                     padding: const EdgeInsets.all(3),
                //                                                     child: Row(
                //                                                       children: [
                //                                                         CircleAvatar(
                //                                                           backgroundColor: Color(0xffC968FF),
                //                                                           minRadius: 6,
                //                                                         ),
                //                                                         Padding(
                //                                                           padding: const EdgeInsets.only(left: 20),
                //                                                           child: Text(
                //                                                             'Half Paid',
                //                                                             style: TextStyle(
                //                                                               fontSize: 16,
                //                                                               color: Color(0xff7F6AFF),
                //                                                             ),
                //                                                           ),
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   ),
                //                                                   Padding(
                //                                                     padding: const EdgeInsets.fromLTRB(3, 3, 3, 20),
                //                                                     child: Row(
                //                                                       children: [
                //                                                         CircleAvatar(
                //                                                           backgroundColor: Color(0xffED5A6B),
                //                                                           minRadius: 6,
                //                                                         ),
                //                                                         Padding(
                //                                                           padding: const EdgeInsets.only(left: 20),
                //                                                           child: Text(
                //                                                             'Pending',
                //                                                             style: TextStyle(
                //                                                               fontSize: 16,
                //                                                               color: Color(0xff7F6AFF),
                //                                                             ),
                //                                                           ),
                //                                                         ),
                //                                                       ],
                //                                                     ),
                //                                                   ),
                //                                                 ],
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ),
                //                                       ),
                //                                     ],
                //                                   );
                //                                 },
                //                               ),
                //                             ),
                //                           );
                //                         },
                //                       );
                //                     },
                //                     child: Container(
                //                       height: 160,
                //                       width: 160,
                //                       child: Center(
                //                         child: Text(
                //                           touchedSectionIndex != null
                //                               ? getSectionTitle(touchedSectionIndex!)
                //                               : "${completedBookingsCount/totalBookingsCount*100}%\nCompleted Successfully",
                //                           textAlign: TextAlign.center,
                //                           style: TextStyle(fontSize: 20),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //             if (tooltipMessage != null)
                //               Container(
                //                 padding: EdgeInsets.all(8),
                //                 color: Colors.white,
                //                 child: Row(
                //                   children: [
                //                     Container(
                //                       width: 20,
                //                       height: 20,
                //                       color: sectionColors[touchedSectionIndex!],
                //                     ),
                //                     Text(
                //                       tooltipMessage!,
                //                       style: TextStyle(color: Colors.black,fontSize: 15),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //           ],
                //         ),
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                  child: GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            insetPadding: EdgeInsets.symmetric(horizontal: 10),
                            backgroundColor: Colors.white,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(0),
                              child: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        children: <Widget>[
                                          AspectRatio(
                                            aspectRatio: 1.15,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 0,
                                                left: 0,
                                                top: MediaQuery.sizeOf(context).height * 0.13,
                                                bottom: 0,
                                              ),
                                              child: LineChart(
                                                showCompletedData
                                                    ? completedChartData!
                                                    : showPendingData
                                                    ? pendingChartData!
                                                    : allChartData!,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 20,
                                            left: 20,
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  if (showCompletedData) {
                                                    showCompletedData = false;
                                                    showPendingData = false;
                                                    updateAllChartData(selectedDuration);
                                                  } else {
                                                    showCompletedData = true;
                                                    showPendingData = false;
                                                    updateChartData(selectedDuration);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: showCompletedData?Color(0xffF6F6F6):Colors.white,
                                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: Color(0xff009E10),
                                                        minRadius: 6,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Completed',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Color(0xff7F6AFF),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 20,
                                            left: MediaQuery.sizeOf(context).width * 0.35,
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  if (showPendingData) {
                                                    showPendingData = false;
                                                    showCompletedData = false;
                                                    updateAllChartData(selectedDuration);
                                                  } else {
                                                    showPendingData = true;
                                                    showCompletedData = false;
                                                    updateChartData(selectedDuration);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: showPendingData?Color(0xffF6F6F6):Colors.white,
                                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: Color(0xffE20808),
                                                        minRadius: 6,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          'Pending',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Color(0xff7F6AFF),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 20,
                                            right: 20,
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.sizeOf(context).width * 0.3,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffF6F6F6),
                                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                                      child: DropdownButton<String>(
                                                        value: selectedDuration,
                                                        dropdownColor: Colors.white,
                                                        icon: Icon(Icons.keyboard_arrow_down),
                                                        items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                                                          return DropdownMenuItem<String>(
                                                            value: value,
                                                            child: Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged: (String? newValue) {
                                                          if (newValue != null) {
                                                            setState(() {
                                                              selectedDuration = newValue;
                                                              showPendingData == true || showCompletedData == true
                                                                  ? updateChartData(selectedDuration)
                                                                  : updateAllChartData(selectedDuration);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Color(0xff707070),width: 0.2)
                      ),
                      child: Stack(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1.15,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 0,
                                left: 0,
                                top: MediaQuery.sizeOf(context).height * 0.13,
                                bottom: 0,
                              ),
                              child: LineChart(
                                showCompletedData
                                    ? completedChartData!
                                    : showPendingData
                                    ? pendingChartData!
                                    : allChartData!,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  if (showCompletedData) {
                                    showCompletedData = false;
                                    showPendingData = false;
                                    updateAllChartData(selectedDuration);
                                  } else {
                                    showCompletedData = true;
                                    showPendingData = false;
                                    updateChartData(selectedDuration);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: showCompletedData?Color(0xffF6F6F6):Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xff009E10),
                                        minRadius: 6,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Completed',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff7F6AFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: MediaQuery.sizeOf(context).width * 0.35,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  if (showPendingData) {
                                    showPendingData = false;
                                    showCompletedData = false;
                                    updateAllChartData(selectedDuration);
                                  } else {
                                    showPendingData = true;
                                    showCompletedData = false;
                                    updateChartData(selectedDuration);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: showPendingData?Color(0xffF6F6F6):Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xffE20808),
                                        minRadius: 6,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Pending',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff7F6AFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 15,
                            child: Stack(
                              children: <Widget>[
                                Container(
                        width: MediaQuery.sizeOf(context).width * 0.3,
                        decoration: BoxDecoration(
                          color: Color(0xffF6F6F6),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: DropdownButton<String>(
                              value: selectedDuration,
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.keyboard_arrow_down),
                              items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedDuration = newValue;
                                   showPendingData == true || showCompletedData == true
                                   ? updateChartData(selectedDuration)
                                   : updateAllChartData(selectedDuration);
                                  });
                                }
                              },
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
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    elevation: 5,
                    backgroundColor: const Color(0xff6269FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
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
                  child: const Text(
                    'New Booking',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    elevation: 5,
                    backgroundColor: Color(0xff6269FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
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
                  },
                  child: const Text(
                    'Trigger Booking',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 20,
        shadowColor: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SvgPicture.asset('assets/home.svg'),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text('Home'),
                ),
              ],
            ),
            GestureDetector(
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
              },
              child: Column(
                children: [
                  SvgPicture.asset('assets/booking_manager.svg'),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text('Booking manager'),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
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
              child: Column(
                children: [
                  SvgPicture.asset('assets/payment.svg'),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text('Payment'),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        token: widget.token,
                        id: widget.id,
                        email: widget.email
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  SvgPicture.asset('assets/profile.svg'),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text('Profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchRunningBookingsCount() async {
    String userId = widget.id;
    String token = widget.token;

    try {
      final counts = await superUserServices.getBookingsCount(userId, token);
      print('Counts received: $counts$pendingBookingDate');

      setState(() {
        totalBookingsCount = counts['totalBookings'] ?? 0;
        runningBookingsCount = counts['runningBookingsCount'] ?? 0;
        completedBookingsCount = counts['completedBookings'] ?? 0;
        yetToStartBookingsCount = counts['yetToStartBookingsCount'] ?? 0;
        halfPaidPaymentCount = counts['halfPaidPaymentCount'] ?? 0;
        pendingPaymentCount = counts['pendingPaymentCount'] ?? 0;
        date = List<String>.from(counts['bookingDates'] ?? []);
        pendingBookingDate = List<String>.from(counts['pendingBookingDates'] ?? []);
        totalPending = runningBookingsCount + yetToStartBookingsCount;
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching running bookings count: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getSectionTitle(int index) {
    switch (index) {
      case 0:
        return "${halfPaidPaymentCount/totalBookingsCount*100}%\nHalf Paid";
      case 1:
        return "${completedBookingsCount/totalBookingsCount*100}%\nCompleted";
      case 2:
        return "${completedBookingsCount/totalBookingsCount*100}%\nPaid";
      case 3:
        return "${pendingPaymentCount/totalBookingsCount*100}%\nPending";
      default:
        return "${completedBookingsCount/totalBookingsCount*100}%\nCompleted Successfully";
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Color(0xff8F8E97),
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Jan', style: style);
        break;
      case 2:
        text = const Text('Feb', style: style);
        break;
      case 3:
        text = const Text('Mar', style: style);
        break;
      case 4:
        text = const Text('Apr', style: style);
        break;
      case 5:
        text = const Text('May', style: style);
        break;
      case 6:
        text = const Text('Jun', style: style);
        break;
      case 7:
        text = const Text('Jul', style: style);
        break;
      case 8:
        text = const Text('Aug', style: style);
        break;
      case 9:
        text = const Text('Sep', style: style);
        break;
      case 10:
        text = const Text('Oct', style: style);
        break;
      case 11:
        text = const Text('Nov', style: style);
        break;
      case 12:
        text = const Text('Dec', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData(List<String> completedBookingDates, List<String> pendingBookingDates) {
    final completedMonthlyCounts = countBookingsByMonth(completedBookingDates);
    final pendingMonthlyCounts = countBookingsByMonth(pendingBookingDates);

    final completedSpots = generateSpotsFromMonthlyData(completedMonthlyCounts);
    final pendingSpots = generateSpotsFromMonthlyData(pendingMonthlyCounts);

    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: AppColors.mainGridLineColor,
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: AppColors.mainGridLineColor,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 42),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, _) {
              if (value < 1 || value > 12) return const Text('');
              const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''];
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: completedSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: [Color(0xffEBE7FF), Color(0xffB6A3FF)]),
          ),
        ),
        LineChartBarData(
          spots: pendingSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: [Color(0xffEBE7FF), Color(0xffB6A3FF)]),
          ),
        ),
      ],
    );
  }

  LineChartData pendingData(List<String> filteredDates) {
    final monthlyCounts = countBookingsByMonth(filteredDates);
    final spots = generateSpotsFromMonthlyData(monthlyCounts);

    print("Monthly counts: $monthlyCounts");
    print("Spots generated: $spots");

    double maxY = monthlyCounts.values.isNotEmpty
        ? monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.1 // Adjust scaling factor as needed
        : 1;

    return LineChartData(
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: [Color(0xffEBE7FF), Color(0xffB6A3FF)]),
          ),
        ),
      ],
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 42),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              if (value < 0 || value > 12) return Text(''); // Return empty if out of bounds
              const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''];
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
    );
  }

  LineChartData completedData(List<String> filteredDates) {
    final monthlyCounts = countBookingsByMonth(filteredDates);
    final spots = generateSpotsFromMonthlyData(monthlyCounts);


    print("Monthly counts: $monthlyCounts");
    print("Spots generated: $spots");

    double maxY = monthlyCounts.values.isNotEmpty
        ? monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.1
        : 1;

    return LineChartData(
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: [Color(0xffEBE7FF), Color(0xffB6A3FF)]),
          ),
        ),
      ],
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 42),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              if (value < 0 || value > 12) return Text(''); // Return empty if out of bounds
              const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''];
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
    );
  }

  Map<int, int> countBookingsByMonth(List<String> bookingDates) {
    Map<int, int> monthlyCounts = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var dateStr in bookingDates) {
      try {
        final date = dateFormat.parse(dateStr);
        int month = date.month;
        monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
      } catch (e) {
        print("Invalid date format: $dateStr");
      }
    }
    return monthlyCounts;
  }

  List<FlSpot> generateSpotsFromMonthlyData(Map<int, int> monthlyCounts) {
    List<FlSpot> spots = [];
    for (int month = 1; month <= 12; month++) {
      int count = monthlyCounts[month] ?? 0;
      spots.add(FlSpot(month.toDouble(), count.toDouble()));
    }
    return spots;
  }

  void updateChartData(String duration) {
    List<String> filteredDates = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    switch (duration) {
      case 'This Week':
        showCompletedData == true
        ? filteredDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
              bookingDate.isBefore(endOfWeek.add(Duration(days: 1)));
        }).toList()
        : filteredDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
              bookingDate.isBefore(endOfWeek.add(Duration(days: 1)));
        }).toList();
        break;

      case 'This Month':
        showCompletedData == true
        ? filteredDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year && bookingDate.month == now.month;
        }).toList()
        : filteredDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year && bookingDate.month == now.month;
        }).toList();
        break;

      case 'This Year':
        showCompletedData == true
        ? filteredDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year;
        }).toList()
        : filteredDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year;
        }).toList();
        break;

      case 'All time':
        showCompletedData == true
        ? filteredDates = date
        : filteredDates = pendingBookingDate;
        break;

      default:
        showCompletedData == true
            ? filteredDates = date
            : filteredDates = pendingBookingDate;
        break;
    }

    print("Filtered Dates: $filteredDates");

    if (filteredDates.isEmpty) {
      setState(() {
        final monthlyCounts = countBookingsByMonth(filteredDates);
        final spots = generateSpotsFromMonthlyData(monthlyCounts);
        double maxY = monthlyCounts.values.isNotEmpty
            ? monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.1
            : 1;
        showCompletedData == true
        ? completedChartData = LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          gridData: FlGridData(
            show: false,
            drawHorizontalLine: true,
            verticalInterval: 1,
            horizontalInterval: 1,
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: 0,
          maxX: 13,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green, // Customize as needed
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, _) {
                  if (value < 0 || value > 12) return Text(''); // Return empty if out of bounds
                  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
          ),
        )
        : pendingChartData = LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          gridData: FlGridData(
            show: false,
            drawHorizontalLine: true,
            verticalInterval: 1,
            horizontalInterval: 1,
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: 0,
          maxX: 13,
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.red, // Customize as needed
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, _) {
                  if (value < 0 || value > 12) return Text(''); // Return empty if out of bounds
                  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ''];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
          ),
        );
      });
    } else {
      setState(() {
        showCompletedData == true
        ? completedChartData = completedData(filteredDates)
        : pendingChartData = pendingData(filteredDates);
      });
    }
  }

  void updateAllChartData(String duration) {
    List<String> filteredCompletedDates = [];
    List<String> filteredPendingDates = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    switch (duration) {
      case 'This Week':
        filteredCompletedDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.isAfter(startOfWeek) && bookingDate.isBefore(endOfWeek);
        }).toList();
        filteredPendingDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.isAfter(startOfWeek) && bookingDate.isBefore(endOfWeek);
        }).toList();
        break;

      case 'This Month':
        filteredCompletedDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year && bookingDate.month == now.month;
        }).toList();
        filteredPendingDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year && bookingDate.month == now.month;
        }).toList();
        break;

      case 'This Year':
        filteredCompletedDates = date.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year;
        }).toList();
        filteredPendingDates = pendingBookingDate.where((date) {
          DateTime bookingDate = DateTime.parse(date);
          return bookingDate.year == now.year;
        }).toList();
        break;

      case 'All time':
        filteredCompletedDates = date;
        filteredPendingDates = pendingBookingDate;
        break;

      default:
        filteredCompletedDates = date;
        filteredPendingDates = pendingBookingDate;
        break;
    }


    setState(() {
      allChartData = mainData(filteredCompletedDates, filteredPendingDates);
    });
  }


  List<String> getWeeklyData(List<String> dates) {
    final DateTime today = DateTime.now();
    final DateTime weekAgo = today.subtract(Duration(days: 7));
    return dates.where((date) {
      final bookingDate = DateTime.parse(date);
      return bookingDate.isAfter(weekAgo) && bookingDate.isBefore(today);
    }).toList();
  }

  List<String> getMonthlyData(List<String> dates) {
    final DateTime today = DateTime.now();
    final DateTime monthAgo = today.subtract(Duration(days: 30));
    return dates.where((date) {
      final bookingDate = DateTime.parse(date);
      return bookingDate.isAfter(monthAgo) && bookingDate.isBefore(today);
    }).toList();
  }

  List<String> getYearlyData(List<String> dates) {
    final DateTime today = DateTime.now();
    final DateTime yearAgo = today.subtract(Duration(days: 365));
    return dates.where((date) {
      final bookingDate = DateTime.parse(date);
      return bookingDate.isAfter(yearAgo) && bookingDate.isBefore(today);
    }).toList();
  }


  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppColors {
  static const Color contentColorRed = Colors.red; // Example color
  static const Color contentColorGreen = Colors.green; // Example color
  static const Color mainGridLineColor = Color(0xffB6A3FF); // Example color
}