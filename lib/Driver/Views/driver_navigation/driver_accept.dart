import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_interaction.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notification.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderAccept extends StatefulWidget {
  const OrderAccept({super.key});

  @override
  State<OrderAccept> createState() => _OrderAcceptState();
}

class _OrderAcceptState extends State<OrderAccept> {
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

                                  },
                                  icon: Icon(FontAwesomeIcons.multiply)),
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 30),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.93,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Center(child: SvgPicture.asset('assets/naqleeBorder.svg',height: 35,)),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 35,left: 8),
                                      child: SvgPicture.asset('assets/person.svg',),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text('SAR 70.5',style: TextStyle(fontSize: 35 ),)),
                                  ],
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
                                  padding: const EdgeInsets.only(left: 8,top: 8,bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            Text('8 mins(2.5mi)away',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 0),
                                              child: Text('Xxxxxxxxx',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20),
                                              child: Text('9 mins(2.50mi)left',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                            ),
                                            Text('Xxxxxxxxx',style: TextStyle(fontSize: 20,color: Color(0xff676565)),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.057,
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff6069FF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                            Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => DriverInteraction()));
                                            },
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        )),
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
