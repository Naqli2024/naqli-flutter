import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/edit_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUser_payment.dart';
import 'package:flutter_naqli/SuperUser/Views/profile/user_profile.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BookingManager extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const BookingManager({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<BookingManager> createState() => _BookingManagerState();
}

class _BookingManagerState extends State<BookingManager> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  final TextEditingController pickUpPointController = TextEditingController();
  final TextEditingController dropPointController = TextEditingController();
  List<Map<String, dynamic>> paymentStatus = [];
  int _selectedIndex = 1;
  String selectedMode= 'Tralia';
  String _currentFilter = 'Hold';
  String partnerId = '';
  String partnerName = '';
  String bookingId = '';
  String unit = '';
  String unitType = '';
  String bookingStatus = '';
  String bookingDate = '';
  bool isLoading = false;
  int selectedUnit = 1;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isChecked = false;
  bool isDeleting = false;
  int selectedLabour = 0;
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  List<Map<String, dynamic>> bookings = [];
  String partnerData = '';
  Map<String, String> partnerNames = {};
  bool allSelected = false;
  List<Map<String, dynamic>> _filteredBookings = [];
  List<Map<String, dynamic>> allBookings = [];
  bool _noBookingsFound = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAndSetBookingDetails();
    fetchBookingsAndPartnerNames(widget.id,widget.token);
    _filteredBookings = List.from(bookings);
  }

  Future<void> fetchBookingsAndPartnerNames(String userId, String token) async {
    try {
      // Step 1: Fetch bookings data with partner IDs
      final bookingsData = await superUserServices.getBookingsCount(userId, token);
      final bookings = bookingsData['bookings'] as List<Map<String, dynamic>>? ?? [];

      // Debugging: Check initial bookings data
      print('Fetched bookings: $bookings');

      // Step 2: Extract unique partnerIds from bookings
      final partnerIds = bookings.map((booking) => booking['partner']).whereType<String>().toSet().toList();

      // Step 3: Fetch partner names for each unique partnerId
      Map<String, String> partnerIdToNameMap = {};
      if (partnerIds.isNotEmpty) {
        partnerIdToNameMap = await superUserServices.getPartnerNames(partnerIds, token);
      }

      // Debugging: Check partnerId to partnerName mappings
      print('Partner ID to Name Map: $partnerIdToNameMap');

      // Step 4: Update each booking with the correct partner name based on bookingId
      List<Map<String, dynamic>> updatedBookings = bookings.map((booking) {
        String partnerId = booking['partner'] ?? '';
        String partnerName = partnerIdToNameMap[partnerId] ?? 'N/A';

        // Debugging: Ensure partnerName is correctly set based on partnerId
        print('Booking ID: ${booking['_id']}, Partner ID: $partnerId, Partner Name: $partnerName');

        // Assign the partnerName to the booking
        booking['partnerName'] = partnerName;

        return booking;
      }).toList();

      // Debugging: Check updated bookings with partner names
      print('Updated bookings with partner names: $updatedBookings');

      // Update the state with the correct booking data
      setState(() {
        this.bookings = updatedBookings;
        this.isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings and partner names: $e');
      setState(() {
        this.isLoading = false;
      });
    }
  }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });

    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);

    setState(() {
      bookings = (bookingData['bookings'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ?? [];
        _filteredBookings = bookings;
        isLoading = false;
    });
  }

  Future<void> _fetchAndSetBookingDetails() async {
    await fetchBookingsData();
    setState(() {
      _bookingDetailsFuture = Future.value(_filterBookings(bookings));
      _filteredBookings  = _filterBookings(bookings);
    });
    isLoading = false;
  }

  List<Map<String, dynamic>> _filterBookings(List<Map<String, dynamic>> bookings) {
    if (_currentFilter == 'All') {
      return bookings;
    }  else if (_currentFilter == 'Hold') {
      return bookings.where((booking) => booking['paymentStatus'] == 'NotPaid' || booking['bookingStatus'] == 'Yet to start').toList();
    } else if (_currentFilter == 'Running') {
      return bookings.where((booking) => booking['bookingStatus'] == 'Running').toList();
    } else if(_currentFilter == 'Pending for Payment') {
      return bookings.where((booking) => booking['tripStatus'] == 'Completed' && booking['remainingBalance'] != 0).toList();
    } else if(_currentFilter == 'Completed') {
      return bookings.where((booking) => (booking['paymentStatus'] == 'Paid' || booking['paymentStatus'] == 'Completed') && booking['bookingStatus'] == 'Completed').toList();
    }
    return bookings;
  }

  void _updateFilter(String filter) {
    setState(() {
      isLoading = true;
      _currentFilter = filter;
    _fetchAndSetBookingDetails();
    _filteredBookings = _filterBookings(bookings);
    _applyDateFilter('All');
      fetchBookingsAndPartnerNames(widget.id,widget.token);
    });
  }

  void _applyDateFilter(String dateFilter) {
    final DateTime now = DateTime.now();

    List<Map<String, dynamic>> filteredBookings = _filterBookings(bookings);

    DateTime startDate;
    DateTime endDate;

    switch (dateFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
        break;

      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday));
        endDate = startDate.add(Duration(days: 6)).add(Duration(hours: 23, minutes: 59, seconds: 59));
        break;

      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1).subtract(Duration(seconds: 1));
        break;

      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1).subtract(Duration(seconds: 1));
        break;

      case 'All':
      default:
        setState(() {
          _filteredBookings = List.from(filteredBookings);
          _noBookingsFound = _filteredBookings.isEmpty;
          isLoading = false;
        });
        return;
    }

    filteredBookings = filteredBookings.where((booking) {
      try {
        DateTime bookingDate = DateTime.parse(booking['createdAt']).toLocal();
        DateTime onlyDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

        return (onlyDate.isAfter(startDate) || onlyDate.isAtSameMomentAs(startDate)) &&
            (onlyDate.isBefore(endDate) || onlyDate.isAtSameMomentAs(endDate));
      } catch (e) {
        print('Date parsing error: ${booking['createdAt']}');
        return false;
      }
    }).toList();

    setState(() {
      _filteredBookings = filteredBookings;
      _noBookingsFound = _filteredBookings.isEmpty;
      isLoading = false;
    });

    print('Filtered bookings count: ${filteredBookings.length}');
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
          preferredSize: const Size.fromHeight(150.0),
          child: Column(
            children: [
              AppBar(
                scrolledUnderElevation: 0,
                toolbarHeight: MediaQuery.of(context).size.height * 0.09,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff807BE5),
                title: Text(
                      'Booking Manager',
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
              Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               Padding(
            padding: EdgeInsets.fromLTRB(8, 20, 8, 10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.035,
              width: MediaQuery.of(context).size.width * 0.17,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allSelected ? Color(0xff6269FE) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Color(0xffBCBCBC)),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _updateFilter('Hold');
                      _currentFilter = 'Hold';
                    } else {
                      _updateFilter('All');
                      _currentFilter = 'All';
                    }

                    allSelected = !allSelected;
                    fetchBookingsAndPartnerNames(widget.id, widget.token);
                  });
                },
                child: Text(
                  'All',
                  style: TextStyle(
                    color: allSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
               Padding(
            padding: EdgeInsets.fromLTRB(8, 20, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  offset: const Offset(0, 45),
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    maxWidth: 150,
                  ),
                  icon: Icon(Icons.filter_alt_rounded),
                  onSelected: (value) {
                    setState(() {
                      _applyDateFilter(value);
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'All',
                        child: Text('All'),
                      ),
                      PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'Today',
                        child: Text('Today'),
                      ),
                      PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'This Week',
                        child: Text('This Week'),
                      ),
                      PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'This Month',
                        child: Text('This Month'),
                      ),
                      PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'This Year',
                        child: Text('This Year'),
                      ),
                    ];
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ],
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !allSelected,
            replacement: Container(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
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
                          _updateFilter('Hold');
                          // fetchBookingsAndPartnerNames(widget.id,widget.token);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentFilter == 'Hold' ? Color(0xff6269FE) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Hold',
                              style: TextStyle(
                                color: _currentFilter == 'Hold' ? Colors.white : Colors.black,
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
                          _updateFilter('Running');
                          // fetchBookingsAndPartnerNames(widget.id,widget.token);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentFilter == 'Running' ? Color(0xff6269FE) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Running',
                              style: TextStyle(
                                color: _currentFilter == 'Running' ? Colors.white : Colors.black,
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
                          _updateFilter('Pending for Payment');
                          // fetchBookingsAndPartnerNames(widget.id,widget.token);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentFilter == 'Pending for Payment' ? Color(0xff6269FE) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Pending for Payment',textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _currentFilter == 'Pending for Payment' ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async{
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
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator(),))
              : bookings.isNotEmpty
                ? Flexible(
                  child: Column(
                  children: [
                    if (_noBookingsFound)
                    Expanded(child: Center(child: Text('No bookings found.'))),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
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
                                final partnerName = snapshot.data ?? 'N/A';

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(25, 15, 25, 5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    color: Colors.white,
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                color: Color(0xff6269FE),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16)
                                                ),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Booking Id: ${booking['_id']}',
                                                    style: TextStyle(fontSize: 17,color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Positioned.fill(
                                                  top: -1,
                                                  bottom: 5,
                                                  child: Container(
                                                    color: Color(0xff6269FE),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(30),
                                                      topRight: Radius.circular(30),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15, top: 15),
                                                    child: Row(
                                                      children: [
                                                        booking['paymentStatus'] == 'HalfPaid'
                                                            ? SvgPicture.asset('assets/running.svg', height: 45)
                                                            : booking['paymentStatus'] == 'NotPaid'
                                                            ? SvgPicture.asset('assets/pending.svg', height: 45)
                                                            : SvgPicture.asset('assets/completed.svg', height: 45),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                            booking['paymentStatus'] == 'Paid'
                                                                ? 'Completed'
                                                                : '${booking['paymentStatus']??'N/A'}',
                                                            style: TextStyle(fontSize: 17),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 20,top: 15),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                'Unit',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                '${booking['unitType']??'N/A'}',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 20,top: 15),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                'Vendor',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                isLoading ? 'Loading...' :partnerName ?? 'Loading...',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      /*booking['remainingBalance'] == 0
                                                      ? Container()
                                                      : */Padding(
                                                        padding: const EdgeInsets.only(left: 20,top: 15),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                                    ? 'Payment Status' : booking['remainingBalance'] == 0 ?'':'Pending Payment',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 2,
                                                                child: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                                    ? Text('Completed', style: TextStyle(fontSize: 16,color: Colors.green))
                                                                    : booking['remainingBalance'] == 0
                                                                    ? SizedBox(height: 0,)
                                                                    : Text('${booking['remainingBalance']??'N/A'} SAR',
                                                                     style: TextStyle(fontSize: 16,color: Colors.red))
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                    ? Container()
                                                    : Expanded(
                                                    flex: 0,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: GestureDetector(
                                                                onTap: (){
                                                                  showConfirmationDialog();
                                                                },
                                                                child: SvgPicture.asset('assets/delete.svg'))
                                                        ),
                                                        Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: GestureDetector(
                                                                onTap: (){
                                                                  Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                      builder: (context) => EditBooking(
                                                                        firstName: widget.firstName,
                                                                        lastName: widget.lastName,
                                                                        token: widget.token,
                                                                        id: widget.id,
                                                                        email: widget.email,
                                                                        unitType: booking['unitType']??'',
                                                                        pickUpPoint: booking['pickup']??'',
                                                                        dropPoint: booking['dropPoints']??[],
                                                                        mode: booking['name']??'',
                                                                        modeClassification: booking['type']?.isNotEmpty ?? '' ? booking['type'][0]['typeName'] ?? 'N/A' : 'N/A',
                                                                        date: booking['date']??'',
                                                                        additionalLabour: booking['additionalLabour']??'',
                                                                        bookingId: booking['_id']??'',
                                                                        cityName: booking['cityName']??'',
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: SvgPicture.asset('assets/edit.svg'))
                                                        ),
                                                      ],
                                                    )
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20,bottom: 15),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.045,
                                                width: MediaQuery.of(context).size.width * 0.65,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                        side: BorderSide(color: Color(0xff6269FE),width: 0.5)
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    showBookingDialog(context,booking,bookingPartnerName: partnerName);
                                                  },
                                                  child: Text(
                                                    'View Booking',
                                                    style: TextStyle(
                                                      color: Color(0xff6269FE),
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          );
                        },
                      ),

                      /*ListView.builder(
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
                          final bookingPartnerName = bookings[index];
                          partnerId = booking['partner']??'N/A';
                          bookingId = booking['_id']??'N/A';
                          unit = booking['unitType']??'N/A';
                          unitType = booking['_id']??'N/A';
                          final partnerNames = bookingPartnerName['partnerName'] ?? 'Loading...';
                          bookingStatus = booking['bookingStatus']??'N/A';
                          bookingDate = booking['date']??'N/A';
                          print('partnerId''${partnerId}');
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(25, 15, 25, 5),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Colors.white,
                              elevation: 5,
                              child: Column(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Color(0xff6269FE),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16)
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Booking Id: ${booking['_id']}',
                                              style: TextStyle(fontSize: 17,color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Stack(
                                        children: [
                                          Positioned.fill(
                                            top: -1,
                                            bottom: 5,
                                            child: Container(
                                              color: Color(0xff6269FE),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15, top: 15),
                                              child: Row(
                                                children: [
                                                  booking['paymentStatus'] == 'HalfPaid'
                                                  ? SvgPicture.asset('assets/running.svg', height: 45)
                                                    : booking['paymentStatus'] == 'NotPaid'
                                                  ? SvgPicture.asset('assets/pending.svg', height: 45)
                                                  : SvgPicture.asset('assets/completed.svg', height: 45),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      booking['paymentStatus'] == 'Paid'
                                                      ? 'Completed'
                                                      : '${booking['paymentStatus']??'N/A'}',
                                                      style: TextStyle(fontSize: 17),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 15),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          'Unit',
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          '${booking['unitType']??'N/A'}',
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 15),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          'Vendor',
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          isLoading ? 'Loading...' :partnerNames ?? 'Loading...',
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 15),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                              ? 'Payment Status' : 'Pending Payment',
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                                        ? Text('Completed',
                                                          style: TextStyle(fontSize: 16,color: Colors.green))
                                                        : Text('${booking['remainingBalance']??'N/A'} SAR',
                                                          style: TextStyle(fontSize: 16,color: Colors.red))
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                                          ? Container()
                                          : Expanded(
                                              flex: 0,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: GestureDetector(
                                                        onTap: (){
                                                          showConfirmationDialog();
                                                        },
                                                          child: SvgPicture.asset('assets/delete.svg'))
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: GestureDetector(
                                                          onTap: (){
                                                            Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                builder: (context) => EditBooking(
                                                                    firstName: widget.firstName,
                                                                    lastName: widget.lastName,
                                                                    token: widget.token,
                                                                    id: widget.id,
                                                                    email: widget.email,
                                                                    unitType: booking['unitType']??'',
                                                                    pickUpPoint: booking['pickup']??'',
                                                                    dropPoint: booking['dropPoints']??[],
                                                                    mode: booking['name']??'',
                                                                    modeClassification: booking['type']?.isNotEmpty ?? '' ? booking['type'][0]['typeName'] ?? 'N/A' : 'N/A',
                                                                    date: booking['date']??'',
                                                                    additionalLabour: booking['additionalLabour']??'',
                                                                    bookingId: booking['_id']??'',
                                                                    cityName: booking['cityName']??'',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: SvgPicture.asset('assets/edit.svg'))
                                                  ),
                                                ],
                                              )
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20,bottom: 15),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.045,
                                          width: MediaQuery.of(context).size.width * 0.65,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15),
                                                  side: BorderSide(color: Color(0xff6269FE),width: 0.5)
                                              ),
                                            ),
                                            onPressed: () {
                                              showBookingDialog(context,booking,bookingPartnerName: bookingPartnerName);
                                            },
                                            child: Text(
                                              'View Booking',
                                              style: TextStyle(
                                                color: Color(0xff6269FE),
                                                fontSize: 17,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),*/
                    ),
                  ],
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

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking,{String? bookingPartnerName}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                              ? Colors.green
                              : booking['paymentStatus'] == 'HalfPaid'
                                ? Color(0xffFDAF2C)
                                : Colors.red,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.08,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Booking id: ${booking['_id']}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Unit', style: TextStyle(fontSize: 16)),
                                Text('${booking['unitType']??'N/A'}', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          Divider(indent: 5, endIndent: 5),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Unit Type', style: TextStyle(fontSize: 16)),
                                Text('${booking['name']??'N/A'}', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          Divider(indent: 5, endIndent: 5),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Vendor', style: TextStyle(fontSize: 16)),
                                Text('${bookingPartnerName??'N/A'}', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          Divider(indent: 5, endIndent: 5),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Booking status', style: TextStyle(fontSize: 16)),
                                Text('${booking['bookingStatus']??'N/A'}', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          booking['paymentStatus'] == 'Completed' || booking['paymentStatus'] == 'Paid'
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Completed',style: TextStyle(color: Colors.green,fontSize: 20),),
                          )
                          : Padding(
                            padding: const EdgeInsets.only(top: 20,bottom: 20),
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
                                  'Pay Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -15,
                right: -20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    // radius: 15,
                    child: Icon(FontAwesomeIcons.multiply, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 10),
                    child: Text(
                      'Are you sure you want to cancel?',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  if (isDeleting)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    if (!isDeleting) {
                      setState(() {
                        isDeleting = true;
                      });
                      handleDeleteBooking();
                    }
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
    );
  }

  Future<void> handleDeleteBooking() async {
    try {
      await userService.deleteBooking(context, bookingId, widget.token);
      isDeleting = false;
      Navigator.pushReplacement(
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $e')),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  void showEditBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                FontAwesomeIcons.times, // Or FontAwesomeIcons.multiply
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        buildUnitRadioList(setState),
                        Padding(
                          padding: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: pickUpPointController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xff009E10)),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xffBCBCBC), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: dropPointController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.circle,size: 15,color: Color(0xffE20808)),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xffBCBCBC), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Mode'),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xff707070)),
                                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: DropdownButton<String>(
                                          value: selectedMode,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          items: <String>['Tralia', 'Bus', 'Lorry']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedMode = newValue!;
                                              // Add logic to update the chart data based on the selected duration
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Mode\nClassification'),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xff707070)),
                                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: DropdownButton<String>(
                                          value: selectedMode,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          items: <String>['Tralia', 'Bus', 'Lorry']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedMode = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Start Date'),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  selectStartDate(context, setState);
                                },
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xffBCBCBC)),
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () => selectStartDate(context, setState),
                                        icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                                      ),
                                      Container(
                                        height: 50,
                                        child: const VerticalDivider(
                                          color: Colors.grey,
                                          thickness: 1.2,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          selectStartDate(context, setState);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              DateFormat('yyyy-MM-dd').format(_selectedStartDate),
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('End Date'),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  selectEndDate(context, setState);
                                },
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xffBCBCBC)),
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () => selectEndDate(context, setState),
                                        icon: const Icon(FontAwesomeIcons.calendar,color: Color(0xffBCBCBC)),
                                      ),
                                      Container(
                                        height: 50,
                                        child: const VerticalDivider(
                                          color: Colors.grey,
                                          thickness: 1.2,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          selectEndDate(context, setState);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              DateFormat('yyyy-MM-dd').format(_selectedEndDate),
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                                checkColor: Colors.white,
                                activeColor: const Color(0xff6A66D1),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Need Additional Labour',
                                    style:
                                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isChecked)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: const Text('1'),
                                  value: 1,
                                  groupValue: selectedLabour,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLabour = value!;
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text('2'),
                                  value: 2,
                                  groupValue: selectedLabour,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLabour = value!;
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text('3'),
                                  value: 3,
                                  groupValue: selectedLabour,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLabour = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }
          ),
        );
      },
    );
  }

  Widget buildUnitRadioList(StateSetter setState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: const Text('Vehicle', style: TextStyle(fontSize: 14)),
                  value: 1,
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  dense: true,
                  title: const Text('Bus', style: TextStyle(fontSize: 14)),
                  value: 2,
                  groupValue: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Equipment',style: TextStyle(fontSize: 14)),
                value: 3,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Special',style: TextStyle(fontSize: 14)),
                value: 4,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RadioListTile(
                dense: true,
                title: const Text('Others',style: TextStyle(fontSize: 14)),
                value: 5,
                groupValue: selectedUnit,
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> selectStartDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context, StateSetter setState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

}
