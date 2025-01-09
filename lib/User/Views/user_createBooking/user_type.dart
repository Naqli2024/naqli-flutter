import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_bookingHistory.dart';
import 'package:flutter_naqli/User/Views/user_bookingDetails/user_payment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_paymentStatus.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_editProfile.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_help.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class UserType extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  final String? accountType;
  final String? paymentStatus;
  final String? quotePrice;
  final String? oldQuotePrice;
  const UserType({super.key, required this.firstName, required this.lastName, required this.token, required this.id, this.paymentStatus, this.quotePrice, this.oldQuotePrice, required this.email, this.accountType});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  String _selectedType = '';
  String isFromUserType = '';
  Future<Map<String, dynamic>?>? booking;
  List<Map<String, dynamic>>? partnerData;
  String? partnerId;
  Locale _locale = Locale('en');
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
    booking = _fetchBookingDetails();
  }


  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId == null || token == null) {
      if (widget.id != null && widget.token != null) {
        bookingId = await userService.getPaymentPendingBooking(widget.id, widget.token);

        if (bookingId != null) {
          // await saveBookingId(bookingId,widget.token);
        } else {
          print('No pending booking found, navigating to NewBooking.');
          return null;
        }
      } else {
        print('No userId or token available.');
        return null;
      }
    }

    if (bookingId != null && widget.token != null) {
      return await userService.fetchBookingDetails(bookingId, widget.token);
    } else {
      print('Failed to fetch booking details due to missing bookingId or token.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewBooking(
            token: widget.token,
            firstName: widget.firstName,
            lastName: widget.lastName,
            id: widget.id,
            email: widget.email,
          ),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          userId: widget.id,
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
                      builder: (context) => UserEditProfile(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
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
                  leading: SvgPicture.asset('assets/booking_logo.svg'),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('booking'.tr(),style: TextStyle(fontSize: 25),
              ),
                  ),
                  onTap: ()async {
                    try {
                      final bookingData = await booking;
                      partnerId = bookingData?['partner']??'';
                      if (bookingData != null) {
                        bookingData['paymentStatus']== 'Pending' || bookingData['paymentStatus']== 'NotPaid'
                        ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseVendor(
                              id: widget.id,
                              bookingId: bookingData['_id'] ?? '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : 'N/A'.tr(),
                              unitType: bookingData['unitType'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? 'N/A' : 'N/A',
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : 'N/A'.tr(),
                              unit: bookingData['name'] ?? '',
                              pickup: bookingData['pickup'] ?? '',
                              dropPoints: bookingData['dropPoints'] ?? [],
                              token: widget.token,
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: _selectedType,
                              cityName: bookingData['cityName'] ?? '',
                              address: bookingData['address'] ?? '',
                              zipCode: bookingData['zipCode'] ?? '',
                              email: widget.email,
                            ),
                          ),
                        )
                        : bookingData['paymentStatus']== 'HalfPaid'
                        ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PendingPayment(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: _selectedType,
                              token: widget.token,
                              unit: bookingData['name'] ?? '',
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : '',
                              bookingId: bookingData['_id'] ?? '',
                              unitType: bookingData['unitType'] ?? '',
                              pickup: bookingData['pickup'] ?? '',
                              dropPoints: bookingData['dropPoints'] ?? [],
                              cityName: bookingData['cityName'] ?? '',
                              address: bookingData['address'] ?? '',
                              zipCode: bookingData['zipCode'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                              id: widget.id,
                              partnerName: '',
                              partnerId: bookingData['partner'] ?? '',
                              oldQuotePrice: widget.oldQuotePrice??'',
                              paymentStatus: bookingData['paymentStatus'] ?? '',
                              quotePrice: widget.quotePrice??'',
                              advanceOrPay: bookingData['remainingBalance'] ?? 0,
                              bookingStatus: bookingData['bookingStatus'] ?? '',
                              email: widget.email,
                            )
                          ),
                        )
                        : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentCompleted(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: _selectedType,
                              token: widget.token,
                              unit: bookingData['name'] ?? '',
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : '',
                              bookingId: bookingData['_id'] ?? '',
                              unitType: bookingData['unitType'] ?? '',
                              pickup: bookingData['pickup'] ?? '',
                              dropPoints: bookingData['dropPoints'] ?? [],
                              cityName: bookingData['cityName'] ?? '',
                              address: bookingData['address'] ?? '',
                              zipCode: bookingData['zipCode'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                              id: widget.id,
                              partnerId: bookingData['partner'] ?? '',
                              bookingStatus: bookingData['bookingStatus'] ?? '',
                              email: widget.email,
                            )
                          ),
                        );
                      } else {
                        if (bookingData == null)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewBooking(token: widget.token, firstName: widget.firstName, lastName: widget.lastName, id: widget.id,email: widget.email,)
                          ),
                        );
                      }
                    } catch (e) {
                      // Handle errors here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error fetching booking details: $e')),
                      );
                    }
                  }
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/booking_history.svg',
                      height: viewUtil.isTablet
                      ? MediaQuery.of(context).size.height * 0.028
                      : MediaQuery.of(context).size.height * 0.035),
                  title: Padding(
                    padding: EdgeInsets.only(left: viewUtil.isTablet ?5:10),
                    child: Text('booking_history'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingHistory(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                      ),
                    );
                  }
              ),
              ListTile(
                  leading: SvgPicture.asset('assets/payment_logo.svg'),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('payment'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Payment(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,quotePrice: widget.quotePrice??'',email: widget.email,),
                      ),
                    );
                  }
              ),
              ListTile(
                  leading: Icon(Icons.account_balance_outlined,size: 35,),
                  title: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Invoice'.tr(),style: TextStyle(fontSize: 25),),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInvoice(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,email: widget.email,),
                      ),
                    );
                  }
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 20,bottom: 10,top: 15),
                child: Text('more_info_and_support'.tr(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
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
                      MaterialPageRoute(builder: (context)=>
                          UserHelp(firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  token: widget.token,
                                  id: widget.id,
                                  email: widget.email
                          )));
                },
              ),
              ListTile(
                leading: Icon(Icons.phone,size: 30,color: Color(0xff707070),),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('contact_us'.tr(),style: TextStyle(fontSize: 25),),
                ),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>
                          PaymentPage(checkoutId: '', integrity: '',)));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout,color: Colors.red,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('logout'.tr(),style: TextStyle(fontSize: 25,color: Colors.red),),
                ),
                onTap: () {
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
                          content: Container(
                            width: viewUtil.isTablet
                                ? MediaQuery.of(context).size.width * 0.6
                                : MediaQuery.of(context).size.width,
                            height: viewUtil.isTablet
                                ? MediaQuery.of(context).size.height * 0.08
                                : MediaQuery.of(context).size.height * 0.1,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 30,bottom: 10),
                                  child: Text(
                                    'are_you_sure_you_want_to_logout'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?27:19),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('yes'.tr(),
                                style: TextStyle(fontSize: viewUtil.isTablet?22:16),),
                              onPressed: () async {
                                await clearUserData();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserLogin()),
                                );
                              },
                            ),
                            TextButton(
                              child: Text('no'.tr(),
                                  style: TextStyle(fontSize: viewUtil.isTablet?22:16)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
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
                              fontSize: viewUtil.isTablet ? 30 : 15,
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
                    padding: viewUtil.isTablet
                        ? EdgeInsets.fromLTRB(20,20,20,MediaQuery.sizeOf(context).height * 0.13)
                        : EdgeInsets.fromLTRB(12,5,12,MediaQuery.sizeOf(context).height * 0.13),
                    child: GridView.builder(
                      itemCount: cardData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: viewUtil.isTablet ? 3.5 / 3.2 : 2.8 / 3.2,
                      ),
                      itemBuilder: (context, index) {
                        final item = cardData[index];
                        return GestureDetector(
                          onTap: () {
                              item['title'] != 'Others'
                                  ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateBooking(
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
                                    builder: (context) => SuccessScreen(
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
                                      Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ))
                                    : Padding(
                                      padding: EdgeInsets.only(bottom: viewUtil.isTablet?15:0),
                                      child: Image.asset(
                                             item['asset']!,
                                        height: viewUtil.isTablet
                                            ? MediaQuery.sizeOf(context).height * 0.1
                                            : MediaQuery.sizeOf(context).height * 0.12,
                                             fit: BoxFit.contain,
                                      ),
                                    ),
                                SizedBox(height: 7),
                                Divider(
                                  indent: viewUtil.isTablet ? 15 : 7,
                                  endIndent: viewUtil.isTablet ? 15 : 7,
                                  color: Color(0xffACACAD),
                                  thickness: viewUtil.isTablet ? 1.5 : 0.8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text(
                                    item['title']!.tr(),
                                    textDirection: ui.TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: viewUtil.isTablet ? 25 : 16),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: viewUtil.isTablet ? 25 : 17),),
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
    ViewUtil viewUtil = ViewUtil(context);
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
                            style: TextStyle(fontSize: viewUtil.isTablet ? 25 : 16, fontWeight: FontWeight.bold),
                          ),
                          Text('please_select_service'.tr(),
                              style: TextStyle(
                              fontSize: viewUtil.isTablet ? 20 : 16)),
                          bottomCard('assets/vehicle.svg', 'Vehicle'.tr(),'vehicle'),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateBooking(
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
                                      child: Image.asset('assets/bus.png', width: viewUtil.isTablet ? 130:100, height: viewUtil.isTablet ? 90:80),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Text('Bus'.tr(), style: TextStyle(fontSize: viewUtil.isTablet ? 25 : 17)),
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
    ViewUtil viewUtil = ViewUtil(context);
    return GestureDetector(
      onTap: (){
        userType != 'others'
        ? Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateBooking(
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
              builder: (context) => SuccessScreen(
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
                child: SvgPicture.asset(imagePath, width: viewUtil.isTablet ? 130:90, height: viewUtil.isTablet ? 90:70),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(title, style: TextStyle(fontSize: viewUtil.isTablet ? 25 : 17)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



