import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/login.dart';
import 'package:flutter_naqli/Partner/Views/auth/role.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerHelp.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class PartnerHomePage extends StatefulWidget {
  final String mobileNo;
  final String partnerName;
  final String password;
  final String partnerId;
  final String token;
  const PartnerHomePage({super.key, required this.mobileNo, required this.partnerName, required this.password, required this.partnerId, required this.token});

  @override
  State<PartnerHomePage> createState() => _PartnerHomePageState();
}

class _PartnerHomePageState extends State<PartnerHomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: viewUtil.isTablet
            ? MediaQuery.of(context).size.height * 0.05
            : MediaQuery.of(context).size.height * 0.07,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Builder(
              builder: (BuildContext context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Color(0xff5D5151),
                  size: viewUtil.isTablet ? 50 : 45,
                ),
              ),
            ),
          ),
          title: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserHomePage()
                ),
              );
            },
            child: Container(
                margin: EdgeInsets.only(top: viewUtil.isTablet ? 15 : 20),
                child: SvgPicture.asset(
                  'assets/naqlee-logo.svg',
                  fit: BoxFit.fitWidth,
                  height: viewUtil.isTablet ? 45 : 40,
                )),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: PopupMenuButton<Locale>(
                color: Colors.white,
                offset: const Offset(0, 55),
                icon: Icon(Icons.language, color: Colors.blue,size: viewUtil.isTablet ? 35 : 25),
                onSelected: (Locale locale) {
                  context.setLocale(locale);
                },
                itemBuilder: (BuildContext context) {
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
            )
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
                  child: Text('User'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> UserHomePage()));
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> PartnerHelp(
                          partnerName: widget.partnerName,
                          token: widget.token,
                          partnerId: widget.partnerId,
                          email: '',
                      )));
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        double scrollPosition = MediaQuery.sizeOf(context).width * _animationController.value;
                        return Transform.translate(
                          offset: Offset(-scrollPosition, 0),
                          child: SvgPicture.asset(
                            'assets/partnerHome.svg',
                            height: viewUtil.isTablet
                                ? MediaQuery.sizeOf(context).height * 0.35
                                : MediaQuery.sizeOf(context).height * 0.25,
                            width: 1242,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Role()),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sign up now'.tr(),
                          style: TextStyle(
                            color: Color(0xff140303),
                            fontSize: viewUtil.isTablet?35:30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: Color(0xff140303),
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                indent: Checkbox.width,
                endIndent: Checkbox.width,
                color: Color(0xff707070),
                thickness: 3,
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(partnerName: widget.partnerName,mobileNo: widget.mobileNo,password: widget.password,token: widget.token, partnerId: widget.partnerId,)));
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log in'.tr(),
                          style: TextStyle(
                              color: Color(0xff140303),
                              fontSize: viewUtil.isTablet?35:30,
                              fontWeight: FontWeight.w500),
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: Color(0xff140303),
                          size: 40,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                indent: Checkbox.width,
                endIndent: Checkbox.width,
                color: Color(0xff707070),
                thickness: 4,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Driving with naqli'.tr(),
                      style: TextStyle(
                          color: Color(0xff5D5151),
                          fontSize: viewUtil.isTablet?35:30,
                          fontWeight: FontWeight.w500),
                    )),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.3,
                child: ListView(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: viewUtil.isTablet?20 / 9:14 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 0.9,
                      ),
                      items: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: SvgPicture.asset('assets/regular-trips.svg',height: viewUtil.isTablet?35:30)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Regular Trips'.tr(),
                                    style: TextStyle(
                                        fontSize: viewUtil.isTablet?30:25, color: Colors.black),
                                  )),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 20, right: 20),
                                  child: Text(
                                    'With our growing presence across multiple cities, we always have our hands full! This means you will never run out of trips.'.tr(),
                                    style: TextStyle(
                                      color: Color(0xff5D5151),
                                      fontSize: viewUtil.isTablet?25:20,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset('assets/better-earning.svg',height: viewUtil.isTablet?35:30,)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Better Earning'.tr(),
                                    style: TextStyle(
                                      fontSize: viewUtil.isTablet?30:25,
                                    ),
                                  )),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 20, right: 20),
                                  child: Text(
                                    'Earn money by partnering with The best regular trips and efficient service and grow your earnings!'.tr(),
                                    style: TextStyle(
                                      color: Color(0xff5D5151),
                                      fontSize: viewUtil.isTablet?25:20,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset('assets/onTime-payment.svg',height: viewUtil.isTablet?35:30,)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    'On-Time Payments'.tr(),
                                    style: TextStyle(
                                      fontSize: viewUtil.isTablet?30:25,
                                    ),
                                  )),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(top: 20, right: 20),
                                  child: Text(
                                    'Be assured to receive all payments on time & get the best in class support.'.tr(),
                                    style: TextStyle(
                                      color: Color(0xff5D5151),
                                      fontSize: viewUtil.isTablet?25:20,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
