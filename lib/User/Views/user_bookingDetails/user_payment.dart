import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';

class Payment extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;

  const Payment({
    super.key,
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.id,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late Future<List<dynamic>> paymentHistory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    paymentHistory = fetchHistory();
  }

  // Future<void> fetchHistory() async {
  //   try {
  //     List<dynamic> history = await userService.fetchPaymentBookingHistory(widget.id, widget.token);
  //     setState(() {
  //       paymentHistory = history;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching payment history: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
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
                      'Payment',
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
        future: fetchHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.17),
                    child: SvgPicture.asset('assets/noPayment.svg'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 0),
                    child: Text(
                      "No Payment information Available",
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 0),
                    child: Text(
                      "It looks like you don't have any recent payment details available at the moment. Please check back later.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final paymentHistory = snapshot.data!;
            return ListView.builder(
              itemCount: paymentHistory.length,
              itemBuilder: (context, index) {
                final booking = paymentHistory[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 3.0,
                    child: ListTile(
                      title: Text('Booking Id: ${booking['_id'].toString()}'),
                      subtitle: Row(
                        children: [
                          Text('${booking['date']}'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${booking['time']}'),
                          ),
                        ],
                      ),
                      trailing: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                          width: MediaQuery.of(context).size.width * 0.23,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6A66D1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              showBookingDialog(context, booking);
                            },
                            child: Text(
                              booking['paymentStatus'] == 'Pending' || booking['paymentStatus'] == 'HalfPaid' ? 'Pay Bal' : 'View',
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
                );
              },
            );
          }
        },
      ),
    );
  }
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
            booking?['paymentStatus'] == 'Paid' || booking?['paymentStatus'] == 'Completed'
            ?Padding(
              padding: const EdgeInsets.only(top: 30,bottom: 10),
              child: Text(
                'Total ${booking?['paymentStatus'] ?? ''}',
                style: const TextStyle(fontSize: 19),
              ),
            )
            : Padding(
              padding: const EdgeInsets.only(top: 30,bottom: 10),
              child: Text(
                'Pending Amount',
                style: const TextStyle(fontSize: 19),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${booking?['paymentAmount'] ?? 'No Amount'} SAR',
                style: const TextStyle(fontSize: 19),
              ),
            ),
            booking?['paymentStatus'] == 'Pending' || booking?['paymentStatus'] == 'HalfPaid'
                ? Container(
              margin: const EdgeInsets.only(
                  top: 10, left: 10),
              child: SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height *
                    0.054,
                width: MediaQuery.of(context)
                    .size
                    .width *
                    0.4,
                child: ElevatedButton(
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                          0xff6269FE),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(15),
                      ),
                    ),
                    onPressed: () {

                    },
                    child: Text(
                      'Pay : ${booking['remainingBalance']??''}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight
                              .normal),
                    )),
              ),
            )
                : Container()
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