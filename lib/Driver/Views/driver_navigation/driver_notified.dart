import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_droppingProduct.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerNotified extends StatefulWidget {
  const CustomerNotified({super.key});

  @override
  State<CustomerNotified> createState() => _CustomerNotifiedState();
}

class _CustomerNotifiedState extends State<CustomerNotified> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
          context,
          showLeading: false
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.93,
                  child: const GoogleMap(initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0),  // Default position
                    zoom: 1,
                  ),),
                ),
                Positioned(
                    top: 15,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                  onPressed: (){
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => DroppingProduct()));
                                  },
                                  icon: Icon(FontAwesomeIcons.multiply)),
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    top: MediaQuery.sizeOf(context).height * 0.1,
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      width: MediaQuery.sizeOf(context).width * 0.92,
                      height: MediaQuery.sizeOf(context).height * 0.13,
                      child: Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50,right: 50,top: 15),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset('assets/notified.svg'),
                                        Text('0 ft'),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text('XXXXXXXXX',style: TextStyle(fontSize: 16,color: Color(0xff676565))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
                Positioned(
                  bottom: 20,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15,right: 30),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.93,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Customer Notified',style: TextStyle(fontSize: 24,color: Color(0xff676565),
                                ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Angel',style: TextStyle(fontSize: 24,color: Color(0xff676565),
                                ),
                                                              ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20,right:20,bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.call,color: Color(0xff6069FF),),
                                    Icon(Icons.message,color: Color(0xff6069FF),),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
}
