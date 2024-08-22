import 'package:flutter/material.dart';
import 'package:flutter_naqli/Model/bookingData.dart';
import 'package:flutter_naqli/Model/sharedPreferences.dart';
import 'package:flutter_naqli/Viewmodel/services.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/booking/view_booking.dart';
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

  @override
  void initState() {
    super.initState();
    _bookingDetailsFuture = fetchBookingDetails();
  }

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      print('Fetching booking details for partnerId: ${widget.partnerId}');
      final bookingIds = await AuthService().getBookingData(widget.partnerId, widget.token);
      print('Booking IDs retrieved: $bookingIds');

      if (bookingIds.isEmpty) {
        print("No booking IDs found.");
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];
      for (var booking in bookingIds) {
        final bookingId = booking['bookingId'] as String;
        final paymentStatus = booking['paymentStatus'] as String;

        try {
          print('Fetching details for booking ID: $bookingId');
          final details = await AuthService().getBookingId(bookingId, widget.token, paymentStatus, widget.quotePrice);
          print('Details retrieved: $details');
          if (details.isNotEmpty) {
            bookingDetails.add(details);
          } else {
            print("No details found for booking ID $bookingId.");
          }
        } catch (e) {
          print("Error fetching details for booking ID $bookingId: $e");
        }
      }

      return bookingDetails;
    } catch (e) {
      print("Error fetching booking details: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
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
      drawer: createDrawer(context),
      body: FutureBuilder<List<Map<String, dynamic>?>>(
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
                final date = booking?['date'] ?? 'No date available';
                final time = booking?['time'] ?? 'No date available';
                final quotePrice = booking?['quotePrice'] ?? 'No quotePrice available';
                final paymentStatus = booking?['paymentStatus'] ?? 'No paymentStatus available';
                final userId = booking?['userId'] ?? 'No userId available';

                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    child: ListTile(
                      // leading: Container(
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     border: Border.all(
                      //       color: Colors.black,
                      //       width: 1.0,
                      //     ),
                      //   ),
                      //   child: const CircleAvatar(
                      //     backgroundColor: Colors.white,
                      //   ),
                      // ),
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewBooking(
                                    partnerName: widget.partnerName,
                                    token: widget.token,partnerId:
                                  widget.partnerId,bookingId: id,
                                    bookingDetails: [booking?? {} ], quotePrice: quotePrice,paymentStatus: paymentStatus, userId: userId,),
                                ),
                              );
                            },
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No bookings found.'));
          }
        },
      ),
    );
  }
}


