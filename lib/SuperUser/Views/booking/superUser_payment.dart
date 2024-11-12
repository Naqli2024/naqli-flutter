import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/booking_manager.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';

class SuperUserPayment extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const SuperUserPayment({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<SuperUserPayment> createState() => _SuperUserPaymentState();
}

class _SuperUserPaymentState extends State<SuperUserPayment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  List<Map<String, dynamic>> bookings = [];
  String _currentFilter = 'All';
  bool isLoading = false;
  String partnerId = '';
  String partnerName = '';
  String bookingId = '';
  String unit = '';
  String unitType = '';
  String bookingStatus = '';
  String bookingDate = '';
  String bookingTime = '';
  String fromTime = '';
  String toTime = '';
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchAndSetBookingDetails();
  }


  // Future<void> fetchBookingsAndPartnerNames(String userId, String token) async {
  //   final bookingsData = await superUserServices.getBookingsCount(userId, token);
  //   final bookings = bookingsData['bookings'] as List<Map<String, dynamic>>? ?? [];
  //   final partnerIds = bookings.map((booking) => booking['partner']).whereType<String>().toList();
  //
  //   Map<String, String> partnerIdToNameMap = {};
  //   if (partnerIds.isNotEmpty) {
  //     List<String> partnerNames = await superUserServices.getPartnerNamess(partnerIds, token);
  //
  //     if (partnerNames.length == partnerIds.length) {
  //       for (int i = 0; i < partnerIds.length; i++) {
  //         partnerIdToNameMap[partnerIds[i]] = partnerNames[i];
  //       }
  //     }
  //   }
  //
  //   setState(() {
  //     this.bookings = bookings.map((bookingPartnerName) {
  //       String partnerId = bookingPartnerName['partner'] ?? '';
  //       bookingPartnerName['partnerName'] = partnerIdToNameMap[partnerId] ?? 'N/A';
  //       return bookingPartnerName;
  //     }).toList();
  //     this.isLoading = false;
  //   });
  // }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });

    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);

    setState(() {
      bookings = (bookingData['bookings'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
      isLoading = false;
    });
  }

  Future<void> _fetchAndSetBookingDetails() async {
    await fetchBookingsData();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookings));
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }  else if (_currentFilter == 'Completed') {
      return bookings.where((booking) => booking['paymentStatus'] == 'Paid' || booking['paymentStatus'] == 'Completed').toList();
    } else if (_currentFilter == 'HalfPaid') {
      return bookings.where((booking) => booking['tripStatus'] != 'Completed' && booking['bookingStatus'] == 'Running' && booking['paymentStatus'] == 'HalfPaid' && booking['remainingBalance'] != 0).toList();
    } else if(_currentFilter == 'Pending') {
      return bookings.where((booking) => booking['tripStatus'] == 'Completed' && booking['remainingBalance'] != 0 && booking['bookingStatus'] == 'Running').toList();
    }
    return bookings;
  }

  void _updateFilter(String filter) {
    setState(() {
      isLoading = true;
      _currentFilter = filter;
      _fetchAndSetBookingDetails();
    });
  }

  Future<String> fetchPartnerNameForBooking(String partnerId, String token) async {
    try {
      final partnerNameData = await superUserServices.getPartnerNames([partnerId], token);
      print('Received partnerNameData for $partnerId: $partnerNameData');
      if (partnerNameData is Map && partnerNameData.containsKey(partnerId)) {
        return partnerNameData[partnerId] ?? 'N/A';
      } else {
        print('Unexpected data format for partner names: $partnerNameData');
        return 'N/A';
      }
    } catch (e) {
      print('Error fetching partner name for $partnerId: $e');
      return 'N/A';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName +' '+ widget.lastName,
        userId: widget.id,
        showLeading: false,
        showLanguage: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160.0),
          child: Column(
            children: [
              AppBar(
                scrolledUnderElevation: 0,
                toolbarHeight: MediaQuery.of(context).size.height * 0.09,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff807BE5),
                title: const Text(
                  'Payment',
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SuperUserHomePage(
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            token: widget.token,
                            id: widget.id,
                            email: widget.email
                        ),
                      ),
                    );
                  },
                  icon: CircleAvatar(
                    backgroundColor: Color(0xffB7B3F1),
                    child: const Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    offset: const Offset(0, 55),
                    icon: CircleAvatar(
                      backgroundColor: Color(0xffB7B3F1),
                      child: const Icon(
                        Icons.more_vert_outlined,
                        color: Colors.white,
                      ),
                    ),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        height: 30,
                        child: Text('New Booking'),
                        onTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserType(
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  token: widget.token,
                                  id: widget.id,
                                  email: widget.email
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    color: Colors.white,
                    border: Border.all(color: Color(0xff707070),width: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: MediaQuery.of(context).size.height * 0.063,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _updateFilter('All');
                            // fetchBookingsAndPartnerNames(widget.id,widget.token);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentFilter == 'All' ? Color(0xff6269FE) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color: _currentFilter == 'All' ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _updateFilter('Completed');
                            // fetchBookingsAndPartnerNames(widget.id,widget.token);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentFilter == 'Completed' ? Color(0xff6269FE) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  color: _currentFilter == 'Completed' ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _updateFilter('HalfPaid');
                            // fetchBookingsAndPartnerNames(widget.id,widget.token);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentFilter == 'HalfPaid' ? Color(0xff6269FE) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'HalfPaid',
                                style: TextStyle(
                                  color: _currentFilter == 'HalfPaid' ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _updateFilter('Pending');
                            // fetchBookingsAndPartnerNames(widget.id,widget.token);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentFilter == 'Pending' ? Color(0xff6269FE) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'Pending',
                                style: TextStyle(
                                  color: _currentFilter == 'Pending' ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator(),))
                : bookings.isNotEmpty
                  ? Flexible(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _bookingDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading bookings.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Bookings found'));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final booking = snapshot.data![index];
                          final bookingPartnerName = bookings[index];
                          partnerId = booking['partner']??'N/A';
                          bookingId = booking['_id']??'N/A';
                          unit = booking['unitType']??'N/A';
                          unitType = booking['_id']??'N/A';
                          // partnerName = bookingPartnerName['partnerName'] ?? 'Loading...';
                          bookingStatus = booking['bookingStatus']??'N/A';
                          bookingDate = booking['date']??'N/A';
                          bookingTime = booking['time']??'N/A';
                          fromTime = booking['fromTime']??'N/A';
                          toTime = booking['toTime']??'N/A';
                          print('partnerId''${partnerId}');
                          return FutureBuilder<String>(
                            future: fetchPartnerNameForBooking(booking['partner']??'null', widget.token),
                            builder: (context, snapshot) {
                              // if (snapshot.connectionState == ConnectionState.waiting) {
                              //   return Center(child: CircularProgressIndicator());
                              // }

                              if (snapshot.hasError) {
                                return Center(child: Text('Error Loading'));
                              }

                              if (snapshot.hasData) {
                                final partnerNames = snapshot.data ?? 'N/A';

                                return Container(
                                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  child: Card(
                                    color: Colors.white,
                                    shadowColor: Colors.black,
                                    elevation: 3.0,
                                    child: ListTile(
                                      title: Text('Booking Id: ${booking['_id']??'N/A'}'),
                                      subtitle: Row(
                                        children: [
                                          Text('${booking['date']??'N/A'}'),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${booking['time']??'N/A'}' == 'N/A' ? '${booking['fromTime']??'N/A'}'+'-'+'${booking['toTime']??'N/A'}' :'${booking['time']??'N/A'}'),
                                          )
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
                                              showBookingDialog(context,booking,bookingPartnerName: partnerNames);
                                            },
                                            child: const Text(
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
                                );
                              }
                              return Container();
                            },
                          );

                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          )
                  : Expanded(child: Center(child: Text('No Bookings found')))
        ],
      ),
      bottomNavigationBar: commonWidgets.buildBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking,{String? bookingPartnerName}) {
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
                    padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                    child: Card(
                      elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0),
                          width: 1,
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
                                    '${booking['_id']}',
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
                                    'Vendor',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${bookingPartnerName??'N/A'}',
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
                                    'Vehicle',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${booking['unitType']??'N/A'}',
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
                                    '${booking['date'] ??'N/A'}',
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
                        border:Border.all(color: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                            ? Colors.greenAccent
                            : booking['paymentStatus'] == 'HalfPaid'
                            ? Color(0xffA89610)
                            : Colors.red,),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text('${booking['paymentStatus']??'N/A'}',style: const TextStyle(fontSize: 19)),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -30,
                    child: GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.red,
                            minRadius: 20,
                            maxRadius: double.maxFinite,
                            child: Icon(Icons.cancel_outlined, color: Colors.white,size: 30,))),
                  ),
                ],
              ),
              booking['paymentStatus'] == 'HalfPaid'
                  ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Pending Amount',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8,bottom: 20),
                        child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.054,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Pay: ${booking['remainingBalance']} SAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ],
                  )
                  : Column(
                children: [
                  Text('Total Paid',style: const TextStyle(fontSize: 19)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${booking['paymentAmount']} SAR',style: const TextStyle(fontSize: 19)),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuperUserHomePage(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  token: widget.token,
                  id: widget.id,
                  email: widget.email,
                )));
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingManager(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuperUserPayment(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(
              firstName: widget.firstName,
              lastName: widget.lastName,
              token: widget.token,
              id: widget.id,
              email: widget.email,
            ),
          ),
        );
        break;
    }
  }

}
