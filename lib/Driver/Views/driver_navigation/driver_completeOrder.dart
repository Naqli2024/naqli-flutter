import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_navigation/driver_notification.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';

class CompleteOrder extends StatefulWidget {
  const CompleteOrder({super.key});

  @override
  State<CompleteOrder> createState() => _CompleteOrderState();
}

class _CompleteOrderState extends State<CompleteOrder> {
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
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) => DriverHomePage()));
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
                                    padding: const EdgeInsets.only(left: 50,right: 30,top: 20),
                                    child: Column(
                                      children: [
                                        Icon(Icons.location_on,color: Color(0xff6069FF),size: 30,),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('XXXXXXXXX',style: TextStyle(fontSize: 16,color: Color(0xff676565))),
                                        Text('XXXXXXXXX',style: TextStyle(fontSize: 16,color: Color(0xff676565))),
                                      ],
                                    ),
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
                  bottom: 35,
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
                              Divider(
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Angel',style: TextStyle(fontSize: 20,color: Color(0xff676565))),
                              ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 15, top: 20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,  // Adjust height
                              width: MediaQuery.of(context).size.width * 0.62,
                              child: SlideAction(
                                borderRadius: 12,
                                elevation: 0,
                                submittedIcon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                innerColor: Color(0xff6069FF),  // Inner sliding button color
                                outerColor: Color(0xff6069FF),  // Background color
                                sliderButtonIcon: Icon(
                                  Icons.arrow_forward_outlined,
                                  color: Colors.white,
                                ),
                                text: "Complete Order",
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                onSubmit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DriverHomePage()),
                                  );
                                },
                              ),
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
