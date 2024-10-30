import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/edit_booking.dart';
import 'package:flutter_naqli/SuperUser/Views/superUser_home_page.dart';
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
  final TextEditingController pickUpPointController = TextEditingController();
  final TextEditingController dropPointController = TextEditingController();
  String selectedMode= 'Tralia';
  String _currentFilter = 'All';
  bool isLoading = false;
  int selectedUnit = 1;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  bool isChecked = false;
  int selectedLabour = 0;

  @override
  void initState() {
    super.initState();
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
          preferredSize: const Size.fromHeight(170.0),
          child: Column(
            children: [
              AppBar(
                toolbarHeight: MediaQuery.of(context).size.height * 0.09,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff807BE5),
                title: const Text(
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
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
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
                                    'Booking Id: 34646363666467457',
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
                                        SvgPicture.asset('assets/running.svg', height: 45),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Running',
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
                                                 'N/A',
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
                                                'N/A',
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
                                                'Pending Payment',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'N/A',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 0,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset('assets/delete.svg')
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
                                                      email: widget.email
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
                                    showBookingDialog(context);
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
            ),
          ),
        ],
      ),
    );
  }

  void showBookingDialog(BuildContext context) {
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
                        color: Colors.green,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.08,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          'Booking id: 6486548748678578467287',
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
                                Text('N/A', style: TextStyle(fontSize: 16)),
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
                                Text('N/A', style: TextStyle(fontSize: 16)),
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
                                Text('N/A', style: TextStyle(fontSize: 16)),
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
                                Text('N/A', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          Padding(
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
                          ),
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
                            print("Close button tapped"); // Debug line
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

  void _updateFilter(String filter) {
    isLoading = true;
    setState(() {
      _currentFilter = filter;
      // _fetchAndSetBookingDetails();
    });
  }
}
