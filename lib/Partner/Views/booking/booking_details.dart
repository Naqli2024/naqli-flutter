import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Views/auth/register.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_booking.dart';
import 'package:flutter_naqli/Partner/Views/booking/view_map.dart';
import 'package:flutter_naqli/Partner/Views/payment/payment_details.dart';

class BookingDetails extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String quotePrice;
  final String paymentStatus;

   const BookingDetails({super.key, required this.partnerName, required this.partnerId, required this.token, required this.quotePrice, required this.paymentStatus});

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
  int? balance;
  String? bookingId;
  bool isLaunching = false;
  List<bool> loadingStates = [];

  @override
  void initState() {
    super.initState();
    _bookingDetailsFuture = fetchBookingDetails();
    fetchBookingDetails();
  }

/*
  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      print('Fetching booking details for partnerId: ${widget.partnerId}');
      final bookingIds = await _authService.getBookingData(widget.partnerId, widget.token);
      print('Booking IDs retrieved: $bookingIds');

      if (bookingIds.isEmpty) {
        print("No booking IDs found.");
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final bookingId = booking['bookingId'] as String;
        final paymentStatus = booking['paymentStatus'] as String;
        final quotePrice = booking['quotePrice'].toString();
        final bookingStatus = booking['bookingStatus'].toString();

        print('Fetching details for booking ID: $bookingId');
        final details = await _authService.getBookingId(bookingId, widget.token, paymentStatus, quotePrice);
        print('Details retrieved: $details');

        // Make sure quotePrice is correctly part of details
        details['quotePrice'] = quotePrice;

        if (details.isNotEmpty) {
          if (bookingStatus == 'Running') {
            bookingDetails.add(details);
            print("Added details for booking ID $bookingId with quotePrice $quotePrice.");
          } else {
            print("Skipped booking ID $bookingId due to booking Status: $bookingStatus.");
          }
        } else {
          print("No details found for booking ID $bookingId.");
        }
      }

      return bookingDetails;
    } catch (e) {
      print("Error fetching booking details: $e");
      return [];
    }
  }
*/

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      print('Fetching booking details for partnerId: ${widget.partnerId}');
      final bookingIds = await _authService.getBookingData(widget.partnerId, widget.token);
      print('Booking IDs retrieved: $bookingIds');

      if (bookingIds.isEmpty) {
        print("No booking IDs found.");
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final bookingId = booking['bookingId'] as String;
        final paymentType = booking['paymentStatus'] as String;
        final quotePrice = booking['quotePrice'].toString();

        try {
          print('Fetching details for booking ID: $bookingId');
          final details = await _authService.getBookingId(bookingId, widget.token, '', widget.quotePrice);

          // Add quotePrice and paymentStatus to the details
          details['quotePrice'] = quotePrice;
          details['paymentStatus'] = paymentType;

          balance = details['remainingBalance'];
          payment = paymentType;
          print('Details retrieved: $details');

          if (details['bookingStatus'] != 'Completed') {
            if (details.isNotEmpty || details['bookingStatus'] == 'Running' &&
                (paymentType == 'Pending' || paymentType == 'Paid' || paymentType == 'HalfPaid')) {
              bookingDetails.add(details);  // Add the valid booking details
            } else {
              print("Booking is not running or payment status does not match for booking ID $bookingId.");
            }
          } else {
            print("Booking ID $bookingId is completed and will not be shown.");
          }
        } catch (e) {
          print("Error fetching details for booking ID $bookingId: $e");
        }
      }
      loadingStates = List<bool>.filled(bookingDetails.length, false);

      return bookingDetails;
    } catch (e) {
      print("Error fetching booking details: $e");
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
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                commonWidgets.logout(context);
              },
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      drawer: commonWidgets.createDrawer(context,onPaymentPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetails(token: widget.token,partnerId: widget.partnerId,partnerName: widget.partnerName, quotePrice: widget.quotePrice,paymentStatus: widget.paymentStatus,)
          ),
        );
      },),
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
                  final pickup = booking?['pickup'] ?? 'N/A';
                  final dropPoints = booking?['dropPoints'] ?? 'N/A';
                  final remainingBalance = booking?['remainingBalance'] ?? 'N/A';
                  final name = booking?['name'] ?? 'N/A';
                  final typeName = booking?['typeName'] ?? 'N/A';
                  final userId = booking?['userId'] ?? 'N/A';
                  final bookingStatus = booking?['bookingStatus'] ?? 'N/A';
                  final cityName = booking?['cityName'] ?? 'N/A';
                  final address = booking?['address'] ?? 'N/A';
                  final zipCode = booking?['zipCode'] ?? 'N/A';
                   print('qqqqqqqqqqq$quotePrice');
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Card(
                          color: Colors.white,
                          shadowColor: Colors.black,
                          elevation: 3.0,
                          child: ListTile(
                            title: Text('Booking Id: $id'),
                            subtitle: Row(
                              children: [
                                Text('$date'),
                                Padding(
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
                                    await fetchBookingDetails();

                                    if(payment == 'Pending'){
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
                                              mode: name+ typeName,
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
                                    'View',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
              // Show empty ListView with centered message and allow RefreshIndicator to work
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8, // Adjust the height
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      'No bookings found.',
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20), // Space between the indicator and text
              const Text("Loading..."), // You can customize the loading message here
            ],
          ),
        );
      },
    );
  }

}


