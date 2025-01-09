import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUserType.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class SuperUserHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  final String? image;
  final String? accountType;
  const SuperUserHomePage({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email, this.accountType, this.image});

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
  int completedPaymentCount = 0;
  int paidPaymentCount = 0;
  int tripCompletedBookingsCount = 0;
  int totalPending = 0;
  int totalCompleted = 0;
  List<String> date = [];
  List<String> pendingBookingDate = [];
  String? tooltipMessage;
  bool isLoading = true;
  bool isTapped = false;
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
    'HalfPaid'.tr(),
    'Completed'.tr(),
    'Pending'.tr(),
  ];
  final List<Color> sectionColors = [
    Color(0xffC968FF),
    Color(0xff70CF97),
    Color(0xffED5A6B),
  ];
  final List<String> dropdownItems = ['All time', 'This Week', 'This Month', 'This Year'];
  LineChartData? completedChartData;
  LineChartData? pendingChartData;
  LineChartData? allChartData;
  int _selectedIndex = 0;

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
    ViewUtil viewUtil = ViewUtil(context);
    assert(dropdownItems.contains(selectedDuration), 'selectedDuration must be in dropdownItems');
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
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              toolbarHeight: 80,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Text(
                'Home'.tr(),
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
                  leading: SvgPicture.asset('assets/booking_logo.svg',
                      height: viewUtil.isTablet
                          ? MediaQuery.of(context).size.height * 0.028
                          : MediaQuery.of(context).size.height * 0.035),
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
                  leading: SvgPicture.asset('assets/booking_manager.svg',
                      height: viewUtil.isTablet
                          ? MediaQuery.of(context).size.height * 0.028
                          : MediaQuery.of(context).size.height * 0.035),
                  title: Padding(
                    padding: EdgeInsets.only(left: viewUtil.isTablet?5:10),
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
                leading: SvgPicture.asset('assets/payment.svg',
                    height: viewUtil.isTablet
                        ? MediaQuery.of(context).size.height * 0.028
                        : MediaQuery.of(context).size.height * 0.035),
                title: Padding(
                  padding: EdgeInsets.only(left: viewUtil.isTablet?5:10),
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
                  leading: Icon(Icons.account_balance_outlined,size: viewUtil.isTablet?37:35,),
                  title: Padding(
                    padding: EdgeInsets.only(left: viewUtil.isTablet?5:7),
                    child: Text('Invoice'.tr(),style: TextStyle(fontSize: 25),),
                  ),
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
                leading: SvgPicture.asset('assets/report_logo.svg',
                    height: viewUtil.isTablet
                        ? MediaQuery.of(context).size.height * 0.028
                        : MediaQuery.of(context).size.height * 0.035),
                title: Padding(
                  padding: EdgeInsets.only(left: viewUtil.isTablet?5:10),
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
                leading: SvgPicture.asset('assets/help_logo.svg',
                    height: viewUtil.isTablet
                        ? MediaQuery.of(context).size.height * 0.028
                        : MediaQuery.of(context).size.height * 0.035),
                title: Padding(
                  padding: EdgeInsets.only(left: viewUtil.isTablet?5:10),
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
                            Text('$totalBookingsCount',style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?30:26)),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text('Total Bookings'.tr(),
                                style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
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
                            Text('$completedBookingsCount',style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?30:26),),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text('Completed'.tr(),style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
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
                            Text('$yetToStartBookingsCount',style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet?30:26)),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text('Hold'.tr(),style: TextStyle(fontSize: viewUtil.isTablet?26:16)),
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
                  autoPlay: true,
                  aspectRatio:  viewUtil.isTablet ? 13/9 : 10 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 1,
                ),
                items:[
                  Container(
                    padding: viewUtil.isTablet
                        ? EdgeInsets.fromLTRB(20,12,20,10)
                        : EdgeInsets.fromLTRB(8,12,8,10),
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xff707070),width: 0.2)
                      ),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTapDown: (details) {
                              Offset localPosition = details.localPosition;

                              setState(() {
                                tooltipMessage = null;
                              });
                            },
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: 250,
                                sectionsSpace: 0,
                                centerSpaceRadius: viewUtil.isTablet ?150:100,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                                    setState(() {
                                      if (event is PointerUpEvent || event is PointerExitEvent) {
                                        tooltipMessage = null;
                                        touchedSectionIndex = null;
                                      } else if (response != null && response.touchedSection != null) {
                                        touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                                        if (touchedSectionIndex != null &&
                                            touchedSectionIndex! >= 0 &&
                                            touchedSectionIndex! < sectionLabels.length) {
                                          tooltipMessage = '  ${touchedSectionIndex == 0
                                              ? halfPaidPaymentCount
                                              : touchedSectionIndex ==  1
                                              ? totalCompleted
                                              : tripCompletedBookingsCount
                                          } ${sectionLabels[touchedSectionIndex!]}';
                                        } else {
                                          touchedSectionIndex = null;
                                          tooltipMessage = null;
                                        }
                                      }
                                    });
                                  },
                                ),
                                sections: [
                                  PieChartSectionData(
                                    value: halfPaidPaymentCount > 0 ? halfPaidPaymentCount.toDouble() : 0.0001,
                                    color: Color(0xffC968FF),
                                    radius: viewUtil.isTablet ? 30: 20,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: totalCompleted > 0 ? totalCompleted.toDouble() : 0.0001,
                                    color: Color(0xff70CF97),
                                    radius: viewUtil.isTablet ?40 : 30,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: tripCompletedBookingsCount > 0 ? tripCompletedBookingsCount.toDouble() : 0.0001,
                                    color: Color(0xffED5A6B),
                                    radius: viewUtil.isTablet ? 50: 40,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Directionality(
                                          textDirection: ui.TextDirection.ltr,
                                          child: Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            insetPadding: EdgeInsets.symmetric(horizontal: viewUtil.isTablet ?40:10),
                                            backgroundColor: Colors.white,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: const EdgeInsets.all(0),
                                              child: StatefulBuilder(
                                                builder: (BuildContext context, StateSetter setState) {
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(context).size.width * 0.8,
                                                        height: MediaQuery.of(context).size.height * 0.53,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Expanded(
                                                              child: Stack(
                                                                children: [
                                                                  PieChart(
                                                                    PieChartData(
                                                                      startDegreeOffset: 250,
                                                                      sectionsSpace: 0,
                                                                      centerSpaceRadius: viewUtil.isTablet ?140:80,
                                                                      pieTouchData: PieTouchData(
                                                                        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                                                                          setState(() {
                                                                            if (event is! PointerUpEvent && event is! PointerExitEvent) {
                                                                              if (response != null && response.touchedSection != null) {
                                                                                touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                                                                              }
                                                                            } else {
                                                                              touchedSectionIndex = null;
                                                                            }
                                                                          });
                                                                        },
                                                                      ),
                                                                      sections: [
                                                                        PieChartSectionData(
                                                                          value: halfPaidPaymentCount.toDouble(),
                                                                          color: Color(0xffC968FF),
                                                                          radius: viewUtil.isTablet ? 30: 20,
                                                                          showTitle: false,
                                                                        ),
                                                                        PieChartSectionData(
                                                                          value: totalCompleted.toDouble(),
                                                                          color: Color(0xff70CF97),
                                                                          radius: viewUtil.isTablet ? 40: 30,
                                                                          showTitle: false,
                                                                        ),
                                                                        PieChartSectionData(
                                                                          value: tripCompletedBookingsCount.toDouble(),
                                                                          color: Color(0xffED5A6B),
                                                                          radius: viewUtil.isTablet ? 50: 40,
                                                                          showTitle: false,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Positioned.fill(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                          height: 160,
                                                                          width: 160,
                                                                          child: Center(
                                                                            child: totalBookingsCount!= 0
                                                                                ? Text(
                                                                              touchedSectionIndex != null
                                                                                  ? getSectionTitle(touchedSectionIndex!)
                                                                                  : totalCompleted!=0
                                                                                  ? "${(totalCompleted / totalBookingsCount * 100).toInt()}%\n${'Completed Successfully'.tr()}"
                                                                                  : "${(totalCompleted / totalBookingsCount * 100).toInt()}%\n${'Completed'.tr()}",
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: viewUtil.isTablet ? 25: 20),
                                                                            )
                                                                                : Text('No Bookings Found'.tr()),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(35, 8, 8, 8),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(3),
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundColor: Color(0xff009E10),
                                                                          minRadius: 6,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 20),
                                                                          child: Text(
                                                                            'Completed'.tr(),
                                                                            style: TextStyle(
                                                                              fontSize: viewUtil.isTablet ?22:16,
                                                                              color: Color(0xff7F6AFF),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(3),
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundColor: Color(0xffC968FF),
                                                                          minRadius: 6,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 20),
                                                                          child: Text(
                                                                            'HalfPaid'.tr(),
                                                                            style: TextStyle(
                                                                              fontSize:  viewUtil.isTablet ?22:16,
                                                                              color: Color(0xff7F6AFF),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.fromLTRB(3, 3, 3, 20),
                                                                    child: Row(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          backgroundColor: Color(0xffED5A6B),
                                                                          minRadius: 6,
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 20),
                                                                          child: Text(
                                                                            'Pending'.tr(),
                                                                            style: TextStyle(
                                                                              fontSize:  viewUtil.isTablet ?22:16,
                                                                              color: Color(0xff7F6AFF),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 160,
                                    width: 160,
                                    child: Center(
                                      child: totalBookingsCount!=0
                                          ? Text(
                                        touchedSectionIndex != null
                                            ? getSectionTitle(touchedSectionIndex!)
                                            : totalCompleted!=0
                                              ? "${(totalCompleted / totalBookingsCount * 100).toInt()}%\n${'Completed Successfully'.tr()}"
                                              : "${(totalCompleted / totalBookingsCount * 100).toInt()}%\n${'Completed'.tr()}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: viewUtil.isTablet ?25:20),
                                              )
                                            : Text('No Bookings Found'.tr()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tooltipMessage != null)
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    color: sectionColors[touchedSectionIndex!],
                                  ),
                                  Text(
                                    tooltipMessage!,
                                    style: TextStyle(color: Colors.black,fontSize:  viewUtil.isTablet ?22:15),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: viewUtil.isTablet
                      ? EdgeInsets.fromLTRB(20,12,20,10)
                      : EdgeInsets.fromLTRB(8, 12, 8, 10),
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
                            aspectRatio: viewUtil.isTablet?1.18:1.15,
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
                          totalBookingsCount!=0
                          ? Positioned(
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
                                          'Completed'.tr(),
                                          style: TextStyle(
                                            fontSize: viewUtil.isTablet?22:16,
                                            color: Color(0xff7F6AFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          : Container(),
                          totalBookingsCount!=0
                          ? Positioned(
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
                                          'Hold'.tr(),
                                          style: TextStyle(
                                            fontSize: viewUtil.isTablet?22:16,
                                            color: Color(0xff7F6AFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          : Container(),
                          Positioned(
                            top: 20,
                            right: 15,
                            child: Stack(
                              children: <Widget>[
                                Container(
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
                                            child: Directionality(
                                              textDirection: ui.TextDirection.ltr,
                                              child: Row(
                                                children: [
                                                  Text(value.tr()),
                                                ],
                                              ),
                                            ),
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
                ]
              ),
              Padding(
                padding: viewUtil.isTablet?EdgeInsets.all(15):EdgeInsets.all(8.0),
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
                          builder: (context) => SuperUsertype(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              token: widget.token,
                              id: widget.id,
                              email: widget.email
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'NewBooking'.tr(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet?27:20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  viewUtil.isTablet?EdgeInsets.all(15):EdgeInsets.all(8.0),
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
                    child: Text(
                      'Trigger Booking'.tr(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet?27:20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
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
        commonWidgets.showToast("You're already on Home");
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
        completedPaymentCount = counts['completedPaymentCount'] ?? 0;
        paidPaymentCount = counts['paidPaymentCount'] ?? 0;
        tripCompletedBookingsCount = counts['tripCompletedBookingsCount'] ?? 0;
        date = List<String>.from(counts['bookingDates'] ?? []);
        pendingBookingDate = List<String>.from(counts['pendingBookingDates'] ?? []);
        totalPending = runningBookingsCount + yetToStartBookingsCount;
        totalCompleted = completedPaymentCount + paidPaymentCount;
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

  void showLogoutDialog(){
    ViewUtil viewUtil = ViewUtil(context);
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
                  : MediaQuery.of(context).size.height * 0.1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30,bottom: 10),
                    child: Text(
                      'are_you_sure_you_want_to_logout'.tr(),
                      style: TextStyle(fontSize: viewUtil.isTablet?27:19),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('yes'.tr(),
                  style: TextStyle(fontSize: viewUtil.isTablet?22:16),),
                onPressed: () async {
                  await clearUserData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserLogin()),
                  );
                },
              ),
              TextButton(
                child: Text('no'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
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

  String getSectionTitle(int index) {
    switch (index) {
      case 0:
        return "${(halfPaidPaymentCount/totalBookingsCount*100).toInt()}%\n${'HalfPaid'.tr()}";
      case 1:
        return "${(totalCompleted/totalBookingsCount*100).toInt()}%\n${'Completed'.tr()}";
      case 2:
        return "${(tripCompletedBookingsCount/totalBookingsCount*100).toInt()}%\n${'Pending'.tr()}";
      default:
        return "${(totalCompleted/totalBookingsCount*100).toInt()}%\n${'Completed Successfully'.tr()}";
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
        text = Text('Jan'.tr(), style: style);
        break;
      case 2:
        text = Text('Feb'.tr(), style: style);
        break;
      case 3:
        text = Text('Mar'.tr(), style: style);
        break;
      case 4:
        text = Text('Apr'.tr(), style: style);
        break;
      case 5:
        text = Text('May'.tr(), style: style);
        break;
      case 6:
        text = Text('Jun'.tr(), style: style);
        break;
      case 7:
        text = Text('Jul'.tr(), style: style);
        break;
      case 8:
        text = Text('Aug'.tr(), style: style);
        break;
      case 9:
        text = Text('Sep'.tr(), style: style);
        break;
      case 10:
        text = Text('Oct'.tr(), style: style);
        break;
      case 11:
        text = Text('Nov'.tr(), style: style);
        break;
      case 12:
        text = Text('Dec'.tr(), style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  List<FlSpot> generateWeeklySpots(List<String> bookingDates) {
    final dailyCounts = countBookingsByDay(bookingDates);
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), dailyCounts[index].toDouble());
    });
  }

  List<int> countBookingsByDay(List<String> bookingDates) {
    List<int> dailyCounts = List.filled(7, 0);

    for (String date in bookingDates) {
      DateTime bookingDate = DateTime.parse(date);
      int dayOfWeek = bookingDate.weekday % 7;
      dailyCounts[dayOfWeek]++;
    }

    return dailyCounts;
  }

  LineChartData mainData(List<String> completedBookingDates, List<String> pendingBookingDates) {
    final totalCompletedCount = completedBookingDates.length;
    final totalPendingCount = pendingBookingDates.length;
    ViewUtil viewUtil = ViewUtil(context);
    List<FlSpot> completedSpots;
    List<FlSpot> pendingSpots;

    if (selectedDuration == 'All time') {
      completedSpots = [FlSpot(2, totalCompletedCount.toDouble())];
      pendingSpots = [FlSpot(1, totalPendingCount.toDouble())];
    } else {
      completedSpots = selectedDuration == 'This Week'
          ? generateWeeklySpots(completedBookingDates)
          : generateSpotsFromMonthlyData(countBookingsByMonth(completedBookingDates));

      pendingSpots = selectedDuration == 'This Week'
          ? generateWeeklySpots(pendingBookingDates)
          : generateSpotsFromMonthlyData(countBookingsByMonth(pendingBookingDates));
    }

    List<String> weekDays = ['Sun'.tr(), 'Mon'.tr(), 'Tue'.tr(), 'Wed'.tr(), 'Thu'.tr(), 'Fri'.tr(), 'Sat'.tr(),];
    List<String> months = ['', 'Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(), 'May'.tr(), 'Jun'.tr(), 'Jul'.tr(), 'Aug'.tr(), 'Sep'.tr(), 'Oct'.tr(), 'Nov'.tr(), 'Dec'.tr(), ''];
    List<String> allTimeTitles = ['All Bookings'.tr(), 'Hold'.tr(), 'Completed'.tr()];

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
            interval: 1,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              if (selectedDuration == 'All time') {
                if (value >= 0 && value < allTimeTitles.length) {
                  return Text(allTimeTitles[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else if (selectedDuration == 'This Week') {
                if (value >= 0 && value < weekDays.length) {
                  return Text(weekDays[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else {
                if (value < 0 || value > 12) return Text('');
                return Text(months[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
              }
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: selectedDuration == 'This Week' ? -1 : selectedDuration == 'All time' ? -0.7 : 0,
      maxX: selectedDuration == 'This Week' ? 7 : selectedDuration == 'All time' ? 3 : 13,
      minY: 0,
      maxY: selectedDuration == 'All time' ? 20:15,
      lineBarsData: [
        LineChartBarData(
          show: selectedDuration == 'All time',
          spots: selectedDuration == 'All time'
              ? [
            FlSpot(-0.7, 0),
            FlSpot(0, totalBookingsCount.toDouble()),
            FlSpot(1, totalPendingCount.toDouble()),
            FlSpot(2, totalCompletedCount.toDouble()),
            FlSpot(3, 0),
          ]
              : completedSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffD8D4EF),
                Color(0xffDCD6FE),
                Color(0xffDCD6FE),
                Color(0xffE2DDFE),
                Color(0xffEBE7FF),
                Color(0xffF4F2FF),
                Color(0xffFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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
            gradient: LinearGradient(
              colors: [
                Color(0xffD8D4EF),
                Color(0xffDCD6FE),
                Color(0xffDCD6FE),
                Color(0xffE2DDFE),
                Color(0xffEBE7FF),
                Color(0xffF4F2FF),
                Color(0xffFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        LineChartBarData(
          spots: completedSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffD8D4EF),
                Color(0xffDCD6FE),
                Color(0xffDCD6FE),
                Color(0xffE2DDFE),
                Color(0xffEBE7FF),
                Color(0xffF4F2FF),
                Color(0xffFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData pendingData(List<String> filteredDates) {
    ViewUtil viewUtil = ViewUtil(context);
    final totalPendingCount = filteredDates.length;
    final spots = selectedDuration == 'This Week'
        ? generateWeeklySpots(filteredDates)
        : generateSpotsFromMonthlyData(countBookingsByMonth(filteredDates));
    List<FlSpot> completedSpots;
    List<FlSpot> pendingSpots;

    if (selectedDuration == 'All time') {
      pendingSpots = [FlSpot(1, totalPendingCount.toDouble())];
    } else {
      final spots = selectedDuration == 'This Week'
          ? generateWeeklySpots(filteredDates)
          : generateSpotsFromMonthlyData(countBookingsByMonth(filteredDates));
    }


    List<String> weekDays = ['Sun'.tr(), 'Mon'.tr(), 'Tue'.tr(), 'Wed'.tr(), 'Thu'.tr(), 'Fri'.tr(), 'Sat'.tr()];
    List<String> months = ['', 'Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(), 'May'.tr(), 'Jun'.tr(), 'Jul'.tr(), 'Aug'.tr(), 'Sep'.tr(), 'Oct'.tr(), 'Nov'.tr(), 'Dec'.tr(), ''];
    List<String> allTimeTitles = ['All Bookings'.tr(), 'Hold'.tr()];


    return LineChartData(
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: selectedDuration == 'This Week' ? -1 : selectedDuration == 'All time' ? -0.7 : 0,
      maxX: selectedDuration == 'This Week' ? 7 : selectedDuration == 'All time' ? 3 : 13,
      minY: 0,
      maxY: selectedDuration == 'All time' ? 20 : 15,
      lineBarsData: [
        LineChartBarData(
          spots: selectedDuration == 'All time'
              ? [
            FlSpot(-0.7, 0),
            FlSpot(0, totalBookingsCount.toDouble()),
            FlSpot(1, totalPendingCount.toDouble()),
            FlSpot(3, 0),
          ]
              : spots,
          isCurved: true,
          color: Colors.red,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffD8D4EF),
                Color(0xffDCD6FE),
                Color(0xffDCD6FE),
                Color(0xffE2DDFE),
                Color(0xffEBE7FF),
                Color(0xffF4F2FF),
                Color(0xffFFFFFF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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
              if (selectedDuration == 'All time') {
                if (value >= 0 && value < allTimeTitles.length) {
                  return Text(allTimeTitles[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else if (selectedDuration == 'This Week') {
                if (value >= 0 && value < weekDays.length) {
                  return Text(weekDays[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else {
                if (value < 1 || value > 12) return Text('');
                return Text(months[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
              }
            },
          ),
        ),
      ),
    );
  }

  LineChartData completedData(List<String> filteredDates) {
    ViewUtil viewUtil = ViewUtil(context);
    final totalCompletedCount = filteredDates.length;
    final spots = selectedDuration == 'This Week'
        ? generateWeeklySpots(filteredDates)
        : generateSpotsFromMonthlyData(countBookingsByMonth(filteredDates));
    List<FlSpot> completedSpots;
    List<FlSpot> pendingSpots;

    if (selectedDuration == 'All time') {
      completedSpots = [FlSpot(2, totalCompletedCount.toDouble())];
    } else {
      final spots = selectedDuration == 'This Week'
          ? generateWeeklySpots(filteredDates)
          : generateSpotsFromMonthlyData(countBookingsByMonth(filteredDates));
    }


    List<String> weekDays = ['Sun'.tr(), 'Mon'.tr(), 'Tue'.tr(), 'Wed'.tr(), 'Thu'.tr(), 'Fri'.tr(), 'Sat'.tr()];
    List<String> months = ['', 'Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(), 'May'.tr(), 'Jun'.tr(), 'Jul'.tr(), 'Aug'.tr(), 'Sep'.tr(), 'Oct'.tr(), 'Nov'.tr(), 'Dec'.tr(), ''];
    List<String> allTimeTitles = ['All Bookings'.tr(), 'Completed'.tr()];
    print("Monthly counts: ${countBookingsByMonth(filteredDates)}");
    print("Spots generated: $spots");

    double maxY = spots.isNotEmpty
        ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1
        : 1;

    return LineChartData(
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: selectedDuration == 'This Week' ? -1 : selectedDuration == 'All time' ? -0.7 : 0,
      maxX: selectedDuration == 'This Week' ? 7 : selectedDuration == 'All time' ? 3 : 13,
      minY: 0,
      maxY: selectedDuration == 'All time' ? 20 : 15,
      lineBarsData: [
        LineChartBarData(
          spots: selectedDuration == 'All time'
              ? [
            FlSpot(-0.7, 0),
            FlSpot(0, totalBookingsCount.toDouble()),
            FlSpot(1, totalCompletedCount.toDouble()),
            FlSpot(3, 0),
          ]
              : spots,
          isCurved: true,
          color: Colors.green,
          barWidth: 4,
          isStrokeCapRound: false,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
              Color(0xffD8D4EF),
              Color(0xffDCD6FE),
              Color(0xffDCD6FE),
              Color(0xffE2DDFE),
              Color(0xffEBE7FF),
              Color(0xffF4F2FF),
              Color(0xffFFFFFF),
            ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,),
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
              if (selectedDuration == 'All time') {
                if (value >= 0 && value < allTimeTitles.length) {
                  return Text(allTimeTitles[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else if (selectedDuration == 'This Week') {
                if (value >= 0 && value < weekDays.length) {
                  return Text(weekDays[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                } else {
                  return Text('');
                }
              } else {
                if (value < 1 || value > 12) return Text('');
                return Text(months[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
              }
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
    ViewUtil viewUtil = ViewUtil(context);
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
        final spots = selectedDuration == 'This Week'
            ? generateWeeklySpots(filteredDates)
            : generateSpotsFromMonthlyData(monthlyCounts);

        List<String> weekDays = ['Sun'.tr(), 'Mon'.tr(), 'Tue'.tr(), 'Wed'.tr(), 'Thu'.tr(), 'Fri'.tr(), 'Sat'.tr()];
        List<String> months = ['', 'Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(), 'May'.tr(), 'Jun'.tr(), 'Jul'.tr(), 'Aug'.tr(), 'Sep'.tr(), 'Oct'.tr(), 'Nov'.tr(), 'Dec'.tr(), ''];

        double maxY = monthlyCounts.values.isNotEmpty
            ? monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.1
            : 1;

        if (showCompletedData) {
          completedChartData = LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            gridData: FlGridData(
              show: false,
              drawHorizontalLine: true,
              verticalInterval: 1,
              horizontalInterval: 1,
              getDrawingVerticalLine: (value) => const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              ),
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: false,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            minX: selectedDuration == 'This Week' ? -1 : selectedDuration == 'All time' ? -0.7 : 0,
            maxX: selectedDuration == 'This Week' ? 7 : selectedDuration == 'All time' ? 3 : 13,
            minY: 0,
            maxY: selectedDuration == 'All time' ? 20 : 15,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.green,
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
                    if (selectedDuration == 'This Week') {
                      if (value >= 0 && value < weekDays.length) {
                        return Text(weekDays[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                      } else {
                        return Text('');
                      }
                    } else {
                      if (value < 0 || value > 12) return Text('');
                      return Text(months[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                    }
                  },
                ),
              ),
            ),
          );
        } else {
          pendingChartData = LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            gridData: FlGridData(
              show: false,
              drawHorizontalLine: true,
              verticalInterval: 1,
              horizontalInterval: 1,
              getDrawingVerticalLine: (value) => const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              ),
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: false,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            minX: selectedDuration == 'This Week' ? -1 : selectedDuration == 'All time' ? -0.7 : 0,
            maxX: selectedDuration == 'This Week' ? 7 : selectedDuration == 'All time' ? 3 : 13,
            minY: 0,
            maxY: selectedDuration == 'All time' ? 20 : 15,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.red,
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
                    if (selectedDuration == 'This Week') {
                      if (value >= 0 && value < weekDays.length) {
                        return Text(weekDays[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                      } else {
                        return Text('');
                      }
                    } else {
                      if (value < 0 || value > 12) return Text('');
                      return Text(months[value.toInt()],style: TextStyle(fontSize: viewUtil.isTablet?20:14));
                    }
                  },
                ),
              ),
            ),
          );
        }
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
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
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

}

class AppColors {
  static const Color contentColorRed = Colors.red;
  static const Color contentColorGreen = Colors.green;
  static const Color mainGridLineColor = Color(0xffB6A3FF);
}