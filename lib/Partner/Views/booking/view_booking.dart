import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_map.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerEditProfile.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/partnerHelp.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/submitTicket.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class ViewBooking extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String email;
  final String bookingId;
  final String quotePrice;
  final String paymentStatus;
  final String userId;
  final String bookingStatus;
  final String cityName;
  final String address;
  final String zipCode;
  final List<Map<String, dynamic>> bookingDetails;

  const ViewBooking({
    super.key,
    required this.partnerName,
    required this.partnerId,
    required this.token,
    required this.bookingId,
    required this.bookingDetails,
    required this.quotePrice,
    required this.paymentStatus,
    required this.userId,
    required this.bookingStatus, required this.cityName, required this.address, required this.zipCode, required this.email,
  });

  @override
  State<ViewBooking> createState() => _ViewBookingState();
}


class _ViewBookingState extends State<ViewBooking> {
  Map<String, dynamic>? bookingDetails;
  String? firstName;
  String? lastName;
  bool isLoading = true;
  bool isSending = false;
  String errorMessage = '';
  late TextEditingController quotePriceController = TextEditingController();
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  String? paymentStatus;
  String? bookingStatus;
  String? partnerProfileImage;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
    fetchUserName();
    fetchPartnerProfile();
    quotePriceController = TextEditingController(
      text: widget.quotePrice != 'null' && widget.quotePrice.isNotEmpty ? widget.quotePrice : '',
    );
    // quotePriceController = TextEditingController(text: widget.quotePrice??'');
  }

  Future<void> fetchBookingDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final details = await _authService.getBookingId(
        widget.bookingId,
        widget.token,
        '',
        widget.quotePrice,
      );

      setState(() {
        isLoading = false; // Stop loading
        if (details != null && details.isNotEmpty) {
          bookingDetails = details;
          paymentStatus = bookingDetails?['paymentStatus'];
          bookingStatus = bookingDetails?['bookingStatus'];
        } else {
          errorMessage = 'No booking details found for the selected ID.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching booking details: $e';
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchPartnerProfile() async {
    try {
      final bookingIds = await _authService.getBookingData(
          widget.partnerId, widget.token);

      if (bookingIds.isEmpty) {
        return [];
      }
      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final profileImage = booking['profileImage'];
        partnerProfileImage = profileImage;
        return bookingDetails;
      }
      return bookingDetails;
    }catch (e) {
      return [];
    }
  }

  Future<void> fetchUserName() async {
    try {
      final fetchedFirstName = await _authService.getUserName(widget.userId, widget.token);
      setState(() {
        firstName = fetchedFirstName;
        lastName = fetchedFirstName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
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
                  Navigator.pop(context);
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
          onBookingPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookingDetails(token: widget.token,partnerId: widget.partnerId,partnerName: widget.partnerName, quotePrice: widget.quotePrice,paymentStatus: widget.paymentStatus,email: widget.email,)
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : bookingDetails == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
             backgroundColor: Colors.white,
              onRefresh:()async{
                await fetchBookingDetails();
                if (bookingStatus == 'Yet to start' || paymentStatus == 'NotPaid') {
                  await fetchBookingDetails();
                  setState(() {});
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMap(
                        partnerName: widget.partnerName,
                        userName: firstName != null?'$firstName':''+ '${lastName != null ?'$lastName':''}',
                        userId: widget.userId,
                        mode: '${bookingDetails?['name'] ?? 'No name available'}'+' '+'${bookingDetails?['typeName'] ?? ''}',
                        bookingStatus: widget.bookingStatus,
                        pickupPoint: '${bookingDetails?['pickup'] ?? ''}',
                        dropPoint: bookingDetails?['dropPoints'] ?? [],
                        remainingBalance: '${bookingDetails?['remainingBalance'] ?? 'No balance'}',
                        bookingId: widget.bookingId,
                        token: widget.token,
                        partnerId: widget.partnerId,
                        quotePrice: widget.quotePrice,
                        paymentStatus: widget.paymentStatus,
                        cityName: widget.cityName,
                        address: widget.address,
                        zipCode: widget.zipCode,
                        email: widget.email,
                      ),
                    ),
                  );
                  setState(() {});
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                  children: [
                    Padding(
                      padding: viewUtil.isTablet
                          ? EdgeInsets.fromLTRB(20, 60, 20, 0)
                          : EdgeInsets.fromLTRB(8, 40, 8, 0),
                      child: Card(
              elevation: 15,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:7,child: Text('Booked by'.tr(),
                          style: TextStyle(fontSize: viewUtil.isTablet?22: 14),)),
                          Expanded(flex:2,child: Text('Booking id'.tr(),
                          style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:7,child: Text(firstName != null?'$firstName':''+ '${lastName != null ?'$lastName':''}',style: TextStyle(color: Color(0xffAD1C86),fontSize: viewUtil.isTablet?22: 14))),
                          Text(widget.bookingId.toString(),style: TextStyle(color: Color(0xffAD1C86),fontSize: viewUtil.isTablet?22: 14)),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Mode'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                Expanded(flex:2,child: Text('${bookingDetails?['name'] ?? 'N/A'}'.tr()+
                                    ' ${bookingDetails?['typeName'] ?? ''}'.tr(),style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14))),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Load'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                Expanded(flex:2,child: Text('${bookingDetails?['typeOfLoad'] ?? 'N/A'.tr()}'.tr(),style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14),)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Date'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                Expanded(flex:2,child: Text('${bookingDetails?['date'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14),)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Time'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                bookingDetails?['time'] == null
                                ? Expanded(flex:2,child: Text('${bookingDetails?['fromTime'] ?? ''} - ${bookingDetails?['toTime'] ?? ''}',style: TextStyle(color: Color(0xff79797C)),))
                                : Expanded(flex:2,child: Text('${bookingDetails?['time'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14),))
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Additional Labour'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                Expanded(flex:2,child: Text('${bookingDetails?['additionalLabour'] ?? 'N/A'.tr()}',style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14),)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('valueOfProduct'.tr(),
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 14))),
                                Expanded(flex:2,child: Text('${bookingDetails?['productValue'] ?? 'N/A'.tr()} SAR',style: TextStyle(color: Color(0xff79797C),fontSize: viewUtil.isTablet?22: 14),)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DottedDivider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/pickup_drop.svg',
                          height: viewUtil.isTablet ? 90 :70),
                          bookingDetails?['cityName'] != null
                          ? Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom:0,left: 10),
                                  child: Column(
                                    children: [
                                      Text('${bookingDetails?['cityName'] ?? 'No cityName available'}',textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: viewUtil.isTablet?22: 17),),
                                      Text('${bookingDetails?['address'] ?? 'No address available'}',textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: viewUtil.isTablet?22: 17),),
                                      Text('${bookingDetails?['zipCode'] ?? ''}',textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: viewUtil.isTablet?22: 17),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom:35,left: 0),
                                  child: Text('${bookingDetails?['pickup'] ?? 'No pickup available'}',textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 17)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Text('${bookingDetails?['dropPoints'] ?? 'No dropPoints available'}',textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: viewUtil.isTablet?22: 17)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DottedDivider(),
                    widget.paymentStatus == 'Paid' ||  widget.paymentStatus == 'Completed' ||  widget.paymentStatus == 'HalfPaid'
                    ? Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: Container(
                      height: MediaQuery.sizeOf(context).width * 0.12,
                      width: MediaQuery.sizeOf(context).width * 0.65,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffBCBCBC)),
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                      ),
                        child: Center(child: Text(widget.quotePrice)),
                      ))
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: TextField(
                        controller: quotePriceController,
                        decoration: InputDecoration(
                          hintText: 'Enter Quote Price'.tr(),
                          hintStyle: const TextStyle(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.057,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: paymentStatus == 'Paid' ||  paymentStatus == 'Completed' ||  paymentStatus == 'HalfPaid'
                                        ? const Color(0xffa09fc3)
                                        : const Color(0xff6269FE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async{
                                    setState(() {
                                      isSending =true;
                                    });
                                      paymentStatus == 'Paid' ||  paymentStatus == 'Completed' ||  paymentStatus == 'HalfPaid'
                                          ? null
                                          : quotePriceController.text.isEmpty
                                          ? CommonWidgets().showToast('Please enter Quote price to send')
                                          : await _authService.sendQuotePrice(context, quotePrice: quotePriceController.text, partnerId: widget.partnerId, bookingId: widget.bookingId,token: widget.token);
                                    setState(() {
                                      isSending =false;
                                    });
                                  },
                                  child: isSending
                                ? Container(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                :Text(
                                    'Send Quote'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: viewUtil.isTablet?22: 15,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.057,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: paymentStatus == 'Paid' ||  paymentStatus == 'Completed' ||  paymentStatus == 'HalfPaid'
                                    ? const Color(0xff513434)
                                    : const Color(0xff6F181C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      paymentStatus == 'Paid' ||  paymentStatus == 'Completed' ||  paymentStatus == 'HalfPaid'
                                          ? null
                                          : showDialog(
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
                                                    'Are you sure you want to cancel?'.tr(),
                                                    style: TextStyle(fontSize: viewUtil.isTablet ? 24 :19),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('yes'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 :15)),
                                                onPressed: () async {
                                                  await _authService.deleteBookingRequest(context,widget.partnerId, widget.bookingId, widget.token);
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BookingDetails(partnerName: widget.partnerName,
                                                              partnerId: widget.partnerId,
                                                              token: widget.token,
                                                              quotePrice: '',
                                                              paymentStatus: '',email:widget.email,)
                                                    ),
                                                  );
                                                },
                                              ),
                                              TextButton(
                                                child: Text('no'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 :15)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),);
                                        },
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Cancel Quote'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: viewUtil.isTablet?22: 15,
                                        fontWeight: FontWeight.w500),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                      ),
                    ),
                  ],
                  ),
                  ),
            ),

      ),
    );
  }
}

class DottedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashHeight;
  final Color color;

  DottedDivider({
    this.dashWidth = 4.0,
    this.dashHeight = 1.0,
    this.color = const Color(0xff707070),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

