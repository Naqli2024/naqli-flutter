import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
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
import 'package:flutter_naqli/User/vectorImage.dart';
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
  final num? quotePrice;
  final num? oldQuotePrice;
  const UserType({super.key, required this.firstName, required this.lastName, required this.token, required this.id, this.paymentStatus, this.oldQuotePrice, required this.email, this.accountType, this.quotePrice});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  String _selectedType = '';
  String isFromUserType = '';
  Future<Map<String, dynamic>?>? booking;
  List<Map<String, dynamic>>? partnerData;
  String? partnerId;
  final List<Map<String, String>> cardData = [
    {'title': 'Vehicle', 'asset': 'vehicle.vg'},
    {'title': 'Bus', 'asset': 'bus.vg'},
    {'title': 'Equipment', 'asset': 'equipment.vg'},
    {'title': 'Special', 'asset': 'special.vg'},
    {'title': 'Shared Cargo', 'asset': 'sharedCargo.vg'},
    {'title': 'Others', 'asset': 'others.vg'},
  ];
  final List<String> carouselAssets = [
    'userHome1.vg',
    'userHome2.vg',
    'userHome3.vg',
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
  late Future<UserDataModel> userData;
  late final Widget userHome1;
  late final Widget userHome2;
  late final Widget userHome3;
  Map<String, Widget> cachedSvgWidgets = {};

  @override
  void initState() {
    super.initState();
    booking = _fetchBookingDetails();
    userData = userService.getUserData(widget.id, widget.token);
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

  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId == null && widget.id != null && widget.token != null) {
      bookingId = await userService.getPaymentPendingBooking(widget.id, widget.token);

      if (bookingId == null || bookingId.isEmpty) {
        bookingId = await userService.getBookingByUserId(widget.id, widget.token);
      }

      if (bookingId == null || bookingId.isEmpty) {
        return null;
      }
    }

    if (bookingId != null && widget.token != null) {
      final bookingDetails = await userService.fetchBookingDetails(bookingId, widget.token);

      if (bookingDetails != null) {
        return bookingDetails;
      } else {
        print("Booking details returned null from API.");
      }
    } else {
      print("Either bookingId or token is null, cannot fetch details.");
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          userId: widget.id,
          currentLocale: currentLocale,
          onLocaleChanged: (Locale locale) {
            setState(() {
              currentLocale = locale;
            });
            context.setLocale(locale);
          }),
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
                child:ListTile(
                  leading: FutureBuilder<UserDataModel>(
                    future: userData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data?.userProfile == null) {
                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: Icon(Icons.person, color: Colors.grey, size: 30),
                        );
                      } else {
                        final user = snapshot.data!;
                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          backgroundImage: NetworkImage(
                            "https://prod.naqlee.com/api/image/${user.userProfile!.fileName}",
                          ),
                        );
                      }
                    },
                  ),
                  title: Text(
                    widget.firstName +' '+ widget.lastName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.id,
                    style: TextStyle(color: Color(0xff8E8D96)),
                  ),
                  trailing: Icon(Icons.edit, color: Colors.grey, size: 20),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Divider(),
              ),
              ListTile(
                leading: SvgPicture.asset('assets/booking_logo.svg'),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('booking'.tr(), style: TextStyle(fontSize: 25)),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                          ),
                            padding: EdgeInsets.symmetric(horizontal: 30,vertical: 30),
                            child: CircularProgressIndicator())),
                  );
                  try {
                    final bookingData = await booking;
                    partnerId = bookingData?['partner'] ?? '';

                    if (bookingData != null) {
                      Navigator.pop(context);
                      if (bookingData['paymentStatus'] == 'Pending' || bookingData['paymentStatus'] == 'NotPaid') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseVendor(
                              id: widget.id,
                              bookingId: bookingData['_id'] ?? '',
                              size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : ''.tr(),
                              unitType: bookingData['unitType'] ?? '',
                              unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? '' : '',
                              load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : ''.tr(),
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
                        );
                      } else if (bookingData['paymentStatus'] == 'HalfPaid') {
                        Navigator.push(
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
                              oldQuotePrice: widget.oldQuotePrice ?? 0,
                              paymentStatus: bookingData['paymentStatus'] ?? '',
                              quotePrice: widget.quotePrice ?? 0,
                              advanceOrPay: bookingData['remainingBalance']??0,
                              bookingStatus: bookingData['bookingStatus'] ?? '',
                              email: widget.email,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
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
                            ),
                          ),
                        );
                      }
                    } else {
                      Navigator.pop(context);
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
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    commonWidgets.showToast('Error fetching booking details: $e');
                  }
                },
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
                        builder: (context) => Payment(firstName: widget.firstName,lastName: widget.lastName,token: widget.token,id: widget.id,quotePrice: widget.quotePrice??0,email: widget.email,),
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
                leading: Icon(Icons.person_remove_alt_1_outlined,color: Colors.red,size: 30,),
                title: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text('Delete Account'.tr(),style: TextStyle(fontSize: 25,color: Colors.red),),
                ),
                onTap: () {
                  showDeleteAccountDialog();
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
                                : MediaQuery.of(context).size.height * 0.12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 30,bottom: 10),
                                  child: Text(
                                    'are_you_sure_you_want_to_logout'.tr(),
                                    textAlign: TextAlign.center,
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
                    color: Colors.transparent,
                    padding: viewUtil.isTablet
                        ? EdgeInsets.fromLTRB(20, 20, 20, screenHeight * 0.13)
                        : EdgeInsets.fromLTRB(12, 5, 12, screenHeight * 0.13),
                    child: GridView.builder(
                      itemCount: cardData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: viewUtil.isTablet ? 3.5 / 3.2 : 2.8 / 3,
                      ),
                      itemBuilder: (context, index) {
                        final item = cardData[index];
                        final svgHeight = screenHeight * 0.11;
                        final isTablet = viewUtil.isTablet;
                        final dividerIndent = isTablet ? 15.0 : 7.0;
                        final dividerThickness = isTablet ? 1.5 : 0.8;
                        final titleFontSize = isTablet ? 25.0 : 16.0;
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
                                        title: 'Others'.tr(),
                                        subTitle: 'Sorry,the others section is currently unavailable'.tr())
                                ),
                              );
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
                child: FloatingActionButton(
                  backgroundColor: const Color(0xff7f6bf6),
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

  void showDeleteAccountDialog() {
    ViewUtil viewUtil = ViewUtil(context);
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
                  ? MediaQuery.of(context).size.height * 0.1
                  : MediaQuery.of(context).size.height * 0.1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      'Are you sure you want to delete this account?'.tr(),
                      textAlign: TextAlign.center,
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
                  await userService.deleteUserAccount(context, widget.token, widget.id);
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
  }
  
  void _showModalBottomSheet(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,StateSetter setState){
            return Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.90,
                  minChildSize: 0,
                  maxChildSize: 0.95,
                  builder: (BuildContext context, ScrollController scrollController) {
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
                                      shape:RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
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
                                            padding: const EdgeInsets.only(bottom: 20,top: 20),
                                            child: Text('Contact Us For Estimate Details'.tr(),
                                              style: TextStyle(fontSize: viewUtil.isTablet? 25 : 20,fontWeight: FontWeight.w500),),
                                          ),
                                          estimateTextField('Name'.tr(),nameController),
                                          estimateTextField('Mobile no'.tr(),mobileNoController),
                                          estimateTextField('Email Id'.tr(),emailIdController),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 30),
                                            child: SizedBox(
                                              height: viewUtil.isTablet
                                                  ? MediaQuery.of(context).size.height * 0.06
                                                  : MediaQuery.of(context).size.height * 0.07,
                                              width: MediaQuery.of(context).size.width * 0.5,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xff0022CC),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () async{
                                                  await userService.postGetAnEstimate(
                                                      context,
                                                      name:nameController.text,
                                                      email:emailIdController.text,
                                                      mobile: mobileNoController.text
                                                  );
                                                },
                                                child: Text(
                                                  'Submit'.tr(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: viewUtil.isTablet ?23 :20,
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
                                  padding: const EdgeInsets.only(top: 20,bottom: 20),
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Get an estimate'.tr(),
                                          style: TextStyle(fontSize: viewUtil.isTablet? 25 : 20,fontWeight: FontWeight.w500))),
                                ),
                                Text('Naqlee is an online portal that specializes in logistics, machinery rentals, and transportation services. It connects businesses and individuals to freight and machinery services, allowing for efficient shipping and delivery.'.tr()),
                                Padding(
                                  padding: EdgeInsets.only(top: 20,bottom: 20),
                                  child: Text("The 'Exclusive Quote on Request' feature provides consumers with personalized pricing depending on their specific transportation requirements, resulting in tailored solutions rather than fixed rates. This functionality is advantageous to firms who want personalized logistical services.".tr()),
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
                              icon: Icon(FontAwesomeIcons.multiply,color: Colors.red,),
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

  Widget estimateTextField (
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
              fontSize: viewUtil.isTablet ?20 :15,
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
                borderSide: const BorderSide(
                    color: Color(0xffBCBCBC), width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



