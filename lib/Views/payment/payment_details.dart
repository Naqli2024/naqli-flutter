import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';

import '../booking/view_booking.dart';
class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        context,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(160.0),
            child: Column(
              children: [
                AppBar(
                  toolbarHeight: 80,
                  backgroundColor: const Color(0xffA09CEC),
                  title: const Center(
                    child: Text('Payment',
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
                ),
                Container(
                  color: const Color(0xff6A66D1),
                  height: 60,
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){

                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text('All',style: TextStyle(color: Colors.white,fontSize: 15)),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){

                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Completed',style: TextStyle(color: Colors.white,fontSize: 15)),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){

                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Text('Pending Payment',style: TextStyle(color: Colors.white,fontSize: 15),),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
      drawer: createDrawer(context),
      body: ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child:  Card(
              color: Colors.white,
              shadowColor: Colors.black,
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black, // Set to transparent to show the gradient
                      width: 1.0,
                    ),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,

                  ),
                ),
                title: const Text('Booking Id: XXXXX'),
                subtitle: const Text('09 August 2024,12:00 PM'),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ViewBooking()));
                        },
                        child: const Text(
                          'View',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.normal),
                        )),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
),
    );
  }
}
