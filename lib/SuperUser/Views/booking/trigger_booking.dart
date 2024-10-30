import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';


class TriggerBooking extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const TriggerBooking({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<TriggerBooking> createState() => _TriggerBookingState();
}

class _TriggerBookingState extends State<TriggerBooking> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final SuperUserServices superUserServices = SuperUserServices();
  final UserService userService = UserService();
  int? selectedVendor;
  bool showCheckbox = false;
  bool isChecked = false;
  bool isLoading = false;
  bool isDeleting = false;
  List<bool> isCheckedList = List.generate(3, (index) => false);
  bool allSelected = false;
  List<dynamic> notPaidBookings = [];
  String bookingId = '';
  String unitType = '';
  String unitClassification = '';
  String subClassification = '';
  late Future<List<Map<String, dynamic>>?> _vendorsFuture;

  @override
  void initState() {
    super.initState();
    fetchBookingsData();
    fetchVendors();
  }

  Future<void> fetchBookingsData() async {
    setState(() {
      isLoading = true;
    });
    final bookingData = await superUserServices.getBookingsCount(widget.id, widget.token);
    setState(() {
      notPaidBookings = bookingData['notPaidBookings'];
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<List<Map<String, dynamic>>?> fetchVendors() {
    return userService.userVehicleVendor(
      context,
      bookingId: bookingId,
      unitType: unitType,
      unitClassification: unitClassification,
      subClassification: subClassification,
    );
  }

  Future<void> handleDeleteBooking() async {
    try {
      await userService.deleteBooking(context, bookingId, widget.token);
      await clearUserData();
      isDeleting = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuperUserHomePage(
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
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height * 0.09,
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: const Text(
                'Trigger Booking',
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
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(),)
          : RefreshIndicator(
              onRefresh: () async {
                await fetchVendors();
              },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
             child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: showCheckbox,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.035,
                      width: MediaQuery.of(context).size.width * 0.29,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: toggleSelectAll,
                        child: Text(
                          allSelected ? 'Deselect All' : 'Select All',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              notPaidBookings.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No bookings available.',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ),
                  )
                : Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notPaidBookings.length,
                    itemBuilder: (context, index) {
                      final booking = notPaidBookings[index];
                      bookingId = booking['_id'];
                      unitType = booking['unitType'];
                      unitClassification = booking['name'];
                      subClassification = booking['type']?.isNotEmpty ?? '' ? booking['type'][0]['typeName'] ?? 'N/A' : 'N/A';
                      print(unitType);
                      print(unitClassification);
                      print(subClassification);
                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            showCheckbox = true;
                          });
                        },
                        onTap: () {
                          if (showCheckbox) {
                            setState(() {
                              showCheckbox = false;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(25, 15, 25, 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Colors.white,
                                  elevation: 5,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${booking['unitType']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Booking id: ${booking['_id']}',
                                          style: TextStyle(color: Color(0xff914F9D), fontSize: 14),
                                        ),
                                      ),
                                      FutureBuilder<List<Map<String, dynamic>>?>(
                                        future: fetchVendors(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Center(child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: CircularProgressIndicator(),
                                            ));
                                          } else if (snapshot.hasError) {
                                            return Center(child: Text('Error: ${snapshot.error}'));
                                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                            return Center(child: Padding(
                                              padding: const EdgeInsets.only(top: 22,bottom: 22),
                                              child: Text('No vendors found'),
                                            ));
                                          }

                                          final vendors = snapshot.data!;
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: vendors.length,
                                            itemBuilder: (context, index) {
                                              final vendor = vendors[index];
                                              return RadioListTile(
                                                dense: true,
                                                fillColor: MaterialStateProperty.resolveWith<Color>(
                                                      (Set<MaterialState> states) {
                                                    if (states.contains(MaterialState.selected)) {
                                                      return Color(0xff6269FE);
                                                    }
                                                    return Color(0xff707070);
                                                  },
                                                ),
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        vendor['partnerName'] ?? 'No Partner Name',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        '${vendor['quotePrice'] ?? 'N/A'} SAR',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                value: index + 1,
                                                groupValue: selectedVendor,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedVendor = value!;
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20,bottom: 20),
                                        child: GestureDetector(
                                          onTap: () {
                                             showConfirmationDialog();
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.red, fontSize: 17),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 35,
                                left: 40,
                                child: showCheckbox
                                    ? Checkbox(
                                  value: isCheckedList[index],
                                  onChanged: (value) {
                                    setState(() {
                                      isCheckedList[index] = value!;
                                    });
                                  },
                                )
                                    : CircleAvatar(
                                  backgroundColor: Color(0xff572727),
                                  minRadius: 6,
                                  maxRadius: double.maxFinite,
                                ),
                              ),
                              Positioned(
                                top: 60,
                                left: 20,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(9, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xffD4D4D4),
                                        radius: 9,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
                    ),
                  ),
          ),


      bottomNavigationBar: Visibility(
        visible: showCheckbox,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff6269FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: (){},
          child: Container(
            color: Color(0xff6269FE),
            height: MediaQuery.of(context).size.height * 0.07,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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

  void toggleSelectAll() {
    setState(() {
      allSelected = !allSelected;
      for (int i = 0; i < isCheckedList.length; i++) {
        isCheckedList[i] = allSelected;
      }
    });
  }
}
