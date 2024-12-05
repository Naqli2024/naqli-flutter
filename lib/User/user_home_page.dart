import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Driver/driver_home_page.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepTwo.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_otp.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();

  final List<Map<String, String>> cardData = [
    {'title': 'Vehicle', 'asset': 'assets/vehicle.svg'},
    {'title': 'Bus', 'asset': 'assets/bus.png'},
    {'title': 'Equipment', 'asset': 'assets/equipment.svg'},
    {'title': 'Special', 'asset': 'assets/special.svg'},
    {'title': 'Others', 'asset': 'assets/others.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
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
                  child: Text(
                    'Sign in'.tr(),
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
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: PopupMenuButton<Locale>(
                        color: Colors.white,
                        offset: const Offset(0, 55),
                        icon: Icon(Icons.language, color: Colors.blue),
                        onSelected: (Locale locale) {
                          context.setLocale(locale);
                        },
                        itemBuilder: (BuildContext context) {
                          Locale currentLocale = context.locale;
                          return <PopupMenuEntry<Locale>>[
                            PopupMenuItem(
                              value: Locale('en', 'US'),
                              child: Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      'English'.tr(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: Locale('ar', 'SA'),
                              child: Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      'Arabic'.tr(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: Locale('hi', 'IN'),
                              child: Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      'Hindi'.tr(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
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
                title: Padding(
                  padding: EdgeInsets.only(left: 15,top: 5),
                  child: Text('Partner'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> PartnerHomePage(mobileNo: '', partnerName: '', password: '', partnerId: '', token: '')));
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.car),
                title: Padding(
                  padding: EdgeInsets.only(left: 15,top: 5),
                  child: Text('Driver'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverLogin()));
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.phone),
                title: Padding(
                  padding: EdgeInsets.only(left: 15,top: 5),
                  child: Text('Contact us'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                ),
                onTap: () {

                },
              ),
              ListTile(
                leading: SvgPicture.asset('assets/help_logo.svg'),
                title: Padding(
                  padding: EdgeInsets.only(left: 13,top: 5),
                  child: Text('Help'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=> UserHelp()));
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 20 / 10,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 1.2,
                  ),
                  items: [
                    Container(width: MediaQuery.sizeOf(context).width * 1,child: SvgPicture.asset('assets/userHome2.svg',fit: BoxFit.fill)),
                    Container(width: MediaQuery.sizeOf(context).width * 1,child: SvgPicture.asset('assets/userHome3.svg',fit: BoxFit.fill)),
                    Container(width: MediaQuery.sizeOf(context).width * 1,child: SvgPicture.asset('assets/userHome4.svg',fit: BoxFit.fill)),
                    Stack(
                      children: [
                        Container(child: SvgPicture.asset('assets/userHome1.svg',fit: BoxFit.fill,)),
                        Positioned(
                          left: MediaQuery.sizeOf(context).width * 0.3,
                          top: MediaQuery.sizeOf(context).height * 0.08,
                          child: Text(
                            'Drive Your Business Forward \nwith Seamless Vehicle Booking!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(12, 5, 12,MediaQuery.sizeOf(context).height * 0.13,),
                    child: GridView.builder(
                      itemCount: cardData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 2.8 / 3.2,
                      ),
                      itemBuilder: (context, index) {
                        final item = cardData[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserLogin()),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            color: Color(0xffF7F6FF),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xffACACAD), width: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                item['asset']!.endsWith('.svg')
                                    ? SvgPicture.asset(
                                  item['asset']!,
                                  height: MediaQuery.sizeOf(context).height * 0.12,
                                  placeholderBuilder: (context) =>
                                      Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                )
                                    : Image.asset(
                                  item['asset']!,
                                  height: MediaQuery.sizeOf(context).height * 0.12,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 7),
                                const Divider(
                                  indent: 7,
                                  endIndent: 7,
                                  color: Color(0xffACACAD),
                                  thickness: 0.8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    item['title']!.tr(),
                                    textDirection: ui.TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 25,
              left: 10,
              right: 10,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6069FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: (){
                    _showModalBottomSheet(context);
                  },
                  child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text('Get an estimate'.tr(),
                          textDirection: ui.TextDirection.ltr,
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(Icons.arrow_forward,color: Colors.white,),
                      )
                    ],
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.70,
            minChildSize: 0,
            maxChildSize: 0.75,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.sizeOf(context).width,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'how_may_we_assist_you'.tr(),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('please_select_service'.tr()),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: cardData.length,
                            itemBuilder: (context, index) {
                              final item = cardData[index];
                              return bottomCard(item['asset']!, item['title']!.tr());
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -15,
                      right: -10,
                      child: IconButton(
                        alignment: Alignment.topRight,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(FontAwesomeIcons.multiply),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
              child: imagePath.endsWith('.svg')
                  ? SvgPicture.asset(imagePath, width: 90, height: 70)
                  : Image.asset(imagePath, width: 90, height: 70),
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
}
