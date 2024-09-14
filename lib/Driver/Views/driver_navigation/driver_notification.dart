import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriverNotification extends StatefulWidget {
  const DriverNotification({super.key});

  @override
  State<DriverNotification> createState() => _DriverNotificationState();
}

class _DriverNotificationState extends State<DriverNotification> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Container(
    //     decoration: BoxDecoration(
    //     image: DecorationImage(
    //     image: AssetImage('assets/images/background.jpg'), // Replace with your image path
    // fit: BoxFit.cover, // Fit the image to cover the entire background
    // )),
      child: Scaffold(
        backgroundColor: Color(0xffE6E5E3),
        appBar: AppBar(
          backgroundColor: Color(0xffE6E5E3),
          toolbarHeight: MediaQuery.of(context).size.height * 0.15,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
              child: Icon(Icons.arrow_back_outlined)
          ),
          title: Text('Radar'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30,right: 30),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset('assets/naqleeBorder.svg'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye,color: Color(0xff6069FF),),
                                  Text('5',style: TextStyle(color: Color(0xff6069FF),fontSize: 20 ),)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                            child: Text('SAR 70.5',style: TextStyle(fontSize: 40 ),)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded,color: Color(0xff6069FF),size: 30,),
                            Text(' 4.88',style: TextStyle(fontSize: 20 ),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8,top: 8,bottom: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                SvgPicture.asset('assets/direction.svg',height: MediaQuery.of(context).size.height * 0.13,),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('8 mins(2.5mi)away',style: TextStyle(fontSize: 20 ),),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text('Xxxxxxxxx',style: TextStyle(fontSize: 20 ),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text('9 mins(2.50mi)left',style: TextStyle(fontSize: 20 ),),
                                  ),
                                  Text('Xxxxxxxxx',style: TextStyle(fontSize: 20 ),),
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
              padding: const EdgeInsets.only(top: 35),
              child: Text('We’ll let you know when there\nIs a request',style: TextStyle(fontSize: 17 )),
            )
          ],
        ),
      ),
    );
  }
}
