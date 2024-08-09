import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
class ViewBooking extends StatefulWidget {
  const ViewBooking({super.key});

  @override
  State<ViewBooking> createState() => _ViewBookingState();
}

class _ViewBookingState extends State<ViewBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: const Color(0xff6A66D1),
              title: const Center(
                child: Text('Booking',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                  )),
            )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:7,child: Text('Booked by')),
                          Expanded(flex:2,child: Text('Booking Id')),
                        ],
                      ),
                    ),
                     Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:7,child: Text('Khalid',style: TextStyle(color: Color(0xffAD1C86)))),
                          Expanded(flex:2,child: Text('135789458',style: TextStyle(color: Color(0xffAD1C86)))),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        side: const BorderSide(
                          color: Colors.black, // Border color
                          width: 1, // Border width
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Mode')),
                                Expanded(flex:2,child: Text('Pickup truck')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Load')),
                                Expanded(flex:2,child: Text('Auto Parts')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Date')),
                                Expanded(flex:2,child: Text('Jun 10 2022')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Time')),
                                Expanded(flex:2,child: Text('10:30 AM')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Distance')),
                                Expanded(flex:2,child: Text('50 km')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Additional Labour')),
                                Expanded(flex:2,child: Text('3')),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex:6,child: Text('Value of the Product')),
                                Expanded(flex:2,child: Text('45000 SAR')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    DottedDivider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Image.asset('assets/pickup_drop.png'),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom:40),
                                child: Text('Pickup location'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text('Destination location'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DottedDivider(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Quote Price',
                          hintStyle: TextStyle(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.057,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6A66D1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => const StepTwo()));
                                },
                                child: const Text(
                                  'Send Quote',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.057,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6F181C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => const StepTwo()));
                                },
                                child: const Text(
                                  'Cancel Quote',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashHeight;
  final Color color;

  DottedDivider({
    this.dashWidth = 4.0,
    this.dashHeight = 1.0,
    this.color = const Color(0xff707070),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
