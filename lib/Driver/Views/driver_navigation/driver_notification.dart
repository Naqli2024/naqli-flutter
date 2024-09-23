import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverNotification extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final double distanceToPickup;
  final List<double> distanceToDropPoints;
  final String timeToPickup;
  final String timeToDrop;
  const DriverNotification({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.distanceToPickup, required this.distanceToDropPoints, required this.timeToPickup, required this.timeToDrop});

  @override
  State<DriverNotification> createState() => _DriverNotificationState();
}

class _DriverNotificationState extends State<DriverNotification> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Color(0xffE6E5E3).withOpacity(0.1),
              toolbarHeight: MediaQuery.of(context).size.height * 0.15,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_outlined,
                  size: 30,
                ),
              ),
              title: const Text('Radar', style: TextStyle(fontSize: 26)),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    color: Colors.white,
                    elevation: 3.0, // Shadow for the notification card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset('assets/naqleeBorder.svg'),
                              ],
                            ),
                          ),
                          Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'SAR',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '70.5',
                                    style: TextStyle(fontSize: 34),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xff6069FF),
                                  size: 30,
                                ),
                                Text(
                                  ' 4.88',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/direction.svg',
                                      height: MediaQuery.of(context).size.height * 0.13,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.timeToPickup } (${widget.distanceToPickup.toStringAsFixed(2)} km)',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          'Xxxxxxxxx',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      for (int i = 0; i < widget.distanceToDropPoints.length; i++)
                                      Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: Text('${widget.timeToDrop }(${widget.distanceToDropPoints[i].toStringAsFixed(2)} km)',
                                          style: TextStyle(fontSize: 20),),
                                      ),
                                      Text(
                                        'Xxxxxxxxx',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Text(
                    'We’ll let you know when there\nIs a request',
                    style: TextStyle(fontSize: 18,color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: IconButton(
                      onPressed: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> DriverHomePage(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,)));
                      },
                      icon: Icon(Icons.cancel)
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
