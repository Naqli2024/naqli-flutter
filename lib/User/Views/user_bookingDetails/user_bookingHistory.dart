import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookingHistory extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  const BookingHistory({super.key, required this.token, required this.firstName, required this.lastName, required this.id});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late Future<List<dynamic>> bookingHistory;
  bool isLoading = true;

  @override
  void initState() {
    bookingHistory = fetchHistory();
    super.initState();
  }

  // Future<void> fetchHistory() async {
  //   List<dynamic> history = await userService.fetchPaymentBookingHistory(widget.id, widget.token);
  //   setState(() {
  //     bookingHistory = history;
  //     isLoading = false;
  //   });
  // }

  Future<List<dynamic>> fetchHistory() async {
    try {
      final data = await getSavedUserData();
      final String? id = data['id'];
      final String? token = data['token'];

      if (id != null && token != null) {
        return await userService.fetchPaymentBookingHistory(id, token);
      } else {
        setState(() {
          isLoading = false;
        });
        return [];
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName + widget.lastName,
        showLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: const Text(
                      'Booking History',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> UserType(
                        firstName: widget.firstName,
                        lastName: widget.lastName, token: widget.token, id: widget.id,)));
              },
              icon: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: bookingHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.17),
                    child: SvgPicture.asset('assets/history.svg'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 20),
                    child: Text(
                      "No history available !!!",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "Let's book some vehicle and make your",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  Text(
                    "Booking history heavy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            );
          } else {
            final bookingHistory = snapshot.data!;
            return ListView.builder(
              itemCount: bookingHistory.length,
              itemBuilder: (context, index) {
                final booking = bookingHistory[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17, 40, 17, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Mode',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        booking['name'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17, 8, 17, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Date',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        booking['date'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17, 8, 17, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Unit Type',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        booking['unitType'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17, 8, 17, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Booking ID',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        booking['_id'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17, 8, 17, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Payment Status',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        booking['paymentStatus'] ?? 'N/A',
                                        style: TextStyle(fontSize: 16),
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
                        top: 5,
                        left: 170,
                        child: Container(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/history_truck.svg',
                            height: 70,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
