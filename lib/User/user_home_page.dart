import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naqli/Driver/Views/driver_auth/driver_login.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/stepOne.dart';
import 'package:flutter_naqli/Partner/Views/partner_home_page.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/vectorImage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final List<Map<String, String>> cardData = [
    {'title': 'Vehicle', 'asset': 'vehicle.vg'},
    {'title': 'Bus', 'asset': 'bus.vg'},
    {'title': 'Equipment', 'asset': 'equipment.vg'},
    {'title': 'Special', 'asset': 'special.vg'},
    {'title': 'Shipping Cargo', 'asset': 'sharedCargo.vg'},
    {'title': 'Others', 'asset': 'others.vg'},
  ];
  final List<String> carouselAssets = [
    'assets/userHome1.svg',
    'assets/userHome2.svg',
    'assets/userHome3.svg'
  ];
  Locale currentLocale = Locale('en', 'US');
  final _cardBorder = RoundedRectangleBorder(
    side: const BorderSide(color: Color(0xffACACAD), width: 0.5),
    borderRadius: BorderRadius.circular(10),
  );
  final _dividerColor = const Color(0xffACACAD);
  final _cardColor = const Color(0xffF7F6FF);
  final _sizedBoxHeight7 = const SizedBox(height: 7);
  final _paddingTop15 = const EdgeInsets.only(top: 5);
  late final Widget userHome1;
  late final Widget userHome2;
  late final Widget userHome3;
  Map<String, Widget> cachedSvgWidgets = {};

  @override
  void initState() {
    super.initState();
    userHome1 = SvgPicture.asset('assets/userHome1.svg', fit: BoxFit.fill);
    userHome2 = SvgPicture.asset('assets/userHome2.svg', fit: BoxFit.fill);
    userHome3 = SvgPicture.asset('assets/userHome3.svg', fit: BoxFit.fill);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadImages(context);
    });
    precacheSvgImages();
  }

  Future<void> precacheSvgImages() async {
    final allAssets = [
      'assets/userHome1.svg',
      'assets/userHome2.svg',
      'assets/userHome3.svg'];

    for (var asset in allAssets) {
      if (!cachedSvgWidgets.containsKey(asset)) {
        await safePrecacheSvg(asset);
        cachedSvgWidgets[asset] = SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> safePrecacheSvg(String asset) async {
    try {
      final loader = SvgAssetLoader(asset);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
            () => loader.loadBytes(null),
      );
    } catch (e) {
      debugPrint("Error precaching $asset: $e");
    }
  }

  Future<void> preloadImages(BuildContext context) async {
    for (var item in cardData) {
      await MyVectorImage.preload(context, item['asset']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
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
              icon: Icon(
                Icons.menu,
                color: Color(0xff5D5151),
                size: viewUtil.isTablet ? 50 : 40,
              ),
            ),
          ),
          title: SvgPicture.asset(
            'assets/naqlee-logo.svg',
            fit: BoxFit.fitWidth,
            height: viewUtil.isTablet ? 45 : 40,
          ),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserLogin(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign in'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: viewUtil.isTablet ? 20 : 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xff5D5151),
                  size: viewUtil.isTablet ? 25 : 15,
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.person,
                      color: Color(0xff5D5151),
                      size: viewUtil.isTablet ? 35 : 25,
                    )),
                Stack(
                  children: [
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: PopupMenuButton<Locale>(
                        color: Colors.white,
                        offset: const Offset(0, 55),
                        icon: Icon(
                          Icons.language,
                          color: Color(0xff7f6bf6),
                          size: viewUtil.isTablet ? 35 : 25,
                        ),
                        onSelected: (Locale locale) {
                          setState(() {
                            currentLocale = locale;
                            context.setLocale(locale);
                          });
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
                                      style: TextStyle(
                                          fontSize:
                                              viewUtil.isTablet ? 20 : 14),
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
                                      style: TextStyle(
                                          fontSize:
                                              viewUtil.isTablet ? 20 : 14),
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
                                      style: TextStyle(
                                          fontSize:
                                              viewUtil.isTablet ? 20 : 14),
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                            child: Icon(FontAwesomeIcons.multiply)))
                  ],
                ),
              ),
              const Divider(),
              Container(
                color: Color(0xffE5EBF8),
                child: ListTile(
                    leading: Icon(Icons.person, size: 30),
                    title: Padding(
                      padding: EdgeInsets.only(left: 7),
                      child: Text(
                        'User'.tr(),
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    }),
              ),
              ListTile(
                leading: Icon(Icons.people, size: 30),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text(
                    'Partner'.tr(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PartnerHomePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.drive_eta_rounded, size: 30),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text(
                    'Driver'.tr(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => DriverLogin()));
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline, size: 30),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text(
                    'Help'.tr(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserHelp()));
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
                    enlargeCenterPage: false,
                    autoPlay: true,
                    aspectRatio: 20 / 10,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 1,
                  ),
                  items: [
                    commonWidgets.buildCarouselItem(
                      context,
                      svgWidget: userHome1,
                      text: '${'For Tough job,Trust Our Heavy Duty'.tr()}\n${'Trucks - Your First Choice'.tr()}',
                      alignRight: true,
                    ),
                    commonWidgets.buildCarouselItem(
                      context,
                      svgWidget: userHome2,
                      text: '${'The Best Bus Service Awaits'.tr()}\n${'Ride with us, Travel better'.tr()}',
                    ),
                    commonWidgets.buildCarouselItem(
                      context,
                      svgWidget: userHome3,
                      text: '${'Choose us for Fast,'.tr()}\n${'Reliable freight Delivery,'.tr()}\n${'Every Time'.tr()}',
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: viewUtil.isTablet
                        ? EdgeInsets.fromLTRB(20, 20, 20, screenHeight * 0.13)
                        : EdgeInsets.fromLTRB(12, 5, 12, screenHeight * 0.13),
                    child: GridView.builder(
                      itemCount: cardData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 16,
                        childAspectRatio: viewUtil.isTablet ? 3.5 / 3.2 : 2.8 / 3,
                      ),
                      itemBuilder: (context, index) {
                        final item = cardData[index];
                        final svgHeight = screenHeight * 0.12;
                        final isTablet = viewUtil.isTablet;
                        final dividerIndent = isTablet ? 15.0 : 7.0;
                        final dividerThickness = isTablet ? 1.5 : 0.8;
                        final titleFontSize = isTablet ? 25.0 : 16.0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserLogin()));
                          },
                          child: Card(
                            elevation: 3,
                            color: _cardColor,
                            shape: _cardBorder,
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RepaintBoundary(
                                child:  MyVectorImage( name: item['asset']??'', height: svgHeight)
                              ),
                              _sizedBoxHeight7,
                              Divider(
                                indent: dividerIndent,
                                endIndent: dividerIndent,
                                color: _dividerColor,
                                thickness: dividerThickness,
                              ),
                              Padding(
                                padding: _paddingTop15,
                                child: Text(
                                  item['title']!.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: titleFontSize),
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
              left: viewUtil.isTablet ? 20 : 10,
              right: viewUtil.isTablet ? 20 : 10,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7f6bf6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    _showModalBottomSheet(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'Get an estimate'.tr(),
                            textDirection: ui.TextDirection.ltr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: viewUtil.isTablet ? 25 : 17),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
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
    ViewUtil viewUtil = ViewUtil(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.90,
                  minChildSize: 0,
                  maxChildSize: 0.95,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.sizeOf(context).width,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                          color: Color(0xff707070),
                                          width: 1,
                                        ),
                                      ),
                                      color: Colors.white,
                                      shadowColor: Colors.black,
                                      elevation: 3.0,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20, top: 20),
                                            child: Text(
                                              'Contact Us For Estimate Details'
                                                  .tr(),
                                              style: TextStyle(
                                                  fontSize: viewUtil.isTablet
                                                      ? 25
                                                      : 20,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          estimateTextField(
                                              'Name'.tr(), nameController),
                                          estimateTextField('Mobile no'.tr(),
                                              mobileNoController),
                                          estimateTextField('Email Id'.tr(),
                                              emailIdController),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 30),
                                            child: SizedBox(
                                              height: viewUtil.isTablet
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.06
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.07,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xff0022CC),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await userService
                                                      .postGetAnEstimate(
                                                          context,
                                                          name: nameController
                                                              .text,
                                                          email:
                                                              emailIdController
                                                                  .text,
                                                          mobile:
                                                              mobileNoController
                                                                  .text);
                                                },
                                                child: Text(
                                                  'Submit'.tr(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: viewUtil.isTablet
                                                        ? 23
                                                        : 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Get an estimate'.tr(),
                                          style: TextStyle(
                                              fontSize:
                                                  viewUtil.isTablet ? 25 : 20,
                                              fontWeight: FontWeight.w500))),
                                ),
                                Text(
                                    'Naqlee is an online portal that specializes in logistics, machinery rentals, and transportation services. It connects businesses and individuals to freight and machinery services, allowing for efficient shipping and delivery.'
                                        .tr()),
                                Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 20),
                                  child: Text(
                                      "The 'Exclusive Quote on Request' feature provides consumers with personalized pricing depending on their specific transportation requirements, resulting in tailored solutions rather than fixed rates. This functionality is advantageous to firms who want personalized logistical services."
                                          .tr()),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: -15,
                            right: -10,
                            child: IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                FontAwesomeIcons.multiply,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget estimateTextField(
    String label,
    TextEditingController controller,
  ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
          alignment: Alignment.topLeft,
          child: Text(
            label,
            style: TextStyle(
              fontSize: viewUtil.isTablet ? 20 : 15,
              color: Color(0xff707070),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xffBCBCBC), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

