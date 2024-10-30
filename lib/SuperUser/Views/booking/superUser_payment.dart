import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
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
  Future<List<Map<String, dynamic>>>? _bookingDetailsFuture;
  String _currentFilter = 'All';
  bool isLoading = false;

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
                        child: Text('Bookings'),
                      ),
                      PopupMenuDivider(),
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
                            _updateFilter('Running');
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
                            _updateFilter('Pending');
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
      body: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Card(
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 3.0,
                    child: ListTile(
                      title: Text('Booking Id: 8797970080675568879'),
                      subtitle: Row(
                        children: [
                          Text('date'),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('time'),
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
                              showBookingDialog(context);
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
              },
            ),
    );
  }

  void showBookingDialog(BuildContext context) {
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
                                    '6697900867564465',
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
                                    'N/A',
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
                                    'N/A',
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
                                    'N/A',
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
                        border:Border.all(color:  Colors.red,),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text('N/A',style: const TextStyle(fontSize: 19)),
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
              Text('Total Paid',style: const TextStyle(fontSize: 19)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('46,586 SAR',style: const TextStyle(fontSize: 19)),
              )
            ],
          ),
        );
      },
    );
  }


  void _updateFilter(String filter) {
    isLoading = true;
    setState(() {
      _currentFilter = filter;
      // _fetchAndSetBookingDetails();
    });
  }
}
