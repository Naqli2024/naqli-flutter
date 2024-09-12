import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.78,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  onPressed: (){},
                                  icon: Icon(Icons.menu)),
                            ),
                          ),
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
                                  onPressed: (){},
                                  icon: Icon(Icons.search)),
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 30,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff6069FF),
                          width: 6,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          minRadius: 45,
                          maxRadius: double.maxFinite,
                          backgroundColor: Color(0xff6069FF),
                          child: Text(
                            'Move',
                            style: TextStyle(color: Colors.white,fontSize: 20),
                          )
                        ),
                      ),
                    )),
              ],
            ),
            // Container(
            //   margin: const EdgeInsets.only(top:20,bottom: 20),
            //   child: SizedBox(
            //     height: MediaQuery.of(context).size.height * 0.07,
            //     width: MediaQuery.of(context).size.width * 0.45,
            //     child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.white,
            //           shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(10),
            //               side: const BorderSide(color: Color(0xff6069FF))),
            //         ),
            //         onPressed: () {
            //
            //         },
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceAround,
            //           children: [
            //             SvgPicture.asset('assets/car.svg',height: 35),
            //             Text(
            //               'Offline',
            //               style: TextStyle(
            //                   fontSize: 23,color: Colors.black),
            //             ),
            //           ],
            //         )),
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.only(top:20,bottom: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff6069FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xff6069FF))),
                    ),
                    onPressed: () {

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Online',
                          style: TextStyle(
                              fontSize: 23,color: Colors.black),
                        ),
                        SvgPicture.asset('assets/carOnline.svg',height: 35),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
