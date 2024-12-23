import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/trigger_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class SuperUsertype extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  final String? accountType;
  const SuperUsertype({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email, this.accountType});

  @override
  State<SuperUsertype> createState() => _SuperUsertypeState();
}

class _SuperUsertypeState extends State<SuperUsertype> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  String _selectedType = '';
  String isFromUserType = '';
  Future<Map<String, dynamic>?>? booking;
  List<Map<String, dynamic>>? partnerData;
  String? partnerId;
  final List<Map<String, String>> cardData = [
    {'title': 'Vehicle', 'asset': 'assets/vehicle.svg'},
    {'title': 'Bus', 'asset': 'assets/bus.png'},
    {'title': 'Equipment', 'asset': 'assets/equipment.svg'},
    {'title': 'Special', 'asset': 'assets/special.svg'},
    {'title': 'Others', 'asset': 'assets/others.svg'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          userId: widget.id,
          showLeading: true,
          showLanguage: true,
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person,color: Colors.grey,size: 30),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.firstName +' '+ widget.lastName,
                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      Icon(Icons.edit,color: Colors.grey,size: 20),
                    ],
                  ),
                  subtitle: Text(widget.id,
                    style: TextStyle(color: Color(0xff8E8D96),
                    ),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Divider(),
              ),
              ListTile(
                leading: Icon(Icons.home,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Home'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuperUserHomePage(firstName: widget.firstName, lastName: widget.lastName, token: widget.token, id: widget.id, email: widget.email)
                    ),
                  );
                },
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/booking_logo.svg',
                      height: MediaQuery.of(context).size.height * 0.035),
                  title: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text('Trigger Booking'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TriggerBooking(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        ),
                      ),
                    );
                  }
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/booking_manager.svg'),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Booking Manager'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingManager(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        ),
                      ),
                    );
                  }
              ),
              ListTile(
                leading: SvgPicture.asset('assets/payment.svg'),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Payments'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuperUserPayment(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          email: widget.email
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                  leading: Icon(Icons.account_balance_outlined,size: 35,),
                  title: Text('Invoice'.tr(),style: TextStyle(fontSize: 25),),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInvoice(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                      ),
                    );
                  }
              ),
              ListTile(
                leading: SvgPicture.asset('assets/report_logo.svg'),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('report'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSubmitTicket(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                    ),
                  );
                },
              ),
              ListTile(
                leading: SvgPicture.asset('assets/help_logo.svg'),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text('help'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> UserHelp(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          token: widget.token,
                          id: widget.id,
                          email: widget.email
                      )));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout,color: Colors.red,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('logout'.tr(),style: TextStyle(fontSize: 25,color: Colors.red),),
                ),
                onTap: () {
                  showLogoutDialog();
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
                            item['title'] != 'Others'
                            ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuperUserBooking(
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  selectedType: item['title']!.toLowerCase(),
                                  token: widget.token,
                                  id: widget.id,
                                  email: widget.email,
                                  isFromUserType: 'isFromUserType',
                                  accountType: widget.accountType,
                                ),
                              ),
                            )
                            : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SuperUserMessageScreen(
                                      id: widget.id,
                                      firstName: widget.firstName,
                                      lastName: widget.lastName,
                                      token: widget.token,
                                      Image: 'assets/others.svg',
                                      title: 'Others',
                                      subTitle: 'Sorry,the others section is currently unavailable')
                              ),
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
                                  const CircularProgressIndicator(),
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
                        child: Text('Get an estimate'.tr(),
                          textDirection: ui.TextDirection.ltr,
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
              ),)
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
                          Text(
                            'how_may_we_assist_you'.tr(),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text('please_select_service'.tr()),
                          bottomCard('assets/vehicle.svg', 'Vehicle'.tr(),'vehicle'),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SuperUserBooking(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    selectedType: 'bus',
                                    token: widget.token,
                                    id: widget.id,
                                    email: widget.email,
                                    accountType: widget.accountType,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
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
                                      child: Text('Bus'.tr(), style: TextStyle(fontSize: 20)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          bottomCard('assets/equipment.svg', 'Equipment'.tr(),'equipment'),
                          bottomCard('assets/special.svg', 'Special'.tr(),'special'),
                          bottomCard('assets/others.svg', 'Others'.tr(),'others'),
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
          ),
        );
      },
    );
  }

  Widget bottomCard(String imagePath, String title,String userType) {
    return GestureDetector(
      onTap: (){
        userType != 'others'
        ? Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuperUserBooking(
              firstName: widget.firstName,
              lastName: widget.lastName,
              selectedType: userType,
              token: widget.token,
              id: widget.id,
              email: widget.email,
              accountType: widget.accountType,
            ),
          ),
        )
        : Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuperUserMessageScreen(
                  id: widget.id,
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  Image: 'assets/others.svg',
                  title: 'Others',
                  subTitle: 'Sorry,the others section is currently unavailable')
          ),
        );
      },
      child: Padding(
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
      ),
    );
  }

  void showLogoutDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30,bottom: 10),
                  child: Text(
                    'are_you_sure_you_want_to_logout'.tr(),
                    style: TextStyle(fontSize: 19),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('yes'.tr()),
                onPressed: () async {
                  await clearUserData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserLogin()),
                  );
                },
              ),
              TextButton(
                child: Text('no'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
