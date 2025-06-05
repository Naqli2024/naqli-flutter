import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/register_step_one.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_booking.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_map.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerEditProfile.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerHelp.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/submitTicket.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';
import 'dart:ui' as ui;

class BookingDetails extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String quotePrice;
  final String paymentStatus;
  final String email;

   const BookingDetails({super.key, required this.partnerName, required this.partnerId, required this.token, required this.quotePrice, required this.paymentStatus, required this.email});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  Map<String, dynamic>? bookingData;
  String errorMessage = '';
  String? firstName;
  String? lastName;
  String? payment;
  String? paymentData;
  int? balance;
  String? bookingId;
  bool isLaunching = false;
  List<bool> loadingStates = [];
  Map<String, dynamic>? bookingDetails;
  String? partnerProfileImage;

  @override
  void initState() {
    super.initState();
    payment = widget.paymentStatus;
    _bookingDetailsFuture = fetchBookingDetails();
    fetchBookingDetails();
  }

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      final bookingIds = await _authService.getBookingData(widget.partnerId, widget.token);

      if (bookingIds.isEmpty) {
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final bookingId = booking['bookingId'] as String;
        final paymentType = booking['paymentStatus'] as String;
        final quotePrice = booking['quotePrice'].toString();
        final profileImage = booking['profileImage'];
        partnerProfileImage = profileImage;

        try {
          final details = await _authService.getBookingId(bookingId, widget.token, '', widget.quotePrice);
          details['quotePrice'] = quotePrice;
          payment = details['paymentStatus'];
          balance = details['remainingBalance'];
          if (details['bookingStatus'] != 'Completed') {
            if (details.isNotEmpty || details['bookingStatus'] == 'Running' &&
                (paymentType == 'NotPaid' || paymentType == 'Paid' || paymentType == 'HalfPaid')) {
              bookingDetails.add(details);
            } else {
              print("Booking is not running or payment status does not match for booking ID $bookingId.");
            }
          } else {
            print("Booking ID $bookingId is completed and will not be shown.");
          }
        } catch (e) {
          print("Error fetching details for booking ID $bookingId: $e");
          return [];
        }
      }
      loadingStates = List<bool>.filled(bookingDetails.length, false);

      return bookingDetails;
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchUserName(String userId) async {
    try {
      final fetchedFirstName = await _authService.getUserName(userId, widget.token);
      setState(() {
        firstName = fetchedFirstName;
        lastName = fetchedFirstName;
      });
    } catch (e) {
      setState(() {
      });

    }
  }

  Future<void> fetchPaymentType(String bookingId) async {
    setState(() {
      errorMessage = '';
    });

    try {
      final details = await _authService.getBookingId(
        bookingId,
        widget.token,
        '',
        widget.quotePrice,
      );

      setState(() {
        if (details != null && details.isNotEmpty) {
          bookingDetails = details;
          paymentData = bookingDetails?['paymentStatus'];
        } else {
          errorMessage = 'No booking details found for the selected ID.';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching booking details: $e';
      });
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
          User: widget.partnerName,
            userId: widget.partnerId,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 25),
                  child: Text(
                    'booking'.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  commonWidgets.logout(context);
                },
                icon: Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                  size: viewUtil.isTablet?27: 24,
                ),
              ),
            ),
          ),
        ),
        drawer: commonWidgets.createDrawer(context,
            widget.partnerId,
            widget.partnerName,
            profileImage: partnerProfileImage,
          onBookingPressed: (){
            Navigator.pop(context);
          },
          onEditProfilePressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PartnerEditProfile(partnerName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,)
              ),
            );
          },
          onPaymentPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetails(token: widget.token,partnerId: widget.partnerId,partnerName: widget.partnerName, quotePrice: widget.quotePrice,paymentStatus: widget.paymentStatus,email: widget.email,)
            ),
          );
        },
          onReportPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitTicket(firstName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,),
              ),
            );
          },
          onHelpPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PartnerHelp(partnerName: widget.partnerName,token: widget.token,partnerId: widget.partnerId,email: widget.email,),
              ),
            );
          }
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: ()async {
            final refreshedData = await fetchBookingDetails();
            setState(() {
              _bookingDetailsFuture = Future.value(refreshedData);
            });
          },
          child: FutureBuilder<List<Map<String, dynamic>?>>(
            future: _bookingDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final bookingDetails = snapshot.data!;
                return ListView.builder(
                  itemCount: bookingDetails.length,
                  itemBuilder: (context, index) {
                    final booking = bookingDetails[index];
                    final id = booking?['_id'] ?? 'Unknown ID';
                    bookingId =id;
                    final date = booking?['date'] ?? 'N/A';
                    final time = booking?['time'] ?? 'N/A';
                    final dynamic quotePriceValue = booking?['quotePrice'];
                    final quotePrice = quotePriceValue != null ? quotePriceValue.toString() : 'N/A';
                    final paymentStatus = booking?['paymentStatus'] ?? 'N/A';
                    final pickup = booking?['pickup'] ?? '';
                    final dropPoints = booking?['dropPoints'] ?? '';
                    final remainingBalance = booking?['remainingBalance'] ?? 'N/A';
                    final name = booking?['name'] ?? 'N/A';
                    final typeName = booking?['typeName'] ?? 'N/A';
                    final userId = booking?['userId'] ?? 'N/A';
                    final bookingStatus = booking?['bookingStatus'] ?? 'N/A';
                    final cityName = booking?['cityName'] ?? 'N/A';
                    final address = booking?['address'] ?? 'N/A';
                    final zipCode = booking?['fromTime'] ?? 'N/A';
                    final fromTime = booking?['fromTime'] ?? 'N/A';
                    final toTime = booking?['toTime'] ?? 'N/A';
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Card(
                            color: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 3.0,
                            child: ListTile(
                              title: Text('${'Booking id'.tr()}: $id'),
                              subtitle: Row(
                                children: [
                                  Text('$date'),
                                  time == 'N/A'
                                  ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('$fromTime - $toTime'),
                                  )
                                  :Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('$time'),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff6A66D1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loadingStates[index] = true;
                                      });
                                      await fetchUserName(userId);
                                      await fetchPaymentType(id??"");
                                      // await fetchBookingDetails();
                                      if(paymentData == 'Pending' || paymentData == 'NotPaid'){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewBooking(
                                              partnerName: widget.partnerName,
                                              token: widget.token,
                                              partnerId: widget.partnerId,
                                              bookingId: id,
                                              bookingDetails: [booking?? {} ],
                                              quotePrice: quotePrice,
                                              paymentStatus: paymentStatus,
                                              userId: userId,
                                              bookingStatus: bookingStatus,
                                              cityName: cityName,
                                              address: address,
                                              zipCode: zipCode,
                                              email: widget.email,
                                            ),
                                          ),
                                        );
                                      }
                                     else{
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewMap(
                                                partnerName: widget.partnerName,
                                                userName: firstName != null?'$firstName':''+ '${lastName != null ?'$lastName':''}',
                                                userId: userId,
                                                mode: name+' '+typeName,
                                                bookingStatus: bookingStatus,
                                                pickupPoint: pickup,
                                                dropPoint: dropPoints,
                                                remainingBalance: balance.toString(),
                                                bookingId: id,token: widget.token,
                                                partnerId: widget.partnerId,
                                                quotePrice: quotePrice,
                                                paymentStatus: paymentStatus,
                                                cityName: cityName,
                                                address: address,
                                                zipCode: zipCode,
                                                email: widget.email,
                                              )
                                          ),
                                        );
                                      }
                                      setState(() {
                                        loadingStates[index] = false;
                                      });
                                    },
                                    child: loadingStates[index]
                                    ? Container(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    :Text(
                                      'View'.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: viewUtil.isTablet ?18:12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    alignment: Alignment.center,
                    child: Center(
                      child: Text(
                        'No Bookings Found'.tr(),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Text("Loading..."),
            ],
          ),
        );
      },
    );
  }

}


