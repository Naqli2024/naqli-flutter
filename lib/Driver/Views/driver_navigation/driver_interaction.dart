import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notified.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverInteraction extends StatefulWidget {
  const DriverInteraction({super.key});

  @override
  State<DriverInteraction> createState() => _DriverInteractionState();
}

class _DriverInteractionState extends State<DriverInteraction> {
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
                                    MaterialPageRoute(builder: (context) => CustomerNotified()));
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
                                        Text('600 ft',style: TextStyle(fontSize: 20,color: Color(0xff676565),)),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15,right: 30),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.93,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * 0.18),
                                      child: SvgPicture.asset('assets/person.svg'),
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text('Angel',style: TextStyle(fontSize: 24,color: Color(0xff676565),),)),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star_rounded,color: Color(0xff6069FF),size: 25,),
                                  Text(' 4.88',style: TextStyle(fontSize: 17,color: Color(0xff676565)),)
                                ],
                              ),
                              Text('6 mins 2.5mi',style: TextStyle(fontSize: 17,color: Color(0xff676565)),),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right:15,top: 12,bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(Icons.call,color: Color(0xff6069FF),),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text('Call',style: TextStyle(fontSize: 17,color: Color(0xff676565)),),
                                    ),
                                    Icon(Icons.message,color: Color(0xff6069FF),),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text('Message',style: TextStyle(fontSize: 17,color: Color(0xff676565)),),
                                    ),
                                    Icon(FontAwesomeIcons.multiply,color: Color(0xff6069FF),),
                                    Text('Cancel',style: TextStyle(fontSize: 17,color: Color(0xff676565)),),
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
