import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepTwo.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              color: Color(0xff5D5151),
              size: 45,
            ),
          ),
        ),
        title: SvgPicture.asset(
          'assets/naqlee-logo.svg',
          fit: BoxFit.fitWidth,
          height: 40,
        ),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserLogin(),
                    ),
                  );
                },
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right,
                color: Color(0xff5D5151),
                size: 15,
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person,
                    color: Color(0xff5D5151),
                    size: 30,
                  )),
              Stack(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications,
                        color: Color(0xff6A66D1),
                        size: 30,
                      )),
                  Positioned(
                    right: 10,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
              leading: Icon(FontAwesomeIcons.userGroup),
              title: const Padding(
                padding: EdgeInsets.only(left: 15,top: 5),
                child: Text('Partner',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> PartnerHomePage(mobileNo: '', partnerName: '', password: '', partnerId: '', token: '')));
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.car),
              title: const Padding(
                padding: EdgeInsets.only(left: 15,top: 5),
                child: Text('Driver',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverLogin()));
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.phone),
              title: const Padding(
                padding: EdgeInsets.only(left: 15,top: 5),
                child: Text('Contact us',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.handsHelping),
              title: const Padding(
                padding: EdgeInsets.only(left: 15,top: 5),
                child: Text('Help',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
              ),
              onTap: () {

              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.2,
              decoration: const BoxDecoration(
                color: Color(0xff6A66D1),
              ),
              /*child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.2,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 14 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        viewportFraction: 0.9,
                      ),
                      items: [
                        Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                child: Image.asset('assets/Truck.jpg')),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                child: Image.asset('assets/Earnings.jpg')),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                child: Image.asset('assets/Payments.jpg')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),*/
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20,left: 35,right: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserLogin(),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xffACACAD), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SvgPicture.asset('assets/vehicle.svg'),
                            const Divider(
                              indent: 7,
                              endIndent: 7,
                              color: Color(0xffACACAD),
                              thickness: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: const Text(
                                'Vehicle',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.sizeOf(context).width * 0.09),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserLogin(),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xffACACAD), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.asset('assets/bus.png'),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 18),
                              child: Divider(
                                indent: 7,
                                endIndent: 7,
                                color: Color(0xffACACAD),
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: const Text(
                                'Bus',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserLogin(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15,left: 35,right: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xffACACAD), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SvgPicture.asset('assets/equipment.svg',height: MediaQuery.sizeOf(context).height * 0.12,),
                            const Divider(
                              indent: 7,
                              endIndent: 7,
                              color: Color(0xffACACAD),
                              thickness: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: const Text(
                                'Equipment',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.09),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserLogin(),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Color(0xffACACAD), width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SvgPicture.asset('assets/special.svg',height: MediaQuery.sizeOf(context).height * 0.12),
                              const Divider(
                                indent: 7,
                                endIndent: 7,
                                color: Color(0xffACACAD),
                                thickness: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: const Text(
                                  'Special',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin:  EdgeInsets.only(left: 35, top: 15,bottom: MediaQuery.sizeOf(context).height * 0.12),
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserLogin(),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.36,
                  // height: MediaQuery.sizeOf(context).height * 0.21,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xffACACAD), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SvgPicture.asset('assets/others.svg'),
                          const Divider(
                            indent: 7,
                            endIndent: 7,
                            color: Color(0xffACACAD),
                            thickness: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: const Text(
                              'Others',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
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
      ),
        floatingActionButton: Container(
          margin: EdgeInsets.only(left: 30,right: 0),
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * 0.07,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff6069FF),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
              onPressed: (){
                _showModalBottomSheet(context);
              },child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Get an estimate',
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.arrow_forward,color: Colors.white,),
                )
              ],
            ),
          ),
              ),
        ),
    );
  }
}
void _showModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.70,
        minChildSize: 0,
        maxChildSize: 0.75,
        builder: (BuildContext context, ScrollController scrollController) {
          return  Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            width: MediaQuery.sizeOf(context).width,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'How may we assist you?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text('Please select a service so that we can assist you'),
                      bottomCard('assets/vehicle.svg', 'Vehicle'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                      side: const BorderSide(
                        color: Color(0xffE0E0E0), // Border color
                        width: 1, // Border width
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/bus.png', width: 90, height: 70),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50),
                          child: Text('Bus', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                ),
                      bottomCard('assets/equipment.svg', 'Equipment'),
                      bottomCard('assets/special.svg', 'Special'),
                      bottomCard('assets/others.svg', 'Others'),
                    ],
                  ),
                  Positioned(
                    top: -15,
                    right: -10,
                    child: IconButton(
                        alignment: Alignment.topRight,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(FontAwesomeIcons.multiply)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget bottomCard(String imagePath, String title) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        side: const BorderSide(
          color: Color(0xffE0E0E0), // Border color
          width: 1, // Border width
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(imagePath, width: 90, height: 70),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(title, style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    ),
  );
}
