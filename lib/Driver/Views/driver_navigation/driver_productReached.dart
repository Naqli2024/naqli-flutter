import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_completeOrder.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_droppingProduct.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProductReached extends StatefulWidget {
  const ProductReached({super.key});

  @override
  State<ProductReached> createState() => _ProductReachedState();
}

class _ProductReachedState extends State<ProductReached> {
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
                                        MaterialPageRoute(builder: (context) => CompleteOrder()));
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
                                    padding: const EdgeInsets.only(left: 50,right: 50,top: 20),
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
                  child:
                      Padding(
                        padding: const EdgeInsets.only(left: 15,right: 30),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.93,
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10,top: 5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                     Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Text('1 min',style: TextStyle(fontSize: 20,color: Color(0xff676565))),
                                     ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset('assets/person.svg'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('0 ft',style: TextStyle(fontSize: 20,color: Color(0xff676565))),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
