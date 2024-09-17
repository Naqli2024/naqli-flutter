import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notified.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_productReached.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DroppingProduct extends StatefulWidget {
  const DroppingProduct({super.key});

  @override
  State<DroppingProduct> createState() => _DroppingProductState();
}

class _DroppingProductState extends State<DroppingProduct> {
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
                                        MaterialPageRoute(builder: (context) => ProductReached()));
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
                      height: MediaQuery.sizeOf(context).height * 0.17,
                      child: Card(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30,right: 50),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset('assets/upArrow.svg'),
                                        Text('800 ft',style: TextStyle(fontSize: 20,color: Color(0xff676565),)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text('Xxxxxxxxx'),
                                      Text('Towards'),
                                      Text('   Xxxxxxxxx'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              indent: 15,
                              endIndent: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on,color: Color(0xff6069FF),),
                                Column(
                                  children: [
                                    Text('Xxxxxxxxx'),
                                    Text('Xxxxxxxxx'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                ),
                Positioned(
                  bottom: 20,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15,right: 30,top: 70),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.93,
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20,top: 35,bottom: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.call,color: Color(0xff6069FF),),
                                        Icon(Icons.message,color: Color(0xff6069FF),),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text('Dropping of Product',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.sizeOf(context).height * 0.18,
                        bottom: MediaQuery.sizeOf(context).height * 0.09,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset('assets/person.svg'),
                        ),
                      ),
                    ],
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
