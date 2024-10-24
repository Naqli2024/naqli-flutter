import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SingleUserHomePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const SingleUserHomePage({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<SingleUserHomePage> createState() => _SingleUserHomePageState();
}

class _SingleUserHomePageState extends State<SingleUserHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();
  int? touchedSectionIndex;
  List<Color> gradientColors = [
    AppColors.contentColorRed,
    AppColors.contentColorGreen,
  ];
  bool showAvg = false;
  String selectedDuration = 'Weekly';
  bool showCompletedData = false;
  bool showPendingData = false;

  String getSectionTitle(int index) {
    switch (index) {
      case 0:
        return "25%\nHalf Paid";
      case 1:
        return "35%\nCompleted";
      case 2:
        return "45%\nPaid";
      case 3:
        return "15%\nPending";
      default:
        return "29% \nCompleted Successfully";
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 16,
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

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Changed to true to show left titles
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          color: Colors.green,
          // gradient: LinearGradient(
          //   colors: [Colors.blue, Colors.green],
          // ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffEBE7FF),
                Color(0xffB6A3FF),
                Color(0xffB6A3FF),
                Color(0xffEBE7FF),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 1),
            FlSpot(2.6, 3),
            FlSpot(4.9, 1),
            FlSpot(6.8, 4),
            FlSpot(8, 2),
            FlSpot(9.5, 5),
            FlSpot(11, 2),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orangeAccent],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffEBE7FF),
                Color(0xffB6A3FF),
                Color(0xffEBE7FF),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData completedData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Changed to true to show left titles
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          color: Colors.green,
          // gradient: LinearGradient(
          //   colors: [Colors.blue, Colors.green],
          // ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffEBE7FF),
                Color(0xffB6A3FF),
                Color(0xffB6A3FF),
                Color(0xffEBE7FF),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData pendingData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false, // Changed to true to show left titles
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xffF5F3FF)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 1),
            FlSpot(2.6, 3),
            FlSpot(4.9, 1),
            FlSpot(6.8, 4),
            FlSpot(8, 2),
            FlSpot(9.5, 5),
            FlSpot(11, 2),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.red, Colors.red],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Color(0xffEBE7FF),
                Color(0xffB6A3FF),
                Color(0xffEBE7FF),
              ],
            ),
          ),
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
                          Text('50',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30)),
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
                          Text('25',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30),),
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
                          Text('25',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 30)),
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
                autoPlay: true,
                aspectRatio: 10 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 1,
              ),
              items: [
                Container(
                  // height: MediaQuery.sizeOf(context).height * 0.4,
                  padding: const EdgeInsets.fromLTRB(8,12,8,10),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 3.0,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            startDegreeOffset: 250,
                            sectionsSpace: 0,
                            centerSpaceRadius: 100,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                                setState(() {
                                  if (event is! PointerUpEvent && event is! PointerExitEvent) {
                                    if (response != null && response.touchedSection != null) {
                                      touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                                    }
                                  } else {
                                    touchedSectionIndex = 25;
                                  }
                                });
                              },
                            ),
                            sections: [
                              PieChartSectionData(
                                value: 25,
                                color: Color(0xffC968FF),
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 35,
                                color: Color(0xff70CF97),
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 45,
                                color: Color(0xff7F6AFF),
                                radius: 45,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 15,
                                color: Color(0xffED5A6B),
                                radius: 30,
                                showTitle: false,
                              ),
                            ],
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
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        contentPadding: const EdgeInsets.all(0), // Remove default padding
                                        content: Container(
                                          width: MediaQuery.sizeOf(context).width,
                                          height: MediaQuery.sizeOf(context).height * 0.5,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    PieChart(
                                                      PieChartData(
                                                        startDegreeOffset: 250,
                                                        sectionsSpace: 0,
                                                        centerSpaceRadius: 80, // Adjust if needed
                                                        pieTouchData: PieTouchData(
                                                          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                                                            setState(() {
                                                              if (event is! PointerUpEvent && event is! PointerExitEvent) {
                                                                if (response != null && response.touchedSection != null) {
                                                                  touchedSectionIndex = response.touchedSection!.touchedSectionIndex;
                                                                }
                                                              } else {
                                                                touchedSectionIndex = null; // Reset if not touching
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        sections: [
                                                          PieChartSectionData(
                                                            value: 25,
                                                            color: Color(0xffC968FF),
                                                            radius: 20,
                                                            showTitle: false,
                                                          ),
                                                          PieChartSectionData(
                                                            value: 35,
                                                            color: Color(0xff70CF97),
                                                            radius: 25,
                                                            showTitle: false,
                                                          ),
                                                          PieChartSectionData(
                                                            value: 45,
                                                            color: Color(0xff7F6AFF),
                                                            radius: 45,
                                                            showTitle: false,
                                                          ),
                                                          PieChartSectionData(
                                                            value: 15,
                                                            color: Color(0xffED5A6B),
                                                            radius: 30,
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
                                                              child: Text(
                                                                touchedSectionIndex != null
                                                                    ? getSectionTitle(touchedSectionIndex!)
                                                                    : "29% \nCompleted Successfully",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 20),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
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
                                                            padding: const EdgeInsets.all(3),
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
                                                    Padding(
                                                      padding: const EdgeInsets.all(3),
                                                      child: Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor: Color(0xff7F6AFF),
                                                            minRadius: 6,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(3),
                                                            child: Text(
                                                              'Paid',
                                                              style: TextStyle(
                                                                fontSize: 16,
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
                                                            padding: const EdgeInsets.all(3),
                                                            child: Text(
                                                              'Half Paid',
                                                              style: TextStyle(
                                                                fontSize: 16,
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
                                                            backgroundColor: Color(0xffED5A6B),
                                                            minRadius: 6,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(3),
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
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                    child: Text(
                                      touchedSectionIndex != null
                                          ? getSectionTitle(touchedSectionIndex!)
                                          : "29% \nCompleted Successfully",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                ),
                Container(
                  // height: MediaQuery.sizeOf(context).height * 0.4,
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 3.0,
                    child: Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 0,
                              left: 0,
                              top: MediaQuery.sizeOf(context).height * 0.15,
                              bottom: 0,
                            ),
                            child: LineChart(
                              showCompletedData
                                  ? completedData()
                                  : showPendingData
                                  ? pendingData()
                                  : mainData(),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 20,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                if (showCompletedData) {
                                  showCompletedData = false;
                                  showPendingData = false;
                                } else {
                                  showCompletedData = true;
                                  showPendingData = false;
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
                          top: 40,
                          left: MediaQuery.sizeOf(context).width * 0.35,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                if (showPendingData) {
                                  showPendingData = false;
                                  showCompletedData = false;
                                } else {
                                  showPendingData = true;
                                  showCompletedData = false;
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
                          top: 40,
                          right: 20,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                                decoration: BoxDecoration(
                                  color: Color(0xffF6F6F6),
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8),
                                    child: DropdownButton<String>(
                                      value: selectedDuration,
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      items: <String>['Weekly', 'Monthly', 'Yearly']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedDuration = newValue!;
                                          // Add logic to update the chart data based on the selected duration
                                        });
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
                    backgroundColor: const Color(0xff6A66D1),
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
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey,width: 1)
                    ),
                  ),
                  onPressed: () {

                  },
                  child: const Text(
                    'Trigger Booking',
                    style: TextStyle(
                        color: Colors.black,
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
            Column(
              children: [
                SvgPicture.asset('assets/booking_manager.svg'),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('Booking manager'),
                ),
              ],
            ),
            Column(
              children: [
                SvgPicture.asset('assets/payment.svg'),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('Payment'),
                ),
              ],
            ),
            Column(
              children: [
                SvgPicture.asset('assets/profile.svg'),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppColors {
  static const Color contentColorRed = Colors.red; // Example color
  static const Color contentColorGreen = Colors.green; // Example color
  static const Color mainGridLineColor = Color(0xffB6A3FF); // Example color
}