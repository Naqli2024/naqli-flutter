import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Viewmodel/services.dart';
import 'package:flutter_naqli/Views/booking/booking_details.dart';

class PaymentDetails extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String quotePrice;
  final String paymentStatus;
  const PaymentDetails({super.key, required this.partnerName, required this.partnerId, required this.token, required this.quotePrice, required this.paymentStatus});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  String _currentFilter = 'All';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading =true;
    _fetchAndSetBookingDetails();
  }

  Future<void> _fetchAndSetBookingDetails() async {
    final bookingDetails = await fetchBookingDetails();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookingDetails));
    });
    isLoading =false;
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

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }
    return bookings.where((booking) => booking['paymentStatus'] == _currentFilter).toList();
  }

  void _updateFilter(String filter) {
    isLoading = true;
    setState(() {
      _currentFilter = filter;
      _fetchAndSetBookingDetails();
    });
  }

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                    child: Card(
                      elevation: 20,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0), // Border color
                          width: 1, // Border width
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Booking ID',
                                    style: TextStyle(
                                        fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${booking?['_id'] ?? 'No Booking Id'}',
                                    style: const TextStyle(fontSize: 16,color: Color(0xff79797C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Contract Type',
                                    style: TextStyle(
                                        fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '-',
                                    style: const TextStyle(fontSize: 16,color: Color(0xff79797C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Date',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${booking?['date'] ?? 'No Date'}',
                                    style: const TextStyle(fontSize: 16,color: Color(0xff79797C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                          border:Border.all(color: booking?['paymentStatus'] == 'Completed'
                              ? Colors.greenAccent
                              : booking?['paymentStatus'] == 'Paid'
                              ? Colors.green
                              : Colors.red,),
                          borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text('${booking?['paymentStatus'] ?? 'No paymentStatus'}',style: const TextStyle(fontSize: 19)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30,bottom: 10),
                child: Text(
                  'Total ${booking?['paymentStatus'] ?? ''}',
                  style: const TextStyle(fontSize: 19),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${booking?['paymentAmount'] ?? 'No Amount'}',
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*  void showBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.10,
                  child: Image.network(
                    'https://via.placeholder.com/150',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              Text('Booking ID: ${booking['_id']}'),
              Text('Date: ${booking['date']}'),
              Text('Time: ${booking['time']}'),
              Text('Quote Price: ${booking['quotePrice']}'),
              Text('Payment Status: ${booking['paymentStatus']}'),
              Text('User ID: ${booking['userId']}'),
              Text('Booking Status: ${booking['bookingStatus']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        context,
        User: widget.partnerName,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: Column(
            children: [
              AppBar(
                toolbarHeight: 80,
                backgroundColor: const Color(0xffA09CEC),
                title: const Center(
                  child: Text(
                    'Payment',
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
              Container(
                color: const Color(0xff6A66D1),
                height: 60,
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _updateFilter('All'),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text(
                          'All',
                          style: TextStyle(
                            color: _currentFilter == 'All' ? Colors.white : Color(0xffC2BFF2),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _updateFilter('Completed'),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: _currentFilter == 'Completed' ? Colors.white : Color(0xffC2BFF2),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _updateFilter('Pending Payment'),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          'Pending Payment',
                          style: TextStyle(
                            color: _currentFilter == 'Pending Payment' ? Colors.white : Color(0xffC2BFF2),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: createDrawer(context, onBookingPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetails(
              partnerName: widget.partnerName,
              partnerId: widget.partnerId,
              token: widget.token,
              quotePrice: widget.quotePrice,
              paymentStatus: '',
            ),
          ),
        );
      }),
      body: isLoading
      ? Center(child: CircularProgressIndicator(),)
      : FutureBuilder<List<Map<String, dynamic>?>>(
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
                final bookingStatus = booking?['bookingStatus'] ?? 'No bookingStatus available';

                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
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
                            onPressed: () {
                              showBookingDialog(context, booking!);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ViewBooking(
                              //       partnerName: widget.partnerName,
                              //       token: widget.token,
                              //       partnerId: widget.partnerId,
                              //       bookingId: id,
                              //       bookingDetails: [booking ?? {}],
                              //       quotePrice: quotePrice,
                              //       paymentStatus: paymentStatus,
                              //       userId: userId,
                              //       bookingStatus: bookingStatus,
                              //     ),
                              //   ),
                              // );
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
            return Center(child: Text('${_currentFilter=='All'?'No Payment Found':'No $_currentFilter found'}'));
          }
        },
      ),
    );
  }

}
