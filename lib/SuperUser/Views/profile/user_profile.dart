import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class UserProfile extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const UserProfile({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final CommonWidgets commonWidgets = CommonWidgets();
  int _selectedIndex = 3;
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
          showLanguage: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
                scrolledUnderElevation: 0,
                toolbarHeight: MediaQuery.of(context).size.height * 0.09,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff6A66D1),
                title: Text(
                  'Profile'.tr(),
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
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(

                    ),
                    title: Text(widget.firstName +' '+ widget.lastName),
                    subtitle: Row(
                      children: [
                        Text('${'Id'.tr()}: ${ widget.id}',
                          style: TextStyle(
                            color: Color(0xff8E8D96),
                          ),)
                      ],
                    ),
                    trailing: IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.edit))
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  color: Colors.white,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          const SizedBox(
                            width: 32,
                          ),
                          Text(
                            'Monthly Booking'.tr(),
                            style: TextStyle(
                              color: Color(0xff8E8D96),
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '450',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          Expanded(
                            child: BarChart(
                              randomData(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Booking'.tr(),style: TextStyle(fontSize: 16)),
                    Text('View All'.tr(),style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 3.0,
                  child: ListTile(
                      leading: CircleAvatar(),
                      title: Text('Vehicle'.tr()),
                      subtitle: Row(
                        children: [
                          Text('12.02.2022',
                            style: TextStyle(
                              color: Color(0xff8E8D96),
                            ),)
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffF5F3FF),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${'Vendor'.tr()} 2',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff7F6AFF),
                            ),
                          ),
                        ),
                      ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 3.0,
                  child: ListTile(
                      leading: CircleAvatar(

                      ),
                      title: Text('Equipment'.tr()),
                      subtitle: Row(
                        children: [
                          Text('12.02.2022',
                            style: TextStyle(
                            color: Color(0xff8E8D96),
                          ),)
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: Color(0xffE0FEEC),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${'Vendor'.tr()} 3',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff70CF97),
                            ),
                          ),
                        ),
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
            builder: (context) => UserProfile(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
    }
  }

  BarChartGroupData makeGroupData(
      int x,
      double y,
      ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x >= 4 ? Color(0xff8E8D96) : Color(0xff6A66D1),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
          width: 22,
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff8E8D96),
      fontSize: 14,
    );
    List<String> days = ['Jan'.tr(), 'Feb'.tr(), 'Mar'.tr(), 'Apr'.tr(), 'May'.tr(), 'Jun'.tr(), 'Jul'.tr()];

    Widget text = Text(
      days[value.toInt()],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      maxY: 300.0,
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(
        7,
            (i) => makeGroupData(
          i,
          Random().nextInt(290).toDouble() + 10,
        ),
      ),
      gridData: const FlGridData(show: false),
    );
  }
}
