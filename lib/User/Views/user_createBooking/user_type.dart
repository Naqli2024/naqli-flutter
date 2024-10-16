import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
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
import 'package:flutter_naqli/User/Views/user_report/user_submitTicket.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserType extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  final String? paymentStatus;
  final String? quotePrice;
  final String? oldQuotePrice;
  const UserType({super.key, required this.firstName, required this.lastName, required this.token, required this.id, this.paymentStatus, this.quotePrice, this.oldQuotePrice, required this.email});

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  String _selectedType = '';
  Future<Map<String, dynamic>?>? booking;
  List<Map<String, dynamic>>? partnerData;
  String? partnerId;

  @override
  void initState() {
    super.initState();
    booking = _fetchBookingDetails();
  }
  // Future<Map<String, dynamic>?> _fetchBookingDetails() async {
  //   try {
  //     final history = await userService.fetchBookingDetails(widget.id, widget.token);
  //     return history;
  //   } catch (e) {
  //     print('Error fetching booking details: $e');
  //     return null;
  //   }
  // }

/*  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    final String? bookingId = data['_id'];
    final String? token = data['token'];

    if (bookingId != null && token != null) {
      print('Fetching details with bookingId=$bookingId and token=$token');
      return await userService.fetchBookingDetails(bookingId, token);
    } else {
      print('No bookingId or token found in shared preferences.');
      return null;
    }
  }*/

  Future<Map<String, dynamic>?> _fetchBookingDetails() async {
    final data = await getSavedBookingId();
    String? bookingId = data['_id'];
    final String? token = data['token'];

    // If bookingId is null, call getPaymentPendingBooking API
    if (bookingId == null || token == null) {
      print('No bookingId found, fetching pending booking details.');

      if (widget.id != null && token != null) {
        bookingId = await userService.getPaymentPendingBooking(widget.id, token);

        if (bookingId != null) {
          // Optionally, save the bookingId to shared preferences
          // await saveBookingIdToPreferences(bookingId, token);
        } else {
          print('No pending booking found, navigating to NewBooking.');
          return null;
        }
      } else {
        print('No userId or token available.');
        return null;
      }
    }

    // Proceed to fetch booking details if bookingId is available
    if (bookingId != null && token != null) {
      return await userService.fetchBookingDetails(bookingId, token);
    } else {
      print('Failed to fetch booking details due to missing bookingId or token.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewBooking(
            token: token,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName +' '+ widget.lastName,
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
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking',style: TextStyle(fontSize: 25),),
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
                            size: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['scale'] ?? '' : 'N/A',
                            unitType: bookingData['unitType'] ?? '',
                            unitTypeName: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeName'] ?? 'N/A' : 'N/A',
                            load: bookingData['type']?.isNotEmpty ?? false ? bookingData['type'][0]['typeOfLoad'] ?? '' : 'N/A',
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
                leading: Image.asset('assets/booking_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text('Booking History',style: TextStyle(fontSize: 25),),
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
                leading: Image.asset('assets/payment_logo.png',
                    height: MediaQuery.of(context).size.height * 0.05),
                title: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('Payment',style: TextStyle(fontSize: 25),),
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
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 20,bottom: 10,top: 15),
              child: Text('More info and support',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Image.asset('assets/report_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Report',style: TextStyle(fontSize: 25),),
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
              leading: Image.asset('assets/help_logo.png',
                  height: MediaQuery.of(context).size.height * 0.05),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Help',style: TextStyle(fontSize: 25),),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.phone,size: 30,color: Color(0xff707070),),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 17),
                child: Text('Contact us',style: TextStyle(fontSize: 25),),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.logout,color: Colors.red,size: 30,),
              ),
              title: const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text('Logout',style: TextStyle(fontSize: 25,color: Colors.red),),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 30,bottom: 10),
                            child: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            await clearUserData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserLogin()),
                            );
                          },
                        ),
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.2,
              width: MediaQuery.sizeOf(context).width,
              decoration: const BoxDecoration(
                color: Color(0xff6A66D1),
              ),
             /* child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                        setState(() {
                          _selectedType = 'vehicle';
                        });

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBooking(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: _selectedType,
                              token: widget.token,
                              id: widget.id,
                              email: widget.email,
                            ),
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
                        setState(() {
                          _selectedType = 'bus';
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBooking(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              selectedType: _selectedType,
                              token: widget.token,
                              id: widget.id,
                              email: widget.email,
                            ),
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
                setState(() {
                  _selectedType = 'equipment';
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBooking(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      selectedType: _selectedType,
                      token: widget.token,
                      id: widget.id,
                      email: widget.email,
                    ),
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
                            SvgPicture.asset('assets/equipment.svg',height: MediaQuery.sizeOf(context).height * 0.12),
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
                          setState(() {
                            _selectedType = 'special';
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateBooking(
                                firstName: widget.firstName,
                                lastName: widget.lastName,
                                selectedType: _selectedType,
                                token: widget.token,
                                id: widget.id,
                                email: widget.email,
                              ),
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
              margin: EdgeInsets.only(left: 35, top: 15,bottom: MediaQuery.sizeOf(context).height * 0.12),
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'others';
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateBooking(
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        selectedType: _selectedType,
                        token: widget.token,
                        id: widget.id,
                        email: widget.email,
                      ),
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


