import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_map.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';

class ViewBooking extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
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
    required this.bookingStatus, required this.cityName, required this.address, required this.zipCode,
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

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
    fetchUserName();
    quotePriceController = TextEditingController(
      text: widget.quotePrice != 'null' && widget.quotePrice.isNotEmpty ? widget.quotePrice : '',
    );
    // quotePriceController = TextEditingController(text: widget.quotePrice??'');
  }

  // Future<void> fetchBookingDetails() async {
  //   try {
  //     final details = await _authService.getBookingId(widget.bookingId, widget.token,widget.paymentStatus,widget.quotePrice);
  //
  //
  //     setState(() {
  //       isLoading = false;
  //       if (details != null && details.isNotEmpty) {
  //         bookingDetails = details;
  //       } else {
  //         errorMessage = 'No booking details found for the selected ID.';
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Error fetching booking details: $e';
  //     });
  //   }
  // }

  Future<void> fetchBookingDetails() async {
    setState(() {
      isLoading = true; // Start loading
      errorMessage = ''; // Clear any previous error message
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
          bookingDetails = details; // Store fetched details
          paymentStatus = bookingDetails?['paymentStatus'];
          bookingStatus = bookingDetails?['bookingStatus'];
          print(paymentStatus);
        } else {
          errorMessage = 'No booking details found for the selected ID.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading
        errorMessage = 'Error fetching booking details: $e';
      });
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
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: const Center(
              child: Text(
                'Booking',
                style: TextStyle(color: Colors.white),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      drawer: commonWidgets.createDrawer(context,
        onPaymentPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentDetails(token: widget.token,partnerId: widget.partnerId,partnerName: widget.partnerName, quotePrice: widget.quotePrice,paymentStatus: widget.paymentStatus,)
          ),
        );
      },
        onBookingPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookingDetails(token: widget.token,partnerId: widget.partnerId,partnerName: widget.partnerName, quotePrice: widget.quotePrice,paymentStatus: widget.paymentStatus,)
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
                      mode: '${bookingDetails?['name'] ?? 'No name available'} ${bookingDetails?['typeName'] ?? ''}',
                      bookingStatus: widget.bookingStatus,
                      pickupPoint: '${bookingDetails?['pickup'] ?? 'No pickup available'}',
                      dropPoint: '${bookingDetails?['dropPoints'] ?? 'No dropPoints available'}',
                      remainingBalance: '${bookingDetails?['remainingBalance'] ?? 'No balance'}',
                      bookingId: widget.bookingId,
                      token: widget.token,
                      partnerId: widget.partnerId,
                      quotePrice: widget.quotePrice,
                      paymentStatus: widget.paymentStatus,
                      cityName: widget.cityName,
                      address: widget.address,
                      zipCode: widget.zipCode,
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
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
            elevation: 15,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex:7,child: Text('Booked by')),
                        Expanded(flex:2,child: Text('Booking Id')),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex:7,child: Text(firstName != null?'$firstName':''+ '${lastName != null ?'$lastName':''}',style: TextStyle(color: Color(0xffAD1C86)))),
                        GestureDetector(
                          onTap: (){
                            /*widget.paymentStatus == 'Paid' ||  widget.paymentStatus == 'Completed' ||  widget.paymentStatus == 'HalfPaid'
                            ?Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewMap(
                                    partnerName: widget.partnerName,
                                    userName: firstName != null?'$firstName':''+ '${lastName != null ?'$lastName':''}',
                                    userId: widget.userId,
                                    mode: '${bookingDetails?['name'] ?? 'No name available'}'+
                                          ' ${bookingDetails?['typeName'] ?? ''}',
                                    bookingStatus: widget.bookingStatus,
                                    pickupPoint: '${bookingDetails?['pickup'] ?? 'No pickup available'}',
                                    dropPoint: '${bookingDetails?['dropPoints'] ?? 'No dropPoints available'}',
                                    remainingBalance: '${bookingDetails?['remainingBalance'] ?? 'No balance'}',
                                    bookingId: widget.bookingId,token: widget.token,
                                    partnerId: widget.partnerId,
                                    quotePrice: widget.quotePrice,
                                    paymentStatus: widget.paymentStatus,
                                    cityName: widget.cityName,
                                    address: widget.address,
                                    zipCode: widget.zipCode,
                                  )
                              ),
                            )
                                :null;*/
                          },
                            child: Text(widget.bookingId.toString(),style: const TextStyle(color: Color(0xffAD1C86)))),
                      ],
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                      side: const BorderSide(
                        color: Color(0xffE0E0E0), // Border color
                        width: 1, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Mode')),
                              Expanded(flex:2,child: Text('${bookingDetails?['name'] ?? 'N/A'}'+
                                  ' ${bookingDetails?['typeName'] ?? ''}',style: TextStyle(color: Color(0xff79797C)),)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Load')),
                              Expanded(flex:2,child: Text('${bookingDetails?['typeOfLoad'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C)),)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Date')),
                              Expanded(flex:2,child: Text('${bookingDetails?['date'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C)),)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Time')),
                              Expanded(flex:2,child: Text('${bookingDetails?['time'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C)),)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Additional Labour')),
                              Expanded(flex:2,child: Text('${bookingDetails?['additionalLabour'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C)),)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(flex:6,child: Text('Value of the Product')),
                              Expanded(flex:2,child: Text('${bookingDetails?['productValue'] ?? 'N/A'}',style: TextStyle(color: Color(0xff79797C)),)),
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
                        Image.asset('assets/pickup_drop.png'),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom:35,left: 0),
                                child: Text('${bookingDetails?['pickup'] ?? 'No pickup available'}',textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 20),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text('${bookingDetails?['dropPoints'] ?? 'No dropPoints available'}',textAlign: TextAlign.left,
                                  style: const TextStyle(fontSize: 20),),
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
                        hintText: 'Enter Quote Price',
                        hintStyle: const TextStyle(),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
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
                                'Send Quote',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
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
                                                'Are you sure you want to cancel?',
                                                style: TextStyle(fontSize: 19),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () async {
                                              await _authService.deleteBookingRequest(context,widget.partnerId, widget.bookingId, widget.token);
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
                                });
                              },
                              child: const Text(
                                'Cancel Quote',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              )),
                        ),
                      ),
                    ],
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

