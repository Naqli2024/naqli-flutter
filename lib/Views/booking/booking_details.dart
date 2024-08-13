import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/appbar.dart';
import 'package:flutter_naqli/Views/booking/view_booking.dart';
class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              toolbarHeight: 80,
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
      drawer: createDrawer(context),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
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
              );
            }
        ),
      ),
    );
  }
}
