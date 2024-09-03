import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_booking.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_pendingPayment.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChooseVendor extends StatefulWidget {
  const ChooseVendor({super.key});

  @override
  State<ChooseVendor> createState() => _ChooseVendorState();
}

class _ChooseVendorState extends State<ChooseVendor> {
  final CommonWidgets commonWidgets = CommonWidgets();
  int selectedVendor = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonWidgets.commonAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  child: const GoogleMap(initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0),  // Default position
                    zoom: 1,
                  ),),
                ),
                Positioned(
                    top: 15,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                              backgroundColor: Colors.white,
                            child: IconButton(
                                onPressed: (){},
                                icon: const Icon(Icons.more_vert_outlined)),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80),
                          ),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Image.asset('assets/moving_truck.png'),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                        height: 50,
                                        width: MediaQuery.sizeOf(context).width * 0.55,
                                        child: const Text('Booking Id #343577585868')
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        contentPadding: const EdgeInsets.all(20),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 30,bottom: 10),
                                              child: Text(
                                                'Are you sure you want to cancel ?',
                                                style: TextStyle(fontSize: 19),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const CreateBooking(firstName: '',lastName: '',selectedType: '',)
                                                ),
                                              );
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
                                icon: const Icon(FontAwesomeIcons.multiply)),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 15,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      // height: MediaQuery.sizeOf(context).height * 0.1,
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Rounded corners
                          side: const BorderSide(
                            color: Color(0xffE0E0E0), // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(flex:4,child: Text(
                                          'Unit',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                                        const Expanded(flex:4,child: Text(
                                          'Diana',
                                          style: TextStyle(fontSize: 14),
                                        )),
                                        Container(
                                          height: 20,
                                          child: const VerticalDivider(
                                            color: Colors.grey,
                                            thickness: 1,
                                          ),
                                        ),
                                        const Expanded(flex:4,child: Text(
                                            'Load',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                        )),
                                        const Expanded(flex:4,child: Text(
                                          'Wood',
                                          style: TextStyle(fontSize: 14),)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(flex:4,child: Text(
                                          'Unit type',
                                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                      )),
                                      const Expanded(flex:4,child: Text(
                                        'Truck',
                                        style: TextStyle(fontSize: 14),)),
                                      Container(
                                        height: 40,
                                        child: const VerticalDivider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                      const Expanded(flex:4,child: Text(
                                          'Size',
                                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                      )),
                                      const Expanded(flex:4,child: Text(
                                        '1 to 1.5',
                                        style: TextStyle(fontSize: 14),)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ))
              ],
            ),
            Container(
              alignment: Alignment.topLeft,
              child: const Padding(
                padding: EdgeInsets.only(left: 30,top: 20,bottom: 20),
                child: Text(
                  'Choose your Vendor',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  RadioListTile(
                    title: Text('Vendor 1 XXXX SAR',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: selectedVendor == 1 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    value: 1,
                    groupValue: selectedVendor,
                    onChanged: (value) {
                      setState(() {
                        selectedVendor = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Vendor 2 XXXX SAR',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: selectedVendor == 2 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    value: 2,
                    groupValue: selectedVendor,
                    onChanged: (value) {
                      setState(() {
                        selectedVendor = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Vendor 3 XXXX SAR',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: selectedVendor == 3 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    value: 3,
                    groupValue: selectedVendor,
                    onChanged: (value) {
                      setState(() {
                        selectedVendor = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 15,top: 15),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.055,
                width: MediaQuery.of(context).size.width * 0.53,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6269FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(FontAwesomeIcons.multiply)),
                            ],
                          ),
                          content: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/confirm.svg',
                                      fit: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    const Positioned.fill(
                                      child: Center(
                                        child: Text('Thank you!',
                                          style: TextStyle(fontSize: 30),
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10,),
                                  child: Text(
                                    'Your booking is confirmed',
                                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 10,),
                                  child: Text(
                                    'with advance payment of SAR xxxx ',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Pay Advance : XXXX',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10,bottom: 15),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.055,
                width: MediaQuery.of(context).size.width * 0.53,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2229BF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PendingPayment()
                      ),
                    );
                  },
                  child: const Text(
                    'Pay : XXXX',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
